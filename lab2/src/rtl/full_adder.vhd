library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity full_adder is
  port (
    a     : in  STD_LOGIC ;
    b     : in  STD_LOGIC ;
    cin   : in  STD_LOGIC ;
    sum   : out STD_LOGIC ;
    cout  : out STD_LOGIC
  );
end entity full_adder;

architecture full_adder_arch of full_adder is
begin
  sum  <= a xor b xor cin ;
  cout <= (a and b) or (cin and (a xor b)) ;
end architecture full_adder_arch ;

