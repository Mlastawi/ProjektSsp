library ieee;
use ieee.std_logic_1164.all;

entity FSM_1 is
	port (
	STAT 	: in std_logic;
	ACK 	: in std_logic;
	FINISH : in std_logic;
	ERR		 : in std_logic;
	START : out std_logic
	
	);
end FSM_1;

architecture arch of FSM_1 is
				 
begin				

START <= '1' when STAT = '1' else
				 '0';

end arch;