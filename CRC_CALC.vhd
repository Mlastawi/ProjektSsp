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
	read_en : in std_logic;
	
	mode : in std_logic; -- 0 - licz CRC, 1 - sprawdz CRC
	
	-- Output ports
	data_out : out std_logic_vector(11 downto 0);
	finish : out std_logic;
	data_req : out std_logic
);
end CRC_CALC;

architecture arch of CRC_CALC is

	signal len_counter : unsigned(15 downto 0);

	signal counter : signed(16 downto 0);
	
	signal conc : std_logic_vector(27 downto 0);
	
	signal poly : std_logic_vector(12 downto 0);	
	signal poly_wrap : std_logic_vector(31 downto 0);
	
	signal reminder : std_logic_vector(11 downto 0);
	signal dividend : std_logic_vector(15 downto 0);

	signal two_bytes : std_logic_vector(31 downto 0);
	
	signal fin_inside : std_logic;
	
	signal flag : std_logic;
	signal data_loaded : std_logic;
	
	signal code_to_check : std_logic_vector(11 downto 0);

begin
	poly <= "1100000001111" when crc_type = '0' and endiannes = '0' else --0x80f
			"1111000000011" when crc_type = '0' and endiannes = '1' else --0xf01
			"1111100010011" when crc_type = '1' and endiannes = '0' else --0xf13
			"1100100011111" when crc_type = '1' and endiannes = '1' else --0xc8f
			"0000000000000";
			
	data_out <= reminder when fin_inside = '1'
				else (others => '0');
	reminder <= conc(11 downto 0);
	dividend <= conc(27 downto 12);
	
process(CLK, RST)
begin
	if(rst = '0') then
		
		data_loaded <= '0';
		data_req <= '0';
		two_bytes <= (others => '0');
		conc <= (others => '0');
		
		counter <= (others => '0');
		len_counter <= len;
		
		finish <= '0';
		fin_inside <= '0';
		
		poly_wrap <= poly & X"0000" & "000";
		code_to_check <= (others => '0');
		
	elsif rising_edge(clk) and start = '1' then
		if data_loaded = '0' then --jesli nie wczytano zadnych danych
			data_req <= '1';
			if read_en = '1' then --gdy FSM da zgode na odczyt
				data_loaded <= '1';
				data_req <= '0';
				len_counter <= len;
					if(len = 1) then --w zaleznosci od dlugosci bloku dane przypisywane sa bezposrednio do conc
						conc <= data_in & "000000000000";
						two_bytes <= (others => '0');
						flag <= '1';
					else --lub do 2 bajtowego slowa
						two_bytes <= X"0000" & data_in;
						conc <= (others => '0');
						flag <= '0';
					end if;
			end if;
		elsif len_counter = 1 and flag = '1' then --operacja CRC gdy zostalo ostatnie slowo
			if conc(27 downto 12) = X"0000" then --gdy "starsza czesc" conc = 0 znaczy ze koniec
				finish <= '1';
				fin_inside <= '1';
				
			elsif(conc(conc'length - to_integer(counter)-1) /= '1') then --jesli aktualny bit nie jest rowny 1, jedynie przesuniecie
				counter <= counter + 1;
				finish <= '0'; 
				fin_inside <= '0';				
				poly_wrap <= '0' & poly_wrap(31 downto 1);
				
			elsif(counter < conc'length - poly'length + 1) then	--jesli jest to xor			
				conc <= conc xor poly_wrap(31 downto 4);
				poly_wrap <= '0' & poly_wrap(31 downto 1);
				
				counter <= counter + 1;
				finish <= '0';
				fin_inside <= '0';
			end if;
			
		elsif len_counter >= 1 and flag = '0' then --operacja CRC gdy zostalo wiecej niz jedno slowo
			if two_bytes(31 downto 16) = X"0000" then --gdy starszy bajt = 0 wczytaj nastepny
				poly_wrap <= poly & X"0000" & "000";
				if len_counter > 1 then					
						data_req <= '1';
					if read_en = '1' then
						len_counter <= len_counter - 1;
						data_req <= '0';
						two_bytes(31 downto 16) <= two_bytes(15 downto 0);
						two_bytes(15 downto 0) <= data_in;
						counter <= (others => '0');
					end if;
					
				elsif len_counter = 1 then
					if mode = '0' then
						conc <= two_bytes(15 downto 0) & X"000";
					--else
					end if;
					counter <= (others => '0');
					flag <= '1';
				end if;
			else
				if(two_bytes(two_bytes'length - to_integer(counter)-1) /= '1') then --jesli aktualny bit nie jest rowny 1, jedynie przesuniecie
					counter <= counter + 1;
					poly_wrap <= '0' & poly_wrap(31 downto 1);
				else two_bytes <= two_bytes xor poly_wrap; --jesli jest to xor	
					counter <= counter + 1;
					
					poly_wrap <= '0' & poly_wrap(31 downto 1);
				end if;
			end if;
		end if;
	end if;
end process;

end arch;
