object SetupForm: TSetupForm
  Left = 218
  Top = 125
  BorderStyle = bsDialog
  Caption = #36873#39033#35774#32622
  ClientHeight = 175
  ClientWidth = 350
  Color = clBtnFace
  Font.Charset = GB2312_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #23435#20307
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  object Label1: TLabel
    Left = 8
    Top = 16
    Width = 60
    Height = 12
    Caption = #32534#35793#22120#20301#32622
  end
  object Label2: TLabel
    Left = 8
    Top = 48
    Width = 60
    Height = 12
    Caption = #36816#34892#22120#20301#32622
  end
  object Label3: TLabel
    Left = 8
    Top = 80
    Width = 54
    Height = 12
    Caption = 'Win'#36816#34892#22120
  end
  object Edit1: TEdit
    Left = 80
    Top = 8
    Width = 225
    Height = 20
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    Text = 'SPT.EXE'
  end
  object Edit2: TEdit
    Left = 80
    Top = 40
    Width = 225
    Height = 20
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    Text = 'RUNSPT.EXE'
  end
  object CheckBox1: TCheckBox
    Left = 16
    Top = 136
    Width = 113
    Height = 25
    Caption = #36816#34892#32467#26463#21518#26242#20572
    Checked = True
    State = cbChecked
    TabOrder = 8
  end
  object BitBtn1: TBitBtn
    Left = 144
    Top = 136
    Width = 75
    Height = 25
    Caption = #30830#23450
    TabOrder = 9
    OnClick = BitBtn1Click
    Kind = bkOK
  end
  object BitBtn2: TBitBtn
    Left = 248
    Top = 136
    Width = 75
    Height = 25
    Caption = #21462#28040
    TabOrder = 10
    Kind = bkCancel
  end
  object btnAPL: TButton
    Left = 312
    Top = 8
    Width = 25
    Height = 17
    Caption = '...'
    TabOrder = 1
    OnClick = btnAPLClick
  end
  object btnRun: TButton
    Left = 312
    Top = 40
    Width = 25
    Height = 17
    Caption = '...'
    TabOrder = 3
    OnClick = btnRunClick
  end
  object Button3: TButton
    Left = 136
    Top = 104
    Width = 89
    Height = 25
    Caption = #20851#32852'.apl'#25991#20214
    TabOrder = 6
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 240
    Top = 104
    Width = 89
    Height = 25
    Caption = #20851#32852'.spt'#25991#20214
    TabOrder = 7
    OnClick = Button4Click
  end
  object Edit3: TEdit
    Left = 80
    Top = 72
    Width = 225
    Height = 20
    TabOrder = 4
    Text = 'WINAPL.EXE'
  end
  object btnWin: TButton
    Left = 312
    Top = 72
    Width = 25
    Height = 17
    Caption = '...'
    TabOrder = 5
    OnClick = btnWinClick
  end
  object OpenDialog1: TOpenDialog
    Filter = #24212#29992#31243#24207'|*.EXE|'#25209#22788#29702'|*.BAT'
    Left = 264
    Top = 8
  end
end
