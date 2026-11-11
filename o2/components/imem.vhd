library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity imem is
    generic (
        PROG_FILE : string := "t0.hex";
        MEM_SIZE  : integer := 256
    );
    port (
        addr     : in  std_logic_vector(31 downto 0);
        instr    : out std_logic_vector(31 downto 0)
    );
end entity;

architecture rtl of imem is
    type mem_array is array (0 to MEM_SIZE-1) of std_logic_vector(31 downto 0);
    signal mem : mem_array := (others => (others => '0'));
    signal loaded : boolean := false;
begin
    -- Carrega arquivo .hex na inicialização
    process
        file f : text;
        variable l : line;
        variable v : std_logic_vector(31 downto 0);
        variable i : integer := 0;
        variable status : file_open_status;
    begin
        file_open(status, f, PROG_FILE, read_mode);
        if status = open_ok then
            while not endfile(f) and i < MEM_SIZE loop
                readline(f, l);
                if l'length > 0 then
                    hread(l, v);
                    mem(i) <= v;
                    i := i + 1;
                end if;
            end loop;
            file_close(f);
        end if;
        loaded <= true;
        wait;
    end process;

    -- Leitura combinacional protegida
    process(addr, mem, loaded)
        variable idx : integer;
    begin
        if not loaded then
            instr <= (others => '0');
        else
            idx := to_integer(unsigned(addr(9 downto 2)));
            if idx < MEM_SIZE then
                instr <= mem(idx);
            else
                instr <= (others => '0');
            end if;
        end if;
    end process;
end architecture;