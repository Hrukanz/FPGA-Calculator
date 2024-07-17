----------------------------------------------------------------------------------
-- Design Name: adjustable_register
-- Module Name: adjustable_register - Behavioral
-- Project Name: calculator 
-- Group Number: 21
-- Creators: BOURKE Jordan, WILSON Conor, YAMAMOTO Haruka
-- Description: A simple register with an adjustable bit size determined by the generic REGISTER_SIZE
--              Has as an enable and an asynchronous reset
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity adjustable_register is
    generic (
        REGISTER_SIZE : integer := 12
    );
    port ( 
        clk: in std_logic;
        enable : in std_logic;
        reset: in std_logic;
        input : in std_logic_vector (REGISTER_SIZE-1 downto 0);
        
        output : out std_logic_vector (REGISTER_SIZE-1 downto 0)
    );
end adjustable_register;

architecture Behavioral of adjustable_register is

begin
    full_register : process (enable, reset) 
        begin
            -- Register cleared on asynchronous reset
            if (reset = '1') then
                output <= std_logic_vector(to_unsigned(0, REGISTER_SIZE));
            -- Stored in rising edges when enabled
            elsif rising_edge(clk) then
                if (enable = '1') then
                    output <= input;
                end if;
            end if;
        end process full_register;
end Behavioral;
