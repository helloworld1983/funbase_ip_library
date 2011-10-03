-- megafunction wizard: %FIFO%
-- GENERATION: STANDARD
-- VERSION: WM1.0
-- MODULE: dcfifo 

-- ============================================================
-- File Name: fifo_multi_clk.vhd
-- Megafunction Name(s):
-- 			dcfifo
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library altera_mf;
use altera_mf.all;

entity alt_fifo_sc is
	generic ( DATA_WIDTH : integer := 8;
            FIFO_LENGTH : integer := 256;
            CNT_WIDTH : integer := 9 );
            
  port (
		clk : in std_logic;
		rst_n : in std_logic;
		
    wdata_in : in std_logic_vector(DATA_WIDTH-1 downto 0);
		rdata_out : out std_logic_vector(DATA_WIDTH-1 downto 0);
    re_in : in std_logic;
		we_in : in std_logic;
		empty_out : out std_logic;
		one_d_out : out std_logic;
    one_p_out : out std_logic;
    count_out : out std_logic_vector(CNT_WIDTH-1 downto 0);
		full_out : out std_logic );
end alt_fifo_sc;


architecture rtl of alt_fifo_sc is
  
  component scfifo
	generic (
		add_ram_output_register	:	string := "OFF";
		allow_rwcycle_when_full	:	string := "OFF";
		almost_empty_value	:	natural := 0;
		almost_full_value	:	natural := 0;
		intended_device_family	:	string := "unused";
		lpm_numwords	:	natural;
		lpm_showahead	:	string := "OFF";
		lpm_width	:	natural;
		lpm_widthu	:	natural := 1;
		overflow_checking	:	string := "ON";
		underflow_checking	:	string := "ON";
		use_eab	:	string := "ON";
		lpm_hint	:	string := "UNUSED";
		lpm_type	:	string := "scfifo"
	);
	port(
		aclr	:	in std_logic := '0';
		almost_empty	:	out std_logic;
		almost_full	:	out std_logic;
		clock	:	in std_logic;
		data	:	in std_logic_vector(lpm_width-1 downto 0);
		empty	:	out std_logic;
		full	:	out std_logic;
		q	:	out std_logic_vector(lpm_width-1 downto 0);
		rdreq	:	in std_logic;
		sclr	:	in std_logic := '0';
		usedw	:	out std_logic_vector(lpm_widthu-1 downto 0);
		wrreq	:	in std_logic
	);
  end component;
  
  function i2s(value : integer; width : integer) return std_logic_vector is
  begin
    return conv_std_logic_vector(value, width);
  end;
  
  function s2i(value : std_logic_vector) return integer is
  begin
    return conv_integer(value);
  end;
  
  constant ENABLE_SIM : integer := 0
  -- synthesis translate_off
  + 1
  -- synthesis translate_on
  ;
  
--  constant UNDEF : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => 'X');
  
  signal aclr : std_logic;
  signal rdata : std_logic_vector(DATA_WIDTH-1 downto 0);
  
begin
  
  aclr <= not(rst_n);
  
  rdata_out <= i2s(s2i(rdata), DATA_WIDTH);
  
  
  fifo_0 : scfifo
	generic map (	add_ram_output_register => "OFF",
		            almost_empty_value => 2,
		            almost_full_value => FIFO_LENGTH-1,
		            intended_device_family => "Arria II GX",
		            lpm_numwords => FIFO_LENGTH,
		            lpm_showahead => "ON",
		            lpm_type => "scfifo",
		            lpm_width => DATA_WIDTH,
		            lpm_widthu => CNT_WIDTH,
		            overflow_checking => "ON",
		            underflow_checking => "ON",
		            use_eab => "ON"
                	)
	
  port map ( data => wdata_in,
             clock => clk,
             aclr => aclr,
             rdreq => re_in,
             wrreq => we_in,
             usedw => count_out,
		         almost_empty => one_d_out,
		         almost_full => one_p_out, 
             full => full_out,
             empty => empty_out,
             q => rdata );
  
  
end rtl;
