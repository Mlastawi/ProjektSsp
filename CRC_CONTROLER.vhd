library ieee;
use ieee.std_logic_1164.all;

entity CRC_CONTROLER is
	port (
	CLK : in std_logic;
	clk_master : in std_logic;
	RST : in std_logic;
	START : in std_logic;
	ACK : out std_logic;
	
	--AGU
	AGU_START : out std_logic;
	
	--zapis fifo
	wb_start : in std_logic;
	fifo_full : in std_logic;
	fifo_empty : in std_logic;
	stb_master : in std_logic;

	fifo_in_en : out std_logic;
	
	--CRC
	crc_finish : in std_logic;
	finish : out std_logic;
	cmode : out std_logic;
	crc_data_req : in std_logic;
	crc_data_en : out std_logic
	--tu bedzie wiecej rzeczy
);
end CRC_CONTROLER;

architecture arch of CRC_CONTROLER is

	signal ACK_O : std_logic;
	signal mode : std_logic;
	signal fin_in : std_logic;

	signal crc_en_in : std_logic;
	
begin
	ACK <= '1' when START = '1' else
		   '0';
	AGU_START <= '1' when START = '1' else
				 '0';

process(stb_master, rst, clk_master)
begin
	if rst = '0' then
		FIFO_IN_EN <= '0';
	elsif wb_start = '0' and clk_master = '1'then
		FIFO_IN_EN <= '0';
	elsif falling_edge(stb_master) and wb_start = '1' and mode = '0' then
		if FIFO_FULL = '0' and START = '1' then
			FIFO_IN_EN <= '1';
		else
			FIFO_IN_EN <= '0';
		end if;
	end if;
end process;

process(rst, crc_finish, stb_master)
begin
	if rst = '0' then
		cmode <= '0';
		mode <= '0';
		finish <= '0';
		fin_in <= '0';
	elsif crc_finish = '1' then
		cmode <= '1';
		mode <= '1';
		if fin_in = '0' then
			finish <= '1';
			fin_in <= '1';
		elsif falling_edge(stb_master) then
			finish <= '0';
			fin_in <= '0';
		end if;
	else
		cmode <= '0';
		mode <= '0';
	end if;
end process;

process(rst, clk)
begin
	if rst = '0' then
		crc_data_en <= '0';
		crc_en_in <= '0';
	elsif rising_edge(clk) then
		if crc_data_req = '1' and crc_en_in = '0' then
			if fifo_empty = '0' then
				crc_data_en <= '1';
				crc_en_in <= '1';
			else				
				crc_data_en <= '0';
				crc_en_in <= '0';
			end if;
		else				
			crc_data_en <= '0';
			crc_en_in <= '0';
		end if;
	end if;
end process;
end arch;
