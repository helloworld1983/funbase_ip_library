-------------------------------------------------------------------------------
-- Title      : Testbench for a hibi network
-- Project    : 
-------------------------------------------------------------------------------
-- File       : tb_video_gen_1.vhd
-- Author     : ege
-- Created    : 2010/03/16
-- Last update: 2010/03/19
-- Description: 
--
-------------------------------------------------------------------------------
-- Copyright (c) 2010 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2010/03/16  1.0      ES      Created
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use ieee.std_logic_misc.all;
use std.textio.all;

--use work.txt_util.all;
use work.hibiv2_pkg.all;

entity tb_video_gen_1 is
end tb_video_gen_1;



architecture structural of tb_video_gen_1 is

  constant x_pels_c : integer := 640;
  constant y_pels_c : integer := 320;

  
  constant n_ag_c          : integer := 3;   -- number of agents (=IPs)

  -- HIBI parameters
  constant data_width_c    : integer := 32;  -- bits
  constant addr_width_c    : integer := 32;  -- bits
  constant counter_width_c : integer := 16;  -- bits
  constant id_width_c      : integer := 6;   -- bits
  constant max_send_c      : integer := 40;  -- words
  constant arb_type_c      : integer := 3;   -- 0-3
  constant tx_fifo_size_c  : integer := 4;   -- words
  constant rx_fifo_size_c  : integer := 4;   -- words

  type gen_addr_array_type    is array (0 to 3) of integer;
  constant addresses_c : gen_addr_array_type := 
    (16#41000000#,      -- video_gen
     16#43000000#,      -- pic manipulator
     16#C0000000#,      -- ddr
     16#45000000#       -- currently unused
     );


  -- IPs and wrappers can run on different frequencies
  -- (All Ips using one clock and all wrappers unsing the other)
  -- Frequencies must be integer multiple of each other.
  -- Edit both period and frequencies manually and ensure consistency.
  constant PERIOD_IP_C      : time    := 1*10 ns;
  constant PERIOD_HIBI_C    : time    := 1*10 ns;
  constant rel_agent_freq_c : integer := 1;
  constant rel_bus_freq_c   : integer := 1;


  -- Global signals
  signal clk_ip  : std_logic := '1';
  signal clk_noc : std_logic := '1';
  signal rst_n   : std_logic := '0';

  -- Define types for arrays. Transposed versions are needed for or_reduce
  -- function in bus resolution.
  type data_vec_type is array (n_ag_c-1 downto 0) of std_logic_vector (data_width_c-1 downto 0);
  type comm_vec_type is array (n_ag_c-1 downto 0) of std_logic_vector (comm_width_c-1 downto 0);
  type trnsp_data_vec is array (data_width_c-1 downto 0) of std_logic_vector (n_ag_c-1 downto 0);
  type trnsp_comm_vec is array (comm_width_c-1 downto 0) of std_logic_vector (n_ag_c-1 downto 0);

  
  -- Signals going from the IPs to the wrappers.
  -- Note that full and one_p actually come from wrapper but they are grouped
  -- here due their purpose.
  signal av_ip_wra    : std_logic_vector ( n_ag_c-1 downto 0); 
  signal data_ip_wra  : data_vec_type;
  signal comm_ip_wra  : comm_vec_type;
  signal we_ip_wra    : std_logic_vector ( n_ag_c-1 downto 0);
  signal full_wra_ip  : std_logic_vector ( n_ag_c-1 downto 0);
  signal one_p_wra_ip : std_logic_vector ( n_ag_c-1 downto 0);

  -- Signals going from the wrappers to the IPs.
  signal av_wra_ip    : std_logic_vector ( n_ag_c-1 downto 0);
  signal data_wra_ip  : data_vec_type;
  signal comm_wra_ip  : comm_vec_type;
  signal re_ip_wra    : std_logic_vector ( n_ag_c-1 downto 0);
  signal empty_wra_ip : std_logic_vector ( n_ag_c-1 downto 0);
  signal one_d_wra_ip : std_logic_vector ( n_ag_c-1 downto 0);
  
  -- Signals going from the wrappers to the OR ports.
  signal av_wra_bus     : std_logic_vector ( n_ag_c-1 downto 0);
  signal data_wra_bus   : data_vec_type;
  signal comm_wra_bus   : comm_vec_type;
  signal trnsp_data_out : trnsp_data_vec;
  signal trnsp_comm_out : trnsp_comm_vec;
  signal full_wra_bus   : std_logic_vector ( n_ag_c-1 downto 0);
  signal lock_wra_bus   : std_logic_vector ( n_ag_c-1 downto 0);

  -- Signals going from the OR ports to the wrappers.
  signal av_bus_wra   : std_logic;
  signal data_bus_wra : std_logic_vector(data_width_c-1 downto 0);
  signal comm_bus_wra : std_logic_vector(comm_width_c-1 downto 0);
  signal full_bus_wra : std_logic;
  signal lock_bus_wra : std_logic;

  
  -- 2007/04/16
  constant dbg_width_c  : integer := 1;
  signal   debug_tb_wra : std_logic_vector ( dbg_width_c-1 downto 0);


  --  constant arb_type_c   : integer := 0;



  
