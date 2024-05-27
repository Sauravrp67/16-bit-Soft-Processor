library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity reg16_8_tb is
--  Port ( );
end reg16_8_tb;

architecture Behavioral of reg16_8_tb is
    Component reg16_8 
                Port(I_clk: in std_logic;
                     I_en: in std_logic;
                     I_we: in std_logic;
                     I_dataD: in std_logic_vector(15 downto 0);
                     O_dataA: out std_logic_vector(15 downto 0);
                     O_dataB: out std_logic_vector(15 downto 0);
                     I_selA: in std_logic_vector(2 downto 0);
                     I_selB: in std_logic_vector(2 downto 0);
                     I_selD: in std_logic_vector(2 downto 0));
     end Component;
     
     --Input
     signal I_clk_tb: std_logic := '0';
     signal I_en_tb: std_logic := '0';
     signal I_we_tb: std_logic := '0';
     signal I_dataD_tb: std_logic_vector(15 downto 0):= (others => '0');
     --Output
     signal O_dataA_tb: std_logic_vector(15 downto 0):= (others => '0');
     signal O_dataB_tb: std_logic_vector(15 downto 0):= (others => '0');
     --selection line
     signal I_selA_tb: std_logic_vector(2 downto 0):= (others => '0');
     signal I_selB_tb:std_logic_vector(2 downto 0):= (others => '0');
     signal I_selD_tb: std_logic_vector (2 downto 0):= (others => '0');
     
     -- define clock period
     constant I_clk_period :time := 10 ns;
begin
    uut:reg16_8 
            Port Map (
                  I_clk => I_clk_tb,
                  I_en => I_en_tb,
                  I_we => I_we_tb,
                  I_dataD => I_dataD_tb,
                  O_dataA => O_dataA_tb,
                  O_dataB => O_dataB_tb,
                  I_selA => I_selA_tb,
                  I_selB => I_selB_tb,
                  I_selD => I_selD_tb);
                  
I_clk_process: process
begin
    I_clk_tb <= '0';
    wait for I_clk_period/2;
    I_clk_tb <= '1';
    wait for I_clk_period/2;
end Process;

stimulus:process
begin
    -- hold reset state for 100ns
    wait for 100ns;
--    wait for I_clk_period * 10;
    
    -- insert stimulus here
    
    I_en_tb <= '1';
    
    -- test for writing to register
    -- r0 = 0xfab5
    I_selA_tb <= b"000";
    I_selB_tb <= b"001";
    I_selD_tb <= b"000";
    I_dataD_tb <= X"FAB5";
    I_we_tb <= '1';
    
    wait for I_clk_period;
    -- r2 = 0x2222
    I_selA_tb <= b"000";
    I_selB_tb <= b"001";
    I_selD_tb <= b"010";
    I_dataD_tb <= X"2222";
    I_we_tb <= '1';
    
    wait for I_clk_period;
    
    -- r3 = 0x 1234
    
    I_selA_tb <= b"000";
    I_selB_tb <= b"000";
    I_selD_tb <= b"011";
    I_dataD_tb <= X"1234";
    I_we_tb <= '1';
    
    wait for I_clk_period;
    
    --test just reading, with no write
    I_selA_tb <= b"000";
    I_selB_tb <= b"001";
    I_selD_tb <= b"000";
    I_dataD_tb <= X"1235";
    I_we_tb <= '0';
    wait for I_clk_period;
    
    I_selA_tb <= b"001";
    I_selB_tb <= b"010";
    wait for I_clk_period;
    
    I_selA_tb <= b"011";
    I_selB_tb <= b"100";
    wait for I_clk_period;
    I_selA_tb <= "000";
    I_selB_tb <= "001";
    I_selD_tb <= "100";
    I_dataD_tb <= X"4444";
    I_we_tb <= '1';
      wait for I_clk_period;

    I_we_tb <= '0';
    wait for I_clk_period;

    -- nop
    wait for I_clk_period;

    I_selA_tb <= "100";
    I_selB_tb <= "100";
    wait for I_clk_period;
    wait;
   
end process;

end Behavioral;
