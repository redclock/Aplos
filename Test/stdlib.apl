//
// Copyright Redclock 2005
//
#explicit off

'
' 常数
'
const  VT_INT   = 0     //变量类型
const  VT_FLOAT = 1
const  VT_BOOL  = 2
const  VT_STR   = 3
const  VT_ARRAY = 4

const  PI       = 3.1415926535897932385

'
' 实用函数
'

//绝对值
function Abs(a)
  if a<0: return -a
end a

//符号
function Sgn(a)
  if a<0
    return -1
  else if a>0
    return 1
  endif
end 0

//最大值
function open Max()
  pop n
  if n <= 0: return 0
  pop a
  for i = 2 to n
    pop b
    if a < b: a = b
  next
end a

//最小值
function open Min()
  pop n
  if n <= 0: return 0
  pop a
  for i = 2 to n
    pop b
    if a > b: a = b
  next
end a

//正切
function Tan(x)
end Sin(x) / Cos(x)

//反正切
function Cot(x)
end Cos(x) / Sin(x)

//乘方
function Pow(x, y)
end Exp(y*Ln(x))

//建立二维数组
function CreateArray2D(m,n)
  private i, a
  a = NewArray(m)
  for i = 0 to m - 1
    a[i] = NewArray(n)
  next
end a

//由值建立数组
function open MakeArray()
  pop n
  a = NewArray(n)
  for i = n - 1 downto 0: pop a[i]
end a

//复制数组
function CopyArray(afrom)
  a = NewArray(Len(afrom))
  for i = 0 to Len(afrom) - 1: a[i] = afrom[i]
end a

//等待指定时间
function Wait(delay)
  t=_Timer
  while _Timer-t<delay
  wend
end


//快速排序
function QSort(arr, s, e)
    private i, j, x
    if s >= e :return
    x = arr[s]
    i = s
    j = e
    while i < j
      while (i < j) & (arr[j] >= x) : dec j
      arr[i] = arr[j]
      while (i < j) & (arr[i] <= x) : inc i
      arr[j] = arr[i]
    wend
    arr[i] = x
    QSort(arr, s, i-1)
    QSort(arr, i+1, e)
end

//求最大公约数
function Gcd(a, b)
  if a > b
    push a   //交换变量
    push b
    pop a
    pop b
  endif
  if (b % a) <> 0 : a = Gcd(b % a, a)
end a
