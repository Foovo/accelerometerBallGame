
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;



entity player_control is
    Port (
        clk: in std_logic;
        reset: in std_logic;
        miso: in std_logic;
        mosi: out std_logic;
        sclk: out std_logic;
        cs: out std_logic;
        up : out STD_LOGIC;
        down : out STD_LOGIC;
        left : out STD_LOGIC;
        right : out STD_LOGIC
    );
end player_control;

architecture Behavioral of player_control is
    signal acc_x, acc_y, acc_z: std_logic_vector(11 downto 0);
    
    constant positive_trigger_threshold : signed := to_signed(64, acc_x'length);
    constant negative_trigger_threshold : signed := to_signed(-64, acc_x'length);
    
    signal i_up, i_down, i_left, i_right : std_logic;
begin
    axdl362: entity work.axdl362(Behavioral)
    Port map (
        clk => clk,
        reset => reset,
        miso => miso,
        sclk => sclk,
        cs => cs,
        mosi => mosi, 
        acc_x => acc_x,
        acc_y => acc_y,
        acc_z => acc_z
    );
    
    up <= i_up;
    down <= i_down;
    left <= i_left;
    right <= i_right;

    tilting: process(acc_x, acc_y)
    begin
        if abs(signed(acc_x)) > abs(signed(acc_y)) then
            i_left <= '0';
            i_right <= '0';
            if signed(acc_x) < negative_trigger_threshold then
                i_up <= '1';
            else
                i_up <= '0';
            end if;
            
            if signed(acc_x) > positive_trigger_threshold then
                i_down <= '1';
            else
                i_down <= '0';
            end if;
        else
            i_up <= '0';
            i_down <= '0';
            if signed(acc_y) < negative_trigger_threshold then
                i_right <= '1';
            else
                i_right <= '0';
            end if;
            
            if signed(acc_y) > positive_trigger_threshold then
                i_left <= '1';
            else
                i_left <= '0';
            end if;
        end if; 
    end process;

end Behavioral;
