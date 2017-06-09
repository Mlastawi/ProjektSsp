library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity WBS is
	port
	(
	RST_I : in std_logic; --reset
	CLK_I : in std_logic; --zegar uC
	ADDR_I : in std_logic_vector(15 downto 0); --adres rejestru do zapisu
	DAT_O : out std_logic_vector(15 downto 0); --dane wyjœciowe
	DAT_I : in std_logic_vector(15 downto 0); --dane wejœciowe
	WE_I : in std_logic; --czy zapisywaæ
	SEL_I : in std_logic; --wybór bitów do czytania, u nas nieistotne
	STB_I : in std_logic; --czy MASTER gotowy do przesy³u
	ACK_O : out std_logic := '0'; --czy SLAVE gotowy do przesy³u
	CYC_I : in std_logic; --czy MASTER chce przesy³aæ 
	
	data_latch_in : out std_logic_vector(15 downto 0);
	
	ADDR_LATCH : out std_logic_vector(15 downto 0);
	
	data_out : in std_logic_vector(15 downto 0);
	
	ram_enable : out std_logic;
	
	we_latch : out std_logic
	);
end WBS;

architecture arch of WBS is 

	signal DAT_IN : std_logic_vector(15 downto 0);
	--signal ADDR_LATCH : std_logic_vector(15 downto 0);
	signal wait_state : std_logic := '0';
	signal ACK : std_logic := '0';
	--signal ram_enable : std_logic;
	

begin

process(CLK_I) --DODAÆ RESET ASYNCHRONICZNY
begin
	if rising_edge(CLK_I) then
		if (STB_I = '1') and (ACK = '0') then
					if WE_I = '1' then
						Ram_enable <= '0';
					else
						--Ram_enable <= '1';
						ADDR_LATCH <= ADDR_I;
						we_latch <= we_i;
					end if;
			--if Wait_state = '1' then
					ACK <= '1';
					ACK_O <= '1';
--					Wait_state <= '0';
--			else
--				Wait_state <= '1';
--			end if;
		elsif (STB_I = '1') and (ACK = '1') then
				ACK <= '0';
				ACK_O <= '0';		
				if WE_I = '1' then
					data_latch_in <= DAT_I;	
					ADDR_LATCH <= ADDR_I;
					Ram_enable <= '1';	
					we_latch <= we_i;
				else
					
					DAT_O <= data_out;
					--Ram_enable <= '0';
				end if;
		elsif WE_I = '0' then
			ram_enable <= '1';
		else 
			Ram_enable <= '0';
		end if;
	end if;
end process;

end arch;