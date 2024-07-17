----------------------------------------------------------------------------------
-- Design Name: finite_state_machine
-- Module Name: finite_State_machine - Behavioral
-- Project Name: calculator 
-- Group Number: 21
-- Creators: BOURKE Jordan, WILSON Conor, YAMAMOTO Haruka
-- Description: Finite state machine controls the state of the machine depending on inputs and current state.
--              States of FSM (s0 = Operator, s1 = OperandA, s2 = OperandB, s3 = result).
--              Rising edge detection of the input stops multiple state changes occuring when the input is high
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

entity finite_state_machine is
    port (
        clk : in std_logic;
        reset : in std_logic;
        x : in std_logic;
        
        y : out std_logic_vector(3 downto 0)
    );
end finite_state_machine;

architecture Behavioral of finite_state_machine is

-- States of FSM (s0 = OperandA, s1 = Operator,
--                s2 = OperandB, s3 = Result).
type state_type is (s0, s1, s2, s3); 
signal current_s, next_s: state_type;

-- Used for rising edge detection
signal d : std_logic := '0';
signal re : std_logic;

begin

    -- Flip flop used for rising edge detection
    -- Lasts for the clock cycle it takes x to be pushed to d
    --
    d <= x when rising_edge(clk);
    re <= not d and x;

    -- Writes the next stat to the current state, includes asynchronous reset
    process (clk, reset)
    begin
        -- resets FSM to original state (Operator Input)
        if reset = '1' then
            current_s <= s0;
        elsif rising_edge(clk) then
            current_s <= next_s;
        end if;
    end process;
    
    process (clk, current_s, x)
    begin
            -- Changes state depending on input rising edge
            -- If not on a rising edge then state remains the same
            case current_s is
                when s0 =>
                    if re = '1' then
                        y <= "0010";
                        next_s <= s1;
                    else
                        y <= "0001";
                        next_s <= s0;
                    end if;
                when s1 =>
                    if re = '1' then
                        y <= "0100";
                        next_s <= s2;
                    else
                        y <= "0010";
                        next_s <= s1;
                    end if;
                when s2 =>
                    if re = '1' then
                        y <= "1000";
                        next_s <= s3;
                    else
                        y <= "0100";
                        next_s <= s2;
                    end if;
                when s3 =>
                    if re = '1' then
                        y <= "0001";
                        next_s <= s0;
                    else
                        y <= "1000";
                        next_s <= s3;
                    end if;
                end case;
    end process;

end Behavioral;
