library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity axdl362 is
    port(
        reset        : in      std_logic;
        clk            : in      std_logic;
        cs           : out  std_logic;
        miso           : in      std_logic;
        mosi           : out     std_logic;
        sclk           : out  std_logic;
        acc_x : out     std_logic_vector(11 downto 0);
        acc_y : out     std_logic_vector(11 downto 0);
        acc_z : out     std_logic_vector(11 downto 0)
    );
end axdl362;

architecture Behavioral of axdl362 is
    -- state machine:
        -- idle: reset state
        -- init: initialize procedure
        -- write byte: write byte for init
        -- read acc: read 2x3 bytes of accel data
        -- finish: output data
    type adxl_state is (
        adxl_idle,
        adxl_init,
        adxl_write_byte,
        adxl_read_acc,
        adxl_finish
    );
    
    signal current_state : adxl_state;

    -- Initialization
    type adxl_init_stage is (
        adxl_init_filter,
        adxl_init_power,
        adxl_init_finish
    );

    signal init_stage : adxl_init_stage;
    signal init_addr, init_setting : std_logic_vector(7 downto 0);

    constant adxl_reg_filter_addr : std_logic_vector(7 downto 0)
        := X"2C";
    constant adxl_reg_filter_setting : std_logic_vector(7 downto 0)
        := "00010011"; -- Range +- 2g, half_bw, odr 100Hz

    constant adxl_reg_power_addr : std_logic_vector(7 downto 0)
        := X"2D";
    constant adxl_reg_power_setting : std_logic_vector(7 downto 0)
        := "00000010"; -- Normal measurement

    -- Write byte
    constant adxl_command_write : std_logic_vector(7 downto 0) := X"0A";

    -- Read data
    constant adxl_command_read : std_logic_vector(7 downto 0) := X"0B";
    constant adxl_reg_data_addr : std_logic_vector(7 downto 0) := X"0E";

    -- CS hold
    signal cs_hold_ce, cs_hold_reset : std_logic;

    signal tx_start, tx_continue, i_tx_busy, tx_busy :  std_logic;

    signal tx_byte, rx_byte : std_logic_vector(7 downto 0);

    signal i_acc_x, i_acc_y, i_acc_z : std_logic_vector(15 downto 0);
begin
    spi_controller: entity work.spi_controller(Behavioral)
        port map(
            reset => reset,
            clk => clk,
            cs => cs,
            miso => miso,
            mosi => mosi,
            sclk => sclk,
            tx_start => tx_start,
            tx_continue => tx_continue,
            tx_busy => tx_busy,
            tx_byte => tx_byte,
            rx_byte => rx_byte
        );

    cs_hold: entity work.prescaler(Behavioral)
        generic map(
            n => 8,
            frequency => 5e6 -- 200ns
        )
        port map ( 
            clk => clk,
            reset => cs_hold_reset,
            clock_enable => cs_hold_ce
        );

    cs_hold_reset <= '1' when current_state /= adxl_init or tx_busy = '1' else '0';

    process(clk)
        variable byte_count : integer := 0;
    begin            
        if rising_edge(clk) then
            if reset = '1' then
                i_tx_busy <= '0';
                
                tx_byte <= (others => '0');
                tx_start <= '0';
                tx_continue <= '0';
                
                acc_x <= (others => '0');
                acc_y <= (others => '0');
                acc_z <= (others => '0');
                
                current_state <= adxl_idle;
                init_stage <= adxl_init_filter;
            else
                -- Count tx bytes - busy falling edge
                i_tx_busy <= tx_busy;
                if i_tx_busy = '1' and tx_busy = '0' then
                    byte_count := byte_count + 1;
                end if;
    
                case current_state is
                    when adxl_idle =>
                        current_state <= adxl_init;
                        init_stage <= adxl_init_filter;

                        byte_count := 0;
    
                    when adxl_init =>
                        current_state <= adxl_init;    

                        if cs_hold_ce = '1' then
                            byte_count := 0;

                            case init_stage is
                                when adxl_init_filter =>
                                    init_addr <= adxl_reg_filter_addr;
                                    init_setting <= adxl_reg_filter_setting;

                                    init_stage <= adxl_init_power;
                                    current_state <= adxl_write_byte;

                                when adxl_init_power =>
                                    init_addr <= adxl_reg_power_addr;
                                    init_setting <= adxl_reg_power_setting;

                                    init_stage <= adxl_init_finish;
                                    current_state <= adxl_write_byte;

                                when adxl_init_finish =>
                                    current_state <= adxl_read_acc;

                            end case;
                        end if;
    
                    when adxl_write_byte =>
                        case byte_count is
                            when 0 =>
                                -- Start spi and write command
                                if(tx_busy = '0') then
                                    tx_continue <= '1';
                                    tx_start <= '1';
                                    tx_byte <= adxl_command_write;
                                else
                                -- Write address
                                    tx_byte <= init_addr;
                                end if;
                            
                            when 1 =>
                                -- Write settings
                                tx_byte <= init_setting;
                            
                            when 2 =>
                                -- Finish
                                tx_start <= '0';
                                tx_continue <= '0';

                                byte_count := 0;
                                
                                current_state <= adxl_init;
                                
                            when others =>
                        end case;
    
    
                    when adxl_read_acc =>
                        case byte_count is
                            when 0 =>
                                -- Start spi and read command
                                if(tx_busy = '0') then
                                    tx_continue <= '1';
                                    tx_start <= '1';
                                    tx_byte <= adxl_command_read;
                                else
                                    -- Write read address
                                    tx_byte <= adxl_reg_data_addr;
                                end if;
                                
                            -- Burst read 6 bytes
                            when 1 =>
                                tx_byte <= (others => '0');
                            when 3 =>
                                i_acc_x(7 downto 0) <= rx_byte;
                            when 4 =>
                                i_acc_x(15 downto 8) <= rx_byte;
                            when 5 =>
                                i_acc_y(7 downto 0) <= rx_byte;
                            when 6 =>
                                i_acc_y(15 downto 8) <= rx_byte;
                            when 7 =>
                                i_acc_z(7 downto 0) <= rx_byte;
                                -- Finish burst read
                                tx_continue <= '0';
                                tx_start <= '0';
                                
                            when 8 =>
                                i_acc_z(15 downto 8) <= rx_byte;
                                
                                -- Finish
                                byte_count := 0;
                                current_state <= adxl_finish;
                            
                            when others =>
                        end case;
    
    
                    when adxl_finish =>
                        acc_x <= i_acc_x(11 downto 0);
                        acc_y <= i_acc_y(11 downto 0);
                        acc_z <= i_acc_z(11 downto 0);

                        current_state <= adxl_init;
                end case;      
            end if;
        end if;
    end process;
end Behavioral;
