include winctrl

function BtClick(sender)
  MsgBox("Clicked Button "+sender.GetText()+"!", "Message", 0)
end

function OnPaint(sender)
  //sender.SetFont("ËÎÌו", 12)
  //sender.TextOut(10, 10, "Draw Text")
end

Main.SetText("App")
//Mian.SetEvent(EVT_PAINT, OnPaint)
bt = Main.AddButton("Hello", 10, 10, 100, 100)
bt.SetEvent(EVT_CLICK, BtClick)
suspend
