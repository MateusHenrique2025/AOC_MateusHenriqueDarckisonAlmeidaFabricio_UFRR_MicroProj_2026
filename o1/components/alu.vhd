library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
    port (
        a        : in  std_logic_vector(31 downto 0);
        b        : in  std_logic_vector(31 downto 0);
        alu_ctrl : in  std_logic_vector(2 downto 0);
        result   : out std_logic_vector(31 downto 0);
        zero     : out std_logic
    );
end entity;

architecture rtl of alu is
    signal res : std_logic_vector(31 downto 0);
begin
    process(a, b, alu_ctrl)
    begin
        case alu_ctrl is
            when "000" => res <= std_logic_vector(unsigned(a) + unsigned(b)); -- ADD
            when "001" => res <= std_logic_vector(unsigned(a) - unsigned(b)); -- SUB
            when "010" => res <= a and b;                                     -- AND
            when "011" => res <= a or b;                                      -- OR
            when "100" => -- SLT
                if signed(a) < signed(b) then res <= x"00000001";
                else res <= x"00000000"; end if;
            when others => res <= (others => '0');
        end case;
    end process;
    result <= res;
    zero   <= '1' when res = x"00000000" else '0';
end architecture;