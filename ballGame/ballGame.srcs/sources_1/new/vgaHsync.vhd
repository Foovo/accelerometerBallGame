----------------------------------------------------------------------------------
-- Krmilnik za VGA: generiranje signala HSYNC
-- Create Date: 19.10.2022
-- Modified:    2.11.2022
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vgaHsync is
    port (
        clk:      in  std_logic;
        reset:    in  std_logic;
        ce:       out std_logic;            -- konec vrstice, omogoèimo štetje za vsync
        display:  out std_logic;            -- ali smo v "display area"
        column:   out unsigned(9 downto 0); -- odmik slikovne toèke (indeks) v vodoravni smeri 
        hsync :   out std_logic);
end entity;

architecture Behavioral of vgaHsync is
    ----------------------------------------------------------------------------------
    -- KONSTANTE
    ----------------------------------------------------------------------------------
    -- Konstante pomnožimo s 4, ker je sistemska ura (100 MHz) 4x hitrejša od frekvence 
    -- izrisa slikovnih toèk pri standardu 640x480@60Hz, ki je 25 MHz.
    -- Alternativa: uporaba "prescaler"-ja
    constant SP : integer := 96*4;  -- Sync pulse
    constant BP : integer := 48*4;  -- Back porch
    constant FP: integer := 16*4;   -- Front porch
    constant T  : integer := 800*4; -- Hsync period time

    ----------------------------------------------------------------------------------
    -- NOTRANJI SIGNALI
    ----------------------------------------------------------------------------------
    signal count: unsigned(11 downto 0);  -- 12 bitov za vrednost števca, ki šteje do 4*800-1
    signal sync_on, sync_off, q: std_logic;
    signal reset_counter: std_logic;
    signal display_on: std_logic;
    signal column_i: unsigned(11 downto 0);

begin
    ----------------------------------------------------------------------------------
    -- VZPOREDNI STAVKI
    ----------------------------------------------------------------------------------
    -- Prirejanje V/I 
    ce <= sync_off;
    hsync <= q;
    display <= display_on;
    column <= column_i(9 downto 0);

    -- Primerjalnik za SP-1, ko damo sync_on na '1'
    sync_on <= '1' when count = SP-1 else '0';

    -- Ugotavljanje, kdaj smo v t.i. "display area" - obmoèju izrisa na zaslon  
    display_on <= '1' when (count >= SP + BP) and (count < (T-FP)) else '0';

    -- Preslikava vrednosti števca count na indeks slikovne toèke column 
    column_i <= (count - (SP + BP))/4 when display_on='1' else (others => '0');

    -- Ponastavitev vezja
    reset_counter <= reset or sync_off;

    ----------------------------------------------------------------------------------
    -- ZAPOREDNI DEL = PROCESI
    ----------------------------------------------------------------------------------
    Counter: process (clk)
    begin
        if rising_edge(clk) then
            -- Sinhroni reset
            if reset_counter='1' then
                count <= (others => '0'); -- postavi vrednost števca na '0'
            else
                count <= count + 1;
            end if;
        end if;
    end process;


    -- Namenoma smo za ta primerjalnik uporabili proces, da pokažemo,
    -- da se odloèitveno vezje lahko opiše tudi v procesu.
    primerjalnik_T: process (count)
    begin
        if count = T-1 then
            sync_off <= '1';
        else
            sync_off <= '0';
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
                    -- v našem primeru do tega scenarija nikoli ne pride
                    q <= not q;
                else
                    -- to je lahko tudi implicitno
                    q <= q;
                end if;
            end if;
        end if;
    end process;
end Behavioral;
