library ieee;
use ieee.std_logic_1164.all;

entity DOUBLE_D is
	port (
	CLK : in std_logic;
	INPUT : in std_logic;
	OUTPUT : out std_logic
);
end DOUBLE_D;

architecture arch of DOUBLE_D is

component FF_D is
	port (
	CLK : in std_logic;
	D : in std_logic;
	Q : out std_logic;
	NQ : out std_logic
);
end component;

signal CONNECTOR_X : std_logic;

begin

D1 : FF_D port map(CLK, INPUT, CONNECTOR_X, open);
D2 : FF_D port map(CLK, CONNECTOR_X, OUTPUT, open);

end arch;
