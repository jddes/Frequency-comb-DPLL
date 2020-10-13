library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity registers_read_testbench is
end registers_read_testbench;

architecture behavior of registers_read_testbench is


	-- Inputs
	signal clk                         :  std_logic := '0';
	signal status_flags                :  std_logic_vector(32-1 downto 0) := (others => '0');
	signal dither0_lockin_output       :  std_logic_vector(64-1 downto 0) := (others => '0');
	signal dither1_lockin_output       :  std_logic_vector(64-1 downto 0) := (others => '0');
	signal zdtc_samples_number_counter :  std_logic_vector(32-1 downto 0) := (others => '0');
	signal counter0_out                :  std_logic_vector(64-1 downto 0) := (others => '0');
	signal counter1_out                :  std_logic_vector(64-1 downto 0) := (others => '0');
	signal counter_new_data            :  std_logic := '0';
	signal counter_reg_to_dpll         :  std_logic_vector(64-1 downto 0) := (others => '0');
	signal dac0_out                    :  std_logic_vector(32-1 downto 0) := (others => '0');
	signal dac1_out                    :  std_logic_vector(32-1 downto 0) := (others => '0');
	signal dac2_out                    :  std_logic_vector(32-1 downto 0) := (others => '0');
	signal sys_addr                    :  std_logic_vector(32-1 downto 0) := (others => '0');
	signal sys_wdata                   :  std_logic_vector(32-1 downto 0) := (others => '0');
	signal sys_sel                     :  std_logic_vector(4-1  downto 0) := (others => '0');
	signal sys_wen                     :  std_logic := '0';
	signal sys_ren                     :  std_logic := '0';
	
	-- Outputs
	signal sys_rdata : std_logic_vector(32-1 downto 0);
	signal sys_err : std_logic;
	signal sys_ack : std_logic;
	
	signal sys_rdata_reg : unsigned(32-1 downto 0);
	signal counter_readout_error : std_logic := '0';
	-- Clock period definition
	constant clk_period : time := 5 ns;
