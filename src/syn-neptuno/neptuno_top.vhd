-------------------------------------------------------------------------------
--
-- MSX1 FPGA project
--
-- Copyright (c) 2016, Fabio Belavenuto (belavenuto@gmail.com)
--
-- TOP created by Victor Trucco (c) 2018
--
-- All rights reserved
--
-- Redistribution and use in source and synthezised forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- Redistributions of source code must retain the above copyright notice,
-- this list of conditions and the following disclaimer.
--
-- Redistributions in synthesized form must reproduce the above copyright
-- notice, this list of conditions and the following disclaimer in the
-- documentation and/or other materials provided with the distribution.
--
-- Neither the name of the author nor the names of other contributors may
-- be used to endorse or promote products derived from this software without
-- specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
--
-- Please report bugs to the author, but before you do so, please
-- make sure that this is not a derivative work and that
-- you have the latest version of this file.
--
-------------------------------------------------------------------------------
-- Neptuno Top adapted 07/09/2020 delgrom
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.msx_pack.all;

entity neptuno_top is
	port (
		-- Clocks
		clock_50_i			: in    std_logic;

		-- Buttons
		btn_n_i				: in    std_logic_vector(4 downto 1);

		-- SRAM (AS7C34096)
--		sram_addr_o			: out   std_logic_vector(18 downto 0)	:= (others => '0');
--		sram_data_io		: inout std_logic_vector( 7 downto 0)	:= (others => 'Z');
--		sram_we_n_o			: out   std_logic								:= '1';
--		sram_oe_n_o			: out   std_logic								:= '1';

		-- SDRAM	(H57V256 = 16Mx16 = 32MB)
		sdram_clk_o			: out   std_logic								:= '0';
		sdram_cke_o			: out   std_logic								:= '0';
		sdram_ad_o			: out   std_logic_vector(12 downto 0)	:= (others => '0');
		sdram_da_io			: inout std_logic_vector(15 downto 0)	:= (others => 'Z');
		sdram_ba_o			: out   std_logic_vector( 1 downto 0)	:= (others => '0');
		sdram_dqm_o			: out   std_logic_vector( 1 downto 0)	:= (others => '1');
		sdram_ras_o			: out   std_logic								:= '1';
		sdram_cas_o			: out   std_logic								:= '1';
		sdram_cs_o			: out   std_logic								:= '1';
		sdram_we_o			: out   std_logic								:= '1';

		-- PS2
		ps2_clk_io			: inout std_logic								:= 'Z';
		ps2_data_io			: inout std_logic								:= 'Z';
		ps2_mouse_clk_io  : inout std_logic								:= 'Z';
		ps2_mouse_data_io : inout std_logic								:= 'Z';

		-- SD Card
		sd_cs_n_o			: out   std_logic								:= '1';
		sd_sclk_o			: out   std_logic								:= '0';
		sd_mosi_o			: out   std_logic								:= '0';
		sd_miso_i			: in    std_logic;

		-- Joysticks
--		joy1_up_i			: in    std_logic;
--		joy1_down_i			: in    std_logic;
--		joy1_left_i			: in    std_logic;
--		joy1_right_i		: in    std_logic;
--		joy1_p6_i			: in    std_logic;
--		joy1_p9_i			: in    std_logic;
--		joy2_up_i			: in    std_logic;
--		joy2_down_i			: in    std_logic;
--		joy2_left_i			: in    std_logic;
--		joy2_right_i		: in    std_logic;
--		joy2_p6_i			: in    std_logic;
--		joy2_p9_i			: in    std_logic;
		JOY_CLK				: out   std_logic;
		JOY_LOAD 			: out   std_logic;
		JOY_DATA 			: in    std_logic;
		joyX_p7_o			: out   std_logic								:= '1';
				
		-- Audio
		dac_l_o				: out   std_logic								:= '0';
		dac_r_o				: out   std_logic								:= '0';
		ear_i					: in    std_logic;
		mic_o					: out   std_logic								:= '0';

		-- VGA
		vga_r_o				: out   std_logic_vector(5 downto 0)	:= (others => '0');
		vga_g_o				: out   std_logic_vector(5 downto 0)	:= (others => '0');
		vga_b_o				: out   std_logic_vector(5 downto 0)	:= (others => '0');
		vga_hsync_n_o		: out   std_logic								:= '1';
		vga_vsync_n_o		: out   std_logic								:= '1';
		
		--STM32
		stm_rst_o			: out std_logic		:= '0'; -- '0' to hold the microcontroller reset line, to free the SD card

		-- I2S audio		
		i2s_bclk				: out   std_logic								:= '0';
		i2s_lrclk			: out   std_logic								:= '0';
		i2s_data				: out   std_logic								:= '0'		
		
	);
