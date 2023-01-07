----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.01.2023 22:55:35
-- Design Name: 
-- Module Name: axdl_test_tb - Behavioral
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

entity axdl_test_tb is
--  Port ( );
end axdl_test_tb;

architecture Behavioral of axdl_test_tb is
    constant sys_clk_period : time := 10 ns;
    constant spi_clk_period : time := 1 us;
    
    -- input
    signal reset: std_logic := '1';
    signal clk: std_logic := '0';
    signal miso: std_logic := '1';

    signal sim_accel_data_1 : std_logic_vector(23 downto 0) := X"cdab12";
    signal sim_accel_data_2 : std_logic_vector(23 downto 0) := X"deadbe";
    
    -- driven
    signal mosi: std_logic;
    signal sclk: std_logic;
    signal cs: std_logic;
    signal leds: std_logic_vector(7 downto 0);
begin
    UUT: entity work.adxl_test(Behavioral)
    Port map(
        CLK100MHZ => clk,
        CPU_RESETN => reset,
        LED => leds,
        ACL_MISO => miso,
        ACL_MOSI => mosi,
        ACL_SCLK => sclk,
        ACL_CSN => cs 
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
        reset <= '0';
        wait for sys_clk_period * 3;
        reset <= '1';
        wait for sys_clk_period * 3;
        wait for sys_clk_period;
        
        -- Wait set read command, set register address
        wait for spi_clk_period * 16;
        
        for i in 23 downto 0 loop
            miso <= sim_accel_data_1(i);
            wait for spi_clk_period;
        end loop;
        
        
        -- Second time
        miso <= '1';
        wait for spi_clk_period * 16;
        
        for i in 23 downto 0 loop
            miso <= sim_accel_data_2(i);
            wait for spi_clk_period;
        end loop;

        
        wait;   
    end process;

end Behavioral;
