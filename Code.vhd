library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity project_reti_logiche is
  port (
    i_clk : in std_logic;
    i_rst : in std_logic;
    i_start : in std_logic;
    i_data : in std_logic_vector(7 downto 0);
    o_address : out std_logic_vector(15 downto 0);
    o_done : out std_logic;
    o_en : out std_logic;
    o_we : out std_logic;
    o_data : out std_logic_vector (7 downto 0));
end project_reti_logiche;


architecture Behavioral of project_reti_logiche is
component datapath is
    Port ( i_clk : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           i_data : in STD_LOGIC_VECTOR (7 downto 0);
           o_data : out STD_LOGIC_VECTOR (7 downto 0);
           o_address: out std_logic_vector(15 downto 0);
           max_l: in STD_LOGIC;
           righe_l: in STD_LOGIC;
           colonne_l : in STD_LOGIC;
           newpix_l : in STD_LOGIC;
           temppix_l: in std_logic;
           min_l : in STD_LOGIC;
           next_address_l: in std_logic;
           write_here_l: in std_logic;
           deltav_l: in std_logic;
           shiftlev_l: in std_logic;
           max_sel: in std_logic;
           min_sel: in std_logic;
           next_address_sel: in std_logic_vector(1 downto 0);
           write_here_sel: in std_logic_vector(1 downto 0);
           sel_o_address: in std_logic;
           done_phase : out std_logic;
           o_done : out std_logic;
           i_read: in std_logic;
           phase_2 : in std_logic;
           i_start: in std_logic;
           i_wait: in std_logic;
           righe_sel : in std_logic;
           colonne_sel: in std_logic);
end component;
type stato is (RESET, INIZIALE,LEGGI_COLONNE , PREPARA_RAM, LEGGI_RIGHE,CHECK_FINE, PREPARA_RAM_2, LEGGI_MAX_MIN,RESET_INDIRIZZI,CALC_DELTA,CALC_SHIFT,PREPARA_RAM_3,LEGGI_PIXEL,CALC_NEW_PIXEL,SCRIVI_MEM,PREPARA_INDIRIZZI, ASPETTA);

signal stato_corr,stato_prossimo: stato;
signal max_l,righe_l,colonne_l, newpix_l,temppix_l, min_l,next_address_l,write_here_l,deltav_l,shiftlev_l : std_logic;
signal max_sel,min_sel,sel_o_address, done_phase, i_read, phase_2,i_wait, righe_sel, colonne_sel: STD_LOGIC;
signal next_address_sel, write_here_sel: std_logic_vector(1 downto 0);


begin
    DATAPATH0: datapath port map(
           i_clk,
           i_rst ,
           i_data ,
           o_data ,
           o_address,
           max_l,
           righe_l,
           colonne_l ,
           newpix_l ,
           temppix_l,
           min_l,
           next_address_l,
           write_here_l,
           deltav_l,
           shiftlev_l,
           max_sel,
           min_sel,
           next_address_sel,
           write_here_sel,
           sel_o_address,
           done_phase ,
           o_done,
           i_read,
           phase_2,
           i_start,
           i_wait,
           righe_sel,
           colonne_sel
    );
    
process(i_clk, i_rst)
begin 
if(i_rst = '1') then
   stato_corr <= RESET;
  elsif(rising_edge(i_clk)) then
  stato_corr<= stato_prossimo;
  end if;
  end process;
  
 
 process(stato_corr, i_start, done_phase, o_done)
 begin 
 case stato_corr is
 when RESET =>
 if(i_start = '0') then
 stato_prossimo <= RESET;
 elsif (i_start = '1') then
 stato_prossimo <= INIZIALE;
 end if;
 when INIZIALE =>
 stato_prossimo <= LEGGI_COLONNE;
 when LEGGI_COLONNE =>
 stato_prossimo <= PREPARA_RAM;
 when PREPARA_RAM =>
 if(o_done = '1') then 
 stato_prossimo <= ASPETTA;
 else
 stato_prossimo <= LEGGI_RIGHE;
 end if;
 when LEGGI_RIGHE =>
 stato_prossimo <=CHECK_FINE;
 WHEN CHECK_FINE =>
 if(o_done = '1') then 
 stato_prossimo <= ASPETTA;
 else
 stato_prossimo <= PREPARA_RAM_2;
 end if;
 when PREPARA_RAM_2 =>
 stato_prossimo <= LEGGI_MAX_MIN;
 when LEGGI_MAX_MIN =>
 if(done_phase = '1') then
 stato_prossimo <= RESET_INDIRIZZI;
 else
 stato_prossimo <= PREPARA_RAM_2;
 end if;
