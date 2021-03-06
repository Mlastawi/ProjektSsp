library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity WBM is
	port
	(
	RST_I : in std_logic; --reset
	CLK_I : in std_logic; --zegar uC
	ADDR_O : out std_logic_vector(15 downto 0); --adres rejestru do zapisu
	DAT_O : out std_logic_vector(31 downto 0); --dane wyj�ciowe
	DAT_I : in std_logic_vector(31 downto 0); --dane wej�ciowe
	WE_O : out std_logic; --czy zapisywa�
	SEL_O : out std_logic; --wyb�r bit�w do czytania, u nas nieistotne
	STB_O : out std_logic; --czy MASTER gotowy do przesy�u
	ACK_I : in std_logic; --czy SLAVE gotowy do przesy�u
	CYC_O : out std_logic;
	
	addr : in std_logic_vector(15 downto 0);
	data_out : in std_logic_vector(31 downto 0); --dane kt�re maj� by� wypuszczone na zewn�trz
	data_in : out std_logic_vector(31 downto 0); -- dana kt�re maj� by� odczytane do uk�adu
	we : in std_logic;
	
	start : in std_logic
	);
end WBM;

architecture arch of WBM is

	signal cyc : std_logic;

begin

	SEL_O <= '0';
	WE_O <= we;
	addr_O <= addr;
	cyc_o <= cyc;
	dat_o <= data_out;
	data_in <= dat_i;

	stb_up: process(rst_i, clk_i)
		begin
			if rst_i = '0' then
				CYC <= '0';
				STB_O <= '0';
				
			elsif rising_edge(clk_i) then	
				if start = '1' then
					if CYC = '1' then
						if ACK_I ='0' then
							STB_O <= '1';
						else
							STB_O <= '0';
							CYC <= '0';
						end if;
					else
						CYC <= '1';
						 STB_O <= '1';
					end if;
				else
					CYC <= '0';
					STB_O <= '0';
				end if;
			end if;
		end process;

end arch;

