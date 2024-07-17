----------------------------------------------------------------------------------
-- Design Name: counter
-- Module Name: counter - Behavioral
-- Project Name: calculator 
-- Group Number: 21
-- Creators: BOURKE Jordan, WILSON Conor, YAMAMOTO Haruka
-- Description: Simple adjustable sized counter with an overflow/carry flag.
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter is
    generic (
        MAX_COUNT  : integer := 9);
    port (
        clk      : in std_logic;
        count    : out std_logic_vector (2 downto 0);
        overflow : out std_logic);
end counter;

architecture Behavioral of counter is
begin
    process (clk)
        variable counter : integer range 0 to MAX_COUNT := 0;
    begin
        if rising_edge(clk) then
            if counter = MAX_COUNT then
                -- Reset counter and assert overflow
                counter := 0;
                overflow <= '1';
             ----assert overflow here--
            else
                -- Increment counter and reset overflow
                counter := counter + 1;
                overflow <= '0';
              --reset overflow here---
            end if;

            -- Convert value of counter to std_logic_vector
            count <= std_logic_vector(to_unsigned(counter, count'length));
        end if;
    end process;
end Behavioral;