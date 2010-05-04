library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.textmode_vga_pkg.all;
use ieee.std_logic_unsigned.all;

architecture beh of line_buffer is
	constant DEFAULT_VGA_DATA : std_logic_vector(3 * COLOR_SIZE + CHAR_SIZE - 1 downto 0) := x"00000000";


	type LINEBUFFER_FSM_STATE_TYPE is
    (CLEAR_SCREEN, CHECK_ASCII, ENTER_1, ENTER_2, BKSP_1, BKSP_2, BKSP_3, SAVE_VALUE, WAIT_STATE);
  signal lb_fsm_state, lb_fsm_state_next, save_next_state, save_next_state_next : LINEBUFFER_FSM_STATE_TYPE;
	signal vga_command_next : std_logic_vector(COMMAND_SIZE - 1 downto 0);
  signal vga_command_data_next : std_logic_vector(3 * COLOR_SIZE + CHAR_SIZE - 1 downto 0);
	signal count, count_next  : std_logic_vector(ADDR_WIDTH - 1 downto 0);
	signal vga_free_sig, once, once_next : std_logic := '0';
	signal lb_addr_next : std_logic_vector(ADDR_WIDTH - 1 downto 0);
	signal lb_data_next : std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal wr_enable_next : std_logic;



begin

	next_state : process(lb_fsm_state, new_ascii_in, ascii_sign_in, vga_free, save_next_state, count)
  begin
    
		lb_fsm_state_next <= lb_fsm_state;
		save_next_state_next <= save_next_state;

    case lb_fsm_state is
		
			when CLEAR_SCREEN =>
				if count <= x"3C" then 	-- 3C = 2*30 ... doppelt so weit zählen da output prozess imm 2 mal aufgerufen wird
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
							lb_fsm_state_next <= ENTER_1;
						-- BKSP
						when x"08" =>
							if count /= x"00" then
								lb_fsm_state_next <= BKSP_1;
							end if;
						-- other value
						when others =>	
							if count < x"46" then
								lb_fsm_state_next <= SAVE_VALUE;	
							end if;
					end case;
				end if;
 	    when ENTER_1 => 
				if vga_free = '0' then
					lb_fsm_state_next <= WAIT_STATE;
					save_next_state_next <= ENTER_2;
				end if;
			when ENTER_2 =>
--				led_sig <= '0'; 
				if vga_free = '0' then
					lb_fsm_state_next <= CHECK_ASCII;
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


	output : process(lb_fsm_state, count, ascii_sign_in, vga_free, once)
	
	begin
	--	start_calc <= '0';
		vga_command_next <= COMMAND_NOP;
		vga_command_data_next <= DEFAULT_VGA_DATA;
		count_next <= count;
		once_next <= once;
		wr_enable_next <= '0';
		lb_data_next <= x"00";
		lb_addr_next <= count;


		case lb_fsm_state is
			when CLEAR_SCREEN =>
				if vga_free = '1' then
					if count = x"00" then
						vga_command_next <= COMMAND_SET_CURSOR_LINE;
					 	vga_command_data_next(7 downto 0) <= x"1E";
						count_next <= (count + '1');
					else
						if count <= x"3C" then 	 	-- 3C = 2*30 ... doppelt so weit zählen da output prozess imm 2 mal aufgerufen wird
--							if count <= x"" then
--								wr_enable_next <= '1';
--							lb_data_next <= x"00";
--								lb_addr_next <= srl count 1;
--							end if;
							vga_command_next <= COMMAND_SET_CHAR;
							vga_command_data_next(7 downto 0) <= x"0A";  
							count_next <= (count + '1');
						else
							vga_command_next <= COMMAND_SET_CURSOR_LINE;
						 	vga_command_data_next(7 downto 0) <= x"00";
							count_next <= (others => '0');
						end if;
					end if;
				end if;
			when CHECK_ASCII =>
				once_next <= '0';	
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
--				start_calc <= '1';
				end if;
			when BKSP_1 =>
				if vga_free = '1' then
					vga_command_next <= COMMAND_SET_CURSOR_COLUMN;
					vga_command_data_next(6 downto 0) <= (count - '1');
				end if;
			when BKSP_2 =>
				if vga_free = '1' then
					vga_command_next <= COMMAND_SET_CHAR;
					vga_command_data_next(31 downto 0) <= x"00000060";
				end if;
			when BKSP_3 =>
				if vga_free = '1' then
					vga_command_next <= COMMAND_SET_CURSOR_COLUMN;
					vga_command_data_next(6 downto 0) <= (count - '1');	
					if once = '0' then	
						count_next <= (count - '1');
					end if;
					once_next <= '1';
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
						count_next <= (count + '1');
					else					
						wr_enable_next <= '0';
					end if;
					once_next <= '1';
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
    elsif rising_edge(sys_clk) then
			lb_fsm_state <= lb_fsm_state_next;
			count <= count_next;
			save_next_state <= save_next_state_next;
			vga_command <= vga_command_next;
			vga_command_data <= vga_command_data_next;
			once <= once_next;
			wr_enable <= wr_enable_next;
			lb_data <= lb_data_next;
			lb_addr <= lb_addr_next;
		end if;
	end process sync;

end architecture beh;

