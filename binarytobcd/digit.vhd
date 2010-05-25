--
-- Copyright (C) Doulos Ltd 2001
--
library IEEE;
use IEEE.std_logic_1164.all;

entity Digit is
  port (Clock : in std_logic;
        Reset : in std_logic;      -- clear registers asynchronously
        Init : in std_logic;       -- initialise the BCD conversion
        ModIn : in std_logic;      -- modulus in from less significant digit
        ModOut : out std_logic;    -- modulus out to more significant digit
        Q      : out std_logic_vector(3 downto 0) -- BCD output
       );
end;

architecture RTL of Digit is
  signal Q_int : std_logic_vector(3 downto 0);
  signal NextQ_int : std_logic_vector(2 downto 0);
  signal NextModOut : std_logic;
begin

  -- Calculate the shift in the BCD register. Numbers between
  -- 0 and 4 inclusive are doubled, by shifting by 1.
  -- Numbers from  5 to 9 inclusive get mapped to 10, 12, 14,
  -- 16, 18. This gives an modout of 1 (i.e. a carry to the
  -- next digit), and the values 0, 2, 4, 6, 8.
  BCDdoubler : process(Q_int)
  begin
    case Q_int is
    when "0000" =>
                           -- Input 10s   Units    Result
      NextQ_int <= "000";  --  0     0     0         0
    when "0001" =>
      NextQ_int <= "001";  --  1     0     2         2
    when "0010" =>
      NextQ_int <= "010";  --  2     0     4         4
    when "0011" =>
      NextQ_int <= "011";  --  3     0     6         6 
    when "0100" =>
      NextQ_int <= "100";  --  4     0     8         8 
    when "0101" =>
      NextQ_int <= "000";  --  5     1     0         10
    when "0110" =>
      NextQ_int <= "001";  --  6     1     2         12
    when "0111" =>
      NextQ_int <= "010";  --  7     1     4         14
    when "1000" =>
      NextQ_int <= "011";  --  8     1     6         16
    when "1001" =>
      NextQ_int <= "100";  --  9     1     8         18
    when others =>
      NextQ_int <= (others => '-');
    end case;
  end process; 

  -- if the numbers are greater than 5, we should generate a 
  -- carry out (modulus out) to the next digit.
  ModOutGen : process(Q_int)
  begin
    case Q_int is
    when "0101" | "0110" | "0111" | "1000" | "1001" =>
      NextModOut <= '1';
    when others =>
      NextModOut <= '0';
    end case;
  end process; 

  -- When Init is high, we force ModOut to 0
  ModOut <= NextModOut and (not Init);
  
  ShiftReg : process(Clock, Reset)
  begin
    if Reset = '1' then
      Q_int <= (others => '0');
    elsif Rising_Edge(Clock) then
      if Init = '1' then
        Q_int <= (others => '0');
        Q_int(0) <= ModIn; -- set LSB initialisation
      else
        Q_int <= NextQ_int & ModIn;
       end if;
     end if;
  end process;

  Q <= Q_int;
  
end;
