library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity tb_cpu is
    generic (
        PROG_FILE     : string  := "t0.hex";
        ESPERADO_FILE : string  := "t0_esperado.txt";
        ORG_NOME      : string  := "O1";
        NUM_SLOTS     : integer := 1;
        MEM_UNIFICADA : boolean := false;
        ESPERA_ABORTO : boolean := false;
        TIPO_ESPERADO : integer := 0;
        MAX_CICLOS    : integer := 10000
    );
end entity;

architecture sim of tb_cpu is
    signal clk           : std_logic := '0';
    signal rst           : std_logic := '1';
    signal fim_sim       : boolean := false;
    
    signal done          : std_logic;
    signal hazard_abort  : std_logic;
    signal hazard_type   : std_logic_vector(1 downto 0);
    signal hazard_pc     : std_logic_vector(31 downto 0);
    signal hazard_cycle  : unsigned(31 downto 0);
    signal retired       : unsigned(1 downto 0);
    signal stage_valid   : std_logic_vector(9 downto 0);
    signal dbg_reg_addr  : std_logic_vector(4 downto 0) := (others => '0');
    signal dbg_reg_data  : std_logic_vector(31 downto 0);
begin
    -- 1. Geração de clock (T_CLK fixado em 10 ns)
    clk <= not clk after 10 ns / 2 when not fim_sim else '0';

    -- 2. Instanciação do DUT (Device Under Test)
    dut : entity work.cpu_top
        generic map (PROG_FILE => PROG_FILE, MEM_UNIFICADA => MEM_UNIFICADA)
        port map (
            clk => clk, rst => rst, done => done,
            hazard_abort => hazard_abort, hazard_type => hazard_type,
            hazard_pc => hazard_pc, hazard_cycle => hazard_cycle,
            retired => retired, stage_valid => stage_valid,
            dbg_reg_addr => dbg_reg_addr, dbg_reg_data => dbg_reg_data
        );

    -- 3. Processo Principal
    process
        file f_esp : text;
        file f_csv : text;
        variable l : line;
        variable st : file_open_status;
        variable ciclos : natural := 0;
        variable instrs : natural := 0;
        variable ocupados : natural := 0;
        variable erros : natural := 0;
        variable reg_num : integer;
        variable valor : std_logic_vector(31 downto 0);
        variable cpi, ipc, ocup : real := 0.0;
    begin
        -- 3.1 Reset síncrono durante 2 ciclos
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        rst <= '0';

        -- 3.2 Execução: amostra na borda de DESCIDA, no meio do ciclo
        loop
            wait until falling_edge(clk);
            ciclos := ciclos + 1;
            instrs := instrs + to_integer(retired);
            for i in 0 to NUM_SLOTS - 1 loop
                if stage_valid(i) = '1' then
                    ocupados := ocupados + 1;
                end if;
            end loop;
            exit when done = '1' or hazard_abort = '1' or ciclos = MAX_CICLOS;
        end loop;

        -- 3.3 Desfecho: aborto, fim normal ou tempo esgotado
        if hazard_abort = '1' then
            report ORG_NOME & ": ABORTO tipo=" & to_string(hazard_type) &
                   " pc=0x" & to_string(hazard_pc) &
                   " ciclo=" & integer'image(to_integer(hazard_cycle));
            assert ESPERA_ABORTO report "Aborto inesperado: o traço deveria ser livre de conflitos" severity error;
            assert to_integer(unsigned(hazard_type)) = TIPO_ESPERADO report "Tipo de conflito diferente do esperado" severity error;
            assert to_integer(hazard_cycle) = ciclos report "hazard_cycle difere da contagem do testbench" severity warning;
        elsif done = '1' then
            assert not ESPERA_ABORTO report "Conflito esperado não foi detectado" severity error;
            
            -- 3.4 Verificação automática: compara registradores com o esperado
            file_open(st, f_esp, ESPERADO_FILE, read_mode);
            if st = open_ok then
                while not endfile(f_esp) loop
                    readline(f_esp, l);
                    next when l'length = 0;
                    next when l(1) = '#';
                    read(l, reg_num);
                    hread(l, valor);
                    
                    dbg_reg_addr <= std_logic_vector(to_unsigned(reg_num, 5));
                    wait for 1 ns; -- leitura combinacional estabiliza
                    
                    if dbg_reg_data /= valor then
                        erros := erros + 1;
                        report "Reg " & integer'image(reg_num) & ": esperado 0x" & to_hstring(valor) &
                               ", obtido 0x" & to_hstring(dbg_reg_data) severity error;
                    end if;
                end loop;
                file_close(f_esp);
            else
                report "Não foi possível abrir " & ESPERADO_FILE severity failure;
            end if;
        else
            report ORG_NOME & ": tempo esgotado em " & integer'image(MAX_CICLOS) & " ciclos" severity failure;
        end if;

        -- 3.5 Métricas: uma linha por execução em metricas.csv
        if instrs > 0 then
            cpi := real(ciclos) / real(instrs);
            ipc := real(instrs) / real(ciclos);
        end if;
        ocup := real(ocupados) / real(ciclos * NUM_SLOTS);
        
        file_open(st, f_csv, "metricas.csv", append_mode);
        write(l, ORG_NOME & "," & PROG_FILE & "," & integer'image(ciclos) & "," &
                 integer'image(instrs) & "," & real'image(cpi) & "," &
                 real'image(ipc) & "," & real'image(ocup) & "," &
                 integer'image(erros));
        writeline(f_csv, l);
        file_close(f_csv);

        -- 3.6 Encerramento
        report ORG_NOME & ": fim da simulação, " & integer'image(ciclos) &
               " ciclos, " & integer'image(erros) & " erro(s)";
        fim_sim <= true;
        wait;
    end process;
end architecture;