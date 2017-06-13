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
	len : in std_logic_vector(15 downto 0);
	start : in std_logic;
	crc_type : in std_logic;
	
	-- Output ports
	data_out : out std_logic_vector(11 downto 0);
	finish : out std_logic
);
end CRC_CALC;

architecture arch of CRC_CALC is


	signal counter : signed(16 downto 0);
	signal tst : std_logic_vector(12 downto 0);
	signal chunk : std_logic_vector(12 downto 0);
	
	signal conc : std_logic_vector(12+15 downto 0);
	
	signal poly : std_logic_vector(12 downto 0);
	signal reminder : std_logic_vector(11 downto 0);
	signal dividend : std_logic_vector(15 downto 0);
--obliczane CRC: (x12+x11+x3+x2+x+1)

begin
	poly <= "1100000001111" when crc_type = '0' else
			"1001111100011";
			
	--tst <= clk & clk & clk & clk & clk & clk;
	--finish <= clk xor start; 
	--data_out <= data_in(11 downto 0) xor poly;
	reminder <= conc(11 downto 0);
	dividend <= conc(27 downto 12);
	
process(CLK, RST)
begin
	if(rst = '0') then
		conc <= X"aaaa" & "000000000000";--(others => '0');
		counter <= (others => '0');
	elsif rising_edge(clk) then
		
		if conc(27 downto 12) = X"0000" then
			finish <= '1';
		elsif(conc(conc'length - to_integer(counter)-1) /= '1') then
			counter <= counter + 1;
			finish <= '0'; 
		elsif(counter < conc'length - poly'length + 1) then
			tst <= conc(conc'length - to_integer(counter)-1 downto (conc'length - to_integer(counter) - 13));
			chunk <= conc(conc'length - to_integer(counter)-1 downto (conc'length - to_integer(counter) - 13)) xor poly;
			conc <= conc(conc'length - 1 downto conc'length - to_integer(counter)) & ((conc(conc'length - to_integer(counter)-1 downto (conc'length - to_integer(counter) - 13))) xor poly) & conc((conc'length - to_integer(counter) - 13 - 1) downto 0);
			counter <= counter + 1;
			finish <= '0';
		--else
			--finish <= '1';
		end if;
		
	end if;
end process;
end arch;
