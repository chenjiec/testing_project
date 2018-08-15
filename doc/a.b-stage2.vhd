
-- NAME: stage2-- instruction decode/load address of register
-- DESC: 26 bits input,25-21-- RS1 ,20-16--RS2/RD0,15-11--RD1,15-0---EXT;output,readdata1/2/ext---32bits
-- i just implement the forwarding in the stage2, to check the w_re_num is equal ra or rb then , to verify whether to forwarding or not-------
--------------------------------------------------------------------------------

 
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;


entity stage2 is  
  port (CLK     : in  std_logic;
        RST   : in  std_logic;
        -----------control signal from control block-------------------
        RegA_LATCH_EN      : in std_logic;  -- Register A Latch Enable
        RegB_LATCH_EN      : in std_logic;  -- Register B Latch Enable
        RegIMM_LATCH_EN    : in std_logic;  -- Immediate Register
        -----------value from the  fetch state-------------------------
        id_ra_value        : in std_logic_vector(31 downto 0);
        id_rb_value        : in std_logic_vector(31 downto 0);
        id_imm             : in std_logic_vector(31 downto 0);
		-----------value from the fetch stage used for forwarding-------
		w_re_num           : in std_logic_vector(4 downto 0);
		ra                 : in std_logic_vector(4 downto 0);
	  rb                 : in std_logic_vector(4 downto 0);
		alu_out_re1        : in std_logic_vector(31 downto 0);
        -----------value from the  fetch state-------------------------          
        id_imm_32          : out std_logic_vector(31 downto 0);
        ra_value           : out std_logic_vector(31 downto 0);
        rb_value           : out std_logic_vector(31 downto 0)
   );
end stage2;

architecture beh of stage2 is
signal ra0 :std_logic_vector(4 downto 0);
signal ra1 :std_logic_vector(4 downto 0);
signal rb0 :std_logic_vector(4 downto 0);
signal rb1 :std_logic_vector(4 downto 0);
begin  
process (CLK,RST,id_ra_value,id_rb_value)
begin 
    if RST = '1' then                 
    id_imm_32<=(others=>'0');
    ra_value <=(others=>'0');
    rb_value <=(others=>'0');
    else
	ra0 <= ra;
	ra1 <= ra0;
	
	rb0<=rb;
	rb1<=rb0;
    if (CLK = '1'and CLK'event) then  
       if (REGA_LATCH_EN='1') then 
	    if ( ra0 = w_re_num  or ra1 = w_re_num ) then 
		 ra_value<=alu_out_re1;
		 else
         ra_value<=id_ra_value;
		 end if;
       end if;
       if (REGB_LATCH_EN='1') then
	    if ( rb0 = w_re_num or rb1 = w_re_num ) then 
		 ra_value<=alu_out_re1;
		 else
         ra_value<=id_ra_value;
		 end if;
       rb_value<=id_rb_value;
       end if;
       if (REGIMM_LATCH_EN='1') then
       id_imm_32<=id_imm;
       end if;
  end if;
end if;  
end process;
    
end beh;


                          
          
           
