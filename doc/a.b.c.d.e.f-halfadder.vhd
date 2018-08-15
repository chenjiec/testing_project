--------------------------------------------------------------------------------
--
-- NAME: halfadder
-- DESC: 1 bit halfadder
--------------------------------------------------------------------------------


library ieee;

use ieee.std_logic_1164.all;

--use work.constants.all;


entity HalfAdder is

	port(
		
                     a: in std_logic;
		
                   	b: in std_logic;
		
                   	s: out std_logic;
		
                   	co: out std_logic
		
                            );
	

end HalfAdder;


architecture half_adder_arch_behav of HalfAdder is

begin
	
   
     s <= a xor b;
    co <= a and b;
        
 
end half_adder_arch_behav;


configuration half_adder_cfg_behav of HalfAdder is
	
      for half_adder_arch_behav
	
   end for;

end half_adder_cfg_behav;
