--Module for display

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity display is
    Port ( reset : in STD_LOGIC;
           display_h : in STD_LOGIC;
           display_v : in STD_LOGIC;
           row : in UNSIGNED(9 downto 0);
           column : in UNSIGNED(9 downto 0);
           ballX : in UNSIGNED(9 downto 0);
           ballY : in UNSIGNED(9 downto 0);
           finish : in STD_LOGIC;     --out of time
           endOfGame : out STD_LOGIC; --won the game
           VGA_R : out STD_LOGIC_VECTOR (3 downto 0);
           VGA_G : out STD_LOGIC_VECTOR (3 downto 0);
           VGA_B : out STD_LOGIC_VECTOR (3 downto 0));
end display;

architecture Behavioral of display is

    signal display : STD_LOGIC;
    signal labirint: std_logic;
    signal cilj : std_logic;
    
    signal ball: std_logic;
  
    signal sign : std_logic := '0';  
    signal win : std_logic := '0'; 
    
begin 
    
    maze: process (row, column)
    begin
        display <= display_h and display_v;
        endOfGame <= win;
        
        if reset = '1' then
            win <= '0';
                    
        elsif win = '0' then
            -- labirint
            if display='1' and (row=4 or row=479 or column=1 or column=639 -- border
                or (column > 420 and row < 80) or (((column > 420 and column < 500) or column > 600) and row < 230)
                or (column > 520 and column < 560 and row < 230 and row > 100)
                or (row > 200 and row < 230 and ((column > 300 and column <= 420) or column < 100 or (column > 180 and column < 270) or (column >= 560 and column <= 600)))
                or (row >= 230 and column < 100)
                or (column < 400 and row > 100 and row < 180)
                or (column > 180 and column < 200 and row >= 180 and row <= 200)
                or (row < 70 and column >= 200)
                or (row > 390 and column < 210)
                or (row > 390 and row < 440 and column > 250)
                or (row > 250 and row < 260 and ((column > 180 and column < 220) or (column > 260 and column < 560) or column > 600))
                or (column > 180 and column < 220 and row >= 250 and row < 350)
                or (row >= 310 and row < 350 and ((column >= 220 and column <= 440) or (column > 470)))
                or (row >= 260 and row < 280 and column > 260 and column < 370)
                or (row > 280 and row < 310 and ((column > 420 and column <= 440) or (column > 470 and column < 500) or (column > 520 and column < 560) or (column > 600)))
                or (row > 270 and row <= 280 and column > 400 and column < 500)) 
            then
                labirint <= '1';
            else 
                labirint <= '0';
            end if;
            
            --ciljno polje
            if display <= '1' and ((((row > 445 and row < 450) or (row > 469 and row < 474)) and column > 605 and column < 634) or
            (row >= 450 and row <= 469 and ((column > 605 and column < 610) or (column > 629 and column < 634)))) then
                cilj <= '1';
            else
                cilj <= '0';
            end if;
            
            --shape of ball (size 4)
            if display='1' and ((ballX = column and ballY = row) or(ballX = column-1 and ballY = row) or
                 (ballX = column-2 and ballY = row) or(ballX = column-3 and ballY = row) or
                 (ballX = column-4 and ballY = row) or(ballX = column-1 and ballY = row-1) or
                 (ballX = column-2 and ballY = row-1) or(ballX = column-3 and ballY = row-1)or
                 (ballX = column-2 and ballY = row-2) or(ballX = column-1 and ballY = row-2) or
                 (ballX = column-1 and ballY = row-3) or(ballX = column+1 and ballY = row) or
                 (ballX = column+2 and ballY = row) or(ballX = column and ballY = row-3) or 
                 (ballX = column and ballY = row-4) or(ballX = column and ballY = row+3) or 
                 (ballX = column and ballY = row+4) or(ballX = column+1 and ballY = row+1) or
                 (ballX = column+1 and ballY = row+2) or(ballX = column+1 and ballY = row+3) or
                 (ballX = column+2 and ballY = row+1) or(ballX = column+2 and ballY = row+2) or
                 (ballX = column+3 and ballY = row) or(ballX = column+3 and ballY = row+1) or
                 (ballX = column+4 and ballY = row) or(ballX = column+1 and ballY = row-2) or
                 (ballX = column+1 and ballY = row-3) or(ballX = column+2 and ballY = row-1) or
                 (ballX = column+2 and ballY = row-2) or (ballX = column+3 and ballY = row-1) or
                 (ballX = column-2 and ballY = row+1) or(ballX = column-3 and ballY = row+1)or
                 (ballX = column-2 and ballY = row+2) or(ballX = column-1 and ballY = row+2) or
                 (ballX = column-1 and ballY = row+3) or(ballX = column+1 and ballY = row-1) or
                 (ballX = column-1 and ballY = row+1) or(ballX = column and ballY = row+1) or
                 (ballX = column and ballY = row+2) or(ballX = column and ballY = row-1) or
                 (ballX = column and ballY = row-2))
            then 
                ball <= '1';
            else 
                ball <= '0';
            end if;            
                        
            if labirint = '1' then
                VGA_R <= "1111";
                VGA_G <= "1111";
                VGA_B <= "0000";
                
            elsif ball = '1' then
                VGA_R <= "1111";
                VGA_G <= "1111";
                VGA_B <= "1111";
                
            elsif cilj = '1' then
                VGA_R <= "0000";
                VGA_G <= "0000";
                VGA_B <= "1111"; 
                   
            else 
                VGA_R <= "0000";
                VGA_G <= "0000";
                VGA_B <= "0000";
            end if;
            
            if ballY > 450 and ballY < 469 and ballX > 610 and ballX < 629 then
                win <= '1';
            end if;
            
        --finish screen - YOU WIN!
        else
            if display = '1' and (
            --Y and top O,U,W,I,N,!
            (row > 140 and row <= 153 and ((column > 88 and column < 109) or (column > 123 and column < 144) or (column > 157 and column < 205) or 
            (column > 218 and column < 234) or (column > 258 and column < 274) or (column > 298 and column < 314) or (column > 338 and column < 354)
            or (column > 363 and column < 419) or (column > 428 and column < 450) or (column > 462 and column < 484)
            or (column > 497 and column < 545))) or 
            
            (row > 153 and row <= 192 and ((column > 86 and column < 111) or (column > 121 and column < 146) or (column > 155 and column < 207))) or
            (row > 192 and row <= 205 and ((column > 88 and column < 144) or (column > 153 and column < 209))) or
            (row > 205 and row <= 218 and ((column > 90 and column < 142))) or
            (row > 218 and row <= 231 and ((column > 92 and column < 140))) or
            (row > 231 and row <= 340 and ((column > 100 and column < 132))) or
            
            --O
            (((row > 179 and row <= 215) or (row > 265 and row <= 301)) and (column > 151 and column < 211)) or --O
            (row > 215 and row <= 265 and ((column > 151 and column < 176) or (column > 186 and column < 211))) or
            (row > 301 and row <= 314 and ((column > 153 and column < 209) or (column > 218 and column < 274))) or --bottom u
            (row > 314 and row <= 327 and ((column > 155 and column < 207) or (column > 220 and column < 272))) or --bottom u
            (row > 327 and row <= 340 and ((column > 157 and column < 205) or (column > 222 and column < 270))) or --bottom u
            
            --U
            (row > 153 and row <= 281 and ((column > 216 and column < 236) or (column > 256 and column < 276))) or
            (row > 281 and row <= 301 and ((column > 216 and column < 276))) or
            
            --W
            (row > 153 and row <= 197 and ((column > 296 and column < 316) or (column > 336 and column < 356))) or
            (row > 175 and row <= 188 and ((column > 324 and column < 328))) or
            (row > 188 and row <= 201 and ((column > 322 and column < 330))) or
            (row > 201 and row <= 214 and ((column > 316 and column < 318) or (column > 320 and column < 332) or (column > 334 and column < 336))) or
            (row > 197 and row <= 236 and ((column > 298 and column < 354))) or
            (row > 236 and row <= 262 and ((column > 300 and column < 352))) or
            (row > 262 and row <= 301 and ((column > 302 and column < 350))) or
            (row > 301 and row <= 340 and ((column > 304 and column < 319) or (column > 333 and column < 348))) or
            
            -- I
            (row > 153 and row <= 188 and ((column > 361 and column < 421))) or
            (row > 188 and row <= 305 and ((column > 375 and column < 406))) or
            (row > 305 and row <= 340 and ((column > 361 and column < 421))) or
            
            --N
            (row > 153 and row <= 340 and ((column > 426 and column < 452) or (column > 460 and column < 486))) or
            (row > 153 and row <= 321 and ((column >= 452 and column <= 454))) or
            (row > 168 and row <= 331 and ((column > 454 and column <= 456))) or
            (row > 170 and row <= 336 and ((column > 456 and column <= 458))) or
            (row > 172 and row <= 338 and ((column > 458 and column <= 460))) or
            
            --!
            (row > 153 and row <= 166 and ((column > 495 and column < 547))) or
            (row > 166 and row <= 179 and ((column > 493 and column < 549))) or
            (row > 179 and row <= 265 and ((column > 491 and column < 551))) or
            (((row > 265 and row <= 285) or (row > 295 and row <= 340)) and ((column > 496 and column < 546)))
            )then
                sign <= '1';
            else
                sign <= '0';
            end if; 
            
            
            if sign = '1' then
                VGA_R <= "1111";
                VGA_G <= "1111";
                VGA_B <= "0000";
            end if;
                                
        end if;
    end process;   

end Behavioral;
