library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ttb is
end ttb;

architecture arch of ttb is

	signal ADDR_0 : std_logic_vector(19 downto 0);
	signal LEN : std_logic_vector(19 downto 0) := X"FFFFF";
	signal COUNT : std_logic := '0';	
	signal START : std_logic;	
	signal FULL : std_logic := '0';
	signal ADDR_OUT : std_logic_vector(19 downto 0);

component AGU is
	port (
	ADDR_0: in std_logic_vector(19 downto 0);
	LEN : in std_logic_vector(19 downto 0);
	COUNT : in std_logic;
	START : in std_logic;
	FULL : in std_logic;
	
	ADDR_OUT : out std_logic_vector(19 downto 0)
);
end component;

begin

x1 : AGU port map(ADDR_0, LEN, COUNT, START, FULL, ADDR_OUT);

process
begin
	COUNT <= not COUNT;
	wait for 15 ns;
end process;

ADDR_0 <= X"00000", X"00010" after 30 ns;
START <= '0', '1' after 50ns;
end arch;