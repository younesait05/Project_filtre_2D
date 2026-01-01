library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity Clock_Counter is
    Generic (
        CYCLE_COUNT : integer :=  100
    );
    Port (
        clk          : in  std_logic;             
        reset        : in  std_logic;            
        enable       : in  std_logic;             
        done         : out std_logic             
                        
    );
end Clock_Counter;

architecture Behavioral of Clock_Counter is
    signal counter : integer := 0; 
    signal count_done : std_logic := '0';
begin

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                counter <= 0;
                count_done <= '0';
            elsif enable = '1' then
                if counter < CYCLE_COUNT - 1 then
                    counter <= counter + 1;
                    count_done <= '0';
                else
                    count_done <= '1'; 
                    counter <= 0;      
                end if;
            else
                count_done <= '0';
            end if;
        end if;
    end process;

    
    done <= count_done;
    

end Behavioral;
