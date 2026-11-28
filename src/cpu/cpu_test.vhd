library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity CPU_TEST is

end CPU_TEST;


architecture test of CPU_TEST is

	component CPU is
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
		
		

	end component;
	
	signal clock : std_logic := '0';
	signal d : std_logic_vector (7 downto 0);
	signal addr : std_logic_vector (15 downto 0);
	signal enable_control : std_logic_vector (2 downto 0) := "000";
	
	signal oe1, oe2, o1, o2, o3, ad1, ad2, read_write : std_logic;
	
	signal a, b, c, p, d_out : std_logic_vector (7 downto 0) := "00000000";
	
	constant clk_period : time := 50ns;
	signal end_sim : std_logic := '0';
	constant wait_time : time := 50ns;
	

begin
	dut : CPU port map (
		clk => clock,
		DIN => d,
		DOUT => d_out,
		ADDR => addr,
		R_W => read_write,
		RAM_ENABLE => enable_control(0),
		PPU_ENABLE => enable_control(1),
		CART_ENABLE => enable_control(2),
		IRQ => '0',
		NMI => '0',
		OE1 => oe1,
		OE2 => oe2,
		OUT1 => o1,
		OUT2 => o2,
		OUT3 => o3,
		AD1 => ad1,
		AD2 => ad2,
		RST => '0',
		A_reg => a,
		X_reg => b,
		Y_reg => c,
		status => p
	);
	
	clock <= NOT(clock) after clk_period/2;
	
	test: process
	
	begin
		if (end_sim = '0') then
			d <= x"A9";
			wait for wait_time;
			d <= x"01";


--			wait for wait_time;
--			d <= x"38";
--			wait for wait_time*2;
--			d <= x"C9";
--			wait for wait_time;
--			d <= x"01";
--			wait for wait_time;
--			d <= x"A9";
--			wait for wait_time;
--			d <= x"0B";
--			wait for wait_time;
--			d <= x"C9";
--			wait for wait_time;
--			d <= x"0E";
--			wait for wait_time;
--			d <= x"49";
--			wait for wait_time;
--			d <= x"9B";
			
--			d <= x"A0";
--			wait for wait_time;
--			d <= x"F0";
--			wait for wait_time;
--			d <= x"69";
--			wait for wait_time;
--			d <= x"09";
--			wait for wait_time;
--			d <= x"A9";
--			wait for wait_time;
--			d <= x"02";
--			wait for wait_time;
--			d <= x"69";
--			wait for wait_time;
--			d <= x"FE";
--			wait for wait_time;
--			d <= x"A9";
--			wait for wait_time;
--			d <= x"01";
--			wait for wait_time;
--			d <= x"29";
--			wait for wait_time;
--			d <= x"01";
--			wait for wait_time;
--			d <= x"29";
--			wait for wait_time;
--			d <= x"A0";
--			wait for wait_time;
--			d <= x"09";
--			wait for wait_time;
--			d <= x"A4";
--			wait for wait_time;
--			d <= x"18";
--			wait for wait_time*2;
--			d <= x"E9";
--			wait for wait_time;
--			d <= x"A5";
--			wait for wait_time;
--			d <= x"38";
			
			
			end_sim <= '1';
			wait;
		end if;		
	
	end process;


end test;