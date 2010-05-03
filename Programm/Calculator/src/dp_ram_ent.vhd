library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dp_ram is
  generic
  (
		ADDR_WIDTH : integer range 1 to integer'high;
		DATA_WIDTH : integer range 1 to integer'high
  );
  port
  (
		clk       : in std_logic;
		address1 : in std_logic_vector(ADDR_WIDTH -   1 downto 0);
		data_out1 : out std_logic_vector(DATA_WIDTH - 1 downto 0);
		wr1       : in std_logic;
		data_in1 : in std_logic_vector(DATA_WIDTH -   1 downto 0);
		address2 : in std_logic_vector(ADDR_WIDTH -   1 downto 0);
		data_out2 : out std_logic_vector(DATA_WIDTH - 1 downto 0)
	);
end entity dp_ram;


