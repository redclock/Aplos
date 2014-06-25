TAplosSyn   {first Identifier is considered to be the Class Name }
tk              {second Identifier is considered to be the Identifier Prefix }
IdentStart '_', 'a'..'z', 'A'..'Z':: '_', '0'..'9', 'a'..'z', 'A'..'Z'::

TOKENTYPES
Identifier
Comment Style=[fsItalic]|Foreground=clNavy
Space
String Foreground=clRed
Labels Foreground=clGreen

Key Style=[]|Foreground=clBlue
Ins Foreground= $00FF6FB7
|><|

KEYS
private
public
push
pop
if
else
endif
for
to
downto
next
while
wend
repeat
until
break
continue
open
goto
exit
call
thread
lock
unlock
return
include
const
inc 
dec
function
end
true
false
declare
suspend
|><|
CHARS

'A'..'Z', 'a'..'z', '_':: Ident
BeginProc
  fTokenID := IdentKind((fLine + Run));
  inc(Run, fStringLen);
  while Identifiers[fLine[Run]] do
    Inc(Run);
EndProc

|><|

ENCLOSEDBY

Comment,Comment1,//,#13
Comment,Comment2,',#13
String,String,","
Labels,Labels,@,#13
Ins,Ins,#,#13
|><|

SAMPLESOURCE
'test 

|><|

