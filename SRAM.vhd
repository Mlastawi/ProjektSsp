library IEEE;
use IEEE.STD_LOGIC_1164.all;
USE ieee.numeric_std.ALL; 

entity sram is
generic (
BIT_WIDTH  	: integer :=8;        --Bit Width of word.
ADDR_WIDTH 	: integer :=8;        --Address Width.
RAM_SIZE	: integer :=8);
port(							   
clk 		: in std_logic;		   
ram_en 		: in std_logic; --'1' enable
ram_in		: in std_logic_vector(BIT_WIDTH -1 downto 0);
ram_out		: out std_logic_vector(BIT_WIDTH -1 downto 0);
addres		: in std_logic_vector(ADDR_WIDTH -1 downto 0);
async_out	: out std_logic_vector(RAM_SIZE*BIT_WIDTH - 1 downto 0);
r_w			: in std_logic;	--'1' SAVING | '0' READING
rst			: in std_logic	--'0' resets
);
end sram;

architecture sram of sram is

type ram_type is array (RAM_SIZE-1 downto 0) of std_logic_vector(BIT_WIDTH-1 downto 0);
signal memo : ram_type;
begin						
	
--	asynch_out(159 downto 140) <= memo();
	
label_req: for a in ram_type'range generate
		async_out( (a+1)*BIT_WIDTH  - 1 downto a*BIT_WIDTH ) <= memo(a);
	 end generate label_req ;

	
process (clk, rst)									
begin
	if(rst = '0') then
			for i in ram_type'range loop
				memo(i) <= (others => '0'); 
			end loop;
			ram_out <= (others => '0');			
			
	elsif(rising_edge(clk)) then
		if(ram_en = '1') then
			if r_w='1' then
				memo( to_integer(unsigned(addres)) ) <= ram_in;
			else
				ram_out <= memo( to_integer(unsigned(addres)) );
			end if;
		end if;
	end if;
end process;


end sram;
