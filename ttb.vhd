library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.all;

entity ttb is
end ttb;

architecture arch of ttb is

	signal data_in : std_logic_vector(15 downto 0);
	signal len : std_logic_vector(15 downto 0) := X"0001";
	signal clk : std_logic := '0';	
	signal rst : std_logic;
	signal endiannes : std_logic;
	signal start : std_logic;
	signal crc_type : std_logic;
	signal finish : std_logic;
	signal data_out : std_logic_vector(11 downto 0);

begin

CALC : entity work.CRC_CALC port map(clk, rst, endiannes, data_in, len, start, crc_type, data_out, finish);

process
begin
	clk <= not clk;
	wait for 2 ns;
end process;

data_in <= X"0A50";
START <= '0', '1' after 2 ns;
rst <= '0', '1' after 2 ns;
endiannes <= '0';
crc_type <= '0', '1' after 1115 ns;
end arch;