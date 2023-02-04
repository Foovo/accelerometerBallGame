-- game logic

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity game is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           ce : in STD_LOGIC;
           up : in STD_LOGIC;
           down : in STD_LOGIC;
           left : in STD_LOGIC;
           right : in STD_LOGIC;
           finish : in STD_LOGIC; --game is over
           pause : in STD_LOGIC;  --pause game
           coordX : out unsigned(9 downto 0);
           coordY : out unsigned(9 downto 0));
end game;

architecture Behavioral of game is
    constant xRange : integer := 639;
    constant yRange : integer := 479;

    --start position (10,10)
    signal x : unsigned(9 downto 0) := "0000001010";
    signal y : unsigned(9 downto 0) := "0000001010";
    
    signal oldX : unsigned(9 downto 0) := "0000001010";
    signal oldY : unsigned(9 downto 0) := "0000001010";
    
    signal u : std_logic := '0';
    signal d : std_logic := '0';
    signal l : std_logic := '0';
    signal r : std_logic := '0';
    
    signal ballSize : integer := 4;
    
begin

    
    logic: process (clk)
    begin
        if rising_edge(clk) then
        
            coordX <= x;
            coordY <= y;
            
            -- Sinhroni reset
            if reset = '1' then
                x <= "0000001010";
                y <= "0000001010";
                u <= '0';
                d <= '0';
                l <= '0';
                r <= '0';
                
                oldX <= x;
                oldY <= y;
            
            -- move to new position
            elsif ce = '1' and finish = '0' and pause = '1' then
                
                if up = '1' and y > 4 + ballSize then
                    u <= '1';
                    oldX <= x;
                    oldY <= y - 1 - ballSize;
                    
                elsif down = '1' and y < yRange - ballSize then
                    d <= '1';
                    oldX <= x;
                    oldY <= y + 1 + ballSize;
                    
                elsif right = '1' and x < xRange - ballSize then
                    r <= '1';
                    oldY <= y;
                    oldX <= x + 1 + ballSize;
                    
                elsif left = '1' and x > 1 + ballSize then
                    l <= '1';
                    oldY <= y;
                    oldX <= x - 1 - ballSize;
                end if;
                
                --check if coordinate is valid
                if (oldX > 420 and oldY < 80) or (((oldX > 420 and oldX < 500) or oldX > 600) and oldY < 230)
                    or (oldX > 520 and oldX < 560 and oldY < 230 and oldY > 100)
                    or (oldY > 200 and oldY < 230 and ((oldX > 300 and oldX <= 420) or oldX < 100 or (oldX > 180 and oldX < 270) or (oldX >= 560 and oldX <= 600)))
                    or (oldY >= 230 and oldX < 100)
                    or (oldX < 400 and oldY > 100 and oldY < 180)
                    or (oldX > 180 and oldX < 200 and oldY >= 180 and oldY <= 200)
                    or (oldY < 70 and oldX >= 200)
                    or (oldY > 390 and oldX < 210)
                    or (oldY > 390 and oldY < 440 and oldX > 250)
                    or (oldY > 250 and oldY < 260 and ((oldX > 180 and oldX < 220) or (oldX > 260 and oldX < 560) or oldX > 600))
                    or (oldX > 180 and oldX < 220 and oldY >= 250 and oldY < 350)
                    or (oldY >= 310 and oldY < 350 and ((oldX >= 220 and oldX <= 440) or (oldX > 470)))
                    or (oldY >= 260 and oldY < 280 and oldX > 260 and oldX < 370)
                    or (oldY > 280 and oldY < 310 and ((oldX > 420 and oldX <= 440) or (oldX > 470 and oldX < 500) or (oldX > 520 and x < 560) or (x > 600)))
                    or (oldY > 270 and oldY <= 280 and x > 400 and x < 500) then
                   
                   --coord is invalid, restore original value
                    if u = '1' then
                        y <= oldY + 1 + ballSize;
                        u <= '0';
                        
                    elsif d = '1' then
                        y <= oldY - 1 - ballSize;
                        d <= '0';
                        
                    elsif l = '1' then
                        x <= oldX + 1 + ballSize;
                        l <= '0';
                        
                    elsif r = '1' then
                        x <= oldX - 1 - ballSize;
                        r <= '0';
                    end if;
                 
                
                    --coord is valid   
                    else 
                        if u = '1' then
                            y <= oldY + ballSize;
                            u <= '0';
                        elsif d = '1' then
                            y <= oldY - ballSize;
                            d <= '0';
                        elsif l = '1' then
                            x <= oldX + ballSize;
                            l <= '0';
                        elsif r = '1' then
                            x <= oldX - ballSize;
                            r <= '0';
                        end if;
                    end if;
         
            end if;
        end if;
    end process;
 
end Behavioral;
