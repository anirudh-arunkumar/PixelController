-- IO DECODER for SCOMP
-- This eliminates the need for a lot of AND decoders or Comparators 
--    that would otherwise be spread around the top-level BDF

LIBRARY IEEE;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY IO_DECODER IS

  PORT
  (
    IO_ADDR       : IN STD_LOGIC_VECTOR(10 downto 0);
    IO_CYCLE      : IN STD_LOGIC;
    SWITCH_EN     : OUT STD_LOGIC;
    LED_EN        : OUT STD_LOGIC;
    TIMER_EN      : OUT STD_LOGIC;
    HEX0_EN       : OUT STD_LOGIC;
    HEX1_EN       : OUT STD_LOGIC;
    PXL_A_EN      : OUT STD_LOGIC;
    PXL_D_EN      : OUT STD_LOGIC;
	 MODE_16bit		: OUT STD_LOGIC;
	 MODE_24bit		: OUT STD_LOGIC;
	 MODE_ALL		: OUT STD_LOGIC;
	 MODE_INC		: OUT STD_LOGIC;
	 MODE_ADVINC	: OUT STD_LOGIC;
	 MODE_LETTER   : OUT STD_LOGIC;
	 MODE_INVERT   : OUT STD_LOGIC;
	 MODE_UNSET    : OUT STD_LOGIC;
	 MODE_SHIFT: OUT STD_LOGIC;
	 MODE_NUMBER: OUT STD_LOGIC;
	 MODE_EVEN: OUT STD_LOGIC;
	 MODE_ODD: OUT STD_LOGIC
  );

END ENTITY;

ARCHITECTURE a OF IO_DECODER IS

  SIGNAL  ADDR_INT  : INTEGER RANGE 0 TO 2047;
  
begin

  ADDR_INT <= TO_INTEGER(UNSIGNED(IO_ADDR));
        
  SWITCH_EN    <= '1' WHEN (ADDR_INT = 16#000#) and (IO_CYCLE = '1') ELSE '0';
  LED_EN       <= '1' WHEN (ADDR_INT = 16#001#) and (IO_CYCLE = '1') ELSE '0';
  TIMER_EN     <= '1' WHEN (ADDR_INT = 16#002#) and (IO_CYCLE = '1') ELSE '0';
  HEX0_EN      <= '1' WHEN (ADDR_INT = 16#004#) and (IO_CYCLE = '1') ELSE '0';
  HEX1_EN      <= '1' WHEN (ADDR_INT = 16#005#) and (IO_CYCLE = '1') ELSE '0';
  PXL_A_EN     <= '1' WHEN (ADDR_INT = 16#0B0#) and (IO_CYCLE = '1') ELSE '0';
  PXL_D_EN     <= '1' WHEN (ADDR_INT = 16#0B1#) and (IO_CYCLE = '1') ELSE '0';
  MODE_16bit	<= '1' WHEN (ADDR_INT = 16#0B2#) and (IO_CYCLE = '1') ELSE '0';
  MODE_24bit	<= '1' WHEN (ADDR_INT = 16#0B3#) and (IO_CYCLE = '1') ELSE '0';
  MODE_ALL     <= '1' WHEN (ADDR_INT = 16#0B4#) and (IO_CYCLE = '1') ELSE '0';
  MODE_INC		<= '1' WHEN (ADDR_INT = 16#0B5#) and (IO_CYCLE = '1') ELSE '0';
  MODE_ADVINC	<= '1' WHEN (ADDR_INT = 16#0B6#) and (IO_CYCLE = '1') ELSE '0';
  MODE_LETTER  <= '1' WHEN (ADDR_INT = 16#0B7#) and (IO_CYCLE = '1') ELSE '0';
  MODE_INVERT  <= '1' WHEN (ADDR_INT = 16#0B8#) and (IO_CYCLE = '1') ELSE '0';
  MODE_UNSET   <= '1' WHEN (ADDR_INT = 16#0B9#) and (IO_CYCLE = '1') ELSE '0';
  MODE_SHIFT   <= '1' WHEN (ADDR_INT = 16#0BA#) and (IO_CYCLE = '1') ELSE '0';
  MODE_NUMBER   <= '1' WHEN (ADDR_INT = 16#0BB#) and (IO_CYCLE = '1') ELSE '0';
  MODE_EVEN   <= '1' WHEN (ADDR_INT = 16#0BC#) and (IO_CYCLE = '1') ELSE '0';
  MODE_ODD   <= '1' WHEN (ADDR_INT = 16#0BD#) and (IO_CYCLE = '1') ELSE '0';
      
END a;