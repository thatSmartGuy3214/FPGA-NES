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
		DIN : in std_logic_vector (7 downto 0);
		DOUT : in std_logic_vector (7 downto 0);
		ADDR : out std_logic_vector (15 downto 0);
		R_W : out std_logic; -- Bit for reading and writing; 0 - Write, 1 - Read
		RAM_ENABLE : out std_logic;
		PPU_ENABLE : out std_logic;
		CART_ENABLE : out std_logic;
		
		IRQ : in std_logic; -- Interrupt pin (Negative logic)
		NMI : in std_logic; -- Non Maskable Interrupt Pin (Negative logic)
		
		-- Controller enable pins (Negative logic)
		OE1 : out std_logic;
		OE2 : out std_logic;
		
		-- Controller output pins
		OUT1 : out std_logic;
		OUT2 : out std_logic;
		OUT3 : out std_logic;
		
		-- Audio pins
		AD1 : out std_logic;
		AD2 : out std_logic;
		
		
		RST : in std_logic; -- Negative logicl; puts cpu in reset state where all pins are in high impedance. (except pin2)
		
		-- Signals for testing, comment out in later.
		A_reg : out std_logic_vector (7 downto 0); 
		X_reg : out std_logic_vector (7 downto 0);
		Y_reg : out std_logic_vector (7 downto 0);
		status : out std_logic_vector (7 downto 0)
	
	);

end CPU;


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity flow_check is
	
	port (
		A : in std_logic_vector (7 downto 0);
		B : in std_logic_vector (7 downto 0);
		
		Carry : out std_logic
		
	);
	
end flow_check;

architecture flow of flow_check is
	signal sum : integer range -128 to 127;
	signal sum_to_bytes : std_logic_vector (7 downto 0);

begin
	
	sum <= to_integer(signed(A)) + to_integer(signed(B));
	sum_to_bytes <= std_logic_vector(to_signed(sum, 8));
	
	Carry <= (NOT(A(7)) and NOT(B(7)) AND sum_to_bytes(7)) or (A(7) and B(7) AND NOT(sum_to_bytes(7)));

end flow;


