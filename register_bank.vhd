library IEEE;
use IEEE.STD_LOGIC_1164.all;
USE ieee.numeric_std.ALL; 

library work;
use work.all;

entity register_bank is
port(							   
clk 		: in std_logic;		   
en 		: in std_logic; --'1' enable
data_in		: in std_logic_vector(15 downto 0);
data_out		: out std_logic_vector(15 downto 0);
addres		: in std_logic_vector(15 downto 0);
r_w			: in std_logic;	--'1' SAVING | '0' READING
rst			: in std_logic;	--'0' resets


DADR : out std_logic_vector(15 downto 0);
DLEN : out std_logic_vector(15 downto 0);
DBIT : out std_logic_vector(15 downto 0);
CADR : out std_logic_vector(15 downto 0);
CCRC : out std_logic_vector(15 downto 0);
STAT : out std_logic_vector(15 downto 0)
	
);
end register_bank;

architecture register_bank of register_bank is

signal async_out	: std_logic_vector(95 downto 0);

begin						
	RAM : entity work.sram(sram) generic map(16, 3, 6) port map(clk, en, data_in, data_out, addres(2 downto 0), async_out, r_w, rst);

--TU MO¯NA ZMIENIÆ ADRESY POSZCZEGÓLNYCH REJESTRÓW
	DADR <= async_out(15 downto 0);
	DLEN <= async_out(31 downto 16);
	DBIT <= async_out(47 downto 32);
	CADR <= async_out(63 downto 48);
	CCRC <= async_out(79 downto 64);
	STAT <= async_out(95 downto 80);

end register_bank;
