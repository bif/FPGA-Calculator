library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

architecture beh of memarray is
	subtype RAM_CELL is std_logic_vector(7 downto 0);					-- 8 bit for every ram cell
	--type MEM_ARRAY is array (0 to (2 ** 12) - 1) of RAM_CELL;	-- 2d - array: 80x50 consisiting of RAM_CELL
	type MEM_ARRAY is array ((LINES - 1) * (LINE_LENGTH - 1) downto 0) of RAM_CELL;	-- 2d - array: 80x50 consisiting of RAM_CELL
	signal ram : MEM_ARRAY := (others => x"00");

	signal count, count_next		:	integer range 0 to 4100;
	signal linecount, linecount_next	:	integer range 0 to 100;
	signal delay, delay_next		:	integer range 0 to 100;
	signal tmp, tmp_next			:	integer range 48 to 57;
	signal enable, enable_next		:	std_logic := '0';

begin
	process(sys_clk, sys_res_n)
	begin
		if(sys_res_n = '0')
		then
			data_out <= x"00";
			count <= 0;
			enable <= '0';
			delay <= 0;
			tmp <= 48;
			linecount <= 0;
		elsif(rising_edge(sys_clk))
		then
			linecount <= linecount_next;
			tmp <= tmp_next;
			enable <= enable_next;
			count <= count_next;
			data_out <= ram(ram_offset);
			delay <= delay_next;
	
			if wr = '1' then
				ram(ram_offset) <= data_in;
			elsif(enable = '1')
			then
				ram(count) <= x"30";
			end if;
		end if;
	end process;

	process(delay, count, enable, tmp, linecount)
	begin
		linecount_next <= linecount;
		tmp_next <= tmp;
		delay_next <= delay;
		enable_next <= enable;
		count_next <= count;

		if(delay < 50)
		then
			delay_next <= delay + 1;
		else
			enable_next <= '1';
		end if;
				
		if(tmp > 57)
		then
			tmp_next <= 48;
		end if;

		if(enable = '1')
		then
			if(count < 4095)
			then
				count_next <= count + 1;
				tmp_next <= tmp + 1;
			else
				enable_next <= '0';
			end if;
		end if;

	end process;
end architecture beh;
