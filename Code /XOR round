library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity addroundkey is
    Port (
        state_in  : in  std_logic_vector(127 downto 0);  
        round_key : in  std_logic_vector(127 downto 0);  
        state_out : out std_logic_vector(127 downto 0)   
    );
end addroundkey;

architecture Behavioral of addroundkey is
begin
    process(state_in, round_key)
    begin
        state_out <= state_in xor round_key;
    end process;
    
end Behavioral;
