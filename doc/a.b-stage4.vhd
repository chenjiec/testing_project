library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
use work.myTypes.all;
use work.all;

entity stage4 is  
port (rst:in std_logic;
      clk:in std_logic;
      --------------------signal from the control block---------------------
      DRAM_WE     : in std_logic;  -- Data RAM Write Enable
      --LMD_LATCH_EN: in std_logic;  -- LMD Register Latch Enable
      JUMP_EN     : in std_logic;  -- JUMP Enable Signal for PC input MUX
      PC_LATCH_EN : in std_logic;  -- Program Counte Latch Enable
      ALU_OPCODE  : in aluop;
      --------------------signal from the former stage----------------------
      branch_out  : in std_logic;-----------------------------from stage3
      alu_out_re1 : in std_logic_vector(31 downto 0);---------from stage3 
      rb_val      : in std_logic_vector(31 downto 0);---------form stage1
      pc_count    : in std_logic_vector(31 downto 0);---------from stage1
      --alu_out_re  : in std_logic_vector(31 downto 0);---------from stage3
      alu_out_re_jal: in std_logic_vector(31 downto 0);---------from stage3
      -------------------out put to the stage5 and stage1------------------------
      M_PCIN             :out std_logic_vector(31 downto 0);      
      data_mem_out_to_re :out std_logic_vector(31 downto 0);
      alu_out_re_jal_1   :out std_logic_vector(31 downto 0)
);
end stage4;

architecture beh of stage4 is
component data_mem is  
port (
----------------signal from the control block-------------
read_or_write  :in  std_logic;
----------------data from the alu_out and rb_reg----------
addr_or_val    :in  std_logic_vector(31 downto 0);
     rb_val    :in  std_logic_vector(31 downto 0);
data_mem_out   :out std_logic_vector(31 downto 0)
);
end component;
signal muxpc_sel : std_logic;
signal Dram_out  : std_logic_vector(31 downto 0);
signal M_PCIN1:std_logic_vector(31 downto 0);
begin  
p1:process (CLK,RST,branch_out,jump_en)
begin
if RST = '1' then 
M_PCIN <=(others=>'0');
data_mem_out_to_re<=(others=>'0');                  
elsif CLK'event and CLK = '1' then 
---------------------pc_mux------------------
muxpc_sel <= branch_out or JUMP_EN;
   if(muxpc_sel='1')then
   M_PCIN1<=alu_out_re1;
   else
   M_PCIN1<=PC_count;
   end if;
   if(PC_LATCH_EN='1')then
   M_PCIN<=M_PCIN1;-------------if PC_LATCH_EN='0' remain the same PC
   end if;  
--------------------jal reg31 store---------- 
   if(JUMP_EN='1')then
   alu_out_re_jal_1<=alu_out_re_jal+1;
   end if;
   end if ;
end process p1;
--------------------Dram---------------------
dram1:Data_mem port map(DRAM_WE,alu_out_re1,rb_val,Dram_out);
p2:process(dram_we,alu_out_re1,rb_val,clk,rst)
begin
if RST = '0' then 
  if CLK'event and CLK = '1' then
    --if(LMD_LATCH_EN='1') then
     if(ALU_OPCODE=lb)then
       data_mem_out_to_re(7 downto 0)<=Dram_out(7 downto 0);
       data_mem_out_to_re(31 downto 25)<=(others=>Dram_out(7));
       elsif( ALU_OPCODE=lbu)then
       data_mem_out_to_re(7 downto 0)<=Dram_out(7 downto 0);
       data_mem_out_to_re(31 downto 25)<=(others=>'0');
       elsif(ALU_OPCODE=lhu)then
       data_mem_out_to_re(15 downto 0)<=Dram_out(15 downto 0);
       data_mem_out_to_re(31 downto 17)<=(others=>'0');
       else
       data_mem_out_to_re<=Dram_out;
       end if;
    --else
    --data_mem_out_to_re<=(others=>'U');
    --end if;
  end if;  
end if;
end process p2;
end beh;


                          
          
           



                          
          
           
