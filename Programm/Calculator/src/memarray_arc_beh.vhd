library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

architecture beh of memarray is
	subtype RAM_CELL is std_logic_vector(7 downto 0);					-- 8 bit for every ram cell
	type MEM_ARRAY is array (0 to (2 ** 12) - 1) of RAM_CELL;	-- 2d - array: 80x50 consisiting of RAM_CELL
--	type MEM_ARRAY is array (4000 downto 0) of RAM_CELL;	-- 2d - array: 80x50 consisiting of RAM_CELL
	signal ram : MEM_ARRAY := (
0 => x"30", 80 => x"31", 160 => x"32", 240 => x"33", 320 => x"34", 400 => x"35", 480 => x"36", 560 => x"37", 640 => x"38", 720 => x"39", 
800 => x"30", 880 => x"31", 960 => x"32", 1040 => x"33", 1120 => x"34", 1200 => x"35", 1280 => x"36", 1360 => x"37", 1440 => x"38", 1520 => x"39",
801 => x"30", 881 => x"31", 961 => x"32", 1041 => x"33", 1121 => x"34", 1201 => x"35", 1281 => x"36", 1361 => x"37", 1441 => x"38", 1521 => x"39",
1600 => x"30", 1680 => x"31", 1760 => x"32", 1840 => x"33", 1920 => x"34", 2000 => x"35", 2080 => x"36", 2160 => x"37", 2240 => x"38", 2320 => x"39",
1601 => x"30", 1681 => x"31", 1761 => x"32", 1841 => x"33", 1921 => x"34", 2001 => x"35", 2081 => x"36", 2161 => x"37", 2241 => x"38", 2321 => x"39",  
1602 => x"30", 1682 => x"31", 1762 => x"32", 1842 => x"33", 1922 => x"34", 2002 => x"35", 2082 => x"36", 2162 => x"37", 2242 => x"38", 2322 => x"39",
2400 => x"30", 2480 => x"31", 2560 => x"32", 2640 => x"33", 2720 => x"34", 2800 => x"35", 2880 => x"36", 2960 => x"37", 3040 => x"38", 3120 => x"39",
2401 => x"30", 2481 => x"31", 2561 => x"32", 2641 => x"33", 2721 => x"34", 2801 => x"35", 2881 => x"36", 2961 => x"37", 3041 => x"38", 3121 => x"39",
2402 => x"30", 2482 => x"31", 2562 => x"32", 2642 => x"33", 2722 => x"34", 2802 => x"35", 2882 => x"36", 2962 => x"37", 3042 => x"38", 3122 => x"39",
2403 => x"30", 2483 => x"31", 2563 => x"32", 2643 => x"33", 2723 => x"34", 2803 => x"35", 2883 => x"36", 2963 => x"37", 3043 => x"38", 3123 => x"39",
3200 => x"30", 3280 => x"31", 3360 => x"32", 3440 => x"33", 3520 => x"34", 3600 => x"35", 3680 => x"36", 3760 => x"37", 3840 => x"38", 3920 => x"39",
3201 => x"30", 3281 => x"31", 3361 => x"32", 3441 => x"33", 3521 => x"34", 3601 => x"35", 3681 => x"36", 3761 => x"37", 3841 => x"38", 3921 => x"39",
3202 => x"30", 3282 => x"31", 3362 => x"32", 3442 => x"33", 3522 => x"34", 3602 => x"35", 3682 => x"36", 3762 => x"37", 3842 => x"38", 3922 => x"39",
3203 => x"30", 3283 => x"31", 3363 => x"32", 3443 => x"33", 3523 => x"34", 3603 => x"35", 3683 => x"36", 3763 => x"37", 3843 => x"38", 3923 => x"39",
3204 => x"30", 3284 => x"31", 3364 => x"32", 3444 => x"33", 3524 => x"34", 3604 => x"35", 3684 => x"36", 3764 => x"37", 3844 => x"38", 3924 => x"39",
79 => x"40",
159 => x"41",
3996 => x"47",
3997 => x"48",
3998 => x"49",
3999 => x"4A",
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
				ram(ram_offset) <= data_in;
			end if;
		end if;
	end process;

end architecture beh;
