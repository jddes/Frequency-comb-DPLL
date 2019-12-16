library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- thin wrapper around the divide_and_round() function found in maths_helper.vhd.
-- The purpose of this is to be able to use this function from Verilog.
-- according to https://forums.xilinx.com/t5/General-Technical-Discussion/call-vhdl-package-in-verilog/td-p/566899
-- that is the way to do it..

library work;
use work.maths_helper.all;


-- simply does resize(round(x/2^N_SIZE_SHIFT), x'length-N_SIZE_SHIFT))
-- note that this can wrap in extreme cases when the input is already super close to the positive rail
-- function divide_and_round( x : in signed; N_SIZE_SHIFT : in integer) return signed;
entity divide_and_round_module is
Generic (
    N_DATA_BITS  : integer := 16;
    N_SIZE_SHIFT : integer :=  6
);
port (
        data_in  : in  std_logic_vector(N_DATA_BITS-1              downto 0);
        data_out : out std_logic_vector(N_DATA_BITS-N_SIZE_SHIFT-1 downto 0)
    );
end entity;

architecture Behavioral of divide_and_round_module is
begin
    data_out <= std_logic_vector(divide_and_round(signed(data_in), N_SIZE_SHIFT));

end;
