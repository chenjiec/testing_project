library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myTypes.all;
use ieee.numeric_std.all;
use work.all;

entity dlx_cu is
  generic (
    MICROCODE_MEM_SIZE :     integer := 9;  -- Microcode Memory Size
    FUNC_SIZE          :     integer := 11;  -- Func Field Size for R-Type Ops
    OP_CODE_SIZE       :     integer := 6;  -- Op Code Size
    -- ALU_OPC_SIZE       :     integer := 6;  -- ALU Op Code Word Size
    IR_SIZE            :     integer := 32;  -- Instruction Register Size    
    CW_SIZE            :     integer := 16);  -- Control Word Size
  port (
    Clk                : in  std_logic;  -- Clock
    Rst                : in  std_logic;  -- Reset:Active-Low
    -- Instruction Register
    IR_IN              : in  std_logic_vector(IR_SIZE - 1 downto 0);
    
    -- IF Control Signal
    IR_LATCH_EN        : out std_logic;  -- Instruction Register Latch Enable
    NPC_LATCH_EN       : out std_logic;  -- NextProgramCounter Register Latch Enable
    muxpc              : out std_logic;
                                        
    -- ID Control Signals
    RegA_LATCH_EN      : out std_logic;  -- Register A Latch Enable
    RegB_LATCH_EN      : out std_logic;  -- Register B Latch Enable
    RegIMM_LATCH_EN    : out std_logic;  -- Immediate Register Latch Enable

    -- EX Control Signals
    MUXA_SEL           : out std_logic;  -- MUX-A Sel
    MUXB_SEL           : out std_logic;  -- MUX-B Sel
    ALU_OUTREG_EN      : out std_logic;  -- ALU Output Register Enable
    EQ_COND            : out std_logic;  -- Branch if (not) Equal to Zero
	
    -- ALU Operation Code
    ALU_OPCODE         : out ALUOP;
    -- MEM Control Signa aluOp; -- choose between implicit or exlicit coding, like std_logic_vector(ALU_OPC_SIZE -1 downto 0);
    
    DRAM_WE            : out std_logic;  -- Data RAM Write Enable
    --LMD_LATCH_EN       : out std_logic;  -- LMD Register Latch Enable
    JUMP_EN            : out std_logic;  -- JUMP Enable Signal for PC input MUX
    PC_LATCH_EN        : out std_logic;  -- Program Counte Latch Enable

    -- WB Control signals
    LMD_LATCH_EN       : out std_logic;  -- LMD Register Latch Enable
    WB_MUX_SEL         : out std_logic;  -- Write Back MUX Sel
    RF_WE              : out std_logic);-- Register File Write Enable
    

end dlx_cu;

