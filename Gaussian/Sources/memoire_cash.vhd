library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity mm_cache is
    Port (
        clk  : in  STD_LOGIC;      
        rst  : in  STD_LOGIC;      
        din  : in  STD_LOGIC_VECTOR(7 downto 0); 
        dout : out STD_LOGIC_VECTOR(7 downto 0); 
        
        wr_en : in STD_LOGIC             
    );
end mm_cache;

architecture Behavioral of mm_cache is

    signal sobel_h, sobel_v : std_logic_vector(7 downto 0); -- pour filtre sobel

    signal dff1_out, dff2_out, dff3_out : STD_LOGIC_VECTOR(7 downto 0);
    signal dff4_out, dff5_out, dff6_out : STD_LOGIC_VECTOR(7 downto 0);
    signal dff7_out, dff8_out, dff9_out : STD_LOGIC_VECTOR(7 downto 0);

    signal din_1 : std_logic_vector(7 downto 0);
    signal dout_f1: std_logic_vector(7 downto 0);
    signal wr1 : std_logic;
    signal rd1 : std_logic;
    signal full1 : std_logic;
    signal empty1 : std_logic;
    signal prog_full1 : std_logic;

    signal din_2 : std_logic_vector(7 downto 0);
    signal dout_f2: std_logic_vector(7 downto 0);
    signal wr2 : std_logic;
    signal rd2 : std_logic;
    signal full2 : std_logic;
    signal empty2 : std_logic;
    signal prog_full2 : std_logic;

    signal ten_cycles : std_logic;
    signal enable : std_logic;
    signal enable1: std_logic;
    signal done_s : std_logic;
    signal done_s1 : std_logic;
    signal enable_fd1 : std_logic := '0';
    signal enable_fd2 : std_logic := '0';
    signal enable_fd3 : std_logic := '0';
    
    
    signal P8, P7, P6, P5, P4, P3, P2, P1, P0 : STD_LOGIC_VECTOR(7 downto 0);
    signal P87, P65, P32, P10 : STD_LOGIC_VECTOR(8 downto 0);
    signal P8765, P3210 : STD_LOGIC_VECTOR(9 downto 0);
    signal P0T : STD_LOGIC_VECTOR(10 downto 0);
    signal P0TT : STD_LOGIC_VECTOR(7 downto 0); 
    signal gaus:STD_LOGIC_VECTOR(7 downto 0);

    type Liste_Stage is (STAGE1, STAGE2, STAGE3, STAGE4, STAGE5, STAGE6, STAGE7 );
    signal STAGE : Liste_Stage ;
    component add_pixels is
    generic (
        bus_width : integer := 8  
    );
    Port ( 
        clk  : in  STD_LOGIC;                           
        A    : in  STD_LOGIC_VECTOR(bus_width-1 downto 0); 
        B    : in  STD_LOGIC_VECTOR(bus_width-1 downto 0); 
        Sum  : out STD_LOGIC_VECTOR(bus_width downto 0)    
    );
end component;

    component compt_decompt is
        Port (
            clk : in  std_logic;
            enable : in  std_logic;      
            reset : in  std_logic;   
            ten_cycles : out std_logic
        );
    end component;

    component Clock_Counter is
        Generic (
            CYCLE_COUNT : integer := 3 
        );
        Port (
            clk          : in  std_logic;             
            reset        : in  std_logic;             
            enable       : in  std_logic;             
            done         : out std_logic                               
        );
    end component;
component gaussian is
  Port (p00, p01, p02 : in std_logic_vector(7 downto 0); -- Top row of 3x3
        p10, p11, p12 : in std_logic_vector(7 downto 0); -- Middle row of 3x3
        p20, p21, p22 : in std_logic_vector(7 downto 0); -- Bottom row of 3x3
        output  : out std_logic_vector(7 downto 0) -- Filtered pixel 
        );
