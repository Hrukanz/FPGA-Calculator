----------------------------------------------------------------------------------
-- Design Name: FSM_tb
-- Module Name: FSM_tb 
-- Project Name: calculator 
-- Group Number: 21
-- Creators: BOURKE Jordan, WILSON Conor, YAMAMOTO Haruka
-- Description: test bench used to test operation of the finite state machine
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FSM_tb is
--  Port ( );
end FSM_tb;

architecture Behavioral of FSM_tb is

component finite_state_machine
    Port ( x : in STD_LOGIC;
           y : out STD_LOGIC_VECTOR(3 downto 0);
           reset : in STD_LOGIC;
           clk : in STD_LOGIC);
end component;

    -- Input and output signals for the testbench
    signal x : std_logic := '0';
    signal y : std_logic_vector(3 downto 0);
    signal reset : std_logic := '1';
    signal clk : std_logic := '0';

begin

UUT: finite_state_machine port map ( x => x, y => y, reset => reset, clk => clk);

 -- we need a clock process, so define one, in addition to some clock delays
 clk_process : process
  begin
   clk <= '1', '0' after 10 ns, '1' after 20 ns, '0' after 30 ns;
   wait for 40 ns;
  end process clk_process;
   
 -- stimulus process for test data   
 io_process : process
  begin  
  -- test the output y for 1, 2, 4, and 8
   reset <= '0';
   x <= '0';
   wait for 20 ns;
   x <= '1';
   wait for 20 ns;
   x <= '0';
   wait for 20 ns;
   x <= '1';
   wait for 20 ns;
   x <= '0';
   wait for 20 ns;
   x <= '1';
   wait for 20 ns;
   x <= '0';
   wait for 20 ns;
   x <= '1';
   wait for 20 ns;
   -- test reset 
   reset <= '1';
   x <= '0';
   wait for 20 ns;
   x <= '1';
   wait for 20 ns;
   
  
  
  end process io_process; 
  
end Behavioral;