architecture dlx_cu_fsm of dlx_cu is
  type mem_array is array (integer range 0 to MICROCODE_MEM_SIZE - 1) of std_logic_vector(CW_SIZE - 1 downto 0);
  signal cw_mem : mem_array := (
                                "1101100110001001", --- 0 R type:0add/and/or/sge/sle/sll/sne/srl/sub...								
                                "1101010010001001", --- 1 I type:addi/andi/ori/sgei/slei/slli/snei/srli/subi...
								                "1101110010101111", --- 2 lw/sw
								                "1111011011001010", --- 3 BEQZ /BNEQZ								
								                "1111011010011000",-----4 J (0X02)								                				
								                "1110011010001001",-----5 JAL	
								                "1111010010011000",-----6 jr
								                "1111010010001001",-----7 jalr						
								                "0000000000000000");----8 NOP
                                
                                
  signal IR_opcode : std_logic_vector(OP_CODE_SIZE -1 downto 0);  -- OpCode part of IR----------6 bits
  signal IR_func : std_logic_vector(FUNC_SIZE-1 downto 0);   -- Func part of IR when Rtype--------11 bits
  signal cw1   : std_logic_vector(CW_SIZE - 1 downto 0):=(others=>'U'); -- full control word read from cw_mem-----15 bits
  signal cw2   : std_logic_vector(CW_SIZE - 1 downto 0):=(others=>'U'); 
  signal cw3   : std_logic_vector(CW_SIZE - 1 downto 0):=(others=>'U'); 
  signal cw4   : std_logic_vector(CW_SIZE - 1 downto 0):=(others=>'U'); 
  signal cw5   : std_logic_vector(CW_SIZE - 1 downto 0):=(others=>'U');
  --signal cw2_2   : std_logic_vector(CW_SIZE - 1 downto 0):="110011010001100"; 
  --signal cw_JL   : std_logic_vector(CW_SIZE - 1 downto 0):="110011010001000";---jal is different since it works at the previous 

  signal aluOpcode_i:aluOp:= NOP; -- ALUOP defined in package
  signal aluOpcode1: aluOp := NOP;
  signal aluOpcode2: aluOp := NOP;
  signal aluOpcode3: aluOp := NOP;
  signal aluOpcode4: aluOp := NOP;
  
  ---------pcstall 
  signal PCstall:std_logic:='0';
  
  -- declarations for FSM implementation (to be completed whith alla states!)
	type TYPE_STATE is (
		reset, 
		fetch,
		decode,
    execute,	
    memory,	
		write_back	
	);
	signal CURRENT_STATE : TYPE_STATE ;--:= reset;
	signal NEXT_STATE : TYPE_STATE :=reset;--:= fetch;
  signal conv_int:integer;	
