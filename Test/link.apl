//用数组模拟链表

const VAL = 0
const NXT = 1

//创建一个节点
function CreateNode(Value)
  a=NewArray(2)
  a[VAL]=Value               //第一个是数据
  a[NXT]=0                   //第二个是下一项的指针
end a

//在链表头部添加
function AddHead(Head, Node)
  Node[NXT]=Head
  Head=Node
end Head                      //返回值为新头指针

//在链表尾部添加
function AddTail(Head, Node)
  while Head[NXT] <> 0 : Head=Head[NXT]   //查找尾部
  Head[NXT]=Node                   //添加
end

function Find(Head, Value)
  while Head <> 0
    if Head[VAL] = Value : return Head
    Head = Head[NXT]
  wend
end 0
//输出
function Out(Head)
  Writeln()
  Write("List = (")
  while Head <> 0
    Write(Head[VAL])
    Head=Head[NXT]
    if Head <> 0 :Write(",")
  wend
  Writeln(")")
end

function Menu()
  Writeln()
  Writeln("   1.在链表头部添加")
  Writeln("   2.在链表尾部添加")
  Writeln("   3.打印链表")
  Writeln("   4.清空链表")
  Writeln("   5.退出")
  Writeln()
  repeat
    Write("   输入选项(1-4):")
    n = ReadInt()
  until n>0 & n < 5
end n


//主程序
Head = 0

while(true)
  n = Menu()
  if n = 1             //1.在链表头部添加
    Write("输入数据:")
    data = ReadString()
    if Head = 0  //如果头为空
       Head = CreateNode(data)
    else
       Head = AddHead(Head, CreateNode(data))
    endif
  else if n = 2        //2.在链表尾部添加
    Write("输入数据:")
    data = ReadString()
    if Head = 0  //如果头为空
       Head = CreateNode(data)
    else
       AddTail(Head, CreateNode(data))
    endif
  else if n = 3        //3.打印链表
    Out(Head)
  else if n = 4        //4.清空链表
    Head = 0  //只需把头指针清空，所有内存自动释放。
  else
    break     //退出
  endif
wend

