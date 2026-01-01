library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity tb_lena_dupliq is
       
end;

architecture arch_tb_lena_dupliq of tb_lena_dupliq is


  signal I1 : std_logic_vector (7 downto 0);
  signal CLK : std_logic;
  signal O1 : std_logic_vector (7 downto 0); 
  signal DATA_AVAILABLE : std_logic;
  
  
  signal clk_TB : std_logic := '0';
  signal rest_TB : std_logic;
 
  
   
  
  constant clck_period : time := 10 ns;
  
  component mm_cache 

 Port (
        clk  : in  STD_LOGIC;      
        rst  : in  STD_LOGIC;      
        din  : in  STD_LOGIC_VECTOR(7 downto 0); 
        dout : out STD_LOGIC_VECTOR(7 downto 0);
        
        wr_en : in STD_LOGIC             
    );
  
  
  end component;
begin

memory: mm_cache 

 Port map (
        clk  => clk_TB,      
        rst  => rest_TB,      
        din  => I1,
        dout => O1,
        
        wr_en => DATA_AVAILABLE             
    );

clck_process : process
    begin
        clk_TB <= '0';
        wait for clck_period/2;
        clk_TB <= '1';
        wait for clck_period/2;
        
        
        
    end process;
    
    

 p_read : process
 
   
  FILE vectors : text;
  variable Iline : line;
  variable I1_var :std_logic_vector (7 downto 0);
 
    begin
       
	DATA_AVAILABLE <= '0';
    file_open (vectors,"C:/Users/hp/projet filtre/projet filtre.srcs/sim_1/new/Lena128x128g_8bits.dat", read_mode);
    wait for 200 ns;
    
    while not endfile(vectors) loop
      readline (vectors,Iline);
      read (Iline,I1_var);
                
      I1 <= I1_var;
	  DATA_AVAILABLE <= '1';
	  
	  wait for clck_period;
    end loop;
    DATA_AVAILABLE <= '0';
    wait for clck_period;
    file_close (vectors);
    wait;
 end process;

p_write: process
  file results : text;
  variable OLine : line;
  variable count_out : integer := 0;
  constant EXPECTED : integer := 16128; 
begin
  file_open(results,"C:/Users/hp/projet filtre/projet filtre.srcs/sim_1/new/Lena128x128g_8bits_r.dat", write_mode);

  
  wait until rest_TB = '0';
  wait until rising_edge(clk_TB);

  while count_out < EXPECTED loop
    wait until rising_edge(clk_TB);

    -- On écrit seulement si la sortie n'est pas inconnue (pas U/X)
    if not is_x(O1) then
      write(OLine, O1);
      writeline(results, OLine);
      count_out := count_out + 1;
    end if;
  end loop;

  file_close(results);
  wait;
end process;

 
sim: process
    begin
        
       
        rest_TB <= '1';
        
     
        wait for clck_period*15;
        rest_TB <= '0';
  
        wait for clck_period*12;
        
 
        
        
        
 
        wait;                                                                                      

 end process sim;

      CLK <= clk_TB;
      
      
  
end arch_tb_lena_dupliq;