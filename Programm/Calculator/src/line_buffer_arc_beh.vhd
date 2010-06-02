library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.textmode_vga_pkg.all;

architecture beh of line_buffer is
	constant DEFAULT_VGA_DATA : std_logic_vector(3 * COLOR_SIZE + CHAR_SIZE - 1 downto 0) := x"00000000";


	type LINEBUFFER_FSM_STATE_TYPE is
    (DISABLE, CLEAR_SCREEN, CLEAR_BUFFER, WRITE_RESULT, CHECK_ASCII, ENTER_1, ENTER_2, BKSP_1, BKSP_2, BKSP_3, SAVE_VALUE, WAIT_STATE);
	signal lb_fsm_state, lb_fsm_state_next, save_next_state, save_next_state_next : LINEBUFFER_FSM_STATE_TYPE;
	signal vga_command_next : std_logic_vector(COMMAND_SIZE - 1 downto 0);
	signal vga_command_data_next : std_logic_vector(3 * COLOR_SIZE + CHAR_SIZE - 1 downto 0);
	signal count, count_next : std_logic_vector(ADDR_WIDTH - 1 downto 0);
	signal reset_count, reset_count_next : std_logic_vector(ADDR_WIDTH - 1 downto 0);
	signal vga_free_sig, once, once_next : std_logic := '0';
	signal lb_addr_next : std_logic_vector(ADDR_WIDTH - 1 downto 0);
	signal lb_data_next : std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal enable_old, enable_old_next, wr_enable_next, start_calc_next, enter_write_result, enter_write_result_next : std_logic;
	signal bcd_buf, bcd_buf_next : std_logic_vector(39 downto 0);
	signal wait_write, wait_write_next : std_logic;

