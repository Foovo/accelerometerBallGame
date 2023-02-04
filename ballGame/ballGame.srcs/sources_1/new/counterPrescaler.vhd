--Izziv04: Prescaler

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity counterPrescaler is
    generic (n : integer := 32);
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           anode_ce : out STD_LOGIC;
           val_ce : out STD_LOGIC);
end entity;

architecture Behavioral of counterPrescaler is
    constant f_clk_sys : integer := 100e6; --100MHz
    constant f_clk_anode : integer := 250; --1/4ms
    constant f_clk_value : integer := 1; --1 sec

--SIMULATION CONSTANTS
--    constant f_clk_sys : integer := 10; --100MHz
--    constant f_clk_anode : integer := 5; --1/4ms
--    constant f_clk_value : integer := 1; --1 sec
    
    constant limit_anode : integer := f_clk_sys/f_clk_anode -1;
    constant limit_value : integer := f_clk_sys/f_clk_value -1;
    
    signal prescaler_val_anode : unsigned(n-1 downto 0) := (others => '0'); --change anode
    signal prescaler_val_num : unsigned(n-1 downto 0) := (others => '0');   --increment number after 1 sec
    
    signal prescaler_limit_anode : unsigned(n-1 downto 0) := (others => '0');
    signal prescaler_limit_value : unsigned(n-1 downto 0) := (others => '0');
begin

    prescaler_limit_anode <= to_unsigned(limit_anode, prescaler_limit_anode'length);
    prescaler_limit_value <= to_unsigned(limit_value, prescaler_limit_value'length);
    
    prescaler: process(clk)
    begin
        if rising_edge(clk) then
            --reset should be synchronous
            if reset = '1' then
                prescaler_val_anode <= (others => '0');
                prescaler_val_num <= (others => '0');
                anode_ce <= '0';
                val_ce <= '0';
            end if;
            
            --anode counter
            if prescaler_val_anode >= prescaler_limit_anode then
                prescaler_val_anode <= (others => '0');
                anode_ce <= '1';
            else
                prescaler_val_anode <= prescaler_val_anode + 1;
                anode_ce <= '0';
            end if;
            
            --value to display counter
            if prescaler_val_num >= prescaler_limit_value then
                prescaler_val_num <= (others => '0');
                val_ce <= '1';              
            else
                prescaler_val_num <= prescaler_val_num + 1;
                val_ce <= '0';
            end if;
        end if;
    end process;

end Behavioral;
