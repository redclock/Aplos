include winctrl
declare MouseMove(sender, shift, x, y)
declare MouseDown(sender, button, shift, x, y)
declare MouseUp(sender, button, shift, x, y)
function setMouseEvent(c)
  c.SetEvent(EVT_MOUSEMOVE, MouseMove)
  c.SetEvent(EVT_MOUSEDOWN, MouseDown)
  c.SetEvent(EVT_MOUSEUP, MouseUp)
end
if _VMType = 1
  Writeln("请在窗口模式运行")
  exit
endif
Main.setMouseEvent()
l1 = Main.AddStatic("",10,10,500,40)
l2 = Main.AddStatic("",10,50,500,20)
l3 = Main.AddStatic("",10,90,500,20)

suspend


function MouseMove(sender, shift, x, y)
  l1.SetText("Mouse Move: shift=" + $str(shift) +" x=" +$str(x) + " y="+$str(y))
end

function MouseDown(sender, button, shift, x, y)
  l2.SetText("Mouse Down: shift=" + $str(shift) + " bt=" + $str(button) + " x=" +$str(x) + " y="+$str(y))
end

function MouseUp(sender, button, shift, x, y)
  l3.SetText("Mouse Up: shift=" + $str(shift) +"  bt=" + $str(button)+ " x=" +$str(x) + " y="+$str(y))
end

