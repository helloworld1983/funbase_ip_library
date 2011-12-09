-- megafunction wizard: %RAM: 2-PORT%
-- GENERATION: STANDARD
-- VERSION: WM1.0
-- MODULE: altsyncram 

-- ============================================================
-- File Name: onchip_mem.vhd
-- Megafunction Name(s):
-- 			altsyncram
--
-- Simulation Library Files(s):
-- 			altera_mf
-- ============================================================
-- ************************************************************
-- THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
--
-- 10.0 Build 262 08/18/2010 SP 1 SJ Full Version
-- ************************************************************


--Copyright (C) 1991-2010 Altera Corporation
--Your use of Altera Corporation's design tools, logic functions 
--and other software and tools, and its AMPP partner logic 
--functions, and any output files from any of the foregoing 
--(including device programming or simulation files), and any 
--associated documentation or information are expressly subject 
--to the terms and conditions of the Altera Program License 
--Subscription Agreement, Altera MegaCore Function License 
--Agreement, or other applicable license agreement, including, 
--without limitation, that your use is for the sole purpose of 
--programming logic devices manufactured by Altera and sold by 
--Altera or its authorized distributors.  Please refer to the 
--applicable agreement for further details.


library ieee;
use ieee.std_logic_1164.all;

library altera_mf;
use altera_mf.all;

entity alt_mem_dc_dw is
	generic ( MEM_PORTS  : integer := 1;
            DATA_0_WIDTH : integer := 8;
            DATA_1_WIDTH : integer := 8; -- DATA_1_WIDTH must be greater or equal than DATA_0_WIDTH
            ADDR_0_WIDTH : integer := 6;
            ADDR_1_WIDTH : integer := 6;
            MEM_SIZE   : integer := 64 );
  
  port ( clk_0       : in std_logic;
         clk_1       : in std_logic;
         
         addr_0_in   : in  std_logic_vector(ADDR_0_WIDTH-1 downto 0);
         addr_1_in   : in  std_logic_vector(ADDR_1_WIDTH-1 downto 0);
         wdata_0_in  : in  std_logic_vector(DATA_0_WIDTH-1 downto 0);
         wdata_1_in  : in  std_logic_vector(DATA_1_WIDTH-1 downto 0);
         we_0_in     : in  std_logic;
         we_1_in     : in  std_logic;
         rdata_0_out : out std_logic_vector(DATA_0_WIDTH-1 downto 0);
         rdata_1_out : out std_logic_vector(DATA_1_WIDTH-1 downto 0)
	);
end alt_mem_dc_dw;

