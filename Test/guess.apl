//²ÂÊýÓÎÏ·
Writeln("GUESS WHAT THE NUMBER IS!")
Write("INPUT RANGE:")
RNG = ReadInt()
NUM = Random(RNG)
TIME = 0
REPEAT
  INC TIME
  Writeln("TIME ",TIME)
  Write("GUESS(0-",RNG-1,") : ")
  INP = ReadInt()
  RIGHT = (INP = NUM)
  IF INP>NUM
    Writeln("LARGER.")
  ELSE IF INP<NUM
    Writeln("SMALLER.")
  ENDIF
UNTIL RIGHT=TRUE
Writeln("RIGHT!")
