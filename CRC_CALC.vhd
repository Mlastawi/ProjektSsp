library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.all;

entity CRC_CALC is
port(
	-- Input ports
	clk : in std_logic;
	rst : in std_logic;
	endiannes : in std_logic;
	data_in : in std_logic_vector(15 downto 0);
	len : in unsigned(15 downto 0);
	start : in std_logic;
	crc_type : in std_logic;
	
	empty_fifo : in std_logic;
	
	-- Output ports
	data_out : out std_logic_vector(11 downto 0);
	finish : out std_logic;
	data_req : out std_logic
);
end CRC_CALC;

architecture arch of CRC_CALC is

	signal len_counter : unsigned(15 downto 0);

	signal counter : signed(16 downto 0);
	signal tst : std_logic_vector(12 downto 0);
	signal chunk : std_logic_vector(12 downto 0);
	
	signal conc : std_logic_vector(27 downto 0);
	
	signal poly : std_logic_vector(12 downto 0);
	
	signal poly_wrap : std_logic_vector(31 downto 0);
	
	signal reminder : std_logic_vector(11 downto 0);
	signal dividend : std_logic_vector(15 downto 0);

	signal two_bytes : std_logic_vector(31 downto 0);
	
	signal fin_inside : std_logic;
	signal data_req_inside : std_logic;
	
	signal flag : std_logic;
	signal data_loaded : std_logic;
	signal wait_state : std_logic_vector(1 downto 0);

begin
	poly <= "1100000001111" when crc_type = '0' and endiannes = '0' else --0x80f
			"1111000000011" when crc_type = '0' and endiannes = '1' else --0xf01
			"1111100010011" when crc_type = '1' and endiannes = '0' else --0xf13
			"1100100011111" when crc_type = '1' and endiannes = '1' else --0xc8f
			"0000000000000";
			
	data_out <= reminder when fin_inside = '1';
	reminder <= conc(11 downto 0);
	dividend <= conc(27 downto 12);
	
process(CLK, RST)
begin
	if(rst = '0') then
		
		data_loaded <= '0';
		wait_state <= "00";
		data_req_inside <= '0';
		data_req <= '0';
		two_bytes <= (others => '0');
		conc <= (others => '0');
		
		counter <= (others => '0');
		len_counter <= len;
		
		finish <= '0';
		fin_inside <= '0';
		
		poly_wrap <= poly & X"0000" & "000";
		
	elsif rising_edge(clk) and start = '1' then
		if data_loaded = '0' then
			len_counter <= len;
			if empty_fifo = '0' then
				if wait_state = "00" then
					data_loaded <= '0';
					wait_state <= "01";
					data_req_inside <= '1';
					data_req <= '1';
				elsif wait_state = "01" then
					wait_state <= "10";
					data_req_inside <= '0';
					data_req <= '0';
				elsif wait_state = "10" then	
					wait_state <= "00";
					
					data_loaded <= '1';
					if(len = 1) then
						conc <= data_in & "000000000000";
						two_bytes <= (others => '0');
						flag <= '1';
					else
						two_bytes <= X"0000" & data_in;
						conc <= (others => '0');
						tst <= (others => '1');
						flag <= '0';
					end if;
				end if;
			end if;
		elsif len_counter = 1 and flag = '1' then
			if conc(27 downto 12) = X"0000" then
				finish <= '1';
				fin_inside <= '1';
			elsif(conc(conc'length - to_integer(counter)-1) /= '1') then
				counter <= counter + 1;
				finish <= '0'; 
				fin_inside <= '0';
				
				poly_wrap <= '0' & poly_wrap(31 downto 1);
			elsif(counter < conc'length - poly'length + 1) then				
				conc <= conc xor poly_wrap(31 downto 4);
				poly_wrap <= '0' & poly_wrap(31 downto 1);
				
				counter <= counter + 1;
				finish <= '0';
				fin_inside <= '0';
			end if;
		elsif len_counter >= 1 and flag = '0' then
			if two_bytes(31 downto 16) = X"0000" then
				poly_wrap <= poly & X"0000" & "000";
				if len_counter > 1 then
					if data_req_inside = '1' and empty_fifo = '0' then
						two_bytes(31 downto 16) <= two_bytes(15 downto 0);
						two_bytes(15 downto 0) <= data_in;
						data_req_inside <= '0';
						data_req <= '0';
						len_counter <= len_counter - 1;
						counter <= (others => '0');
						
					elsif data_req_inside = '0' then
						data_req_inside <= '1';
						data_req <= '1';
					end if;
				elsif len_counter = 1 then
					conc <= two_bytes(15 downto 0) & X"000";
					counter <= (others => '0');
					flag <= '1';
				end if;
			else
				if(two_bytes(two_bytes'length - to_integer(counter)-1) /= '1') then
					counter <= counter + 1;
					poly_wrap <= '0' & poly_wrap(31 downto 1);
				else two_bytes <= two_bytes xor poly_wrap;
					counter <= counter + 1;
					
					poly_wrap <= '0' & poly_wrap(31 downto 1);
				end if;
			end if;
		end if;
	end if;
end process;

end arch;