when RESET_INDIRIZZI =>
stato_prossimo <= CALC_DELTA;
when CALC_DELTA =>
stato_prossimo <= CALC_SHIFT;
when CALC_SHIFT =>
stato_prossimo <= PREPARA_RAM_3;
when PREPARA_RAM_3 =>
stato_prossimo <= LEGGI_PIXEL;
when LEGGI_PIXEL=>
stato_prossimo <= CALC_NEW_PIXEL;
when CALC_NEW_PIXEL =>
stato_prossimo <= SCRIVI_MEM;
when SCRIVI_MEM =>
stato_prossimo <= PREPARA_INDIRIZZI;
when PREPARA_INDIRIZZI =>
if(o_done = '1') then
stato_prossimo <= ASPETTA;
else
stato_prossimo <= PREPARA_RAM_3;
end if;
when ASPETTA =>
 if(o_done = '1') then
 stato_prossimo <= ASPETTA;
 else
 stato_prossimo <= RESET;
 end if;

 end case;
 end process; 
  
process(stato_corr) 
begin
i_read <= '0';
max_l <= '0';
min_l <= '0';
righe_l <= '0';
colonne_l <= '0';
newpix_l <= '0';
temppix_l <= '0';
next_address_l <= '0';
write_here_l <= '0';
deltav_l <= '0';
shiftlev_l <= '0';
max_sel <= '0';
min_sel <= '0';
next_address_sel <= "10";
write_here_sel <= "00";
sel_o_address <= '0';
o_we <= '0';
o_en <= '0';
phase_2 <= '0';
i_wait <= '0';
righe_sel <= '0';
colonne_sel <= '0';
case stato_corr is
when RESET =>
    next_address_sel <= "00";
    next_address_l <= '1';
    write_here_l <= '1';
    max_l <= '1';
    min_l <= '1';
    righe_l <= '1';
    colonne_l <= '1';
when INIZIALE => 
     max_l <= '1';
     min_l <= '1';
     next_address_l <= '1';
     next_address_sel <= "00";
     o_en <= '1';
when LEGGI_COLONNE =>
     colonne_sel <= '1';
     colonne_l <= '1';
     next_address_l <= '1';
     next_address_sel <= "01";
when PREPARA_RAM =>
    o_en <= '1';
when LEGGI_RIGHE =>
    righe_sel <= '1';
    righe_l <= '1';
    next_address_l <= '1';
    next_address_sel <= "01";
    write_here_sel <= "00";
    write_here_l <= '1';
when CHECK_FINE =>
when PREPARA_RAM_2 =>
    o_en <= '1';
when LEGGI_MAX_MIN =>       
    min_l <= '1';
    max_l <= '1';
    max_sel <= '1';
    min_sel <= '1';
    next_address_l <= '1';
    next_address_sel <= "01";
    i_read <= '1';
when RESET_INDIRIZZI =>
    write_here_sel <= "00";
    write_here_l <= '1';
    next_address_sel <= "00";
    next_address_l <= '1';
when CALC_DELTA =>
    next_address_sel <= "01";
    next_address_l <= '1';
    deltav_l <= '1';
when CALC_SHIFT =>
    next_address_sel <= "01";
    next_address_l <= '1';
    shiftlev_l <= '1';
when PREPARA_RAM_3 =>
    o_en <= '1';
when LEGGI_PIXEL =>
     temppix_l <= '1';
when CALC_NEW_PIXEL =>
     newpix_l <= '1';
when SCRIVI_MEM =>
     sel_o_address <= '1';
     o_we <= '1';
     o_en <= '1';
when PREPARA_INDIRIZZI => 
     sel_o_address <= '1';
     next_address_sel <= "01";
     next_address_l <= '1';
     write_here_sel <= "01";
     write_here_l <= '1'; 
     i_read <= '1';
     phase_2 <= '1';
when ASPETTA =>  
     i_wait <= '1';       
end case;
end process;
end Behavioral;












library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity datapath is
    Port ( i_clk : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           i_data : in STD_LOGIC_VECTOR (7 downto 0);
           o_data : out STD_LOGIC_VECTOR (7 downto 0);
           max_l: in STD_LOGIC;
           righe_l: in STD_LOGIC;
           colonne_l : in STD_LOGIC;
           newpix_l : in STD_LOGIC;
           temppix_l: in std_logic;
           min_l : in STD_LOGIC;
           next_address_l: in std_logic;
           write_here_l: in std_logic;
           deltav_l: in std_logic;
           shiftlev_l: in std_logic;
           max_sel: in std_logic;
           min_sel: in std_logic;
           next_address_sel: in std_logic_vector(1 downto 0);
           write_here_sel: in std_logic_vector(1 downto 0);
           o_address: out std_logic_vector(15 downto 0);
           sel_o_address: in std_logic;
           i_read : in std_logic;
           done_phase: out std_logic;
           o_done: out std_logic;
           phase_2 : in std_logic;
           i_start : in std_logic;
           i_wait: in std_logic;
           righe_sel: in std_logic;
           colonne_sel: in std_logic);
