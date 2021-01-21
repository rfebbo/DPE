-- Single Debounced Pulse from a Pushbutton 
LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;
USE ieee.STD_LOGIC_UNSIGNED.all;

ENTITY SingPul IS
PORT (
  Clk1: IN STD_LOGIC; ---a low frequency Clock from CDiv
  Key: IN STD_LOGIC;  -- active low input
  pulse: OUT STD_LOGIC);
END SingPul;

ARCHITECTURE onepulse OF SIngPul IS
  SIGNAL cnt: STD_LOGIC_VECTOR (1 DOWNTO 0);
BEGIN
  PROCESS (Clk1,Key)
  BEGIN 
   
   IF (Key = '1') THEN
      cnt <= "00";
    ELSIF (clk1'EVENT AND Clk1= '1') THEN
      IF (cnt /= "11") THEN cnt <= cnt + 1; END IF;
    END IF;
   
   IF (cnt = "10") AND (Key = '0') THEN
      pulse <= '1';
   ELSE pulse <= '0'; 
   END IF;

  END PROCESS;
END onepulse;