end entity;

architecture behavior of neptuno_top is

	component audio_top is
	Port ( 	
				clk_50MHz : in STD_LOGIC; -- system clock (50 MHz)
				dac_MCLK : out STD_LOGIC; -- outputs to PMODI2L DAC
				dac_LRCK : out STD_LOGIC;
				dac_SCLK : out STD_LOGIC;
				dac_SDIN : out STD_LOGIC;
				L_data : 	in std_logic_vector(15 downto 0);  	-- LEFT data (15-bit signed)
				R_data : 	in std_logic_vector(15 downto 0)  	-- RIGHT data (15-bit signed) 
	);
	end component;	

	-- Buttons
	signal btn_por_n_s		: std_logic;
	signal btn_reset_n_s		: std_logic;
	signal btn_scan_s			: std_logic;

	-- Resets
	signal pll_locked_s		: std_logic;
	signal por_s				: std_logic;
	signal reset_s				: std_logic;
	signal soft_reset_k_s	: std_logic;
	signal soft_reset_s_s	: std_logic;
	signal soft_por_s			: std_logic;
	signal soft_rst_cnt_s	: unsigned(7 downto 0)	:= X"FF";

	-- Clocks
	signal clock_sdram_s		: std_logic;
	signal clock_master_s	: std_logic;
	signal clock_vdp_s		: std_logic;
	signal clock_cpu_s		: std_logic;
	signal clock_psg_en_s	: std_logic;
	signal clock_3m_s			: std_logic;
	signal turbo_on_s			: std_logic;
	signal clock_vga_s		: std_logic;
	signal clock_dvi_s		: std_logic;
	signal clock_vga2x_s		: std_logic;

	-- RAM
	signal ram_addr_s			: std_logic_vector(22 downto 0);		-- 8MB
	signal ram_data_from_s	: std_logic_vector( 7 downto 0);
	signal ram_data_to_s		: std_logic_vector( 7 downto 0);
	signal ram_ce_s			: std_logic;
	signal ram_oe_s			: std_logic;
	signal ram_we_s			: std_logic;

	-- VRAM memory
	signal vram_addr_s		: std_logic_vector(13 downto 0);		-- 16K
	signal vram_do_s			: std_logic_vector( 7 downto 0);
	signal vram_di_s			: std_logic_vector( 7 downto 0);
	signal vram_we_s			: std_logic;

	-- Audio
	signal audio_scc_s		: signed(14 downto 0);
	signal audio_psg_s		: unsigned( 7 downto 0);
	signal beep_s				: std_logic;
	signal audio_l_s			: unsigned(15 downto 0);
	signal audio_r_s			: unsigned(15 downto 0);
	signal audio_l_amp_s		: unsigned(15 downto 0);
	signal audio_r_amp_s		: unsigned(15 downto 0);
	signal volumes_s			: volumes_t;

	-- Video
	signal rgb_col_s			: std_logic_vector( 3 downto 0);
	signal cnt_hor_s			: std_logic_vector( 8 downto 0);
	signal cnt_ver_s			: std_logic_vector( 7 downto 0);
	signal vga_hsync_n_s		: std_logic;
	signal vga_vsync_n_s		: std_logic;
	signal vga_blank_s		: std_logic;
	signal vga_col_s			: std_logic_vector( 3 downto 0);
	signal vga_r_s				: std_logic_vector( 3 downto 0);
	signal vga_g_s				: std_logic_vector( 3 downto 0);
	signal vga_b_s				: std_logic_vector( 3 downto 0);
	signal scanlines_en_s	: std_logic;
	signal odd_line_s			: std_logic;

	-- señales video 
	signal rgb_r_s				: std_logic_vector( 3 downto 0);
	signal rgb_g_s				: std_logic_vector( 3 downto 0);
	signal rgb_b_s				: std_logic_vector( 3 downto 0);
	signal rgb_hsync_n_s		: std_logic;
	signal rgb_vsync_n_s		: std_logic;
	signal ntsc_pal_s			: std_logic;
	signal vga_en_s			: std_logic;	
	
	-- Keyboard
	signal rows_s				: std_logic_vector( 3 downto 0);
	signal cols_s				: std_logic_vector( 7 downto 0);
	signal caps_en_s			: std_logic;
	signal extra_keys_s		: std_logic_vector( 3 downto 0);
	signal keyb_valid_s		: std_logic;
	signal keyb_data_s		: std_logic_vector( 7 downto 0);
	signal keymap_addr_s		: std_logic_vector( 8 downto 0);
	signal keymap_data_s		: std_logic_vector( 7 downto 0);
	signal keymap_we_s		: std_logic;

	-- Joystick
	signal joy1_out_s			: std_logic;
	signal joy2_out_s			: std_logic;

	-- Bus
	signal bus_addr_s			: std_logic_vector(15 downto 0);
	signal bus_data_from_s	: std_logic_vector( 7 downto 0)	:= (others => '1');
	signal bus_data_to_s		: std_logic_vector( 7 downto 0);
	signal bus_rd_n_s			: std_logic;
	signal bus_wr_n_s			: std_logic;
	signal bus_m1_n_s			: std_logic;
	signal bus_iorq_n_s		: std_logic;
	signal bus_mreq_n_s		: std_logic;
	signal bus_sltsl1_n_s	: std_logic;
	signal bus_sltsl2_n_s	: std_logic;
	signal bus_int_n_s		: std_logic;
	signal bus_wait_n_s		: std_logic;

	-- JT51
	signal jt51_cs_n_s		: std_logic;
	signal jt51_data_from_s	: std_logic_vector( 7 downto 0)	:= (others => '1');
	signal jt51_hd_s			: std_logic								:= '0';
	signal jt51_left_s		: signed(15 downto 0)				:= (others => '0');
	signal jt51_right_s		: signed(15 downto 0)				:= (others => '0');
		
	-- OPLL
	signal opll_cs_n_s		: std_logic							:= '1';
	signal opll_mo_s			: signed(12 downto 0)			:= (others => '0');
	signal opll_ro_s			: signed(12 downto 0)			:= (others => '0');
	
	-- JOYSTICKS
	signal joy1up			: std_logic								:= '1';
	signal joy1down		: std_logic								:= '1';
	signal joy1left		: std_logic								:= '1';
	signal joy1right		: std_logic								:= '1';
	signal joy1fire1		: std_logic								:= '1';
	signal joy1fire2		: std_logic								:= '1';
	signal joy2up			: std_logic								:= '1';
	signal joy2down		: std_logic								:= '1';
	signal joy2left		: std_logic								:= '1';
	signal joy2right		: std_logic								:= '1';
	signal joy2fire1		: std_logic								:= '1';
	signal joy2fire2		: std_logic								:= '1';
	
	-- i2s 
	signal i2s_mclk		    : std_logic								:= '0';
	
	component joydecoder is
	Port ( 	
 				clk 			: in std_logic; 
				joy_data    : in std_logic;
				joy_clk		: out std_logic;
				joy_load_n	: out std_logic;
				joy1up		: out std_logic;
				joy1down		: out std_logic;
				joy1left		: out std_logic;
				joy1right	: out std_logic;
				joy1fire1	: out std_logic;
				joy1fire2	: out std_logic;
				joy2up		: out std_logic;
				joy2down		: out std_logic;
				joy2left		: out std_logic;
				joy2right	: out std_logic;
				joy2fire1	: out std_logic;
				joy2fire2	: out std_logic
 	);
   end component;	
	

