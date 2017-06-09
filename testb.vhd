library IEEE;
use IEEE.STD_LOGIC_1164.all;

library work;
use work.all;

entity testb is
end testb;
		
architecture arch of testb is

signal rst_tb: std_logic;
signal clk_tb: std_logic;
signal addr_tb : std_logic_vector(15 downto 0); --adres rejestru do zapisu
signal DAT_O : std_logic_vector(31 downto 0); --dane wyjœciowe
signal DAT_I : std_logic_vector(31 downto 0); --dane wejœciowe
signal WE : std_logic := '0'; --czy zapisywaæ
signal SEL : std_logic := '0'; --wybór bitów do czytania, u nas nieistotne
signal STB : std_logic := '0'; --czy MASTER gotowy do przesy³u
signal ACK : std_logic := '0'; --czy SLAVE gotowy do przesy³u
signal CYC : std_logic := '0';

constant clk_period : time := 2 ns;
constant addr_0 : std_logic_vector(15 downto 0) := X"0010";
constant len : std_logic_vector(15 downto 0) := X"0002";

signal start_tb : std_logic;
signal addr : std_logic_vector(15 downto 0);

begin

ram_out1 : entity work.ram_out 
generic map(16,16,1024)
port map(rst_tb, clk_tb, addr_tb, dat_i(15 downto 0), dat_o(15 downto 0), we, sel, stb, ack, cyc);

agu1 : entity work.agu
port map(addr_0, len, stb, rst_tb, start_tb, '0', addr);

--wbm1 : entity work.wbm
--port map(rst_tb, clk_tb, addr_tb, dat_o, dat_i, we, sel, stb, ack, cyc, addr, start_tb);

start_tb <= '0', '1' after 10 ns;

rst_tb <= '0', '1' after 5 ns;
--addr_tb <= X"0000", X"0010" after 10 ns;
--WE_I <= '0';
--CYC_I <= '0', '1' after 30 ns;
--STB_I <= '0', '1' after 32 ns;

clk_tb_process: process(clk_tb)
   begin
   if clk_tb = 'U' then 
      clk_tb <= '1';
   else 
      clk_tb <= not clk_tb after clk_period; 
  end if;
end process;
									
--stb_up: process(clk_tb)
--	begin
--		if rising_edge(clk_tb) then
--			
--			if CYC_I = '1' and ACK_O ='0' then
--				STB_I <= '1';
--			elsif CYC_I = '1' and ACK_O = '1' then
--				STB_I <= '0';
--			end if;
--		end if;
--	end process;

--stb_down: process(ack_o)
--	begin
--		if falling_edge(ack_o) then
--			STB_I <= '0';
--		end if;
--	end process;	
--	
end arch;
