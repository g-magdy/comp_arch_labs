library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity elevator_ctrl is
  generic(
    NUM_FLOORS  : integer := 10;
    FLOOR_BITS  : integer := 4;
    CLK_FREQ    : integer := 50
  );
  port(
    clk           : in  std_logic;
    rst           : in  std_logic;
    floor_request : in  std_logic_vector(NUM_FLOORS - 1 downto 0);
    current_floor : out unsigned(FLOOR_BITS - 1 downto 0);
    moving_up     : out std_logic;
    moving_down   : out std_logic;
    door_open     : out std_logic;
    a_out         : out std_logic;
    b_out         : out std_logic;
    c_out         : out std_logic;
    d_out         : out std_logic;
    e_out         : out std_logic;
    f_out         : out std_logic;
    g_out         : out std_logic
  );
end elevator_ctrl;

architecture rtl of elevator_ctrl is

  -- state
  type state_type is (
    S_IDLE,
    S_CHECK_REQUESTS,
    S_MOVING_UP,
    S_MOVING_DOWN,
    S_DOOR_OPENING,
    S_DOOR_OPEN,
    S_DOOR_CLOSING
  );
  signal current_state, next_state : state_type;

  -- signals / regs
  signal current_floor_reg   : unsigned(FLOOR_BITS - 1 downto 0);
  signal target_floor_reg    : unsigned(FLOOR_BITS - 1 downto 0);
  signal move_timer          : integer range 0 to 2;
  signal door_timer          : integer range 0 to 2;
  signal is_idle             : std_logic;
  signal request_valid       : std_logic;
  signal suggested_direction : std_logic;
  signal enable              : std_logic;
  signal request_done : std_logic;
  -- FIX: those are added for can't read an output error in compile
  signal moving_up_reg       : std_logic;
  signal moving_down_reg     : std_logic;



  -- components
  component request_resolver is
      generic (
          NUM_FLOORS  : integer := 5;
          FLOOR_BITS  : integer := 4
      );
      port (
          clk               : in  std_logic;
          rst               : in  std_logic;
          floor_request     : in  std_logic_vector(NUM_FLOORS-1 downto 0);
          current_floor     : in  unsigned(FLOOR_BITS-1 downto 0);
          moving_up         : in  std_logic;
          moving_down       : in  std_logic;
          is_idle           : in  std_logic;
          request_done      : in  std_logic;
          target_floor      : out unsigned(FLOOR_BITS-1 downto 0);
          request_valid     : out std_logic;
          suggest_direction : out std_logic
      );
  end component;

  component clock_divider is
      generic (
          CLK_FREQ  : integer := 50
      );
      port (
          clk     : in  std_logic;
          rst     : in  std_logic;
          enable  : out std_logic
      );
  end component;

  component binary_to_seven_seg is
    port (
      num : in std_logic_vector(3 downto 0);
      a : out std_logic;
      b : out std_logic;
      c : out std_logic;
      d : out std_logic;
      e : out std_logic;
      f : out std_logic;
      g : out std_logic
    ) ;
  end component;
  

begin

  -- clock divider
  clock_divider_inst : clock_divider
      generic map (
          CLK_FREQ => CLK_FREQ
      )
      port map (
          clk => clk,
          rst => rst,
          enable => enable
      );

  req_resolver: request_resolver
      generic map (
          NUM_FLOORS => NUM_FLOORS,
          FLOOR_BITS => FLOOR_BITS
      )
      port map (
          clk => clk,
          rst => rst,
          floor_request => floor_request,
          current_floor => current_floor_reg,
          moving_up => moving_up_reg,
          moving_down => moving_down_reg,
          is_idle => is_idle,
          request_done => request_done,
          target_floor => target_floor_reg,
          request_valid => request_valid,
          suggest_direction =>  suggested_direction
      );

  -- state machine
  -- NOTE: almost boilerplate except timer logic and reset state
  process(clk, rst)
  begin
    if rst = '1' then
      current_state <= S_IDLE;
      current_floor_reg <= (others => '0');
      move_timer <= 0;
      door_timer <= 2;

    elsif rising_edge(clk) then
      current_state <= next_state;

      -- NOTE: this the timer logic

      if current_state = S_DOOR_OPEN and door_timer = 0 then
        -- door_timer <= 2;
      end if;

      if current_state = S_DOOR_OPENING then
        door_timer <= 2;
      end if;

      if enable = '1' then -- NOTE: enable is coming from the clock divider every 1 sec
        case current_state is

          when S_MOVING_UP | S_MOVING_DOWN =>
            if move_timer = 0 then

              if current_state = S_MOVING_UP then
                current_floor_reg <= current_floor_reg + 1;
              else
                current_floor_reg <= current_floor_reg - 1;
              end if;
              
              move_timer <= 1;
            else
              move_timer <= move_timer - 1;
            end if;

          when S_DOOR_OPEN =>
            if door_timer = 0 then
              door_timer <= 2;
            else
              door_timer <= door_timer - 1;
            end if;

          when S_CHECK_REQUESTS =>
            if move_timer = 0 then
              move_timer <= 1;
            end if;
            -- if door_timer = 0 then
            --   door_timer <= 2;
            -- end if;

          when others =>
            move_timer <= 0;
            door_timer <= 2;

        end case;
      end if;

    end if;
  end process;


  -- state transitions
  process(current_state, request_valid, suggested_direction, current_floor_reg, target_floor_reg, move_timer, door_timer)
  begin
    next_state <= current_state;
    moving_up_reg <= '0';
    moving_down_reg <= '0';
    door_open <= '0';
    is_idle <= '0';
    request_done <= '0';

    case current_state is
      when S_IDLE =>
        is_idle <= '1';
        if request_valid = '1' then
          next_state <= S_CHECK_REQUESTS;
        end if;

      when S_CHECK_REQUESTS =>
        if request_valid = '0' or request_done ='1'then
          next_state <= S_IDLE;
        elsif current_floor_reg = target_floor_reg then
          next_state <= S_DOOR_OPENING;
        elsif suggested_direction = '1' then
          next_state <= S_MOVING_UP;
        else
          next_state <= S_MOVING_DOWN;
        end if;

      when S_MOVING_UP =>
        moving_up_reg <= '1';
        if move_timer = 0 and current_floor_reg = target_floor_reg then
          next_state <= S_CHECK_REQUESTS;
        end if;

      when S_MOVING_DOWN =>
        moving_down_reg <= '1';
        if move_timer = 0 and current_floor_reg = target_floor_reg then
          next_state <= S_CHECK_REQUESTS;
        end if;

      when S_DOOR_OPENING =>
        door_open <= '1';
        next_state <= S_DOOR_OPEN;

      when S_DOOR_OPEN =>
        door_open <= '1';
        request_done <= '1';
        if door_timer = 0 then
          next_state <= S_DOOR_CLOSING;
        end if;

      when S_DOOR_CLOSING =>
        door_open <= '0';
        next_state <= S_CHECK_REQUESTS;

    end case;
  end process;

  -- output logic
  current_floor <= current_floor_reg;
  moving_up <= moving_up_reg;
  moving_down <= moving_down_reg;

  binary_to_seven_segment: binary_to_seven_seg
    port map (
      num => std_logic_vector(current_floor_reg),
      a => a_out,
      b => b_out,
      c => c_out,
      d => d_out,
      e => e_out,
      f => f_out,
      g => g_out
    );

end architecture rtl;
