library ieee;
use ieee.std_logic_1164.all;


entity FF_D is
	port (
	CLK : in std_logic;
	D : in std_logic;
	Q : out std_logic;
	NQ : out std_logic
);
end FF_D;

architecture arch of FF_D is

	--signal HOLDER : std_logic;

begin

flip: process(CLK)
begin
if rising_edge(CLK) then
	Q <= D;
	NQ <= not D;
	--HOLDER <= D;
end if;
end process;
end arch;