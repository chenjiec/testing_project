library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_textio.all; 
use ieee.numeric_std.all;
use work.myTypes.all;
use work.all;

entity Data_mem is
port(
----------------signal from the control block-------------
read_or_write  :in  std_logic;
----------------data from the alu_out and rb_reg----------
addr_or_val    :in  std_logic_vector(31 downto 0);
     rb_val    :in  std_logic_vector(31 downto 0);
data_mem_out   :out std_logic_vector(31 downto 0)
);
end data_mem;

architecture beh of data_mem is
type data_type is array (integer range 0 to 31) of std_logic_vector(31 downto 0);
signal dram: data_type :=("00000000000000000000000000000000",
                          "00000000000000000000000000000000",
                          "00000000000000000000000000000000",
                          "00000000000000000000000000000000",
                          "00000000000000000000000000000000",
                          "00000000000000000000000000000000",
                          "00000000000000000000000000000000",
                          "00000000000000000000000000000000",
                          "00000000000000000000000000000000",
                          "00000000000000000000000000000000",
                          "00000000000000000000000000000000",
                          "00000000000000000000000000000000",
                          "00000000000000000000000000000000",
                          "00000000000000000000000000000000",
                          "00000000000000000000000000000000",
                          "00000000000000000000000000000000",
                          "00000000000000000000000000000000",
                          "00000000000000000000000000000000",
                          "00000000000000000000000000000000",
                          "00000000000000000000000000000000",
                          "00000000000000000000000000000000",
                          "00000000000000000000000000000000",
                          "00000000000000000000000000000000",
                          "00000000000000000000000000000000",
                          "00000000000000000000000000000000",
                          "00000000000000000000000000000000",
                          "00000000000000000000000000000000",
                          "00000000000000000000000000000000",
                          "00000000000000000000000000000000",
                          "00000000000000000000000000000000",
                          "00000000000000000000000000000000",
                          "00000000000000000000000000000000");
begin
process(addr_or_val,read_or_write)
begin
if(conv_integer(addr_or_val)>0)then
if(read_or_write='0')then--------------------read operation
data_mem_out<=dram(conv_integer(addr_or_val));
else
dram(conv_integer(addr_or_val))<=rb_val;
end if;
end if;
end process;
end beh;
