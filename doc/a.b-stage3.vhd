-- NAME: stage3-- operand fetch/execute
-- DESC: 26 bits input;output,result---32bits /zero---1
----ALU_TYPE:
----ALU_OPCODE:     000        001        010          011          100         101            
----                ADD        SUB        MUL          DIV          SHL         SHR
library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
--use ieee.std_logic_signed.all;---------eventhough input is std_logic_vector still can using signed algorithm
--use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all; 
use ieee.numeric_std.all;
use work.myTypes.all;
use work.all;

entity stage3 is  
  port (CLK     : in  std_logic;
        RST   : in  std_logic;
        -------------control signal from control block------------
        MUXA_SEL      : in std_logic;
        MUXB_SEL      : in std_logic;
        ALU_OUTREG_EN : in std_logic;  
        EQ_COND       : in std_logic;
        
        ALU_OPCODE : in aluOp;
        -------------register value get from stage2,PC_count from stage1----------
        PC_count  : in  std_logic_vector(31 downto 0);---stage1
        ra_val    : in  std_logic_vector(31 downto 0);
        rb_val    : in  std_logic_vector(31 downto 0);
        id_imm_32 : in  std_logic_vector(31 downto 0);
        
        alu_out_re1   : out std_logic_vector(31 downto 0);-------outcome connected with alu_out
        alu_out_re_jal: out std_logic_vector(31 downto 0);-------used for jal in the stage5
        branch_out    : out std_logic
   );
end stage3;

architecture beh of stage3 is
component ALU is
  port 	 ( 	OP: in aluOp	:=NOP;
      DATA1: in std_logic_vector(31 downto 0);
      DATA2: in std_logic_vector(31 downto 0);
      ALU_OUT: out std_logic_vector(31 downto 0));
end component;

signal addc,or_en,and_en,addco :std_logic;
signal adda,addb,addce :std_logic_vector(31 downto 0);
signal alu_ra_sel:std_logic_vector(31 downto 0);
signal alu_rb_sel:std_logic_vector(31 downto 0);
signal alu_out_re:std_logic_vector(31 downto 0);
begin
p_exe:process (CLK, RST,alu_opcode,MUXA_SEL,MUXB_SEL)
variable sll_inter:integer:=0;
variable slr_inter:integer:=0;
variable lw_v:integer:=0;
variable sw_v:integer:=0;
variable sra_v:integer:=0;
--variable alu_rb_sel_1:signed(31 downto 0);
begin 
    if RST = '1' then              
    alu_out_re <= (others => '0') ;   
    else
    if CLK'event and CLK = '1' then  
        -------------------MUXA--------------------------
         if(MUXA_SEL='1') then
         alu_ra_sel<=PC_count;
         else
         alu_ra_sel<=ra_val;
         end if;
         alu_out_re_jal<=alu_ra_sel;
        -------------------MUXB--------------------------
         if(MUXB_SEL='1') then
         alu_rb_sel<=rb_val;
         else
         alu_rb_sel<=id_imm_32;         
         end if;       
  end if;
end if;
end process p_exe;
        --------------------ALU--------------------------
        ALU0: 
        ALU port map(ALU_OPCODE,alu_ra_sel,alu_rb_sel,alu_out_re1);	 
          
   --if(ALU_OPCODE=ADD) then
--    alu_out_re<=std_logic_vector(signed(alu_ra_sel)+signed(alu_rb_sel));
--    elsif(ALU_OPCODE=addui)then
--    alu_out_re<=std_logic_vector(unsigned(alu_ra_sel)+unsigned(alu_rb_sel));
--    elsif(ALU_OPCODE=sub1) then
--    alu_out_re<=std_logic_vector(signed(alu_ra_sel)-signed(alu_rb_sel));
--    elsif(ALU_OPCODE=subu1) then
--    alu_out_re<=std_logic_vector(unsigned(alu_ra_sel)-unsigned(alu_rb_sel));
--    elsif(ALU_OPCODE=and1) then
--    alu_out_re<=alu_ra_sel and alu_rb_sel;
    --elsif(ALU_OPCODE=or1) then
