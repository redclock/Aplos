include winctrl
declare NumClick(sender)
declare OpClick(sender)
declare ClearClick(sender)
const ES_RIGHT = 0x0002
if _VMType = 1
  Writeln("���ڴ���ģʽ����")
  exit
endif
//������ֵ
NumChar = "1234567890"
OpChar  = "+-*/="
NumStr = ""
lastop = "="
Result = 0.0
//�������ԣ����ܸı��С
Main.SetStyle(WS_CAPTION|WS_BORDER|WS_POPUP|WS_SYSMENU,false)
Main.SetText("������")
Main.SetSize(140, 170)
//�������ֿ򣺲��ɱ༭���Ҷ���
NumBox = Main.AddEdit("0", 10, 10, 115, 20)
NumBox.SetStyle(ES_RIGHT, false)
NumBox.SetEnabled(false)
//������ְ�ť
for i = 0 to 9
  bt = Main.AddButton(NumChar[i+1], 10+i%4*30, 40+$int(i/4)*25,  25, 20)
  bt.SetEvent(EVT_CLICK, NumClick)
next
//������㰴ť
for i = 10 to 14
  bt = Main.AddButton(OpChar[i-9], 10+i%4*30, 40+$int(i/4)*25,  25, 20)
  bt.SetEvent(EVT_CLICK, OpClick)
next
//���C��ť
bt = Main.AddButton("C", 10+15%4*30, 40+$int(15/4)*25,  25, 20)
bt.SetEvent(EVT_CLICK, ClearClick)
//�ȴ��¼�
suspend

//���ְ�ť�¼�
function NumClick(sender)
  NumStr = NumStr+sender.GetText()
  NumBox.SetText(NumStr)
end
//���㰴ť�¼�
function OpClick(sender)
  a = $float(NumBox.GetText())
  if lastop = "+"
    Result = Result + a
  else if lastop = "-"
    Result = Result - a
  else if lastop = "*"
    Result = Result * a
  else if lastop = "/"
    Result = Result / a
  else if lastop = "="
    Result =  a
  endif
  lastop = sender.GetText()
  NumStr = ""
  NumBox.SetText(Result)
end
//C��ť�¼�
function ClearClick(sender)
  NumStr =""
  Result = 0
  NumBox.SetText("0")
end

