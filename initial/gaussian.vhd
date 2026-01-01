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

    
    signal normalized_value : integer := 0;
begin
    process(p00, p01, p02, p10, p11, p12, p20, p21, p22)
        variable temp_sum : integer := 0;
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

        
        
        normalized_value <= temp_sum / 16;

        
        output <= std_logic_vector(to_unsigned(normalized_value, 8));
    end process;


end Behavioral;
