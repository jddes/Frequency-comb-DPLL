library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity mux_internal_vco is
Generic (
	DATA_IN_WIDTH		: integer := 16;
	DATA_OUT_WIDTH		: integer := 14
);
port (
	clk									   : in  std_logic;
	-- input
    DACin0								   : in std_logic_vector(DATA_IN_WIDTH-1 downto 0); 	-- data out for DACa
    DACin1								   : in std_logic_vector(DATA_IN_WIDTH-1 downto 0);  	-- data out for DACb	
    -- internal configuration bus
    sys_addr                               : in  std_logic_vector(32-1 downto 0);  				-- bus address
    sys_wdata                              : in  std_logic_vector(32-1 downto 0); 				-- bus write data
    sys_sel                                : in  std_logic_vector(4-1 downto 0);  	 			-- bus write byte select
    -- communication bus for the vco
    sys_wen_vco                            : in  std_logic;   									-- bus write enable
    sys_ren_vco                            : in  std_logic;   									-- bus read enable
    sys_rdata_vco                          : out std_logic_vector(32-1 downto 0);  				-- bus read data
    sys_err_vco                            : out std_logic;  									-- bus error indicator
    sys_ack_vco                            : out std_logic;  									-- bus acknowledge signal
    -- communication bus for the mux
    sys_wen_mux                            : in  std_logic;   									-- bus write enable
    sys_ren_mux                            : in  std_logic;   									-- bus read enable
    sys_rdata_mux                          : out std_logic_vector(32-1 downto 0);  				-- bus read data
    sys_err_mux                            : out std_logic;  									-- bus error indicator
    sys_ack_mux                            : out std_logic;  									-- bus acknowledge signal
    -- output
    DACa_out							   : out std_logic_vector(DATA_OUT_WIDTH-1 downto 0);  	-- data out for DACa
    DACb_out							   : out std_logic_vector(DATA_OUT_WIDTH-1 downto 0)   	-- data out for DACa
);
end entity;

architecture Behavioral of mux_internal_vco is
	
	-- instanciation of the internal VCO
	component internal_vco 
		Generic (
			DATA_WIDTH			: integer := 16;	-- this cannot be changed without recompiling the DDS core
			AMPLITUDE_WIDTH : integer := 16			-- this should fit in a DSP47 mult
		);
		
		port (
			clk : in std_logic;
			frequency : in  std_logic_vector(48-1 downto 0);

			sys_addr : in  std_logic_vector(32-1 downto 0);   -- bus address
			sys_wdata : in  std_logic_vector(32-1 downto 0);   -- bus write data
			sys_sel : in  std_logic_vector(4-1 downto 0);   -- bus write byte select
			sys_wen : in  std_logic;   -- bus write enable
			sys_ren : in  std_logic;   -- bus read enable
			sys_rdata : out std_logic_vector(32-1 downto 0);  -- bus read data
			sys_err  : out std_logic;  -- bus error indicator
			sys_ack  : out std_logic;  -- bus acknowledge signal

			cosine_out : out std_logic_vector (DATA_IN_WIDTH-1 downto 0);
			sine_out : out std_logic_vector (DATA_IN_WIDTH-1 downto 0)
		);
	end component;

	signal selector_vco			: std_logic_vector (2-1 downto 0)	:= (others => '0') ; -- signal to select which DAC will get the VCO signal as output
	signal vco_offset 			: std_logic_vector (14-1 downto 0)  := (others => '0') ; -- intermediate signal to change the selected value that controls the frequency of the VCO
	signal vco_input_voltage	: std_logic_vector (16-1 downto 0)  := (others => '0') ; -- intermediate signal to change the selected value that controls the frequency of the VCO
	signal vco_frequency 		: std_logic_vector (48-1 downto 0)  := (others => '0') ; -- signal that contains the value of the frequency of the vco
	signal vco_cos_signal 		: std_logic_vector (16-1 downto 0)  := (others => '0') ; -- output value of the vco
	signal vco_sin_signal 		: std_logic_vector (16-1 downto 0)  := (others => '0') ; -- output value of the vco
	
	signal mux_a_out 		    : std_logic_vector (14-1 downto 0)  := (others => '0') ; -- signal for the DAC
	signal mux_b_out 		    : std_logic_vector (14-1 downto 0)  := (others => '0') ; -- signal for the DAC
	