begin  -- structural

    duv : entity work.video_gen_1
      generic map (
          image_data_width           => 8,
          image_fps                  => 10,
          image_pattern_id           => 2,
          H_pixels_across            => x_pels_c,
          V_pixels_down              => y_pels_c,
          video_gen_1_addr_g         => addresses_c (0),
          picture_manipulator_addr_g => addresses_c (1),
          ddr2_controller_addr_g     => addresses_c (2),
          data_width_g               => data_width_c,
          comm_width_g               => comm_width_c)
      port map (
          rst_n                      => rst_n,
          clk                        => clk_ip,
          hibi_comm_out              => comm_ip_wra (0),
          hibi_data_out              => data_ip_wra (0),
          hibi_av_out                => av_ip_wra (0),
          hibi_we_out                => we_ip_wra (0),
          hibi_re_out                => re_ip_wra (0),
          
          hibi_comm_in               => comm_wra_ip (0),          
          hibi_data_in               => data_wra_ip (0),
          hibi_av_in                 => av_wra_ip (0),
          hibi_full_in               => full_wra_ip (0),
          hibi_one_p_in              => one_p_wra_ip (0),
          hibi_empty_in              => empty_wra_ip (0),
          hibi_one_d_in              => one_d_wra_ip (0)
          );


 linux: entity work.basic_test_tx

  generic map(
    conf_file_g  => "test1.txt",
    own_number_g => 1,
    n_agents_g   => 3,
    n_segments_g => 1,
    comm_width_g => 3,
    data_width_g => 32
    )
  port map(
    clk          => clk_ip,
    rst_n        => rst_n,
    
    -- done_out     => ,

    -- HIBI WRAPPER PORTS
    agent_av_out   => av_ip_wra (1),
    agent_data_out => data_ip_wra (1),
    agent_comm_out => comm_ip_wra (1),
    agent_we_out   => we_ip_wra (1),
    agent_full_in  => full_wra_ip (1),
    agent_one_p_in => one_p_wra_ip (1)
    );


--    fire_the_video_gen: process
--    begin  -- process fire_the video_gen

--      av_ip_wra (1)   <= '0';
--      data_ip_wra (1) <= (others => 'Z');
--      comm_ip_wra (1) <= (others => 'Z');
--      re_ip_wra (1)   <= '1';
--      we_ip_wra (1)   <= '0';

--      wait for (x_pels_c * y_pels_c * 5 / 4 * PERIOD_IP_C);


      -- ask video_gen to continue (assume that hibi fifo is not full)
--      av_ip_wra (1)   <= '1';
--      data_ip_wra (1) <= std_logic_vector (to_unsigned (addresses_c (0), data_width_c));
--      comm_ip_wra (1) <= std_logic_vector (to_unsigned (2, comm_width_c));
--      we_ip_wra (1)   <= '1';
--      assert full_wra_ip (1) = '0' report "tb cannot handle full tx fifo! please stop simulation" severity error;
--      wait for (1* PERIOD_IP_C);

--      av_ip_wra (1)   <= '0';
--      data_ip_wra (1) <= x"000000FF";
--      we_ip_wra (1)   <= '1';
--      wait for (1* PERIOD_IP_C);
      
