
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.tpu_constants.all;

entity top_tb is
--  Port ( );
end top_tb;

architecture Behavioral of top_tb is
    Component reg16_8 Port (I_clk : in std_logic;
         I_en: in std_logic;
         I_we: in std_logic;
         I_dataD: in std_logic_vector(15 downto 0);
         O_dataA: out std_logic_vector(15 downto 0);
         O_dataB: out std_logic_vector(15 downto 0);
         I_selA: in std_logic_vector(2 downto 0);
         I_selB: in std_logic_vector(2 downto 0);
         I_selD: in std_logic_vector(2 downto 0));
    end Component;
    
    Component decoder Port(I_clk: in std_logic;
         I_en: in std_logic;
         I_dataInst: in std_logic_vector(15 downto 0);
         O_selA: out std_logic_vector(2 downto 0);
         O_selB : out std_logic_vector(2 downto 0);
         O_selD: out std_logic_vector(2 downto 0);
         O_dataIMM: out std_logic_vector(15 downto 0);
         O_regDwe: out std_logic;
         O_aluop: out std_logic_vector(4 downto 0));
    end Component;
    
    Component ram Port(  I_clk: in std_logic;
          I_addr: in std_logic_vector (15 downto 0);
          I_we: in std_logic;
          I_data: in std_logic_vector(15 downto 0);
          O_data: out std_logic_vector(15 downto 0));
    end Component;
    
    Component alu port(I_en: in std_logic;
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
    end Component;
    
    -- Signal declarations
    signal I_clk          : std_logic := '0'; -- clk signal going to every unit
    signal en             : std_logic := '0'; -- en signal that goes to every unit's en input
    signal instruction    : std_logic_vector(15 downto 0) := (others => '0'); -- instruction that will come from the memory
    signal selA           : std_logic_vector(2 downto 0) := (others => '0'); -- selection input that goes into the register bank for register A
    signal selB           : std_logic_vector(2 downto 0) := (others => '0'); -- selection input that goes into register bank for selecting the register B value
    signal selD           : std_logic_vector(2 downto 0) := (others => '0'); -- selection bit for which register should the I_dataD should be stored
    signal dataIMM        : std_logic_vector(15 downto 0) := (others => '0'); -- immediate value of the data
    signal dataDwe        : std_logic := '0'; -- Bit that indicates where Input data in I_dataD must be writed to one of the register in the register bank
    signal aluop          : std_logic_vector(4 downto 0) := (others => '0'); -- signal that should be connected to aluOP that comes out of decoder
    signal dataA          : std_logic_vector(15 downto 0) := (others => '0'); -- signal that should be connected to the dataA register of Register Bank
    signal dataB          : std_logic_vector(15 downto 0) := (others => '0'); -- signal that should be connected to the dataB register of Register Bank
    signal PC             : std_logic_vector(15 downto 0) := (others => '0'); -- program counter value that comes out from the ALU
    signal dataWriteReg   : std_logic := '0';
    signal dataResult     : std_logic_vector(15 downto 0) := (others => '0'); -- result of ALU operation
    
    signal shouldBranch   : std_logic;
    
    
    constant I_clk_period:time := 20 ns;
begin
    uut_decoder: decoder 
                    Port Map(I_clk => I_clk,
                             I_en => en,
                             I_dataInst => instruction,
                             O_selA => selA,
                             O_selB => selB,
                             O_selD => selD,
                             O_dataIMM => dataIMM,
                             O_regDwe => dataDwe,
                             O_aluop => aluop);
    uut_alu: alu
                Port Map (I_en => en,
                          I_clk => I_clk,
                          I_dataA =>  dataA,
                          I_dataB => dataB,
                          I_dataDwe => dataDwe,
                          I_aluop => aluop,
                          I_PC => PC,
                          I_dataIMM =>dataIMM, 
                          O_dataResult => dataResult,
                          O_dataWriteReg => dataWriteReg,
                          O_shouldBranch => shouldBranch);
                          
     uut_reg: reg16_8
                 Port Map (I_clk => I_clk,
                           I_en => '1',
                           I_we => dataWriteReg,
                           I_dataD => dataResult,
                           O_dataA => dataA,
                           O_dataB => dataB,
                           I_selA => selA,
                           I_selB => selB,
                           I_selD => selD);
           
           
     stimulus_clk:process
     begin
     while True loop
        I_clk <= '0';
        wait for I_clk_period/2;
        I_clk <= '1';
        wait for I_clk_period/2;
        end loop;
        end process;
                           
     stimulus:process
     begin
        --hold reset state for 100ns
        wait for 100ns;
        
        wait for I_clk_period*10;
        en <= '1';
        
        --load.h r0,0xfe
        instruction <= OPCODE_LOAD  & "000" & '0' & X"fe";
        wait for I_clk_period;
        wait for I_clk_period;
        
        --load.l r1,0xed
        instruction <= OPCODE_LOAD & "001" & '1' & X"ed";
        wait for I_clk_period;
        wait for I_clk_period;
        
        --or r2,r0,r1
        instruction <= OPCODE_OR & "010" & '0' & "000" & "001" & "00";
        wait for I_clk_period;
        wait for I_clk_period;
        
        --load.l r3,1
        instruction <= OPCODE_LOAD & "011" & '1' & X"01";
        wait for I_clk_period;
        wait for I_clk_period;
        
        --load.l r4,2
        instruction <= OPCODE_LOAD & "100" & '1' & X"02";
        wait for I_clk_period;
        wait for I_clk_period;
        
        --add.u r3,r3,r4
        instruction <= OPCODE_ADD & "011" & '0' & "011" & "100" & "00";
        wait for I_clk_period;
        wait for I_clk_period;
        wait;
        
        

     end process;
end Behavioral;
