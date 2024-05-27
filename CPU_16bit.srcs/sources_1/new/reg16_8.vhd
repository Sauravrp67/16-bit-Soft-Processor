library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity reg16_8 is
  Port ( I_clk : in std_logic;
         I_en: in std_logic;
         I_we: in std_logic;
         I_dataD: in std_logic_vector(15 downto 0);
         O_dataA: out std_logic_vector(15 downto 0);
         O_dataB: out std_logic_vector(15 downto 0);
         I_selA: in std_logic_vector(2 downto 0);
         I_selB: in std_logic_vector(2 downto 0);
         I_selD: in std_logic_vector(2 downto 0));
end reg16_8;

architecture Behavioral of reg16_8 is
    type store_t is array (0 to 7) of std_logic_vector(15 downto 0);
    signal regs: store_t := (others => X"0000");
begin
    process(I_clk) --this process block gets re-evaluated when the state of I_clk is changed
    begin
        if rising_edge(I_clk) and I_en='1' then
            O_dataA <= regs(to_integer(unsigned(I_selA)));
            O_dataB <= regs(to_integer(unsigned(I_selB)));
            
            if (I_we = '1') then
                regs(to_integer(unsigned(I_selD))) <= I_dataD;
            end if;
            end if;
        end process;
        


end Behavioral;
