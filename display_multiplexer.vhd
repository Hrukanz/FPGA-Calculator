----------------------------------------------------------------------------------
-- Design Name: display_multiplexer
-- Module Name: display_multiplexer - Behavioral
-- Project Name: calculator 
-- Group Number: 21
-- Creators: BOURKE Jordan, WILSON Conor, YAMAMOTO Haruka
-- Description: A multiplexer used to change which digit in the display will be lit up, outputs both digit location and value
--              Select line comes from counter which rapidly switches between all display digits to create the effect they are all on at once
--              Enable line allows for it be turned on or disabled
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

entity display_multiplexer is
    port (
        enable : in std_logic;
        sel : in std_logic_vector(2 downto 0);
        digits : in std_logic_vector(31 downto 0); -- All digits stacked together as BCD
        
        num_out : out std_logic_vector(3 downto 0);
        screen : out std_logic_vector(7 downto 0)
    );
end display_multiplexer;

architecture Behavioral of display_multiplexer is

begin
    process (sel) 
        begin
            if enable = '1' then
                -- Loops through each digit in diplay, and feeds it appropriate BCD value
                case sel is
                    when "000" => 
                        num_out <= digits(3 downto 0);
                        screen <= "11111110";
                    when "001" => 
                        num_out <= digits(7 downto 4);
                        screen <= "11111101";
                    when "010" => 
                        num_out <= digits(11 downto 8);
                        screen <= "11111011";
                    when "011" => 
                        num_out <= digits(15 downto 12);
                        screen <= "11110111";
                    when "100" => 
                        num_out <= digits(19 downto 16);
                        screen <= "11101111";
                    when "101" => 
                        num_out <= digits(23 downto 20);
                        screen <= "11011111";
                    when "110" => 
                        num_out <= digits(27 downto 24);
                        screen <= "10111111";
                    when "111" => 
                        num_out <= digits(31 downto 28);
                        screen <= "01111111";
                end case;
            end if;
    end process;
end Behavioral;
