----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.01.2023 16:01:27
-- Design Name: 
-- Module Name: axdl362 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity axdl362 is
    Port ( 
        reset : in STD_LOGIC;
        clk : in STD_LOGIC;
        cs : out STD_LOGIC;
        miso : in STD_LOGIC;
        mosi : out STD_LOGIC;
        sclk : out STD_LOGIC;
        accel_start : in STD_LOGIC;
        new_data_strobe : out STD_LOGIC;
        acc_x : out STD_LOGIC_VECTOR (7 downto 0);
        acc_y : out STD_LOGIC_VECTOR (7 downto 0);
        acc_z : out STD_LOGIC_VECTOR (7 downto 0)
    );
end axdl362;

architecture Behavioral of axdl362 is
    -- State machine
    type state_type is (
        idle,
        write_command_read, wait_command_read, wait_addr_reg,
        read_x, read_y, read_z,
        cs_hold_1, cs_hold_2, cs_hold_3, cs_hold_4
    );
    signal current_state, next_state : state_type;
    signal i_acc_x, i_acc_y, i_acc_z : std_logic_vector(7 downto 0);
    signal i_new_data_strobe : std_logic;
    
    -- SPI
    constant spi_command_write : std_logic_vector(7 downto 0) := X"0A";
    constant spi_command_read : std_logic_vector(7 downto 0) := X"0B";
    
    constant spi_addr_data : std_logic_vector(7 downto 0) := X"00";
    
    signal tx_start, tx_finished : std_logic;
    signal rx_byte, tx_byte: std_logic_vector(7 downto 0);
begin
    spi_controller: entity work.spi_controller(Behavioral)
        port map (
            reset => reset,
            clk => clk,
            cs => cs,
            miso => miso,
            mosi => mosi,
            sclk => sclk,
            tx_start => tx_start,
            tx_finished => tx_finished,
            rx_byte => rx_byte,
            tx_byte => tx_byte
       );
       
   
    avtomat: process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                new_data_strobe <= '0';
                acc_x <= (others => '0');
                acc_y <= (others => '0');
                acc_z <= (others => '0');
            else
                new_data_strobe <= i_new_data_strobe;
                acc_x <= i_acc_x;
                acc_y <= i_acc_y;
                acc_z <= i_acc_z;
                current_state <= next_state;
            end if;
        end if;
    end process;    
    
    branje_spi: process(current_state, accel_start, tx_finished)
    begin
        i_new_data_strobe <= '0';
        case current_state is
            when idle =>
                if accel_start = '1' then
                    i_acc_x <= (others => '0');
                    i_acc_y <= (others => '0');
                    i_acc_z <= (others => '0');
                    next_state <= write_command_read;
                end if;
            when write_command_read => 
                tx_byte <= spi_command_read;
                tx_start <= '1';
                next_state <= wait_command_read;
                
            when wait_command_read =>
                if tx_finished = '1' then
                    tx_byte <= spi_addr_data;
                    next_state <= wait_addr_reg;
                end if;
                
            when wait_addr_reg =>
                if tx_finished = '1' then
                    tx_byte <= (others => '0');
                    next_state <= read_x;
                end if;
                
            when read_x =>
                if tx_finished = '1' then
                    tx_byte <= (others => '0');
                    i_acc_x <= rx_byte;
                    next_state <= read_y;
                end if;
            when read_y =>
                if tx_finished = '1' then
                    i_acc_y <= rx_byte;
                    next_state <= read_z;
                end if;
            when read_z =>
                tx_start <= '0'; -- stop rx
                if tx_finished = '1' then
                    i_acc_z <= rx_byte;
                    i_new_data_strobe <= '1';
                    
                    next_state <= cs_hold_1;
                end if;
                
            -- cs hold time 20ns -- 2 clock cycles
            -- (4+1) cs_hold gives us 50ns
            when cs_hold_1 => next_state <= cs_hold_2;         
            when cs_hold_2 => next_state <= cs_hold_3;         
            when cs_hold_3 => next_state <= cs_hold_4;         
            when cs_hold_4 => next_state <= write_command_read;         
        end case;
    end process;
end Behavioral;
