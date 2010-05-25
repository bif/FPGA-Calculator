library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;


architecture beh of sp_ram is
  subtype RAM_ENTRY_TYPE is std_logic_vector(DATA_WIDTH - 1 downto 0);
  type RAM_TYPE is array (0 to (2 ** ADDR_WIDTH) - 1) of RAM_ENTRY_TYPE;
  signal ram : RAM_TYPE := (others => x"00");
begin
  process(clk)
  begin
    if rising_edge(clk) then
      data_out <= ram(to_integer(unsigned(address_out)));
      data_out_1 <= ram(to_integer(unsigned(address_out_1)));
			if wr = '1' then
        ram(to_integer(unsigned(address_wr))) <= data_wr;
      end if;
    end if;
  end process;
end architecture beh;

