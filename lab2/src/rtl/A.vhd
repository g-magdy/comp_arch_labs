library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity A is
  generic (
    N : integer := 8
  );
  port (
    A     : in  std_logic_vector (N-1 downto 0) ;
    B     : in  std_logic_vector (N-1 downto 0) ;
    Cin   : in  std_logic                     ;
    S     : in  std_logic_vector (3 downto 0) ;
    F     : out std_logic_vector (N-1 downto 0) ;
    Cout  : out std_logic                     
  );
end entity A;

architecture AArch of A is
  component adder_subtractor is
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
  end component adder_subtractor;

  signal sub_con        : std_logic;
  signal b_input        : std_logic_vector(N-1 downto 0);
  signal addsub_result  : std_logic_vector(N-1 downto 0);
  signal addsub_cout    : std_logic;

begin

  addsub: adder_subtractor
    generic map (
      N => N
    )
    port map (
      a       => A,
      b       => b_input,
      sub     => sub_con,
      cin     => Cin,
      result  => addsub_result,
      cout    => addsub_cout
    );

    -- NOTE: the smart part here that the Cin logic all is handled by the addsub module native behavior
    -- only special case is F=B when S=0011 and Cin=1

    sub_con <= S(1); -- noticed from the table

    b_input <= B when S(1 downto 0) = "01" or S(1 downto 0) = "10" or (S(1 downto 0) = "11" and Cin = '1')
               else (others => '0');

    F <= B              when S = "0011" and Cin = '1' else
         addsub_result  when S(3 downto 2) = "00"     else
         (others => '0');

    Cout <= '0' when S = "0011" and Cin = '1' else
            addsub_cout when S(3 downto 2) = "00" else
            '0';
 
end architecture AArch;
