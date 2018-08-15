-- NAME: stage1-- fetch instruction from the IM/update PCindex  
-- DESC: 6 bits input as the index of the IM, 32 bits output
------------------------------------------------------------------------------ 
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

entity stage1 is  
  port (
    CLK     : in  std_logic;
    RST   : in  std_logic;
    ----------------from the control block-------------
    IR_LATCH_EN  : in std_logic;  
    NPC_LATCH_EN : in std_logic;
    muxpc        : in std_logic;
    ----------------signal about the data--------------
    M_PCIN   : in  std_logic_vector(31 downto 0);--------program_counter from the output of the Memory state
    IR       : out std_logic_vector(31 downto 0); 
    PC_count : out std_logic_vector(31 downto 0);--------used in the execution state
    id_ra_val: out std_logic_vector(31 downto 0);
    id_rb_val: out std_logic_vector(31 downto 0);
    id_imm   : out std_logic_vector(31 downto 0);
    --rb_re_num: out std_logic_vector(4 downto 0);---------used in the stage5 for estination reg
    w_re_num : out std_logic_vector(4 downto 0);------used for the write back stage5 to store the value in  this register
	---------------the w_re_num is also used for forwarding in the second stage , and we also have to use the number value of the ra,and rb----------------------------
    ra       : out std_logic_vector(4 downto 0);
	  rb       : out std_logic_vector(4 downto 0)
   );
end stage1;

architecture beh of stage1 is 
component IRAM is
generic (
    RAM_DEPTH : integer := 48;
    I_SIZE : integer := 32);
  port (
    Rst  : in  std_logic;
    clk  : in  std_logic;
    Addr : in  std_logic_vector(I_SIZE - 1 downto 0);
    Dout : out std_logic_vector(I_SIZE - 1 downto 0)
    );
end component; 

component RF_file is
port(clk:in std_logic;
     reg_num:in std_logic_vector(4 downto 0);
     mux_stage5_out:in std_logic_vector(31 downto 0);
     RF_WE  :in std_logic;
     IR_LATCH_EN:in std_logic;
     reg_val:out std_logic_vector(31 downto 0)
   );
end component;

signal IR_Dout  :std_logic_vector(31 downto 0);
signal id_ra_num:std_logic_vector(4  downto 0);
signal id_rb_num:std_logic_vector(4  downto 0);
signal j_imm    :std_logic_vector(25 downto 0);
signal PC_count0:std_logic_vector(31 downto 0):=(others=>'0');
signal pc:std_logic_vector(31 downto 0);
begin 
pp:process(clk,rst,muxpc)
begin
if(muxpc='0') then  
pc<=PC_count0;
else
pc<=M_PCIN;
end if; 
end process pp; 

Get_ir: IRAM 
generic map(RAM_DEPTH=>48,I_SIZE=>32)
port map(RST,clk,pc,IR_Dout);
--rb_re_num<=id_rb_num;
process (CLK, RST)
begin 
if RST = '1' then                 
       IR<=(others=>'0');    
else
    if (CLK'event and CLK = '1') then 
      PC_count0<=pc_count0+1 ;    
       if (NPC_LATCH_EN ='1') then
            PC_count<=PC_count0;-----------i supposed that the program counter is 32 bit so i rread them only one time not 8 bit by 4 times
       end if;
       if (IR_LATCH_EN ='1') then
       IR<=IR_Dout;     
       ----------get the value--------------
       ----------R_type---------------------
       if(conv_integer(IR_Dout(31 downto 26))=0) then
       id_ra_num<=IR_Dout(25 downto 21);
	     ra <= IR_Dout(25 downto 21);
       id_rb_num<=IR_Dout(20 downto 16);
	     rb <=IR_Dout(20 downto 16);
       w_re_num <=IR_Dout(15 downto 11);
	   --------------------------------------I type + branch -----------------------------------------
       elsif(conv_integer(IR_Dout(31 downto 26))=8 )or(conv_integer(IR_Dout(31 downto 26))=10)
       or(conv_integer(IR_Dout(31 downto 26))=11)or(conv_integer(IR_Dout(31 downto 26))=15)
       or(conv_integer(IR_Dout(31 downto 26))=12)or(conv_integer(IR_Dout(31 downto 26))=13)
       or(conv_integer(IR_Dout(31 downto 26))=14)or(conv_integer(IR_Dout(31 downto 26))=18)
       or(conv_integer(IR_Dout(31 downto 26))=20)or(conv_integer(IR_Dout(31 downto 26))=19)
       or(conv_integer(IR_Dout(31 downto 26))=22)or(conv_integer(IR_Dout(31 downto 26))=23)
       or(conv_integer(IR_Dout(31 downto 26))=24)or(conv_integer(IR_Dout(31 downto 26))=25)
       or(conv_integer(IR_Dout(31 downto 26))=26)or(conv_integer(IR_Dout(31 downto 26))=27)
       or(conv_integer(IR_Dout(31 downto 26))=28)or(conv_integer(IR_Dout(31 downto 26))=29)
       or(conv_integer(IR_Dout(31 downto 26))=32)or(conv_integer(IR_Dout(31 downto 26))=36)
       or(conv_integer(IR_Dout(31 downto 26))=37)or(conv_integer(IR_Dout(31 downto 26))=42)
       or(conv_integer(IR_Dout(31 downto 26))=58)or(conv_integer(IR_Dout(31 downto 26))=59)
       or(conv_integer(IR_Dout(31 downto 26))=35)or(conv_integer(IR_Dout(31 downto 26))=43)
       or(conv_integer(IR_Dout(31 downto 26))=61)then
       id_ra_num          <=IR_Dout(25 downto 21);
       w_re_num           <=IR_Dout(20 downto 16);
       id_imm(15 downto 0)<=IR_Dout(15 downto 0 );
       id_imm(31 downto 0)<=(others=>'0');
       elsif(conv_integer(IR_Dout(31 downto 26))=2)or(conv_integer(IR_Dout(31 downto 26))=3)then
       j_imm <= IR_Dout(25 downto 0);
       id_imm(31 downto 26)<=(others=>'0');
       id_imm(25 downto 0 )<=j_imm;
       end if;
       end if;
end if;
end if;
end process;
rb1:RF_file
port map(clk,id_rb_num,(others=>'0'),'0',IR_LATCH_EN,id_rb_val);       
ra1:RF_file
port map(clk,id_ra_num,(others=>'0'),'0',IR_LATCH_EN,id_ra_val);


end beh;

             

 
                          
          
           
