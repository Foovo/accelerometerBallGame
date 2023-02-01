--test bench of game module

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

entity game_tb is
--  Port ( );
end game_tb;

architecture Behavioral of game_tb is

    constant clock_period : time := 10 ns;
    
    component game is
        Port ( clk : in STD_LOGIC;
               reset : in STD_LOGIC;
               ce : in STD_LOGIC;
               up : in STD_LOGIC;
               down : in STD_LOGIC;
               left : in STD_LOGIC;
               right : in STD_LOGIC;
               coordX : out unsigned(9 downto 0);
               coordY : out unsigned(9 downto 0));
    end component;
    
    signal clk, reset, up, down, right, left : std_logic := '0';
    signal ce : std_logic := '1';
   
    signal x: unsigned(9 downto 0) := "0010111110";
    signal y : unsigned(9 downto 0) := "0000001010";
    
    
begin

    UUT: game
        port map (clk => clk,
                  reset => reset,
                  ce => ce,
                   up => up,
                   down => down,
                   left => left,
                   right => right,
                   coordX => x,
                   coordY => y);
       
        
    --generate stimuli
    --Stimulus for clock
    clock: process
    begin
        clk <= '0';
        wait for clock_period/2;
        clk <= '1';
        wait for clock_period/2;
    end process;
    
    --other stimuli
    stimuli: process
    begin
        
        reset <= '0';
        
        --long reset
        reset <= '1';
        wait for clock_period*3;
        
        --withdraw reset
        reset <= '0';
        wait for clock_period*3;
        
        --up
        up <= '1';
        wait for clock_period*10;
        
        --down
        up <= '0';
        down <= '1';
        wait for clock_period*10;
        
        --right
        down <= '0';
        right <= '1';
        wait for clock_period*30;
        
        right <= '0';
        left <= '1';
        wait for clock_period*10;
        
        left <= '0';
        wait;
    
    end process;
    
    
end Behavioral;
