----------------------------------------------------------------------------------
-- Design Name: seven_segment_decoder
-- Module Name: seven_segment_decoder - Behavioral
-- Project Name: calculator 
-- Group Number: 21
-- Notes: Modified version of code originally created by Steve Weddell
-- Creators: BOURKE Jordan, WILSON Conor, YAMAMOTO Haruka
-- Description: The seven segment decoder takes a 4 bit BCD and decodes this to a 7 bit 
--              vector to display the BCD value it represents. The 7 bit vector is a vector
--              with each bit representing a segment on the 7 segment display where
--              the vector is in form "abcdefg" and the segment is structured as;
--                      a    
--                    ====
--                 f||    ||b
--                    ==== <- g
--                 e||    ||c
--                    ====
--                      d
--              Note: 7 segment vector is inverted, so values of 0 turn on segment, eg;
--                      1 = 0001 => 1001111 
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.ALL;
use ieee.std_logic_arith.ALL;
use ieee.std_logic_unsigned.ALL;


entity seven_segment_decoder is
		   port (
		      bcd_in: in std_logic_vector (3 downto 0);	-- Input BCD vector
    	      leds_out: out	std_logic_vector (1 to 7) -- Output 7-Seg vector 
    	   );		
end seven_segment_decoder;

architecture Behavioral of seven_segment_decoder is

begin
	my_seg_proc : process (bcd_in)		-- Enter this process whenever BCD input changes state
		begin
			case bcd_in is					 -- abcdefg segments
				when "0000"	=> leds_out <= "0000001";	  -- if BCD is "0000" write a zero to display
				when "0001"	=> leds_out <= "1001111";	  -- etc...
				when "0010"	=> leds_out <= "0010010";
				when "0011"	=> leds_out <= "0000110";
				when "0100"	=> leds_out <= "1001100";
				when "0101"	=> leds_out <= "0100100";
				when "0110"	=> leds_out <= "1100000";
				when "0111"	=> leds_out <= "0001111";
				when "1000"	=> leds_out <= "0000000";
				when "1001"	=> leds_out <= "0001100";
				when "1010"	=> leds_out <= "1111110";
				
				-- Allows for E and r to be displayed, for error message
				when "1101"	=> leds_out <= "0111001";
				when "1110" => leds_out <= "0110000";
				
				-- If the BCD is not valid then nothing displayed, leadin zeros are shown as 1111
				when others => leds_out <= "1111111";
			end case;
	end process my_seg_proc;

end Behavioral;
