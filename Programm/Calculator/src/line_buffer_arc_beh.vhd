brary ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

architecture beh of line_buffer is
  subtype RAM_ENTRY_TYPE is std_logic_vector(DATA_WIDTH - 1 downto 0);
  type RAM_TYPE is array (0 to (2 ** ADDR_WIDTH) – 1) of RAM_ENTRY_TYPE;
  signal ram : RAM_TYPE := (others => x”00”);
	type LINEBUFFER_FSM_STATE_TYPE is
    (CHECK_ASCII, ENTER, BKSP, SAVE_VALE);
  signal lb_fsm_state, lb_fsm_state_next : LINEBUFFER_FSM_STATE_TYPE;

begin

next_state : process(lb_fsm_state)
  begin
    lb_fsm_state_next <= lb_h_fsm_state;

    case sc_h_fsm_state is
			when CHECK_ASCII =>
				if new_ascii_in = '1' then
				end if;
 	    when ENTER =>
				if data = x"F0" and new_data_sig = '1' then
					sc_h_fsm_state_next <= WAIT_NEXT_DATA;
				end if;
			when BKSP =>
				if data /= x"F0" and new_data_sig = '1' then
					sc_h_fsm_state_next <= CONVERT;
				end if;
			when SAVE_VALUE =>
 				if convert_ready = '1' then
					sc_h_fsm_state_next <= READY;
				end if; 	
			end case;
  end process next_state;

-- State Machine:
-- 													1. check ascii
-- 			|																					|						|
--		Enter																		Backspace			others
--start calc/STOP SCANCODE HANDLER					3 states del		save value/ display value
-- go back to state 1


	memory_io : process(sys_clk)
  begin
    if rising_edge(sys_clk) then
      data_out <= ram(to_integer(unsigned(address)));
      if wr = ‘1’ then
        ram(to_integer(unsigned(address))) <= data_in;
      end if;
    end if;
  end process memory_io;

	sync : process(sys_clk, sys_res_n)
  begin
    if sys_res_n = '0' then
      sc_h_fsm_state <= CHECK_ASCII;
    elsif rising_edge(sys_clk) then
		
		end if;
	end process sync;



end architecture beh;

