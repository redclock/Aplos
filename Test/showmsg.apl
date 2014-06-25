include msgbox
Text = "运行时出现错误。"+Chr(13)+"是否继续？"
if MsgBox(Text,"警告",MB_YESNO|MB_ICONINFORMATION|MB_DEFBUTTON2) = IDYES
   suspend
endif
