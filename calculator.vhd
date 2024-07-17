----------------------------------------------------------------------------------
-- Design Name: calculator
-- Module Name: calculator Top - Behavioral
-- Project Name: calculator 
-- Group Number: 21
-- Creators: BOURKE Jordan, WILSON Conor, YAMAMOTO Haruka
-- Description: This VHDL program is a calculator. It takes two twelve bit numbers and allows for arithmetic to occur between them.
--              The possible operations to perform on these two operands are addition, subtraction, multiplication and exponents (operand1 ^ operand2).
--              Firstly, the operation is inputted by switching the switches furthest to the right with the furthest right switch being 
--              the least significant bit, and is encoded via a 2 bit number where;
--                  00 = addition
--                  01 = subtraction
--                  10 = multiplication
--                  11 = exponents (x ^ y)
--              This operation is confirmed by pressing the center button on the Artix7 board.
--              The first operand is then entered in a similar fashion to the operation but instead, a 12 bit number can be inputted with              
--              the right most switch being the least significant bit. This operand is then confirmed by pressing the center button the Artix7 board.
--              The second operand can then be inputted in the same manner as the first.
--              To get the result, the center button is to be pressed and the display will show the result of the operation between the two operands.
--              The states in which the calculator is in can be seen via the leds above the furthest right switches where;
--                  LED furthest right = operation input
--                  LED 1 from right = operand 1
--                  LED 2 from right = operand 2
--                  LED 3 from right = result
--              To input a new equation once a result has been obtained, press the center button again and the calculator will return to "operation input"
----------------------------------------------------------------------------------

-- imported libraries
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- Main entity for structural program, all inputs and outputs for the calculator are set up (peripherals)
entity calculator is 
    port (
        CLK100MHZ : in std_logic;
        CA : out std_logic;
        CB : out std_logic;
        CC : out std_logic;
        CD : out std_logic;
        CE : out std_logic;
        CF : out std_logic;
        CG : out std_logic;
        AN : out std_logic_vector(7 downto 0);
        BTNC : in std_logic;
        SW : in std_logic_vector(15 downto 0);
        LED : out std_logic_vector(15 downto 0)
    );
end calculator;

architecture Behavioral of calculator is

-- All components are set up with relevant generic values, additional informaiton about each component can be found in its respect file
component clock_divider is
    generic (
        INPUT_FREQUENCY  : integer := 100000000; -- Input clock frequency (100 MHz)
        OUTPUT_FREQUENCY : integer := 2);
    port (
        in_clock  : in std_logic;
        enable : in std_logic;
        out_clock : out std_logic);
end component;

component counter is
    generic (
        MAX_COUNT  : integer := 9);
    port (
        clk      : in std_logic;
        count    : out std_logic_vector (2 downto 0);
        overflow : out std_logic);
end component;

component display_multiplexer is
    port (
        enable : in std_logic;
        sel : in std_logic_vector(2 downto 0);
        digits : in std_logic_vector(31 downto 0);
        
        num_out : out std_logic_vector(3 downto 0);
        screen : out std_logic_vector(7 downto 0)
    );
end component;

component seven_segment_decoder is
    port ( 
        bcd_in: in std_logic_vector (3 downto 0);
        leds_out: out std_logic_vector (1 to 7)
    );
end component;

component switch_debouncer is
    generic (
        N_On  : integer := 3;
        N_Off  : integer := 5
    );
    port (
        clk : in std_logic;
        input : in std_logic;
        
        output : out std_logic
    );
end component;

component finite_state_machine is
    port (
        clk : in std_logic;
        reset : in std_logic;
        x : in std_logic;
        
        y : out std_logic_vector(3 downto 0)
    );
end component;

component adjustable_register is
    generic (
        REGISTER_SIZE : integer := 12
    );
    port ( 
        clk: in std_logic;
        reset: in std_logic;
        enable : in std_logic;
        input : in std_logic_vector (REGISTER_SIZE-1 downto 0);
        
        output : out std_logic_vector (REGISTER_SIZE-1 downto 0)
    );
end component;

