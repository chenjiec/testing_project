library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
use work.myTypes.all;
use work.all;

entity tbram is
end tbram;

architecture tb of tbram is 
component IRAM is
generic (
    RAM_DEPTH : integer := 48;
    I_SIZE : integer := 32);
port (
    Rst  : in  std_logic;
    clk  : in  std_logic;
    Addr : in  std_logic_vector(I_SIZE - 1 downto 0);
    Dout : out std_logic_vector(I_SIZE - 1 downto 0)
    );
end component;
signal rst:std_logic;
signal clk:std_logic;
signal dout:std_logic_vector(31 downto 0);
signal addr:std_logic_vector(31 downto 0);
begin
p1:IRAM
port map(rst,clk,addr,dout);
process
begin 
rst<='1';
wait for 1 ns;
--wait for 1 ns;
rst<='0';
clk<='0';
--wait for 1 ns;
--clk<='1';
wait for 1 ns;
clk<='1';
addr<=x"00000001";
wait for 1 ns;
clk<='0';
wait for 1 ns;
clk<='1';
addr<=x"00000002";
--clk<='0';
--wait for 1 ns;
--clk<='1';
--wait for 1 ns;
--clk<='0';
--wait for 1 ns;
--clk<='1';
wait;
end process;
end tb;