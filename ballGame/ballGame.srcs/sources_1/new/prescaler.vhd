--Ball Game: Prescaler

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity prescaler is
    generic (n : integer := 27);
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           speed : in STD_LOGIC;
           ce : out STD_LOGIC);
end entity;

architecture Behavioral of prescaler is
    constant f_clk_sys : integer := 100e6; --100MHz
    constant f_clk_slow : integer := 1;
    constant f_clk_fast : integer := 2;
    
    constant limit_slow : integer := f_clk_sys/f_clk_slow -1;
    constant limit_fast : integer := f_clk_sys/f_clk_fast -1;
    
    signal prescaler_val : unsigned(n-1 downto 0) := (others => '0');
    signal prescaler_limit : unsigned(n-1 downto 0) := (others => '0');
begin

    prescaler_limit <= to_unsigned(limit_slow, prescaler_limit'length) when speed = '0' 
                        else to_unsigned(limit_fast, prescaler_limit'length);
    
    prescaler: process(clk)
    begin
        if rising_edge(clk) then
            --reset should be synchronous
            if reset = '1' then
                prescaler_val <= (others => '0');
                ce <= '0';
            end if;
            if prescaler_val >= prescaler_limit then
                prescaler_val <= (others => '0');
                ce <= '1';
            else
                prescaler_val <= prescaler_val + 1;
                ce <= '0';
            end if;
        end if;
    end process;

end Behavioral;
