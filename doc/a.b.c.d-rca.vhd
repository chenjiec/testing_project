-- NAME:  Rca -- Ripple Carry Adder

-- DESC: 32 bits rca
--------------------------------------------------------------------------------

library ieee;

use ieee.std_logic_1164.all;

--use work.constants.all;

use ieee.numeric_std.all;

entity rca is
	
generic(   nbits: integer := 32	);
	       port(
                         ci: in std_logic;

                          a: in std_logic_vector(nbits-1 downto 0);
		
                          b: in std_logic_vector(nbits-1 downto 0);
		
                          s: out std_logic_vector(nbits-1 downto 0);
		
                          co: out std_logic
	
                           );
           
end rca;


    
architecture rca_arch_struct of rca is
	 component FullAdder is
		port(
                ci: in std_logic;
			
                 a: in std_logic;
			
                 b: in std_logic;
			
                 s: out std_logic;
			
                 co: out std_logic
		
              );
	
         end component;

 
      signal carry: std_logic_vector(nbits-1 downto 0);

begin
	
GE: for i in 0 to nbits-1 generate
	
begin
		
 GE1:if i=0 generate
		
 FA1: FullAdder port map (ci, a(i), b(i), s(i), carry(i+1));
	
	end generate;
	
 GE2:if i=nbits-1 generate
		
   FA2: FullAdder port map (carry(i), a(i), b(i), s(i), co);
		
    end generate;
		
 GE3:if i>0 and i<nbits-1 generate
		
  FA3: FullAdder port map (carry(i), a(i), b(i), s(i), carry(i+1));
		
   end generate;
	
  end generate;

end rca_arch_struct;


