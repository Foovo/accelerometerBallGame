----------------------------------------------------------------------------------
-- Krmilnik za VGA: generiranje signala VSYNC
-- Create Date: 2.11.2022
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vgaVsync is
    port ( 
         clk:     in  std_logic;
         reset:   in  std_logic;
         ce:      in  std_logic;            -- clock enable: kdaj štejemo
         display: out std_logic;
         row:     out unsigned(9 downto 0); -- indeks vrstice
         vsync:   out std_logic);
end entity;


architecture Behavioral of vgaVsync is
    ----------------------------------------------------------------------------------
    -- KONSTANTE
    ----------------------------------------------------------------------------------
    constant SP: integer := 2;   -- Sync pulse
    constant BP: integer := 29;  -- Back porch
    constant FP: integer := 10;  -- Front porch
    constant T:  integer := 521; -- Vsync period time
    
    ----------------------------------------------------------------------------------
    -- NOTRANJI SIGNALI
    ----------------------------------------------------------------------------------
    signal count: unsigned(9 downto 0);  -- 10 bitov za vrednost števca, ki šteje do 520
    signal sync_on, sync_off, q: std_logic;
    signal reset_counter: std_logic;
    signal display_on: std_logic; 
    
begin
    ----------------------------------------------------------------------------------
    -- VZPOREDNI DEL
    ----------------------------------------------------------------------------------
    -- Prirejanje V/I
    vsync <= q;
    display <= display_on;
    
    -- Primerjalniki za SP-1 in T-1 
    -- V pogoj dodamo še visok signal "ce", sicer se VSYNC spremeni ob 
    -- naslednji pozitivni fronti sistemske ure, kar je prezgodaj (glej simulacijo)
    sync_on <= '1' when count = SP-1 and ce='1' else '0';
    sync_off <= '1' when count = T-1 and ce='1' else '0';
        
    -- Ugotavljanje, kdaj smo v t.i. "display area" - obmoèju izrisa na zaslon  
    display_on <= '1' when (count >= SP + BP) and (count < (T-FP)) else '0';
    
    -- Preslikava vrednosti števca count na indeks vrstice row 
    row <= count - (SP + BP) when display_on='1' else (others => '0');
    
    -- Ponastavitev vezja
    reset_counter <= reset or sync_off;

    ----------------------------------------------------------------------------------
    -- ZAPOREDNI DEL = PROCESI
    ----------------------------------------------------------------------------------

    Counter: process (clk)
    begin
        if rising_edge(clk) then
            -- sinhroni reset
            if reset_counter='1' then
                count <= (others => '0'); -- postavi count na '0'
            else
                -- Samo, ko je clock enable visok, štejemo gor.
                if ce='1' then
                    count <= count + 1;
                end if;
            end if;
        end if;
    end process;
    
    JK_pomnilna_celica: process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                q <= '0';
            else
                if sync_on = '1' and sync_off = '0' then
                    q <= '1';
                elsif sync_on = '0' and sync_off = '1' then
                    q <= '0';
                elsif sync_on = '1' and sync_off = '1' then
                    q <= not q;
                else
                    q <= q;
                end if;
            end if;
        end if;
    end process;

end Behavioral;
