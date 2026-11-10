library ieee;
use ieee.std_logic_1164.all;

entity control is
    port (
        opcode     : in  std_logic_vector(5 downto 0);
        funct      : in  std_logic_vector(5 downto 0);
        reg_dst    : out std_logic;
        alu_src    : out std_logic;
        mem_to_reg : out std_logic;
        reg_write  : out std_logic;
        mem_read   : out std_logic;
        mem_write  : out std_logic;
        branch     : out std_logic;
        alu_ctrl   : out std_logic_vector(2 downto 0);
        is_break   : out std_logic
    );
end entity;

architecture rtl of control is
begin
    process(opcode, funct)
    begin
        -- Valores padrão (evita latches)
        reg_dst    <= '0'; alu_src    <= '0'; mem_to_reg <= '0';
        reg_write  <= '0'; mem_read   <= '0'; mem_write  <= '0';
        branch     <= '0'; alu_ctrl   <= "000"; is_break <= '0';

        case opcode is
            -- R-Type
            when "000000" => 
                reg_dst   <= '1'; 
                reg_write <= '1';
                case funct is
                    when "100000" => alu_ctrl <= "000"; -- add
                    when "100010" => alu_ctrl <= "001"; -- sub
                    when "100100" => alu_ctrl <= "010"; -- and
                    when "100101" => alu_ctrl <= "011"; -- or
                    when "101010" => alu_ctrl <= "100"; -- slt
                    when "001101" => is_break <= '1';   -- break
                    when others   => null;
                end case;
            -- I-Type
            when "001000" => -- addi
                alu_src   <= '1'; reg_write <= '1'; alu_ctrl <= "000";
            when "100011" => -- lw
                alu_src   <= '1'; mem_read  <= '1'; mem_to_reg <= '1'; reg_write <= '1';
            when "101011" => -- sw
                alu_src   <= '1'; mem_write <= '1';
            when "000100" => -- beq
                branch    <= '1'; alu_ctrl  <= "001"; -- sub para comparar
            when others   => null;
        end case;
    end process;
end architecture;