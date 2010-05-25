--
-- Copyright (C) Doulos Ltd 2001
--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use STD.textio.all;

entity BCDConvTB is
end;

architecture Bench of BCDConvTB is

  component BCDConv
    generic (N : positive);
    port (Clock : in std_logic;
          Reset : in std_logic;
          Init : in std_logic;
          ModIn : in std_logic;
          ModOut : out std_logic;
          Q      : out std_logic_vector(N*4-1 downto 0)
        );
  end component;

  -- hold an array of BCD digits
  type BCDVectorT is array (natural range <>) of std_logic_vector(3 downto 0);
  
  -- number of digits implemented in this test bench
  constant N : positive := 5;
  
  -- BCD array as a single std_logic_vector (packed in 4 bits at a 
  -- time)
  subtype BcdT is std_logic_vector(N*4-1 downto 0);
  
  signal Clock  : std_logic;
  signal Reset  : std_logic;
  signal Init   : std_logic;   -- Initialise BCD conversion 
  signal ModIn  : std_logic;   -- modulus in, if we wanted to 
                               -- cascade lots of NDigits design entities
  signal ModOut : std_logic;   -- modulus out, same reason as ModIn
  signal Q : BCDT;             -- The outputs of the BCD conversion packed
                               -- into a std_logic_vector
  
  -- Test bench control signal to ensure Clock stops when testing is over
  signal StopClock : boolean;  
  
  -- Outputs of BCD conversion as an array of 4 bit digits.
  signal BCDVec : BcdVectorT(1 to N);
  
  -- Type to allow a table of test values
  type TableT is array (natural range <>) of Integer;

  -- some interesting values to test
  constant Table : TableT := (17,18,19,20,21,22,23,30,40,50,
                              60,70,80,90,91,92,93,94,95,96,
                              97,98,99,100,101,302,
                              555,707,9999,10100, 99999);

  signal TestInteger : Integer;

begin

  UUT: BCDConv
    generic map (N => N)
    port map (
         Clock => Clock,
         Reset => Reset,
         Init => Init,
         ModIn => ModIn,
         ModOut => ModOut,
         Q     => Q);

  -- 100 ns clock. Clock loop stops automatically when the 
  -- stimulus process has finished, using the boolean signal StopClock
  ClockGen: process
  begin
    while not StopClock loop
      Clock <= '0';
      wait for 50 ns;
      Clock <= '1';
      wait for 50 ns;
    end loop;
    wait;
  end process;

  
  --
  -- Generate a set of values to test the Binary to BCD converter
  --
  StimGen: process
    variable TestVal : BCDT;
    variable L : LINE;
  begin
    Reset <= '0';
    ModIn <= '0';
    Init <= '0';
    wait until falling_edge(Clock);
    Reset <= '1';
    wait until falling_edge(Clock);
    Reset <= '0';

    
    -- test all the values in the table
    write(L, STRING'("Expected:"), LEFT, 10);
    write(L, STRING'("Actual:"),   LEFT, 10);
    writeline(OUTPUT,L);
    
    for I in Table'RANGE loop
      
      -- convert integer value to std_logic_vector
      TestVal := std_logic_vector(to_unsigned(Table(I), N*4));
      
      -- assign the test value to an integer signal - easy to 
      -- disply in the simulator
      TestInteger <= Table(I);
      write(L, Table(I), LEFT, 10);
      
      -- Loop round all the bits in the input vector 
      for J in BCDT'RANGE loop
        
        -- initialise conversion if shifting in the first bit
        if J = BCDT'LEFT then
          Init<= '1';
        else
          Init <= '0';
        end if;
        
        ModIn <= TestVal(J);
      
        wait until falling_edge(Clock);
      end loop;
      
      -- pack the result from the converter into a single std_logic_vector
      -- (and write them as we go to check against the originals).
      for J in 1 to N loop
         BCDVec(J) <= Q(J*4-1 downto J*4-4);
         write(L, to_integer(unsigned(Q(J*4-1 downto J*4-4))));
      end loop;
      
      writeline(OUTPUT,L);
      
    end loop;
    
    StopClock <= TRUE;  -- tell the clock generator to stop
    wait;
  end process;
  
end;

-- must have a configuration for synopsys vhdl simulator
use work.all;
configuration cfg_BCDConvTB of BCDConvTB is
  for Bench
  end for;
end; 
