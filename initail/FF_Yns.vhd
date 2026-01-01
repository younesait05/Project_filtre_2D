library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FF_Yns is
    Port ( D : in STD_LOGIC_VECTOR (7 downto 0);
           Q : out STD_LOGIC_VECTOR (7 downto 0);
           CLK : in STD_LOGIC;
           EN : in STD_LOGIC;
           RESET : in STD_LOGIC);
end FF_Yns;

architecture FF_Yns_arch of FF_Yns is

signal temp: STD_LOGIC_VECTOR (7 downto 0);

begin

p1: process(CLK,RESET)
begin
    if (RESET ='1') then temp <= (others => '0');
    elsif (CLK'event and CLK='1') then
        if (EN ='1') then
            temp <= D;                                  
        end if;
    end if;
    
    
end process;

Q <= temp; 



end FF_Yns_arch;
