library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity request_resolver is
    generic (
        NUM_FLOORS : integer := 10;    -- Total number of floors (0-9)
        FLOOR_BITS : integer := 4      -- Bits needed to represent floor number
    );
    port (
        clk              : in  std_logic;
        rst              : in  std_logic;
        -- Input requests and current state
        floor_request    : in  std_logic_vector(NUM_FLOORS-1 downto 0);
        current_floor    : in  unsigned(FLOOR_BITS-1 downto 0);
        moving_up        : in  std_logic;
        moving_down      : in  std_logic;
        is_idle         : in  std_logic;
        request_done : in std_logic;
        -- Output signals
        target_floor     : out unsigned(FLOOR_BITS-1 downto 0);
        request_valid    : out std_logic;
        suggest_direction : out std_logic
    );
end request_resolver;

architecture Behavioral of request_resolver is
    -- Internal signals for request tracking
    signal request_reg : std_logic_vector(NUM_FLOORS-1 downto 0);
    signal request_valid_reg : std_logic;
    signal target_floor_reg : unsigned(FLOOR_BITS-1 downto 0);
    signal suggested_dir_up_reg : std_logic;

    -- Function to check if there are any requests above current floor
    function has_requests_above(requests: std_logic_vector; curr_floor: integer) return boolean is
    begin
        for i in curr_floor + 1 to requests'high loop
            if requests(i) = '1' then
                return true;
            end if;
        end loop;
        return false;
    end function;

    -- Function to check if there are any requests below current floor
    function has_requests_below(requests: std_logic_vector; curr_floor: integer) return boolean is
    begin
        for i in 0 to curr_floor - 1 loop
            if requests(i) = '1' then
                return true;
            end if;
        end loop;
        return false;
    end function;

    -- Function to find next request in upward direction
    function find_next_up_request(requests: std_logic_vector; curr_floor: integer) 
    return integer is
    begin
        for i in curr_floor + 1 to requests'high loop
            if requests(i) = '1' then
                return i;
            end if;
        end loop;
        return curr_floor;  -- Return current floor if no requests found
    end function;

    -- Function to find next request in downward direction
    function find_next_down_request(requests: std_logic_vector; curr_floor: integer) 
    return integer is
    begin
        for i in curr_floor - 1 downto 0 loop
            if requests(i) = '1' then
                return i;
            end if;
        end loop;
        return curr_floor;  -- Return current floor if no requests found
    end function;

begin
    -- Main request resolution process
 process(clk, rst)
        variable next_target : integer;
        variable has_request : boolean;
        variable current_floor_int : integer;
    begin
        if rst = '1' then
            request_reg <= (others => '0');
            request_valid_reg <= '0';
            target_floor_reg <= (others => '0');
            suggested_dir_up_reg <= '0';
            
        elsif rising_edge(clk) then
            -- Update request register with new requests
            request_reg <= request_reg or floor_request;
            
            -- Clear request when done
            if request_done = '1' then
                request_reg(to_integer(current_floor)) <= '0';
                -- Only clear valid flag if no other requests pending
                if not (has_requests_above(request_reg, to_integer(current_floor)) or 
                       has_requests_below(request_reg, to_integer(current_floor))) then
                    request_valid_reg <= '0';
                end if;
            end if;
            
            -- Process new requests or direction changes
            if (request_valid_reg = '0' and request_reg /= (request_reg'range => '0')) or
               (request_done = '1' and request_reg /= (request_reg'range => '0')) then
                
                current_floor_int := to_integer(current_floor);
                
                -- Check current floor first
                if request_reg(current_floor_int) = '1' then
                    target_floor_reg <= current_floor;
                    request_valid_reg <= '1';
                    
                -- Moving up or idle
                elsif moving_up = '1' or is_idle = '1' then
                    if has_requests_above(request_reg, current_floor_int) then
                        -- Find next request above
                        for i in current_floor_int + 1 to NUM_FLOORS-1 loop
                            if request_reg(i) = '1' then
                                target_floor_reg <= to_unsigned(i, FLOOR_BITS);
                                request_valid_reg <= '1';
                                suggested_dir_up_reg <= '1';
                                exit;
                            end if;
                        end loop;
                    elsif has_requests_below(request_reg, current_floor_int) then
                        -- Find next request below
                        for i in current_floor_int - 1 downto 0 loop
                            if request_reg(i) = '1' then
                                target_floor_reg <= to_unsigned(i, FLOOR_BITS);
                                request_valid_reg <= '1';
                                suggested_dir_up_reg <= '0';
                                exit;
                            end if;
                        end loop;
                    end if;
                    
                -- Moving down
                else
                    if has_requests_below(request_reg, current_floor_int) then
                        -- Find next request below
                        for i in current_floor_int - 1 downto 0 loop
                            if request_reg(i) = '1' then
                                target_floor_reg <= to_unsigned(i, FLOOR_BITS);
                                request_valid_reg <= '1';
                                suggested_dir_up_reg <= '0';
                                exit;
                            end if;
                        end loop;
                    elsif has_requests_above(request_reg, current_floor_int) then
                        -- Find next request above
                        for i in current_floor_int + 1 to NUM_FLOORS-1 loop
                            if request_reg(i) = '1' then
                                target_floor_reg <= to_unsigned(i, FLOOR_BITS);
                                request_valid_reg <= '1';
                                suggested_dir_up_reg <= '1';
                                exit;
                            end if;
                        end loop;
                    end if;
                end if;
            end if;
        end if;
    end process;
    -- Output assignments
    target_floor <= target_floor_reg;
    request_valid <= request_valid_reg;
    suggest_direction  <= suggested_dir_up_reg;
end Behavioral;
