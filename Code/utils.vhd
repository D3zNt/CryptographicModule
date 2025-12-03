library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity utils is
  Port (
    byte_in  : in std_logic_vector(7 downto 0);
    mul2_out : out std_logic_vector(7 downto 0);
    mul3_out : out std_logic_vector(7 downto 0)
  );  
end utils;

architecture Behavioral of utils is
    function mul2(x : std_logic_vector(7 downto 0)) return std_logic_vector is
        variable byte_result : std_logic_vector(7 downto 0);
    begin
        byte_result(7) := x(6);
        byte_result(6) := x(5);
        byte_result(5) := x(4);
        byte_result(4) := x(3) xor x(7);
        byte_result(3) := x(2) xor x(7);
        byte_result(2) := x(1);
        byte_result(1) := x(0) xor x(7);
        byte_result(0) := x(7);
        return byte_result;
    end function;
begin
    mul2_out <= mul2(byte_in);
    mul3_out <= mul2(byte_in) xor byte_in;
end Behavioral;
