library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gaussian is
  Port (p00, p01, p02 : in std_logic_vector(7 downto 0); 
        p10, p11, p12 : in std_logic_vector(7 downto 0); 
        p20, p21, p22 : in std_logic_vector(7 downto 0); 
        output  : out std_logic_vector(7 downto 0) 
        );
end gaussian;

architecture Behavioral of gaussian is

begin
    process(p00, p01, p02, p10, p11, p12, p20, p21, p22)
        variable temp_sum : integer;
        variable norm : integer;
    begin
        
        temp_sum := 1 * to_integer(unsigned(p00)) +
                    2 * to_integer(unsigned(p01)) +
                    1 * to_integer(unsigned(p02)) +
                    2 * to_integer(unsigned(p10)) +
                    4 * to_integer(unsigned(p11)) + 
                    2 * to_integer(unsigned(p12)) +
                    1 * to_integer(unsigned(p20)) +
                    2 * to_integer(unsigned(p21)) +
                    1 * to_integer(unsigned(p22));

        
        
        norm := temp_sum / 16;
        if norm < 0 then norm := 0; end if;
        if norm > 255 then norm := 255; end if;

        
        output <= std_logic_vector(to_unsigned(norm, 8));
    end process;


end Behavioral;