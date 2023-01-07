library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity adxl_test is
  Port (
    CLK100MHZ: in std_logic;
    CPU_RESETN: in std_logic;
    LED: out std_logic_vector(7 downto 0);
    ACL_MISO: in std_logic;
    ACL_MOSI: out std_logic;
    ACL_SCLK: out std_logic;
    ACL_CSN: out std_logic;
    LED_reset: out std_logic;
    LED_cs: out std_logic;
    LED_miso: out std_logic;
    LED_mosi: out std_logic;
    LED_sclk: out std_logic;
    JA_cs: out std_logic;
    JA_miso: out std_logic;
    JA_mosi: out std_logic;
    JA_sclk: out std_logic
  );
end adxl_test;

architecture Behavioral of adxl_test is
    signal reset : std_logic;
    signal led_bits : std_logic_vector(7 downto 0);
    signal accel_start : std_logic;
    signal new_data_strobe : std_logic;
    signal acc_x, acc_y, acc_z: std_logic_vector(7 downto 0);
    
    signal cs, miso, mosi, sclk : std_logic;
begin
    reset <= '1' when CPU_RESETN = '0' else '0';
    miso <= ACL_MISO;
    ACL_CSN <= cs;
    ACL_MOSI <= mosi;
    ACL_SCLK <= sclk;
    
    LED_reset <= reset;
    LED_cs <= cs;
    LED_miso <= miso;
    LED_mosi <= mosi;
    LED_sclk <= sclk;
    LED <= led_bits;
    
    JA_cs <= cs;
    JA_miso <= miso;
    JA_mosi <= mosi;
    JA_sclk <= sclk;

    axdl362: entity work.axdl362(Behavioral)
        Port map (
            reset => reset,
            clk => CLK100MHZ,
            cs => cs,
            miso => miso,
            mosi => mosi,
            sclk => sclk,
            accel_start => accel_start,
            new_data_strobe => new_data_strobe,
            acc_x => acc_x,
            acc_y => acc_y,
            acc_z => acc_z
       );
       
    led_mapping: process(CLK100MHZ)
    begin
        if rising_edge(CLK100MHZ) then
            if reset = '1' then
                accel_start <= '0';
                led_bits <= (others => '1');
            else
                accel_start <= '1';
                if new_data_strobe = '1' then
                    led_bits <= acc_x;
                end if;
            end if;
        end if;
    end process;

end Behavioral;
