library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity running_median is
Generic (
    DATA_WIDTH    : integer := 16;
    COUNTER_WIDTH : integer := 32 -- sets the max number of points between assertions of dump_results
);
port (
    clk             : in  std_logic;
    
    clk_enable      : in  std_logic;
    data            : in  std_logic_vector(DATA_WIDTH-1 downto 0);    -- unsigned
    
    -- output port: media_estimate updates 1 clk cycle after assertion of dump_results
    dump_results    : in  std_logic;
    median_estimate : out std_logic_vector(DATA_WIDTH-1 downto 0)

    );
end entity;

architecture Behavioral of running_median is


    signal total_points                  : unsigned(COUNTER_WIDTH-1 downto 0) := (others => '0');
    signal pts_above                     : unsigned(COUNTER_WIDTH-1 downto 0) := (others => '0');
    signal pts_above_higher              : unsigned(COUNTER_WIDTH-1 downto 0) := (others => '0');
    signal pts_above_lower               : unsigned(COUNTER_WIDTH-1 downto 0) := (others => '0');
    
    signal current_threshold             : unsigned(DATA_WIDTH-1 downto 0) := (others => '0');
    -- pipelined calculations of the next possible thresholds:
    signal next_threshold_much_higher    : unsigned(DATA_WIDTH-1 downto 0) := (others => '0');
    signal next_threshold_much_lower     : unsigned(DATA_WIDTH-1 downto 0) := (others => '0');
    signal next_threshold_slightly_higher: unsigned(DATA_WIDTH-1 downto 0) := (others => '0');
    signal next_threshold_slightly_lower : unsigned(DATA_WIDTH-1 downto 0) := (others => '0');
    
    signal median_estimate_internal : unsigned(DATA_WIDTH-1 downto 0) := (others => '0');
    


begin

    process (clk)
    begin
        if rising_edge(clk) then
            if dump_results = '1' then
                -- need to make a decision regarding the current threshold
                median_estimate_internal <= current_threshold;
                if pts_above_higher > shift_right(total_points, 1) then
                    -- threshold is way too low
                    current_threshold <= next_threshold_much_higher;
                elsif pts_above_lower < shift_right(total_points, 1) then
                    -- threshold is way too high
                    current_threshold <= next_threshold_much_lower;
                else
                    -- we are close to convergence
                    -- we simply nudge the threshold by a small amount at each stats_period:
                    -- we could put a deadband here but I don't really think that it matters
                    if pts_above > shift_right(total_points, 1) then
                        -- threshold is too low: nudge it up by ~1%
                        current_threshold <= next_threshold_slightly_higher;
                    else 
                        -- threshold is (probably) too high: nudge it down by ~1%
                        current_threshold <= next_threshold_slightly_lower;
                    end if;
                end if;

                -- reset counters
                pts_above        <= (others => '0');
                pts_above_higher <= (others => '0');
                pts_above_lower  <= (others => '0');
                total_points     <= (others => '0');
            else
                -- normal mode: count how many points are above our three thresholds:
                if clk_enable = '1' then
                    total_points <= total_points + 1;
                    -- compare the new point with our three different thresholds:
                    if unsigned(data) > current_threshold then
                        pts_above <= pts_above + 1;
                    end if;
                    if unsigned(data) > shift_left(current_threshold, 1) then
                        pts_above_higher <= pts_above_higher + 1;
                    end if;
                    if unsigned(data) > shift_right(current_threshold, 1) then
                        pts_above_lower <= pts_above_lower + 1;
                    end if;

                end if;
            end if;

            -- pipelined calculations of the next possible thresholds:
            next_threshold_much_higher <= shift_left(current_threshold, 1) + to_unsigned(1, DATA_WIDTH); -- the +1 here is to avoid getting stuck into the state: current_threshold = 0.
            next_threshold_much_lower <= shift_right(current_threshold, 1);
            -- these next two lines wouldn't work if the optimal threshold were way too low and we only used the shift operation,
            -- so we are adding a constant too to cover this edge case.
            next_threshold_slightly_higher <= current_threshold + shift_right(current_threshold, 7) + to_unsigned(1, DATA_WIDTH); -- increases by ~1%
            if current_threshold > 1 then
                next_threshold_slightly_lower <= current_threshold - shift_right(current_threshold, 7) - to_unsigned(1, DATA_WIDTH); -- decreases by ~1%
            else
                next_threshold_slightly_lower <= to_unsigned(1, DATA_WIDTH); -- clamp to 1
            end if;
        end if;
    end process;


    median_estimate <= std_logic_vector(median_estimate_internal);

end;
