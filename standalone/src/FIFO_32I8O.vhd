LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
 
entity FIFO_32I8O is
  generic (
    constant DATAINP_WIDTH : positive := 32;
    constant DATAOUT_WIDTH : positive := 8;
    constant FIFO_DEPTH : positive := 64
  );
  port ( 
    CLK       : in  STD_LOGIC;
    RST       : in  STD_LOGIC;
    WriteEn   : in  STD_LOGIC;
    DataIn    : in  STD_LOGIC_VECTOR (DATAINP_WIDTH - 1 downto 0);
    ReadEn    : in  STD_LOGIC;
    DataOut   : out STD_LOGIC_VECTOR (DATAOUT_WIDTH - 1 downto 0);
    Empty     : out STD_LOGIC;
    Full      : out STD_LOGIC
  );
end FIFO_32I8O;
 
architecture behavioral of FIFO_32I8O is
begin
  -- Memory Pointer Process
  fifo_proc : process (CLK)
    type FIFO_Memory is array (0 to FIFO_DEPTH - 1) of STD_LOGIC_VECTOR (DATAINP_WIDTH - 1 downto 0);
    variable Memory : FIFO_Memory;
    variable Head : natural range 0 to FIFO_DEPTH - 1;
    variable Tail : natural range 0 to FIFO_DEPTH - 1;
    variable Looped : boolean;
    variable readpos : natural range 0 to (DATAINP_WIDTH / DATAOUT_WIDTH)-1 := 0;
  begin
    if rising_edge(CLK) then
      if RST = '1' then
        Head := 0;
        Tail := 0;			
        Looped := false;
        Full  <= '0';
        Empty <= '1';
      else
        if (ReadEn = '1') then
          if ((Looped = true) or (Head /= Tail)) then
            -- Update data output
            DataOut <= Memory(Tail)(((readpos+1)*DATAOUT_WIDTH-1) downto (readpos*DATAOUT_WIDTH));

            if (readpos = ((DATAINP_WIDTH / DATAOUT_WIDTH)-1)) then
              -- Update Tail pointer as needed
              if (Tail = FIFO_DEPTH - 1) then
                Tail := 0;

                Looped := false;
              else
                Tail := Tail + 1;
              end if;

              readpos := 0;
            else
              readpos := readpos + 1;
            end if;
          end if;
        end if;
				
        if (WriteEn = '1') then
          if ((Looped = false) or (Head /= Tail)) then
            -- Write Data to Memory
            Memory(Head) := DataIn;

            -- Increment Head pointer as needed
            if (Head = FIFO_DEPTH - 1) then
              Head := 0;

              Looped := true;
            else
              Head := Head + 1;
            end if;
          end if;
        end if;

        -- Update Empty and Full flags
        if (Head = Tail) then
          if Looped then
            Full <= '1';
          else
            Empty <= '1';
          end if;
        else
          Empty <= '0';
          Full  <= '0';
        end if;
      end if;
    end if;
  end process;
end behavioral;
