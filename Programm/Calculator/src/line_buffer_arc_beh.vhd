library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.textmode_vga_pkg.all;

architecture beh of line_buffer is
	constant DEFAULT_VGA_DATA : std_logic_vector(3 * COLOR_SIZE + CHAR_SIZE - 1 downto 0) := x"00000000";


--  subtype RAM_ENTRY_TYPE is std_logic_vector(DATA_WIDTH - 1 downto 0);
--  type RAM_TYPE is array (0 to (2 ** ADDR_WIDTH) – 1) of RAM_ENTRY_TYPE;
--  signal ram : RAM_TYPE := (others => x”00”);
	type LINEBUFFER_FSM_STATE_TYPE is
    (CHECK_ASCII, ENTER_1, ENTER_2, BKSP_1, BKSP_2, BKSP_3, SAVE_VALUE, WAIT_PREE_STATE,  WAIT_STATE);
  signal lb_fsm_state, lb_fsm_state_next, wait_next_state : LINEBUFFER_FSM_STATE_TYPE;
--	signal ready, ready_next  : std_logic := '0';	
	signal vga_command_next : std_logic_vector(COMMAND_SIZE - 1 downto 0);
  signal vga_command_data_next : std_logic_vector(3 * COLOR_SIZE + CHAR_SIZE - 1 downto 0);
	signal col_cnt, col_cnt_next  : integer;
	signal new_ascii_in_sig, vga_free_sig : std_logic := '0';



	function my_rising_edge(value : in std_logic) return std_logic is
		begin
			if value = '1' then
				return '1';
			else
				return '0';
			end if;
	end function;  

begin

	next_state : process(lb_fsm_state, new_ascii_in_sig, ascii_sign_in, vga_free_sig, wait_next_state)
  begin
    
		lb_fsm_state_next <= lb_fsm_state;
		wait_next_state <= WAIT_STATE;

    case lb_fsm_state is
		
			when CHECK_ASCII =>
				if new_ascii_in_sig = '1' then
					case ascii_sign_in is
						-- ENTER
						when x"03" =>
							lb_fsm_state_next <= ENTER_1;
						-- BKSP
						when x"08" =>
							lb_fsm_state_next <= BKSP_1;
						-- other value
						when others =>
							lb_fsm_state_next <= SAVE_VALUE;	
					end case;
				end if;
 	    when ENTER_1 => 
				if vga_free_sig = '1' then
					lb_fsm_state_next <= WAIT_PREE_STATE;
					wait_next_state <= ENTER_2;
				end if;
			when ENTER_2 => 
				if vga_free_sig = '1' then
					lb_fsm_state_next <= CHECK_ASCII;
				end if;
			when BKSP_1 => 
				if vga_free_sig = '1' then
					lb_fsm_state_next <= WAIT_PREE_STATE;
					wait_next_state <= BKSP_2; 
				end if;
			when BKSP_2 =>  
				if vga_free_sig = '1' then
					lb_fsm_state_next <= WAIT_PREE_STATE;
					wait_next_state <= BKSP_3; 
				end if;
			when BKSP_3 =>  
				if vga_free_sig = '1' then
					lb_fsm_state_next <= CHECK_ASCII; 
				end if;		
			when SAVE_VALUE => 
				if vga_free_sig = '1' then
					lb_fsm_state_next <= CHECK_ASCII; 
				end if;	
			when WAIT_PREE_STATE =>
				if vga_free_sig = '0' then
					lb_fsm_state_next <= WAIT_STATE;
				end if;
			when WAIT_STATE =>
				if vga_free_sig = '1' then
					lb_fsm_state_next <= wait_next_state;
				end if;
		end case;
  end process next_state;


	output : process(lb_fsm_state, col_cnt, ascii_sign_in)
	begin
	--	start_calc <= '0';
		vga_command_next <= COMMAND_NOP;
		vga_command_data_next <= DEFAULT_VGA_DATA;
		col_cnt_next <= col_cnt;

		case lb_fsm_state is
			when ENTER_1 =>
				vga_command_next <= COMMAND_SET_CHAR;
				vga_command_data_next(7 downto 0) <= x"0D";
			when ENTER_2 =>
				vga_command_next <= COMMAND_SET_CHAR;
				vga_command_data_next(7 downto 0) <= x"0A"; 
				col_cnt_next <= 0; 
--				start_calc <= '1';
			when BKSP_1 =>
				if col_cnt /= 0 then
					col_cnt_next <= (col_cnt - 1);
					vga_command_next <= COMMAND_SET_CURSOR_COLUMN;
					vga_command_data_next(7 downto 0) <= std_logic_vector(to_unsigned((col_cnt - 1), 8));
				end if;
			when BKSP_2 =>
				if col_cnt /= 0 then
					vga_command_next <= COMMAND_SET_CHAR;
					vga_command_data_next(31 downto 0) <= x"00000060";
				end if;
			when BKSP_3 =>
				if col_cnt /= 0 then
					vga_command_next <= COMMAND_SET_CURSOR_COLUMN;
					vga_command_data_next(7 downto 0) <= std_logic_vector(to_unsigned((col_cnt - 1), 8));
				end if;
			when SAVE_VALUE =>
				col_cnt_next <= (col_cnt + 1);
				vga_command_next <= COMMAND_SET_CHAR;
				vga_command_data_next(31 downto 8) <= x"FFFFFF";
				vga_command_data_next(7 downto 0) <= ascii_sign_in;
			when others =>
				null;
		end case;
	end process output;


--	memory_io : process(sys_clk)
--	begin
--	  if rising_edge(sys_clk) then
--      data_out <= ram(to_integer(unsigned(address)));
--      if wr = ‘1’ then
--        ram(to_integer(unsigned(address))) <= data_in;
--      end if;
--    end if;
--  end process memory_io;

	sync : process(sys_clk, sys_res_n)
  begin
    if sys_res_n = '0' then
      lb_fsm_state <= CHECK_ASCII;
			col_cnt <= 0;
    elsif rising_edge(sys_clk) then
			vga_free_sig <= my_rising_edge(vga_free);
			new_ascii_in_sig <= my_rising_edge(new_ascii_in);
			lb_fsm_state <= lb_fsm_state_next;
			col_cnt <= col_cnt_next;
			vga_command <= vga_command_next;
			vga_command_data <= vga_command_data_next;
		end if;
	end process sync;


end architecture beh;

