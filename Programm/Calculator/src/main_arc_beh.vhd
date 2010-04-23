library ieee;
use ieee.std_logic_1164.all;
use work.textmode_vga_pkg.all;

architecture beh of main is
	constant DEFAULT_VGA_DATA : std_logic_vector(3 * COLOR_SIZE + CHAR_SIZE - 1 downto 0) := x"FFFFFF00";

  signal sense_old, sense_old_next : std_logic;
	signal vga_command_next : std_logic_vector(COMMAND_SIZE - 1 downto 0);
  signal vga_command_data_next : std_logic_vector(3 * COLOR_SIZE + CHAR_SIZE - 1 downto 0);

begin

  process(sys_clk, sys_res_n)
  begin
    if sys_res_n = '0' then
      sense_old <= RESET_VALUE;
    elsif rising_edge(sys_clk) then
      sense_old <= sense_old_next;
    	vga_command <= vga_command_next;
			vga_command_data <= vga_command_data_next;
		end if;
  end process;
  
  process(sense, sense_old, vga_free, new_ascii_in, ascii_sign_in)
  begin
    sense_old_next <= sense;
		vga_command_next <= COMMAND_NOP;
		vga_command_data_next <= DEFAULT_VGA_DATA;

		if new_ascii_in = '1' then
			vga_command_next <= COMMAND_SET_CHAR;
			vga_command_data_next(7 downto 0) <= ascii_sign_in;
		end if;

    if sense_old /= sense and sense = '0' and vga_free = '1' then	--sense = '0' ... weil button low aktiv
			vga_command_next <= COMMAND_SET_CHAR;
			vga_command_data_next(7 downto 0) <= x"61";
    end if;
  end process;
end architecture beh;
