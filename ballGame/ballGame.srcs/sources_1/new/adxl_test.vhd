library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity adxl_test is
  Port (
    CLK100MHZ: in std_logic;
    CPU_RESETN: in std_logic;
    LED: out std_logic_vector(11 downto 0);
    ACL_MISO: in std_logic;
    ACL_MOSI: out std_logic;
    ACL_SCLK: out std_logic;
    ACL_CSN: out std_logic;
--    JA_cs: out std_logic;
--    JA_miso: out std_logic;
--    JA_mosi: out std_logic;
--    JA_sclk: out std_logic;
    SW: in std_logic_vector(1 downto 0)
  );
end adxl_test;

architecture Behavioral of adxl_test is
    signal reset : std_logic;
    signal accel_start : std_logic;
    signal acc_x, acc_y, acc_z: std_logic_vector(11 downto 0);
    
    signal cs, miso, mosi, sclk : std_logic;
begin
    reset <= '1' when CPU_RESETN = '0' else '0';
    
    miso <= ACL_MISO;
    ACL_CSN <= cs;
    ACL_MOSI <= mosi;
    ACL_SCLK <= sclk;



    LED <= acc_x when sw = "10" else
           acc_y when sw = "01" else
           acc_z when sw = "11" else
           (others => '0');
    
--    JA_cs <= cs;
--    JA_miso <= miso;
--    JA_mosi <= mosi;
--    JA_sclk <= sclk;

    axdl362: entity work.axdl362(Behavioral)
        Port map (
            clk => CLK100MHZ,
            reset => reset,
            miso => miso,
            sclk => sclk,
            cs => cs,
            mosi => mosi, 
            acc_x => acc_x,
            acc_y => acc_y,
            acc_z => acc_z
       );
       
    

end Behavioral;
