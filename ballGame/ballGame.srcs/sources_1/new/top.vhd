
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
    constant frequency : integer := 100;
    
    --komponente
    component prescaler is
        generic (n : integer;
                 frequency : integer);
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
           display: out STD_LOGIC;
           row:     out UNSIGNED(9 downto 0);
           vsync : out STD_LOGIC);
    end component;
    
    component display is
    Port ( display_h : in STD_LOGIC;
           display_v : in STD_LOGIC;
           row : in UNSIGNED(9 downto 0);
           column : in UNSIGNED(9 downto 0);
           ballX : in UNSIGNED(9 downto 0);
           ballY : in UNSIGNED(9 downto 0);
           VGA_R : out STD_LOGIC_VECTOR (3 downto 0);
           VGA_G : out STD_LOGIC_VECTOR (3 downto 0);
           VGA_B : out STD_LOGIC_VECTOR (3 downto 0));
    end component;
    
    component game is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           ce : in STD_LOGIC;
           up : in STD_LOGIC;
           down : in STD_LOGIC;
           left : in STD_LOGIC;
           right : in STD_LOGIC;
           coordX : out UNSIGNED(9 downto 0);
           coordY : out UNSIGNED(9 downto 0));
    end component;
    
    --notranji signali
    signal clock_enable: std_logic;
    
    signal count_enable: std_logic;
    signal displayh, displayv: std_logic;
    signal column, row: unsigned(9 downto 0);
    
    signal labirint: std_logic;
    signal ball: std_logic;
    signal ballX: unsigned(9 downto 0);
    signal ballY: unsigned(9 downto 0);
    
begin
    presc_inst: prescaler
        generic map (
                  n => prescaler_size,
                  frequency => frequency)
        port map (clk => CLK100MHZ,
                  reset => not CPU_RESETN,
                  clock_enable    => clock_enable);
                  
    hsync_inst: HSYNC_MODULE
        port map(
            clk     =>  CLK100MHZ,
            reset   =>  not CPU_RESETN,
            ce      =>  count_enable,
            display =>  displayh,
            column  =>  column,
            hsync   =>  VGA_HS
        );

    vsync_inst: VSYNC_MODULE
        port map(
            clk     =>  CLK100MHZ,
            reset   =>  not CPU_RESETN,
            ce      =>  count_enable,
            display =>  displayv,
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
        
    display_inst: display
        port map(
           display_h => displayh,
           display_v => displayv,
           row => row,
           column => column,
           ballX => ballX,
           ballY => ballY,
           VGA_R => VGA_R,
           VGA_G => VGA_G,
           VGA_B => VGA_B);
    


end Behavioral;
