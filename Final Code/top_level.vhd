library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity aes_top is
    Port (
        clk        : in  std_logic;
        rst        : in  std_logic;
        start      : in  std_logic;
        
        plaintext  : in  std_logic_vector(127 downto 0);
        key_in     : in  std_logic_vector(127 downto 0);

        done       : out std_logic;
        ciphertext : out std_logic_vector(127 downto 0)
    );
end aes_top;

architecture Behavioral of aes_top is
    component sbox_comb is
        Port ( state_in : in std_logic_vector(127 downto 0);
               state_out: out std_logic_vector(127 downto 0) );
    end component;

    component shiftrows is
        Port ( state_in : in std_logic_vector(127 downto 0);
               state_out: out std_logic_vector(127 downto 0) );
    end component;

    component mixcolumns is
        Port ( data_in : in std_logic_vector(127 downto 0);
               data_out: out std_logic_vector(127 downto 0) );
    end component;

    component key_expansion is
        Port (
            clk       : in std_logic;
            rst       : in std_logic;
            key_in    : in std_logic_vector(127 downto 0);
            start     : in std_logic;
            round_num : in integer range 0 to 10;
            round_key : out std_logic_vector(127 downto 0);
            done      : out std_logic );
    end component;

    signal state_reg      : std_logic_vector(127 downto 0) := (others => '0');
    signal next_state     : std_logic_vector(127 downto 0);

    signal sb_out         : std_logic_vector(127 downto 0);
    signal sr_out         : std_logic_vector(127 downto 0);
    signal mc_out         : std_logic_vector(127 downto 0);

    signal key_start_sig      : std_logic := '0';
    signal key_done_sig       : std_logic;
    signal key_round_select   : integer range 0 to 10 := 0;
    signal key_round_key      : std_logic_vector(127 downto 0);

    -- simplified FSM states
    type fsm_type is (IDLE, REQ_KEY, WAIT_KEY, DONE_ST);
    signal state_fsm : fsm_type := IDLE;

    signal round_idx : integer range 0 to 10 := 0;

begin

    KEYEXP_U: key_expansion
        port map ( clk => clk, rst => rst, key_in => key_in,
                   start => key_start_sig, round_num => key_round_select,
                   round_key => key_round_key, done => key_done_sig );

    SB_U: sbox_comb
        port map ( state_in => state_reg, state_out => sb_out );

    SR_U: shiftrows
        port map ( state_in => sb_out, state_out => sr_out );

    MC_U: mixcolumns
        port map ( data_in => sr_out, data_out => mc_out );
        
        

    combinational_proc : process(sr_out, mc_out, key_round_key, state_fsm)
    begin
        if state_fsm = WAIT_KEY and round_idx = 10 then
            next_state <= sr_out xor key_round_key;
        else
            next_state <= mc_out xor key_round_key;
        end if;
    end process;
    
    control_proc : process(clk, rst)
    begin
        if rst = '1' then
            state_fsm <= IDLE;
            key_start_sig <= '0';
            key_round_select <= 0;
            round_idx <= 0;
            state_reg <= (others => '0');
            done <= '0';

        elsif rising_edge(clk) then

            case state_fsm is

                when IDLE =>
                    done <= '0';
                    key_start_sig <= '0';
                    if start = '1' then
                        round_idx <= 0;
                        key_round_select <= 0;
                        state_fsm <= REQ_KEY;
                    end if;

                when REQ_KEY =>
                    key_start_sig <= '1';
                    state_fsm <= WAIT_KEY;

                when WAIT_KEY =>
                    key_start_sig <= '0';

                    if key_done_sig = '1' then
                        if round_idx = 0 then
                            state_reg <= plaintext xor key_round_key;

                            round_idx <= 1;
                            key_round_select <= 1;
                            state_fsm <= REQ_KEY;

                        elsif round_idx >= 1 and round_idx <= 9 then
                            state_reg <= next_state;

                            if round_idx < 9 then
                                key_round_select <= round_idx + 1;
                                round_idx <= round_idx + 1;
                                state_fsm <= REQ_KEY;
                            else
                                key_round_select <= 10;
                                round_idx <= 10;
                                state_fsm <= REQ_KEY;
                            end if;

                        elsif round_idx = 10 then
                            state_reg <= next_state;
                            done <= '1';
                            state_fsm <= DONE_ST;

                        else
                            state_fsm <= IDLE;
                        end if;
                    end if;

                when DONE_ST =>
                    if start = '1' then
                        round_idx <= 0;
                        key_round_select <= 0;
                        done <= '0';
                        state_fsm <= REQ_KEY;
                    else
                        state_fsm <= DONE_ST;
                    end if;

                when others =>
                    state_fsm <= IDLE;

            end case;
        end if;
    end process;

    ciphertext <= state_reg;

end Behavioral;
