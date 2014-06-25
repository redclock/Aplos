include winctrl
declare NumClick(sender)
declare OpClick(sender)
declare ClearClick(sender)
const ES_RIGHT = 0x0002
if _VMType = 1
  Writeln("请在窗口模式运行")
  exit
endif
//变量初值
NumChar = "1234567890"
OpChar  = "+-*/="
NumStr = ""
lastop = "="
Result = 0.0
//窗体属性：不能改变大小
Main.SetStyle(WS_CAPTION|WS_BORDER|WS_POPUP|WS_SYSMENU,false)
Main.SetText("计算器")
Main.SetSize(140, 170)
//加入数字框：不可编辑，右对齐
NumBox = Main.AddEdit("0", 10, 10, 115, 20)
NumBox.SetStyle(ES_RIGHT, false)
NumBox.SetEnabled(false)
//添加数字按钮
for i = 0 to 9
  bt = Main.AddButton(NumChar[i+1], 10+i%4*30, 40+$int(i/4)*25,  25, 20)
  bt.SetEvent(EVT_CLICK, NumClick)
next
//添加运算按钮
for i = 10 to 14
  bt = Main.AddButton(OpChar[i-9], 10+i%4*30, 40+$int(i/4)*25,  25, 20)
  bt.SetEvent(EVT_CLICK, OpClick)
next
//添加C按钮
bt = Main.AddButton("C", 10+15%4*30, 40+$int(15/4)*25,  25, 20)
bt.SetEvent(EVT_CLICK, ClearClick)
//等待事件
suspend

//数字按钮事件
function NumClick(sender)
  NumStr = NumStr+sender.GetText()
  NumBox.SetText(NumStr)
end
//运算按钮事件
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
//C按钮事件
function ClearClick(sender)
  NumStr =""
  Result = 0
  NumBox.SetText("0")
end