component arithmetic_logic_unit is
    generic (
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
end component;

component bin_to_bcd is
    generic (
        BCD_SIZE : integer := 32; --! Length of BCD signal
        NUM_SIZE : integer := 24; --! Length of binary input
        NUM_SEGS : integer := 8;  --! Number of segments
        SEG_SIZE : integer := 4   --! Vector size for each segment
    );
    port (
        reset : in std_logic;                                --! Asynchronous reset
        clock : in std_logic;                                --! System clock
        start : in std_logic;                                --! Assert to start conversion
        bin   : in std_logic_vector(NUM_SIZE - 1 downto 0);  --! Binary input
        bcd   : out std_logic_vector(BCD_SIZE - 1 downto 0); --! Binary coded decimal output
        ready : out std_logic                                --! Asserted once conversion is finished
    );
end component;

component register_multiplexer is
    port (
        enable : in std_logic;
        sel : in std_logic_vector(3 downto 0);
        operand_one: in std_logic_vector(11 downto 0);
        operand_two: in std_logic_vector(11 downto 0);
        result: in std_logic_vector(23 downto 0);
        
        neg_flag : out std_logic;
        num_out : out std_logic_vector(23 downto 0)
    );
end component;

component screen_input_multiplexer is
    port 
    (
        sel : in std_logic_vector (1 downto 0);
        opcode : in std_logic_vector (1 downto 0);
        digits : in std_logic_vector (31 downto 0);
        neg_flag : in std_logic;
           
        screen_info : out std_logic_vector (31 downto 0)
    );
end component;

    -- Clock divider signals for general logic, button polling, and screen updating respectfully
    signal system_hz : std_logic;
    signal button_hz : std_logic;
    signal screen_hz : std_logic;
    
    -- Carries the output of the switch debouncer
    signal enter : std_logic;
    
    -- The FSM output, one-hot with 4 states, 0001, 0010, 0100, 1000
    signal state : std_logic_vector(3 downto 0);
    
    -- The following are the outputs of the 4 registers
    signal operand_one : std_logic_vector(11 downto 0);
    signal opcode : std_logic_vector(1 downto 0);
    signal operand_two : std_logic_vector(11 downto 0);
    signal result : std_logic_vector(23 downto 0);
    
    -- Carries the result of the ALU to a register
    signal answer : std_logic_vector(23 downto 0);
    
    -- Carries register values from a multiplexer to the bin to bcd
    signal data : std_logic_vector(23 downto 0);
    
    -- Carries bin to bcd output into multiplexer
    signal screen_bcd : std_logic_vector(31 downto 0);
    
    -- Carries multiplexer output into the displaying section
    signal screen_data : std_logic_vector(31 downto 0);
    
    -- Counter iterates through 7-segment display digits
    signal screen_count : std_logic_vector(2 downto 0);
    
    -- Carries the current digit to be written to the specified display digit
    signal display_num : std_logic_vector(3 downto 0);
    
    -- Error flag, commmunicates that an error screen should be displayed
    signal error : std_logic;
    
    -- Negative flag, communicates whether a negative sign should be displayed
    signal neg_flag : std_logic;
    
    -- Resets all components with a reset input when high
    signal reset : std_logic;
    
    --Enables when bin to bcd finishes, redundant in current program
    signal ready : std_logic;
    
    -- Carry flag for the counter, redundant in current program
    signal carry : std_logic;
    
    
    
    
    
    
    
begin

-- State displayed on the 4 rightmost LEDs
LED(3 downto 0) <= state;

-- State of button displayed on left most LED
LED(15) <= enter;

-- Resetting the calculator is performed by turning on the leftmost switch
reset <= SW(15);


-- Three clock dividers for general logic, button polling, and screen updating
system_clock: clock_divider 
                        generic map (
                            INPUT_FREQUENCY => 100000000,
                            OUTPUT_FREQUENCY => 10000
                        )
                        port map (
                            in_clock => CLK100MHZ,
                            enable => '1',
                            out_clock => system_hz
                        ); 

button_poll: clock_divider 
                        generic map (
                            INPUT_FREQUENCY => 100000000,
                            OUTPUT_FREQUENCY => 100
                        )
                        port map (
                            in_clock => CLK100MHZ,
                            enable => '1',
                            out_clock => button_hz
                        ); 

-- 800Hz/8 Digits = 100Hz update rate per digit, thus no flickering         
screen_clock: clock_divider 
                        generic map (
                            INPUT_FREQUENCY => 100000000,
                            OUTPUT_FREQUENCY => 800
                        )
                        port map (
                            in_clock => CLK100MHZ,
                            enable => '1',
                            out_clock => screen_hz
                        ); 

-- Stops noise in button output
enter_button: switch_debouncer 
                        port map (
                            clk => button_hz,
                            input => BTNC,
                            output => enter
                        );

-- FSM controls main functionallity, iterates through state from button presses
FSM: finite_state_machine 
                        port map (
                            x => enter,
                            y => state,
                            reset => reset,
                            clk => system_hz
                        );

-- Four registers for storing the two operands, the opcode, and the result
-- Operands and opcode come from the switches and the result comes from the ALU output
-- Values reset when reset switch is pressed
-- Each register is only enabled when the in relevant state
register_A: adjustable_register 
                        port map (
                            clk => system_hz,
                            enable => state(0),
                            reset => reset,
                            input => SW(11 downto 0),
                            
                            output => operand_one
                        );

register_opcode: adjustable_register 
                        generic map ( 
                            REGISTER_SIZE => 2
                        )
                        port map (
                            clk => system_hz,
                            enable => state(1),
                            reset => reset,
                            input => SW(1 downto 0),
                            output => opcode
                        );

register_B: adjustable_register 
                        port map (
                            clk => system_hz,
                            enable => state(2),
                            reset => reset,
                            input => SW(11 downto 0),
                            output => operand_two
                        );

register_result: adjustable_register 
                        generic map ( 
                            REGISTER_SIZE => 24
                        )
                        port map (
                            clk => system_hz,
                            enable => state(3),
                            reset => reset,
                            input => result,
                            output => answer
                        );

-- ALU only runs when the result state of the FSM
arithmatic_unit: arithmetic_logic_unit
                        port map (
                            clk => system_hz,
                            enable => state(3),
                            operation => opcode,
                            A => operand_one,
                            B => operand_two,
                            error => error,
                            result => result
                        );

-- Multiplexes which register is fed into the bin to bcd converter based on the state, always enabled
register_switcher: register_multiplexer 
                        port map (
                            enable => '1',
                            sel => state,
                            operand_one => operand_one,
                            operand_two => operand_two,
                            result => answer,
                            neg_flag => neg_flag,
                            num_out => data
                        );

-- Converts a register held number into bcd
b_to_bcd: bin_to_bcd 
                        port map (
                            reset => reset,
                            clock => system_hz,
                            start => '0',
                            bin => data,
                            bcd => screen_bcd,
                            ready => ready
                        );

-- Multiplexes what information will displayed, options are: BCD for a register, an error message, or opcode
data_display_mux: screen_input_multiplexer 
                        port map ( 
                            neg_flag => neg_flag,
                            sel(0) => state(1),
                            sel(1) => error,
                            opcode => opcode,
                            digits => screen_bcd,
                            screen_info => screen_data
                        );

-- Counter used to strobe through the digits of the display, creating the appearance they are all on at once
screen_counter: counter 
                        generic map (
                            MAX_COUNT => 7
                        )
                        port map (
                            clk => screen_hz,
                            count => screen_count,
                            overflow => carry
                        );

-- Changes which digit is displayed on what informaiton it is fed, all data inputted as one long std_logic_vector
num_selector: display_multiplexer 
                        port map (
                            enable => '1',
                            sel => screen_count,
                            digits => screen_data,
                            num_out => display_num,
                            screen => AN
                        );

-- Converts BCD to which segments should be lit up, inaddition to numbers it can display: -, E, and r
decoder: seven_segment_decoder 
                        port map(
                            bcd_in => display_num,
                            leds_out(1) => CA,
                            leds_out(2) => CB,
                            leds_out(3) => CC,
                            leds_out(4) => CD,
                            leds_out(5) => CE,
                            leds_out(6) => CF,
                            leds_out(7) => CG
                        );

end Behavioral;

