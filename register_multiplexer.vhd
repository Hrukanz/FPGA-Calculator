----------------------------------------------------------------------------------
-- Design Name: register_multiplexer
-- Module Name: register_multiplexer - Behavioral
-- Project Name: calculator 
-- Group Number: 21
-- Creators: BOURKE Jordan, WILSON Conor, YAMAMOTO Haruka
-- Description: A multiplexer used to determine which register should be fed into the binary to BCD converter
--              Selection based upon FSM output
--              Has an enable so can be turned on and off
--              Outputs a neg_flag, used to display a negative symbol if the outputted number is negative
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity register_multiplexer is
    port (
        enable : in std_logic;
        sel : in std_logic_vector(3 downto 0);
        operand_one: in std_logic_vector(11 downto 0);
        operand_two: in std_logic_vector(11 downto 0);
        result: in std_logic_vector(23 downto 0);
        
        neg_flag : out std_logic;
        num_out : out std_logic_vector(23 downto 0)
    );
end register_multiplexer;

architecture Behavioral of register_multiplexer is

begin
    process (sel) 
        begin
            if enable = '1' then
                case sel is
                    -- In state 1 the first operand is displayed
                    when "0001" =>
                    
                        neg_flag <= operand_one(11);
                        
                        -- Adjusts output to be 24 bits, filler bits set to 1 when -ve otherwise set to 0
                        if (operand_one(11) = '1') then
                            num_out <= X"FFF" & operand_one;
                        else
                            num_out <= X"000" & operand_one;
                        end if;
                    -- In state 3 the second operand is displayed
                    when "0100" => 
                    
                        neg_flag <= operand_two(11);
                        
                        -- Adjusts output to be 24 bits, filler bits set to 1 when -ve otherwise set to 0
                        if (operand_two(11) = '1') then
                            num_out <= X"FFF" & operand_two;
                        else
                            num_out <= X"000" & operand_two;
                        end if;
                    -- In state 4 the result is displayed, in state 1 no number is displayed so bcd input is irrelevant
                    when others => 
                        neg_flag <= result(23);
                        num_out <= result;
                end case;
            end if;
    end process;
end Behavioral;
