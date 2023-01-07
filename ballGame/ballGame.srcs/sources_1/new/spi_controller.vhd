library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity spi_controller is
    generic (
        sclk_freq : integer := 1e6
    );
    Port (
        reset : in STD_LOGIC;
        clk : in STD_LOGIC;
        cs : out STD_LOGIC;
        miso : in STD_LOGIC;
        mosi : out STD_LOGIC;
        sclk : out STD_LOGIC;
        tx_start : in STD_LOGIC;
        tx_finished: out STD_LOGIC;
        rx_byte : out STD_LOGIC_VECTOR (7 downto 0);
        tx_byte : in STD_LOGIC_VECTOR (7 downto 0)
   );
end spi_controller;

architecture Behavioral of spi_controller is
    -- spi clock generation
    constant sclk_gen_freq : integer := sclk_freq * 2;
    signal sclk_gen_reset, sclk_gen_ce : std_logic;
    
    -- state machine
        -- idle: waiting for tx_start
        -- tx: first half of sclk, put bit on mosi
        -- rx: second half of sclk, read bit from miso
    type spi_state is (spi_idle, spi_tx, spi_rx);
    signal current_state, next_state : spi_state;
    
    -- internal outputs
    signal i_cs, i_mosi, i_sclk, i_tx_finished : std_logic;
    signal i_tx_byte, i_rx_byte : std_logic_vector(7 downto 0);
    
    signal tx_bit : unsigned(2 downto 0);
    signal rx_buf : std_logic_vector(7 downto 0);
begin
    sclk_gen_reset <= '1' when reset = '1' or current_state = spi_idle else '0';

    sclk_gen_prescaler: entity work.prescaler(Behavioral)
        generic map (
            n => 8,
            frequency => sclk_gen_freq
        )
        port map( 
            clk => clk,
            reset => sclk_gen_reset,
            clock_enable => sclk_gen_ce
        );

    avtomat: process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then 
                cs <= '1';
                mosi <= '1';
                sclk <= '1';
                tx_finished <= '0';
                rx_byte <= (others => '0');
                
                current_state <= spi_idle;
            else
                cs <= i_cs;
                mosi <= i_mosi;
                sclk <= i_sclk;
                tx_finished <= i_tx_finished;
                rx_byte <= i_rx_byte;
                
                current_state <= next_state;
            end if;
        end if;
    end process;
    
    izhodi: process(current_state, tx_start, sclk_gen_ce)
    begin
        case current_state is
            when spi_idle =>
                -- default
                i_cs <= '1';
                i_mosi <= '1';
                i_sclk <= '1';
                i_tx_finished <= '0';
                tx_bit <= (others => '0');

                -- Start transmition
                if tx_start = '1' then
                    i_cs <= '0';
                    i_sclk <= '0';
                    i_tx_byte <= tx_byte;
                    next_state <= spi_tx;
                end if;
                
            when spi_tx =>
                i_cs <= '0';
                i_sclk <= '0';
                
                -- Tx bit
                i_mosi <= i_tx_byte(7);
                i_tx_byte(7 downto 1) <= i_tx_byte(6 downto 0);
                next_state <= spi_rx;
                
            when spi_rx =>
                if sclk_gen_ce = '1' then
                    -- First half pulse = read bit
                    if i_sclk = '0' then
                        i_sclk <= '1';

                        -- Rx bit
                        rx_buf(7 downto 1) <= rx_buf(6 downto 0);
                        rx_buf(0) <= miso;
                    -- Second half pulse = tx bit or finish
                    else
                        if tx_bit = to_unsigned(7, tx_bit'length) then
                            next_state <= spi_idle;
                            i_rx_byte <= rx_buf;
                            i_tx_finished <= '1';
                        else
                            next_state <= spi_tx;
                            tx_bit <= tx_bit + 1;
                        end if;
                    end if;      
                end if;
            end case;
    end process;
end Behavioral;








