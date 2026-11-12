library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu_top is
    generic (
        PROG_FILE     : string  := "t0.hex";
        MEM_UNIFICADA : boolean := false
    );
    port (
        clk           : in  std_logic;
        rst           : in  std_logic;
        done          : out std_logic;
        hazard_abort  : out std_logic;
        hazard_type   : out std_logic_vector(1 downto 0);
        hazard_pc     : out std_logic_vector(31 downto 0);
        hazard_cycle  : out unsigned(31 downto 0);
        retired       : out unsigned(1 downto 0);
        stage_valid   : out std_logic_vector(9 downto 0);
        dbg_reg_addr  : in  std_logic_vector(4 downto 0);
        dbg_reg_data  : out std_logic_vector(31 downto 0)
    );
end entity;

architecture rtl of cpu_top is

    -- IF
    signal pc_out, next_pc, pc_plus4 : std_logic_vector(31 downto 0);
    signal instr_if                  : std_logic_vector(31 downto 0);

    -- IF/ID
    signal pc_id                     : std_logic_vector(31 downto 0);
    signal instr_id                  : std_logic_vector(31 downto 0);

    -- ID
    signal rs_data, rt_data, imm_ext : std_logic_vector(31 downto 0);
    signal rs_addr, rt_addr, rd_addr : std_logic_vector(4 downto 0);
    signal ctrl_reg_dst, ctrl_alu_src, ctrl_mem_to_reg, ctrl_reg_write : std_logic;
    signal ctrl_mem_read, ctrl_mem_write, ctrl_branch, ctrl_is_break : std_logic;
    signal ctrl_alu_ctrl             : std_logic_vector(2 downto 0);
    signal zero_id                   : std_logic;
    signal branch_target_id          : std_logic_vector(31 downto 0);

    -- ID/EX
    signal ex_ctrl_reg_write, ex_ctrl_mem_to_reg, ex_ctrl_mem_read, ex_ctrl_mem_write : std_logic;
    signal ex_ctrl_branch, ex_ctrl_is_break, ex_alu_src, ex_reg_dst : std_logic;
    signal ex_alu_ctrl               : std_logic_vector(2 downto 0);
    signal ex_pc                     : std_logic_vector(31 downto 0);
    signal ex_rs_data, ex_rt_data, ex_imm : std_logic_vector(31 downto 0);
    signal ex_rs_addr, ex_rt_addr, ex_rd_addr : std_logic_vector(4 downto 0);

    -- EX
    signal alu_result                : std_logic_vector(31 downto 0);
    signal alu_b                     : std_logic_vector(31 downto 0);
    signal ex_wr_addr                : std_logic_vector(4 downto 0);

    -- EX/MEM
    signal mem_ctrl_reg_write, mem_ctrl_mem_to_reg, mem_ctrl_mem_read, mem_ctrl_mem_write : std_logic;
    signal mem_ctrl_branch, mem_ctrl_is_break : std_logic;
    signal mem_alu_result, mem_rt_data : std_logic_vector(31 downto 0);
    signal mem_rd_addr               : std_logic_vector(4 downto 0);

    -- MEM
    signal dmem_read                 : std_logic_vector(31 downto 0);

    -- MEM/WB
    signal wb_ctrl_reg_write, wb_ctrl_mem_to_reg, wb_ctrl_is_break : std_logic;
    signal wb_alu_result, wb_dmem_read : std_logic_vector(31 downto 0);
    signal wb_rd_addr                : std_logic_vector(4 downto 0);

    -- WB
    signal write_data                : std_logic_vector(31 downto 0);

    -- Controle de Conflito
    signal hazard_abort_int          : std_logic;
    signal hazard_type_int           : std_logic_vector(1 downto 0);
    signal stall_if                  : std_logic;
    signal flush_id_ex               : std_logic;

    -- NOVO: Contador de ciclos para o hazard_cycle
    signal ciclo_atual : unsigned(31 downto 0) := (others => '0');

    -- Funcao para limpar sinais indefinidos
    function to_logic(v : std_logic) return std_logic is
    begin
        if is_x(v) then
            return '0';
        else
            return v;
        end if;
    end function;

