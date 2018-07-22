library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
        
entity one_wire is
        port ( reset : in std_logic;
                        read_byte : in std_logic;
                        write_byte : in std_logic;
                        wire_out : out std_logic;
                        wire_in : in std_logic;
                        presense : out std_logic;
                        busy : out std_logic;
                        in_byte : in std_logic_vector (7 downto 0);
                        out_byte : out std_logic_vector (7 downto 0);
                        clk : in std_logic );
end one_wire;

architecture a of one_wire is
signal count : std_logic;
signal counter : integer range 0 to 127;

begin
process (clk)

type finit_state is (start, delay_reset, wire_read_presense, wire_0, wire_write, wire_read, delay );
variable state : finit_state := start; 

variable n_bit : integer range 0 to 7;
variable f : std_logic;
begin
if (clk'event and clk = '1') then
case (state) is
        when start => wire_out <= 'Z';
                                busy <= '0';
                                count <= '0';
                                if (reset = '1') then
                                        busy <= '1';
                                        presense <= '0';
                                        state := delay_reset;
                                elsif (write_byte = '1') then 
                                        f := '0';
                                        busy <= '1';
                                        state := wire_0;
                                elsif (read_byte = '1') then
                                        f := '1';
                                        busy <= '1';
                                        state := wire_0;
                                end if;
                                        
        when delay_reset => wire_out <= '0';
                                count <= '1';
                                if (counter = 78) then
                                        state := wire_read_presense;
                                        count <= '0';
                                end if;
                        
        when wire_read_presense => wire_out <= 'Z';
                                count <= '1';
                                if (counter = 11) then
                                        presense <= not wire_in;
                                end if;
                                if (counter = 78) then 
                                        state := start;
                                        count <= '0';
                                end if;
                                        
        when wire_0 => wire_out <= '0';
                                if (f = '0') then
                                        state := wire_write;
                                else 
                                        state := wire_read;
                                end if;
                                        
        when wire_write => 
                                if (in_byte(n_bit) = '1') then
                                        wire_out <= 'Z';
                                end if;
                                state := delay;
                                                                                
        when wire_read => wire_out <= 'Z';
                                count <= '1';
                                if (counter = 1) then     
                                        out_byte(n_bit) <= wire_in;
                                        count <= '0';
                                        state := delay;
                                end if;
                                
        when delay => 
                                count <= '1';
                                if (counter = 8) then
                                        count <= '0';
                                        wire_out <= 'Z';
                                        if (n_bit = 7) then
                                                n_bit := 0;
                                                state := start;
                                        else n_bit := n_bit + 1;
                                                state := wire_0;
                                        end if;
                                end if;
                                                                
end case;
end if;
end process;

process (clk)
begin
if (count = '0') then
        counter <= 0;
elsif (clk'event and clk = '1') then
        counter <= counter + 1;
end if;
end process;

end architecture;
