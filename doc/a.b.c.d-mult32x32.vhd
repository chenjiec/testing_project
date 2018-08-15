
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity mult32x32 is

port(

  ---clk : in  std_logic;
  a   : in  std_logic_vector(31 downto 0);
  b   : in  std_logic_vector(31 downto 0);
  y   : out std_logic_vector(63 downto 0)
  
);

end entity ;

architecture rtl of mult32x32 is

component mult16x16 is
port(
 --- clk : in  std_logic;
  a   : in  std_logic_vector(15 downto 0);
  b   : in  std_logic_vector(15 downto 0);
  y   : out std_logic_vector(31 downto 0)
);
end component;

---signal clkbuf : std_logic;
signal a32 : std_logic_vector(31 downto 0);
signal b32 : std_logic_vector(31 downto 0);
signal y1  : std_logic_vector(31 downto 0);
signal y2  : std_logic_vector(31 downto 0);
signal y3  : std_logic_vector(31 downto 0);
signal y4  : std_logic_vector(31 downto 0);
signal ybuf : std_logic_vector(63 downto 0);

begin

--  clkbuf <= clk;
  y <= ybuf;
  a32 <= a;
  b32 <= b;
  ybuf <= ( y4 & y1)
         + ( X"0000" & y2 & X"0000")
         + ( X"0000" & y3 & X"0000");
  
  m1 : mult16x16
  port map(
  --  clk => clkbuf,
    a   => a32(15 downto 0),
    b   => b32(15 downto 0),
    y   => y1
  );
  
  m2 : mult16x16
  port map(
  --  clk => clkbuf,
    a   => a32(31 downto 16),
    b   => b32(15 downto 0),
    y   => y2
  );

  m3 : mult16x16
  port map(
   -- clk => clkbuf,
    a   => a32(15 downto 0),
    b   => b32(31 downto 16),
    y   => y3
  );

  m4 : mult16x16
  port map(
  --  clk => clkbuf,
    a   => a32(31 downto 16),
    b   => b32(31 downto 16),
    y   => y4
  );


end rtl;