end datapath;

architecture Behavioral of datapath is
signal o_righe, o_colonne,o_newpix, o_min_pixel,mux_newpix, mux_max, mux_conf_max, mux_conf_min, mux_min , mux_i, mux_j, o_max_pixel,o_i, o_j,mux_righe, mux_colonne : STD_LOGIC_VECTOR (7 downto 0);
signal o_temp_pixel,o_next_address, o_write_here, mux_next_address, mux_write_here : STD_LOGIC_VECTOR (15 downto 0);
signal mux_o_address : STD_LOGIC_VECTOR(15 downto 0);
signal  o_deltav: STD_LOGIC_VECTOR(8 downto 0);
signal o_shiftlev, o_prienc : STD_LOGIC_VECTOR(3 downto 0);
signal sel_newpix,sel_conf_max,sel_conf_min: std_logic;
signal i_sel, j_sel: std_logic_vector(1 downto 0);

begin

o_done <= '1' when (o_righe = "00000000" and i_start = '1') or (o_colonne = "00000000" and i_start = '1')  or (phase_2 = '1' and done_phase = '1' and i_start = '1') or (i_wait = '1' and i_start = '1') else '0';
done_phase <= '1' when o_i = std_logic_vector(unsigned(o_righe) - "00000001")and o_j = std_logic_vector(unsigned(o_colonne) - "00000001") else '0';



--registro per numero delle righe
process(i_clk, i_rst)
begin
if(i_rst = '1') then 
o_righe <= "00000001";
elsif(rising_edge(i_clk)) then
     if(righe_l = '1') then 
     o_righe <= mux_righe;
     end if;
end if;
end process;

with righe_sel select
     mux_righe <= "00000001" when '0',
               i_data when '1',
                "XXXXXXXX" when others;

--registro per numero di colonne
process(i_clk, i_rst)
begin
if(i_rst = '1') then 
o_colonne <= "00000001";
elsif(rising_edge(i_clk)) then
     if(colonne_l = '1') then 
     o_colonne <= i_data;
     end if;
end if;
end process;

with colonne_sel select
     mux_colonne <= "00000001" when '0',
               i_data when '1',
                "XXXXXXXX" when others;

--registro max
process(i_clk, i_rst)
begin
if(i_rst = '1') then 
o_max_pixel <= "00000000";
elsif(rising_edge(i_clk)) then
     if(max_l = '1') then 
      o_max_pixel <= mux_max;
end if;
end if;
end process;
 

with max_sel select
     mux_max <= "00000000" when '0',
                mux_conf_max when '1',
                "XXXXXXXX" when others;

with sel_conf_max select
     mux_conf_max <= o_max_pixel when '0',
                    i_data when '1',
                    "XXXXXXXX" when others;
                    
sel_conf_max <= '1' when i_data > o_max_pixel else '0';

--registro minimo
process(i_clk, i_rst)
begin
if(i_rst = '1') then 
o_min_pixel <= "11111111";
elsif(rising_edge(i_clk)) then
     if(min_l = '1') then 
      o_min_pixel <= mux_min;
end if;
end if;
end process;

 
with min_sel select
     mux_min <= "11111111" when '0',
                 mux_conf_min when '1',
                "XXXXXXXX" when others;

with sel_conf_min select 
       mux_conf_min <= o_min_pixel when '0',
                       i_data when '1',
                       "XXXXXXXX" when others;
                       
                                
sel_conf_min <= '1' when i_data < o_min_pixel else '0';



                
--registro contatore per righe
process(i_clk, i_rst)
begin
if(i_rst = '1') then 
o_i <= "00000000";
elsif(rising_edge(i_clk)) then
     if(i_read = '1') then
     o_i <= mux_i;
     end if;
end if;
end process;

--registro contatore per colonne
process(i_clk, i_rst)
begin
if(i_rst = '1') then 
o_j <= "00000000";
elsif(rising_edge(i_clk)) then
     if(i_read = '1') then 
     o_j <= mux_j;
     end if;
end if;
end process;

