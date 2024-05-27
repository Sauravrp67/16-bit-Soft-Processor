library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
entity ram is
  Port (  I_clk: in std_logic;
          I_addr: in std_logic_vector (15 downto 0);
          I_we: in std_logic;
          I_data: in std_logic_vector(15 downto 0);
          O_data: out std_logic_vector(15 downto 0));
end ram;

architecture Behavioral of ram is
    type store_t is array (31 downto 0) of std_logic_vector(15 downto 0);
    signal ram_16: store_t := (others => X"0000");
begin
    process(I_clk)
    begin
        if rising_edge(I_clk) then
            if (I_we = '1') then
                ram_16(TO_INTEGER(unsigned(I_addr(5 downto 0)))) <= I_data;
            else 
                O_data <= ram_16(to_integer(unsigned(I_addr(5 downto 0))));
            end if; 
        end if;
    end process;

end Behavioral;
