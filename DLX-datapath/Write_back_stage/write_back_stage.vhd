--test : tested OK, the component works as expected
--the write back stage is a simple MUX21 which has as
--inputs LMD and ALUOUT

library IEEE;
use IEEE.std_logic_1164.all;
use WORK.constants.all;

entity WRITE_BACK_STAGE is
  generic(N : integer := RISC_BIT);
  port(LMD : IN std_logic_vector(N-1 downto 0);
      ALUOUT : IN std_logic_vector(N-1 downto 0);
      CONTROL : IN std_logic;
      clock : IN std_logic;
      reset : IN std_logic;
      WB_OUT : OUT std_logic_vector(N-1 downto 0));
end WRITE_BACK_STAGE;

architecture STRUCTURAL of WRITE_BACK_STAGE is

  component MUX21_GENERIC
  generic (NBIT : integer := NumBitMux21);
  port(A : IN std_logic_vector(NBIT-1 downto 0);
       B : IN std_logic_vector(NBIT-1 downto 0);
       SEL : IN std_logic;
       Y : OUT std_logic_vector(NBIT-1 downto 0));
  end component;

  component REGISTER_GENERIC
  generic (NBIT : integer := NumBitRegister);
  port(
    D : IN std_logic_vector(NBIT-1 downto 0);
    CK : IN std_logic;
    RESET : IN std_logic;
    Q : OUT std_logic_vector(NBIT-1 downto 0));
  end component;

  signal mux_out : std_logic_vector(RISC_BIT-1 downto 0);

  begin
    UMUX : MUX21_GENERIC
    generic map(RISC_BIT)
    port map(LMD,ALUOUT,CONTROL,mux_out);

    REG : REGISTER_GENERIC
    generic map(RISC_BIT)
    port map(mux_out,clock,reset,WB_OUT);

end STRUCTURAL;

configuration CFG_WRITE_BACK_STAGE of WRITE_BACK_STAGE is
  for STRUCTURAL
    for UMUX : MUX21_GENERIC
      use configuration WORK.CFG_MUX21_GENERIC_STRUCTURAL;
    end for;
  end for;
end CFG_WRITE_BACK_STAGE;