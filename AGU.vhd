library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity AGU is
	port (
	ADDR_0: in std_logic_vector(15 downto 0);
	LEN : in std_logic_vector(15 downto 0);
	COUNT : in std_logic;
	RESET : in std_logic;
	START : in std_logic;
	FULL : in std_logic;
	
	ADDR_OUT : out std_logic_vector(15 downto 0)
);
end AGU;

architecture arch of AGU is

	signal CNT : unsigned(15 downto 0) := (others => '0');
	
begin

	ADDR_OUT <= std_logic_vector( CNT + unsigned(ADDR_0));
		
process(COUNT, RESET)
begin
	if RESET = '0' then
		CNT <= to_unsigned(0,16);
	elsif COUNT = '0' and FULL = '0' and START = '1' then
		if unsigned(LEN) - 1 /= CNT then
			CNT <= CNT + 1;
		end if;
	end if;
end process;

end arch;
