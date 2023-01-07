--Ball Game: Prescaler

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity prescaler is
    generic (
        n : integer := 27;
        frequency: integer
    );
    Port ( 
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        clock_enable : out STD_LOGIC
    );
end entity;

architecture Behavioral of prescaler is
    constant f_clk_sys : integer := 100e6; --100MHz    
    constant limit_freq : integer := f_clk_sys/frequency -1;
    
    signal prescaler_val : unsigned(n-1 downto 0) := (others => '0');
    signal prescaler_limit : unsigned(n-1 downto 0);
begin
    prescaler_limit <= to_unsigned(limit_freq, prescaler_limit'length);
    
    prescaler: process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                prescaler_val <= (others => '0');
                clock_enable <= '0';
            else
                if prescaler_val >= prescaler_limit then
                    prescaler_val <= (others => '0');
                    clock_enable <= '1';
                else
                    prescaler_val <= prescaler_val + 1;
                    clock_enable <= '0';
                end if;
            end if;
        end if;
    end process;

end Behavioral;
