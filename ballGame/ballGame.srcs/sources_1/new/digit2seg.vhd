--Izziv 4: number to cathodes

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity digit2seg is
    Port ( digit : in STD_LOGIC_VECTOR (3 downto 0);
           cathode : out STD_LOGIC_VECTOR(6 downto 0));
end entity;

architecture Behavioral of digit2seg is
    
begin
    
    set_cathode: process(digit)
    begin
        if digit = "0000" then                      --0
            cathode <= (6 => '1', others => '0');
        elsif digit = "0001" then                   --1
            cathode <= (1 => '0', 2 => '0', others => '1');
        elsif digit = "0010" then                   --2
            cathode <= (2 => '1', 5 => '1', others => '0');
        elsif digit = "0011" then                   --3
            cathode <= (4 => '1', 5 => '1', others => '0');
        elsif digit = "0100" then                   --4
            cathode <= (0 => '1', 3 => '1', 4 => '1', others => '0');
        elsif digit = "0101" then                   --5
            cathode <= (1 => '1', 4 => '1', others => '0');
        elsif digit = "0110" then                   --6
            cathode <= (1 => '1', others => '0');        
        elsif digit = "0111" then                   --7
            cathode <= (0 => '0', 1 => '0', 2 => '0', others => '1');
        elsif digit = "1000" then                   --8
            cathode <= (others => '0');
        elsif digit = "1001" then                   --9
            cathode <= (4 => '1', others => '0');
        elsif digit = "1010" then                   --a
            cathode <= (3 => '1', others => '0');
        elsif digit = "1011" then                   --b
            cathode <= (0 => '1', 1 => '1', others => '0');
        elsif digit = "1100" then                   --c
            cathode <= (1 => '1', 2 => '1', 6 => '1', others => '0');
        elsif digit = "1101" then                   --d
            cathode <= (0 => '1', 5 => '1', others => '0');
        elsif digit = "1110" then                   --e
            cathode <= (1 => '1', 2 => '1', others => '0');
        elsif digit = "1111" then                   --f
            cathode <= (1 => '1', 2 => '1', 3 => '1', others => '0');
        end if;
    end process;

end Behavioral;
