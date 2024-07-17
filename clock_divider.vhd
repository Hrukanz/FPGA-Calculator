-- clock_divider.vhd: Configurable clock divider module.
--
-- This VHDL module implements an integer clock divider with an asynchronous
-- enable line. The frequency of the input and output clocks is configurable
-- through generic parameters.
--
-- Written by Blair Bonnett.
-- Version: 1.0
-- Last update: 14 July 2014.

-- We want to use the IEEE libraries.
library ieee;

-- In particular, the standard logic types.
use ieee.std_logic_1164.all;


-- The entity defines what the module looks like (what inputs and outputs it
-- has) but says nothing about how it is implemented.
-- If you are used to C programming, this is equivalent to a header file.
entity clock_divider is
	-- A generic block can be use for parameters which are configurable
	-- per-instance. In other words, you can use this module multiple times in
	-- the same project with different input and output frequencies.
	generic(
		-- The frequency of the input clock in Hertz. The default value of
		-- 50MHz is the speed of the main clock on the Spartan 3 board.
		INPUT_FREQUENCY  : integer := 100000000;

		-- The desired output frequency in Hertz.
		-- Note that the last entry in the generic block does not have trailing semicolon.
		OUTPUT_FREQUENCY : integer :=     1
	);

	-- The port defines the input and output signals.
	port(
		-- The input clock.
		in_clock  : in std_logic;

		-- An asynchronous enable line. If this is low, then the output clock
		-- will be held low.
		enable    : in std_logic;

		-- The output clock.
		-- Note that the last entry in the port block does not have a trailing semicolon.
		out_clock : out std_logic := '0'
	);
end clock_divider;


-- The architecture defines the behaviour of the entity we declared above.
-- In our C analogy, this would be the C file which implements the functions
-- in the header file.
architecture behavioral of clock_divider is

	-- We can define constants and signals at the top of the architecture,
	-- before the 'begin' statement.

	-- Calculate the ratio we need to divide the clock by.
	constant DIVIDER_RATIO : integer := INPUT_FREQUENCY / OUTPUT_FREQUENCY;

	-- To achieve a 50% duty cycle in the output clock, we need to know when we
	-- are halfway through each division.
	constant HALF_DIVIDER  : integer := DIVIDER_RATIO / 2;

	-- Rather than having to specify the bit width of the division counter
    -- ourselves, we can make the synthesiser figure it out. All we need to do is
	-- tell it we want an integer that can handle a certain range of values.
	subtype clockdiv_t is integer range 0 to DIVIDER_RATIO;

	-- The division counter can then be declared as an instance of our custom type.
	signal count : clockdiv_t := 0;
	
-- Start the actual definition.
begin

	-- The process which does the division. You can have as many processes in
	-- an architecture as you want; just remember that they all run concurrently.
	-- The sensitivity list in parentheses declares which signals affect this
	-- process when they change.
	divider : process(in_clock, enable)
	begin
		-- Our enable line is asynchronous, i.e., it happens at any time rather
		-- than being synchronised to a clock edge.
		if enable = '0' then
			out_clock <= '0';
			count <= 0;

		-- All the other logic is synchronous with a rising edge of the input clock.
		-- The clock'event attribute only fires on changes, and we check the
		-- value of the clock to determine the type of edge.
		elsif in_clock'event and in_clock = '1' then
			-- If we have reached the halfway point, set the output high and
			-- keep counting.
			if count = HALF_DIVIDER then
				out_clock <= '1';
				count <= count + 1;

			-- If we have reached the end, pull the output low and reset for
			-- the next cycle.
			elsif count = DIVIDER_RATIO then
				out_clock <= '0';
				count <= 0;

			-- No special values have been reached: continue counting.
			else
				count <= count + 1;
			end if;
		end if;
	end process divider;
end behavioral;
