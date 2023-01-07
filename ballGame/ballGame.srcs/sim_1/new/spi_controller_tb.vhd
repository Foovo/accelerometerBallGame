----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.01.2023 17:45:08
-- Design Name: 
-- Module Name: spi_controller_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity spi_controller_tb is
    
end spi_controller_tb;

architecture Behavioral of spi_controller_tb is
    constant sys_clk_period : time := 10 ns;
    constant spi_clk_period : time := 1 us;
    
    -- input
    signal reset: std_logic := '0';
    signal clk: std_logic := '0';
    signal miso: std_logic := '1';
    signal tx_start: std_logic := '0';
    signal tx_byte: std_logic_vector(7 downto 0) := "11001010";

    signal sim_rx_byte: std_logic_vector(7 downto 0) := "01101010";
    
    -- driven
    signal mosi: std_logic;
    signal sclk: std_logic;
    signal tx_finished: std_logic;
    signal cs: std_logic;
    signal rx_byte: std_logic_vector(7 downto 0);

begin
    UUT: entity work.spi_controller(Behavioral)
        Port map (
            reset => reset,
            clk => clk,
            cs => cs,
            miso => miso,
            mosi => mosi,
            sclk => sclk,
            tx_start => tx_start,
            tx_finished => tx_finished,
            rx_byte => rx_byte,
            tx_byte => tx_byte
       );

    sys_clk: process
    begin 
        clk <= '1';
        wait for sys_clk_period/2;
        clk <= '0';
        wait for sys_clk_period/2;
    end process;
    
    stim: process
    
    begin
        reset <= '1';
        wait for sys_clk_period * 3;
        reset <= '0';
        wait for sys_clk_period * 3;
        tx_start <= '1';
        wait for sys_clk_period;
        
        for i in 7 downto 0 loop
            miso <= sim_rx_byte(i);
            wait for spi_clk_period;
        end loop;
        
        wait for spi_clk_period * 8;
        
        tx_start <= '0';

        
        wait;   
    end process;


end Behavioral;






