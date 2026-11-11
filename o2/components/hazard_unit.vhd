library ieee;
use ieee.std_logic_1164.all;

entity hazard_unit is
    port (
        rs_addr_id    : in  std_logic_vector(4 downto 0);
        rt_addr_id    : in  std_logic_vector(4 downto 0);
        reg_write_ex  : in  std_logic;
        rd_addr_ex    : in  std_logic_vector(4 downto 0);
        mem_read_ex   : in  std_logic;
        reg_write_mem : in  std_logic;
        rd_addr_mem   : in  std_logic_vector(4 downto 0);
        branch_id     : in  std_logic;
        zero_ex       : in  std_logic;
        mem_unificada : in  boolean;
        mem_read_ex_b : in  std_logic;
        hazard_abort  : out std_logic;
        hazard_type   : out std_logic_vector(1 downto 0);
        stall_if      : out std_logic;
        flush_id_ex   : out std_logic
    );
end entity;

architecture rtl of hazard_unit is
    function to_logic(v : std_logic) return std_logic is
    begin
        if is_x(v) then
            return '0';
        else
            return v;
        end if;
    end function;
begin
    process(all)
        variable rw_ex, mr_ex, rw_mem, br_id, zr_ex : std_logic;
    begin
        -- Limpando os sinais
        rw_ex  := to_logic(reg_write_ex);
        mr_ex  := to_logic(mem_read_ex);
        rw_mem := to_logic(reg_write_mem);
        br_id  := to_logic(branch_id);
        zr_ex  := to_logic(zero_ex);

        hazard_abort <= '0';
        hazard_type  <= "00";
        stall_if     <= '0';
        flush_id_ex  <= '0';

        if (rw_ex = '1' and rd_addr_ex /= "00000" and 
           (rd_addr_ex = rs_addr_id or rd_addr_ex = rt_addr_id)) then
            hazard_abort <= '1';
            hazard_type  <= "01";
            stall_if     <= '1';
        elsif (rw_mem = '1' and rd_addr_mem /= "00000" and 
              (rd_addr_mem = rs_addr_id or rd_addr_mem = rt_addr_id)) then
            hazard_abort <= '1';
            hazard_type  <= "01";
            stall_if     <= '1';
        elsif (mem_unificada = true and mr_ex = '1') then
            hazard_abort <= '1';
            hazard_type  <= "10";
            stall_if     <= '1';
        elsif (br_id = '1' and zr_ex = '1') then
            hazard_abort <= '1';
            hazard_type  <= "11";
            flush_id_ex  <= '1';
        end if;
    end process;
end architecture;