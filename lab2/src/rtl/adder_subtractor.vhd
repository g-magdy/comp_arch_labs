library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity adder_subtractor is
  generic (
    N : integer := 8
  );
  port (
    a       : in  std_logic_vector(N-1 downto 0) ;
    b       : in  std_logic_vector(N-1 downto 0) ;
    sub     : in  std_logic                      ; -- 0 for addition, 1 for subtraction
    cin     : in  std_logic                      ;
    result  : out std_logic_vector(N-1 downto 0) ;
    cout    : out std_logic
  );
end entity adder_subtractor;

architecture adder_subtractor_arch of adder_subtractor is
  component full_adder is
    port (
      a     : in  STD_LOGIC ;
      b     : in  STD_LOGIC ;
      cin   : in  STD_LOGIC ;
      sum   : out STD_LOGIC ;
      cout  : out STD_LOGIC
    );
  end component full_adder;

  signal carry : std_logic_vector(N   downto 0) ;
  signal b_xor : std_logic_vector(N-1 downto 0) ; -- b XORed with sub (gets 2's complement if sub = 1)
begin

  carry(0) <= cin ; -- notice that when sub = 1 cin is borrowin 

  invert_sub_gen: for i in 0 to N-1 generate
    b_xor(i) <= b(i) XOR sub ;
  end generate invert_sub_gen ;

  adder_gen: for i in 0 to N-1 generate
    adder : full_adder port map (
      a     => a(i) ,
      b     => b_xor(i) ,
      cin   => carry(i) ,
      sum   => result(i) ,
      cout  => carry(i+1)
    );
  end generate adder_gen ;

  cout <= carry(N) ;
end architecture adder_subtractor_arch ;
