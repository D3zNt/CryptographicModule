library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;


entity aes_tb is
end aes_tb;

architecture Behavioral of aes_tb is

    signal clk         : std_logic := '0';
    signal rst         : std_logic := '1';
    signal start       : std_logic := '0';

    signal plaintext   : std_logic_vector(127 downto 0);
    signal key_in      : std_logic_vector(127 downto 0);

    signal done        : std_logic;
    signal ciphertext  : std_logic_vector(127 downto 0);

    constant expected_cipher : std_logic_vector(127 downto 0) :=
        x"69C4E0D86A7B0430D8CDB78070B4C55A"; -- test to see if it works
    
        -- Convert std_logic_vector to HEX string for reporting only
    function to_hex(slv : std_logic_vector) return string is
        constant nibbles : integer := slv'length / 4;
        variable result  : string(1 to nibbles);
        variable nibble  : std_logic_vector(3 downto 0);
        variable idx     : integer := 1;
    begin
        for i in slv'left downto slv'right loop
            if ((slv'left - i) mod 4 = 0) then
                nibble := slv(i downto i-3);

                case nibble is
                    when "0000" => result(idx) := '0';
                    when "0001" => result(idx) := '1';
                    when "0010" => result(idx) := '2';
                    when "0011" => result(idx) := '3';
                    when "0100" => result(idx) := '4';
                    when "0101" => result(idx) := '5';
                    when "0110" => result(idx) := '6';
                    when "0111" => result(idx) := '7';
                    when "1000" => result(idx) := '8';
                    when "1001" => result(idx) := '9';
                    when "1010" => result(idx) := 'A';
                    when "1011" => result(idx) := 'B';
                    when "1100" => result(idx) := 'C';
                    when "1101" => result(idx) := 'D';
                    when "1110" => result(idx) := 'E';
                    when "1111" => result(idx) := 'F';
                    when others => result(idx) := '?';
                end case;

                idx := idx + 1;
            end if;
        end loop;

        return result;
    end function;


begin

    clk <= not clk after 5 ns;

    DUT: entity work.aes_top
        port map (
            clk        => clk,
            rst        => rst,
            start      => start,
            plaintext  => plaintext,
            key_in     => key_in,
            done       => done,
            ciphertext => ciphertext
        );

    stim_proc: process
    begin
        
       
        rst <= '1';
        wait for 20 ns;
        rst <= '0';

        -- key and plaintext (in hex format)
        key_in     <= x"000102030405060708090A0B0C0D0E0F";
        plaintext  <= x"00112233445566778899AABBCCDDEEFF";

        wait for 20 ns;

        start <= '1';
        wait for 10 ns;
        start <= '0';
        wait until done = '1';

        wait for 20 ns;
        if ciphertext = expected_cipher then
            report "AES-128 TEST PASSED! Cipher = " & to_hex(ciphertext) severity note;

        else
            report "Expected: " & to_hex(expected_cipher) severity note;
            report "Got     : " & to_hex(ciphertext) severity note;
        end if;

        wait;
    end process;

end Behavioral;
