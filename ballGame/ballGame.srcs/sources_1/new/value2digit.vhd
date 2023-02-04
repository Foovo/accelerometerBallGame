--Izziv 4: display number on the correct segment

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity value2digit is
    Port ( anode : in STD_LOGIC_VECTOR(3 downto 0);
           value : in STD_LOGIC_VECTOR (15 downto 0);
           digit : out STD_LOGIC_VECTOR (3 downto 0));
end entity;

architecture Behavioral of value2digit is
    signal anode_value : std_logic_vector(3 downto 0) := "0000";
begin   
    get_digit: process(anode)
    begin
        if anode(3) = '0' then                  --first segment
            anode_value <= value(15 downto 12);
        elsif anode(2) = '0' then               --second segment
            anode_value <= value(11 downto 8);
        elsif anode(1) = '0' then               --third segment
            anode_value <= value(7 downto 4);
        else
            anode_value <= value(3 downto 0); --fourth segment
        end if;
        
        digit <= anode_value;
    end process;
    

end Behavioral;