end component;

    component FF_Yns is
        Port (
            D     : in  STD_LOGIC_VECTOR(7 downto 0); 
            Q     : out STD_LOGIC_VECTOR(7 downto 0); 
            CLK   : in  STD_LOGIC;      
            EN    : in  STD_LOGIC;
            RESET : in  STD_LOGIC
        );
    end component;
    
    component fifo_gen is
        Port (
             clk : IN STD_LOGIC;
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
  
begin
g1:gaussian
    port map ( P22 => p8,
               P21 => p7,
               P20 => p6,
               P12 => p5,
               P11 => p4,
               P10 => p3,
               P02 => p2,
               P01 => p1,
               P00 => p0,
               output => gaus
           ); 
     



    DFF1: FF_Yns
        Port Map (
            D => din,
            Q => dff1_out,
            CLK => clk,
            EN => enable_fd1,
            RESET => rst
        );
        
    DFF2: FF_Yns
        Port Map (
            D => dff1_out,
            Q => dff2_out,
            CLK => clk,
            EN => enable_fd1,
            RESET => rst
        );
        
    DFF3: FF_Yns
        Port Map (
            D => dff2_out,
            Q => dff3_out,
            CLK => clk,
            EN => enable_fd1,
            RESET => rst
        ); 

    FIFO1: fifo_gen
        port map(
            clk => clk,
            rst => rst,
            din => dff3_out,
            wr_en => wr1,
            rd_en => rd1,
            prog_full_thresh=>"0001111100",
            dout => dout_f1,
            full => full1,
            empty => empty1,
            prog_full => prog_full1
        );   
    
    DFF4: FF_Yns
        Port Map (
            D => dout_f1,
            Q => dff4_out,
            CLK => clk,
            EN => enable_fd2,
            RESET => rst
        );
        
    DFF5: FF_Yns
        Port Map (
            D => dff4_out,
            Q => dff5_out,
            CLK => clk,
            EN => enable_fd2,
            RESET => rst
        );
        
    DFF6: FF_Yns
        Port Map (
            D => dff5_out,
            Q => dff6_out,
            CLK => clk,
            EN => enable_fd2,
            RESET => rst
        ); 

    FIFO2: fifo_gen
        port map(
            clk => clk,
            rst => rst,
            din => dff6_out,
            wr_en => wr2,
            rd_en => rd2,
            prog_full_thresh=>"0001111100",
            dout => dout_f2,
            full => full2,
            empty => empty2,
            prog_full => prog_full2
        ); 

    DFF7: FF_Yns
        Port Map (
            D => dout_f2,
            Q => dff7_out,
            CLK => clk,
            EN => enable_fd3,
            RESET => rst
        );
        
    DFF8: FF_Yns
        Port Map (
            D => dff7_out,
            Q => dff8_out,
            CLK => clk,
            EN => enable_fd3,
            RESET => rst
        );
        
    DFF9: FF_Yns
        Port Map (
            D => dff8_out,
            Q => dff9_out,
            CLK => clk,
            EN => enable_fd3,
            RESET => rst
        ); 
        
 
        
    compt1: compt_decompt     
       Port map ( 
           clk => clk,
           enable => enable,   
           reset => rst,   
           ten_cycles => ten_cycles
       );
           
    compt2: Clock_Counter 
        generic map(
            CYCLE_COUNT => 3 
        )
        Port map (
            clk => clk,             
            reset => rst,             
            enable => enable1,             
            done => done_s                               
        );
        P8 <= dff1_out;
        P7 <= dff2_out;
        P6 <= dff3_out;
        
        P5 <= dff4_out;
        P4 <= dff5_out;
        P3 <= dff6_out;
        P2 <= dff7_out;
        P1 <= dff8_out;
        P0 <= dff9_out;
        
        
        sobel_calc : process(P0,P1,P2,P3,P5,P6,P7,P8)
            variable gx, gy : integer;
            variable ax, ay : integer;
        begin
          -- Gx = (P6 + 2*P3 + P0) - (P8 + 2*P5 + P2)
           gx := to_integer(unsigned(P6)) + 2*to_integer(unsigned(P3)) + to_integer(unsigned(P0))
                - (to_integer(unsigned(P8)) + 2*to_integer(unsigned(P5)) + to_integer(unsigned(P2)));

          -- Gy = (P8 + 2*P7 + P6) - (P2 + 2*P1 + P0)
           gy := to_integer(unsigned(P8)) + 2*to_integer(unsigned(P7)) + to_integer(unsigned(P6))
                 - (to_integer(unsigned(P2)) + 2*to_integer(unsigned(P1)) + to_integer(unsigned(P0)));

          -- abs + saturation 0..255
            ax := abs(gx);
            if ax > 255 then ax := 255; end if;
    
            ay := abs(gy);
            if ay > 255 then ay := 255; end if;

            sobel_h <= std_logic_vector(to_unsigned(ax, 8));
            sobel_v <= std_logic_vector(to_unsigned(ay, 8));
        end process;

      add1: add_pixels generic map (bus_width => 8) port map(clk,P8,P7,P87);
      add2: add_pixels generic map (bus_width => 8) port map(clk,P6,P5,P65);
      add3: add_pixels generic map (bus_width => 8)port map(clk,P3,P2,P32);
      add4: add_pixels generic map (bus_width => 8) port map(clk,P1,P0,P10);
      add5: add_pixels generic map (bus_width => 9) port map(clk,P87,P65,P8765);
      add6: add_pixels generic map (bus_width => 9) port map(clk,P32,P10,P3210);
      add7:add_pixels generic map (bus_width => 10) port map(clk,P8765,P3210,P0T);
      


    connection: process(clk,rst)
    begin
        if (rst = '1') then
            STAGE <= STAGE1;
            Wr1<='0';
            Wr2<='0';
            rd1<='0';
            rd2<='0';
            
            
        elsif (clk'event and clk = '1') then
            case STAGE is
            when STAGE1 =>
                enable <= '1';   
                if ((full1 and empty1) = '1') then
                    STAGE <= STAGE1; -- Rester dans l'etat si les conditions ne sont pas remplies
                else
                    STAGE <= STAGE2; -- Passer  l'etat suivant
                    enable <= '0';
                end if;

            when STAGE2 =>
                rd1 <= prog_full1;
                rd2 <= prog_full2;
                if wr_en = '1' then
                    enable_fd1 <= '1';
                    enable1 <= '1';
                    if done_s = '0' then
                        STAGE <= STAGE2;
                    else
                        enable1 <= '0';
                        STAGE <= STAGE3;  
                    end if;         
                else
                    STAGE <= STAGE2;
                end if;

            when STAGE3 =>
                enable_fd1 <= '1';
                rd1 <= prog_full1;
                rd2 <= prog_full2;
                wr1 <= '1';
                if prog_full1 = '1' then
                    STAGE <= STAGE4;
                else
                    STAGE <= STAGE3;    
                end if;

            when STAGE4 =>
                wr1 <= '1';   
                enable_fd1 <= '1';                                             
                rd1 <= prog_full1;
                rd2 <= prog_full2;
                enable_fd2 <= '1';
                enable1 <= '1';
                if done_s = '0' then
                    STAGE <= STAGE4;
                else
                    enable1 <= '0';
                    STAGE <= STAGE5;  
                end if;

            when STAGE5 =>
                wr2 <= '1';
                wr1 <= '1';
                rd1 <= prog_full1;
                rd2 <= prog_full2;
                enable_fd1 <= '1';
                enable_fd2 <= '1';
                if prog_full2 = '1' then
                    STAGE <= STAGE6;
                else
                    STAGE <= STAGE5;    
                end if;

            when STAGE6 =>
                wr2 <= '1';
                wr1 <= '1';
                rd1 <= prog_full1;
                rd2 <= prog_full2;
                enable_fd3 <= '1';
                enable_fd2 <= '1';
                enable_fd1 <= '1';
                enable1 <= '1';
                if done_s = '0' then
                    STAGE <= STAGE6;
                else
                    STAGE <= STAGE7;
                end if;

            when STAGE7 =>
                enable_fd3 <= '1';
                wr2 <= '1';
                rd1 <= prog_full1;
                rd2 <= prog_full2;
                enable1 <= '1';

                
                --dout <= P0T(10 downto 3);-- Sortie du filtre base sur les pixels extraits.
                --dout <= sobel_h; -- pour sobel horizontal
                --dout <= sobel_v; --pour sobel vertical
                dout <= gaus; --pour filtre gaussian
                
                if done_s = '0' then
                    STAGE <= STAGE7; -- Rester dans l'etat tant que le processus n'est pas termine
       
                end if;

            when others =>
                -- En cas d'etat inattendu, revenir Ã  l'etat initial 
                STAGE <= STAGE1;
        end case;
            
            
            
            
        end if;
    end process connection;
    
    
end Behavioral;
-- Younes AIT LAHCEN

