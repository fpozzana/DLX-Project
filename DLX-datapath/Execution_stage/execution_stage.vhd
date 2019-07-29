--test : tested OK, the component works as expected
--during the risign clock the register samlples according to what
--has been provided before the rise of clock
--eg: at 2 ns clock rises, the sampled value which goes into execution stage out
--depends on which inputs the execution stage had right before the
--2 ns mark, even if at 2 ns the inputs change

library ieee;
use ieee.std_logic_1164.all;
use WORK.constants.all;

entity EXECUTION_STAGE is
  generic(numbit : integer := RISC_BIT);
  port(npc_in : IN std_logic_vector(numbit-1 downto 0);
       a_reg_in : IN std_logic_vector(numbit-1 downto 0);
       b_reg_in : IN std_logic_vector(numbit-1 downto 0);
       imm_reg_in : IN std_logic_vector(numbit-1 downto 0);
       mux_one_control : IN std_logic;
       mux_two_control : IN std_logic;
       alu_control : IN std_logic_vector(3 downto 0);
       clk : IN std_logic;
       reset : IN std_logic;
       execution_stage_out : OUT std_logic_vector(numbit-1 downto 0);
       branch_condition_out : OUT std_logic);
end EXECUTION_STAGE;

architecture STRUCTURAL of EXECUTION_STAGE is

  signal mux_one_out : std_logic_vector(numbit-1 downto 0);
  signal mux_two_out : std_logic_vector(numbit-1 downto 0);
  signal alu_out : std_logic_vector(numbit-1 downto 0);
  signal zero_comp : std_logic_vector(numbit-1 downto 0) := (others => '0');
  signal comparator_out : std_logic;

  component MUX21_GENERIC
  generic (NBIT : integer := NumBitMux21);
  port(A : IN std_logic_vector(NBIT-1 downto 0);
       B : IN std_logic_vector(NBIT-1 downto 0);
       SEL : IN std_logic;
       Y : OUT std_logic_vector(NBIT-1 downto 0));
  end component;

  component COMPARATOR_GENERIC
  generic(numbit : integer := NumBitComparator);
  port(A : IN std_logic_vector(numbit-1 downto 0);
       B : IN std_logic_vector(numbit-1 downto 0);
       less : OUT std_logic;
       more : OUT std_logic;
       equal : OUT std_logic);
  end component;

  component REGISTER_GENERIC
  generic (NBIT : integer := NumBitRegister);
  port(
    D : IN std_logic_vector(NBIT-1 downto 0);
    CK : IN std_logic;
    RESET : IN std_logic;
    Q : OUT std_logic_vector(NBIT-1 downto 0));
  end component;

  component ALU_BEHAVIORAL
  generic (NBIT : integer := NumBitALU);
  port 	 ( FUNC: IN std_logic_vector(3 downto 0);
           DATA1, DATA2: IN std_logic_vector(NBIT-1 downto 0);
           OUTALU: OUT std_logic_vector(NBIT-1 downto 0));
  end component;

  component FD
  Port (	D :	IN	std_logic;
					CK :	IN	std_logic;
					RESET :	IN	std_logic;
					Q :	OUT	std_logic);
  end component;

  begin

    MUX_ONE : MUX21_GENERIC
    generic map(numbit)
    port map(npc_in,a_reg_in,mux_one_control,mux_one_out);

    MUX_TWO : MUX21_GENERIC
    generic map(numbit)
    port map(b_reg_in,imm_reg_in,mux_two_control,mux_two_out);

    ALU : ALU_BEHAVIORAL
    generic map(numbit)
    port map(alu_control,mux_one_out,mux_two_out,alu_out);

    REG1 : REGISTER_GENERIC
    generic map(numbit)
    port map(alu_out,clk,reset,execution_stage_out);

    COMP : COMPARATOR_GENERIC
    generic map(numbit)
    port map(a_reg_in,zero_comp,open,open,comparator_out);

    REG2 : FD
    port map(comparator_out,clk,reset,branch_condition_out);

end STRUCTURAL;

configuration CFG_EXECUTION_STAGE_STRUCTURAL of EXECUTION_STAGE is
	for STRUCTURAL
    for all : MUX21_GENERIC
		  use configuration WORK.CFG_MUX21_GENERIC_STRUCTURAL;
    end for;
    for all : ALU_BEHAVIORAL
		  use configuration WORK.CFG_ALU_BEHAVIORAL;
    end for;
    for all : REGISTER_GENERIC
		  use configuration WORK.CFG_REGISTER_GENERIC_STRUCTURAL_SYNC;
    end for;
    for all : COMPARATOR_GENERIC
      use configuration WORK.CFG_COMPARATOR_GENERIC;
    end for;
    for all : FD
      use configuration WORK.CFG_FD_SYNC;
    end for;
	end for;
end CFG_EXECUTION_STAGE_STRUCTURAL;