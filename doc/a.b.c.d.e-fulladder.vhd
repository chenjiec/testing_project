--------------------------------------------------------------------------------

-- NAME: FullAdder -- Full Adder
-- DESC: 1 bit Full Adder

--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

--use work.constants.all;


entity FullAdder is
	
port(
		
           ci: in std_logic;
		
           a: in std_logic;
		
           b: in std_logic;
		
           s: out std_logic;
		
         co: out std_logic
	
        ); 
   
end FullAdder;
       

architecture full_adder_arch_behav of FullAdder is

      begin

	s <= a xor b xor ci;
	
                 co <= (a and b) or (ci and (a xor b));
        
end full_adder_arch_behav;

architecture full_adder_arch_struct of FullAdder is
	
component HalfAdder is

	port(
		
                     	a: in std_logic;
		
                   	b: in std_logic;
		
                   	s: out std_logic;
		
                   	co: out std_logic
		
                            );
	
                    end component;
	
 component OrGate is
		
                  port(
			
                            x1: in std_logic;
			
                            x2: in std_logic;
			
                            x3: out std_logic
		
                           );
	
              end component;
	
signal halfTohalf, halfToOr1, halfToOr2: std_logic;

begin

    HA1: HalfAdder port map(a, b, halfTohalf, halfToOr1);
	
     HA2: HalfAdder port map(halfTohalf, ci, s, halfToOr2);
	
     OR1: OrGate port map(halfToOr1, halfToOr2, co);
    
end full_adder_arch_struct;


configuration full_adder_cfg_behav of FullAdder is

	for full_adder_arch_behav

	end for;

end full_adder_cfg_behav;

configuration full_adder_cfg_struct of FullAdder is
	
for full_adder_arch_struct
		
            for all : HalfAdder
			
                   use configuration work.half_adder_cfg_behav;
	
          end for;
	
end for;

end full_adder_cfg_struct;
