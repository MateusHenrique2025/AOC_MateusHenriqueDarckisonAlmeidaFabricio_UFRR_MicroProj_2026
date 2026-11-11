library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity if_id is
    port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        flush     : in  std_logic;
        stall     : in  std_logic;
        pc_in     : in  std_logic_vector(31 downto 0);
        instr_in  : in  std_logic_vector(31 downto 0);
        pc_out    : out std_logic_vector(31 downto 0);
        instr_out : out std_logic_vector(31 downto 0)
    );
end entity;

architecture rtl of if_id is
    -- Inicializando com zeros para evitar erros de 'U' no tempo 0
    signal pc_reg    : std_logic_vector(31 downto 0) := (others => '0');
    signal instr_reg : std_logic_vector(31 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' or flush = '1' then
                pc_reg    <= (others => '0');
                instr_reg <= (others => '0');
            elsif stall = '0' then
                pc_reg    <= pc_in;
                instr_reg <= instr_in;
            end if;
        end if;
    end process;
    pc_out    <= pc_reg;
    instr_out <= instr_reg;
end architecture;