begin

	-- Unit under test
	registers_read_inst : entity work.registers_read
	port map (
		clk => clk,
		status_flags => status_flags,
		dither0_lockin_output => dither0_lockin_output,
		dither1_lockin_output => dither1_lockin_output,
		zdtc_samples_number_counter => zdtc_samples_number_counter,
		counter0_out => counter0_out,
		counter1_out => counter1_out,
		dac0_out => dac0_out,
		dac1_out => dac1_out,
		dac2_out => dac2_out,

		counter_new_data => counter_new_data,
		counter_reg_to_dpll => counter_reg_to_dpll,
		sys_addr => sys_addr,
		sys_wdata => sys_wdata,
		sys_sel => sys_sel,
		sys_wen => sys_wen,
		sys_ren => sys_ren,
		sys_rdata => sys_rdata,
		sys_err => sys_err,
		sys_ack => sys_ack
	);

	-- Clock process definition for "clk"
	process
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;

	-- Stimulus process
	process
	begin
		wait for clk_period*10;
		-- Enable FIFO writes
		wait until rising_edge(clk);
			sys_addr(20-1 downto 0) <= x"00041";
			sys_wdata <= (others => '1');
			sys_wen <= '1';
		wait until rising_edge(clk);
			sys_wen <= '0';

		-- fifo empty? (less than 10 samples?)
		wait for clk_period*100;
		wait until rising_edge(clk);
			sys_addr(20-1 downto 0) <= x"00038";
			sys_ren <= '1';
		wait until rising_edge(clk);
			sys_ren <= '0';

		-- fifo empty? (less than 10 samples?)
		wait for clk_period*100;
		wait until rising_edge(clk);
			sys_addr(20-1 downto 0) <= x"00038";
			sys_ren <= '1';
		wait until rising_edge(clk);
			sys_ren <= '0';

		-- fifo empty? (less than 10 samples?)
		wait for clk_period*100;
		wait until rising_edge(clk);
			sys_addr(20-1 downto 0) <= x"00038";
			sys_ren <= '1';
		wait until rising_edge(clk);
			sys_ren <= '0';

		-- fifo empty? (less than 10 samples?)
		wait for clk_period*100;
		wait until rising_edge(clk);
			sys_addr(20-1 downto 0) <= x"00038";
			sys_ren <= '1';
		wait until rising_edge(clk);
			sys_ren <= '0';

		-- fifo empty? (less than 10 samples?)
		wait for clk_period*100;
		wait until rising_edge(clk);
			sys_addr(20-1 downto 0) <= x"00038";
			sys_ren <= '1';
		wait until rising_edge(clk);
			sys_ren <= '0';

		-- fifo empty? (less than 10 samples?)
		wait for clk_period*100;
		wait until rising_edge(clk);
			sys_addr(20-1 downto 0) <= x"00038";
			sys_ren <= '1';
		wait until rising_edge(clk);
			sys_ren <= '0';

		-- fifo empty? (less than 10 samples?)
		wait for clk_period*100;
		wait until rising_edge(clk);
			sys_addr(20-1 downto 0) <= x"00038";
			sys_ren <= '1';
		wait until rising_edge(clk);
			sys_ren <= '0';


		-- Disable FIFO writes
		wait until rising_edge(clk);
			sys_addr(20-1 downto 0) <= x"00041";
			sys_wdata <= (others => '0');
			sys_wen <= '1';
		wait until rising_edge(clk);
			sys_wen <= '0';


		-- fifo read
		wait for clk_period*100;

		wait until rising_edge(clk);
			sys_addr(20-1 downto 0) <= x"00039";
			sys_ren <= '1';
		wait until rising_edge(clk);
			sys_ren <= '0';

		wait until rising_edge(clk);
			sys_addr(20-1 downto 0) <= x"00039";
			sys_ren <= '1';
		wait until rising_edge(clk);
			sys_ren <= '0';

		wait until rising_edge(clk);
			sys_addr(20-1 downto 0) <= x"00039";
			sys_ren <= '1';
		wait until rising_edge(clk);
			sys_ren <= '0';

		wait until rising_edge(clk);
			sys_addr(20-1 downto 0) <= x"00039";
			sys_ren <= '1';
		wait until rising_edge(clk);
			sys_ren <= '0';


		-- highest fifo data count?
		wait for clk_period*100;
		wait until rising_edge(clk);
			sys_addr(20-1 downto 0) <= x"00040";
			sys_ren <= '1';
		wait until rising_edge(clk);
			sys_ren <= '0';


		-- test counter readout:


		wait until rising_edge(clk);
			sys_addr(20-1 downto 0) <= x"00041"; -- have counter ? expects no
			sys_ren <= '1';
		wait until rising_edge(clk);
			sys_ren <= '0';
			if unsigned(sys_rdata) /= to_unsigned(0, 32) then
				counter_readout_error <= '1';
			else
				counter_readout_error <= '0';
			end if;


		-- save counter data, then wait a bit:
		wait for clk_period*10;
		wait until rising_edge(clk);
			counter_new_data <= '1';
			counter_reg_to_dpll <= x"ABCD_1234_1111_3333";
		wait until rising_edge(clk);
			counter_new_data <= '0';
			counter_reg_to_dpll <= (others => '0');
		wait for clk_period*10;

		wait until rising_edge(clk);
			sys_addr(20-1 downto 0) <= x"00041"; -- have counter ? expects yes
			sys_ren <= '1';
		wait until rising_edge(clk);
			sys_ren <= '0';
		wait until rising_edge(clk);
			sys_rdata_reg <= unsigned(sys_rdata);
			if unsigned(sys_rdata) /= to_unsigned(1, 32) then
				counter_readout_error <= '1';
			else
				counter_readout_error <= '0';
			end if;

		wait until rising_edge(clk);
			sys_addr(20-1 downto 0) <= x"00042"; -- read LSBs
			sys_ren <= '1';
		wait until rising_edge(clk);
			sys_ren <= '0';
		wait until rising_edge(clk);
			if sys_rdata /= x"1111_3333" then
				counter_readout_error <= '1';
			else
				counter_readout_error <= '0';
			end if;

		wait until rising_edge(clk);
			sys_addr(20-1 downto 0) <= x"00043"; -- read MSBs
			sys_ren <= '1';
		wait until rising_edge(clk);
			sys_ren <= '0';
		wait until rising_edge(clk);
			if sys_rdata /= x"ABCD_1234" then
				counter_readout_error <= '1';
			else
				counter_readout_error <= '0';
			end if;

		wait until rising_edge(clk);
		wait until rising_edge(clk);
			sys_addr(20-1 downto 0) <= x"00041"; -- have counter ? expects no
			sys_ren <= '1';
		wait until rising_edge(clk);
			sys_ren <= '0';
		wait until rising_edge(clk);
			if unsigned(sys_rdata) /= to_unsigned(0, 32) then
				counter_readout_error <= '1';
			else
				counter_readout_error <= '0';
			end if;

		-----------------------------
		-- do it all over again:
		-- save counter data:
		wait for clk_period*10;
		wait until rising_edge(clk);
			counter_new_data <= '1';
			counter_reg_to_dpll <= x"5555_5555_6666_6666";
		wait until rising_edge(clk);
			counter_new_data <= '0';
			counter_reg_to_dpll <= (others => '0');
		wait for clk_period*10;

		wait until rising_edge(clk);
			sys_addr(20-1 downto 0) <= x"00041"; -- have counter ? expects yes
			sys_ren <= '1';
		wait until rising_edge(clk);
			sys_ren <= '0';
		wait until rising_edge(clk);
			if unsigned(sys_rdata) /= to_unsigned(1, 32) then
				counter_readout_error <= '1';
			else
				counter_readout_error <= '0';
			end if;

		wait until rising_edge(clk);
			sys_addr(20-1 downto 0) <= x"00042"; -- read LSBs
			sys_ren <= '1';
		wait until rising_edge(clk);
			sys_ren <= '0';
		wait until rising_edge(clk);
			if sys_rdata /= x"6666_6666" then
				counter_readout_error <= '1';
			else
				counter_readout_error <= '0';
			end if;

		wait until rising_edge(clk);
			sys_addr(20-1 downto 0) <= x"00043"; -- read MSBs
			sys_ren <= '1';
		wait until rising_edge(clk);
			sys_ren <= '0';
		wait until rising_edge(clk);
			if sys_rdata /= x"5555_5555" then
				counter_readout_error <= '1';
			else
				counter_readout_error <= '0';
			end if;

		wait;
	end process;

	
end;
