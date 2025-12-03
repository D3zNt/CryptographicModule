library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mixcolumns is
  Port (
  data_in  : in std_logic_vector(127 downto 0);
  data_out  : out std_logic_vector(127 downto 0)
  );
end mixcolumns;

architecture Behavioral of mixcolumns is
    component utils is
        port(
            byte_in : in std_logic_vector(7 downto 0);
            mul2_out : out std_logic_vector(7 downto 0);
            mul3_out : out std_logic_vector(7 downto 0)
        );
        
    end component;
    
    -- state matrix = 4x4 bytes (16 bytes = 128 bits)
    type state_type is array(0 to 3, 0 to 3) of std_logic_vector(7 downto 0);
    
    signal stateIn, stateOut : state_type;
    signal mul2_out, mul3_out : state_type;
    
    function byte_pos(column, row : integer) return integer is
    begin
        return (127 - ((column * 32) + (row * 8))); 
    end function; 
    
begin
    -- the input is converted from 128 bits into 4x4 state matrix
    process(data_in)
        variable MSB_pos : integer;
    begin
        for column in 0 to 3 loop
            for row in 0 to 3 loop
                MSB_pos := byte_pos(column, row);
                stateIn(row, column) <= data_in(MSB_pos downto (MSB_pos - 7));
            end loop;
        end loop;
    end process;
    
    -- loop for 16 util instances
    COLUMNS : for column in 0 to 3 generate
        ROWS : for row in 0 to 3 generate
            UTILS_INST : utils 
            port map(
                byte_in => stateIn(row, column),
                mul2_out => mul2_out(row, column),
                mul3_out => mul3_out(row, column)
            );
        end generate ROWS;
    end generate COLUMNS;
    
    -- mix column calculations
    process(stateIn, mul2_out, mul3_out)
    begin
        for column in 0 to 3 loop
            stateOut(0, column) <= mul2_out(0, column) xor 
                                   mul3_out(1, column) xor 
                                   stateIn(2, column) xor 
                                   stateIn(3, column);
                                   
            stateOut(1, column) <= stateIn(0, column) xor
                                   mul2_out(1, column) xor
                                   mul3_out(2, column) xor
                                   stateIn(3, column);
                                   
            stateOut(2, column) <= stateIn(0, column) xor
                                   stateIn(1, column) xor
                                   mul2_out(2, column) xor
                                   mul3_out(3, column);
                                    
            stateOut(3, column) <= mul3_out(0, column) xor
                                   stateIn(1, column) xor
                                   stateIn(2, column) xor
                                   mul2_out(3, column);
        end loop;
    end process;
    
    -- the output is converted back from each state matrix sections into 128 bits
    process(stateOut)
        variable MSB_pos : integer;
    begin
        for column in 0 to 3 loop
            for row in 0 to 3 loop
                MSB_pos := byte_pos(column, row);
                data_out(MSB_pos downto (MSB_pos - 7)) <= stateOut(row, column);
            end loop;
        end loop;
    end process;

end Behavioral;
