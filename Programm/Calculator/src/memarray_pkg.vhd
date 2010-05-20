library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

package memarray_pkg is
	component memarray is
	generic
	(
		DATA_WIDTH      : integer range 0 to 7;         -- ASCII-Werte
		LINES           : integer range 0 to 50;        -- speichern der letzten 50 berechnungen
		LINE_LENGTH     : integer range 0 to 81         -- eingabe(80byte) + delimter + ergebnis(10byte)
	);
	port
	(
		sys_clk		: in std_logic;
		sys_res_n	: in std_logic;
		wr		: in std_logic;
		ram_bank        : in integer range 0 to 50;
		ram_offset      : in integer range 0 to 80;
		data_in		: in integer range 0 to 255;
		data_out	: out integer range 0 to 255
	);
	end component memarray;
end package memarray_pkg;

