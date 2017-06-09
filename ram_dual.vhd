library ieee;
use ieee.std_logic_1164.all;
USE ieee.numeric_std.ALL; 

entity ram_dual is
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
end ram_dual;

architecture rtl of ram_dual is

	-- Build a 2-D array type for the RAM
	subtype word_t is std_logic_vector(BIT_WIDTH - 1 downto 0);
	type ramry_t is array(RAM_SIZE - 1 downto 0) of word_t;
	
	-- Declare the RAM signal.
	signal ram : ramry_t;  

begin
	
	process (rst,rclk,wclk)									
	begin
		if(rst = '0') then
			for i in ramry_t'range loop
			--	ram(i) <= (others => '0'); 
			--	data_out <= (others => '0'); --if sram is cleared ram_out is also cleared 
			end loop;
		end if;	
	end process;
	
	
	process(wclk)
	begin
		if(rst = '0') then
			for i in ramry_t'range loop
					ram(i) <= (others => '0'); 
				--	data_out <= (others => '0'); --if sram is cleared ram_out is also cleared 
			end loop;
		elsif(rising_edge(wclk)) then 
			if(in_req = '1') then
					ram( to_integer(unsigned(waddr)) ) <= data_in;
			end if;
		end if;
	end process;
	
	process(rclk)
	begin
		if(rst = '0') then
			for i in ramry_t'range loop
				--	ram(i) <= (others => '0'); 
				--	data_out <= (others => '0'); --if sram is cleared ram_out is also cleared 
			end loop;
		elsif(rising_edge(rclk)) then
			if out_req = '1' then
				data_out <= ram( to_integer(unsigned(raddr)) );
			end if;	
		end if;
	end process;

end rtl;
