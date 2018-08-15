library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;


package myTypes is

	subtype aluOp is std_logic_vector(4 downto 0);
	constant NOP  : aluOp:= "00000";
	constant ADD  : aluOp:= "00001";  -- 0X20 ADD
	constant addui: aluOp:= "00010"; ---0x09 addui
	constant SUB1 : aluOp:= "00011";		-- 0X22 SUB
	constant SUBU1: aluOp:= "00100";  -- 0X23 SUBU
	constant AND1 : aluOp:= "00101";  -- 0X24 AND
	constant OR1  : aluOp:= "00110";  -- 0X25 OR
	constant XOR1 : aluOp:= "00111";  -- 0X26 XOR
	constant LH1  : aluOp:= "01000";  -- lhi 0X0f
	constant SLL1 : aluOp:= "01001";		-- 0X04 SLL
	constant SRA1 : aluOp:= "01010";		-- 0X07 SRA
	constant SEQ  : aluOp:= "01011";  -- 0X28 SEQ
	constant SNE1 : aluOp:= "01100";  -- 0X29 SNE
	constant SLT : aluOp:= "01101";  -- 0X2A SLT
	constant SLTI1 : aluOp:= "01101";  -- 0X2A SLT
	constant SGT : aluOp:= "01110";  -- 0X2B SGT 
	constant SLE1 : aluOp:= "01111";  -- 0X2C SLE
	constant SLEI1 : aluOp:= "01111";  -- 0X2C SLE
	constant SGE1 : aluOp:= "10000";  -- 0X2D SGE
	constant SGEI1 : aluOp:= "10000";  -- 0X2D SGE
	constant LB   : aluOp:= "10001";  -- 0X2D SGE				
	constant LBU   : aluOp:= "10010";  -- 0X2D SGE	
	constant LHU  : aluOp:= "10011";  -- lhU 0X25
	constant SW   : aluOp:= "10100";  -- 0X2D SGE	
	constant SRl1 : aluOp:= "10101";		-- 0X06 srl
	constant ADDU1  : aluOp:= "10110";  -- 0X21 ADDU1
	constant MULT :aluop:="10111";  ----0x0e mult
	
	constant SLTU : aluOp:= "11000";  -- 0X3A SLTUI
	constant SGTU : aluOp:= "11001";  -- 0X3B SGTUI 
	constant SLEU1 : aluOp:= "11010";  -- 0X3C SLEUI
	constant SGEU1 : aluOp:= "11011";  -- 0X3D SGEUI
	constant LW   : aluOp:= "11101";  -- 0X2D SGE								
	constant BEQZ : aluOp:= "11110";  -- beqz 0X04
  constant BNEZ : aluOp:= "11111";  -- bnez 0X05
  
  constant J : aluOp:= "11111";  -- bnez 0X05
  constant JAL : aluOp:= "11111";  -- bnez 0X05
  constant JR : aluOp:= "11111";  -- bnez 0X05

end myTypes;

