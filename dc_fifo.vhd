library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
--use IEEE.std_logic_arith.all;
use ieee.numeric_std.ALL; 

entity dc_fifo is									 	--double clock fifo
	generic (				
	BIT_WIDTH  : integer := 8;				--Bit Width of word.
	RAM_ADDR_WIDTH : integer := 4;		--Minimal number of bits for RAM_SIZE - 1 value.
	RAM_SIZE	:	integer :=16);				--Number of words.
	port(
	clk_in          : in   	std_logic;
	clk_out         : in   	std_logic;
	rst	            : in   	std_logic;      
	in_req        	: in		std_logic;
	out_req       	: in		std_logic;
	data_in         : in		std_logic_vector(BIT_WIDTH-1 downto 0);   
	data_out        : out	 std_logic_vector(BIT_WIDTH-1 downto 0);   
	full            : buffer  std_logic := '0';
	empty           : buffer  std_logic 
	);
end dc_fifo;						 
		
architecture arch of dc_fifo is

type ram_type is array (RAM_SIZE - 1 downto 0) of std_logic_vector(BIT_WIDTH-1 downto 0);
signal memo : ram_type;			 
signal in_pnt : std_logic_vector(RAM_ADDR_WIDTH-1 downto 0) := (others =>'0');
signal out_pnt : std_logic_vector(RAM_ADDR_WIDTH-1 downto 0) := (others =>'0');
signal max_pnt : std_logic_vector(RAM_ADDR_WIDTH-1 downto 0) := (others =>'1');	
signal min_pnt : std_logic_vector(RAM_ADDR_WIDTH-1 downto 0) := (others =>'0');	
signal dly_pnt : std_logic_vector(RAM_ADDR_WIDTH-1 downto 0) := (others =>'0');

begin
		
	process(clk_in, clk_out, in_req, out_req)
	begin

		
		if(rst = '0') then
			for i in ram_type'range loop
				memo(i) <= (others => '0'); 
			end loop;
		
		elsif(rising_edge(clk_in) and rising_edge(clk_out)) then	--rising edges from in_clk and out_clk at the same time
			if( in_req = '1' and out_req = '1' )	then 					--also writing and reading req '1' at the same time
					if (full = '0') then														--same stuff as normally but without incrementing dly_pnt
						memo( to_integer(unsigned(in_pnt)) ) <= data_in;
						if(in_pnt = max_pnt) then
							in_pnt <= (others => '0');
						else
							in_pnt <= in_pnt + 1 ;
						end if;
					end if;
					if (empty = '0') then								--same stuff as normally but without decrementing dly_pnt
						data_out <= memo( to_integer(unsigned(out_pnt)) );
						if(out_pnt = max_pnt) then
							out_pnt <= (others => '0');
						else
							out_pnt <= out_pnt + 1 ;
						end if;
					end if;
			end if; -- in_req = '1' and out_req = '1'			--  rising_edge(clk_in) and rising_edge(clk_out)
		elsif(rising_edge(clk_in) and in_req = '1' and full = '0') then 	-- not! rising edges from in_clk and out_clk at the same time
			memo( to_integer(unsigned(in_pnt)) ) <= data_in;						--same stuff but with incrementing dly_pnt
			if(in_pnt = max_pnt) then
				in_pnt <= (others => '0');
			else
				in_pnt <= in_pnt + 1 ;
			end if;
			dly_pnt <= dly_pnt + 1;
		elsif(rising_edge(clk_out) and out_req = '1' and empty = '0') then	--same stuff but with decrementing dly_pnt													
			data_out <= memo( to_integer(unsigned(out_pnt)) );
			if(out_pnt = max_pnt) then
				out_pnt <= (others => '0');
			else
				out_pnt <= out_pnt + 1 ;
			end if;
			dly_pnt <= dly_pnt - 1;
		end if;
		
		if(	dly_pnt =  max_pnt) then
			full <= '1';
		elsif (	dly_pnt = min_pnt ) then
			empty <= '1';
		else
			full <= '0';
			empty <='0';
		end if;
	end process;
	

end arch;
