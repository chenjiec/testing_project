
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity mult4x4 is

port(

--  clk : in  std_logic;
  a   : in  std_logic_vector(3 downto 0);
  b   : in  std_logic_vector(3 downto 0);
  y   : out std_logic_vector(7 downto 0)

);

end entity ;

architecture rtl of mult4x4 is

signal a_buf : std_logic_vector(3 downto 0) := (others => '0');
signal b1    : std_logic_vector(7 downto 0) := (others => '0');
signal b2    : std_logic_vector(7 downto 0) := (others => '0');
signal b4    : std_logic_vector(7 downto 0) := (others => '0');
signal b8    : std_logic_vector(7 downto 0) := (others => '0');
signal y_buf : std_logic_vector(7 downto 0) := (others => '0');

begin

--  process(clk) begin
    a_buf <= a;
    b1 <= "0000" & b;
    b2 <= "000" & b & '0';
    b4 <= "00" & b & "00";
    b8 <= '0' & b & "000";
    y <= y_buf;
--  end process;

--  process(clk) begin
   process(a,b) begin
    case a_buf is                           
    when "0000" => y_buf <= "00000000";          -- 0
    when "0001" => y_buf <= b1;                  -- 1
    when "0010" => y_buf <=      b2;             -- 2
    when "0011" => y_buf <= b1 + b2;             -- 3
    when "0100" => y_buf <=           b4;        -- 4
    when "0101" => y_buf <= b1 +      b4;        -- 5
    when "0110" => y_buf <=      b2 + b4;        -- 6
    when "0111" => y_buf <= b1 + b2 + b4;        -- 7
    when "1000" => y_buf <=                b8;   -- 8
    when "1001" => y_buf <= b1 +           b8;   -- 9
    when "1010" => y_buf <=      b2 +      b8;   -- 10
    when "1011" => y_buf <= b1 + b2 +      b8;   -- 11
    when "1100" => y_buf <=           b4 + b8;   -- 12
    when "1101" => y_buf <= b1 +      b4 + b8;   -- 13
    when "1110" => y_buf <=      b2 + b4 + b8;   -- 14
    when "1111" => y_buf <= b1 + b2 + b4 + b8;   -- 15
    when others => y_buf <= "00000000";
    end case;
  end process;

end rtl;