begin

	stm_rst_o <= '0';



	-- PLL1
	pll: entity work.pll1
	port map (
		inclk0	=> clock_50_i,
		c0			=> clock_master_s,		-- 21.477 MHz					[21.484]
		c1			=> clock_sdram_s,			-- 85.908 MHz (4x master)	[85.937]
		c2			=> sdram_clk_o,			-- 85.908 MHz -90Â°
		locked	=> pll_locked_s
	);

	-- PLL2
	pll2: entity work.pll2
	port map (
		inclk0	=> clock_50_i,
		c0			=> clock_vga_s,			--  25.200
		c1			=> clock_dvi_s				-- 126.000
	);

	-- Clocks
	clks: entity work.clocks
	port map (
		clock_i			=> clock_master_s,
		por_i				=> not pll_locked_s,
		turbo_on_i		=> turbo_on_s,
		clock_vdp_o		=> clock_vdp_s,
		clock_5m_en_o	=> open,
		clock_cpu_o		=> clock_cpu_s,
		clock_psg_en_o	=> clock_psg_en_s,
		clock_3m_o		=> clock_3m_s
	);

	-- The MSX1
	the_msx: entity work.msx
	generic map (
		hw_id_g			=> 8,
		hw_txt_g			=> "neptUNO Board",
		hw_version_g	=> actual_version,
--		video_opt_g		=> 3,							-- No dblscan and external palette (Color in rgb_r_o)
		video_opt_g		=> 1,						-- 1 = dblscan configurable    
		ramsize_g		=> 8192,
		hw_hashwds_g	=> '0'
	)
	port map (
		-- Clocks
		clock_i			=> clock_master_s,
		clock_vdp_i		=> clock_vdp_s,
		clock_cpu_i		=> clock_cpu_s,
		clock_psg_en_i	=> clock_psg_en_s,
		-- Turbo
		turbo_on_k_i	=> extra_keys_s(3),	-- F11
		turbo_on_o		=> turbo_on_s,
		-- Resets
		reset_i			=> reset_s,
		por_i				=> por_s,
		softreset_o		=> soft_reset_s_s,
		-- Options
		opt_nextor_i	=> '1',
		opt_mr_type_i	=> "00",
--		opt_vga_on_i	=> '1',
		opt_vga_on_i	=> '0',  --
		-- RAM
		ram_addr_o		=> ram_addr_s,
		ram_data_i		=> ram_data_from_s,
		ram_data_o		=> ram_data_to_s,
		ram_ce_o			=> ram_ce_s,
		ram_we_o			=> ram_we_s,
		ram_oe_o			=> ram_oe_s,
		-- ROM
		rom_addr_o		=> open,
		rom_data_i		=> ram_data_from_s,
		rom_ce_o			=> open,
		rom_oe_o			=> open,
		-- External bus
		bus_addr_o		=> bus_addr_s,
		bus_data_i		=> bus_data_from_s,
		bus_data_o		=> bus_data_to_s,
		bus_rd_n_o		=> bus_rd_n_s,
		bus_wr_n_o		=> bus_wr_n_s,
		bus_m1_n_o		=> bus_m1_n_s,
		bus_iorq_n_o	=> bus_iorq_n_s,
		bus_mreq_n_o	=> bus_mreq_n_s,
		bus_sltsl1_n_o	=> bus_sltsl1_n_s,
		bus_sltsl2_n_o	=> bus_sltsl2_n_s,
		bus_wait_n_i	=> bus_wait_n_s,
		bus_nmi_n_i		=> '1',
		bus_int_n_i		=> bus_int_n_s,
		-- VDP RAM
		vram_addr_o		=> vram_addr_s,
		vram_data_i		=> vram_do_s,
		vram_data_o		=> vram_di_s,
		vram_ce_o		=> open,--vram_ce_s,
		vram_oe_o		=> open,--vram_oe_s,
		vram_we_o		=> vram_we_s,
		-- Keyboard
		rows_o			=> rows_s,
		cols_i			=> cols_s,
		caps_en_o		=> caps_en_s,
		keyb_valid_i	=> keyb_valid_s,
		keyb_data_i		=> keyb_data_s,
		keymap_addr_o	=> keymap_addr_s,
		keymap_data_o	=> keymap_data_s,
		keymap_we_o		=> keymap_we_s,
		-- Audio
		audio_scc_o		=> audio_scc_s,
		audio_psg_o		=> audio_psg_s,
		beep_o			=> beep_s,
		volumes_o		=> volumes_s,
		-- K7
		k7_motor_o		=> open,
		k7_audio_o		=> mic_o,
		k7_audio_i		=> ear_i,
		-- Joystick
--		joy1_up_i		=> joy1_up_i,
--		joy1_down_i		=> joy1_down_i,
--		joy1_left_i		=> joy1_left_i,
--		joy1_right_i	=> joy1_right_i,
--		joy1_btn1_i		=> joy1_p6_i,
--		joy1_btn1_o		=> open,
--		joy1_btn2_i		=> joy1_p9_i,
--		joy1_btn2_o		=> open,
--		joy1_out_o		=> joy1_out_s,
--		joy2_up_i		=> joy2_up_i,
--		joy2_down_i		=> joy2_down_i,
--		joy2_left_i		=> joy2_left_i,
--		joy2_right_i	=> joy2_right_i,
--		joy2_btn1_i		=> joy2_p6_i,
--		joy2_btn1_o		=> open,
--		joy2_btn2_i		=> joy2_p9_i,
--		joy2_btn2_o		=> open,
--		joy2_out_o		=> joy2_out_s,

		-- Joystick
		joy1_up_i		=> joy1up,
		joy1_down_i		=> joy1down,
		joy1_left_i		=> joy1left,
		joy1_right_i	=> joy1right,
		joy1_btn1_i		=> joy1fire1,
		joy1_btn1_o		=> open,
		joy1_btn2_i		=> joy1fire2,
		joy1_btn2_o		=> open,
		joy1_out_o		=> open,
		joy2_up_i		=> joy2up,
		joy2_down_i		=> joy2down,
		joy2_left_i		=> joy2left,
		joy2_right_i	=> joy2right,
		joy2_btn1_i		=> joy2fire1,
		joy2_btn1_o		=> open,
		joy2_btn2_i		=> joy2fire2,
		joy2_btn2_o		=> open,
		joy2_out_o		=> open,		
		

		
		-- video  
		cnt_hor_o		=> open,
		cnt_ver_o		=> open,
		rgb_r_o			=> rgb_r_s,
		rgb_g_o			=> rgb_g_s,
		rgb_b_o			=> rgb_b_s,
		hsync_n_o		=> rgb_hsync_n_s,
		vsync_n_o		=> rgb_vsync_n_s,
		ntsc_pal_o		=> ntsc_pal_s,
		vga_on_k_i		=> extra_keys_s(2),		-- Print Screen
		vga_en_o			=> vga_en_s,
		scanline_on_k_i=> extra_keys_s(1),		-- Scroll Lock
		scanline_en_o	=> open,
		vertfreq_on_k_i=> extra_keys_s(0),		-- Pause/Break						
		-- SPI/SD
		spi_cs_n_o		=> sd_cs_n_o,
		spi_sclk_o		=> sd_sclk_o,
		spi_mosi_o		=> sd_mosi_o,
		spi_miso_i		=> sd_miso_i,
		sd_pres_n_i		=> '0',
		sd_wp_i			=> '0',
		-- DEBUG
		D_wait_o			=> open,
		D_slots_o		=> open,
		D_ipl_en_o		=> open
	);

