library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

package memarray_pkg is
	component memarray is
	generic
	(
		DATA_WIDTH      : integer range 0 to 7;         -- ASCII-Werte von 0 - 127 reicht
		LINES           : integer range 0 to 50;        -- speichern der letzten 50 berechnungen
		LINE_LENGTH     : integer range 0 to 81         -- eingabe(80byte) + delimter + ergebnis(10byte)
	);
	port
	(
		sys_clk		: in std_logic;
		sys_res_n	: in std_logic;
		wr		: in std_logic;
		ram_bank        : in std_logic_vector(LINES - 1 downto 0);
		ram_offset      : in std_logic_vector(LINE_LENGTH -1 downto 0);
		data_in		: in std_logic_vector(DATA_WIDTH - 1 downto 0);
		data_out	: out std_logic_vector(DATA_WIDTH - 1 downto 0)
	);
	end component memarray;
end package memarray_pkg;

