-- NES CPU
-- I will only be implementing the official opcodes. I'm too lazy to implement the other codes.
-- Hexidecimal is the number system that is utilised by the NES
-- I will also try to document the instruction cycle as much as possible(So that I don't confuse myself)

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity CPU is
	port (
		-- Clock
		clk : in std_logic;
		
		-- BUSES
		DATA : inout std_logic_vector (7 downto 0);
		ADDR : out std_logic_vector (15 downto 0);
		R_W : out std_logic; -- Bit for reading and writing; 0 - Write, 1 - Read
		RAM_ENABLE : out std_logic;
		PPU_ENABLE : out std_logic;
		CART_ENABLE : out std_logic;
		
		IRQ : in std_logic; -- Interrupt pin (Negative logic)
		NMI : in std_logic; -- Non Maskable Interrupt Pin (Negative logic)
		
		-- Controller enable pins (Negative logic)
		_OE1 : out std_logic;
		_OE2 : out std_logic;
		
		-- Controller output pins
		OUT1 : out std_logic;
		OUT2 : out std_logic;
		OUT3 : out std_logic;
		
		-- Audio pins
		AD1 : out std_logic;
		AD2 : out std_logic;
		
		
		RST : in std_logic; -- Negative logicl; puts cpu in reset state where all pins are in high impedance. (except pin2)
	
	);

end CPU;



architecture processor of CPU is

	type ADDR_MODE is 
	( ZERO_PAGE, I_ZERO_PAGE_X, I_ZERO_PAGE_Y, ABSOLUTE, I_ABS_X, I_ABS_Y, INDIRECT, IMPLIED, 
	ACCUMALATOR, IMMEDIATE, REL, I_INDIRECT, INDIRECT_I); -- Addressing modes (In the  order found in the NESDoc.pdf
	
	-- clock enable system to use a single clock (Avoid unnessary synthesis issues
	signal counter : integer range 0 to 1 : 0;
	signal phase1 : std_logic := '0'; -- ON when counter is 0
	signal phase2 : std_logic := '0'; -- ON when counter is 1
	
	-- Registers
	-- Special purpose
	signal PC : std_logic_vector (15 downto 0) : x"0000"; -- Program Counter
	signal SP : integer range 0 to 255; -- Stack pointer (The stack has 256 entries)
	signal P : std_logic_vector (7 downto 0); -- Status register
	signal IR : integer 0 to 255; -- Instruction register (Hods the current instruction
	
		
	-- General
	signal A : out std_logic_vector (7 downto 0); -- Accumulator
	signal X : out std_logic_vector (7 downto 0);
	signal Y : out std_logic_vector (7 downto 0);
	
	
	
begin
	
	phase_ctrl: process(clk)
	begin
		
		if rising_edge(clk) then
			counter <= counter + 1;
			
			if counter = 0 then
				phase1 <= '1';
			else
				phase1 <= '0';
			end if;
			
			if counter = 1 then
				phase2<= '1';
			else
				phase2 <= '0';
			end if;
			
		end if;
		
	end process;
	
	phi1: process(phase1) -- Establish the read/write signal and address
	begin
		
	
	end process;
	
	phi2: process(phase2) -- Do actual bus stuff
	begin
		
	
	end process;


end processor;

