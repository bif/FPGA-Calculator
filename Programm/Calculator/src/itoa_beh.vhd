library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

architecture beh of itoa is
	signal count		:	integer range 0 to 35 := 0;
	signal count_next	:	integer range 0 to 35 := 0;
	
	signal sign_next	:	std_logic := '0';
	signal enable		:	std_logic := '0';
	signal enable_next	:	std_logic := '0';
	signal start		:	std_logic := '0';
	signal start_next	:	std_logic := '0';
	signal scratch		:	std_logic_vector(71 downto 0) := "000000000000000000000000000000000000000000000000000000000000000000000000";
	signal scratch_next	:	std_logic_vector(71 downto 0) := "000000000000000000000000000000000000000000000000000000000000000000000000";

begin

	process(sys_clk, sys_res_n)
	begin

		if(sys_res_n = '0')
		then
			start <= '0';
			count <= 0;
			enable <= '0';
		elsif(sys_clk'event and sys_clk = '1')
		then
			start <= start_next;
			count <= count_next;
			enable <= enable_next;
			scratch <= scratch_next;
			sign <= sign_next;
		end if;
		
	end process;

	process(count, enable, start, start_decode, int_in, scratch, sign)
	variable scratch_tmp	: std_logic_vector(71 downto 0) := "000000000000000000000000000000000000000000000000000000000000000000000000";
	begin
		start_next <= start_decode;
		count_next <= count;
		scratch_tmp := scratch;	
		enable_next <= enable;
		sign_next <= sign;
		decode_ready <= '0';

--		out_0	<= "0000";
--		out_1	<= "0000";
--		out_2	<= "0000";
--		out_3	<= "0000";
--		out_4	<= "0000";
--		out_5	<= "0000";
--		out_6	<= "0000";
--		out_7	<= "0000";
--		out_8	<= "0000";
--		out_9	<= "0000";

		if(start /= start_decode and start_decode = '1')
		then
			enable_next <= '1';
			if(int_in < 0)
			then
				sign_next <= '1';       -- set sign - bit
			else
				sign_next <= '0';
			end if;

			--scratch_tmp(31 downto 0) := std_logic_vector(int_in);
			scratch_tmp(31 downto 0) := std_logic_vector(to_unsigned(int_in, 32));
			scratch_tmp(71 downto 32) := "0000000000000000000000000000000000000000";
			scratch_tmp(31) := '0';
			decode_ready <= '0';
			count_next <= 0;
		else
			if(count = 31)
			then
				enable_next <= '0';
				count_next <= 0;
				decode_ready <= '1';
			else
				decode_ready <= '0';
			end if;
		
			if(enable = '1')
			then
				count_next <= count + 1;
	
				--shift it
				scratch_tmp(71 downto 1) := scratch_tmp(70 downto 0);
		                scratch_tmp(0) := '0';
	
				if(count < 31)
				then
					if(scratch_tmp(35 downto 32) > "0100")
					then
						scratch_tmp(35 downto 32) := std_logic_vector(unsigned(scratch_tmp(35 downto 32)) + 3);
					end if;
					if(scratch_tmp(39 downto 36) > "0100")
					then
						scratch_tmp(39 downto 36) := std_logic_vector(unsigned(scratch_tmp(39 downto 36)) + 3);
					end if;
					if(scratch_tmp(43 downto 40) > "0100")
					then
						scratch_tmp(43 downto 40) := std_logic_vector(unsigned(scratch_tmp(43 downto 40)) + 3);
					end if;
					if(scratch_tmp(47 downto 44) > "0100")
					then
						scratch_tmp(47 downto 44) := std_logic_vector(unsigned(scratch_tmp(47 downto 44)) + 3);
					end if;
					if(scratch_tmp(51 downto 48) > "0100")
					then
						scratch_tmp(51 downto 48) := std_logic_vector(unsigned(scratch_tmp(51 downto 48)) + 3);
					end if;
					if(scratch_tmp(55 downto 52) > "0100")
					then
						scratch_tmp(55 downto 52) := std_logic_vector(unsigned(scratch_tmp(55 downto 52)) + 3);
					end if;
					if(scratch_tmp(59 downto 56) > "0100")
					then
						scratch_tmp(59 downto 56) := std_logic_vector(unsigned(scratch_tmp(59 downto 56)) + 3);
					end if;
					if(scratch_tmp(63 downto 60) > "0100")
					then
						scratch_tmp(63 downto 60) := std_logic_vector(unsigned(scratch_tmp(63 downto 60)) + 3);
					end if;
					if(scratch_tmp(67 downto 64) > "0100")
					then
						scratch_tmp(67 downto 64) := std_logic_vector(unsigned(scratch_tmp(67 downto 64)) + 3);
					end if;
					if(scratch_tmp(71 downto 68) > "0100")
					then
						scratch_tmp(71 downto 68) := std_logic_vector(unsigned(scratch_tmp(71 downto 68)) + 3);	
					end if;
				end if;

				-- copy nibbles to corresponding bytes	
				out_0(3 downto 0) <= unsigned(scratch_tmp(35 downto 32));
				out_1(3 downto 0) <= unsigned(scratch_tmp(39 downto 36));
				out_2(3 downto 0) <= unsigned(scratch_tmp(43 downto 40));
				out_3(3 downto 0) <= unsigned(scratch_tmp(47 downto 44));
				out_4(3 downto 0) <= unsigned(scratch_tmp(51 downto 48));
				out_5(3 downto 0) <= unsigned(scratch_tmp(55 downto 52));
				out_6(3 downto 0) <= unsigned(scratch_tmp(59 downto 56));
				out_7(3 downto 0) <= unsigned(scratch_tmp(63 downto 60));
				out_8(3 downto 0) <= unsigned(scratch_tmp(67 downto 64));
				out_9(3 downto 0) <= unsigned(scratch_tmp(71 downto 68));

			end if;
		end if;
		scratch_next <= scratch_tmp;
	end process;

end architecture beh;
