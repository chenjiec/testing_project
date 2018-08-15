-- NAME:  SHIFTER -- shift right and shift left
-- DESC: 32 bits shifter
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shifter32 is
	port(
		DIN		: in std_logic_vector(31 downto 0);--input
		shbits			: in std_logic_vector(4 downto 0);--the number of bits to be shifted
		dir			: in std_logic;--dir=0, left; dir=1, right
		sign		: in std_logic;
		res			: out std_logic_vector(31 downto 0)--the output
	);
end entity shifter32;



-- architecture rtl of shifter32 is

architecture beh of shifter32 is

begin
	SHIFTER_BEHAVE: process (DIN, shbits, dir, sign)
	type matrix_masks is array (0 to 3) of std_logic_vector(39 downto 0);
	variable masks : matrix_masks;	    --vectors of masks: mask00, mask08, mask16, mask24
	type matrix_res is array (0 to 7) of std_logic_vector(31 downto 0);
	variable res_array : matrix_res;	 

	variable resLevelS : std_logic_vector(39 downto 0);

	variable intm : integer; -- intermediate variable
	variable temp : integer; --will contain the integer form of select number	
		
	variable chtemp : unsigned(4 downto 0); 
	
	begin
	

	Level_1: --generate masks
		if dir = '0' then -- shift left, need generate the mask0, mask 8L, mask16L, mask24L
			MASKL_GEN:for i in 0 to 3 loop
				intm := 31 - i * 8;
				masks(i)(39 downto 39-intm) := DIN(intm downto 0);
				masks(i)(39-intm-1 downto 0) := (others => '0');
			end loop;
		else --shift right, need generate the mask8R, mask16R, mask24R, mask32R
			MASKR_GEN:for i in 0 to 3 loop
				intm := i*8;
				masks(i)(31-intm downto 0) := DIN (31 downto intm);
				if sign = '1' then --arithmetic right shift
					masks(i)(39 downto 32-intm) := (others => DIN(31));
				else --positive number
					masks(i)(39 downto 32-intm) := (others => '0');
				end if;
			end loop;
		end if;

	Level_2:	 --generate coarse grains
		chtemp := unsigned (shbits(4 downto 0));		
		temp := to_integer(chtemp(4 downto 3));--to choose the mask we need
		resLevelS := masks(temp);

	Level_3:  --generate fine grains
		if dir = '1' then --shift right
	   	for	i in 0 to 7 loop
			   res_array(i) := resLevelS(31+i downto i);
		  end loop;
		else  --shift left
		  for	i in 0 to 7 loop
		  --consider the negated value issue here when doing left shift
			   res_array(i) := resLevelS(39-i downto 8-i);
		  end loop;
		end if;

		temp := to_integer(chtemp(2 downto 0));		
		res <= res_array(temp);
	
		 
	end process;
end beh;

