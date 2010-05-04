library ieee;
use ieee.std_logic_1164.all;


architecture beh of scancode_handler is
  type SC_H_FSM_STATE_TYPE is
    (READY, E_0, CONVERT, WAIT_NEXT_DATA);
  signal sc_h_fsm_state, sc_h_fsm_state_next : SC_H_FSM_STATE_TYPE;
	signal convert_ready, convert_ready_next, new_ascii_next, ambiguous_next, ambiguous : std_logic := '0';
	signal ascii_sign_next, last_ascii_sign : std_logic_vector(7 downto 0);
	signal new_data_sig : std_logic := '1';

	function my_rising_edge(value : in std_logic) return std_logic is
		begin
			if value = '1' then
				return '1';
			else
				return '0';
			end if;
	end function;  

begin

  next_state : process(sc_h_fsm_state, data, new_data_sig, convert_ready, ambiguous)
  begin
    sc_h_fsm_state_next <= sc_h_fsm_state;
		ambiguous_next <= ambiguous;

    case sc_h_fsm_state is
			when READY =>
				if data = x"E0" and new_data_sig = '1' then
					sc_h_fsm_state_next <= E_0;
					ambiguous_next <= '1';
				elsif data = x"F0" and new_data_sig = '1' then
					sc_h_fsm_state_next <= WAIT_NEXT_DATA;
					ambiguous_next <= '0';
				end if;
 	    when E_0 =>
				if data = x"F0" and new_data_sig = '1' then
					sc_h_fsm_state_next <= WAIT_NEXT_DATA;
				end if;
			when WAIT_NEXT_DATA =>
				if data /= x"F0" and new_data_sig = '1' then
					sc_h_fsm_state_next <= CONVERT;
				end if;
			when CONVERT =>
 				if convert_ready = '1' then
					sc_h_fsm_state_next <= READY;
				end if; 	
			end case;
  end process next_state;

  output : process(sc_h_fsm_state, data, last_ascii_sign, ambiguous)
  begin
-- FIXME: data in sensitivity list ... kann es passieren dass sich data ändert während man noch im CONVERT state ist?

		ascii_sign_next <= last_ascii_sign;
		new_ascii_next <= '0';	
	
		if sc_h_fsm_state = CONVERT then
			case data is
				when x"4A" => 
					if ambiguous = '1' then
						ascii_sign_next <= x"2F"; 
						new_ascii_next <= '1';
					end if;
				-- ENTER: hex ascii 0A ... next line, 0D ... goto x=0
				when x"5A" =>
					ascii_sign_next <= x"03"; 
					new_ascii_next <= '1';
				when x"7C" => 
					if ambiguous = '0' then
						ascii_sign_next <= x"2A"; 
						new_ascii_next <= '1';
					end if;
				when x"7B" =>
					ascii_sign_next <= x"2D"; 
					new_ascii_next <= '1';
				when x"79" =>
					ascii_sign_next <= x"2B"; 
					new_ascii_next <= '1';
				when x"29" =>
					ascii_sign_next <= x"20"; 
					new_ascii_next <= '1';
				-- BKSP
				when x"66" =>
					ascii_sign_next <= x"08"; 
					new_ascii_next <= '1';
				when x"70" => 
					if ambiguous = '0' then
						ascii_sign_next <= x"30"; 
						new_ascii_next <= '1';
					end if;
				when x"69" => 
					if ambiguous = '0' then
						ascii_sign_next <= x"31"; 
						new_ascii_next <= '1';
					end if;
				when x"72" => 
					if ambiguous = '0' then
						ascii_sign_next <= x"32"; 
						new_ascii_next <= '1';
					end if;
				when x"7A" => 
					if ambiguous = '0' then
						ascii_sign_next <= x"33"; 
						new_ascii_next <= '1';
					end if;
				when x"6B" => 
					if ambiguous = '0' then
						ascii_sign_next <= x"34"; 
						new_ascii_next <= '1';
					end if;
				when x"73" =>
					ascii_sign_next <= x"35"; 
					new_ascii_next <= '1';
				when x"74" => 
					if ambiguous = '0' then
						ascii_sign_next <= x"36"; 
						new_ascii_next <= '1';
					end if;
				when x"6C" => 
					if ambiguous = '0' then
						ascii_sign_next <= x"37"; 
						new_ascii_next <= '1';
					end if;
				when x"75" => 
					if ambiguous = '0' then
						ascii_sign_next <= x"38"; 
						new_ascii_next <= '1';
					end if;
				when x"7D" => 
					if ambiguous = '0' then
						ascii_sign_next <= x"39"; 
						new_ascii_next <= '1';
					end if;
				when others => 
					new_ascii_next <= '0';
			end case;
			convert_ready_next <= '1';
		else
			convert_ready_next <= '0';
		end if;
   end process output;

  assert RESET_VALUE = '0' or RESET_VALUE = '1' report
    "RESET_VALUE may only be 0 or 1!" severity failure;

  sync : process(sys_clk, sys_res_n)
  begin
    if sys_res_n = '0' then
      sc_h_fsm_state <= READY;
    elsif rising_edge(sys_clk) then
			new_data_sig <= my_rising_edge(new_data);
      sc_h_fsm_state <= sc_h_fsm_state_next;
			convert_ready <= convert_ready_next;
			new_ascii <= new_ascii_next;
			ascii_sign <= ascii_sign_next; 
			last_ascii_sign <= ascii_sign_next;
			ambiguous <= ambiguous_next;
		end if;
  end process sync;
end architecture beh;
