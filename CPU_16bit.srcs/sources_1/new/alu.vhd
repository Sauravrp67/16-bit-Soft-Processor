
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.tpu_constants.all;


entity alu is
  Port (I_en: in std_logic;
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
end alu;

architecture Behavioral of alu is
-- Internal Register Inside ALU to store the result of operation
-- 16 bit for result and 2 bits for carry/overflow flag
signal s_result: std_logic_vector(17 downto 0) := (others => '0');
signal s_shouldBranch:std_logic := '0';
begin
    process(I_clk,I_en)
    begin
        if rising_edge(I_clk) and I_en = '1' then
        O_dataWriteReg <= I_dataDwe;
        case I_aluop(4 downto 1) is
            -- ADDITION OPCODE
            when OPCODE_ADD =>
               if  I_aluop(0) = '0' then
                   s_result(16 downto 0) <= std_logic_vector(unsigned('0' & I_dataA) + unsigned('0' & I_dataB));
                   -- we are concatenating '0' with I_dataA and similarly for I_dataB, to capture the carry flag if the result of addition is beyond the storing capacity of 16 bit 
               else
                    s_result(16 downto 0) <= std_logic_vector(signed(I_dataA(15) & I_dataA) + signed(I_dataB(15) & I_dataB));
                    -- we are concatenating the LSB with the operand itself to preserve the last bit and capture the overflow flag....
               end if;
               s_shouldBranch <= '0';
               
               
               -- SUB OPCODE
               when OPCODE_SUB =>
                    if  I_aluop(0) = '0' then
                   s_result(16 downto 0) <= std_logic_vector(unsigned('0' & I_dataA) - unsigned('0' & I_dataB));
                   -- we are concatenating '0' with I_dataA and similarly for I_dataB, to capture the carry flag if the result of addition is beyond the storing capacity of 16 bit 
               else
                    s_result(16 downto 0) <= std_logic_vector(signed(I_dataA(15) & I_dataA) - signed(I_dataB(15) & I_dataB));
               
               end if;
               s_shouldBranch <= '0';
               -- OR OPCODE
               when OPCODE_OR =>
                        s_result(15 downto 0) <= I_dataA or I_dataB;
                        s_shouldBranch <= '0';
                        
               -- AND OPCODE         
               when OPCODE_AND =>
                        s_result(15 downto 0) <= I_dataA and I_dataB;
                        s_shouldBranch <= '0';
                        
               -- XOR OPCODE         
               when OPCODE_XOR =>
                        s_result(15 downto 0) <= I_dataA and I_dataB;
                        s_shouldBranch <= '0';
                        
               -- NOT OPCODE
               when OPCODE_NOT =>
                        s_result(15 downto 0) <= not I_dataA;
                        s_shouldBranch <= '0';
                        
               -- LOADING IMMEDIATE VALUE 
               when OPCODE_LOAD =>
                        if I_aluop(0) = '0' then
                            s_result(15 downto 0) <= I_dataIMM(7 downto 0) & X"00";
                        else
                            s_result(15 downto 0) <= X"00" & I_dataIMM(7 downto 0);
                        end if;
                        s_shouldBranch <= '0';
                        
               -- COMPARE INSTRUCTION         
               when OPCODE_CMP =>
                    if I_dataA = I_dataB then 
                        s_result(CMP_BIT_EQ) <= '1';
                    else 
                         s_result(CMP_BIT_EQ) <= '0';
                    end if;
                        
                    if I_dataA = X"0000" then
                         s_result(CMP_BIT_AZ) <= '1';
                    else
                         s_result(CMP_BIT_AZ) <= '0';
                    end if;
                        
                    if I_dataB = X"0000" then
                         s_result(CMP_BIT_BZ) <= '1';
                    else
                         s_result(CMP_BIT_BZ) <= '0';
                    end if;
                    
                    -- Now check if A > B, B > A. This requires checking if the operation is signed or not.
                    -- First if the operation is unsigned
                    if I_aluop(0) = '0' then
                       if unsigned(I_dataA) > unsigned(I_dataB) then
                          s_result(CMP_BIT_AGB) <= '1';
                       else
                          s_result(CMP_BIT_AGB) <= '0';
                       end if;
                       
                       if unsigned(I_dataA) < unsigned(I_dataB) then
                           s_result(CMP_BIT_ALB) <= '1';
                       else
                           s_result(CMP_BIT_ALB) <= '0';
                       end if;
                     else
                       if signed(I_dataA) > signed(I_dataB) then
                           s_result(CMP_BIT_AGB) <= '1';
                       else
                           s_result(CMP_BIT_AGB) <= '0';
                       end if;
                       
                       if signed(I_dataA) < signed(I_dataB) then
                           s_result(CMP_BIT_ALB) <= '1';
                       else
                           s_result(CMP_BIT_ALB) <= '0';
                       end if;
                     end if;  
                     s_shouldBranch <= '0';
                     s_result(15) <= '0';
                     s_result(9 downto 0) <= "0000000000";
                     
               when OPCODE_SHL => 
                    case I_dataB(3 downto 0) is
                        when "0001" =>
                                s_result(15 downto 0) <= std_logic_vector(shift_left(unsigned(I_dataA),1));
                        when "0010" =>
                                s_result(15 downto 0) <= std_logic_vector(shift_left(unsigned(I_dataA),2));
                        when "0011" =>
                                s_result(15 downto 0) <= std_logic_vector(shift_left(unsigned(I_dataA),3));
                        when "0100" =>
                                s_result(15 downto 0) <= std_logic_vector(shift_left(unsigned(I_dataA),4));
                        when "0101" =>
                                s_result(15 downto 0) <= std_logic_vector(shift_left(unsigned(I_dataA),5));
                        when "0110" =>
                                s_result(15 downto 0) <= std_logic_vector(shift_left(unsigned(I_dataA),6));
                        when "0111" =>
                                s_result(15 downto 0) <= std_logic_vector(shift_left(unsigned(I_dataA),7));
                        when "1000" =>
                                s_result(15 downto 0) <= std_logic_vector(shift_left(unsigned(I_dataA),8));
                        when "1001" =>
                                s_result(15 downto 0) <= std_logic_vector(shift_left(unsigned(I_dataA),9));
                        when "1010" =>
                                s_result(15 downto 0) <= std_logic_vector(shift_left(unsigned(I_dataA),10));
                        when "1011" =>
                                s_result(15 downto 0) <= std_logic_vector(shift_left(unsigned(I_dataA),11));
                        when "1100" =>
                                s_result(15 downto 0) <= std_logic_vector(shift_left(unsigned(I_dataA),12));
                        when "1101" =>
                                s_result(15 downto 0) <= std_logic_vector(shift_left(unsigned(I_dataA),13));
                        when "1110" =>
                                s_result(15 downto 0) <= std_logic_vector(shift_left(unsigned(I_dataA),14));
                        when "1111" =>
                                s_result(15 downto 0) <= std_logic_vector(shift_left(unsigned(I_dataA),15));
                        when others => 
                                s_result(15 downto 0) <= I_dataA;
                        end case; 
                        s_shouldBranch <= '0';
                        
                when OPCODE_SHR => 
                    case I_dataB(3 downto 0) is
                        when "0001" =>
                                s_result(15 downto 0) <= std_logic_vector(shift_right(unsigned(I_dataA),1));
                        when "0010" =>
                                s_result(15 downto 0) <= std_logic_vector(shift_right(unsigned(I_dataA),2));
                        when "0011" =>
                                s_result(15 downto 0) <= std_logic_vector(shift_right(unsigned(I_dataA),3));
                        when "0100" =>
                                s_result(15 downto 0) <= std_logic_vector(shift_right(unsigned(I_dataA),4));
                        when "0101" =>
                                s_result(15 downto 0) <= std_logic_vector(shift_right(unsigned(I_dataA),5));
                        when "0110" =>
                                s_result(15 downto 0) <= std_logic_vector(shift_right(unsigned(I_dataA),6));
                        when "0111" =>
                                s_result(15 downto 0) <= std_logic_vector(shift_right(unsigned(I_dataA),7));
                        when "1000" =>
                                s_result(15 downto 0) <= std_logic_vector(shift_right(unsigned(I_dataA),8));
                        when "1001" =>
                                s_result(15 downto 0) <= std_logic_vector(shift_right(unsigned(I_dataA),9));
                        when "1010" =>
                                s_result(15 downto 0) <= std_logic_vector(shift_right(unsigned(I_dataA),10));
                        when "1011" =>
                                s_result(15 downto 0) <= std_logic_vector(shift_right(unsigned(I_dataA),11));
                        when "1100" =>
                                s_result(15 downto 0) <= std_logic_vector(shift_right(unsigned(I_dataA),12));
                        when "1101" =>
                                s_result(15 downto 0) <= std_logic_vector(shift_right(unsigned(I_dataA),13));
                        when "1110" =>
                                s_result(15 downto 0) <= std_logic_vector(shift_right(unsigned(I_dataA),14));
                        when "1111" =>
                                s_result(15 downto 0) <= std_logic_vector(shift_right(unsigned(I_dataA),15));
                        when others => 
                                s_result(15 downto 0) <= I_dataA;
                        end case; 
                        s_shouldBranch <= '0';  
               when OPCODE_JUMPEQ =>
                    -- set the branch target regardless
                    s_result(15 downto 0) <= I_dataB(15 downto 0);
                    
                    case (I_aluop(0) & I_dataIMM(1 downto 0)) is
                        when CJF_EQ =>
                            s_shouldBranch <= I_dataA(CMP_BIT_EQ); -- checking reg{Ra] for equality bit
                        when CJF_AZ =>
                        s_shouldBranch <= I_dataA(CMP_BIT_Az);
                        when CJF_BZ => 
                            s_shouldBranch <= I_dataA(CMP_BIT_Bz);
                        when CJF_ANZ => 
                            s_shouldBranch <= not I_dataA(CMP_BIT_AZ);
                        when CJF_BNZ =>
                            s_shouldBranch <= not I_dataA(CMP_BIT_BZ);
                        when CJF_AGB => 
                            s_shouldBranch <= I_dataA(CMP_BIT_AGB);
                        when CJF_ALB =>
                            s_shouldBranch <= I_dataA(CMP_BIT_ALB);
                        when others =>
                        s_shouldBranch <= '0';
                   end case;
                                                    
               when others =>
                    s_result <= "00" & X"FEFE";
               end case;
               end if;
               end process;
               
               O_dataResult <= s_result(15 downto 0);
               O_shouldBranch <= s_shouldBranch;
end Behavioral;
