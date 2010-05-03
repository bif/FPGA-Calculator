library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;


architecture beh of dp_ram is
  subtype RAM_ENTRY_TYPE is std_logic_vector(DATA_WIDTH - 1 downto 0);
  type RAM_TYPE is array (0 to (2 ** ADDR_WIDTH) – 1) of RAM_ENTRY_TYPE;
  signal ram : RAM_TYPE := (others => x”00”);
begin
  process(clk)
  begin
    if rising_edge(clk) then
      data_out1 <= ram(to_integer(unsigned(address1)));
      data_out2 <= ram(to_integer(unsigned(address2)));
      if wr1 = ‘1’ then
        ram(to_integer(unsigned(address1))) <= data_in1;
      end if;
    end if;
  end process;
end architecture beh;

