----------------------------------------------------------------------------------
-- Design Name: arithmetic_logic_unit
-- Module Name: arithmetic_logic_unit - Behavioral
-- Project Name: calculator 
-- Group Number: 21
-- Creators: BOURKE Jordan, WILSON Conor, YAMAMOTO Haruka
-- Description: An arithmatic logic unit with addition, subtraction, multiplication and exponents
--              Performs an operation determined by 2 bit opcode on two 12 bit operands to create a 24 bit result
--              A 24 bit result utilises the full display and makes the calculator more powerful, as it has less risk of overflow
--              Has enable line to enable and disable ALU, only enabled when in the state 4, which displays the result
--              There is an error output which displays an error message, occurs on overflow and -ve exponents
--              Exponent function uses clock input and a built in counter to loop multiplication
--              
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity arithmetic_logic_unit is
    generic (
        -- Allows for a variable input size, will always output a result double the input size
        BIT_SIZE  : integer := 12
    );
    port (
        clk : in std_logic;
        enable : in std_logic;
        operation : in std_logic_vector (1 downto 0);
        A : in std_logic_vector (BIT_SIZE-1 downto 0);
        B : in std_logic_vector (BIT_SIZE-1 downto 0);
        
        error : out std_logic;
        result : out std_logic_vector (BIT_SIZE*2-1 downto 0)
    );
end arithmetic_logic_unit;

architecture Behavioral of arithmetic_logic_unit is

    signal answer : std_logic_vector (BIT_SIZE*2-1 downto 0);

begin

    process (operation, A, B, clk) is
    
        -- counter used to track how many times the base of an exponent has been multiplied by itself
        variable counter : integer := 0;
        variable power_sum : integer := 0;
    begin
        -- Clock required for running the exponential function, to iterate multiplication
        if rising_edge(clk) then
            
            -- Only enabled in state 3, as calculation not required for any other states
            if enable = '1' then
                case operation is
                    
                    -- Multiply, Add, and Sub all convert operands to integers, perform operation and then convert back to std_logic_vector
                    when "00" => 
                        answer <= std_logic_vector(to_signed((to_integer(signed(A)) + to_integer(signed(B))), BIT_SIZE*2));
                    when "01" => 
                        answer <= std_logic_vector(to_signed((to_integer(signed(A)) - to_integer(signed(B))), BIT_SIZE*2));
                    when "10" => 
                        answer <= std_logic_vector(to_signed((to_integer(signed(A)) * to_integer(signed(B))), BIT_SIZE*2));
                    when "11" => 
                    
                        -- Initiliases the compounding multiple to the base value of the exponent
                        if counter = 0 then
                            power_sum := to_integer(signed(A));
                        end if;
                        
                        -- Edge detection for when exponent = 0, answer always 1
                        if to_integer(signed(B)) = 0 then
                            answer <= X"000001";
                        -- If the exponent is negative or the multiple goes out of the 24 bit integer limits an error is is ouputted
                        elsif power_sum >= 8388607 OR B(BIT_SIZE-1) = '1' OR power_sum <= -8388608 then
                            error <= '1';
                            counter := 0;
                            power_sum := 0;
                        -- Multiple is increased when counter is less than the exponent
                        elsif counter < to_integer(signed(B))-1 then
                            power_sum := power_sum * to_integer(signed(A));
                            counter := counter + 1;
                        -- Answer outputted upon completion of the exponential function
                        else
                            counter := 0;
                            answer <= STD_LOGIC_VECTOR(to_signed(power_sum, BIT_SIZE*2));
                            power_sum := 0;
                        end if;
                end case;
            else
                error <= '0';
            end if;
        end if;
    end process;
    
    result <= answer;

end Behavioral;
