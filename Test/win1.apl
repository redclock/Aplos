include winctrl
include msgbox
declare  ButtonClick(sender)

if _VMType = 1
  Writeln("请在窗口模式运行")
  exit
endif

Main.SetText("World Hello")
Main.AddStatic("姓名：", 10, 10, 100,20)
ed = Main.AddEdit("", 60, 8,  80, 20)
bt=Main.AddButton("确定",150, 7, 50,22)
bt.SetEvent(EVT_CLICK, ButtonClick)
Main.SetSize(240, 70)

Suspend

function ButtonClick(sender)
  S = ed.GetText()
  if S = ""
    MsgBox("请先输入姓名","错误",MB_ICONSTOP)
  else
    MsgBox("欢迎你：" + S,"Hello",MB_ICONINFORMATION)
    bt.SetEnabled(false)
  endif
end

