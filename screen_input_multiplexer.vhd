----------------------------------------------------------------------------------
-- Design Name: screen_input_multiplexer
-- Module Name: screen_input_multiplexer - Behavioral
-- Project Name: calculator 
-- Group Number: 21
-- Creators: BOURKE Jordan, WILSON Conor, YAMAMOTO Haruka
-- Description: The screen input multiplexer determines which value is to be outputted to
--              the number selector. This is either the BCD for a number from a register,
--              an error message, or the opcode for an operator
--              sel includes the operator state and error flag sel = (error, opcode_state)
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.ALL;

entity screen_input_multiplexer is
    port 
    (
        neg_flag : in std_logic;
        sel : in std_logic_vector (1 downto 0);
        opcode : in std_logic_vector (1 downto 0);
        digits : in std_logic_vector (31 downto 0);
           
        screen_info : out std_logic_vector (31 downto 0)
    );
end screen_input_multiplexer;

architecture Behavioral of screen_input_multiplexer is
    signal info : std_logic_vector (31 downto 0);
begin
    process (sel) 
        begin
            case sel is
                -- If there is no error and we are in the opcode state, then opcode displays
                when "01" =>
                    info <= X"FFFFFF00";
                    info(0) <= opcode(0);
                    info(4) <= opcode(1);
                -- If there is an error and not in the opcode state, then error message displays
                when "10" =>
                    info <= X"FFFED0DD";
                -- If no error and not in the opcode state then numbers are displayed
                when others =>
                    -- If the number is negative then the start of digits is set to 1010, code representing negative sign
                    if neg_flag = '1' then
                        info <= "1010" & digits(27 downto 0);
                    else
                        info <= digits;
                    end if;
            end case;
    end process;
    
    screen_info <= info;

end Behavioral;
