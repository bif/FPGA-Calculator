library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package error_msg_pkg is

	type		ERR_STR	is array(10 downto 0) of std_logic_vector(7 downto 0);
	constant	err_str_divbyzero : ERR_STR :=	(	0 => x"44",	-- D
								1 => x"49",	-- I
								2 => x"56",	-- V
								3 => x"20",	-- _
								4 => x"42",	-- B
								5 => x"59",	-- Y
								6 => x"20",	-- _
								7 => x"5A",	-- Z
								8 => x"45",	-- E
								9 => x"52",	-- R
								10 => x"4F");	-- O

	constant	err_str_overflow : ERR_STR := 	(	0 => x"20",	-- _
								1 => x"4F",	-- O
								2 => x"56",	-- V
								3 => x"45",	-- E
								4 => x"52",	-- R
								5 => x"46",	-- F
								6 => x"4C",	-- L
								7 => x"4F",	-- O
								8 => x"57",	-- W
								9 => x"20",	-- _
								10 => x"20");	-- _

	constant	err_str_parsererror : ERR_STR :=(	0 => x"50",	-- P
								1 => x"41",	-- A
								2 => x"52",	-- R
								3 => x"53",	-- S
								4 => x"45",	-- E
								5 => x"52",	-- R
								6 => x"45",	-- E
								7 => x"52",	-- R
								8 => x"52",	-- R
								9 => x"4F",	-- O
								10 => x"52");	-- R

end package error_msg_pkg;
