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
    -- Sinais Internos
    signal pc_out, next_pc, pc_plus4 : std_logic_vector(31 downto 0);
    signal instr                     : std_logic_vector(31 downto 0);
    signal rs_data, rt_data          : std_logic_vector(31 downto 0);
    signal alu_a, alu_b, alu_result  : std_logic_vector(31 downto 0);
    signal zero                      : std_logic;
    signal write_data, dmem_read     : std_logic_vector(31 downto 0);
    signal wr_addr                   : std_logic_vector(4 downto 0);
    signal branch_target             : std_logic_vector(31 downto 0);
    
    -- Sinais de Controle
    signal reg_dst, alu_src, mem_to_reg, reg_write : std_logic;
    signal mem_read, mem_write, branch, is_break   : std_logic;
    signal alu_ctrl                                : std_logic_vector(2 downto 0);

begin
    -- 1. Program Counter
    pc_inst: entity work.pc
        port map (
            clk     => clk,
            rst     => rst,
            freeze  => is_break or done, -- Congela se achar break ou done
            next_pc => next_pc,
            pc_out  => pc_out
        );

    -- 2. Instruction Memory
    imem_inst: entity work.imem
        generic map (PROG_FILE => PROG_FILE)
        port map (
            addr  => pc_out,
            instr => instr
        );

    -- 3. Register File
    regfile_inst: entity work.regfile
        port map (
            clk        => clk,
            rst        => rst,
            reg_write  => reg_write,
            rs_addr    => instr(25 downto 21),
            rt_addr    => instr(20 downto 16),
            rd_addr    => wr_addr,
            write_data => write_data,
            rs_data    => rs_data,
            rt_data    => rt_data,
            dbg_addr   => dbg_reg_addr,
            dbg_data   => dbg_reg_data
        );

    -- 4. Control Unit
    ctrl_inst: entity work.control
        port map (
            opcode     => instr(31 downto 26),
            funct      => instr(5 downto 0),
            reg_dst    => reg_dst,
            alu_src    => alu_src,
            mem_to_reg => mem_to_reg,
            reg_write  => reg_write,
            mem_read   => mem_read,
            mem_write  => mem_write,
            branch     => branch,
            alu_ctrl   => alu_ctrl,
            is_break   => is_break
        );

    -- 5. ALU Mux e ALU
    alu_a <= rs_data;
    -- Sign-extend do imediato
    alu_b <= rt_data when alu_src = '0' else
             (31 downto 16 => instr(15)) & instr(15 downto 0);

    alu_inst: entity work.alu
        port map (
            a        => alu_a,
            b        => alu_b,
            alu_ctrl => alu_ctrl,
            result   => alu_result,
            zero     => zero
        );

    -- 6. Data Memory
    dmem_inst: entity work.dmem
        port map (
            clk        => clk,
            rst        => rst,
            mem_read   => mem_read,
            mem_write  => mem_write,
            addr       => alu_result,
            write_data => rt_data,
            read_data  => dmem_read
        );

    -- 7. Write-back Mux
    wr_addr    <= instr(15 downto 11) when reg_dst = '1' else instr(20 downto 16);
    write_data <= dmem_read when mem_to_reg = '1' else alu_result;

    -- 8. Lógica do Próximo PC (Branch e PC+4)
    pc_plus4 <= std_logic_vector(unsigned(pc_out) + 4);
    
    -- Cálculo seguro do endereço de desvio
    process(pc_plus4, instr, branch, zero, is_break)
    begin
        if branch = '1' and zero = '1' and is_break = '0' then
            -- Se for beq tomado, calcula o salto
            branch_target <= std_logic_vector(unsigned(pc_plus4) + 
                                unsigned((31 downto 16 => instr(15)) & instr(15 downto 0) & "00"));
            next_pc <= branch_target;
        else
            -- Para qualquer outra instrução, vai para PC+4
            branch_target <= (others => '0');
            next_pc <= pc_plus4;
        end if;
    end process;

    -- 9. Sinais de Saída Exigidos pelo R3
    done          <= is_break;
    hazard_abort  <= '0'; -- Não há hazards no O1
    hazard_type   <= "00";
    hazard_pc     <= (others => '0');
    hazard_cycle  <= (others => '0');
    
    -- Retired indica instrução útil concluída (1 no ciclo)
    retired       <= "01" when is_break = '0' else "00";
    
    -- Stage valid: O1 usa apenas o bit 0
    stage_valid   <= "0000000001";

end architecture;