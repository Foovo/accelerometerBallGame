
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
           coordX : out unsigned(9 downto 0);
           coordY : out unsigned(9 downto 0));
end game;

architecture Behavioral of game is
    constant xRange : integer := 639;
    constant yRange : integer := 479;

    --start position (10,10)
    signal x : unsigned(9 downto 0) := "0000001010";
    signal y : unsigned(9 downto 0) := "0000001110";
    
    signal u : std_logic := '0';
    signal d : std_logic := '0';
    signal l : std_logic := '0';
    signal r : std_logic := '0';
    
    signal ballSize : integer := 4;
    
begin
    
    logic: process (clk)
    begin
        if rising_edge(clk) then
            -- Sinhroni reset
            if reset = '1' then
                x <= "0000001010";
                y <= "0000001110";
                u <= '0';
                d <= '0';
                l <= '0';
                r <= '0';
                
                coordX <= x;
                coordY <= y;
                
            elsif ce = '1' then
                if up = '1' and y > 4 + ballSize then
                    u <= '1';
                    y <= y - 1 - ballSize;
                elsif down = '1' and y < yRange - ballSize then
                    d <= '1';
                    y <= y + 1 + ballSize;
                elsif right = '1' and x < xRange - ballSize then
                    r <= '1';
                    x <= x + 1 + ballSize;
                elsif left = '1' and x > 1 + ballSize then
                    l <= '1';
                    x <= x - 1 - ballSize;
                end if;
                
                --check if coordinate is valid
                if (x > 420 and y < 80) or (((x > 420 and x < 500) or x > 600) and y < 230)
                    or (x > 520 and x < 560 and y < 230 and y > 100)
                    or (y > 200 and y < 230 and ((x > 300 and x <= 420) or x < 100 or (x > 180 and x < 270) or (x >= 560 and x <= 600)))
                    or (y >= 230 and x < 100)
                    or (x < 400 and y > 100 and y < 180)
                    or (x > 180 and x < 200 and y >= 180 and y <= 200)
                    or (y < 70 and x >= 200)
                    or (y > 390 and x < 210)
                    or (y > 390 and y < 440 and x > 250)
                    or (y > 250 and y < 260 and ((x > 180 and x < 220) or (x > 260 and x < 560) or x > 600))
                    or (x > 180 and x < 220 and y >= 250 and y < 350)
                    or (y >= 310 and y < 350 and ((x >= 220 and x <= 440) or (x > 470)))
                    or (y >= 260 and y < 280 and x > 260 and x < 370)
                    or (y > 280 and y < 310 and ((x > 420 and x <= 440) or (x > 470 and x < 500) or (x > 520 and x < 560) or (x > 600)))
                    or (y > 270 and y <= 280 and x > 400 and x < 500) then
                   
                   --coord is invalid, restore original value
                    if u = '1' then
                        y <= y + 1 + ballSize;
                        --coordY <= y;
                        u <= '0';
                    elsif d = '1' then
                        y <= y - 1 - ballSize;
                        --coordY <= y;
                        d <= '0';
                    elsif l = '1' then
                        x <= x + 1 + ballSize;
                        --coordX <= x;
                        l <= '0';
                    elsif r = '1' then
                        x <= x - 1 - ballSize;
                        --coordX <= x;
                        r <= '0';
                    end if;
                    
                    
                
                --coord is valid   
                else 
                    if u = '1' then
                        y <= y + ballSize;
                        --coordY <= y;
                        u <= '0';
                    elsif d = '1' then
                        y <= y - ballSize;
                        --coordY <= y;
                        d <= '0';
                    elsif l = '1' then
                        x <= x + ballSize;
                        --coordX <= x;
                        l <= '0';
                    elsif r = '1' then
                        x <= x - ballSize;
                        --coordX <= x;
                        r <= '0';
                    end if;
                    
                end if;
                coordX <= x;
                coordY <= y;
                
                
                
            end if;
        end if;
    end process;
    

end Behavioral;
