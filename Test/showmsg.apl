include msgbox
Text = "����ʱ���ִ���"+Chr(13)+"�Ƿ������"
if MsgBox(Text,"����",MB_YESNO|MB_ICONINFORMATION|MB_DEFBUTTON2) = IDYES
   suspend
endif
