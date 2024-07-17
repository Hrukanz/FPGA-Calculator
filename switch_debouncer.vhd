----------------------------------------------------------------------------------
-- Design Name: switch_debouncer
-- Module Name: switch_debouncer - Behavioral
-- Project Name: calculator 
-- Group Number: 21
-- Creators: BOURKE Jordan, WILSON Conor, YAMAMOTO Haruka
-- Description: A debouncer to ensure that each button press is detected as only one
--              Clock input is used to poll the input value, when the input has remained
--              high for N_On polls then the output is enabled, when the input as remained
--              low for N_Off polls then the output is disabled, these values and the poll
--              rate must be tuned
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;


entity switch_debouncer is
    generic (
        N_On  : integer := 100;
        N_Off  : integer := 200
    );
    port (
        clk : in std_logic;
        input : in std_logic;
        
        output : out std_logic
    );
end switch_debouncer;

architecture Behavioral of switch_debouncer is

    -- The state the button is in, high or low
    signal state : std_logic := '0';

begin
    process (clk)
        
        -- Counts the number of cycles the input has remained unchanged
        variable samples : integer := 0;
    begin
        if rising_edge(clk) then
            
            -- Samples is increased if the input differs from the state, otherwise is reset
            if ((state = '0' and input = '1') or
                (state = '1' and input = '0')) then
                samples := samples + 1;
            else
                samples := 0;
            end if;
            
            -- State is changed if samples are higher than the set boundaries
            if state = '1' and samples >= N_Off then
                state <= '0';
                samples := 0;
            elsif state = '0' and samples >= N_On then
                state <= '1';
                samples := 0;
            end if;
        end if;
    end process;
    
    -- the output is always equal to the state
    output <= state;
    
end Behavioral;
