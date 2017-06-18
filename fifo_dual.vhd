library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all; 
use ieee.numeric_std.ALL; 

entity fifo_dual is									 	--double clock fifo
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
	full            : out  std_logic := '0';
	empty           : out  std_logic 
	);
end fifo_dual;						 

architecture arch of fifo_dual is

component ram_dual is
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
		
			data_out						: out std_logic_vector(BIT_WIDTH - 1 downto 0)
	);	
end component;

signal out_en : std_logic;

signal out_pnt  : std_logic_vector( ADDR_WIDTH_F-1 downto 0) := (others =>'0');
signal in_pnt  : std_logic_vector( ADDR_WIDTH_F-1 downto 0) := (others =>'0');

signal max_pnt : std_logic_vector( ADDR_WIDTH_F-1 downto 0) := (others =>'1');	
signal min_pnt : std_logic_vector( ADDR_WIDTH_F-1 downto 0) := (others =>'0');	

signal full_inside : std_logic;
signal empty_inside : std_logic;

begin

	--data_out <= data_out_holder when empty_inside = '0';
	
	out_en <= '1' when empty_inside = '0' and out_req = '1' else
			  '0';
	
	process(clk_in, rst, clk_out)
	begin
		if in_pnt = out_pnt then
			empty <= '1';				
			empty_inside <= '1';
		else
			empty <= '0';
			empty_inside <= '0';
		end if;
		if (in_pnt) = out_pnt - 3 then --poprawa
			full <= '1';
			full_inside	<= '1';
		else
			full <= '0';		 
			full_inside	<= '0';
		end if;
		
	end process;
	
	
	process(clk_in, rst, in_req)
	begin
		if(rst = '0') then
			in_pnt  <= ( others => '0' );
			--out_pnt <= min_pnt;
			--data_out <= (others => '0');
		elsif(rising_edge(clk_in) and in_req = '1'and full_inside = '0') then
			--if(in_pnt = max_pnt) then
			--	in_pnt <= ( others => '0' );
			--else
				in_pnt <= in_pnt + 1 ;
			--end if;
	 	end if;
	end process;	
	
	process(clk_out, rst, out_req)
	begin
		if(rst = '0') then
		  --in_pnt  <= min_pnt;
			out_pnt <= ( others => '0' );
			--data_out <= (others => '0');
		elsif(rising_edge(clk_out) and out_req = '1' and empty_inside = '0') then
			--if(out_pnt = max_pnt) then
				--out_pnt <= ( others => '0' );
			--else
				out_pnt <= out_pnt + 1 ;
			--end if;
	 	end if;
	end process;	

IN_MEM: ram_dual 	generic map(BIT_WIDTH_F,  ADDR_WIDTH_F,  SIZE_F)
									port map(data_in, out_pnt, in_pnt, rst, in_req, out_en, clk_out, clk_in, data_out);
	
	
end arch;
