include winctrl
include msgbox
declare  ButtonClick(sender)

if _VMType = 1
  Writeln("���ڴ���ģʽ����")
  exit
endif

Main.SetText("World Hello")
Main.AddStatic("������", 10, 10, 100,20)
ed = Main.AddEdit("", 60, 8,  80, 20)
bt=Main.AddButton("ȷ��",150, 7, 50,22)
bt.SetEvent(EVT_CLICK, ButtonClick)
Main.SetSize(240, 70)

Suspend

function ButtonClick(sender)
  S = ed.GetText()
  if S = ""
    MsgBox("������������","����",MB_ICONSTOP)
  else
    MsgBox("��ӭ�㣺" + S,"Hello",MB_ICONINFORMATION)
    bt.SetEnabled(false)
  endif
end

