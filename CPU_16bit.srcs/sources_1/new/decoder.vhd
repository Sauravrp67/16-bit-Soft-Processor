library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity decoder is
  Port ( I_clk: in std_logic;
         I_en: in std_logic;
         I_dataInst: in std_logic_vector(15 downto 0);
         O_selA: out std_logic_vector(2 downto 0);
         O_selB : out std_logic_vector(2 downto 0);
         O_selD: out std_logic_vector(2 downto 0);
         O_dataIMM: out std_logic_vector(15 downto 0);
         O_regDwe: out std_logic;
         O_aluop: out std_logic_vector(4 downto 0));
end decoder;

architecture Behavioral of decoder is

begin
    process(I_clk)
        begin
            if rising_edge (I_clk) then 
                if I_en = '1' then
                -- Defining the output logic for the decoder
                O_selA <= I_dataInst(7 downto 5);
                O_selB <= I_dataInst(4 downto 2);
                O_selD <= I_dataInst(11 downto 9);
                O_dataIMM <= I_dataInst(7 downto 0) & I_dataInst(7 downto 0);
                O_aluop <= I_dataInst(15 downto 12) & I_dataInst(8);
                
                --defining when there should be register write based on the operation performed by the ISA we defined.
                case I_dataInst(15 downto 12) is
                    when "0111" => O_regDwe <= '0'; --write to memory, source register where data is stored and R where address of the memory cell is stored.
                    when "1100" => O_regDwe <= '0'; -- JUMP either immediately or based on value of rD
                    when "1101" => O_regDwe <= '0'; -- Jump conditional
                    when others =>
                    O_regDwe <= '1';
                end case;
                else
                    -- When not enabled, default the outputs
                    O_selA <= (others => '0');
                    O_selB <= (others => '0');
                    O_selD <= (others => '0');
                    O_dataIMM <= (others => '0');
                    O_regDwe <= '0';
                    O_aluop <= (others => '0');
                end if;
                end if;
             end process;
end Behavioral;
