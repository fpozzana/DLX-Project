library IEEE;
use IEEE.std_logic_1164.all;
use WORK.globals.all;

entity TB_WRITE_BACK_STAGE is
end TB_WRITE_BACK_STAGE;

architecture TEST of TB_WRITE_BACK_STAGE is

  constant NBIT : integer := RISC_BIT;
  signal TB_LMD : std_logic_vector(NBIT-1 downto 0);
  signal TB_ALU_OUT : std_logic_vector(NBIT-1 downto 0);
  signal TB_CONTROL : std_logic;
  signal TB_WB_OUT : std_logic_vector(NBIT-1 downto 0);
  signal TB_RD_IN : std_logic_vector(4 downto 0) := "00111";
  signal TB_RD_OUT : std_logic_vector(4 downto 0);
  signal TB_JAL_SEL : std_logic := '0';

  component WRITE_BACK_STAGE
  generic(N : integer := RISC_BIT);
  port(LMD : IN std_logic_vector(N-1 downto 0);
      ALUOUT : IN std_logic_vector(N-1 downto 0);
      RD_IN : IN std_logic_vector(4 downto 0);
      CONTROL : IN std_logic;
      JAL_SEL : IN std_logic;
      RD_OUT : OUT std_logic_vector(4 downto 0);
      WB_OUT : OUT std_logic_vector(N-1 downto 0));
  end component;

  begin
    DUT : WRITE_BACK_STAGE
    generic map(NBIT)
    port map(TB_LMD,TB_ALU_OUT,TB_RD_IN,TB_CONTROL,TB_JAL_SEL,TB_RD_OUT,TB_WB_OUT);

    TB_LMD <= "00001111000011110000111100001111";
    TB_ALU_OUT <= "11110000111100001111000011110000";
    TB_CONTROL <= '0', '1' after 5 ns;
    TB_JAL_SEL <= '1' after 20 ns;

end TEST;

configuration CFG_TB_WRITE_BACK_STAGE of TB_WRITE_BACK_STAGE is
  for TEST
    for DUT : WRITE_BACK_STAGE
      use configuration WORK.CFG_WRITE_BACK_STAGE;
    end for;
  end for;
end CFG_TB_WRITE_BACK_STAGE;