--    alu_out_re<=alu_ra_sel or alu_rb_sel;
--    elsif(ALU_OPCODE=xor1) then
--    alu_out_re<=alu_ra_sel xor alu_rb_sel;
--    elsif(ALU_OPCODE=sll1) then
--    sll_inter:=to_integer(unsigned(alu_rb_sel(31 downto 27)));
--    alu_out_re(31 downto (sll_inter))<=alu_ra_sel((31-sll_inter)downto 0);
--    alu_out_re((sll_inter-1)downto 0)<=(others=>'0');
--    elsif(ALU_OPCODE=srl1) then
--    slr_inter:=to_integer(unsigned(alu_rb_sel(31 downto 27)));
--    alu_out_re((31-slr_inter) downto 0)<=alu_ra_sel(31 downto (slr_inter));
--    alu_out_re(31 downto 32-sll_inter)<=(others=>'0');
--    elsif(ALU_OPCODE=sne1) then
--      if(alu_ra_sel/=alu_rb_sel) then
--      alu_out_re<=(others=>'1');
--      else
--      alu_out_re<=(others=>'0');
--      end if;
--    elsif(ALU_OPCODE=sle1) then
--      if(alu_ra_sel=alu_rb_sel)then
--      alu_out_re<=(others=>'1');
--      else
--      alu_out_re<=(others=>'0'); 
--    end if;
--    elsif(ALU_OPCODE=sge1) then
--      if(signed(alu_ra_sel)>=signed(alu_rb_sel))then
--      alu_out_re<=(others=>'1');
--      else
--      alu_out_re<=(others=>'0');       
--      end if; 
--    elsif(ALU_OPCODE=sgeu1) then
--      if(unsigned(alu_ra_sel)>=unsigned(alu_rb_sel))then
--      alu_out_re<=(others=>'1');
--      else
--      alu_out_re<=(others=>'0');       
--      end if; 
--    elsif(ALU_OPCODE=slt)then
--      if(signed(alu_ra_sel)<signed(alu_rb_sel))then
--      alu_out_re(31 downto 1)<=(others=>'0');
--      alu_out_re(0)<='1';
--      else
--      alu_out_re<=(others=>'0');
--      end if;
--    elsif(ALU_OPCODE=sltu)then
--      if(unsigned(alu_ra_sel)<unsigned(alu_rb_sel))then
--      alu_out_re(31 downto 1)<=(others=>'0');
--      alu_out_re(0)<='1';
--      else
--      alu_out_re<=(others=>'0');
--      end if;
--    elsif(ALU_OPCODE=sgt)then
--     if(signed(alu_ra_sel)<signed(alu_rb_sel))then
--      alu_out_re(31 downto 1)<=(others=>'0');
--      alu_out_re(0)<='1';
--      else
--      alu_out_re<=(others=>'0');
--      end if; 
--    elsif(ALU_OPCODE=sgtu)then
--     if(signed(alu_ra_sel)<signed(alu_rb_sel))then
--      alu_out_re(31 downto 1)<=(others=>'0');
--      alu_out_re(0)<='1';
--      else
--      alu_out_re<=(others=>'0');
--      end if; 
--    elsif(ALU_OPCODE=lw) then
--      lw_v:=to_integer(unsigned(alu_ra_sel))+to_integer(signed(alu_rb_sel));
--      alu_out_re<=std_logic_vector(to_unsigned(lw_v,32));
--      elsif(ALU_OPCODE=lb) then
--      lw_v:=to_integer(unsigned(alu_ra_sel))+to_integer(signed(alu_rb_sel));
--      alu_out_re<=std_logic_vector(to_unsigned(lw_v,32));
--      elsif(ALU_OPCODE=lbu) then
--      lw_v:=to_integer(unsigned(alu_ra_sel))+to_integer(signed(alu_rb_sel));
--      alu_out_re<=std_logic_vector(to_unsigned(lw_v,32));
--      elsif(ALU_OPCODE=lhu) then
--      lw_v:=to_integer(unsigned(alu_ra_sel))+to_integer(signed(alu_rb_sel));
--      alu_out_re<=std_logic_vector(to_unsigned(lw_v,32));
--    elsif(ALU_OPCODE=lh1) then
--      alu_out_re(31 downto 16)<=alu_rb_sel(15 downto 0);
--      alu_out_re(15 downto 0) <=(others=>'0');
--    elsif(ALU_OPCODE=sw) then 
--      sw_v:=to_integer(unsigned(alu_ra_sel))+to_integer(signed(alu_rb_sel));
--      alu_out_re<=std_logic_vector(to_unsigned(sw_v,32));
--    elsif(ALU_OPCODE=sra1) then 
--      sra_v:=to_integer(unsigned(alu_rb_sel));
--      alu_out_re(31 downto 32-sra_v)<=(others=>alu_ra_sel(31));
--      alu_out_re(31-sra_v downto 0)<=alu_ra_sel(31 downto 32-sra_v);
--    elsif(ALU_OPCODE=seq)then
--      if(signed(alu_ra_sel)=signed(alu_rb_sel))then
--      alu_out_re(31 downto 1)<=(others=>'0');
--      alu_out_re(0)<='1';
--      else
--      alu_out_re<=(others=>'0');
--    end if;
--    end if;
--    if(ALU_OUTREG_EN='1') then
--    alu_out_re1<=alu_out_re;
--    end if;  
--  end if;
--end if;
--end process p_exe; 

        -------------------Branch_Condition--------------
--p_branch:process(ra_val,alu_opcode,clk,RST)
--begin
--if RST = '0' then
--  if(clk='1'and clk'event) then
--       if(EQ_COND='1') then
--          if(ALU_OPCODE=beqz) then
--            if((to_integer(unsigned(ra_val))=0))then
--            branch_out<='1';
--            else
--            branch_out<='0';
--            end if;
--          elsif(ALU_OPCODE=bnez) then
--            if((to_integer(unsigned(ra_val))=0)) then
--            branch_out<='0';
--            else
--            branch_out<='1';
--            end if;
--          end if;
--         end if; 
-- end if;
--end if; 
--end process p_branch;      

end beh;


                          
          
           

