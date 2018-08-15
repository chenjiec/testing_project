library ieee;

use ieee.std_logic_1164.all;

entity OR32 is
	
port(

      en: in std_logic;		
      a: in std_logic_vector(31 downto 0);	
     b: in std_logic_vector(31 downto 0);	
     y: out std_logic_vector(31 downto 0)

	);

end OR32;


architecture or32_gate_arch_behav of OR32 is

begin
	
     process(a,en)
    begin
     if (en= '1') then
     y<=a or b;
    end if;
  end process;
        
 
end or32_gate_arch_behav;


configuration or32_gate_cfg_behav of OR32 is
	
      for or32_gate_arch_behav
	
   end for;

end or32_gate_cfg_behav;

