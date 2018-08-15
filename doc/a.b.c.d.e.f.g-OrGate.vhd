
library ieee;
use ieee.std_logic_1164.all;


entity OrGate is 
  
  port (
        x1:in std_logic;
        x2:in std_logic;
        x3:out std_logic
      );
end OrGate;

architecture beh of OrGate is 

begin 
  x3 <= x1 or x2;
  
end beh;