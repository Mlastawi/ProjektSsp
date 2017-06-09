library IEEE;
library work;

use IEEE.STD_LOGIC_1164.all;
use work.all;  

entity tb is
end tb;
		
architecture arch of tb is

component ram_dual  is
generic(
		BIT_WIDTH  	: integer :=8;        --Bit Width of word.
		ADDR_WIDTH 	: integer :=8;        --Address Width.
		RAM_SIZE		: integer :=10);
port (
		data_in			: in std_logic_vector(BIT_WIDTH - 1 downto 0);
		raddr				: in std_logic_vector(ADDR_WIDTH -1 downto 0);
		waddr				: in std_logic_vector(ADDR_WIDTH -1 downto 0);
		rst					: in std_logic;
		in_req     	: in std_logic;
		out_req    	: in		std_logic;
		rclk				: in std_logic;
		wclk				: in std_logic;

		data_out						: out std_logic_vector(7 downto 0)
	);	
end component;

component fifo_dual is									 	--double clock fifo
	generic (				
	BIT_WIDTH_F  	: integer := 8;					--Bit Width of word.
	ADDR_WIDTH_F	: integer := 4;					--Minimal number of bits for RAM_SIZE - 1 value.
	SIZE_F				:	integer :=16);				--Number of words.
	port(
	clk_in          : in   	std_logic;
	clk_out         : in   	std_logic;
	rst	            : in   	std_logic;      
	in_req        	: in		std_logic;
	out_req       	: in		std_logic;
	data_in         : in		std_logic_vector(BIT_WIDTH_F - 1 downto 0);   
	data_out        : out	 std_logic_vector(BIT_WIDTH_F - 1 downto 0);   
	full            : buffer  std_logic := '0';
	empty           : buffer  std_logic 
	);
end component;


signal rst_tb: std_logic;
signal clk_tb: std_logic; 	
signal clk_tb2: std_logic; 	
signal fifo_in_req: std_logic; 	
signal fifo_out_req: std_logic; 	

signal cnt_tb : std_logic_vector(7 downto 0);	 
signal ram_in: std_logic_vector(7 downto 0)   := X"00";
signal ram_out: std_logic_vector(7 downto 0)  :=X"00";
signal ram_add: std_logic_vector(7 downto 0)  :=X"00";

signal r_w_tb: std_logic := '0';					  			   

signal ram_en_tb : std_logic := '0';

constant clk_period : time := 0.5 ns;
constant clk_period2 : time := 5 ns;


begin
	
	rst_tb <= '0','1' after 10 ns,'0' after 90 ns;	
	r_w_tb <= '1','0' after 10 ns,'1' after 40 ns;	
	
	ram_add <= X"00", X"01"	after 10 ns, X"02"	after 20 ns, X"03"	after 30 ns, X"04"	after 40 ns, X"05"	after 50 ns,
					  X"01" after 60 ns, X"02"	after 70 ns, X"03"	after 80 ns, X"04"	after 90 ns, X"05"	after 100 ns;
	
	ram_in <= X"00", X"10" after 10 ns, X"11" after 20 ns, X"12" after 30 ns, X"13" after 40 ns, X"14" after 50 ns, X"15" after 60 ns, X"16" after 70 ns, X"17" after 80 ns;					  
	
	fifo_in_req <= '1','0' after 70 ns;
	fifo_out_req <= '0','1' after 40 ns;

	
--hram: work.sram generic map(20,8,8)
--port map(clk_tb,'1',cnt_tb,ram_out,ram_add,r_w_tb,rst_tb);
	

--ramik: ram_dual port map(
--		data_in			=> ram_in,
--		raddr				=> ram_add,
--		waddr				=> ram_add,
--		rst					=> rst_tb,
--		in_req     	=> fifo_in_req,
--		out_req    	=> fifo_out_req,
--		rclk				=> clk_tb2,
--		wclk				=> clk_tb,

--		data_out		=> ram_out
--	);			

fifa: fifo_dual port map(
	clk_in          => clk_tb,
	clk_out         => clk_tb2,
	rst	            => rst_tb,      
	in_req        	=> fifo_in_req,
	out_req       	=> fifo_out_req,
	data_in         => ram_in,   
	data_out        => ram_out,  
	full            => open,
	empty           => open 
	);	


clk_tb_process: process(clk_tb)
   begin
   if clk_tb = 'U' then 
      clk_tb <= '1';
   else 
      clk_tb <= not clk_tb after clk_period; 
  end if;
end process;

clk_tb2_process: process(clk_tb2)
   begin
   if clk_tb2 = 'U' then 
      clk_tb2 <= '1';
   else 
      clk_tb2 <= not clk_tb2 after clk_period2; 
  end if;
end process;



end arch;
