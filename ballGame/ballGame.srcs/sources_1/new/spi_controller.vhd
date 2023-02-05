
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity spi_controller is
    generic(
        sclk_freq   : integer := 1e6;
        word_length : integer := 8
    );
    port(
        reset       : in std_logic;
        clk         : in std_logic;
        cs          : out std_logic;
        miso        : in std_logic;
        mosi        : out std_logic;
        sclk        : out std_logic;
        tx_start    : in std_logic;
        tx_continue : in std_logic;
        tx_busy     : out std_logic;
        tx_byte     : in std_logic_vector(word_length-1 downto 0);
        rx_byte     : out std_logic_vector(word_length-1 downto 0)
    );
end spi_controller;

architecture Behavioral of spi_controller is
    -- state machine
        -- idle: waiting for tx_start
        -- spi_tx_rx: in transaction
    type spi_state is(spi_idle, spi_tx_rx);
    signal current_state       : spi_state;
    
    -- sclk generation
    constant f_clk_sys : integer := 100e6; --100MHz    
    constant sclk_limit_freq : integer := f_clk_sys / (sclk_freq * 2);

    signal sclk_limit : integer := sclk_limit_freq - 1;
    signal sclk_prescaler_count : integer range 0 to sclk_limit_freq;
    
    signal sclk_edge_count : integer range 0 to word_length * 2 + 1;
    constant sclk_edges : integer := word_length * 2;
    

    signal rx_tx_bit, extend_tx: std_logic;    
   
    signal i_sclk, i_cs : std_logic;
    signal i_rx_byte, i_tx_byte : std_logic_vector(word_length-1 downto 0);
begin
    sclk <= i_sclk;
    cs <= i_cs;

    spi_control: process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                tx_busy <= '1';

                i_cs <= '1';
                mosi <= '1';
                i_sclk <= '0';

                rx_byte <= (others => '0');

                current_state <= spi_idle;
            else
                case current_state is
    
                    when spi_idle =>
                        tx_busy <= '0';
                        extend_tx <= '0';

                        i_cs <= '1';
                        mosi <= '1';
                        i_sclk <= '0';
        
                        if tx_start = '1' then
                            tx_busy <= '1';

                            sclk_prescaler_count <= sclk_limit;
                            sclk_edge_count <= 0;
                            
                            rx_tx_bit <= '1'; -- First tx

                            i_tx_byte <= tx_byte;
                            
                            current_state <= spi_tx_rx;
                        else
                            current_state <= spi_idle;
                        end if;
        
                    when spi_tx_rx =>
                        tx_busy <= '1';
                        i_cs <= '0';
        
                        if sclk_prescaler_count = sclk_limit then
                            sclk_prescaler_count <= 1;

                            -- Count edge
                            if sclk_edge_count = sclk_edges + 1 then
                                sclk_edge_count <= 0;
                            else
                                sclk_edge_count <= sclk_edge_count + 1;
                            end if;
        
                            -- Toggle sclk
                            if sclk_edge_count <= sclk_edges and i_cs = '0' then
                                i_sclk <= not i_sclk;
                            end if;
        
                            -- Tx/Rx bit
                            if rx_tx_bit = '1' then
                                if sclk_edge_count < sclk_edges - 1 then
                                    mosi <= i_tx_byte(word_length-1);
                                    i_tx_byte <= i_tx_byte(word_length-2 downto 0) & '0';
                                end if;
                            else
                                if sclk_edge_count < sclk_edges then
                                    i_rx_byte <= i_rx_byte(word_length-2 downto 0) & miso;
                                end if;
                            end if;
                            
                            rx_tx_bit <= not rx_tx_bit;
        
                            -- Check if extended transaction
                            if sclk_edge_count = sclk_edges - 1 and tx_continue = '1' then
                                extend_tx <= '1';
                                
                                sclk_edge_count <= 0;
                                
                                i_tx_byte <= tx_byte;
                            end if;
        
                            -- Signal first transaction end
                            if extend_tx = '1' then
                                tx_busy <= '0';

                                extend_tx <= '0';
                                rx_byte <= i_rx_byte;
                            end if;
        
                            -- Finish
                            if (sclk_edge_count = sclk_edges + 1) and tx_continue = '0' then
                                tx_busy <= '0';
                                
                                i_cs <= '1';
                                mosi <= '1';
                                
                                rx_byte <= i_rx_byte;
                                
                                current_state <= spi_idle;
                            else
                                current_state <= spi_tx_rx;
                            end if;
        
                        else
                            sclk_prescaler_count <= sclk_prescaler_count + 1;
                            current_state <= spi_tx_rx;
                        end if;
        
                end case;
            end if;
        end if;
    end process;
end Behavioral;
