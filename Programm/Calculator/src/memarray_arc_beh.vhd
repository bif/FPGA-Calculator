library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

architecture beh of memarray is
	subtype RAM_CELL is integer range 0 to 255;	-- 8 bit for every ram cell(7 would be enough, but its easier this way(casting...))
	type MEM_ARRAY is array (LINES - 1 downto 0, LINE_LENGTH - 1 downto 0) of RAM_CELL;
	signal ram : MEM_ARRAY;

begin
	process(sys_clk, sys_res_n)
	begin
		if(sys_res_n = '0')
		then
			data_out <= 0;
			ram(0,0) <= 8;		-- testweise belegung des ringbuffers
			ram(1,0) <= 9;
			ram(2,1) <= 1;
			ram(3,2) <= 2;
			ram(4,3) <= 3;
			ram(5,4) <= 4;
			ram(6,5) <= 5;
			ram(7,6) <= 6;
			ram(8,7) <= 7;
			ram(49,7) <= 9;
		elsif(rising_edge(sys_clk))
		then
			data_out <= ram(ram_bank, ram_offset);
			if wr = '1' then
				ram(ram_bank, ram_offset) <= data_in;
			end if;
		end if;
	end process;
end architecture beh;
