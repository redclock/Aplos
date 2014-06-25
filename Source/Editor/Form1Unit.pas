unit Form1Unit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Menus, SynEdit, ComCtrls,
  fmSetup,fmAbout,unitShowHelp,ShellAPI, SynMemo, APLOS, IniFiles, ImgList,
  StdActns, ActnList, ToolWin, unitSearch;

const
  Max_File = 100;
type
  TMainForm = class(TForm)
    MainMenu: TMainMenu;
    F1: TMenuItem;
    N1: TMenuItem;
    O1: TMenuItem;
    S1: TMenuItem;
    A1: TMenuItem;
    N2: TMenuItem;
    X1: TMenuItem;
    MemoDebug: TMemo;
    Splitter1: TSplitter;
    StatusBar1: TStatusBar;
    Open1: TOpenDialog;
    Save1: TSaveDialog;
    P1: TMenuItem;
    C1: TMenuItem;
    mRun: TMenuItem;
    T1: TMenuItem;
    O2: TMenuItem;
    H1: TMenuItem;
    C2: TMenuItem;
    N3: TMenuItem;
    A2: TMenuItem;
    PopupMenu1: TPopupMenu;
    C3: TMenuItem;
    C4: TMenuItem;
    mmEdit: TMenuItem;
    F2: TMenuItem;
    N4: TMenuItem;
    R2: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    mRecent: TMenuItem;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    SynEdit: TSynEdit;
    ImageList1: TImageList;
    mRunWin: TMenuItem;
    mCopy: TMenuItem;
    mCut: TMenuItem;
    mPaste: TMenuItem;
    EditActions: TActionList;
    actCopy: TEditCopy;
    actCut: TEditCut;
    actPaste: TEditPaste;
    actSelectAll: TEditSelectAll;
    actUndo: TEditUndo;
    PopupMenu2: TPopupMenu;
    C5: TMenuItem;
    T2: TMenuItem;
    P2: TMenuItem;
    A3: TMenuItem;
    U1: TMenuItem;
    A4: TMenuItem;
    U2: TMenuItem;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    actNew: TAction;
    actOpen: TAction;
    actSave: TAction;
    actSaveAs: TAction;
    actCompile: TAction;
    actRun: TAction;
    actWinRun: TAction;
    actSetup: TAction;
    actExit: TAction;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    ToolButton12: TToolButton;
    ToolButton13: TToolButton;
    ToolButton14: TToolButton;
    actHelp: TAction;
    ToolButton15: TToolButton;
    ToolButton16: TToolButton;
    ToolButton17: TToolButton;
    actFindPrev: TAction;
    V1: TMenuItem;
    actSearch: TAction;
    actFindNext: TAction;
    actReplace: TAction;
    F3: TMenuItem;
    ToolButton18: TToolButton;
    ToolButton19: TToolButton;
    ToolButton20: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure RunDosInMemo(const DosApp: string; AMemo: TMemo; Hide:Boolean = True);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure N5Click(Sender: TObject);
    procedure T1Click(Sender: TObject);
    procedure A2Click(Sender: TObject);
    procedure C3Click(Sender: TObject);
    procedure C4Click(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure mCopyClick(Sender: TObject);
    procedure mCutClick(Sender: TObject);
    procedure mPasteClick(Sender: TObject);
    procedure actCopyExecute(Sender: TObject);
    procedure actCutExecute(Sender: TObject);
    procedure actPasteExecute(Sender: TObject);
    procedure actSelectAllExecute(Sender: TObject);
    procedure actUndoExecute(Sender: TObject);
    procedure actCompileExecute(Sender: TObject);
    procedure actRunExecute(Sender: TObject);
    procedure actWinRunExecute(Sender: TObject);
    procedure actSetupExecute(Sender: TObject);
    procedure actHelpExecute(Sender: TObject);
    procedure actNewExecute(Sender: TObject);
    procedure actOpenExecute(Sender: TObject);
    procedure actSaveExecute(Sender: TObject);
    procedure actSaveAsExecute(Sender: TObject);
    procedure actExitExecute(Sender: TObject);
    procedure actSaveUpdate(Sender: TObject);
    procedure SynEditReplaceText(Sender: TObject; const ASearch,
      AReplace: String; Line, Column: Integer;
      var Action: TSynReplaceAction);
    procedure actFindPrevExecute(Sender: TObject);
    procedure actSearchExecute(Sender: TObject);
    procedure actFindNextExecute(Sender: TObject);
    procedure actReplaceExecute(Sender: TObject);
  private

    { Private declarations }
    function AskSave:Boolean;
    procedure Compile;
    procedure NewFile;
    function  OpenFile(FileName: string): Boolean;
    function  SaveFile: Boolean;
    function  SaveFileAs: Boolean;
    procedure WMDropFiles(var Msg: TWMDropFiles); message WM_DROPFILES;
    procedure AppOnMessage(var Msg: TMsg; var Handled: Boolean);
    procedure UpdateTitle;
    procedure ReadIni;
    procedure WriteIni;
    procedure CreateMenuFromRecent;
    procedure RecentItemClick(Sender: TObject);
    procedure AddCurrentFileToRecentList;
  private
    DefaultTitle: string;
    RecentFile: TStringList;
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;
  CurrentFile: string;
  
implementation

uses dlgConfirmReplace;
{$R *.dfm}

procedure TMainForm.RunDosInMemo(const DosApp: string; AMemo: TMemo;
                               Hide:Boolean = True);
const
  {设置ReadBuffer的大小}
  ReadBuffer = 2400;
var
  Security: TSecurityAttributes;
  ReadPipe, WritePipe: THandle;
  start: TStartUpInfo;
  ProcessInfo: TProcessInformation;
  Buffer: PChar;
  BytesRead: DWord;
  Buf: string;
begin
  with Security do
  begin
    nlength := SizeOf(TSecurityAttributes);
    binherithandle := true;
    lpsecuritydescriptor := nil;
  end;
  {创建一个命名管道用来捕获console程序的输出}
  if Createpipe(ReadPipe, WritePipe, @Security, 0) then
  begin
    Buffer := AllocMem(ReadBuffer + 1);
    FillChar(Start, Sizeof(Start), #0);
    {设置console程序的启动属性}
    with start do
    begin
      cb := SizeOf(start);
      start.lpReserved := nil;
      lpDesktop := nil;
      lpTitle := nil;
      dwX := 0;
      dwY := 0;
      dwXSize := 0;
      dwYSize := 0;
      dwXCountChars := 0;
      dwYCountChars := 0;
      dwFillAttribute := 0;
      cbReserved2 := 0;
      lpReserved2 := nil;
      hStdOutput := WritePipe; //将输出定向到我们建立的WritePipe上
      hStdInput := ReadPipe; //将输入定向到我们建立的ReadPipe上
      hStdError := WritePipe;//将错误输出定向到我们建立的WritePipe上
      dwFlags := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;
      if Hide then
         wShowWindow := SW_HIDE//设置窗口为hide
      else
         wShowWindow := SW_SHOW;//设置窗口为show
    end;

    try
      {创建一个子进程，运行console程序}
      if CreateProcess(nil, PChar(DosApp), @Security, @Security, true,
        NORMAL_PRIORITY_CLASS,
        nil, nil, start, ProcessInfo) then
      begin
       {等待进程运行结束}
        WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
        {关闭输出...开始没有关掉它，结果如果没有输出的话，程序死掉了。}
        CloseHandle(WritePipe);
        Buf := '';
        {读取console程序的输出}
        repeat
          BytesRead := 0;
          ReadFile(ReadPipe, Buffer[0], ReadBuffer, BytesRead, nil);
          Buffer[BytesRead] := #0;
          OemToAnsi(Buffer, Buffer);
          Buf := Buf + string(Buffer);
        until (BytesRead < ReadBuffer);

//        SendDebug(Buf);
       {按照换行符进行分割，并在Memo中显示出来}
        while pos(#10, Buf) > 0 do
        begin
          AMemo.Lines.Add(Copy(Buf, 1, pos(#10, Buf) - 1));
          Delete(Buf, 1, pos(#10, Buf));
        end;
      end;
    finally
      FreeMem(Buffer);
      CloseHandle(ProcessInfo.hProcess);
      CloseHandle(ProcessInfo.hThread);
      CloseHandle(ReadPipe);
    end;
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  SynEditor := SynEdit;
  RecentFile := TStringList.Create;
  ThisPath := ExtractFilePath(Application.ExeName);
  if ThisPath[Length(ThisPath)] <> '\' then ThisPath := ThisPath + '\';
  DragAcceptFiles(Handle, True);
  DragAcceptFiles(Application.Handle, True);
  Application.OnMessage := AppOnMessage;
  ReadIni;
  SynEdit.Highlighter:=TAplosSyn.Create(SynEdit);
  MemoDebug.Clear;
  MemoDebug.Lines.Add('Started');
  CurrentFile:='';
  DefaultTitle := Caption;

  if ParamCount > 0 then
  begin
    OpenFile(ParamStr(1));
  end else begin
    NewFile;
  end;
end;

function TMainForm.AskSave: Boolean;
var r:Integer;
begin
  if SynEdit.Modified then
  begin
     R:=Application.MessageBox('文件已经修改,是否保存?','Aplos Editor',
                         MB_YESNOCANCEL);
     if R=IDYES then SaveFile;
     Result:=(R<>IDCANCEL);
  end else
     Result:=True;
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose:=AskSave;
end;

procedure TMainForm.Compile;
begin
  MemoDebug.Lines.SetText('编译:');
//先将目录设为当前文件所在的目录
  SetCurrentDir(ExtractFilePath(CurrentFile));
  RunDosInMemo(APLOSNAME+' "'+CurrentFile+'" "/c'+ExpandFileName(DEBUGOUT)+'"' ,MemoDebug);
end;

procedure TMainForm.N5Click(Sender: TObject);
begin
 try
  MemoDebug.Clear;
  MemoDebug.Lines.LoadFromFile(DEBUGOUT);
 finally
 end;
end;

procedure TMainForm.T1Click(Sender: TObject);
begin
   N5.Enabled:=FileExists(DEBUGOUT);
end;

procedure TMainForm.A2Click(Sender: TObject);
begin
  ABoutBox.ShowModal;
end;

procedure TMainForm.C3Click(Sender: TObject);
begin
   MemoDebug.Lines.Clear;
end;

procedure TMainForm.C4Click(Sender: TObject);
begin
   MemoDebug.CopyToClipboard;
end;

procedure TMainForm.PopupMenu1Popup(Sender: TObject);
begin
   C4.Enabled := MemoDebug.SelLength > 0;
   C3.Enabled := MemoDebug.Text <> '';
end;

procedure TMainForm.NewFile;
begin
  SynEdit.Lines.Clear;
//  SynEdit.Lines.Add('#setlock');
//  SynEdit.Lines.Add('include stdlib');
//  SynEdit.Lines.Add('');
//  SynEdit.SelStart := Length(SynEdit.Text)-1;
  SynEdit.Modified:=False;
  MemoDebug.Lines.Add('新建文件');
  AddCurrentFileToRecentList;
  CreateMenuFromRecent;
  CurrentFile:='';
  UpdateTitle;
end;

procedure TMainForm.AppOnMessage(var Msg: TMsg; var Handled: Boolean);
var WMD : TWMDropFiles;
begin
  if Msg.message = WM_DROPFILES then
  begin
    MessageBeep(0);
    WMD.Msg    := Msg.message;
    WMD.Drop   := Msg.wParam;
    WMD.Unused := Msg.lParam;
    WMD.Result := 0;
    WMDropFiles(WMD);
    Handled := TRUE;
  end;
end;

procedure TMainForm.WMDropFiles(var Msg: TWMDropFiles);
var
  N : Word;
  buffer : array[0..180] of Char;
begin
  with Msg do
  begin
    for N := 0 to DragQueryFile(Drop, $FFFFFFFF, buffer,1)-1 do
    begin
      DragQueryFile(Drop, N, Buffer, 80);
      if AskSave then
        OpenFile(StrPas(Buffer));
      Break;  
    end;
    DragFinish(Drop);
  END;
END;



function TMainForm.OpenFile(FileName: string): Boolean;
var
  I: Integer;
begin
  Result := True;
  try
    AddCurrentFileToRecentList;
    I := RecentFile.IndexOf(FileName);
    if  I >= 0 then
    begin
      RecentFile.Delete(I);
    end;
    SynEdit.Lines.LoadFromFile(FileName);
    SynEdit.Modified:=False;
    MemoDebug.Lines.Add('打开文件 '+FileName);
    CurrentFile:=FileName;
    UpdateTitle;
    CreateMenuFromRecent;
  except
    Result := False;
    ShowMessage('无法打开文件：'+FileName);
  end;
end;

function TMainForm.SaveFile: Boolean;
begin
  Result := True;
  if CurrentFile = '' then
  begin
   if Save1.Execute then
   begin
     CurrentFile := Save1.FileName;
   end else
     Exit;
  end;
  SynEdit.Lines.SaveToFile(CurrentFile);
  SynEdit.Modified:=False;
  MemoDebug.Lines.Add('保存文件 '+CurrentFile);
  UpdateTitle;
end;

function TMainForm.SaveFileAs: Boolean;
begin
  Result := True;
  if Save1.Execute then
  begin
    AddCurrentFileToRecentList;
    CreateMenuFromRecent;
    CurrentFile := Save1.FileName;
    Result := SaveFile;
  end else
    Exit;

end;


procedure TMainForm.UpdateTitle;
begin
  if CurrentFile = '' then
    Caption := '未命名'+' - '+DefaultTitle
  else
    Caption := CurrentFile+' - '+DefaultTitle ;
end;

procedure TMainForm.ReadIni;
var
  KeyList: TStringList;
  I: Integer;
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(ExpandFileName('Editor.ini'));

  KeyList := TStringList.Create;

  APLOSNAME := Ini.ReadString('选项', 'Aplos', ThisPath + 'aplos.exe');

  RUNAPLNAME := Ini.ReadString('选项', 'RunApl', ThisPath + 'runapl.exe');

  WINAPLNAME := Ini.ReadString('选项', 'WinApl', ThisPath + 'winapl.exe');

  DELAYED   := Ini.ReadBool('选项', 'Delay', True);

  Ini.ReadSection('最近文件', KeyList);
  RecentFile.Clear;
  RecentFile.BeginUpdate;
  for I := 0 to KeyList.Count - 1 do
    RecentFile.Add(Ini.ReadString('最近文件', KeyList[I], ''));
  RecentFile.EndUpdate;
  CreateMenuFromRecent;
  KeyList.Free;
  Ini.Free;
end;

procedure TMainForm.WriteIni;
var
  Ini: TIniFile;
  I: Integer;
begin
  Ini := TIniFile.Create(ThisPath + 'Editor.ini');
  Ini.WriteString('选项', 'Aplos', APLOSNAME);
  Ini.WriteString('选项', 'RunApl', RUNAPLNAME);
  Ini.WriteString('选项', 'WinApl', WINAPLNAME);
  Ini.WriteBool('选项', 'Delay', DELAYED);
  for I := 0  to RecentFile.Count - 1 do
  begin
    Ini.WriteString('最近文件', IntToStr(I), RecentFile.Strings[I]);
  end;
  Ini.Free;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  AddCurrentFileToRecentList;
  WriteIni;
  RecentFile.Free;
end;

procedure TMainForm.CreateMenuFromRecent;
var
  I: Integer;
  Item: TMenuItem;
begin
  mRecent.Clear;
  if RecentFile.Count = 0 then
  begin
    Item := TMenuItem.Create(Self);
    Item.Caption := '(空)';
    Item.Enabled := False;
    mRecent.Add(Item);
  end else begin
    for I := 0 to RecentFile.Count - 1 do
    begin
      Item := TMenuItem.Create(Self);
      Item.Caption := '&'+IntToStr(I)+'.'+ RecentFile.Strings[I];
      Item.Tag := I;
      Item.OnClick := RecentItemClick;
      mRecent.Add(Item);
    end;
  end;
end;

procedure TMainForm.RecentItemClick(Sender: TObject);
var
  I: Integer;
begin
  I := TMenuItem(Sender).Tag;
  if AskSave then
  begin
    OpenFile(RecentFile.Strings[I]);
  end;
end;

procedure TMainForm.AddCurrentFileToRecentList;
const
  RecentMax = 10;
begin
  if (CurrentFile <> '') and ( RecentFile.IndexOf(CurrentFile) < 0 ) then
  begin
    RecentFile.Add(CurrentFile);
  end;
  if RecentFile.Count > RecentMax then
  begin
    RecentFile.Delete(0);
  end;  
end;





procedure TMainForm.mCopyClick(Sender: TObject);
begin
  SynEdit.CopyToClipboard;
end;

procedure TMainForm.mCutClick(Sender: TObject);
begin
  SynEdit.CutToClipboard;
end;

procedure TMainForm.mPasteClick(Sender: TObject);
begin
  SynEdit.PasteFromClipboard;
end;

procedure TMainForm.actCopyExecute(Sender: TObject);
begin
  SynEdit.CopyToClipboard;
end;

procedure TMainForm.actCutExecute(Sender: TObject);
begin
  SynEdit.CutToClipboard;
end;

procedure TMainForm.actPasteExecute(Sender: TObject);
begin
  SynEdit.PasteFromClipboard;
end;

procedure TMainForm.actSelectAllExecute(Sender: TObject);
begin
  SynEdit.SelectAll;
end;

procedure TMainForm.actUndoExecute(Sender: TObject);
begin
  SynEdit.Undo;
end;

procedure TMainForm.actCompileExecute(Sender: TObject);
begin
  if SynEdit.Modified then
  begin
     if Application.MessageBox('要先保存才能编译,是否保存','Aplos Editor'
                             ,MB_YESNO)=IDNO then Exit;;
     actSave.Execute;
  end;
  if CurrentFile<>'' then Compile;
end;

procedure TMainForm.actRunExecute(Sender: TObject);
begin
//先编译
  actCompile.Execute;
  //如编译成功就运行
  if MemoDebug.Lines.Strings[MemoDebug.Lines.Count-3]
     ='OK!' then
  begin
     MemoDebug.Lines.Add('运行:'+ ChangeFileExt(CurrentFile,'.spt'));
     if NOT DELAYED then
       WinExec(PChar(RUNAPLNAME+' "'+ChangeFileExt(CurrentFile,'.spt')+'"'),SW_SHOW)
     else
       WinExec(PChar(RUNAPLNAME+' "'+ChangeFileExt(CurrentFile,'.spt ')+'" /d'),SW_SHOW)
  end;
end;

procedure TMainForm.actWinRunExecute(Sender: TObject);
begin
//先编译
  actCompile.Execute;
  //如编译成功就运行
  if MemoDebug.Lines.Strings[MemoDebug.Lines.Count-3]
     ='OK!' then
  begin
     MemoDebug.Lines.Add('运行(WIN):'+ ChangeFileExt(CurrentFile,'.spt'));
     WinExec(PChar(WINAPLNAME+' "'+ChangeFileExt(CurrentFile,'.spt')+'"'), SW_SHOW)
  end;
end;

procedure TMainForm.actSetupExecute(Sender: TObject);
begin
  SetupForm.ShowModal;
end;

procedure TMainForm.actHelpExecute(Sender: TObject);
begin
  ShowHelpFile(Handle, ThisPath + 'AplosHelp.chm');
end;

procedure TMainForm.actNewExecute(Sender: TObject);
begin
  if AskSave then
  begin
    NewFile;
  end;
end;

procedure TMainForm.actOpenExecute(Sender: TObject);
begin
  if (Open1.Execute)and(AskSave) then
  begin
     OpenFile(Open1.FileName);
  end;
end;

procedure TMainForm.actSaveExecute(Sender: TObject);
begin
  SaveFile;
end;

procedure TMainForm.actSaveAsExecute(Sender: TObject);
begin
  SaveFileAs;
end;

procedure TMainForm.actExitExecute(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.actSaveUpdate(Sender: TObject);
begin
  actSave.Enabled := SynEdit.Modified;
end;

procedure TMainForm.SynEditReplaceText(Sender: TObject; const ASearch,
  AReplace: String; Line, Column: Integer; var Action: TSynReplaceAction);
var
  APos: TPoint;
  EditRect: TRect;
begin
  if ASearch = AReplace then
    Action := raSkip
  else begin
    APos := Point(Column, Line);
    APos := SynEdit.ClientToScreen(SynEdit.RowColumnToPixels(APos));
    EditRect := ClientRect;
    EditRect.TopLeft := ClientToScreen(EditRect.TopLeft);
    EditRect.BottomRight := ClientToScreen(EditRect.BottomRight);

    if ConfirmReplaceDialog = nil then
      ConfirmReplaceDialog := TConfirmReplaceDialog.Create(Application);
    ConfirmReplaceDialog.PrepareShow(EditRect, APos.X, APos.Y,
      APos.Y + SynEditor.LineHeight, ASearch);
    case ConfirmReplaceDialog.ShowModal of
      mrYes: Action := raReplace;
      mrYesToAll: Action := raReplaceAll;
      mrNo: Action := raSkip;
      else Action := raCancel;
    end;
  end;

end;



procedure TMainForm.actFindPrevExecute(Sender: TObject);
begin
  DoSearchReplaceText(FALSE, TRUE);
end;



procedure TMainForm.actSearchExecute(Sender: TObject);
begin
  ShowSearchReplaceDialog(FALSE);

end;

procedure TMainForm.actFindNextExecute(Sender: TObject);
begin
  DoSearchReplaceText(FALSE, FALSE);

end;

procedure TMainForm.actReplaceExecute(Sender: TObject);
begin
  ShowSearchReplaceDialog(TRUE);

end;

end.