begin  -- dlx_cu_rtl

  IR_opcode(5 downto 0) <= IR_IN(31 downto 26);
  IR_func(10 downto 0)  <= IR_IN(FUNC_SIZE - 1 downto 0);
  
  p_cw1_pre:
  process(rst,clk,ir_in)--,ir_opcode)--IR_IN,
  variable cw_mem_integer: integer:=6;
                                
  begin   
   
  if (clk ='1' and clk'event ) then 
     if(PCstall='0') then 
     if (IR_opcode = "000000")then
       cw_mem_integer :=0;
     elsif (conv_integer(IR_opcode)= 8)or(conv_integer(IR_opcode)= 10)or(conv_integer(IR_opcode)= 12)or(conv_integer(IR_opcode)= 13)
     or(conv_integer(IR_opcode)= 14)or(conv_integer(IR_opcode)= 20)or(conv_integer(IR_opcode)= 22)or(conv_integer(IR_opcode)= 25)
     or(conv_integer(IR_opcode)= 28)or(conv_integer(IR_opcode)= 29)or(conv_integer(IR_opcode)= 9)or(conv_integer(IR_opcode)= 11)
     or(conv_integer(IR_opcode)= 15)or(conv_integer(IR_opcode)= 23)or(conv_integer(IR_opcode)= 24)or(conv_integer(IR_opcode)= 26)
     or(conv_integer(IR_opcode)= 27)then
       cw_mem_integer :=1;
     elsif (conv_integer(IR_opcode)= 35)or(conv_integer(IR_opcode)= 42)or(conv_integer(IR_opcode)= 36)or(conv_integer(IR_opcode)= 37)then
       cw_mem_integer :=2;
     elsif (conv_integer(IR_opcode)= 4)OR(conv_integer(IR_opcode)= 5)then
       cw_mem_integer :=3;
     elsif(conv_integer(IR_opcode)= 2) then---j instruction
       cw_mem_integer :=4;
     elsif(conv_integer(IR_opcode)= 3) then---jal instruction
       cw_mem_integer :=5;
     elsif(conv_integer(IR_opcode)=18)then--jr
       cw_mem_integer :=6;
     elsif(conv_integer(IR_opcode)=19)then--jalr
       cw_mem_integer :=7;
     elsif(conv_integer(IR_opcode)= 21) then---nop instruction
       cw_mem_integer :=8;
    end if;
    cw1 <= cw_mem(cw_mem_integer);
  end if;
    cw2<=cw1;
    cw3<=cw2;
    cw4<=cw3;
    cw5<=cw4; 
	end if;
  end process p_cw1_pre;  

 




----------------------------------------------------- 
-- FSM
-- This is a very simplified starting point for a fsm
-- up to you to complete it and to improve it
-----------------------------------------------------
  p_jump_condition:------once in the jump situation we had to stall in order to get the result to jump
  process(clk,ir_in)
  begin
  if(clk='1' and clk'event) then
  if(conv_integer(ir_opcode)=2)or (conv_integer(ir_opcode)=3)then 
  PCstall<='1';
   end if;
  if(cw4(11)='1') then 
  PCstall<='0';
end if;
end if;
end process p_jump_condition;

 	P_state_switch: 
 	process(ir_in,clk,next_state)
	begin
		   if Rst='1' then
	     CURRENT_STATE <= reset;
	     else
		    if (Clk ='1' and Clk'EVENT and PCstall='0') then 
			 CURRENT_STATE <= NEXT_STATE;
		    end if;
		   end if;
	end process P_state_switch;

	P_NEXT_STATE : 
	process(next_STATE,IR_in,clk)--rst)
	begin	  
		  --NEXT_STATE <= CURRENT_STATE;
		  if(rst = '0') then
		    if (clk='1' and clk'event) then
		   case next_STATE is
			 when reset =>
			 NEXT_STATE <= fetch;
			 when fetch => 
			 NEXT_STATE <= decode;
			 when decode => 
			 NEXT_STATE <= execute;
			 when execute =>
			 NEXT_STATE <= memory;
			 when memory =>
			 NEXT_STATE <= write_back;
			 when write_back =>
			 NEXT_STATE <= fetch;
		   end case;	
		   end if;
		   end if;
	end process P_NEXT_STATE;
-----------------------------ALU------------------	
  -- purpose: Generation of ALU OpCode
  -- type   : combinational
  -- inputs : IR_i
  -- outputs: aluOpcode
  
   ALU_OP_CODE_P : process (ir_opcode,ir_func,clk,rst)--opcode, IR_func)
   begin  -- process ALU_OP_CODE_P
   if Rst='1' then
     aluOpcode_i <=NOP;
   else
       if (Clk ='1' and Clk'EVENT) then
	   ------------ case of R type requires analysis of FUNC ----------------
		       if (IR_opcode="000000") then
		      	  c1:case conv_integer(IR_func) is		      	       
				             when 32=> aluOpcode_i <= ADD; -- 0X20 ADD
				             when 36=> aluOpcode_i <= AND1; -- 0X24 AND
				             when 4 => aluOpcode_i <= SLL1; -- 0X04 SLL
				             when 6 => aluOpcode_i <= SRL1; -- 0X06 SRL
				             when 7 => aluOpcode_i <= SRA1; -- 0X07 SRA
				             when 33=> aluOpcode_i <= ADDU1; -- 0X21 ADDU
				             when 34=> aluOpcode_i <= SUB1; -- 0X22 SUB
				             when 35=> aluOpcode_i <= SUBU1;-- 0X23 SUBU
				             when 37=> aluOpcode_i <= OR1;  -- 0X25 OR
				             when 38=> aluOpcode_i <= XOR1; -- 0X26 XOR
				             when 40=> aluOpcode_i <= SEQ; -- 0X28 SEQ
				             when 41=> aluOpcode_i <= SNE1; -- 0X29 SNE
				             when 42=> aluOpcode_i <= SLT; -- 0X2A SLT
				             when 43=> aluOpcode_i <= SGT; -- 0X2B SGT 
				             when 44=> aluOpcode_i <= SLE1; -- 0X2C SLE
				             when 45=> aluOpcode_i <= SGE1; -- 0X2D SGE	
				             when 14=> aluOpcode_i <=	MULT;		
				             when others => aluOpcode_i <= NOP;
			            end case c1;
			      else
			     c2:case conv_integer(IR_opcode) is
		       when 2 => aluOpcode_i <= ADD;     -- j 0X02
		       when 3 => aluOpcode_i <= ADD;   -- jal 0X03
	        	when 8 => aluOpcode_i <= ADD;  -- addi 0X08
		       when 9 => aluOpcode_i <= ADDU1; -- addui 0x09
		       when 10 => aluOpcode_i <= SUB1; -- subi 0X0a
		       when 11 => aluOpcode_i <= SUBU1;-- subui 0X0b
		       when 12 => aluOpcode_i <= AND1; -- andi 0X0c
		       when 13 => aluOpcode_i <= OR1;  -- ori 0X0d
		       when 14 => aluOpcode_i <= XOR1; -- xori 0X0e
		       when 15 => aluOpcode_i <= LH1;  -- lhi 0X0f
		       when 18 => aluOpcode_i <= ADD; --  JR 0X12
		       when 19 => aluOpcode_i <= ADD;  -- JAR 0X13		       
		       when 20 => aluOpcode_i <= SLL1; -- slli 0X14
		       when 22 => aluOpcode_i <= SRL1; -- srli 0X16
		       when 23 => aluOpcode_i <= SRA1; -- srai 0X17
		       when 24 => aluOpcode_i <= SEQ; -- seqi 0X18
		       when 25 => aluOpcode_i <= SNE1; -- snei 0X19
		       when 26 => aluOpcode_i <= SLT; -- slti 0X1a
		       when 27 => aluOpcode_i <= SGT; -- sgti 0X1b
		       when 28 => aluOpcode_i <= SLE1; -- slei 0X1c
		       when 29 => aluOpcode_i <= SGE1; -- sgei 0X1d
		       when 32 => aluOpcode_i <= LB; -- LB 0X20
		       when 35 => aluOpcode_i <= ADD;-- LW 0X23
		       when 36 => aluOpcode_i <= LBU;-- LBU 0X24
		       when 37 => aluOpcode_i <= LHU;-- LHU 0X25
		       when 42 => aluOpcode_i <= SW;--SW 0X2B
		       when 58 => aluOpcode_i <= SLTU;-- sltui 0X3a
		       when 59 => aluOpcode_i <= SGTU;-- sgtui 0X3b
		       when 60 => aluOpcode_i <= SLEU1;-- sleui 0X3c
		       when 61 => aluOpcode_i <= SGEU1;-- sgeui 0X3d
		       when 4  => aluOpcode_i <= BEQZ; -- beqz 0X04
           when 5  => aluOpcode_i <= BNEZ; -- bnez 0X05
		       when others => aluOpcode_i <= NOP;
	         end case c2;
	       end if;
	       end if;
	    end if;
	end process ALU_OP_CODE_P;
	
p_alu_pipeline: 
process(aluOpcode_i,CLK)
       begin
         if(rst='0') then 
         if(clk='1' and clk'event) then
         
       aluOpcode1 <= aluOpcode_i;
	     aluOpcode2 <= aluOpcode1;
	     aluOpcode3 <= aluOpcode2;
	     
	     end if;
	     end if;
       end process p_alu_pipeline;

P_OUTPUT: 
PROCESS(current_state,clk)
       begin
        -- if(rst='0') then
       if (clk='1' and clk'event) then
       CASE CURRENT_STATE IS
       WHEN reset =>
	     IR_LATCH_EN <='0';
       NPC_LATCH_EN <='0';
       muxpc <= '0';
       
       RegA_LATCH_EN <='0';
       RegB_LATCH_EN <='0';
       RegIMM_LATCH_EN <='0';
 
       MUXA_SEL <='0';
       MUXB_SEL <='0';
       ALU_OUTREG_EN <='0';
       EQ_COND  <='0';
 
       ALU_OPCODE <="00000";
 
       DRAM_WE <='0';
       LMD_LATCH_EN <='0';
       JUMP_EN <='0';
       PC_LATCH_EN <='0';
 
       WB_MUX_SEL <='0';
       RF_WE <='0';
	   
	     WHEN fetch =>
	        
	     IR_LATCH_EN  <= cw1(CW_SIZE - 1);
       NPC_LATCH_EN <= cw1(CW_SIZE - 2);
	     muxpc <= cw1(CW_SIZE - 3);
	     
	     ALU_OPCODE    <=  aluOpcode1;
	     WHEN decode =>
	     IR_LATCH_EN  <= cw1(CW_SIZE - 1);
       NPC_LATCH_EN <= cw1(CW_SIZE - 2);
       muxpc <= cw1(CW_SIZE - 3);
                
       RegA_LATCH_EN   <= cw2(CW_SIZE - 3);
       RegB_LATCH_EN   <= cw2(CW_SIZE - 4);
       RegIMM_LATCH_EN <= cw2(CW_SIZE - 5);
       
       ALU_OPCODE    <=  aluOpcode1;
       
       WHEN execute =>
       IR_LATCH_EN  <= cw1(CW_SIZE - 1);
       NPC_LATCH_EN <= cw1(CW_SIZE - 2);
       muxpc <= cw1(CW_SIZE - 3);
              
       RegA_LATCH_EN   <= cw2(CW_SIZE - 3);
       RegB_LATCH_EN   <= cw2(CW_SIZE - 4);
       RegIMM_LATCH_EN <= cw2(CW_SIZE - 5);
       MUXA_SEL      <= cw3(CW_SIZE - 6);
       MUXB_SEL      <= cw3(CW_SIZE - 7);
       ALU_OUTREG_EN <= cw3(CW_SIZE - 8);
       EQ_COND       <= cw3(CW_SIZE - 9);
	   
	     ALU_OPCODE    <=  aluOpcode1; 
     
       WHEN memory =>
       IR_LATCH_EN  <= cw1(CW_SIZE - 1);
       NPC_LATCH_EN <= cw1(CW_SIZE - 2);
       muxpc <= cw1(CW_SIZE - 3);
                 
       RegA_LATCH_EN   <= cw2(CW_SIZE - 3);
       RegB_LATCH_EN   <= cw2(CW_SIZE - 4);
       RegIMM_LATCH_EN <= cw2(CW_SIZE - 5);
       MUXA_SEL      <= cw3(CW_SIZE - 6);
       MUXB_SEL      <= cw3(CW_SIZE - 7);
       ALU_OUTREG_EN <= cw3(CW_SIZE - 8);
       EQ_COND       <= cw3(CW_SIZE - 9);
	   
       DRAM_WE      <= cw4(CW_SIZE - 10);
       LMD_LATCH_EN <= cw4(CW_SIZE - 11);
       JUMP_EN      <= cw4(CW_SIZE - 12);
       --PC_LATCH_EN  <= cw4(CW_SIZE - 13);
	   
	     ALU_OPCODE   <= aluOpcode1; 
     
       WHEN write_back =>
       IR_LATCH_EN  <= cw1(CW_SIZE - 1);
       NPC_LATCH_EN <= cw1(CW_SIZE - 2);
       muxpc <= cw1(CW_SIZE - 3);
                        
       RegA_LATCH_EN   <= cw2(CW_SIZE - 3);
       RegB_LATCH_EN   <= cw2(CW_SIZE - 4);
       RegIMM_LATCH_EN <= cw2(CW_SIZE - 5);
       
       MUXA_SEL      <= cw3(CW_SIZE - 6);
       MUXB_SEL      <= cw3(CW_SIZE - 7);
       ALU_OUTREG_EN <= cw3(CW_SIZE - 8);
       EQ_COND       <= cw3(CW_SIZE - 9);
	   
       DRAM_WE      <= cw4(CW_SIZE - 10);
       LMD_LATCH_EN <= cw4(CW_SIZE - 11);
       JUMP_EN      <= cw4(CW_SIZE - 12);
       
       PC_LATCH_EN  <= cw5(CW_SIZE - 13);
       WB_MUX_SEL <= cw5(CW_SIZE - 14);
       RF_WE      <= cw5(CW_SIZE - 15);
	     ALU_OPCODE   <= aluOpcode1; 
	   
	   end case;
	   end if;
	   --end if;
	   end process P_OUTPUT; 
end dlx_cu_fsm;
