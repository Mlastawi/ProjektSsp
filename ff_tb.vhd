library ieee;
use ieee.std_logic_1164.all;

library work;
use work.all;

entity ff_tb is
end ff_tb;

architecture arch of ff_tb is

	signal CLK : std_logic := '0';
	signal RST : std_logic;
	
	signal ADDR_O : std_logic_vector(15 downto 0); --adres rejestru do zapisu
	signal DAT_O : std_logic_vector(31 downto 0); --dane wyj�ciowe mastera
	signal DAT_I : std_logic_vector(31 downto 0); --dane wej�ciowe mastera
	signal WE : std_logic; --czy zapisywa�
	signal SEL : std_logic; --wyb�r bit�w do czytania, u nas nieistotne
	signal STB : std_logic; --czy MASTER gotowy do przesy�u
	signal ACK : std_logic; --czy SLAVE gotowy do przesy�u
	signal CYC : std_logic;
	
	signal we_uC : std_logic;
	
	
	signal addr : std_logic_vector(15 downto 0);
	signal start : std_logic;
	signal data : std_logic_vector(31 downto 0);
	
	signal clk_int : std_logic := '0';
	signal rst_int : std_logic;
	
	signal CLK_master :  std_logic :='0'; --zegar uC
	
	signal ADDR_O_master :  std_logic_vector(15 downto 0); --adres rejestru do zapisu
	signal DAT_O_master :  std_logic_vector(31 downto 0); --dane wyj�ciowe
	signal DAT_I_master : std_logic_vector(31 downto 0); --dane wej�ciowe
	signal WE_O :  std_logic; --czy zapisywa�
	signal SEL_O :  std_logic; --wyb�r bit�w do czytania, u nas nieistotne
	signal STB_O :  std_logic; --czy MASTER gotowy do przesy�u
	signal ACK_I :  std_logic; --czy SLAVE gotowy do przesy�u
	signal CYC_O :  std_logic;
	

begin

master : entity work.WBM 
port map(rst, clk, addr_o, dat_o, dat_i, we, sel, stb, ack, cyc, addr, data, open, we_uC, start);

slave : entity work.CRC_TOP
port map(
--sygnaly WBS
rst, clk, addr_o, dat_i(15 downto 0), dat_o(15 downto 0), we, sel, stb, ack, cyc,
--sygnaly int
clk_int, rst,
--sygnaly WBM
rst, clk_master, addr_o_master, dat_o_master, dat_i_master, we_o, sel_o, stb_o, ack_i, cyc_o
);

ram_out1 : entity work.ram_out 
generic map(16,16,1024)
port map(rst, clk_master, addr_o_master, dat_i_master(15 downto 0), dat_o_master(15 downto 0), we_o, sel_o, stb_o, ack_i, cyc_o);

process
begin
	CLK <= not CLK;
	wait for 3 ns;
end process;

process
begin
	CLK_master <= not CLK_master;
	wait for 3 ns;
end process;

process
begin
	CLK_int <= not CLK_int;
	wait for 1 ns;
end process;

rst <= '0', '1' after 5 ns;
addr <= X"0000", X"0000" after 7 ns, X"0001" after 31 ns, X"0005" after 60 ns;
data <= X"00000008", X"00000002" after 31 ns, X"00000001" after 60 ns;
we_uC <= '1', '0' after 63 ns;

start <= '0', '1' after 7 ns;
end arch;