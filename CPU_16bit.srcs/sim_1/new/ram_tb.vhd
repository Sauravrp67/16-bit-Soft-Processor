library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity ram_tb is
-- No ports for testbench
end ram_tb;

architecture Behavioral of ram_tb is

    -- Component declaration of the Unit Under Test (UUT)
    component ram
        Port ( 
            I_clk: in std_logic;
            I_addr: in std_logic_vector(15 downto 0);
            I_we: in std_logic;
            I_data: in std_logic_vector(15 downto 0);
            O_data: out std_logic_vector(15 downto 0)
        );
    end component;

    -- Testbench signals
    signal I_clk_tb : std_logic := '0';
    signal I_addr_tb : std_logic_vector(15 downto 0) := (others => '0');
    signal I_we_tb : std_logic := '0';
    signal I_data_tb : std_logic_vector(15 downto 0) := (others => '0');
    signal O_data_tb : std_logic_vector(15 downto 0);

    -- Clock period definition
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: ram 
        Port map (
            I_clk => I_clk_tb,
            I_addr => I_addr_tb,
            I_we => I_we_tb,
            I_data => I_data_tb,
            O_data => O_data_tb
        );

    -- Clock process definitions
    clk_process :process
    begin
        while true loop
            I_clk_tb <= '0';
            wait for clk_period/2;
            I_clk_tb <= '1';
            wait for clk_period/2;
        end loop;
    end process;

    -- Stimulus process
    stimulus :process
    begin        
        -- Initialize RAM with some data
        I_we_tb <= '1';
        I_addr_tb <= std_logic_vector(to_unsigned(0, I_addr_tb'length));
        I_data_tb <= X"AAAA";
        wait for clk_period;
        
        I_addr_tb <= std_logic_vector(to_unsigned(1, I_addr_tb'length));
        I_data_tb <= X"BBBB";
        wait for clk_period;

        I_addr_tb <= std_logic_vector(to_unsigned(2, I_addr_tb'length));
        I_data_tb <= X"CCCC";
        wait for clk_period;

        I_we_tb <= '0';
        
        -- Read back the data
        I_addr_tb <= std_logic_vector(to_unsigned(0, I_addr_tb'length));
        wait for clk_period;
        
        I_addr_tb <= std_logic_vector(to_unsigned(1, I_addr_tb'length));
        wait for clk_period;

        I_addr_tb <= std_logic_vector(to_unsigned(2, I_addr_tb'length));
        wait for clk_period;

        -- End simulation
        wait;
    end process;

end Behavioral;
