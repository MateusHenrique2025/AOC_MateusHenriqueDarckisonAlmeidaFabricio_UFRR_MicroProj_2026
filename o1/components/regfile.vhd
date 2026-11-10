library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity regfile is
    port (
        clk        : in  std_logic;
        rst        : in  std_logic;
        reg_write  : in  std_logic;
        rs_addr    : in  std_logic_vector(4 downto 0);
        rt_addr    : in  std_logic_vector(4 downto 0);
        rd_addr    : in  std_logic_vector(4 downto 0);
        write_data : in  std_logic_vector(31 downto 0);
        rs_data    : out std_logic_vector(31 downto 0);
        rt_data    : out std_logic_vector(31 downto 0);
        dbg_addr   : in  std_logic_vector(4 downto 0);
        dbg_data   : out std_logic_vector(31 downto 0)
    );
end entity;

architecture rtl of regfile is
    type reg_array is array (0 to 31) of std_logic_vector(31 downto 0);
    signal regs : reg_array := (others => (others => '0'));
begin
    -- Escrita na borda de descida
    process(clk)
    begin
        if falling_edge(clk) then
            if rst = '1' then
                regs <= (others => (others => '0'));
            elsif reg_write = '1' and rd_addr /= "00000" then
                regs(to_integer(unsigned(rd_addr))) <= write_data;
            end if;
        end if;
    end process;

    -- Leitura combinacional (ignora $zero)
    rs_data <= (others => '0') when rs_addr = "00000" else regs(to_integer(unsigned(rs_addr)));
    rt_data <= (others => '0') when rt_addr = "00000" else regs(to_integer(unsigned(rt_addr)));
    dbg_data <= (others => '0') when dbg_addr = "00000" else regs(to_integer(unsigned(dbg_addr)));
end architecture;