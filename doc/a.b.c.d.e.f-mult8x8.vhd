
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity mult8x8  is

port(

  --clk : in  std_logic;
  a   : in  std_logic_vector(7 downto 0);
  b   : in  std_logic_vector(7 downto 0);
  y   : out std_logic_vector(15 downto 0)

);

end entity ;

architecture rtl of mult8x8 is

component mult4x4 is
port (
 -- clk : in std_logic;
  a   : in std_logic_vector(3 downto 0);
  b   : in std_logic_vector(3 downto 0);
  y   : out std_logic_vector(7 downto 0)
);
end component;

--signal clkbuf : std_logic;

signal a8   : std_logic_vector(7  downto 0)  := (others => '0');
signal b8   : std_logic_vector(7  downto 0)  := (others => '0');
signal y1   : std_logic_vector(7  downto 0)  := (others => '0');
signal y2   : std_logic_vector(7  downto 0)  := (others => '0');
signal y3   : std_logic_vector(7  downto 0)  := (others => '0');
signal y4   : std_logic_vector(7  downto 0)  := (others => '0');
signal ybuf : std_logic_vector(15 downto 0)  := (others => '0');

begin

  a8 <= a;
  b8 <= b;
  --clkbuf <= clk;
  ybuf <= ( y4 & y1 )
          + ( "0000" & y2 & "0000")
          + ( "0000" & y3 & "0000");  
  y <= ybuf;
  
m1 : mult4x4
  port map(
   -- clk => clkbuf,
    a   => a8(3 downto 0),
    b   => b8(3 downto 0),
    y   => y1
    );

m2 : mult4x4
  port map(
   -- clk => clkbuf,
    a   => a8(7 downto 4),
    b   => b8(3 downto 0),
    y   => y2
    );

m3 : mult4x4
  port map(
    --clk => clkbuf,
    a   => a8(3 downto 0),
    b   => b8(7 downto 4),
    y   => y3
    );
    
m4 : mult4x4
  port map(
   -- clk => clkbuf,
    a   => a8(7 downto 4),
    b   => b8(7 downto 4),
    y   => y4
    );
        
end rtl;
