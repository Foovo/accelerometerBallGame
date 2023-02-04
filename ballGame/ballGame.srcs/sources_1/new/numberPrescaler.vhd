--Izziv 4: increment numbers that will be displayed on the 7-segment dispay every 1 second

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity numberPrescaler is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           button : in STD_LOGIC;
           val_ce : in STD_LOGIC;
           endOfGame : in STD_LOGIC;
           finish : out STD_LOGIC;
           value : out STD_LOGIC_VECTOR (15 downto 0));
end entity;

architecture Behavioral of numberPrescaler is
    --start value is 60 seconds
    signal counter : unsigned(15 downto 0) := "0000000000111100";
    signal finished : std_logic := '0';
begin

    count: process(clk)
    begin
        value <= std_logic_vector(counter);
        finish <= finished;
        
        if rising_edge(clk) then
            if reset = '1' then
                counter <= "0000000000111100";
                finished <= '0';
            end if;
            
            if val_ce = '1' and button = '1' and endOfGame = '0' then
                if counter <= 0 then
                    finished <= '1';
                elsif finished = '0' then
                    counter <= counter - 1; 
                else 
                    counter <= counter;
                end if;
            end if;
        end if;
            
    end process;
end Behavioral;
