library ieee;
use ieee.std_logic_1164.all;

library work;
use work.all;

entity DOUBLE_D is
	port (
	CLK : in std_logic;
	INPUT : in std_logic;
	OUTPUT : out std_logic
);
end DOUBLE_D;

architecture arch of DOUBLE_D is

signal CONNECTOR_X : std_logic;

begin

D1 : entity work.FF_D port map(CLK, INPUT, CONNECTOR_X, open);
D2 : entity work.FF_D port map(CLK, CONNECTOR_X, OUTPUT, open);

end arch;
