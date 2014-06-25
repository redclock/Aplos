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
   c = c - 14
   e = d % a
wend

Writeln()
//补足四位输出
function out(s)
  if s < 10
    Write("000",s)
  else if s < 100
    Write("00",s)
  else if s < 1000
    Write("0",s)
  else
    Write(s)
  endif
end

