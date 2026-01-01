

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;


entity tb_fifo is

end tb_fifo;

architecture Behavioral of tb_fifo is
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
     constant tmp : time := 10 ns;      
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
            wait for tmp;
            clk <= '1';
            wait for tmp;
         end loop;
     end process;
     stim : process 
        
     begin
         rst <= '1';
         wait for 100 ns;
         rst <= '0';
         wait for 100 ns;
         
         wait until clk'event and clk='1';
         wait for 2 ns;
         
         for i in 0 to 15 loop
            wait until clk'event and clk='1';
            wait for 2 ns;
            if full ='0' then
                din <= std_logic_vector(to_unsigned(i, 8));
                wr_en <= '1';
            else 
                wr_en <= '0';
            end if;
            wait until clk'event and clk='1';
            wr_en <= '0';
         end loop;
         
         for j in 0 to 4 loop 
            wait until (clk'event and clk='1');
         end loop;
         
         for i in 0 to 15 loop
            wait until (clk'event and clk='1');
            wait for 2 ns;
            if empty ='0' then
                rd_en <= '1';
            else 
                rd_en <='0';
            end if;
            wait until (clk'event and clk='1');
            
            rd_en <= '0';
            
         end loop;
         
     end process;           

end Behavioral;
