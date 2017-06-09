library IEEE;
use IEEE.STD_LOGIC_1164.all;
USE ieee.numeric_std.ALL;

library work;
use work.all; 

entity ram_out is
generic (
	BIT_WIDTH  	: integer :=8;        --Bit Width of word.
	ADDR_WIDTH 	: integer :=8;        --Address Width.
	RAM_SIZE	: integer :=8);
port(							   
	RST_I : in std_logic; --reset
	CLK_I : in std_logic; --zegar uC
	ADDR_I : in std_logic_vector(15 downto 0); --adres rejestru do zapisu
	DAT_O : out std_logic_vector(15 downto 0); --dane wyjœciowe
	DAT_I : in std_logic_vector(15 downto 0); --dane wejœciowe
	WE_I : in std_logic; --czy zapisywaæ
	SEL_I : in std_logic; --wybór bitów do czytania, u nas nieistotne
	STB_I : in std_logic; --czy MASTER gotowy do przesy³u
	ACK_O : out std_logic := '0'; --czy SLAVE gotowy do przesy³u
	CYC_I : in std_logic --czy MASTER chce przesy³aæ dalej
);
end ram_out;

architecture arch of ram_out is

--type ram_type is array (RAM_SIZE-1 downto 0) of std_logic_vector(BIT_WIDTH-1 downto 0);
--signal memo : ram_type;

signal data_latch : std_logic_vector(15 downto 0);
signal addr_latch : std_logic_vector(15 downto 0);


signal data_out : std_logic_vector(15 downto 0);
signal ram_en : std_logic;
signal we_latch : std_logic;

begin						
	
	WBS : entity work.WBS port map(rst_i, clk_i, addr_i, dat_o, dat_i, we_i, sel_i, stb_i, ack_o, cyc_i, data_latch, addr_latch, data_out, ram_en, we_latch);
	RAM : entity work.SRAM(ramout) 
		generic map(BIT_WIDTH, ADDR_WIDTH, RAM_SIZE)
		port map(clk_i, ram_en, data_latch, data_out, addr_latch, open, we_latch, rst_i);
	
--	asynch_out(159 downto 140) <= memo();
	
--label_req: for a in ram_type'range generate
--		async_out( (a+1)*BIT_WIDTH  - 1 downto a*BIT_WIDTH ) <= memo(a);
--	 end generate label_req ;

	
--process (clk, rst)									
--begin
--	if(rst = '0') then
--			for i in ram_type'range loop
--				memo(i) <= (others => '0'); 
--			end loop;
--			ram_out <= (others => '0');			
--			
--	elsif(rising_edge(clk)) then
--		if(ram_en = '1') then
--			if r_w='1' then
--				memo( to_integer(unsigned(addres)) ) <= ram_in;
--			else
--				ram_out <= memo( to_integer(unsigned(addres)) );
--			end if;
--		end if;
--	end if;
--end process;

--process(CLK_I) --DODAÆ RESET ASYNCHRONICZNY
--begin
--	if rising_edge(CLK_I) then
--		if (STB_I = '1') and (ACK = '0') then
----					if WE_I = '1' then
----						Ram_enable <= '0';
----					else
----						Ram_enable <= '1';
----						ADDR_LATCH <= ADDR_I;
----					end if;
--			--if Wait_state = '1' then
--					ACK <= '1';
--					ACK_O <= '1';
----					Wait_state <= '0';
----			else
----				Wait_state <= '1';
----			end if;
--		elsif (STB_I = '1') and (ACK = '1') then
--				ACK <= '0';
--				ACK_O <= '0';		
--				if WE_I = '1' then
--					DAT_IN <= DAT_I;	
--					--ADDR_LATCH <= ADDR_I;				
--					--Ram_enable <= '1';		
--				else
--					
--					DAT_O <= ADDR_I;
--					--Ram_enable <= '0';
--				end if;
--		else 
--			--Ram_enable <= '0';
--		end if;
--	end if;
--end process;

end arch;