begin

    -- NOVO PROCESSO: Contador de ciclos (conta apenas depois do reset)
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                ciclo_atual <= (others => '0');
            elsif hazard_abort_int = '1' or to_logic(wb_ctrl_is_break) = '1' then
                ciclo_atual <= ciclo_atual; -- Congela no aborto ou done
            else
                ciclo_atual <= ciclo_atual + 1;
            end if;
        end if;
    end process;

    -- ================= IF =================

    pc_inst: entity work.pc
        port map (clk => clk, rst => rst, freeze => to_logic(stall_if or hazard_abort_int),
                  next_pc => next_pc, pc_out => pc_out);

    imem_inst: entity work.imem
        generic map (PROG_FILE => PROG_FILE)
        port map (addr => pc_out, instr => instr_if);

    pc_plus4 <= std_logic_vector(unsigned(pc_out) + 4);

    next_pc <= branch_target_id
        when (to_logic(ctrl_branch) = '1' and to_logic(zero_id) = '1' and to_logic(ctrl_is_break) = '0')
        else pc_plus4;

    if_id_inst: entity work.if_id
        port map (clk => clk, rst => rst, flush => '0', stall => to_logic(stall_if or hazard_abort_int),
                  pc_in => pc_out, instr_in => instr_if, pc_out => pc_id, instr_out => instr_id);

    -- ================= ID =================

    process(instr_id)
    begin
        if is_x(instr_id) then
            rs_addr <= "00000"; rt_addr <= "00000"; rd_addr <= "00000";
        else
            rs_addr <= instr_id(25 downto 21);
            rt_addr <= instr_id(20 downto 16);
            rd_addr <= instr_id(15 downto 11);
        end if;
    end process;

    regfile_inst: entity work.regfile
        port map (clk => clk, rst => rst, reg_write => to_logic(wb_ctrl_reg_write),
                  rs_addr => rs_addr, rt_addr => rt_addr, rd_addr => wb_rd_addr,
                  write_data => write_data, rs_data => rs_data, rt_data => rt_data,
                  dbg_addr => dbg_reg_addr, dbg_data => dbg_reg_data);

    ctrl_inst: entity work.control
        port map (opcode => instr_id(31 downto 26), funct => instr_id(5 downto 0),
                  reg_dst => ctrl_reg_dst, alu_src => ctrl_alu_src, mem_to_reg => ctrl_mem_to_reg,
                  reg_write => ctrl_reg_write, mem_read => ctrl_mem_read, mem_write => ctrl_mem_write,
                  branch => ctrl_branch, alu_ctrl => ctrl_alu_ctrl, is_break => ctrl_is_break);

    imm_ext <= (31 downto 16 => instr_id(15)) & instr_id(15 downto 0);

    branch_target_id <= std_logic_vector(
        unsigned(pc_id) + unsigned((31 downto 18 => instr_id(15)) & instr_id(15 downto 0) & "00"));

    zero_id <= '1' when rs_data = rt_data else '0';

    id_ex_inst: entity work.id_ex
        port map (clk => clk, rst => rst, flush => to_logic(flush_id_ex), stall => to_logic(stall_if or hazard_abort_int),
                  reg_write_in => to_logic(ctrl_reg_write), mem_to_reg_in => to_logic(ctrl_mem_to_reg),
                  mem_read_in => to_logic(ctrl_mem_read), mem_write_in => to_logic(ctrl_mem_write),
                  alu_src_in => to_logic(ctrl_alu_src), reg_dst_in => to_logic(ctrl_reg_dst), alu_ctrl_in => ctrl_alu_ctrl,
                  branch_in => to_logic(ctrl_branch), is_break_in => to_logic(ctrl_is_break),
                  pc_in => pc_id, rs_data_in => rs_data, rt_data_in => rt_data, imm_in => imm_ext,
                  rs_addr_in => rs_addr, rt_addr_in => rt_addr, rd_addr_in => rd_addr,
                  reg_write_out => ex_ctrl_reg_write, mem_to_reg_out => ex_ctrl_mem_to_reg,
                  mem_read_out => ex_ctrl_mem_read, mem_write_out => ex_ctrl_mem_write,
                  alu_src_out => ex_alu_src, reg_dst_out => ex_reg_dst, alu_ctrl_out => ex_alu_ctrl,
                  branch_out => ex_ctrl_branch, is_break_out => ex_ctrl_is_break,
                  pc_out => ex_pc, rs_data_out => ex_rs_data, rt_data_out => ex_rt_data, imm_out => ex_imm,
                  rs_addr_out => ex_rs_addr, rt_addr_out => ex_rt_addr, rd_addr_out => ex_rd_addr);

    -- ================= EX =================

    process(ex_alu_src, ex_rt_data, ex_imm)
    begin
        if is_x(ex_alu_src) then alu_b <= (others => '0');
        elsif ex_alu_src = '0' then alu_b <= ex_rt_data;
        else alu_b <= ex_imm; end if;
    end process;

    alu_inst: entity work.alu
        port map (a => ex_rs_data, b => alu_b, alu_ctrl => ex_alu_ctrl, result => alu_result, zero => open);

    ex_wr_addr <= "00000" when is_x(ex_reg_dst) else
                  ex_rd_addr when ex_reg_dst = '1' else ex_rt_addr;

    ex_mem_inst: entity work.ex_mem
        port map (clk => clk, rst => rst, flush => '0', stall => to_logic(hazard_abort_int),
                  reg_write_in => to_logic(ex_ctrl_reg_write), mem_to_reg_in => to_logic(ex_ctrl_mem_to_reg),
                  mem_read_in => to_logic(ex_ctrl_mem_read), mem_write_in => to_logic(ex_ctrl_mem_write),
                  branch_in => to_logic(ex_ctrl_branch), is_break_in => to_logic(ex_ctrl_is_break),
                  alu_result_in => alu_result, rt_data_in => ex_rt_data, rd_addr_in => ex_wr_addr, pc_in => ex_pc,
                  reg_write_out => mem_ctrl_reg_write, mem_to_reg_out => mem_ctrl_mem_to_reg,
                  mem_read_out => mem_ctrl_mem_read, mem_write_out => mem_ctrl_mem_write,
                  branch_out => mem_ctrl_branch, is_break_out => mem_ctrl_is_break,
                  alu_result_out => mem_alu_result, rt_data_out => mem_rt_data,
                  rd_addr_out => mem_rd_addr, pc_out => open);

    -- ================= MEM =================

    dmem_inst: entity work.dmem
        port map (clk => clk, rst => rst, mem_read => to_logic(mem_ctrl_mem_read), mem_write => to_logic(mem_ctrl_mem_write),
                  addr => mem_alu_result, write_data => mem_rt_data, read_data => dmem_read);

    mem_wb_inst: entity work.mem_wb
        port map (clk => clk, rst => rst, flush => '0', stall => to_logic(hazard_abort_int),
                  reg_write_in => to_logic(mem_ctrl_reg_write), mem_to_reg_in => to_logic(mem_ctrl_mem_to_reg),
                  is_break_in => to_logic(mem_ctrl_is_break),
                  alu_result_in => mem_alu_result, mem_data_in => dmem_read, rd_addr_in => mem_rd_addr,
                  reg_write_out => wb_ctrl_reg_write, mem_to_reg_out => wb_ctrl_mem_to_reg,
                  is_break_out => wb_ctrl_is_break,
                  alu_result_out => wb_alu_result, mem_data_out => wb_dmem_read, rd_addr_out => wb_rd_addr);

    -- ================= WB =================

    write_data <= wb_dmem_read when to_logic(wb_ctrl_mem_to_reg) = '1' else wb_alu_result;

    -- ================= HAZARD & SAIDAS =================

    hazard_inst: entity work.hazard_unit
        port map (rs_addr_id => rs_addr, rt_addr_id => rt_addr,
                  reg_write_ex => to_logic(ex_ctrl_reg_write), rd_addr_ex => ex_wr_addr, mem_read_ex => to_logic(ex_ctrl_mem_read),
                  reg_write_mem => to_logic(mem_ctrl_reg_write), rd_addr_mem => mem_rd_addr,
                  branch_id => to_logic(ctrl_branch), zero_ex => to_logic(zero_id),
                  mem_unificada => MEM_UNIFICADA, mem_read_ex_b => to_logic(ex_ctrl_mem_read),
                  hazard_abort => hazard_abort_int, hazard_type => hazard_type_int,
                  stall_if => stall_if, flush_id_ex => flush_id_ex);

    hazard_abort <= to_logic(hazard_abort_int);
    hazard_type  <= hazard_type_int;
    hazard_pc    <= pc_id;
    hazard_cycle <= ciclo_atual; -- Ligado ao contador novo

    done <= to_logic(wb_ctrl_is_break);

    retired <= "01" when to_logic(wb_ctrl_reg_write) = '1' or to_logic(wb_ctrl_mem_to_reg) = '1' else "00";

    stage_valid <= "0000000001" when to_logic(wb_ctrl_reg_write) = '1' else "0000000000";

end architecture;