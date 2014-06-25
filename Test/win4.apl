include winctrl

function Click1(sender)
  MsgBox("Not finished.", "Sorry", 0)
end

function Click2(sender)
  exit
end
if _VMType = 1
  Writeln("请在窗口模式运行")
  exit
endif
Main.SetText("Editor")
ptop = Main.AddPanel("",0,0,50,25)
ptop.SetAlign(AL_TOP)
ed = Main.AddEdit("", 0,50,100,100)
ed.SetAlign(AL_CLIENT)
bt = ptop.AddButton("&Open", 0,0, 50, 25)
bt.SetAlign(AL_LEFT)
bt.SetEvent(EVT_CLICK, Click1)
bt = ptop.AddButton("&Save", 0,0, 50, 25)
bt.SetAlign(AL_LEFT)
bt.SetEvent(EVT_CLICK, Click1)
bt = ptop.AddButton("E&xit", 0,0, 50, 25)
bt.SetAlign(AL_LEFT)
bt.SetEvent(EVT_CLICK, Click2)

suspend