begin

	next_state : process(lb_fsm_state, new_ascii_in, ascii_sign_in, vga_free, save_next_state, count, reset_count, enable, enable_old,  enter_write_result)
  begin
    
		lb_fsm_state_next <= lb_fsm_state;
		save_next_state_next <= save_next_state;
		enable_old_next <= enable;


    case lb_fsm_state is
		
			when CLEAR_SCREEN =>
				if reset_count <= x"78" then 	-- 0x78 = 2*60 
					if vga_free = '0' then
						lb_fsm_state_next <= WAIT_STATE;
						save_next_state_next <= CLEAR_SCREEN; 
					end if;
				else
					lb_fsm_state_next <= CHECK_ASCII;
				end if;

			when CHECK_ASCII =>

				if new_ascii_in = '1' then
					case ascii_sign_in is
						-- ENTER
						when x"03" => 
							lb_fsm_state_next <= WAIT_STATE;
							save_next_state_next <= ENTER_1;							
						-- BKSP
						when x"08" =>
							if count /= x"00" then 
								lb_fsm_state_next <= WAIT_STATE;
								save_next_state_next <= BKSP_1;							
							end if;
						-- other value
						when others =>	
							if count < x"46" then 
								lb_fsm_state_next <= WAIT_STATE;
								save_next_state_next <= SAVE_VALUE;							
							end if;
					end case;
				end if;

			when DISABLE =>
				if enable_old /= enable and enable = '1' then 
					lb_fsm_state_next <= WRITE_RESULT;
				end if;

			when WRITE_RESULT =>	
				if vga_free = '0' and count < x"0A" then 
					lb_fsm_state_next <= WAIT_STATE;
					save_next_state_next <= WRITE_RESULT;
				elsif vga_free = '0' then
					lb_fsm_state_next <= WAIT_STATE;
					save_next_state_next <= ENTER_1;
				end if;

			when CLEAR_BUFFER =>

				if count >= x"46" then
					lb_fsm_state_next <= CHECK_ASCII;
				end if;

	    when ENTER_1 => 
			if vga_free = '0' then
					lb_fsm_state_next <= WAIT_STATE;
					save_next_state_next <= ENTER_2; 
				end if;

			when ENTER_2 =>
				if vga_free = '0' then
					if enter_write_result = '1' then
						lb_fsm_state_next <= WAIT_STATE;
						save_next_state_next <= CLEAR_BUFFER; 
					else
						lb_fsm_state_next <= WAIT_STATE;
						save_next_state_next <= DISABLE; 
					end if;
				end if;

			when BKSP_1 => 
				if vga_free = '0' then
					lb_fsm_state_next <= WAIT_STATE;
					save_next_state_next <= BKSP_2; 
				end if;

			when BKSP_2 =>  
				if vga_free = '0' then
					lb_fsm_state_next <= WAIT_STATE;
					save_next_state_next <= BKSP_3;  
				end if;

			when BKSP_3 =>  
				if vga_free = '0' then
					lb_fsm_state_next <= CHECK_ASCII;	
				end if;		

			when SAVE_VALUE => 
				if vga_free = '0' then
					lb_fsm_state_next <= CHECK_ASCII;	
				end if;	

			when WAIT_STATE =>
				if vga_free = '1' then
					lb_fsm_state_next <= save_next_state;
				end if;
		end case;
  end process next_state;


	output : process(lb_fsm_state, count, reset_count, ascii_sign_in, vga_free, once, bcd_result, bcd_buf, enter_write_result, wait_write)
	
	begin
		start_calc_next <= '0';
		vga_command_next <= COMMAND_NOP;
		vga_command_data_next <= DEFAULT_VGA_DATA;
		count_next <= count;
		reset_count_next <= reset_count;
		once_next <= once;
		wr_enable_next <= '0';
		lb_data_next <= ascii_sign_in;--x"00";
		lb_addr_next <= count;
		enter_write_result_next <= enter_write_result;
		wait_write_next <= wait_write;
		
		bcd_buf_next <= bcd_buf;

		case lb_fsm_state is

			when CLEAR_SCREEN =>
				if vga_free = '1' then
						if reset_count <= x"78" then 	 	-- 0x78 = 2*60 	
							--init line buffer memmory
							if reset_count < x"46" then
								wr_enable_next <= '1';
								lb_data_next <= x"20";
								lb_addr_next <= reset_count;
							else
								lb_addr_next <= (others => '0');
								wr_enable_next <= '0';
							end if;
							vga_command_next <= COMMAND_SET_CHAR;
							vga_command_data_next(7 downto 0) <= x"0A"; 
							reset_count_next <= std_logic_vector(unsigned(reset_count) + 1);
						else	
							vga_command_next <= COMMAND_SET_CURSOR_LINE;
						 	vga_command_data_next(7 downto 0) <= x"00";
							reset_count_next <= std_logic_vector(unsigned(reset_count) + 1);
						end if;
				end if;

			when CHECK_ASCII =>
				once_next <= '0';
				enter_write_result_next <= '0';

			when DISABLE =>
				bcd_buf_next <= bcd_result;
				wait_write_next <= '0';
				if once = '0' then
					start_calc_next <= '1';
					once_next <= '1';
				else
					start_calc_next <= '0';
				end if;
				count_next <= (others => '0');
				enter_write_result_next <= '1';

			when WRITE_RESULT =>
				once_next <= '0';
				if wait_write = '0' then
					if vga_free = '1' and count < x"0A" then