with i_sel select 
    mux_i <= "00000000" when "00",
             std_logic_vector(unsigned(o_i) + "00000001") when "01",
             o_i when "10",
             "00000000" when others;
             
with j_sel select
     mux_j <= "00000000" when "00",
     std_logic_vector(unsigned(o_j) + "00000001") when "01",
     o_j when "10",
     "00000000" when others;

i_sel <= "00" when o_i = std_logic_vector(unsigned(o_righe) - "00000001") else "01" when i_read = '1' else "10";
j_sel <= "00" when o_j =  std_logic_vector(unsigned(o_colonne) - "00000001") and  o_i = std_logic_vector(unsigned(o_righe) - "00000001") else "01" when o_i = std_logic_vector(unsigned(o_righe) - "00000001") else "10";

              
--registro per delta_value +1
process(i_clk, i_rst)
begin 
if(i_rst = '1') then
   o_deltav <= "000000001";
elsif(rising_edge(i_clk)) then
if(deltav_l = '1') then
  o_deltav <= std_logic_vector(unsigned(o_max_pixel)-unsigned(o_min_pixel)+"000000001");
  end if;
end if;
end process;

--priority encoder 
 process(o_deltav)
 begin 
 if(o_deltav(8) = '1') then
    o_prienc <= "0000";
elsif(o_deltav(7) = '1') then
    o_prienc <= "0001";
elsif(o_deltav(6) = '1') then
    o_prienc <= "0010";
elsif(o_deltav(5) = '1') then
    o_prienc <= "0011";
elsif(o_deltav(4) = '1') then
    o_prienc <= "0100";
elsif(o_deltav(3) = '1') then
    o_prienc <= "0101";
elsif(o_deltav(2) = '1') then
    o_prienc <= "0110";
elsif(o_deltav(1) = '1') then
    o_prienc <= "0111";
elsif(o_deltav(0) = '1') then
    o_prienc <= "1000";
else
    o_prienc <= "XXXX";  
end if;         
end process;
 
--registro per shiflevel                
process(i_clk, i_rst)
begin 
if(i_rst = '1') then
o_shiftlev <= "0000";
elsif(rising_edge(i_clk)) then
if(shiftlev_l = '1') then
        o_shiftlev <= o_prienc;
     end if;
end if;
end process;
  
  
--registro per temp pixel  
process(i_clk, i_rst)
begin
if(i_rst = '1') then 
o_temp_pixel <= "0000000000000000";
elsif(rising_edge(i_clk)) then
     if(temppix_l = '1') then 
     o_temp_pixel <= std_logic_vector(shift_left("00000000"&(unsigned(i_data) - unsigned(o_min_pixel)),to_integer(unsigned(o_shiftlev))));
     end if;
end if;
end process;

with sel_newpix select 
      mux_newpix <= o_temp_pixel(7 downto 0) when '0',
                    "11111111" when '1',
                    "00000000" when others;

sel_newpix <= '1' when TO_INTEGER(unsigned(o_temp_pixel)) > 255 else '0';

--registro per new pixel
process(i_clk, i_rst)
begin
if(i_rst = '1') then 
o_newpix <= "00000000";
elsif(rising_edge(i_clk)) then
     if(newpix_l = '1') then 
     o_newpix <= mux_newpix;
     end if;
end if;
end process;




--registro address lettura
process(i_clk, i_rst)
begin 
if(i_rst = '1') then
o_next_address <= "0000000000000000";
elsif(rising_edge(i_clk)) then
    if(next_address_l = '1') then 
        o_next_address <= mux_next_address;
        end if;
  end if;
end process;


with next_address_sel select
     mux_next_address <=  "0000000000000000" when "00",
                            std_logic_vector(unsigned(o_next_address) + "0000000000000001") when "01",
                            o_next_address when "10",
                            "0000000000000000" when others;
                            
--registro per address scrittura
process(i_clk, i_rst)
begin 
if(i_rst = '1') then
o_write_here <= "0000000000000000";
elsif(rising_edge(i_clk)) then
    if(write_here_l = '1') then 
        o_write_here <= mux_write_here;
        end if;
  end if;
end process;


with write_here_sel select
     mux_write_here <= o_next_address when "00",
                       std_logic_vector(unsigned(o_write_here) + "0000000000000001") when "01",
                       o_write_here when "10",
                       "0000000000000000" when others;
                       
                       
                   
with sel_o_address select 
       mux_o_address <= o_next_address when '0',
                       o_write_here when '1',
                       "XXXXXXXXXXXXXXXX" when others;  
                    
o_address <= mux_o_address;

o_data <= o_newpix;  

end Behavioral;

