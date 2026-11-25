-- Nes Work RAM
-- 2KB memory
-- Asynchronous (So, data values just get updated without a clk and only get accessed when the CPU wants to read or write to it.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity RAM is
	port (		
		DIN: in std_logic_vector (7 downto 0);
		DOUT: out std_logic_vector (7 downto 0);
		ADDR : in std_logic_vector (15 downto 0);
		RD : in std_logic;
		WRT : in std_logic;
		ENABLE : in std_logic;
		RST : in std_logic;
	);

end RAM;


architecture reg of RAM is
	type mem is array (0 to 2047) of std_logic_vector (7 downto 0) := "00000000"; -- 2KB memory
	signal data : mem;
	signal loc : integer range 0 to 2047;
	signal output : std_logic_vector (7 downto 0);
	
	signal control : std_logic_vector (2 downto 0);
	

begin

	loc <= to_integer(unsigned(ADDR));
	control <= ENABLE & RD & WRT;
	
	output <= data(loc) when control = "110" else
				 "ZZZZZZZZ";
	
	data(loc) <= DIN when control = "101" else
					  data(loc);
	
	DOUT <= output;
	
end reg;