--TODO: führende Nullen enfernen / vorzeichen setzen
						vga_command_data_next(31 downto 8) <= x"FFFFFF";
						vga_command_next <= COMMAND_SET_CHAR;
						-- high nibble is always hex 3 => high nibble of offset hex 30
						vga_command_data_next(7 downto 4) <= x"3";
						-- low nibble => bcd value
						vga_command_data_next(3 downto 0) <= bcd_buf(3 downto 0);
						bcd_buf_next <= std_logic_vector(shift_right(unsigned(bcd_buf), 4));
						count_next <= std_logic_vector(unsigned(count) + 1);
					end if;
					wait_write_next <= '1';
				else
 					wait_write_next <= '0';
				end if;
			when CLEAR_BUFFER =>
				if count >= x"46" then
	--				bcd_buf_next <= (others => '0');
					count_next <= (others => '0');
					lb_addr_next <= (others => '0');
				else
					if once = '0' then
						count_next <= (others => '0');		
						lb_addr_next <= (others => '0');
						once_next <= '1';
					else
						lb_addr_next <= count;
						count_next <= std_logic_vector(unsigned(count) + 1);
					end if;
					wr_enable_next <= '1';
					lb_data_next <= x"20";
				end if;

			when ENTER_1 =>
				if vga_free = '1' then
					vga_command_next <= COMMAND_SET_CHAR;
					vga_command_data_next(7 downto 0) <= x"0D";
				end if;

			when ENTER_2 =>
				if vga_free = '1' then
					vga_command_next <= COMMAND_SET_CHAR;
					vga_command_data_next(7 downto 0) <= x"0A"; 
					count_next <= (others => '0');
					lb_addr_next <= (others => '0'); 
--					if enter_write_result = '1' then
--					else


--						start_calc_next <= '1';
--					end if;
					once_next <= '0';
				end if;

			when BKSP_1 =>
				if vga_free = '1' then
					vga_command_next <= COMMAND_SET_CURSOR_COLUMN;
					vga_command_data_next(7 downto 0) <= std_logic_vector(unsigned(count) - 1);
				end if;

			when BKSP_2 =>
				if vga_free = '1' then
					vga_command_next <= COMMAND_SET_CHAR;
					vga_command_data_next(31 downto 0) <= x"00000060";
					--Leerzeichen in Linebuffer schreiben
					if once = '0' then	
						wr_enable_next <= '1';
						lb_data_next <= x"20";
						lb_addr_next <= count;
						once_next <= '1';	
					else					
						wr_enable_next <= '0';
						once_next <= '0';	
					end if;
				end if;

			when BKSP_3 =>
				if vga_free = '1' then
					vga_command_next <= COMMAND_SET_CURSOR_COLUMN;
					vga_command_data_next(7 downto 0) <= std_logic_vector(unsigned(count) - 1);	
					if once = '0' then	
						count_next <= std_logic_vector(unsigned(count) - 1);
						once_next <= '1';
					else
						once_next <= '0';
					end if;
				end if;

			when SAVE_VALUE =>
				if vga_free = '1' then
					vga_command_next <= COMMAND_SET_CHAR;
					vga_command_data_next(31 downto 8) <= x"FFFFFF";
					vga_command_data_next(7 downto 0) <= ascii_sign_in;
					if once = '0' then	
						wr_enable_next <= '1';
						lb_data_next <= ascii_sign_in;
						lb_addr_next <= count;
						count_next <= std_logic_vector(unsigned(count) + 1);
						once_next <= '1';
					else					
						wr_enable_next <= '0';
						once_next <= '0';
					end if;
				end if;

			when WAIT_STATE =>
				if enter_write_result= '1' then
					once_next <= '0';
				end if;

			when others =>
				null;
		end case;
	end process output;


	sync : process(sys_clk, sys_res_n)
  begin

    if sys_res_n = '0' then
      lb_fsm_state <= CLEAR_SCREEN;
			count <= (others => '0');	-- x"00"
			reset_count <= (others => '0');	-- x"00"
			enable_old <= '0';
			wait_write <= '0';	
			bcd_buf <= x"0000000000";
	
		elsif rising_edge(sys_clk) then
			wait_write <= wait_write_next;
			lb_fsm_state <= lb_fsm_state_next;
			count <= count_next;
			reset_count <= reset_count_next;
			save_next_state <= save_next_state_next;
			vga_command <= vga_command_next;
			vga_command_data <= vga_command_data_next;
			once <= once_next;
			wr_enable <= wr_enable_next;
			enable_old <= enable_old_next;
			lb_data <= lb_data_next;
			lb_addr <= lb_addr_next;
			start_calc <= start_calc_next;
			enter_write_result <= enter_write_result_next;
			bcd_buf <= bcd_buf_next;
		end if;
	end process sync;

end architecture beh;

