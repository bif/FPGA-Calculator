library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package main_pkg is
	component main is
		generic
		(
			RESET_VALUE	:	std_logic;
			DAT_WIDTH	:	integer range 1 to integer'high;
			ADR_WIDTH	:	integer range 1 to integer'high
		);
		port
		(
			sys_clk		:	in std_logic;
			sys_res_n	:	in std_logic;
			sense		:	in std_logic;
			uart_main_tx	:	out   std_logic;
			uart_main_rx	:	in    std_logic;
			trigger_main_tx	:	out   std_logic;
			start_calc	:	in    std_logic;
			decode_ready	:	in    std_logic;			-- rising edge after BCD-conversion of calculation is done
			lb_enable	:	out   std_logic;
			lb_data		:	in    std_logic_vector(DAT_WIDTH - 1 downto 0);
			lb_addr		:	out   std_logic_vector(ADR_WIDTH - 1 downto 0);
	                nibble_0	: in unsigned(3 downto 0) := "0000";         -- calculation nibble 0 (einerstelle)
		        nibble_1	: in unsigned(3 downto 0) := "0000";         -- ...     
		        nibble_2	: in unsigned(3 downto 0) := "0000";
		        nibble_3	: in unsigned(3 downto 0) := "0000";
		        nibble_4	: in unsigned(3 downto 0) := "0000";
		        nibble_5	: in unsigned(3 downto 0) := "0000";
		        nibble_6	: in unsigned(3 downto 0) := "0000";
		        nibble_7	: in unsigned(3 downto 0) := "0000";
		        nibble_8	: in unsigned(3 downto 0) := "0000";
		        nibble_9	: in unsigned(3 downto 0) := "0000"         -- ... most significant nibble
	);
	end component main;
end package main_pkg;
