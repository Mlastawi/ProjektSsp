library ieee;
use ieee.std_logic_1164.all;

library work;
use work.all;

entity CRC_TOP is
	port (

	--porty od strony uC
	RST_I_S : in std_logic; --reset
	CLK_slave : in std_logic; --zegar uC
	ADDR_I : in std_logic_vector(15 downto 0); --adres rejestru do zapisu
	DAT_O_slave : out std_logic_vector(15 downto 0); --dane wyjœciowe
	DAT_I_slave : in std_logic_vector(15 downto 0); --dane wejœciowe
	WE_I : in std_logic; --czy zapisywaæ
	SEL_I : in std_logic; --wybór bitów do czytania, u nas nieistotne
	STB_I : in std_logic; --czy MASTER gotowy do przesy³u
	ACK_O : out std_logic := '0'; --czy SLAVE gotowy do przesy³u
	CYC_I : in std_logic; --czy MASTER chce przesy³aæ dalej
	
--	ICRC : out std_logic; --przerwanie od zakoñczenia CRC
	
	--porty dla "srodka" ukladu
	CLK_INT : in std_logic; --zegar wewnêtrzny
	RST_INT : in std_logic;

	--porty od strony pamieci	
	RST_I_M : in std_logic; --reset
	CLK_master : in std_logic; --zegar uC
	ADDR_O : out std_logic_vector(15 downto 0); --adres rejestru do zapisu
	DAT_O_master : out std_logic_vector(31 downto 0); --dane wyjœciowe
	DAT_I_master : in std_logic_vector(31 downto 0); --dane wejœciowe
	WE_O : out std_logic; --czy zapisywaæ
	SEL_O : out std_logic; --wybór bitów do czytania, u nas nieistotne
	STB_O : out std_logic; --czy MASTER gotowy do przesy³u
	ACK_I : in std_logic; --czy SLAVE gotowy do przesy³u
	CYC_O : out std_logic;

	--###  test port's :
	STAT_DD : out std_logic --	
);
end CRC_TOP;

architecture arch of CRC_TOP is

	--sygnaly dla WBS
	signal STORAGE_I : std_logic_vector(15 downto 0);
	signal STORAGE_O : std_logic_vector(15 downto 0);
	
	signal RAM_ENABLE : std_logic := '0';
	signal ADDR_LATCH : std_logic_vector(15 downto 0);
	
	signal ACK : std_logic := '0';
	signal WAIT_STATE : std_logic := '0';
	--signal asynch_out : std_logic_vector(95 downto 0);
	
	signal WE_LATCH : std_logic;

	--sygnaly do synchronizacji zegarow
	signal START : std_logic;
	signal START2 : std_logic;
	signal CRC_ACK : std_logic := '0';
	signal CRC_ACK2 : std_logic := '0';
	
	--sygnaly do rozpoczecia transmisji
	signal AGU_START : std_logic;
	signal AGU_RESET : std_logic;

	-- wyjsciowe sygnaly rejestrow
	signal DADR : std_logic_vector(15 downto 0);
	signal DLEN : std_logic_vector(15 downto 0);
	signal DBIT : std_logic_vector(15 downto 0);
	signal CADR : std_logic_vector(15 downto 0);
	signal CCRC : std_logic_vector(15 downto 0);
	signal STAT : std_logic_vector(15 downto 0);
	
	--sygna³y dla wbm
	
	signal ADDR_OUT : std_logic_vector(15 downto 0);
	signal data : std_logic_vector(31 downto 0);
	signal stb_o_int : std_logic;

begin

	stb_o <= stb_o_int;
	data <= X"0000"&addr_out;

	WBM : entity work.WBM
		port map(rst_i_m, clk_master, addr_o, dat_o_master, dat_i_master, we_o, sel_o, stb_o_int, ack_i, cyc_o, addr_out, data, '0', agu_start);

	WBS : entity work.WBS
		port map(rst_i_s, clk_slave, addr_i, dat_o_slave, dat_i_slave, we_i, sel_i, stb_i, ack_o, cyc_i, storage_i, ADDR_LATCH, storage_o, ram_enable, WE_LATCH);
		
	register_bank : entity work.register_bank
		port map(CLK_slave, RAM_ENABLE, STORAGE_I, STORAGE_O, ADDR_LATCH, WE_LATCH, RST_I_s, DADR, DLEN, DBIT, CADR, CCRC, STAT);
	
	
	
	--synchronizacja
	DD_1 : entity work.DOUBLE_D
		port map(CLK_INT, START, START2);
	DD_2 : entity work.DOUBLE_D
		port map(CLK_slave, CRC_ACK, CRC_ACK2);
	
	--prawa strona uk³adu
	controler : entity work.CRC_CONTROLER
		port map(CLK_INT, START2, CRC_ACK, AGU_START);
	
	agu_reset <= '1';
	
	AGU : entity work.AGU
		port map(DADR, DLEN, stb_o_int, AGU_RESET, AGU_START, '0', ADDR_OUT );
		
	
	START <= '1' when STAT = X"0001" and (Ram_enable ='0' or we_i = '0') else
			'0';
	

end arch;
