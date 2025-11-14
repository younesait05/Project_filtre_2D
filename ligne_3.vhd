library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ligne_3 is
    port(
        clk   : in  std_logic;
        rst   : in  std_logic;
        en    : in  std_logic;
        din   : in  std_logic_vector(7 downto 0);
        p0    : out std_logic_vector(7 downto 0); 
        p1    : out std_logic_vector(7 downto 0); 
        p2    : out std_logic_vector(7 downto 0)  
    );
end entity;

architecture rtl of ligne_3 is
    component demo_P
        port (
            D   : in  std_logic_vector(7 downto 0);
            Q   : out std_logic_vector(7 downto 0);
            CLK : in  std_logic;
            EN  : in  std_logic;
            RST : in  std_logic
        );
    end component;

    signal s1, s2, s3 : std_logic_vector(7 downto 0);
begin
    ff_a: demo_P port map (D=>din,  Q=>s1, CLK=>clk, EN=>en, RST=>rst);
    ff_b: demo_P port map (D=>s1,   Q=>s2, CLK=>clk, EN=>en, RST=>rst);
    ff_c: demo_P port map (D=>s2,   Q=>s3, CLK=>clk, EN=>en, RST=>rst);

    p0 <= s1;
    p1 <= s2;
    p2 <= s3;
end architecture;
