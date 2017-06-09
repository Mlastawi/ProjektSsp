library ieee;
use ieee.std_logic_1164.all;

entity CRC_CONTROLER is
	port (
	CLK : in std_logic;
	START : in std_logic;
	ACK : out std_logic;
	AGU_START : out std_logic
	
	--tu bedzie wiecej rzeczy
);
end CRC_CONTROLER;

architecture arch of CRC_CONTROLER is

	signal ACK_O : std_logic;

	
begin
	ACK <= '1' when START = '1' else
		   '0';
	AGU_START <= '1' when START = '1' else
				 '0';

end arch;