--	joyX_p7_o <= not joy1_out_s;		-- for Sega Genesis joypad
	--joy2_p7_o <= not joy2_out_s;		-- for Sega Genesis joypad

	-- RAM
	ram: entity work.ssdram256Mb
	generic map (
		freq_g		=> 85
	)
	port map (
		clock_i		=> clock_sdram_s,
		reset_i		=> reset_s,
		refresh_i	=> '1',
		-- Static RAM bus
		addr_i		=> "00" & ram_addr_s,
		data_i		=> ram_data_to_s,
		data_o		=> ram_data_from_s,
		cs_i			=> ram_ce_s,
		oe_i			=> ram_oe_s,
		we_i			=> ram_we_s,
		-- SD-RAM ports
		mem_cke_o	=> sdram_cke_o,
		mem_cs_n_o	=> sdram_cs_o,
		mem_ras_n_o	=> sdram_ras_o,
		mem_cas_n_o	=> sdram_cas_o,
		mem_we_n_o	=> sdram_we_o,
		mem_udq_o	=> sdram_dqm_o(1),
		mem_ldq_o	=> sdram_dqm_o(0),
		mem_ba_o		=> sdram_ba_o,
		mem_addr_o	=> sdram_ad_o,
		mem_data_io	=> sdram_da_io
	);

	-- VRAM
	vram: entity work.spram
	generic map (
		addr_width_g => 14,
		data_width_g => 8
	)
	port map (
		clk_i		=> clock_master_s,
		we_i		=> vram_we_s,
		addr_i	=> vram_addr_s,
		data_i	=> vram_di_s,
		data_o	=> vram_do_s
	);

	-- Keyboard PS/2
	keyb: entity work.keyboard
	port map (
		clock_i			=> clock_3m_s,
		reset_i			=> reset_s,
		-- MSX
		rows_coded_i	=> rows_s,
		cols_o			=> cols_s,
		keymap_addr_i	=> keymap_addr_s,
		keymap_data_i	=> keymap_data_s,
		keymap_we_i		=> keymap_we_s,
		-- LEDs
		led_caps_i		=> caps_en_s, 
		-- PS/2 interface
		ps2_clk_io		=> ps2_clk_io,
		ps2_data_io		=> ps2_data_io,
		-- Direct Access
		keyb_valid_o	=> keyb_valid_s,
		keyb_data_o		=> keyb_data_s,
		--
		reset_o			=> soft_reset_k_s,
		por_o				=> soft_por_s,
		reload_core_o	=> open, 
		extra_keys_o	=> extra_keys_s
	);

	-- JOYSTICKS
	joy: joydecoder
	  port map (
		clk				=> clock_master_s,
		joy_clk			=> JOY_CLK,
		joy_load_n 		=> JOY_LOAD,
		joy_data			=> JOY_DATA,		
		joy1up  			=> joy1up,
		joy1down			=> joy1down,
		joy1left			=> joy1left,
		joy1right		=> joy1right,
		joy1fire1		=> joy1fire1,
		joy1fire2		=> joy1fire2,
		joy2up  			=> joy2up,
		joy2down			=> joy2down,
		joy2left			=> joy2left,
		joy2right		=> joy2right,
		joy2fire1		=> joy2fire1,
		joy2fire2		=> joy2fire2
	);	
	
	-- Audio
	mixer: entity work.mixeru
	port map (
		clock_i			=> clock_master_s,
		reset_i			=> reset_s,
		volumes_i		=> volumes_s,
		beep_i			=> beep_s,
		ear_i				=> ear_i,
		audio_scc_i		=> audio_scc_s,
		audio_psg_i		=> audio_psg_s,
		jt51_left_i		=> jt51_left_s,
		jt51_right_i	=> jt51_right_s,
		opll_mo_i		=> opll_mo_s,
		opll_ro_i		=> opll_ro_s,
		audio_mix_l_o	=> audio_l_s,
		audio_mix_r_o	=> audio_r_s
	);

	audio_l_amp_s	<= audio_l_s(15) & audio_l_s(13 downto 0) & "0";
	audio_r_amp_s	<= audio_r_s(15) & audio_r_s(13 downto 0) & "0";

	-- Left Channel
	audiol : entity work.dac
	generic map (
		nbits_g	=> 16
	)
	port map (
		reset_i	=> reset_s,
		clock_i	=> clock_3m_s,
		dac_i		=> audio_l_amp_s,
		dac_o		=> dac_l_o
	);

	-- Right Channel
	audior : entity work.dac
	generic map (
		nbits_g	=> 16
	)
	port map (
		reset_i	=> reset_s,
		clock_i	=> clock_3m_s,
		dac_i		=> audio_r_amp_s,
		dac_o		=> dac_r_o
	);
	
	-- I2S audio
	
	audio_i2s: entity work.audio_top
	port map(
		clk_50MHz => clock_50_i,
		dac_MCLK  => i2s_mclk,
		dac_LRCK  => i2s_lrclk,
		dac_SCLK  => i2s_bclk,
		dac_SDIN  => i2s_data,
		L_data    => std_logic_vector(audio_l_s),
		R_data    => std_logic_vector(audio_r_s)
	);		
	
	-- Glue logic

	-- Resets
	btn_por_n_s		<= btn_n_i(2) or btn_n_i(4);
	btn_reset_n_s	<= btn_n_i(3) or btn_n_i(4);

	por_s			<= '1'	when pll_locked_s = '0' or soft_por_s = '1' or btn_por_n_s = '0'		else '0';
	reset_s		<= '1'	when soft_rst_cnt_s = X"01"                 or btn_reset_n_s = '0'	else '0';

	process(reset_s, clock_master_s)
	begin
		if reset_s = '1' then
			soft_rst_cnt_s	<= X"00";
		elsif rising_edge(clock_master_s) then
			if (soft_reset_k_s = '1' or soft_reset_s_s = '1' or por_s = '1') and soft_rst_cnt_s = X"00" then
				soft_rst_cnt_s	<= X"FF";
			elsif soft_rst_cnt_s /= X"00" then
				soft_rst_cnt_s <= soft_rst_cnt_s - 1;
			end if;
		end if;
	end process;

	-- RGB/VGA Output 
	vga_r_o			<= rgb_r_s & '0' & '0';
	vga_g_o			<= rgb_g_s & '0' & '0';
	vga_b_o			<= rgb_b_s & '0' & '0';
	vga_hsync_n_o	<= rgb_hsync_n_s			when vga_en_s = '1'	else (rgb_hsync_n_s and rgb_vsync_n_s);
	vga_vsync_n_o	<= rgb_vsync_n_s			when vga_en_s = '1'	else '1';
	--	vga_ntsc_o		<= not ntsc_pal_s;
	--	vga_pal_o		<= ntsc_pal_s;

	-- Peripheral BUS control
	bus_data_from_s	<= jt51_data_from_s	when jt51_hd_s = '1'	else
