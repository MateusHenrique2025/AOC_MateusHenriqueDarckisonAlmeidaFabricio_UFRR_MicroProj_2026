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

    -- Leitura combinacional protegida contra 'U' e índices inválidos
    process(rs_addr, rt_addr, dbg_addr, regs)
        variable rs_idx, rt_idx, dbg_idx : integer;
    begin
        -- Proteção rs_addr
        if is_x(rs_addr) then
            rs_data <= (others => '0');
        else
            rs_idx := to_integer(unsigned(rs_addr));
            if rs_idx < 32 then
                rs_data <= (others => '0') when rs_addr = "00000" else regs(rs_idx);
            else
                rs_data <= (others => '0');
            end if;
        end if;

        -- Proteção rt_addr
        if is_x(rt_addr) then
            rt_data <= (others => '0');
        else
            rt_idx := to_integer(unsigned(rt_addr));
            if rt_idx < 32 then
                rt_data <= (others => '0') when rt_addr = "00000" else regs(rt_idx);
            else
                rt_data <= (others => '0');
            end if;
        end if;

        -- Proteção dbg_addr
        if is_x(dbg_addr) then
            dbg_data <= (others => '0');
        else
            dbg_idx := to_integer(unsigned(dbg_addr));
            if dbg_idx < 32 then
                dbg_data <= (others => '0') when dbg_addr = "00000" else regs(dbg_idx);
            else
                dbg_data <= (others => '0');
            end if;
        end if;
    end process;
end architecture;