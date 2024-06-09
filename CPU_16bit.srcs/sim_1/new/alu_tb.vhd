
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.tpu_constants.all;


entity alu_tb is
--  Port ( );
end alu_tb;

architecture Behavioral of alu_tb is
    Component alu Port (I_en: in std_logic;
        I_clk: in std_logic;
        I_dataA: in std_logic_vector(15 downto 0);
        I_dataB: in std_logic_vector(15 downto 0);
        I_dataDwe: in std_logic;
        I_aluop: in std_logic_vector(4 downto 0);
        I_PC: in std_logic_vector(15 downto 0);
        I_dataIMM: in std_logic_vector(15 downto 0);
        O_dataResult: out std_logic_vector(15 downto 0);
        O_dataWriteReg: out std_logic;
        O_shouldBranch: out std_logic );
        
    end component;
    
    signal I_clk_tb : std_logic;
    signal I_en_tb : std_logic;
    signal I_dataA_tb : std_logic_vector(15 downto 0);
    signal I_dataB_tb : std_logic_vector(15 downto 0);
    signal I_dataDwe_tb: std_logic;
    signal I_aluop_tb: std_logic_vector(4 downto 0);
    signal I_PC_tb: std_logic_vector(15 downto 0);
    signal I_dataIMM_tb: std_logic_vector(15 downto 0);
    signal O_dataResult_tb : std_logic_vector(15 downto 0);
    signal O_dataWriteReg_tb: std_logic;
    signal O_shouldBranch_tb :std_logic;
    
    constant clk_period:time := 10ns;
begin
    uut: alu Port Map(I_clk => I_clk_tb,
                      I_en => I_en_tb,
                      I_dataA => I_dataA_tb,
                      I_dataB => I_dataB_tb,
                      I_dataDwe => I_dataDwe_tb,
                      I_aluop => I_aluop_tb,
                      I_PC => I_PC_tb,
                      I_dataIMM => I_dataIMM_tb,
                      O_dataResult => O_dataResult_tb,
                      O_dataWriteReg => O_dataWriteReg_tb,
                      O_shouldBranch => O_shouldBranch_tb);
                      
   clk_process: process
   begin
   while True Loop
        I_clk_tb <= '0';
        wait for clk_period/2;
        I_clk_tb <= '1';
        wait for clk_period/2;
   end loop;
   end process;
   
   stimulus:process
   begin
   -- hold reset state for 1 clock period;
   
   I_en_tb <= '0';
   
   wait for clk_period;
   
   -- enable the alu
   I_en_tb <= '1';
   
   --test for unsigned addition
   I_dataA_tb <= X"0001";
   I_dataB_tb <= X"0001";
   I_dataDwe_tb <= '1';
   I_aluop_tb <= OPCODE_ADD & '0';
   I_dataIMM_tb <= X"F1FA";
   
   wait for clk_period;
   
   --test for unsigned subtraction
   I_dataA_tb <= X"0005";
   I_dataB_tb <= X"0003";
   I_aluop_tb <= OPCODE_SUB & '0';
   wait for clk_period;
   
   --test for comparison unsigned A > B
   I_dataA_tb <= X"FFFF";
   I_dataB_tb <= X"0000";
   I_aluop_tb <= OPCODE_CMP & '0';
   wait for clk_period;  
   
   -- A < B
   I_dataA_tb <= X"0000";
   I_dataB_tb <= X"FFFF";
   I_aluop_tb <= OPCODE_CMP & '0';
   wait for clk_period;
   
   -- A = B
   I_dataA_tb <= X"0001";
   I_dataB_tb <= X"0001";
   I_aluop_tb <= OPCODE_CMP & '0';
   wait for clk_period;
   
   -- A = 0
   I_dataA_tb <= X"0000";
   I_aluop_tb <= OPCODE_CMP & '0';
   wait for clk_period;
   
   -- B = 0
   I_dataB_tb <= X"0000";
   I_aluop_tb <= OPCODE_CMP & '0';
   wait for clk_period;
   
   --test for branching
   
   -- branch if A = B
   I_dataB_tb <= X"FF00";
   I_dataA_tb <= X"4000";
   I_aluop_tb<= OPCODE_JUMPEQ & '0';
   I_dataIMM_tb <= x"0000";
   wait for clk_period;
   
   --signed
   --Addition
   I_dataA_tb <= X"0005";
   I_dataB_tb <= X"FFFE";
   I_aluop_tb <= OPCODE_ADD & '1';
   wait for clk_period;
   
   
   wait for clk_period * 2;
   
   I_en_tb <= '1';
   wait;     
   end process;

end Behavioral;
