
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity axdl362_tb is
    
end axdl362_tb;

architecture Behavioral of axdl362_tb is
    constant sys_clk_period : time := 10 ns;
    constant spi_clk_period : time := 1 us;
    
    -- input
    signal reset: std_logic := '0';
    signal clk: std_logic := '0';
    signal miso: std_logic := '1';
    signal accel_start: std_logic := '0';

    signal sim_accel_data_1 : std_logic_vector(23 downto 0) := X"cdab12";
    signal sim_accel_data_2 : std_logic_vector(23 downto 0) := X"deadbe";
    
    -- driven
    signal mosi: std_logic;
    signal sclk: std_logic;
    signal cs: std_logic;
    signal new_data_strobe: std_logic;
    signal acc_x, acc_y, acc_z: std_logic_vector(7 downto 0);
begin
    UUT: entity work.axdl362(Behavioral)
        Port map (
            reset => reset,
            clk => clk,
            cs => cs,
            miso => miso,
            mosi => mosi,
            sclk => sclk,
            accel_start => accel_start,
            new_data_strobe => new_data_strobe,
            acc_x => acc_x,
            acc_y => acc_y,
            acc_z => acc_z
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
        accel_start <= '1';
        wait for sys_clk_period;
        accel_start <= '0';
        
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






