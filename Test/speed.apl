function TestSpeed()
  t=_Timer
  for i=1 to 1000000
    inc i
    dec i
  next
  Writeln("time used : ",_Timer-t," ms.")
end
unlock
Writeln("------- speed test -------")
Writeln("not locked")
TestSpeed()
Writeln("locked")
lock
TestSpeed()
unlock
Writeln("---------- end -----------")
ReadKey(true)
