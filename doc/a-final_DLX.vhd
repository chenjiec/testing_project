library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
use work.myTypes.all;
use work.all;

entity DLX is
port(clk:in std_logic; 
     rst:in std_logic);
end DLX;

architecture beh of DLX is
component dlx_cu is
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
   NPC_LATCH_EN       : out std_logic;
   muxpc              : out std_logic;                                    -- NextProgramCounter Register Latch Enable
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
   LMD_LATCH_EN       : out std_logic;  -- LMD Register Latch Enable
   JUMP_EN            : out std_logic;  -- JUMP Enable Signal for PC input MUX
   PC_LATCH_EN        : out std_logic;  -- Program Counte Latch Enable

   -- WB Control signals
   WB_MUX_SEL         : out std_logic;  -- Write Back MUX Sel
   RF_WE              : out std_logic);-- Register File Write Enable
end component;
  
component stage1 is
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
end component;

component stage2 is
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
 end component;
 
 component stage3 is
 port (CLK     : in  std_logic;
         RST   : in  std_logic;
         -------------control signal from control block------------
         MUXA_SEL      : in std_logic;
         MUXB_SEL      : in std_logic;
         ALU_OUTREG_EN : in std_logic;  
         EQ_COND       : in std_logic;
         
         ALU_OPCODE : in aluop;
         -------------register value get from stage2,PC_count from stage1----------
         PC_count  : in  std_logic_vector(31 downto 0);
         ra_val    : in  std_logic_vector(31 downto 0);
         rb_val    : in  std_logic_vector(31 downto 0);
         id_imm_32 : in  std_logic_vector(31 downto 0);
         
         alu_out_re1   : out std_logic_vector(31 downto 0);-------outcome connected with alu_out
         alu_out_re_jal: out std_logic_vector(31 downto 0);-------used for jal in the stage5
         branch_out    : out std_logic
    );
end component; 

component stage4 is
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
      --alu_out_re1  : in std_logic_vector(31 downto 0);---------from stage3
      alu_out_re_jal: in std_logic_vector(31 downto 0);---------from stage3
      -------------------out put to the stage5 and stage1------------------------
      M_PCIN             :out std_logic_vector(31 downto 0);      
      data_mem_out_to_re :out std_logic_vector(31 downto 0);
      alu_out_re_jal_1   :out std_logic_vector(31 downto 0)
);
end component;

component stage5 is
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
end component;  
----------control signal form control block-------
--signal IR_IN: std_logic_vector(31 downto 0);

signal IR_LATCH_EN  :std_logic;--stage1
signal NPC_LATCH_EN :std_logic;
signal muxpc:std_logic;

signal RegA_LATCH_EN  :std_logic;---stage2
signal RegB_LATCH_EN  :std_logic;
signal RegIMM_LATCH_EN:std_logic;

signal MUXA_SEL     :std_logic;---stage3
signal MUXB_SEL     :std_logic;
signal ALU_OUTREG_EN:std_logic;
signal EQ_COND      :std_logic;

signal ALU_OPCODE:aluop;----alu_opcode

signal DRAM_WE     :std_logic;----stage4
signal LMD_LATCH_EN:std_logic;---this is  the stage5 signal
signal JUMP_EN     :std_logic;
signal PC_LATCH_EN :std_logic;

signal WB_MUX_SEL :std_logic;----stage5
signal RF_WE:std_logic;
----stage1 other signals---
signal M_PCIN:std_logic_vector(31 downto 0);
signal IR:std_logic_vector(31 downto 0);
signal PC_count:std_logic_vector(31 downto 0);
signal id_ra_val:std_logic_vector(31 downto 0);
signal id_rb_val:std_logic_vector(31 downto 0);
signal id_imm:std_logic_vector(31 downto 0);
signal w_re_num:std_logic_vector(4 downto 0);
----stage2 other signals---
signal id_imm_32:std_logic_vector(31 downto 0);
signal ra_val:std_logic_vector(31 downto 0);
signal rb_val:std_logic_vector(31 downto 0);
----stage3 other signals---
signal alu_out_re1:std_logic_vector(31 downto 0);
signal alu_out_re_jal:std_logic_vector(31 downto 0);
signal branch_out:std_logic;
-----stage4 other signals---
--signal M_PCIN:std_logic_vector(31 downto 0);--output,stage1 input
signal data_mem_out_to_re:std_logic_vector(31 downto 0);
signal alu_out_re_jal_1:std_logic_vector(31 downto 0);
------forwarding signal-----
signal ra :std_logic_vector(4 downto 0);
signal rb :std_logic_vector(4 downto 0);

