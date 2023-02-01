
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top is
    Port ( CLK100MHZ : in STD_LOGIC;
           CPU_RESETN : in STD_LOGIC;
           up : in STD_LOGIC;
           down : in STD_LOGIC;
           left : in STD_LOGIC;
           right : in STD_LOGIC;
           VGA_HS : out STD_LOGIC;
           VGA_VS : out STD_LOGIC;
           VGA_R : out STD_LOGIC_VECTOR (3 downto 0);
           VGA_G : out STD_LOGIC_VECTOR (3 downto 0);
           VGA_B : out STD_LOGIC_VECTOR (3 downto 0));
end top;

architecture Behavioral of top is
    --konstante
    constant prescaler_size : integer := 27;
    
    --komponente
    component prescaler is
        generic (n : integer := 27);
        Port ( clk : in STD_LOGIC;
               reset : in STD_LOGIC;
               clock_enable : out STD_LOGIC);
    end component;
    
    component HSYNC_MODULE is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           ce: out STD_LOGIC; --count enable for vsync
           display:  out std_logic;
           column:   out unsigned(9 downto 0);
           hsync : out STD_LOGIC);
    end component;
    
    component VSYNC_MODULE is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           ce : in STD_LOGIC; --Clock enable -> kdaj steje
           display: out std_logic;
           row:     out unsigned(9 downto 0);
           vsync : out STD_LOGIC);
    end component;
    
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
    
    --notranji signali
    signal clock_enable: std_logic;
    
    signal count_enable: std_logic;
    signal display_h, display_v, display: std_logic;
    signal column, row: unsigned(9 downto 0);
    
    signal labirint: std_logic;
    signal ball: std_logic;
    signal ballX: unsigned(9 downto 0);
    signal ballY: unsigned(9 downto 0);
    
begin
    presc_inst: prescaler
        generic map (n => prescaler_size)
        port map (clk => CLK100MHZ,
                  reset => not CPU_RESETN,
                  clock_enable    => clock_enable);
                  
    hsync_inst: HSYNC_MODULE
        port map(
            clk     =>  CLK100MHZ,
            reset   =>  not CPU_RESETN,
            ce      =>  count_enable,
            display =>  display_h,
            column  =>  column,
            hsync   =>  VGA_HS
        );

    vsync_inst: VSYNC_MODULE
        port map(
            clk     =>  CLK100MHZ,
            reset   =>  not CPU_RESETN,
            ce      =>  count_enable,
            display =>  display_v,
            row     =>  row,
            vsync   =>  VGA_VS
        );
    
    game_inst: game
        port map(
           clk      => CLK100MHZ,
           reset    => not CPU_RESETN,
           ce       => clock_enable,
           up       => up,
           down     => down,
           left     => left,
           right    => right,
           coordX   => ballX,
           coordY   => ballY
        );
    ----------------------------------------------------------------------------------
    -- Logika za prikazovanje na zaslonu 
    ----------------------------------------------------------------------------------

    -- Kdaj lahko aktiviramo el. topove
    display <= display_h and display_v;

    -- labirint
    labirint <= '1' when display='1' and (row=4 or row=479 or column=1 or column=639 -- border
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
                or (row > 270 and row <= 280 and column > 400 and column < 500)
                ) 
                else '0';
    
    --shape of ball (size 4)
    ball <= '1' when (ballX = column and ballY = row) or(ballX = column-1 and ballY = row) or
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
                     (ballX = column and ballY = row-2)
                else '0';
       
    VGA_R <= "1111" when labirint='1' 
                    else "1111" when ball = '1'
                    else "0000";
    VGA_G <= "1111" when labirint='1' 
                    else "1111" when ball = '1'
                    else "0000";
    VGA_B <= "0000" when labirint='1' 
                    else "1111" when ball = '1'
                    else "0000";
    
    

end Behavioral;
