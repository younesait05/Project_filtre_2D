library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity tb_lena_dupliq is
       
end;

architecture arch_tb_lena_dupliq of tb_lena_dupliq is

  component fifo_gen 
    port (  clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            wr_en : IN STD_LOGIC;
            rd_en : IN STD_LOGIC;
            prog_full_thresh : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
            dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            full : OUT STD_LOGIC;
            empty : OUT STD_LOGIC;
            prog_full : OUT STD_LOGIC;
            wr_rst_busy : OUT STD_LOGIC;
            rd_rst_busy : OUT STD_LOGIC
     );
  end component;
  
  signal clk : STD_LOGIC :='0';
  signal rst : STD_LOGIC:='0';
  signal din : STD_LOGIC_VECTOR(7 DOWNTO 0):=(others => '0');
  signal wr_en : STD_LOGIC:='0';
  signal rd_en : STD_LOGIC:='0';
  signal prog_full_thresh : STD_LOGIC_VECTOR(9 DOWNTO 0):=(others => '0');
  signal dout : STD_LOGIC_VECTOR(7 DOWNTO 0);
  signal full : STD_LOGIC;
  signal empty : STD_LOGIC;
  signal prog_full : STD_LOGIC;
  signal wr_rst_busy : STD_LOGIC;
  signal rd_rst_busy : STD_LOGIC; 
    
  signal I1 : std_logic_vector (7 downto 0);
  signal O1 : std_logic_vector (7 downto 0); 
  
  constant tmp : time := 10ns;
  
  
begin

  uut: fifo_gen 
        port map ( 
            clk => clk,
            rst => rst,
            din => din, 
            wr_en => wr_en,
            rd_en => rd_en,
            prog_full_thresh => prog_full_thresh,
            dout => dout ,
            full => full,
            empty => empty,
            prog_full => prog_full,
            wr_rst_busy => wr_rst_busy,
            rd_rst_busy => wr_rst_busy );
            
    clk_proc:process 
     begin
        while true loop
            clk <= '0';
            wait for tmp/2;
            clk <= '1';
            wait for tmp/2;
         end loop;
     end process;
     
 p_read : process
  FILE vectors : text;
  variable Iline : line;
  variable I1_var :std_logic_vector (7 downto 0);
 
    begin
    file_open (vectors,"Lena128x128g_8bits.dat", read_mode);
    rst <= '1';
    wait for 100 ns;
    rst <= '0';
    wait for 200 ns;
    
    
    while not endfile(vectors) loop
      readline (vectors,Iline);
      read (Iline,I1_var);
                
      I1 <= I1_var;
	  wait until clk'event and clk = '1';
	  wait for 3 ns;
	  if full ='0' then 
	   din <= I1_var;
	   wr_en <= '1';
	  else 
         wr_en <= '0';
      end if;
    end loop;
    file_close (vectors);
    wait;
 end process;

p_write: process
  variable comp_pixel : integer := 0;
  constant nb_pixel : integer := 16384;
  file results : text;
  variable OLine : line;
  variable O1_var :std_logic_vector (7 downto 0);
    
    begin
    file_open (results,"Lena128x128g_8bits_r.dat", write_mode);
    wait for 10 ns;
    while comp_pixel < nb_pixel loop
        wait until (clk'event and clk='1');
            wait for 2 ns;
            if empty ='0' then
                rd_en <= '1';
                if dout /= "UUUUUUUU" then
                    O1 <= dout;
                    write (Oline, O1, right, 2);
                    writeline (results, Oline); 
                    comp_pixel := comp_pixel +1;
                end if;
            else 
                rd_en <='0';
            end if; 
    end loop;
    file_close (results);
    wait;
 end process;

end arch_tb_lena_dupliq;