begin
p_cu:dlx_cu
generic map(MICROCODE_MEM_SIZE=>9,
            FUNC_SIZE         =>11,
            OP_CODE_SIZE      =>6,
            IR_SIZE           =>32,
            CW_SIZE           =>16)
port map(Clk=>clk,
         rst=>rst,
         IR_IN=>IR,
         IR_LATCH_EN =>IR_LATCH_EN,     ---stage1
         NPC_LATCH_EN=>NPC_LATCH_EN,
         muxpc=>muxpc,
         RegA_LATCH_EN  =>RegA_LATCH_EN,---stage2
         RegB_LATCH_EN  =>RegB_LATCH_EN,
         RegIMM_LATCH_EN=>RegIMM_LATCH_EN,
         MUXA_SEL      =>MUXA_SEL,     ---stage3 
         MUXB_SEL      =>MUXB_SEL,
         ALU_OUTREG_EN =>ALU_OUTREG_EN,
         EQ_COND       =>EQ_COND,
         ALU_OPCODE    =>ALU_OPCODE,   ---alu
         DRAM_WE     =>DRAM_WE,        ---stage4
         LMD_LATCH_EN=>LMD_LATCH_EN,
         JUMP_EN     =>JUMP_EN,
         PC_LATCH_EN =>PC_LATCH_EN,
         WB_MUX_SEL=>WB_MUX_SEL,       ---stage5
         RF_WE     =>RF_WE
       );
       
p_stage1:stage1
port map(clk=>clk,
         rst=>rst,
         IR_LATCH_EN =>IR_LATCH_EN, ---signal from control block
         NPC_LATCH_EN=>NPC_LATCH_EN,
         muxpc=>muxpc,
         M_PCIN   =>M_PCIN,
         IR       =>IR,----------------out put
         PC_count =>PC_count,
         id_ra_val=>id_ra_val,
         id_rb_val=>id_rb_val,
         id_imm   =>id_imm,
         w_re_num =>w_re_num,
         ra       => ra,
         rb       => rb);
p_stage2:stage2
port map(clk=>clk,
         rst=>rst,
         RegA_LATCH_EN=>RegA_LATCH_EN,----signal form control block
         RegB_LATCH_EN=>RegB_LATCH_EN,
         RegIMM_LATCH_EN=>RegIMM_LATCH_EN,
         id_ra_value=>id_ra_val,---other signal 
         id_rb_value=>id_rb_val,
         id_imm     =>id_imm,
         w_re_num   =>w_re_num,
         ra         =>ra,
         rb         =>rb,
         alu_out_re1=>alu_out_re1,
         id_imm_32=>id_imm_32,---output
         ra_value =>ra_val,
         rb_value =>rb_val);
p_stage3:stage3
port map(clk=>clk,
         rst=>rst,
         MUXA_SEL=>MUXA_SEL,----signal from control block
         MUXB_SEL=>MUXB_SEL,
         ALU_OUTREG_EN=>ALU_OUTREG_EN,
         EQ_COND=>EQ_COND,
         ALU_OPCODE=>ALU_OPCODE,
         PC_count=>PC_count,----other input signal
         id_imm_32=>id_imm_32,
         ra_val   =>ra_val,
         rb_val   =>rb_val,
         alu_out_re1=>alu_out_re1,---output
         alu_out_re_jal=>alu_out_re_jal,
         branch_out=>branch_out);
p_stage4:stage4
port map(clk=>clk,
         rst=>rst,
         DRAM_WE=>DRAM_WE,----signal from control block
        -- LMD_LATCH_EN=>LMD_LATCH_EN,
         JUMP_EN=>JUMP_EN,
         PC_LATCH_EN=>PC_LATCH_EN,
         ALU_OPCODE=>ALU_OPCODE,
         branch_out=>branch_out,----other input signal 
         alu_out_re1=>alu_out_re1,--stage3
         rb_val=>rb_val,--stage3
         pc_count=>pc_count,--stage1
         --alu_out_re1=>alu_out_re1,--stage3
         alu_out_re_jal=>alu_out_re_jal,--stage3
         M_PCIN=>M_PCIN,---output
         data_mem_out_to_re=>data_mem_out_to_re,
         alu_out_re_jal_1=>alu_out_re_jal_1);
p_stage5:stage5
port map(clk=>clk,
         rst=>rst,
         LMD_LATCH_EN=>LMD_LATCH_EN,
         WB_MUX_SEL=>WB_MUX_SEL,---signal from control block
         RF_WE=>RF_WE,
         JUMP_EN=>JUMP_EN,
         data_mem_out_to_re=>data_mem_out_to_re,---other input signal
         alu_out_re_jal_1=>alu_out_re_jal_1,
         alu_out_re1=>alu_out_re1,
         w_re_num=>w_re_num);--stage1 
         
         
end beh;    
         
         
        
  
  