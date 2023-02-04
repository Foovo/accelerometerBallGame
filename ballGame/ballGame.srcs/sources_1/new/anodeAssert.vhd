--Izziv4 : anode_assert

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity anodeAssert is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           ce : in STD_LOGIC;
           anode : out STD_LOGIC_VECTOR(3 downto 0);
           anode_value : out STD_LOGIC_VECTOR(3 downto 0)); --vhdl does not allow mapping into 2 different lines
end entity;

architecture Behavioral of anodeAssert is
    signal anode_status : std_logic_vector(3 downto 0) := "1110";
begin
    select_anode: process(clk)
    begin
        anode <= anode_status;
        anode_value <= anode_status;
        if rising_edge(clk) then
            --reset should be synchronous
            if reset = '1' then
                anode_status <= (0 => '0', others => '1');
            end if;
            if ce = '1' then
                anode_status <= std_logic_vector(unsigned(anode_status) ROL 1);
            end if;
        end if;
    
    end process;

end Behavioral;
