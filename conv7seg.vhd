-- SPDX-License-Identifier: MIT
-- SPDX-License-Text: Copywright © 2021 Gabriel Souza Franco

library ieee;
use ieee.std_logic_1164.all;

entity conv7seg is port (
    bin : in  std_logic_vector(3 downto 0);
    en  : in  std_logic;
    hex : out std_logic_vector(0 to 6)
);
end conv7seg;

architecture structural of conv7seg is
begin
process (all) begin
    if en then
        case bin is
            when "0000" => hex <= "0000001";
            when "0001" => hex <= "1001111";
            when "0010" => hex <= "0010010";
            when "0011" => hex <= "0000110";
            when "0100" => hex <= "1001100";
            when "0101" => hex <= "0100100";
            when "0110" => hex <= "0100000";
            when "0111" => hex <= "0001111";
            when "1000" => hex <= "0000000";
            when "1001" => hex <= "0001100";
            when "1010" => hex <= "0001000";
            when "1011" => hex <= "1100000";
            when "1100" => hex <= "0110001";
            when "1101" => hex <= "1000010";
            when "1110" => hex <= "0110000";
            when "1111" => hex <= "0111000";
        end case;
    else
        hex <= "1111110";
    end if;
end process;
end;