begin

	internal_vco_inst : internal_vco
	generic map ( 	DATA_WIDTH 	=> DATA_IN_WIDTH )
	port map 	( 	clk 		=> clk,
					frequency 	=> vco_frequency,
					sys_addr 	=> sys_addr,
					sys_wdata 	=> sys_wdata,
					sys_sel 	=> sys_sel,
					sys_wen 	=> sys_wen_vco,
					sys_ren 	=> sys_ren_vco,
					sys_rdata 	=> sys_rdata_vco,
					sys_err 	=> sys_err_vco,
					sys_ack 	=> sys_ack_vco,
					cosine_out 	=> vco_cos_signal,
					sine_out 	=> vco_sin_signal
	);

	-- select which signal (DPLL0, DPLL1 or none) will control the VCO
	input_vco : process (clk)
	begin
		if rising_edge(clk) then
			--if the selected VCO output is DAC0
			if selector_vco = "01" then
				vco_input_voltage <= DACin0;
			--if the selected VCO output is DAC1
			elsif selector_vco = "10" then
				vco_input_voltage <= DACin1;
			-- if no DAC are selected for the VCO output
			else
				vco_input_voltage <= (others => '0');
			end if;
		end if;
	end process;


-- This alternative gain setting is set to be able to address the full 0-Nyquist frequency range with the 16-bits control signal out of the DPLL block.
-- offset is equal to dec2bin(31.25e6/125e6 * 2^48, 48)
-- in verilog : vco_frequency <= (signed(vco_input_voltage)<<<(48-16-1)) + signed(48'b0100000000000000000000000000000_00000000000000000);
vco_frequency <= std_logic_vector(signed(vco_input_voltage & "0000000000000000000000000000000") + "010000000000000000000000000000000000000000000000") ;

	-- select which signal (DPLL0 or vco) will control the DAC0
	output_muxa : process (clk)
	begin
		if rising_edge(clk) then
			--if the selected VCO output is DAC0
			if selector_vco = "01" then
				mux_a_out <= std_logic_vector(resize(signed(vco_cos_signal(16-1 downto 2)),mux_a_out'length) + resize(signed(vco_offset),mux_a_out'length));
			-- if no DAC1 or no DAC are selected for the VCO output
			else
				mux_a_out <= DACin0(16-1 downto 2);
			end if;
        end if;
    end process;

    -- select which signal (DPLL0 or vco) will control the DAC1
	output_muxb : process (clk)
	begin
		if rising_edge(clk) then
			--if the selected VCO output is DAC1
			if selector_vco = "10" then
				mux_b_out <= std_logic_vector(resize(signed(vco_cos_signal(16-1 downto 2)),mux_b_out'length) + resize(signed(vco_offset),mux_b_out'length));
			-- if no DAC1 or no DAC are selected for the VCO output
			else
				mux_b_out <= DACin1(16-1 downto 2);
			end if;
        end if;
    end process;

DACa_out <= mux_a_out;
DACb_out <= mux_b_out;

-----------------------------------------
    -- registers

    ibus_manager : process (clk) is
    begin
        if rising_edge(clk) then
            sys_err_mux <= '0';
            sys_ack_mux <= sys_wen_mux or sys_ren_mux;

            -- Write
            if sys_wen_mux = '1' then
                case sys_addr(20-1 downto 0) is
                    when x"00000" =>	selector_vco  <= sys_wdata(2-1 downto 0); --select where will the vco be connected
                    when x"00004" =>	vco_offset    <= sys_wdata(14-1 downto 0); --change the vco offset
                    when others => selector_vco <= (others => '0');
                end case;
            end if;

            -- Read
            if sys_ren_mux = '1' then
                case sys_addr(20-1 downto 0) is
                    when x"00000" => sys_rdata_mux <= std_logic_vector(resize(unsigned(selector_vco), 32));
                    when x"00004" => sys_rdata_mux <= std_logic_vector(resize(  signed(vco_offset)	, 32));
                    when others => sys_rdata_mux <=  (others => '0');
                end case;
            end if;

        end if;
    end process;

end;
