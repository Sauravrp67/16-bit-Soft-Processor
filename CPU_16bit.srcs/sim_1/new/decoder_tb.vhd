library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity decoder_tb is
end decoder_tb;

architecture Behavioral of decoder_tb is
  -- Component declaration for the Unit Under Test (UUT)
  component decoder
    Port (
      I_clk : in std_logic;
      I_en : in std_logic;
      I_dataInst : in std_logic_vector(15 downto 0);
      O_selA : out std_logic_vector(2 downto 0);
      O_selB : out std_logic_vector(2 downto 0);
      O_selD : out std_logic_vector(2 downto 0);
      O_dataIMM : out std_logic_vector(15 downto 0);
      O_regDwe : out std_logic;
      O_aluop : out std_logic_vector(4 downto 0)
    );
  end component;

  -- Signals to connect to the UUT
  signal I_clk_tb : std_logic := '0';
  signal I_en_tb : std_logic := '0';
  signal I_dataInst_tb : std_logic_vector(15 downto 0) := (others => '0');
  signal O_selA_tb : std_logic_vector(2 downto 0);
  signal O_selB_tb : std_logic_vector(2 downto 0);
  signal O_selD_tb : std_logic_vector(2 downto 0);
  signal O_dataIMM_tb : std_logic_vector(15 downto 0);
  signal O_regDwe_tb : std_logic;
  signal O_aluop_tb : std_logic_vector(4 downto 0);

  constant clk_period : time := 10 ns;
begin
  -- Instantiate the Unit Under Test (UUT)
  uut: decoder
    Port map (
      I_clk => I_clk_tb,
      I_en => I_en_tb,
      I_dataInst => I_dataInst_tb,
      O_selA => O_selA_tb,
      O_selB => O_selB_tb,
      O_selD => O_selD_tb,
      O_dataIMM => O_dataIMM_tb,
      O_regDwe => O_regDwe_tb,
      O_aluop => O_aluop_tb
    );

  -- Clock process definitions
  clk_process: process
  begin
    while True loop
      I_clk_tb <= '0';
      wait for clk_period / 2;
      I_clk_tb <= '1';
      wait for clk_period / 2;
    end loop;
  end process;

  -- Stimulus process
  stim_proc: process
  begin
    -- Initialize Inputs
    I_en_tb <= '0';
    I_dataInst_tb <= (others => '0');
    wait for 20 ns;

    -- Apply test stimulus
    I_en_tb <= '1';
    I_dataInst_tb <= "0111001010010011"; -- Example instruction
    wait for clk_period;

    I_dataInst_tb <= "1100011001100110"; -- Example instruction for Jump
    wait for clk_period;

    I_dataInst_tb <= "1101010101010101"; -- Example instruction for Jump conditional
    wait for clk_period;

    I_dataInst_tb <= "0000111100001111"; -- Example instruction for ALU operation
    wait for clk_period;

    -- Disable the decoder
    I_en_tb <= '0';
    I_dataInst_tb <= (others => '0');
    wait for 20 ns;

    -- End simulation
    wait;
  end process;
end Behavioral;
