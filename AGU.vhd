library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity AGU is
	port (
	ADDR_0: in std_logic_vector(15 downto 0);
	LEN : in std_logic_vector(15 downto 0);
	CADR : in std_logic_vector(15 downto 0);
	
	COUNT : in std_logic;
	RESET : in std_logic;
	START : in std_logic;
	FULL : in std_logic;
	mode : in std_logic; --okresla kierunek odczytu 0 -> rosn¹co, 1 -> malej¹co
	c_mode : in std_logic; --okresla czy wypuszcza adres danych czy kodu CRC '0' - dane, '1' - CRC
	
	AGU_FIN : out std_logic;
	ADDR_OUT : out std_logic_vector(15 downto 0)
);
end AGU;

architecture arch of AGU is

	signal CNT : unsigned(15 downto 0) := (others => '0');
	
begin

	ADDR_OUT <= std_logic_vector( CNT + unsigned(ADDR_0)) when c_mode = '0' else
				CADR;
		
process(COUNT, RESET, mode)
begin
	if RESET = '0' then
		agu_fin <= '0';
		if mode = '0' then
			CNT <= to_unsigned(0,16);
		else
			CNT <= unsigned(LEN) - 1;
		end if;
	elsif START = '0' then
		agu_fin <= '0';
		if mode = '0' then
			CNT <= to_unsigned(0,16);
		else
			CNT <= unsigned(LEN) - 1;
		end if;
	elsif falling_edge(count) then
		if FULL = '0' and START = '1' then
			if mode = '0' and unsigned(LEN) - 1 /= CNT then
				CNT <= CNT + 1;
			elsif mode = '1' and CNT /= 0 then
				CNT <= CNT - 1;
			else 
				agu_fin <= '1';
			end if;
		end if;
	end if;
end process;

end arch;
