library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use WORK.Mytypes.all;
--use WORK.CONSTANTS.all;

entity ALU is
  port 	 ( 	OP: in aluOp	:=NOP;
			DATA1: in std_logic_vector(31 downto 0);
			DATA2: in std_logic_vector(31 downto 0);
			ALU_OUT: out std_logic_vector(31 downto 0));
end ALU;

architecture beh of ALU is

--rca from chapter 4
component rca is
		generic(
		
                nbits: integer := 32	);
          port(
                          ci: in std_logic;

                          a: in std_logic_vector(nbits-1 downto 0);
		
                          b: in std_logic_vector(nbits-1 downto 0);
		
                          s: out std_logic_vector(nbits-1 downto 0);
		
                          co: out std_logic
	
                           );
end component;



--32-bit shifter from chapter4
component shifter32 is
	port(
		DIN		: in std_logic_vector(31 downto 0);--input
		shbits			: in std_logic_vector(4 downto 0);--the number of bits to be shifted
		dir			: in std_logic;--dir=0, left; dir=1, right
		sign		: in std_logic;
		res			: out std_logic_vector(31 downto 0)--the output
	);
end component;

component mult32x32 is

port(

  a   : in  std_logic_vector(31 downto 0);
  b   : in  std_logic_vector(31 downto 0);
  y   : out std_logic_vector(63 downto 0)
  
);
end component;

	signal AdderA		: std_logic_vector(31 downto 0);
	signal AdderB		: std_logic_vector(31 downto 0);
	signal B_NOT		: std_logic_vector(31 downto 0);
	signal AdderCin		: std_logic;

	signal AdderRes 	: std_logic_vector(32 downto 0);
	SIGNAL SHIFTBS		: std_logic_vector(4 downto 0);
	signal ShiftRes		: std_logic_vector(31 downto 0);
	signal BitwiseRes	: std_logic_vector(31 downto 0);
	
	signal shift_dir	: std_logic;--shift direction
	signal shift_t		: std_logic;--'0' for logci shift, '1'for arithmetic shift

	signal compFlag		: std_logic;   --compare flag
	signal comRes		: std_logic;	--the result after comparing
------FOR MULT
  --signal MULTA	: std_logic_vector(31 downto 0);
	--signal MULTB: std_logic_vector(31 downto 0);
	signal MULTRES	: std_logic_vector(63 downto 0);
	


begin
	SHIFTBS<=DATA2(4 DOWNTO 0);--THE NUMBER OF bits for shifter

	-- whether this is a compare/set instruction


--	compFlag <='1' when Op=tLE or Op=tLT or Op=tGE or Op=tGT or Op=tLEU or Op=tLTU or Op=tGEU or Op=tGTU or Op=tEQ or Op=tNEQ else  
--				'0';
--compFlag <='1' when Op=SNE1 OR OP=SEQ OR OP=SLE1 OR OP=SLT OR OP=SGE1 OR OP=SGT OR OP=SNEI OR OP=SEQI OR OP=SLEI OR OP=SLTI OR OP=SGEI OR OP=SGTI OR OP=SGEU OR OP=SGEUI OR OP=SLTU OR OP=SLTUI OR OP=SGTU OR OP=SGTUI OR OP=SLEU OR OP=SLEUI else  
				--'0';