architecture processor of CPU is

	type addr_mode is 
	( ZERO_PAGE, I_ZERO_PAGE_X, I_ZERO_PAGE_Y, ABSOLUTE, I_ABS_X, I_ABS_Y, INDIRECT, IMPLIED, 
	ACCUMALATOR, IMMEDIATE, REL, I_INDIRECT, INDIRECT_I); -- Addressing modes (In the  order found in the NESDoc.pdf
	
	type opcode is 
		(
		LDA,
		LDX,
		LDY,
		ADC,
		SBC,
		AND_CODE,
		ORA,
		SEC,
		CLC,
		EOR,
		CMP,
		CPX,
		CPY
			
		);
	
	type operation is
		(
			FETCH_CODE,
			FETCH_FROM_ADDR,
			FETCH_LOW_BYTE,
			FETCH_HIGH_BYTE,
			USE_VALUE,
			INSTRUCTION_COMPLETE,
			WRITE_TO_ADDR
		);
	
	-- clock enable system to use a single clock (Avoid unnessary synthesis issues
	signal counter : integer range 0 to 1 := 0;
	signal phase1 : std_logic := '0'; -- ON when counter is 0
	signal phase2 : std_logic := '0'; -- ON when counter is 1
	
	-- Registers
	-- Special purpose
	signal PC : integer range 0 to 65535; -- Program Counter (Might change this later. Just very inconvenient to do converesions between unsigned integers and std_logic vector)
	signal SP : integer range 0 to 255; -- Stack pointer (The stack has 256 entries)
	signal P : std_logic_vector (7 downto 0) := "00000000"; -- Status register
	signal IR : opcode; -- Instruction register (Hods the current instruction
	
		
	-- General
	signal A : std_logic_vector (7 downto 0); -- Accumulator
	signal X : std_logic_vector (7 downto 0);
	signal Y : std_logic_vector (7 downto 0);
	
	signal curr_op : operation := FETCH_CODE;
	signal mode : addr_mode;
	
	signal address : std_logic_vector (15 downto 0); 
	
begin
	
	phase_ctrl: process(clk)
	begin
		
		phase1 <= not clk;
		phase2 <= clk;

	end process;
	
	phi1: process(phase1) -- Establish the read/write signal and address
	begin
		
		if rising_edge(phase1) then
			
			if curr_op = FETCH_CODE then
				address <= std_logic_vector(to_unsigned(PC, 16));
				R_W <= '1';
			else
				
				case mode is
					when IMMEDIATE =>
						
						case IR is 
							when LDA =>
								address <= std_logic_vector(to_unsigned(PC, 16));
								R_W <= '1';
							when LDX => 
								address <= std_logic_vector(to_unsigned(PC, 16));
								R_W <= '1';
							when LDY => 
								address <= std_logic_vector(to_unsigned(PC, 16));
								R_W <= '1';
							when ADC =>
								address <= std_logic_vector(to_unsigned(PC, 16));
								R_W <= '1';
							when SBC =>
								address <= std_logic_vector(to_unsigned(PC, 16));
								R_W <= '1';
							
							when AND_CODE =>
								address <= std_logic_vector(to_unsigned(PC, 16));
								R_W <= '1';
							
							when ORA =>
								address <= std_logic_vector(to_unsigned(PC, 16));
								R_W <= '1';
							
							when EOR =>
								address <= std_logic_vector(to_unsigned(PC, 16));
								R_W <= '1';
							
							when CMP =>
								address <= std_logic_vector(to_unsigned(PC, 16));
								R_W <= '1';
							
							when CPX =>
								address <= std_logic_vector(to_unsigned(PC, 16));
								R_W <= '1';
							
							when CPY =>
								address <= std_logic_vector(to_unsigned(PC, 16));
								R_W <= '1';
							
							
						
						end case;
						
						
					when ZERO_PAGE =>
						AD1 <= '0'; -- stubbed command
					when I_ZERO_PAGE_X =>
						AD1 <= '0';
					when I_ZERO_PAGE_Y =>
						AD1 <= '0';
					when ABSOLUTE =>
						AD1 <= '0';
					when I_ABS_X =>
						AD1 <= '0';
					when I_ABS_Y =>
						AD1 <= '0';
					when INDIRECT =>
						AD1 <= '0';
					when IMPLIED =>
						
						case IR is
						
							when SEC =>
								address <= std_logic_vector(to_unsigned(PC, 16));
								R_W <= '1';
								
							when CLC =>
								address <= std_logic_vector(to_unsigned(PC, 16));
								R_W <= '1';
								
							when others =>
								R_W <= '1';
						
						end case;
						
					when ACCUMALATOR =>
						AD1 <= '0';
					when REL =>
						AD1 <= '0';
					when I_INDIRECT =>
						AD1 <= '0';
					when INDIRECT_I =>
						AD1 <= '0';
				
				end case;
				
			end if;
			
		
		end if;
	
	end process;
	
	phi2: process(phase2) -- Do actual bus stuff
		variable sum : unsigned (8 downto 0);
		variable result : std_logic_vector(7 downto 0);
		variable complement : signed (7 downto 0);
		
	begin
		if rising_edge(phase2) then
			
			if curr_op = FETCH_CODE then
				case (DIN) is
					
					when x"A9" =>
						IR <= LDA;
						curr_op <= USE_VALUE;
						mode <= IMMEDIATE;
						PC <= PC + 1;
					
					when x"A2" =>
						IR <= LDX;
						curr_op <= USE_VALUE;
						mode <= IMMEDIATE;
						PC <= PC + 1;
					
					when x"A0" =>
						IR <= LDY;
						curr_op <= USE_VALUE;
						mode <= IMMEDIATE;
						PC <= PC + 1;
					
					when x"69" =>
						IR <= ADC;
						curr_op <= USE_VALUE;
						mode <= IMMEDIATE;
						PC <= PC + 1;
					
					when x"E9" =>
						IR <= SBC;
						curr_op <= USE_VALUE;
						mode <= IMMEDIATE;
						PC <= PC + 1;
					 
					 when x"29" =>
						IR <= AND_CODE;
						curr_op <= USE_VALUE;
						mode <= IMMEDIATE;
						PC <= PC + 1;
						
					 when x"09" =>
						IR <= ORA;
						curr_op <= USE_VALUE;
						mode <= IMMEDIATE;
						PC <= PC + 1;
					 
					 when x"38" =>
						IR <= SEC;
						curr_op <= USE_VALUE;
						mode <= IMPLIED;
						PC <= PC + 1;
					
					when x"18" =>
						IR <= CLC;
						curr_op <= USE_VALUE;
						mode <= IMPLIED;
						PC <= PC + 1;
					
					when x"49" =>
						IR <= EOR;
						curr_op <= USE_VALUE;
						mode <= IMMEDIATE;
						PC <= PC + 1;
					
					when x"C9" =>
						IR <= CMP;
						curr_op <= USE_VALUE;
						mode <= IMMEDIATE;
						PC <= PC + 1;
					
					when x"E0" =>
						IR <= CPX;
						curr_op <= USE_VALUE;
						mode <= IMMEDIATE;
						PC <= PC + 1;
					
					when x"C0" =>
						IR <= CPY;
						curr_op <= USE_VALUE;
						mode <= IMMEDIATE;
						PC <= PC + 1;
						
					when others => 
						PC <= PC + 1; -- MUST CHANGE!!!! NOT THE BEST WAY TO DEAL WITH INVALID(UNOFFICIAL) OPCODES
				
				end case;
				
			else
				
				case (mode) is
					
					when IMMEDIATE =>
						
						case IR is 
							when LDA =>
								A <= DIN;
								curr_op <= FETCH_CODE;
							when LDX =>
								X <= DIN;
								curr_op <= FETCH_CODE;
							when LDY =>
								Y <= DIN;
								curr_op <= FETCH_CODE;
							when ADC =>
								sum := unsigned("0" & A) + unsigned("0" & DIN) + unsigned'('0' & P(0));
								result := std_logic_vector(sum(7 downto 0));
								-- Set flags
								
								P(0) <= sum(8);
								
								if result = "00000000" then
									P(1) <= '1';
								else
									P(1) <= '0';
								end if;
											
								P(6) <= (result(7) xor A(7)) and (result(7) xor DIN(7));
								P(7) <= result(7);
								
								A <= result;
									
								curr_op <= FETCH_CODE;
							
							when SBC =>
								complement := -(signed(DIN));
								sum := unsigned("0" & A) + unsigned("0" & complement) + unsigned'('0' & P(0));
								result := std_logic_vector(sum(7 downto 0));
								
								P(0) <= sum(8);
								
								if result = "00000000" then
									P(1) <= '1';
								else
									P(1) <= '0';
								end if;
											
								P(6) <= (result(7) xor A(7)) and (result(7) xnor DIN(7));
								P(7) <= result(7);
								
								A <= result;
									
								curr_op <= FETCH_CODE;
							
							when AND_CODE =>
								result := A AND DIN;
								
								if result = "00000000" then
									P(1) <= '1';
								else
									P(1) <= '0';
								end if;
								P(7) <= result(7);
								
								A <= result;
									
								curr_op <= FETCH_CODE;
							
							when ORA =>
								result := A OR DIN;
								
								if result = "00000000" then
									P(1) <= '1';
								else
									P(1) <= '0';
								end if;
								P(7) <= result(7);
								
								A <= result;
									
								curr_op <= FETCH_CODE;
							
							when EOR =>
								result := A XOR DIN;
								
								if result = "00000000" then
									P(1) <= '1';
								else 
									P(1) <= '0';
								end if;
								P(7) <= result(7);
								
								A <= result;
								
								curr_op <= FETCH_CODE;
							
							when CMP =>
								sum := unsigned('0' & A) - unsigned('0' & DIN);
								result := std_logic_vector(sum(7 downto 0));
								
								if A >= DIN then
									P(0) <= '1';
								else
									P(0) <= '0';
								end if;
								
								if A = DIN then
									P(1) <= '1';
								else
									P(1) <= '0';
								end if;
								
								P(7) <= result(7);
								
								
								curr_op <= FETCH_CODE;
							
							when CPX =>
								sum := unsigned('0' & X) - unsigned('0' & DIN);
								result := std_logic_vector(sum(7 downto 0));
								
								if X >= DIN then
									P(0) <= '1';
								else
									P(0) <= '0';
								end if;
								
								if X = DIN then
									P(1) <= '1';
								else
									P(1) <= '0';
								end if;
								
								P(7) <= result(7);
								
								
								curr_op <= FETCH_CODE;
							
							when CPY =>
								sum := unsigned('0' & Y) - unsigned('0' & DIN);
								result := std_logic_vector(sum(7 downto 0));
								
								if Y >= DIN then
									P(0) <= '1';
								else
									P(0) <= '0';
								end if;
								
								if Y = DIN then
									P(1) <= '1';
								else
									P(1) <= '0';
								end if;
								
								P(7) <= result(7);
								
								curr_op <= FETCH_CODE;
								
								
						
						end case;
						
						
					when ZERO_PAGE =>
						AD1 <= '0'; -- stubbed command
					when I_ZERO_PAGE_X =>
						AD1 <= '0';
					when I_ZERO_PAGE_Y =>
						AD1 <= '0';
					when ABSOLUTE =>
						AD1 <= '0';
					when I_ABS_X =>
						AD1 <= '0';
					when I_ABS_Y =>
						AD1 <= '0';
					when INDIRECT =>
						AD1 <= '0';
					when IMPLIED =>
						
						case IR is
						
							when SEC =>
								P(0) <= '1';
								curr_op <= FETCH_CODE;
							
							when CLC =>
								P(0) <= '0';
								curr_op <= FETCH_CODE;
								
							when others =>
								PC <= PC;
						
						end case;
						
					when ACCUMALATOR =>
						AD1 <= '0';
					when REL =>
						AD1 <= '0';
					when I_INDIRECT =>
						AD1 <= '0';
					when INDIRECT_I =>
						AD1 <= '0';
					
				
				end case;
			
			end if;
			
			
				
		end if;
	
	end process;
	
	ADDR <= address;
	
	RAM_ENABLE <=  '1' when (address(14) = '0' and address(13) = '0') else
						'0';
	
	A_reg <= A;
	X_reg <= X;
	Y_reg <= Y;
	status <= P;
	
end processor;

