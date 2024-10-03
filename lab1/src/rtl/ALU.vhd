library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity ALU is
  port (
    A_IN    : in  std_logic_vector(7 downto 0);
    B_IN    : in  std_logic_vector(7 downto 0);
    Cin  : in  std_logic                   ;
    S    : in  std_logic_vector(3 downto 0);
    F    : out std_logic_vector(7 downto 0);
    Cout : out std_logic
  );
end entity ALU;

architecture ArchALU of ALU is

-- Component Declarations
  component B is
    port (
      A     : in  std_logic_vector (7 downto 0) ;
      B     : in  std_logic_vector (7 downto 0) ;
      Cin   : in  std_logic                     ;
      S     : in  std_logic_vector (3 downto 0) ;
      F     : out std_logic_vector (7 downto 0) ;
      Cout  : out std_logic
    ) ;
  end component;

  component C is
    port (
      A       : in  std_logic_vector (7 downto 0) ;
      B       : in  std_logic_vector (7 downto 0) ;
      Cin     : in  std_logic                     ;
      S       : in  std_logic_vector (3 downto 0) ;
      F       : out std_logic_vector (7 downto 0) ;
      Cout    : out std_logic
    ) ;
  end component;

  component D is
    port (
      A     : in  std_logic_vector (7 downto 0) ;
      B     : in  std_logic_vector (7 downto 0) ;
      Cin   : in  std_logic                     ;
      S     : in  std_logic_vector (3 downto 0) ;
      F     : out std_logic_vector (7 downto 0) ;
      Cout  : out std_logic
    ) ;
  end component;

  -- Signals
  signal F_B : std_logic_vector(7 downto 0);
  signal Cout_B : std_logic;
  signal F_C : std_logic_vector(7 downto 0);
  signal Cout_C : std_logic;
  signal F_D : std_logic_vector(7 downto 0);
  signal Cout_D : std_logic;
 

begin
 
 
  B_inst: B port map(A_IN, B_IN, Cin, S, F_B, Cout_B);
  C_inst: C port map(A_IN, B_IN, Cin, S, F_C, Cout_C);
  D_inst: D port map(A_IN, B_IN, Cin, S, F_D, Cout_D);

  F <= F_B when S(3 downto 2) = "01" else
       F_C when S(3 downto 2) = "10" else
       F_D when S(3 downto 2) = "11" else
       (others => '0');

  Cout <= Cout_B when S(3 downto 2) = "01" else
          Cout_C when S(3 downto 2) = "10" else
          Cout_D when S(3 downto 2) = "11" else
          '0';
  
end architecture ArchALU;
