//
// Copyright Redclock 2005
//
#explicit off

'
' ����
'
const  VT_INT   = 0     //��������
const  VT_FLOAT = 1
const  VT_BOOL  = 2
const  VT_STR   = 3
const  VT_ARRAY = 4

const  PI       = 3.1415926535897932385

'
' ʵ�ú���
'

//����ֵ
function Abs(a)
  if a<0: return -a
end a

//����
function Sgn(a)
  if a<0
    return -1
  else if a>0
    return 1
  endif
end 0

//���ֵ
function open Max()
  pop n
  if n <= 0: return 0
  pop a
  for i = 2 to n
    pop b
    if a < b: a = b
  next
end a

//��Сֵ
function open Min()
  pop n
  if n <= 0: return 0
  pop a
  for i = 2 to n
    pop b
    if a > b: a = b
  next
end a

//����
function Tan(x)
end Sin(x) / Cos(x)

//������
function Cot(x)
end Cos(x) / Sin(x)

//�˷�
function Pow(x, y)
end Exp(y*Ln(x))

//������ά����
function CreateArray2D(m,n)
  private i, a
  a = NewArray(m)
  for i = 0 to m - 1
    a[i] = NewArray(n)
  next
end a

//��ֵ��������
function open MakeArray()
  pop n
  a = NewArray(n)
  for i = n - 1 downto 0: pop a[i]
end a

//��������
function CopyArray(afrom)
  a = NewArray(Len(afrom))
  for i = 0 to Len(afrom) - 1: a[i] = afrom[i]
end a

//�ȴ�ָ��ʱ��
function Wait(delay)
  t=_Timer
  while _Timer-t<delay
  wend
end


//��������
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

//�����Լ��
function Gcd(a, b)
  if a > b
    push a   //��������
    push b
    pop a
    pop b
  endif
  if (b % a) <> 0 : a = Gcd(b % a, a)
end a
