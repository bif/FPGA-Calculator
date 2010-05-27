library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

architecture beh of memarray is
	subtype RAM_CELL is std_logic_vector(7 downto 0);					-- 8 bit for every ram cell
	type MEM_ARRAY is array (0 to (2 ** 12) - 1) of RAM_CELL;	-- 2d - array: 80x50 consisiting of RAM_CELL
	signal ram : MEM_ARRAY := (
0 => x"30", 81 => x"31", 162 => x"32", 243 => x"33", 324 => x"34", 405 => x"35", 486 => x"36", 567 => x"37", 648 => x"38", 729 => x"39",
1 => x"30", 82 => x"31", 163 => x"32", 244 => x"33", 325 => x"34", 406 => x"35", 487 => x"36", 568 => x"37", 649 => x"38", 730 => x"39",
2 => x"30", 83 => x"31", 164 => x"32", 245 => x"33", 326 => x"34", 407 => x"35", 488 => x"36", 569 => x"37", 650 => x"38", 731 => x"39",
3 => x"30", 84 => x"31", 165 => x"32", 246 => x"33", 327 => x"34", 408 => x"35", 489 => x"36", 570 => x"37", 651 => x"38", 732 => x"39",
--70 => x"3d", 151 => x"3d", 232 => x"3d", 313 => x"3d", 394 => x"3d", 475 => x"3d", 556 => x"3d", 637 => x"3d", 718 => x"3d", 799 => x"3d",
70 => x"3d", 151 => x"3d", 232 => x"3d", 313 => x"3d", 394 => x"3d", 475 => x"3d", 556 => x"3d", 637 => x"3d", 718 => x"3d", 799 => x"3d", 880 => x"3d", 961 => x"3d", 1042 => x"3d", 1123 => x"3d", 1204 => x"3d", 1285 => x"3d", 1366 => x"3d", 1447 => x"3d", 1528 => x"3d", 1609 => x"3d", 1690 => x"3d", 1771 => x"3d", 1852 => x"3d", 1933 => x"3d", 2014 => x"3d", 2095 => x"3d", 2176 => x"3d", 2257 => x"3d", 2338 => x"3d", 2419 => x"3d", 2500 => x"3d", 2581 => x"3d", 2662 => x"3d", 2743 => x"3d", 2824 => x"3d", 2905 => x"3d", 2986 => x"3d", 3067 => x"3d", 3148 => x"3d", 3229 => x"3d", 3310 => x"3d", 3391 => x"3d", 3472 => x"3d", 3553 => x"3d", 3634 => x"3d", 3715 => x"3d", 3796 => x"3d", 3877 => x"3d", 3958 => x"3d", 4039 => x"3d",
3997 => x"47",
3998 => x"48",
3999 => x"49",
4000 => x"4A",
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
