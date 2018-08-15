
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity mult16x16 is

port(

  --clk : in  std_logic;
  a   : in  std_logic_vector(15 downto 0);
  b   : in  std_logic_vector(15 downto 0);
  y   : out std_logic_vector(31 downto 0)

);

end entity ;

architecture rtl of mult16x16 is

component mult8x8 is
port(

  --clk : in  std_logic;
  a   : in  std_logic_vector(7 downto 0);
  b   : in  std_logic_vector(7 downto 0);
  y   : out std_logic_vector(15 downto 0)

);
end component;

signal clkbuf : std_logic;

signal a16  : std_logic_vector(15 downto 0) := (others => '0');
signal b16  : std_logic_vector(15 downto 0) := (others => '0');
signal y1   : std_logic_vector(15 downto 0) := (others => '0');
signal y2   : std_logic_vector(15 downto 0) := (others => '0');
signal y3   : std_logic_vector(15 downto 0) := (others => '0');
signal y4   : std_logic_vector(15 downto 0) := (others => '0');
signal ybuf : std_logic_vector(31 downto 0) := (others => '0');

begin

  a16 <= a;
  b16 <= b;
  y <= ybuf;
 -- clkbuf <= clk;
  ybuf <= ( y4 & y1 )
          + ( X"00" & y2 & X"00")
          + ( X"00" & y3 & X"00");
  
  m1 : mult8x8
  port map(
   -- clk => clkbuf,
    a   => a16(7 downto 0),
    b   => b16(7 downto 0),
    y   => y1
    );

  m2 : mult8x8
  port map(
   -- clk => clkbuf,
    a   => a16(15 downto 8),
    b   => b16(7 downto 0),
    y   => y2
    );
    
  m3 : mult8x8
  port map(
  --  clk => clkbuf,
    a   => a16(7 downto 0),
    b   => b16(15 downto 8),
    y   => y3
    );
    
  m4 : mult8x8
  port map(
   -- clk => clkbuf,
    a   => a16(15 downto 8),
    b   => b16(15 downto 8),
    y   => y4
    );
    
end rtl;