architecture rtl of alt_mem_dc_dw is
  
  function max(L : integer; R : integer) return integer is
  begin
    if L > R then
      return L;
    else
      return R;
    end if;
  end;
  
  function log2_ceil(N : natural) return positive is
  begin
    if N < 2 then
      return 1;
    else
      return 1 + log2_ceil(N/2);
    end if;
  end;
  
  component altsyncram
	generic (
		address_aclr_a	:	string := "UNUSED";
		address_aclr_b	:	string := "NONE";
		address_reg_b	:	string := "CLOCK1";
		byte_size	:	natural := 8;
		byteena_aclr_a	:	string := "UNUSED";
		byteena_aclr_b	:	string := "NONE";
		byteena_reg_b	:	string := "CLOCK1";
		clock_enable_core_a	:	string := "USE_INPUT_CLKEN";
		clock_enable_core_b	:	string := "USE_INPUT_CLKEN";
		clock_enable_input_a	:	string := "NORMAL";
		clock_enable_input_b	:	string := "NORMAL";
		clock_enable_output_a	:	string := "NORMAL";
		clock_enable_output_b	:	string := "NORMAL";
		intended_device_family	:	string := "unused";
		ecc_pipeline_stage_enabled	:	string := "FALSE";
		enable_ecc	:	string := "FALSE";
		implement_in_les	:	string := "OFF";
		indata_aclr_a	:	string := "UNUSED";
		indata_aclr_b	:	string := "NONE";
		indata_reg_b	:	string := "CLOCK1";
		init_file	:	string := "UNUSED";
		init_file_layout	:	string := "PORT_A";
		maximum_depth	:	natural := 0;
		numwords_a	:	natural := 0;
		numwords_b	:	natural := 0;
		operation_mode	:	string := "BIDIR_DUAL_PORT";
		outdata_aclr_a	:	string := "NONE";
		outdata_aclr_b	:	string := "NONE";
		outdata_reg_a	:	string := "UNREGISTERED";
		outdata_reg_b	:	string := "UNREGISTERED";
		power_up_uninitialized	:	string := "FALSE";
		ram_block_type	:	string := "AUTO";
		rdcontrol_aclr_b	:	string := "NONE";
		rdcontrol_reg_b	:	string := "CLOCK1";
		read_during_write_mode_mixed_ports	:	string := "DONT_CARE";
		read_during_write_mode_port_a	:	string := "NEW_DATA_NO_NBE_READ";
		read_during_write_mode_port_b	:	string := "NEW_DATA_NO_NBE_READ";
--		stratixiv_m144k_allow_dual_clocks	:	string := "ON";
		width_a	:	natural;
		width_b	:	natural := 1;
		width_byteena_a	:	natural := 1;
		width_byteena_b	:	natural := 1;
		width_eccstatus	:	natural := 3;
		widthad_a	:	natural;
		widthad_b	:	natural := 1;
		wrcontrol_aclr_a	:	string := "UNUSED";
		wrcontrol_aclr_b	:	string := "NONE";
		wrcontrol_wraddress_reg_b	:	string := "CLOCK1";
		lpm_hint	:	string := "UNUSED";
		lpm_type	:	string := "altsyncram"
	);
	port(
		aclr0	:	in std_logic := '0';
		aclr1	:	in std_logic := '0';
		address_a	:	in std_logic_vector(widthad_a-1 downto 0);
		address_b	:	in std_logic_vector(widthad_b-1 downto 0) := (others => '1');
		addressstall_a	:	in std_logic := '0';
		addressstall_b	:	in std_logic := '0';
		byteena_a	:	in std_logic_vector(width_byteena_a-1 downto 0) := (others => '1');
		byteena_b	:	in std_logic_vector(width_byteena_b-1 downto 0) := (others => '1');
		clock0	:	in std_logic := '1';
		clock1	:	in std_logic := '1';
		clocken0	:	in std_logic := '1';
		clocken1	:	in std_logic := '1';
		clocken2	:	in std_logic := '1';
		clocken3	:	in std_logic := '1';
		data_a	:	in std_logic_vector(width_a-1 downto 0) := (others => '1');
		data_b	:	in std_logic_vector(width_b-1 downto 0) := (others => '1');
		eccstatus	:	out std_logic_vector(width_eccstatus-1 downto 0);
		q_a	:	out std_logic_vector(width_a-1 downto 0);
		q_b	:	out std_logic_vector(width_b-1 downto 0);
		rden_a	:	in std_logic := '1';
		rden_b	:	in std_logic := '1';
		wren_a	:	in std_logic := '0';
		wren_b	:	in std_logic := '0'
	);
  end component;
  
  constant DATA_WIDTH : integer := max(DATA_0_WIDTH, DATA_1_WIDTH);
  
  constant DATA_WIDTH_RATIO : integer := DATA_WIDTH / DATA_0_WIDTH;
  constant DATA_WIDTH_RATIO_WIDTH : integer := log2_ceil(DATA_WIDTH_RATIO);
begin

  mem_0 : altsyncram
  generic map ( address_reg_b => "CLOCK1",
                clock_enable_input_a => "BYPASS",
                clock_enable_input_b => "BYPASS",
                clock_enable_output_a => "BYPASS",
                clock_enable_output_b => "BYPASS",
                indata_reg_b => "CLOCK1",
                intended_device_family => "Arria II GX",
                lpm_type => "altsyncram",
                numwords_a => MEM_SIZE*DATA_WIDTH_RATIO,
                numwords_b => MEM_SIZE,
                operation_mode => "BIDIR_DUAL_PORT",
                outdata_aclr_a => "NONE",
                outdata_aclr_b => "NONE",
                outdata_reg_a => "UNREGISTERED",
                outdata_reg_b => "UNREGISTERED",
                power_up_uninitialized => "FALSE",
                read_during_write_mode_port_a => "NEW_DATA_NO_NBE_READ",
                read_during_write_mode_port_b => "NEW_DATA_NO_NBE_READ",
                widthad_a => ADDR_0_WIDTH,
                widthad_b => ADDR_1_WIDTH,
                width_a => DATA_0_WIDTH,
                width_b => DATA_1_WIDTH,
                width_byteena_a => 1,
                width_byteena_b => 1,
                wrcontrol_wraddress_reg_b => "CLOCK1" )
  port map ( clock0 => clk_0,
             clock1 => clk_1,
             
             wren_a => we_0_in,
             address_a => addr_0_in,
             data_a => wdata_0_in,
             q_a => rdata_0_out,
             
             wren_b => we_1_in,
             address_b => addr_1_in,
             data_b => wdata_1_in,
             q_b => rdata_1_out );

end rtl;
