///////////////////////////////////////////////////////////
// 由C语言程序翻译而来
//
//  #include <stdlib.h>
//  #include <stdio.h>
//  long a=10000,b,c=2800,d,e,f[2801],g;
//  main()
//  {
//    for(;b-c;) f[b++]=a/5;
//    for(;d=0,g=c*2;c-=14,printf("%.4d",e+d/a),e=d%a)
//      for(b=c;d+=f[b]*a,f[b]=d%--g,d/=g--,--b;d*=b);
//  }
///////////////////////////////////////////////////////////
lock               //提高速度
declare out(s)


const a = 10000
e = 0
c = 2800
f = NewArray(2801)

result = ""


for b = 0 to c - 1: f[b] = a / 5
while(c > 0)
   d = 0
   g = c*2
   b = c
   while(true)
    d = d + f[b] * a
    dec g
    f[b] = d % g
    d = $int( d/g )
    dec g
    dec b
    if(b = 0): break
    d = d * b
   wend
   out(e + $int(d/a))
   if (c-14) % 140 = 0 : result = result + Chr(13) +Chr(10)
   c = c - 14
   e = d % a
wend
SetSize(0, 330, 330)
SetText(0,"计算PI")
AddStatic(0, "pi = ", 10, 10)
AddEdit(0, result, 10,30, 300, 200)
AddButton(0, "OK", 140,250, 80, 25)

suspend
//MsgBox(result, "Pi = ", 0)
//补足四位输出
function out(s)
  if s < 10
    result = result + "000" +$str(s)
  else if s < 100
    result = result + "00" +$str(s)
  else if s < 1000
    result = result + "0" +$str(s)
  else
    result = result + $str(s)
  endif
end

