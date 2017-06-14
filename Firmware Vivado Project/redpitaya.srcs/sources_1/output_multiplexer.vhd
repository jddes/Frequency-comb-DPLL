library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity output_multiplexer is
Generic (
	SIGNAL_LENGTH	: integer := 14
);

port (
	clk										: in  std_logic;
	--selector								: in  std_logic;
	-- internal configuration bus
    sys_addr                               	: in  std_logic_vector(32-1 downto 0);   -- bus address
    sys_wdata                              	: in  std_logic_vector(32-1 downto 0);   -- bus write data
    sys_sel                                	: in  std_logic_vector(4-1 downto 0);   -- bus write byte select
    sys_wen                                	: in  std_logic;   -- bus write enable
    sys_ren                                	: in  std_logic;   -- bus read enable
    sys_rdata                              	: out std_logic_vector(32-1 downto 0);  -- bus read data
    sys_err                               	: out std_logic;  -- bus error indicator
    sys_ack                                	: out std_logic;  -- bus acknowledge signal
    
    -- mux0
	in0_0_mux								: in  std_logic_vector(SIGNAL_LENGTH-1 downto 0);
	in1_0_mux								: in  std_logic_vector(SIGNAL_LENGTH-1 downto 0);
	out_0_mux								: out std_logic_vector(SIGNAL_LENGTH-1 downto 0);
     -- mux1
    in0_1_mux                               : in  std_logic_vector(SIGNAL_LENGTH-1 downto 0);
    in1_1_mux                               : in  std_logic_vector(SIGNAL_LENGTH-1 downto 0);
    out_1_mux                               : out std_logic_vector(SIGNAL_LENGTH-1 downto 0)
	);
end entity;

architecture Behavioral of output_multiplexer is

    signal output_mux0 : std_logic_vector(SIGNAL_LENGTH-1 downto 0) := (others  => '0') ;
    signal selector_mux0 : std_logic := '0';
    signal output_mux1 : std_logic_vector(SIGNAL_LENGTH-1 downto 0) := (others  => '0') ;
    signal selector_mux1 : std_logic := '0';

begin
    output1 : process (clk)
	begin
		if rising_edge(clk) then
			if selector_mux0 = '0' then
                output_mux0 <= in0_0_mux;
            else
                output_mux0 <= in1_0_mux;
			end if;
		end if;
	end process;

    out_0_mux <= output_mux0;

    output2 : process (clk)
    begin
        if rising_edge(clk) then
            if selector_mux1 = '0' then
                output_mux1 <= in0_1_mux;
            else
                output_mux1 <= in1_1_mux;
            end if;
        end if;
    end process;

    out_1_mux <= output_mux1;


-----------------------------------------
    -- registers

    ibus_manager : process (clk) is
    begin
        if rising_edge(clk) then
            sys_err <= '0';
            sys_ack <= sys_wen or sys_ren;

            -- Write
            if sys_wen = '1' then
                case sys_addr(20-1 downto 0) is
                    when x"00000" => 
                        selector_mux0  <= sys_wdata(0); --select the input for the mux 0
                    when x"00004" => 
                        selector_mux1  <= sys_wdata(0); --select the input for the mux 1
                    when others => 
                end case;
            end if;

            -- Read
            if sys_ren = '1' then
                case sys_addr(20-1 downto 0) is
                    when x"00000" => 
                        sys_rdata <= (others => '0');
                        sys_rdata(0) <= selector_mux0;
                    when x"00004" =>
                        sys_rdata <= (others => '0');
                        sys_rdata(0) <= selector_mux1;
                    when others => sys_rdata <=  (others => '0');
                end case;
            end if;

        end if;
    end process;

end;
