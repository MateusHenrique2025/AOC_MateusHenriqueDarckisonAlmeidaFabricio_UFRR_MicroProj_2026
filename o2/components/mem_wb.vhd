library ieee;
use ieee.std_logic_1164.all;

entity mem_wb is
    port (
        clk           : in  std_logic;
        rst           : in  std_logic;
        flush         : in  std_logic;
        stall         : in  std_logic;
        reg_write_in  : in  std_logic;
        mem_to_reg_in : in  std_logic;
        is_break_in   : in  std_logic;
        alu_result_in : in  std_logic_vector(31 downto 0);
        mem_data_in   : in  std_logic_vector(31 downto 0);
        rd_addr_in    : in  std_logic_vector(4 downto 0);
        reg_write_out  : out std_logic;
        mem_to_reg_out : out std_logic;
        is_break_out   : out std_logic;
        alu_result_out : out std_logic_vector(31 downto 0);
        mem_data_out   : out std_logic_vector(31 downto 0);
        rd_addr_out    : out std_logic_vector(4 downto 0)
    );
end entity;

architecture rtl of mem_wb is
    -- Inicialização
    signal reg_write, mem_to_reg, is_break : std_logic := '0';
    signal alu_result, mem_data : std_logic_vector(31 downto 0) := (others => '0');
    signal rd_addr : std_logic_vector(4 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' or flush = '1' then
                reg_write <= '0'; mem_to_reg <= '0'; is_break <= '0';
                alu_result <= (others => '0'); mem_data <= (others => '0'); rd_addr <= (others => '0');
            elsif stall = '0' then
                reg_write <= reg_write_in; mem_to_reg <= mem_to_reg_in; is_break <= is_break_in;
                alu_result <= alu_result_in; mem_data <= mem_data_in; rd_addr <= rd_addr_in;
            end if;
        end if;
    end process;
    reg_write_out <= reg_write; mem_to_reg_out <= mem_to_reg; is_break_out <= is_break;
    alu_result_out <= alu_result; mem_data_out <= mem_data; rd_addr_out <= rd_addr;
end architecture;