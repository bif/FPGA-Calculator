library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

architecture beh of memarray is
	subtype RAM_CELL is std_logic_vector(7 downto 0);					-- 8 bit for every ram cell
	type MEM_ARRAY is array (0 to (2 ** 12) - 1) of RAM_CELL;	-- 2d - array: 80x50 consisiting of RAM_CELL
	signal ram : MEM_ARRAY := (
0 => x"30", 81 => x"31", 162 => x"32", 243 => x"33", 324 => x"34", 405 => x"35", 486 => x"36", 567 => x"37", 648 => x"38", 729 => x"39",
others => x"00");

begin
	process(sys_clk, sys_res_n)
	begin
		if(sys_res_n = '0')
		then
			data_out <= x"00";
		elsif(rising_edge(sys_clk))
		then
			data_out <= ram(ram_offset);
	
			if wr = '1' then
				if ram_offset = 0 then
					ram(ram_offset) <= data_in;
				else
					ram(ram_offset-1) <= data_in;
				end if;
			end if;
		end if;
	end process;

end architecture beh;
