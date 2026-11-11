library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pc is
    port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        freeze    : in  std_logic; -- '1' congela (done ou hazard)
        next_pc   : in  std_logic_vector(31 downto 0);
        pc_out    : out std_logic_vector(31 downto 0)
    );
end entity;

architecture rtl of pc is
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                pc_out <= (others => '0');
            elsif freeze = '0' then
                pc_out <= next_pc;
            end if;
        end if;
    end process;
end architecture;