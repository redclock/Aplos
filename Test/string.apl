declare StrUpper(a)
declare StrLower(a)
declare StrSplit(s, sep, AllowNull)

repeat
  Write("Input String:")
  s = ReadString()
  Writeln("Uppercase: ", s.StrUpper())
  Writeln("Loercase:  ", s.StrLower())
  Write("Input Seperator:")
  sep = ReadString()
  Writeln(s.StrSplit(sep, false))
  Writeln(s.StrSplit(sep, true))

until false

function StrUpper(a)
  b = ""
  for i = 1 to a.Len()
    c = Asc(a[i])
    if c >= 97 & c <= 122
      b = b + Chr(c - 32)
    else
      b = b + Chr(c)
    endif
  next
end b

function StrLower(a)
  b = ""
  for i = 1 to a.Len()
    c = Asc(a[i])
    if c >= 65 & c <= 90
      b = b + Chr(c + 32)
    else
      b = b + Chr(c)
    endif
  next
end b

function StrSplit(s, sep, AllowNull)
  if s = "" | sep = "" : return 0
  n = 0
  i = 1
  slen = s.Len()
  seplen = sep.Len()
  rt = NewArray(slen)
  repeat
    j = StrPos(s, sep, i)
    if j = 0 : j = slen + 1
    if (j > i) | (AllowNull)
       rt[n] = s.StrSub(i, j - i)
       inc n
    endif
    i = j + seplen
  until i > slen
  rt.Resize(n)
end rt



