//������ģ������

const VAL = 0
const NXT = 1

//����һ���ڵ�
function CreateNode(Value)
  a=NewArray(2)
  a[VAL]=Value               //��һ��������
  a[NXT]=0                   //�ڶ�������һ���ָ��
end a

//������ͷ�����
function AddHead(Head, Node)
  Node[NXT]=Head
  Head=Node
end Head                      //����ֵΪ��ͷָ��

//������β�����
function AddTail(Head, Node)
  while Head[NXT] <> 0 : Head=Head[NXT]   //����β��
  Head[NXT]=Node                   //���
end

function Find(Head, Value)
  while Head <> 0
    if Head[VAL] = Value : return Head
    Head = Head[NXT]
  wend
end 0
//���
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
  Writeln("   1.������ͷ�����")
  Writeln("   2.������β�����")
  Writeln("   3.��ӡ����")
  Writeln("   4.�������")
  Writeln("   5.�˳�")
  Writeln()
  repeat
    Write("   ����ѡ��(1-4):")
    n = ReadInt()
  until n>0 & n < 5
end n


//������
Head = 0

while(true)
  n = Menu()
  if n = 1             //1.������ͷ�����
    Write("��������:")
    data = ReadString()
    if Head = 0  //���ͷΪ��
       Head = CreateNode(data)
    else
       Head = AddHead(Head, CreateNode(data))
    endif
  else if n = 2        //2.������β�����
    Write("��������:")
    data = ReadString()
    if Head = 0  //���ͷΪ��
       Head = CreateNode(data)
    else
       AddTail(Head, CreateNode(data))
    endif
  else if n = 3        //3.��ӡ����
    Out(Head)
  else if n = 4        //4.�������
    Head = 0  //ֻ���ͷָ����գ������ڴ��Զ��ͷš�
  else
    break     //�˳�
  endif
wend

