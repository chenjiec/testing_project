
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myTypes.all;

entity TBFSM is
end TBFSM;

architecture TEST of TBFSM is
    signal Clock: std_logic := '0';
    signal Reset: std_logic := '1';
    signal st1_1,st1_2,st1_add,st2_1,st2_2,st2_3,st3_1,st3_2,st3_3,st3_4,st4_1,st4_2,st4_3,st4_4,st5_1,st5_2: std_logic := '0';
    signal ALU3_i:std_logic_vector(4 downto 0);
    signal IR_IN:std_logic_vector(31 DOWNTO 0);
    signal strange :integer;
  
component dlx_cu
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
    ALU_OPCODE         : out aluOp; -- choose between implicit or exlicit coding, like std_logic_vector(ALU_OPC_SIZE -1 downto 0);
    
    -- MEM Control Signals
    DRAM_WE            : out std_logic;  -- Data RAM Write Enable
    LMD_LATCH_EN       : out std_logic;  -- LMD Register Latch Enable
    JUMP_EN            : out std_logic;  -- JUMP Enable Signal for PC input MUX
    PC_LATCH_EN        : out std_logic;  -- Program Counte Latch Enable

    -- WB Control signals
    WB_MUX_SEL         : out std_logic;  -- Write Back MUX Sel
    RF_WE              : out std_logic  -- Register File Write Enable
    );
    --strange :out integer);
          
    end component;
  

begin

        -- instance of DLX
       dut: dlx_cu
       
       GENERIC MAP(     MICROCODE_MEM_SIZE => 9 ,
                        FUNC_SIZE          => 11,
                        OP_CODE_SIZE       => 6,
                        IR_SIZE            => 32,
                        CW_SIZE            => 16
             )
       port map (-- INPUTS         
                 Clk    => Clock,
                 Rst    => Reset,
                 IR_IN  => IR_IN,
           
                 -- OUTPUTS
                 IR_LATCH_EN    => ST1_1,
                 NPC_LATCH_EN   => ST1_2,
                 muxpc          => st1_add,
                 
                 RegA_LATCH_EN  => ST2_1,
                 RegB_LATCH_EN  => ST2_2,
                 RegIMM_LATCH_EN=> ST2_3,
                 
                 MUXA_SEL       => ST3_1,
                 MUXB_SEL       => ST3_2,
                 ALU_OUTREG_EN  => ST3_3,
                 EQ_COND        => ST3_4,
                 
                 ALU_OPCODE     => ALU3_i,
                 
                 DRAM_WE        => ST4_1,
                 LMD_LATCH_EN   => ST4_2,
                 JUMP_EN        => ST4_3,
                 PC_LATCH_EN    => ST4_4,
                 
                 WB_MUX_SEL     => ST5_1,
                 RF_WE          => ST5_2
                 
                -- strange => strange
               );

        Reset <= '1', '0' after 5 ns;
        
        Clock <= not Clock after 1 ns;
       

        CONTROL: process
        begin

        wait for 5 ns;  ----- be careful! the wait statement is ok in test
                        ----- benches, but do not use it in normal processes!

         --ADD RS1,RS2,RD -> Rtype
        
        --wait for 6 ns;
        IR_IN <= "00010000001000000001000000000110";---6R
        wait for 2 ns;
        IR_IN <= "00000000001000000001000000100000";---32R
        wait for 2 ns;
        IR_IN <= "00000000001000000001000000000110";---6R
        
       -- IR_IN <= "00001000000000000000000000000000";---j
        --wait for 2 ns;
        
        wait;
        end process;

end TEST;