--    end process fire_the_video_gen;

    -- DDR does not send anything in this tb
    av_ip_wra (2)   <= '0';
    data_ip_wra (2) <= (others => 'Z');
    comm_ip_wra (2) <= (others => 'Z');
    we_ip_wra (2)   <= '0';
    re_ip_wra (2)   <= '1';

    
    
  hibi_net            : for ag in 0 to n_ag_c-1 generate
    hibi_wrapper_r4_1 : entity work.hibi_wrapper_r4
      generic map (
        id_g                => ag+1,
        base_id_g           => 2**id_width_c-1,
        inv_addr_en_g       => 0,
        -- first parameter to addresses_c is the segment, 
        -- second is the agents number within the segment
        addr_g              => addresses_c (ag),

        id_width_g          => id_width_c,
        addr_width_g        => addr_width_c,
        data_width_g        => data_width_c,
        comm_width_g        => 3,
        counter_width_g     => counter_width_c,
        
        rx_fifo_depth_g     => rx_fifo_size_c,
        rx_msg_fifo_depth_g => 0,       -- fifo_size_c
        tx_fifo_depth_g     => tx_fifo_size_c,
        tx_msg_fifo_depth_g => 0,       -- fifo_size_c

        rel_agent_freq_g => rel_agent_freq_c,
        rel_bus_freq_g   => rel_bus_freq_c,
        arb_type_g       => arb_type_c,  --13.4.2007


        prior_g    => ag +1,
        max_send_g => max_send_c,
        n_agents_g => n_ag_c,

        n_cfg_pages_g    => 1,
        n_time_slots_g   => 0,
        n_extra_params_g => 1,
        multicast_en_g   => 0,
        cfg_re_g         => 0,
        cfg_we_g         => 1, --0,

        debug_width_g  => dbg_width_c   --2007/04/16
        )
      port map (
        agent_clk      => clk_ip,
        bus_clk        => clk_noc,
        bus_sync_clk   => clk_noc,
        agent_sync_clk => clk_ip, 
        rst_n          => rst_n,

        bus_av_in    => av_bus_wra,
        bus_data_in  => data_bus_wra,
        bus_comm_in  => comm_bus_wra,
        bus_full_in  => full_bus_wra,
        bus_lock_in  => lock_bus_wra,
        bus_av_out   => av_wra_bus   (ag),
        bus_data_out => data_wra_bus (ag),
        bus_comm_out => comm_wra_bus (ag),
        bus_full_out => full_wra_bus (ag),
        bus_lock_out => lock_wra_bus (ag),

        agent_av_in      => av_ip_wra    (ag),
        agent_data_in    => data_ip_wra  (ag),
        agent_comm_in    => comm_ip_wra  (ag),
        agent_we_in      => we_ip_wra    (ag),
        agent_full_out   => full_wra_ip  (ag),
        agent_one_p_out  => one_p_wra_ip (ag),

        agent_re_in      => re_ip_wra    (ag),
        agent_av_out     => av_wra_ip    (ag),
        agent_data_out   => data_wra_ip  (ag),
        agent_comm_out   => comm_wra_ip  (ag),
        agent_empty_out  => empty_wra_ip (ag),
        agent_one_d_out  => one_d_wra_ip (ag),

        --debug_out => dummy,
        debug_in => debug_tb_wra

        );

  end generate hibi_net;

  



  -- assign the bus signals. bus signals are first transposed, eg.
  -- 3*32b buses -> 32*3b buses
  trnsp_bus : for j in 0 to n_ag_c-1 generate

      i : for i in 0 to data_width_c-1 generate
        trnsp_data_out (i)(j) <= data_wra_bus (j)(i);
      end generate i;

      k : for k in 0 to comm_width_c-1 generate
        trnsp_comm_out (k)(j) <= comm_wra_bus (j)(k);
      end generate k;      
  end generate trnsp_bus;



    
    -- here we or_reduce the transposed signals, so we get the in-signals
    -- for wrappers.
    or_reduce_data : for i in 0 to data_width_c-1 generate
      data_bus_wra (i) <= or_reduce(trnsp_data_out (i));
    end generate or_reduce_data;


    chk_lock: process (lock_wra_bus)
      variable n_locks_v : integer := 0;
    begin  -- process chk_lock

      n_locks_v := 0;
      
      for i in 0 to n_ag_c -1 loop
        if lock_wra_bus (i) = '1' then
          n_locks_v := n_locks_v +1;
        end if;        
      end loop;  -- i

      if n_locks_v > 1 then
        assert false report "Multiple drivers for lock signal!!!" severity error;
      end if;                 
    end process chk_lock;
    
    or_reduce_comm : for i in 0 to comm_width_c-1 generate
        comm_bus_wra(i) <= or_reduce(trnsp_comm_out(i));
    end generate or_reduce_comm;


    or_reduce_rest : for i in 0 to comm_width_c-1 generate
      av_bus_wra   <= or_reduce(av_wra_bus);
      lock_bus_wra <= or_reduce(lock_wra_bus);
      full_bus_wra <= or_reduce(full_wra_bus);
    end generate or_reduce_rest;

    clk_ip  <= not clk_ip  after PERIOD_IP_C/2;
    clk_noc <= not clk_noc after PERIOD_HIBI_C/2;
    rst_n <= '0', '1'    after 4.6 * PERIOD_HIBI_C;


end structural;

