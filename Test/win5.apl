include winctrl
const KEY_LEFT = 37
const KEY_UP = 38
const KEY_RIGHT = 39
const KEY_DOWN = 40

lock
X = 10
Y = 10
if _VMType = 1
  Writeln("请在窗口模式运行")
  exit
endif
function Paint(sender)
  sender.DrawBox(X,Y,X+150,Y+70,false)
  sender.TextOut(X+10,Y,"Draw text")
end

function Paint_c(sender)
  sender.DrawBox(X,Y,X+150,Y+70,true)
end

function OnKeyDown(sender, key, shift)
  const dx = 5
  const dy = 5
  sender.Paint_c()
  if key = KEY_LEFT
    X = X - dx
  else if key = KEY_RIGHT
    X = X + dx
  else if key = KEY_UP
    Y = Y - dy
  else if key = KEY_DOWN
    Y = Y + dy
  endif
  sender.Paint()
end

Main.SetEvent(EVT_PAINT, Paint)
Main.SetEvent(EVT_KEYDOWN, OnKeyDown)
suspend