compFlag <='1' when Op=SNE1 OR OP=SEQ OR OP=SLE1 OR OP=SLT OR OP=SGE1 OR OP=SGT OR OP=SLTI1 OR OP=SGEI1 OR OP=SGEU1 OR OP=SLTU OR OP=SGTU  OR OP=SLEU1  else  
				'0';
	-- set the ALU_OUTput according to which operation has been done
	--ALU_OUT <= AdderRes(31 downto 0) when Op = J OR OP=JR OR OP=JAL OR OP=ADD OR OP=ADDU OR OP=ADDI OR OP=ADDUI OR OP=BEQZ OR OP=BNEZ OR OP=BFPT OR OP=BFPF OR OP=LB OR OP=LH OR OP=LW OR OP=LBU OR OP=LHU OR OP=SB OR OP=SH OR OP=SW OR OP=SUB OR OP=SUBI OR OP=SUBU OR OP=SUBUI else
			--ShiftRes when Op = LHI OR OP=LLS OR OP=SLLI OR OP=ARS OR OP=SRAI OR OP=LRS OR OP=SRLI else
			--BitwiseRes when Op =  DNA OR OP=ANDI OR OP=RO OR OP=ORI	OR OP=ROX OR OP=XORI else
			--(31 downto 1 => '0')&comRes when Op=SNE OR OP=SEQ OR OP=SLE OR OP=SLT OR OP=SGE OR OP=SGT OR OP=SNEI OR OP=SEQI OR OP=SLEI OR OP=SLTI OR OP=SGEI OR OP=SGTI OR OP=SGEU OR OP=SGEUI OR OP=SLTU OR OP=SLTUI OR OP=SGTU OR OP=SGTUI OR OP=SLEU OR OP=SLEUI OR OP=SNEU OR OP=SNEUI OR OP=SEQU OR OP=SEQUI else
			--(others =>'0');	
			ALU_OUT <= AdderRes(31 downto 0) when Op = J OR OP=JR OR OP=JAL OR OP=ADD OR OP=ADDUI OR OP=BEQZ OR OP=BNEZ OR OP=LB  OR OP=LW OR OP=LBU OR OP=LHU OR OP=SW OR OP=SUB1 OR OP=SUBU1 OR OP=MULT else
			ShiftRes when Op = LH1  OR OP=SLL1 OR OP=SRA1 else
			BitwiseRes when OP=AND1 OR OP=OR1	OR OP=XOR1 else
			(31 downto 1 => '0')&comRes when Op=SNE1 OR OP=SEQ OR OP=SLE1 OR OP=SLT OR OP=SGE1 OR OP=SGT OR OP=SLEI1 OR OP=SLTI1 OR OP=SGEI1  OR OP=SGEU1 OR OP=SLTU OR OP=SGTU OR OP=SLEU1  else
			MULTRES(31 downto 0) when OP=MULT
			else (others =>'0');	
	
	-- Logic Operation (BitWise)
	BITWISE_OP_LOOP: for i in 31 downto 0 generate
		BitwiseRes(i) <= DATA1(i) and DATA2(i) when Op = AND1  else
						DATA1(i) or DATA2(i) when Op= OR1 else
						DATA1(i) xor DATA2(i) when Op= XOR1 else
						'0'; 
		B_NOT(i) <= not DATA2(i) when Op = SUB1 OR Op= SUBU1 or compFlag = '1';
	end generate BITWISE_OP_LOOP;
	
	-- use RCA to do ADD/SUB operation (in 2's complement)
	AdderA <= DATA1 when Op = J OR Op=JR OR Op=JAL OR Op=ADD  OR Op=ADDUI OR Op=BEQZ OR Op=BNEZ OR Op=LB OR Op=LH1 OR Op=LW OR Op=LBU OR Op=LHU OR Op=SW OR Op=MULT 
 						or Op = SUB1 OR Op=SUBU1  or compFlag = '1';
	AdderB <= DATA2 when Op = J OR Op=JR OR Op=JAL OR Op=ADD OR Op=ADDUI OR Op=BEQZ OR Op=BNEZ OR Op=LB OR Op=LH1 OR Op=LW OR Op=LBU OR Op=LHU OR Op=SW OR Op=MULT else 
			B_NOT when Op = SUB1  OR Op=SUBU1 or compFlag = '1';
	AdderCin <= '0' when Op = J OR Op=JR OR Op=JAL OR Op=ADD OR Op=ADDUI OR Op=BEQZ OR Op=BNEZ OR Op=LB OR Op=LH1 OR Op=LW OR Op=LBU OR Op=LHU OR Op=SW OR Op=MULT else
	
			'1' when Op = SUB1 OR Op=SUBU1 or compFlag = '1';--fulfill the 2's complement

	RCA32Bit : rca 
		port map( Ci => AdderCin,A => AdderA, B => AdderB, S => AdderRes(31 downto 0), Co => AdderRes(32));
	
	  			
	--Reuse the RCA as a comparator (doing SUB operation)
	comRes <= '1' when ((AdderRes(32) = '0' or AdderRes(31 downto 0) = X"00000000")and (Op = SLE1 OR Op=SLEI1 ))
			or (AdderRes(32) = '1' and (Op = SGE1 OR Op=SGEI1 OR Op=SGEU1 ))
			or (AdderRes(32) = '0' and (Op = SLT OR Op=SLTI1 OR Op= SLTU ))
			or ((AdderRes(32) = '1' and AdderRes(31 downto 0) /= X"00000000") and (Op=SGT OR Op=SGTU ))
			or (AdderRes(31 downto 0) = X"00000000" and (Op = SEQ ))
			or (AdderRes(31 downto 0) /= X"00000000" and (Op = SNE1) )
			else
			'0';

	-- Shifter from chapten 4
	shift_dir <= '0' when Op = LH1    else--shift left
			'1' when  Op=SRA1 ;	--shift right
	shift_t <= '0' when Op = LH1  else
			'1' when  Op=SRA1 ;--shift right arithmetic 
	Shifter32_U1: shifter32 port map(DIN => DATA1, SHBITS => SHIFTBS, dir => shift_dir, sign => shift_t,
		res => ShiftRes);
------USE MULT 
  ---MULTA <= DATA1 when Op = MULT;
  ---MULTB <= DATA2 when Op = MULT;
	MULT0:mult32x32 port map (AdderA,AdderB,MULTRES);
	

end beh;

configuration CFG_ALU_beh of ALU is
  for beh
  end for;
end CFG_ALU_beh;
