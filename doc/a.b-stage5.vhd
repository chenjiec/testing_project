library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
use work.myTypes.all;
use work.all;

entity stage5 is 
port(clk:in std_logic;
     rst:in std_logic;
    -----------------signal from control block---------------
     LMD_LATCH_EN      :in std_logic;
     WB_MUX_SEL        :in std_logic;  
     RF_WE             :in std_logic;
     JUMP_EN           :in std_logic;
    -----------------data from the previous stage------------
     data_mem_out_to_re:in std_logic_vector(31 downto 0);
     alu_out_re_jal_1  :in std_logic_vector(31 downto 0);
     alu_out_re1       :in std_logic_vector(31 downto 0);
     w_re_num          :in std_logic_vector(4 downto 0)
   );
end stage5;

architecture beh of stage5 is
component RF_file is
port(clk:in std_logic;
     reg_num:in std_logic_vector(4 downto 0);---------there are 32 registers
     mux_stage5_out:in std_logic_vector(31 downto 0);
     RF_WE  :in std_logic;
     IR_LATCH_EN:in std_logic;
     reg_val:out std_logic_vector(31 downto 0)
   );
end component;
signal mux_stage5_out:std_logic_vector(31 downto 0);
signal reg_val:std_logic_vector(31 downto 0);
signal w_re_num1:std_logic_vector(4 downto 0);
signal w_re_num2:std_logic_vector(4 downto 0);
signal w_re_num3:std_logic_vector(4 downto 0);
signal w_re_num4:std_logic_vector(4 downto 0);
signal data_mem_out_to_re0:std_logic_vector(31 downto 0);
signal alu_out_re_jal_10  :std_logic_vector(31 downto 0);
signal alu_out_re10       :std_logic_vector(31 downto 0);
signal w_re_num0          :std_logic_vector(4 downto 0);

begin 
p1:process(clk,rst)
begin 
if(rst='0')then
if(clk='1' and clk'event)then
if(LMD_LATCH_EN='1') then
data_mem_out_to_re0     <=data_mem_out_to_re;
     alu_out_re_jal_10<= alu_out_re_jal_1;
     alu_out_re10<= alu_out_re1;
     w_re_num0<=w_re_num;
   else
    data_mem_out_to_re0     <=(others=>'0');
     alu_out_re_jal_10<= (others=>'0');
     alu_out_re10<= (others=>'0');
     w_re_num0<=(others=>'0');
   end if;
     
 if(JUMP_EN='1')then
   if(WB_MUX_SEL='1')then
   mux_stage5_out<= alu_out_re_jal_10;
 end if;
 w_re_num4<="11111";
 else
   if(WB_MUX_SEL='1')then
   mux_stage5_out<=data_mem_out_to_re0;
   else
   mux_stage5_out<=alu_out_re10;
   end if;
    w_re_num1<=w_re_num0;
   w_re_num2<=w_re_num1;
   w_re_num4<=w_re_num3;
 end if;
end if;
end if;
end process p1;
re:RF_file port map(clk,w_re_num,mux_stage5_out,'0',RF_WE,reg_val);
end beh;
