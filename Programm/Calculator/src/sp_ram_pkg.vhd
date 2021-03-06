library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;


package sp_ram_pkg is
	component sp_ram is
  generic
  (
     ADDR_WIDTH : integer range 1 to integer'high;
     DATA_WIDTH : integer range 1 to integer'high
  );
  port
  (
			clk      : in std_logic;
			address_out : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
			data_out : out std_logic_vector(DATA_WIDTH - 1 downto 0);
			address_out_1 : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
			data_out_1 : out std_logic_vector(DATA_WIDTH - 1 downto 0);
			address_wr : in std_logic_vector(ADDR_WIDTH - 1 downto 0); 
			wr       : in std_logic;
			data_wr : in std_logic_vector(DATA_WIDTH - 1 downto 0)
  );
	end component sp_ram;
end package sp_ram_pkg;

