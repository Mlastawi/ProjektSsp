LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;  

library work;
use work.all;


ENTITY testbench IS
END testbench;

ARCHITECTURE arch OF testbench IS
	signal CLK : std_logic := '0';
	signal CLK_INT : std_logic := '0';
	signal RST : std_logic;	
	signal ADDR_I : std_logic_vector(15 downto 0);
	signal DAT_I : std_logic_vector(15 downto 0);
	signal DAT_O : std_logic_vector(15 downto 0);
	
	signal WE_I : std_logic;
	signal SEL_I : std_logic;
	signal STB_I : std_logic;
	signal ACK_O : std_logic;
	signal CYC_I : std_logic;
	
	signal stat_dd: std_logic;
	

begin

--crc : entity work.CRC_TOP 
--port map (rst, clk, addr_i, dat_i, dat_o, we_i, sel_i, stb_i);

process
begin
	CLK <= not CLK;
	wait for 10 ns;
end process; 

process
begin
	CLK_INT <= not CLK_INT;
	wait for 15 ns;
end process;

RST <= '1', '0' after 20 ns, '1' after 25 ns;
ADDR_I <= X"0005" after 40 ns, X"0001" after 900 ns;
DAT_I <= X"0001" after 40 ns, X"2137" after 92 ns;
STB_I <= '0', '1' after 40 ns, '0' after 81 ns, '1' after 180 ns, '0' after 221 ns;
CYC_I <= '0', '1' after 40 ns, '0' after 81 ns, '1' after 180 ns, '0' after 221 ns;
WE_I <= '1', '0' after 120 ns;
SEL_I <= '0';

end arch;