--							   midi_data_from_s	when midi_hd_s = '1'	else
								(others => '1');
	bus_wait_n_s	<= '1';--midi_wait_n_s;
	bus_int_n_s		<= '1';--midi_int_n_s;

	-- JT51
	jt51_cs_n_s <= '0' when bus_addr_s(7 downto 1) = "0010000" and bus_iorq_n_s = '0' and bus_m1_n_s = '1'	else '1';	-- 0x20 - 0x21

	jt51: entity work.jt51_wrapper
	port map (
		clock_i			=> clock_3m_s,
		reset_i			=> reset_s,
		addr_i			=> bus_addr_s(0),
		cs_n_i			=> jt51_cs_n_s,
		wr_n_i			=> bus_wr_n_s,
		rd_n_i			=> bus_rd_n_s,
		data_i			=> bus_data_to_s,
		data_o			=> jt51_data_from_s,
		has_data_o		=> jt51_hd_s,
		ct1_o				=> open,
		ct2_o				=> open,
		irq_n_o			=> open,
		p1_o				=> open,
		-- Low resolution output (same as real chip)
		sample_o			=> open,
		left_o			=> open,
		right_o			=> open,
		-- Full resolution output
		xleft_o			=> jt51_left_s,
		xright_o			=> jt51_right_s,
		-- unsigned outputs for sigma delta converters, full resolution		
		dacleft_o		=> open,
		dacright_o		=> open
	);

	-- OPLL
	opll_cs_n_s	<= '0' when bus_addr_s(7 downto 1) = "0111110" and bus_iorq_n_s = '0' and bus_m1_n_s = '1'	else '1';	-- 0x7C - 0x7D

	opll1 : entity work.opll 
	port map (
		clock_i		=> clock_master_s,
		clock_en_i	=> clock_psg_en_s,
		reset_i		=> reset_s,
		data_i		=> bus_data_to_s,
		addr_i		=> bus_addr_s(0),
		cs_n        => opll_cs_n_s,
		we_n        => bus_wr_n_s,
		melody_o		=> opll_mo_s,
		rythm_o		=> opll_ro_s
	);
end architecture;