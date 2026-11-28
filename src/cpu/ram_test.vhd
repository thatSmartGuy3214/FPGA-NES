library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ram_test is

end ram_test;


architecture r of ram_test is
	
	component RAM is
		port (		
			DIN: in std_logic_vector (7 downto 0);
			DOUT: out std_logic_vector (7 downto 0);
			ADDR : in std_logic_vector (15 downto 0);
			RD : in std_logic;
			WRT : in std_logic;
			ENABLE : in std_logic;
			RST : in std_logic
		);

	end component;
	
	signal input : std_logic_vector (7 downto 0);
	signal d : std_logic_vector (7 downto 0);
	signal addr : std_logic_vector(15 downto 0) := x"0000";
	signal r_w : std_logic := '0';
	signal not_r_w : std_logic;
	signal en : std_logic := '0';
	signal reset : std_logic := '0';
	
	
	constant wait_time : time := 20ns;


begin
	dut : RAM port map (
		DIN => input,
		DOUT => d,
		ADDR => addr,
		RD => r_w,
		WRT => not_r_w,
		ENABLE => en,
		RST => reset
	);
	
	not_r_w <= not r_w;
	
	
	test: process
	begin
		input <= x"A2";
		en <= '1';
		wait for wait_time;
		addr <= x"0003";
		wait for wait_time;
		input <= x"F0";
		en <= '0';
		wait for wait_time;
		en <= '1';
		r_w <= '1';
		addr <= x"0000";
		wait for wait_time;
		addr <= x"0003";
		wait for wait_time;
		addr <= x"0002";
		wait for wait_time;
		en <= '0';
		wait for wait_time;
		wait;
	
	end process;
	

end r;





