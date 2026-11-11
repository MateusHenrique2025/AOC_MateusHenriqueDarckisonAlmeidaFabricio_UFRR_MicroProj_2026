library ieee;
use ieee.std_logic_1164.all;

entity id_ex is
    port (
        clk           : in  std_logic;
        rst           : in  std_logic;
        flush         : in  std_logic;
        stall         : in  std_logic;
        reg_write_in  : in  std_logic;
        mem_to_reg_in : in  std_logic;
        mem_read_in   : in  std_logic;
        mem_write_in  : in  std_logic;
        alu_src_in    : in  std_logic;
        reg_dst_in    : in  std_logic;
        alu_ctrl_in   : in  std_logic_vector(2 downto 0);
        branch_in     : in  std_logic;
        is_break_in   : in  std_logic;
        pc_in         : in  std_logic_vector(31 downto 0);
        rs_data_in    : in  std_logic_vector(31 downto 0);
        rt_data_in    : in  std_logic_vector(31 downto 0);
        imm_in        : in  std_logic_vector(31 downto 0);
        rs_addr_in    : in  std_logic_vector(4 downto 0);
        rt_addr_in    : in  std_logic_vector(4 downto 0);
        rd_addr_in    : in  std_logic_vector(4 downto 0);
        reg_write_out  : out std_logic;
        mem_to_reg_out : out std_logic;
        mem_read_out   : out std_logic;
        mem_write_out  : out std_logic;
        alu_src_out    : out std_logic;
        reg_dst_out    : out std_logic;
        alu_ctrl_out   : out std_logic_vector(2 downto 0);
        branch_out     : out std_logic;
        is_break_out   : out std_logic;
        pc_out         : out std_logic_vector(31 downto 0);
        rs_data_out    : out std_logic_vector(31 downto 0);
        rt_data_out    : out std_logic_vector(31 downto 0);
        imm_out        : out std_logic_vector(31 downto 0);
        rs_addr_out    : out std_logic_vector(4 downto 0);
        rt_addr_out    : out std_logic_vector(4 downto 0);
        rd_addr_out    : out std_logic_vector(4 downto 0)
    );
end entity;

architecture rtl of id_ex is
    -- Inicialização para evitar 'U' no tempo 0
    signal reg_write, mem_to_reg, mem_read, mem_write : std_logic := '0';
    signal alu_src, reg_dst, branch, is_break         : std_logic := '0';
    signal alu_ctrl                                   : std_logic_vector(2 downto 0) := "000";
    signal pc, rs_data, rt_data, imm                  : std_logic_vector(31 downto 0) := (others => '0');
    signal rs_addr, rt_addr, rd_addr                  : std_logic_vector(4 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' or flush = '1' then
                reg_write <= '0'; mem_to_reg <= '0'; mem_read <= '0'; mem_write <= '0';
                alu_src <= '0'; reg_dst <= '0'; branch <= '0'; is_break <= '0';
                alu_ctrl <= "000";
                pc <= (others => '0'); rs_data <= (others => '0'); rt_data <= (others => '0'); imm <= (others => '0');
                rs_addr <= (others => '0'); rt_addr <= (others => '0'); rd_addr <= (others => '0');
            elsif stall = '0' then
                reg_write <= reg_write_in; mem_to_reg <= mem_to_reg_in; mem_read <= mem_read_in; mem_write <= mem_write_in;
                alu_src <= alu_src_in; reg_dst <= reg_dst_in; branch <= branch_in; is_break <= is_break_in;
                alu_ctrl <= alu_ctrl_in;
                pc <= pc_in; rs_data <= rs_data_in; rt_data <= rt_data_in; imm <= imm_in;
                rs_addr <= rs_addr_in; rt_addr <= rt_addr_in; rd_addr <= rd_addr_in;
            end if;
        end if;
    end process;

    reg_write_out <= reg_write; mem_to_reg_out <= mem_to_reg; mem_read_out <= mem_read; mem_write_out <= mem_write;
    alu_src_out <= alu_src; reg_dst_out <= reg_dst; branch_out <= branch; is_break_out <= is_break;
    alu_ctrl_out <= alu_ctrl;
    pc_out <= pc; rs_data_out <= rs_data; rt_data_out <= rt_data; imm_out <= imm;
    rs_addr_out <= rs_addr; rt_addr_out <= rt_addr; rd_addr_out <= rd_addr;
end architecture;