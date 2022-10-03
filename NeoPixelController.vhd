-- WS2812 communication interface starting point for
-- ECE 2031 final project spring 2022.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 
use ieee.std_logic_unsigned.all;
--use ieee.std_logic_arith.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

entity NeoPixelController is

	port(
		clk_10M   : in   std_logic;
		resetn    : in   std_logic;
		io_write  : in   std_logic;
		cs_addr   : in   std_logic;
		cs_data   : in   std_logic;
		data_in   : in   std_logic_vector(15 downto 0);
		sda       : out  std_logic;
		
		cs_16bit	 : in   std_logic;
		cs_24bit  : in   std_logic;
		cs_all    : in   std_logic;
		cs_inc    : in   std_logic;
		cs_advinc : in   std_logic;
		cs_letter : in   std_logic;
		cs_invert : in   std_logic;
		cs_unset:   in   std_logic;
		cs_shift: in std_logic;
		cs_number: in std_logic;
		cs_even: in std_logic;
		cs_odd: in std_logic
	); 

end entity;

architecture internals of NeoPixelController is
	
	-- Signals for the RAM read and write addresses
	signal ram_read_addr, ram_write_addr : std_logic_vector(7 downto 0);
	-- RAM write enable
	signal ram_we : std_logic;
	signal mode : integer range 0 to 16;
	signal outputCheck : std_logic;
	signal BR 			: std_logic_vector(15 downto 0); --BLUE + RED vector
	signal inc  : integer range 1 to 255;  -- INCREMENT ADVANCED FEATURE
	

	-- Signals for data coming out of memory
	signal ram_read_data : std_logic_vector(23 downto 0);
	-- Signal to store the current output pixel's color data
	signal pixel_buffer : std_logic_vector(23 downto 0);

	-- Signal SCOMP will write to before it gets stored into memory
	signal ram_write_buffer : std_logic_vector(23 downto 0);
	--signal delay_count : integer range 0 to 9999999;
	--signal delay : std_logic;

	-- RAM interface state machine signals
	type write_states is (idle, storing, increment);
	signal wstate: write_states;
	--signal pixels: std_logic_vector(
	signal background_check : std_logic_vector(255 downto 0) := (others => '1');
	--signal fade_check : std_logic_vector(255 downto 0) := (others => '1');
	signal default_color : std_logic_vector(23 downto 0) := (others => '0');
	signal ram_write_addr_int : integer;
	signal ram_read_addr_int : integer;
	signal i : integer;
	signal data: integer;
	signal numIn: std_logic_vector(3 downto 0);
	
	
begin
	ram_write_addr_int <= to_integer(unsigned(ram_write_addr));
	ram_read_addr_int <= to_integer(unsigned(ram_read_addr));
	data <= to_integer(unsigned(data_in));
	-- This is the RAM that will store the pixel data.
	-- It is dual-ported.  SCOMP will access port "A",
	-- and the NeoPixel controller will access port "B".
	pixelRAM : altsyncram
	GENERIC MAP (
		address_reg_b => "CLOCK0",
		clock_enable_input_a => "BYPASS",
		clock_enable_input_b => "BYPASS",
		clock_enable_output_a => "BYPASS",
		clock_enable_output_b => "BYPASS",
		indata_reg_b => "CLOCK0",
		intended_device_family => "Cyclone V",
		lpm_type => "altsyncram",
		numwords_a => 256,
		numwords_b => 256,
		operation_mode => "BIDIR_DUAL_PORT",
		outdata_aclr_a => "NONE",
		outdata_aclr_b => "NONE",
		outdata_reg_a => "UNREGISTERED",
		outdata_reg_b => "UNREGISTERED",
		power_up_uninitialized => "FALSE",
		read_during_write_mode_mixed_ports => "OLD_DATA",
		read_during_write_mode_port_a => "NEW_DATA_NO_NBE_READ",
		read_during_write_mode_port_b => "NEW_DATA_NO_NBE_READ",
		widthad_a => 8,
		widthad_b => 8,
		width_a => 24,
		width_b => 24,
		width_byteena_a => 1,
		width_byteena_b => 1,
		wrcontrol_wraddress_reg_b => "CLOCK0"
	)
	PORT MAP (
		address_a => ram_write_addr,
		address_b => ram_read_addr,
		clock0 => clk_10M,
		data_a => ram_write_buffer,
		data_b => x"000000",
		wren_a => ram_we,
		wren_b => '0',
		q_b => ram_read_data
	);

	process(resetn, clk_10M, cs_addr, cs_16bit, cs_24bit, cs_all, cs_inc)
	begin 
		if resetn = '0' then
			background_check <= (others => '1');
		elsif rising_edge(clk_10M) then
			-- If SCOMP is writing to the address register...
			if (io_write = '1') and (cs_addr='1') then
				background_check(ram_write_addr_int) <= '1';
			end if;
			
			if (io_write = '1') and (cs_all='1') then
				background_check <= (others => '0');		
			end if;
			
			
			if (io_write = '1') and (cs_letter = '1') then
				background_check(2) <= '0';
				background_check(3) <= '0';	
				background_check(4) <= '0';
				background_check(5) <= '0';	
				background_check(15) <= '0';
				background_check(16) <= '0';	
				background_check(26) <= '0';
				background_check(27) <= '0';
				background_check(28) <= '0';
				background_check(29) <= '0';	
				background_check(34) <= '0';
				background_check(46) <= '0';	
				background_check(58) <= '0';
				background_check(66) <= '0';	
				background_check(67) <= '0';
				background_check(68) <= '0';	
				background_check(69) <= '0';
				background_check(82) <= '0';	
				background_check(90) <= '0';
				background_check(91) <= '0';	
				background_check(92) <= '0';
				background_check(93) <= '0';	
				background_check(98) <= '0';
				background_check(109) <= '0';	
				background_check(122) <= '0';	
				background_check(133) <= '0';
				background_check(145) <= '0';	
				background_check(157) <= '0';
				background_check(162) <= '0';	
				background_check(163) <= '0';
				background_check(164) <= '0';	
				background_check(165) <= '0';
				background_check(175) <= '0';	
				background_check(176) <= '0';
				background_check(186) <= '0';	
				background_check(187) <= '0';	
				background_check(188) <= '0';
				background_check(189) <= '0';	
			end if;
			
			if (io_write = '1') and (cs_number = '1') then
				
				-- numbers for two
				if (numIn = "0010") then
					background_check(44) <= '0';
					background_check(45) <= '0';
					background_check(46) <= '0';
					background_check(47) <= '0';
					background_check(83) <= '0';
					background_check(108) <= '0';
					background_check(109) <= '0';
					background_check(110) <= '0';
					background_check(111) <= '0';
					background_check(144) <= '0';
					background_check(172) <= '0';
					background_check(173) <= '0';
					background_check(174) <= '0';
					background_check(175) <= '0';
				end if;
				
				--numbers for zero 
				if (numIn = "0000") then
					background_check(44) <= '0';
					background_check(45) <= '0';
					background_check(46) <= '0';
					background_check(47) <= '0';
					background_check(80) <= '0';
					background_check(83) <= '0';
					background_check(108) <= '0';
					background_check(111) <= '0';
					background_check(144) <= '0';
					background_check(147) <= '0';
					background_check(172) <= '0';
					background_check(173) <= '0';
					background_check(174) <= '0';
					background_check(175) <= '0';
				end if;
				
				-- numbers for three
				if (numIn = "0011") then
					background_check(44) <= '0';
					background_check(45) <= '0';
					background_check(46) <= '0';
					background_check(47) <= '0';
					background_check(80) <= '0';
					background_check(108) <= '0';
					background_check(109) <= '0';
					background_check(110) <= '0';
					background_check(111) <= '0';
					background_check(144) <= '0';
					background_check(172) <= '0';
					background_check(173) <= '0';
					background_check(174) <= '0';
					background_check(175) <= '0';
				end if;
				
				
				-- numbers for one
				if (numIn = "0001") then
					background_check(47) <= '0';
					background_check(80) <= '0';
					background_check(111) <= '0';
					background_check(144) <= '0';
					background_check(175) <= '0';
				end if;
				
				-- numbers for four
				if (numIn = "0100") then
					background_check(47) <= '0';
					background_check(80) <= '0';
					background_check(108) <= '0';
					background_check(109) <= '0';
					background_check(110) <= '0';
					background_check(111) <= '0';
					background_check(144) <= '0';
					background_check(147) <= '0';
					background_check(172) <= '0';
					background_check(175) <= '0';
				end if;
				
				
				-- numbers for five
				if (numIn = "0101") then
					background_check(44) <= '0';
					background_check(45) <= '0';
					background_check(46) <= '0';
					background_check(47) <= '0';
					background_check(80) <= '0';
					background_check(108) <= '0';
					background_check(109) <= '0';
					background_check(110) <= '0';
					background_check(111) <= '0';
					background_check(147) <= '0';
					background_check(172) <= '0';
					background_check(173) <= '0';
					background_check(174) <= '0';
					background_check(175) <= '0';
				end if;
				
				-- numbers for six
				if (numIn = "0110") then
					background_check(44) <= '0';
					background_check(45) <= '0';
					background_check(46) <= '0';
					background_check(47) <= '0';
					background_check(80) <= '0';
					background_check(83) <= '0';
					background_check(108) <= '0';
					background_check(109) <= '0';
					background_check(110) <= '0';
					background_check(111) <= '0';
					background_check(147) <= '0';
					background_check(172) <= '0';
				end if;
				
				-- numbers for seven
				if (numIn = "0111") then
					background_check(47) <= '0';
					background_check(80) <= '0';
					background_check(111) <= '0';
					background_check(144) <= '0';
					background_check(172) <= '0';
					background_check(173) <= '0';
					background_check(174) <= '0';
					background_check(175) <= '0';
				end if;
				
				-- numbers for eight
				if (numIn = "1000") then
					background_check(44) <= '0';
					background_check(45) <= '0';
					background_check(46) <= '0';
					background_check(47) <= '0';
					background_check(80) <= '0';
					background_check(83) <= '0';
					background_check(108) <= '0';
					background_check(109) <= '0';
					background_check(110) <= '0';
					background_check(111) <= '0';
					background_check(144) <= '0';
					background_check(147) <= '0';
					background_check(172) <= '0';
					background_check(173) <= '0';
					background_check(174) <= '0';
					background_check(175) <= '0';
				end if;
				
				-- numbers for nine
				if (numIn = "1001") then
					background_check(47) <= '0';
					background_check(80) <= '0';
					background_check(108) <= '0';
					background_check(109) <= '0';
					background_check(110) <= '0';
					background_check(111) <= '0';
					background_check(144) <= '0';
					background_check(147) <= '0';
					background_check(172) <= '0';
					background_check(173) <= '0';
					background_check(174) <= '0';
					background_check(175) <= '0';
				end if;
				
				-- numbers for ten
				if (numIn = "1010") then
					background_check(47) <= '0';
					background_check(80) <= '0';
					background_check(111) <= '0';
					background_check(144) <= '0';
					background_check(175) <= '0';
					
					background_check(49) <= '0';
					background_check(50) <= '0';
					background_check(51) <= '0';
					background_check(52) <= '0';
					background_check(75) <= '0';
					background_check(78) <= '0';
					background_check(113) <= '0';
					background_check(114) <= '0';
					background_check(139) <= '0';
					background_check(142) <= '0';
					background_check(177) <= '0';
					background_check(178) <= '0';
					background_check(179) <= '0';
					background_check(180) <= '0';
				end if;
				
				-- numbers for eleven
				if (numIn = "1011") then
					background_check(47) <= '0';
					background_check(80) <= '0';
					background_check(111) <= '0';
					background_check(144) <= '0';
					background_check(175) <= '0';
					
					background_check(52) <= '0';
					background_check(75) <= '0';
					background_check(116) <= '0';
					background_check(139) <= '0';
					background_check(180) <= '0';
				end if;
				
				-- numbers for twelve
				if (numIn = "1100") then
					background_check(47) <= '0';
					background_check(80) <= '0';
					background_check(111) <= '0';
					background_check(144) <= '0';
					background_check(175) <= '0';
					
					background_check(49) <= '0';
					background_check(50) <= '0';
					background_check(51) <= '0';
					background_check(52) <= '0';
					background_check(78) <= '0';
					background_check(113) <= '0';
					background_check(114) <= '0';
					background_check(115) <= '0';
					background_check(116) <= '0';
					background_check(139) <= '0';
					background_check(177) <= '0';
					background_check(178) <= '0';
					background_check(179) <= '0';
					background_check(180) <= '0';
				end if;
				
				-- numbers for thirteen
				if (numIn = "1101") then
					background_check(47) <= '0';
					background_check(80) <= '0';
					background_check(111) <= '0';
					background_check(144) <= '0';
					background_check(175) <= '0';
					
					background_check(49) <= '0';
					background_check(50) <= '0';
					background_check(51) <= '0';
					background_check(52) <= '0';
					background_check(75) <= '0';
					background_check(113) <= '0';
					background_check(114) <= '0';
					background_check(115) <= '0';
					background_check(116) <= '0';
					background_check(139) <= '0';
					background_check(177) <= '0';
					background_check(178) <= '0';
					background_check(179) <= '0';
					background_check(180) <= '0';
				end if;
				
				-- numbers for fourteen
				if (numIn = "1110") then
					background_check(47) <= '0';
					background_check(80) <= '0';
					background_check(111) <= '0';
					background_check(144) <= '0';
					background_check(175) <= '0';
					
					background_check(52) <= '0';
					background_check(75) <= '0';
					background_check(113) <= '0';
					background_check(114) <= '0';
					background_check(115) <= '0';
					background_check(116) <= '0';
					background_check(139) <= '0';
					background_check(142) <= '0';
					background_check(177) <= '0';
					background_check(180) <= '0';
				end if;
				
				-- numbers for fifteen
				if (numIn = "1111") then
					background_check(47) <= '0';
					background_check(80) <= '0';
					background_check(111) <= '0';
					background_check(144) <= '0';
					background_check(175) <= '0';
					
					background_check(49) <= '0';
					background_check(50) <= '0';
					background_check(51) <= '0';
					background_check(52) <= '0';
					background_check(75) <= '0';
					background_check(113) <= '0';
					background_check(114) <= '0';
					background_check(115) <= '0';
					background_check(116) <= '0';
					background_check(142) <= '0';
					background_check(177) <= '0';
					background_check(178) <= '0';
					background_check(179) <= '0';
					background_check(180) <= '0';
				end if;
			end if;
			
			
			-- even pixels
			if (mode = 12) then
				background_check(0) <= '0';
				background_check(2) <= '0';
				background_check(4) <= '0';
				background_check(6) <= '0';
				background_check(8) <= '0';
				background_check(10) <= '0';
				background_check(12) <= '0';
				background_check(14) <= '0';
				background_check(16) <= '0';
				background_check(18) <= '0';
				background_check(20) <= '0';
				background_check(22) <= '0';
				background_check(24) <= '0';
				background_check(26) <= '0';
				background_check(28) <= '0';
				background_check(30) <= '0';
				background_check(32) <= '0';
				background_check(34) <= '0';
				background_check(36) <= '0';
				background_check(38) <= '0';
				background_check(40) <= '0';
				background_check(42) <= '0';
				background_check(44) <= '0';
				background_check(46) <= '0';
				background_check(48) <= '0';
				background_check(50) <= '0';
				background_check(52) <= '0';
				background_check(54) <= '0';
				background_check(56) <= '0';
				background_check(58) <= '0';
				background_check(60) <= '0';
				background_check(62) <= '0';
				background_check(64) <= '0';
				background_check(66) <= '0';
				background_check(68) <= '0';
				background_check(70) <= '0';
				background_check(72) <= '0';
				background_check(74) <= '0';
				background_check(76) <= '0';
				background_check(78) <= '0';
				background_check(80) <= '0';
				background_check(82) <= '0';
				background_check(84) <= '0';
				background_check(86) <= '0';
				background_check(88) <= '0';
				background_check(90) <= '0';
				background_check(92) <= '0';
				background_check(94) <= '0';
				background_check(96) <= '0';
				background_check(98) <= '0';
				background_check(100) <= '0';
				background_check(102) <= '0';
				background_check(104) <= '0';
				background_check(106) <= '0';
				background_check(108) <= '0';
				background_check(110) <= '0';
				background_check(112) <= '0';
				background_check(114) <= '0';
				background_check(116) <= '0';
				background_check(118) <= '0';
				background_check(120) <= '0';
				background_check(122) <= '0';
				background_check(124) <= '0';
				background_check(126) <= '0';
				background_check(128) <= '0';
				background_check(130) <= '0';
				background_check(132) <= '0';
				background_check(134) <= '0';
				background_check(136) <= '0';
				background_check(138) <= '0';
				background_check(140) <= '0';
				background_check(142) <= '0';
				background_check(144) <= '0';
				background_check(146) <= '0';
				background_check(148) <= '0';
				background_check(150) <= '0';
				background_check(152) <= '0';
				background_check(154) <= '0';
				background_check(156) <= '0';
				background_check(158) <= '0';
				background_check(160) <= '0';
				background_check(162) <= '0';
				background_check(164) <= '0';
				background_check(166) <= '0';
				background_check(168) <= '0';
				background_check(170) <= '0';
				background_check(172) <= '0';
				background_check(174) <= '0';
				background_check(176) <= '0';
				background_check(178) <= '0';
				background_check(180) <= '0';
				background_check(182) <= '0';
				background_check(184) <= '0';
				background_check(186) <= '0';
				background_check(188) <= '0';
				background_check(190) <= '0';
			end if;
			
			-- odd pixels
			if (mode = 13) then
				background_check(1) <= '0';
				background_check(3) <= '0';
				background_check(5) <= '0';
				background_check(7) <= '0';
				background_check(9) <= '0';
				background_check(11) <= '0';
				background_check(13) <= '0';
				background_check(15) <= '0';
				background_check(17) <= '0';
				background_check(19) <= '0';
				background_check(21) <= '0';
				background_check(23) <= '0';
				background_check(25) <= '0';
				background_check(27) <= '0';
				background_check(29) <= '0';
				background_check(31) <= '0';
				background_check(33) <= '0';
				background_check(35) <= '0';
				background_check(37) <= '0';
				background_check(39) <= '0';
				background_check(41) <= '0';
				background_check(43) <= '0';
				background_check(45) <= '0';
				background_check(47) <= '0';
				background_check(49) <= '0';
				background_check(51) <= '0';
				background_check(53) <= '0';
				background_check(55) <= '0';
				background_check(57) <= '0';
				background_check(59) <= '0';
				background_check(61) <= '0';
				background_check(63) <= '0';
				background_check(65) <= '0';
				background_check(67) <= '0';
				background_check(69) <= '0';
				background_check(71) <= '0';
				background_check(73) <= '0';
				background_check(75) <= '0';
				background_check(77) <= '0';
				background_check(79) <= '0';
				background_check(81) <= '0';
				background_check(83) <= '0';
				background_check(85) <= '0';
				background_check(87) <= '0';
				background_check(89) <= '0';
				background_check(91) <= '0';
				background_check(93) <= '0';
				background_check(95) <= '0';
				background_check(97) <= '0';
				background_check(99) <= '0';
				background_check(101) <= '0';
				background_check(103) <= '0';
				background_check(105) <= '0';
				background_check(107) <= '0';
				background_check(109) <= '0';
				background_check(111) <= '0';
				background_check(113) <= '0';
				background_check(115) <= '0';
				background_check(117) <= '0';
				background_check(119) <= '0';
				background_check(121) <= '0';
				background_check(123) <= '0';
				background_check(125) <= '0';
				background_check(127) <= '0';
				background_check(129) <= '0';
				background_check(131) <= '0';
				background_check(133) <= '0';
				background_check(135) <= '0';
				background_check(137) <= '0';
				background_check(139) <= '0';
				background_check(141) <= '0';
				background_check(143) <= '0';
				background_check(145) <= '0';
				background_check(147) <= '0';
				background_check(149) <= '0';
				background_check(151) <= '0';
				background_check(153) <= '0';
				background_check(155) <= '0';
				background_check(157) <= '0';
				background_check(159) <= '0';
				background_check(161) <= '0';
				background_check(163) <= '0';
				background_check(165) <= '0';
				background_check(167) <= '0';
				background_check(169) <= '0';
				background_check(171) <= '0';
				background_check(173) <= '0';
				background_check(175) <= '0';
				background_check(177) <= '0';
				background_check(179) <= '0';
				background_check(181) <= '0';
				background_check(183) <= '0';
				background_check(185) <= '0';
				background_check(187) <= '0';
				background_check(189) <= '0';
				background_check(191) <= '0';
			end if;
			
			if (mode = 4 or mode = 5) and (wstate = storing) then 
				background_check(ram_write_addr_int) <= '1';
			end if;
			
			if (io_write = '1') and (cs_invert = '1') then
				background_check <= not(background_check);
			end if;
			
			if (io_write = '1') and (cs_unset = '1') then
				background_check(data) <= '0';
			end if;
			
			if (io_write = '1') and (cs_shift = '1') then
				i <= to_integer(unsigned(data_in));
			end if;
			
			
		end if;
	end process;
	-- This process implements the NeoPixel protocol by
	-- using several counters to keep track of clock cycles,
	-- which pixel is being written to, and which bit within
	-- that data is being written.
	process (clk_10M, resetn)
		-- protocol timing values (in 100s of ns)
		constant t1h : integer := 8; -- high time for '1'
		constant t0h : integer := 3; -- high time for '0'
		constant ttot : integer := 12; -- total bit time
		
		constant npix : integer := 256;

		-- which bit in the 24 bits is being sent
		variable bit_count   : integer range 0 to 31;
		variable bit_count2  : integer range 0 to 31;
		-- counter to count through the bit encoding
		variable enc_count   : integer range 0 to 31;
		-- counter for the reset pulse
		variable reset_count : integer range 0 to 1000;
		-- Counter for the current pixel
		variable pixel_count : integer range 0 to 255;
		--counter for all pixels while loop
		
	begin
		
		if resetn = '0' then
			-- reset all counters
			bit_count := 23;
			enc_count := 0;
			reset_count := 1000;
			-- set sda inactive
			sda <= '0';

		elsif (rising_edge(clk_10M)) then

			-- This IF block controls the various counters
			if reset_count /= 0 then -- in reset/end-of-frame period
				-- during reset period, ensure other counters are reset
				pixel_count := 0;
				bit_count := 23;
				enc_count := 0;
				-- decrement the reset count
				reset_count := reset_count - 1;
				-- load data from memory
				if(background_check(ram_read_addr_int) = '1') then
					pixel_buffer <= ram_read_data;
				else
					pixel_buffer <= default_color;
				end if;
				
			else -- not in reset period (i.e. currently sending data)
				-- handle reaching end of a bit
				if enc_count = (ttot-1) then -- is end of this bit?
					enc_count := 0;
					-- shift to next bit
					pixel_buffer <= pixel_buffer(22 downto 0) & '0';
					if bit_count = 0 then -- is end of this pixels's data?
						bit_count := 23; -- start a new pixel
						if(background_check(ram_read_addr_int) = '1') then
							pixel_buffer <= ram_read_data;
						else
							pixel_buffer <= default_color;
						end if;
						if pixel_count = npix-1 then -- is end of all pixels?
							-- begin the reset period
							reset_count := 1000;
						else
							pixel_count := pixel_count + 1;
						end if;
					else
						-- if not end of this pixel's data, decrement count
						bit_count := bit_count - 1;
					end if;
				else
					-- within a bit, count to achieve correct pulse widths
					enc_count := enc_count + 1;
				end if;
			end if;
			
			
			-- This IF block controls the RAM read address to step through pixels
			if reset_count /= 0 then
				ram_read_addr <= x"00";
			elsif (bit_count = 1) AND (enc_count = 0) then
				ram_read_addr <= ram_read_addr + 1;
			end if;
			
			
			
			
			-- This IF block controls sda
			if reset_count > 0 then
				-- sda is 0 during reset/latch
				sda <= '0';
			elsif 
				-- sda is 1 in the first part of a bit.
				-- Length of first part depends on if bit is 1 or 0
				( (pixel_buffer(23) = '1') and (enc_count < t1h) )
				or
				( (pixel_buffer(23) = '0') and (enc_count < t0h) )
				then sda <= '1';
				
			else
				sda <= '0';
			end if;
			
		end if;
	end process;
	
	--background_check <= (ram_write_addr => '1',)
	process(clk_10M, resetn, cs_addr, cs_16bit, cs_24bit, cs_all, cs_inc, cs_advinc)
		--variable counter : integer range 0 to 8;
	begin
		-- For this implementation, saving the memory address
		-- doesn't require anything special.  Just latch it when
		-- SCOMP sends it.
		if resetn = '0' then
			ram_write_addr <= x"00";
		elsif rising_edge(clk_10M) then
			-- If SCOMP is writing to the address register...
			if (io_write = '1') and (cs_addr='1') then
				ram_write_addr <= data_in(7 downto 0);
			end if;
			
			if (io_write = '1') and (cs_16bit='1') then
				mode <= 1;
			elsif (io_write = '1') and (cs_24bit='1') then
				mode <= 2;
			elsif (io_write = '1') and (cs_all='1') then
				mode <= 3;
			elsif (io_write = '1') and (cs_inc='1') then
				mode <= 4;	
		   elsif (io_write = '1') and (cs_advinc='1') then
				mode <= 5;
			elsif (io_write = '1') and (cs_letter='1') then 
				mode <= 6;
			elsif (io_write = '1') and (cs_invert='1') then
				mode <= 7;
			elsif	(io_write = '1') and (cs_unset='1') then
				mode <= 8;
			elsif (io_write = '1') and (cs_number='1') then
				mode <= 9;
			elsif (io_write = '1') and (cs_even='1') then
				mode <= 12;
			elsif (io_write = '1') and (cs_odd ='1') then
				mode <= 13;
			end if;
			
			
			if (mode = 4) and (wstate = storing) then 
				-- each OUT to PXL_D will increment to next pixel
				ram_write_addr <= ram_write_addr + 1;
			end if;
			if (mode = 5) and (wstate = storing) then 
				-- each OUT to PXL_D will increment to next pixel
				ram_write_addr <= ram_write_addr + inc;
			end if;
			
		end if;
		
		-- The sequnce of events needed to store data into memory will be
		-- implemented with a state machine.
		-- Although there are ways to more simply connect SCOMP's I/O system
		-- to an altsyncram module, it would only work with under specific 
		-- circumstances, and would be limited to just simple writes.  Since
		-- you will probably want to do more complicated things, this is an
		-- example of something that could be extended to do more complicated
		-- things.
		-- Note that 'ram_we' is *not* implemented as a Moore output of this state
		-- machine, because Moore outputs are susceptible to glitches, and
		-- that's a bad thing for memory control signals.
		if resetn = '0' then
			wstate <= idle;
			ram_we <= '0';
			ram_write_buffer <= x"000000";
			-- Note that resetting this device does NOT clear the memory.
			-- Clearing memory would require cycling through each  ress
			-- and setting them all to 0.
		elsif rising_edge(clk_10M) then
			case wstate is
			when idle =>
				if (io_write = '1') and ((cs_16bit='1') or (cs_inc = '1')) then
					
					ram_write_buffer <=  "000" & data_in(10 downto 5) & "00" & data_in(15 downto 11) & "000" & data_in(4 downto 0);
					ram_we <= '1';
					wstate <= storing;
					
				elsif (io_write = '1') and (cs_24bit = '1') then -- 24 bit mode
					if (outputCheck = '0') then 
						BR <= data_in(15 downto 0);
						outputCheck <= '1';
					end if;
							
					if (outputCheck = '1') then
						ram_write_buffer <= data_in(7 downto 0) & BR;
						outputCheck <= '0';
						ram_we <= '1';
						wstate <= storing; -- Change state
					end if;
				
				elsif (io_write = '1') and ((cs_all = '1') or (cs_letter = '1') or (cs_data = '1') or (cs_even = '1') or (cs_odd = '1')) then 
					default_color <=  "000" & data_in(10 downto 5) & "00" &data_in(15 downto 11) & "000"  & data_in(4 downto 0);
					ram_we <= '1';
					wstate <= storing;
				
				elsif (io_write = '1') and (cs_advinc = '1') then 
					inc <=  to_integer(unsigned(data_in(7 downto 0)));
					ram_we <= '1';
					wstate <= storing;
					
				elsif (io_write = '1') and (cs_number = '1') then 
					numIn <=  data_in(3 downto 0);
					ram_we <= '1';
					wstate <= storing;
				end if;
				
				
			when storing =>
				-- All that's needed here is to lower ram_we.  The RAM will be
				-- storing data on this clock edge, so ram_we can go low at the
				-- same time.
				ram_we <= '0';
				wstate <= idle;
			
			when others =>
				wstate <= idle;
			end case;
		end if;
		
	end process;
	
	
end internals;