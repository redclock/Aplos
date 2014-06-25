unit fmMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Script, SptCtrl, StackUnit;

type
  TMainForm = class(TForm)
    OpenSptDialog: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    procedure InitScript;
    function CallSptFile(FileName: string): Boolean;
  public
    { Public declarations }
    ScriptFileName: string;
    function CallScriptFuntion(fid: Integer; P: array of TVar): TVar;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

{ TMainForm }

procedure TMainForm.InitScript;
begin
  if ParamCount = 0 then
  begin
    if OpenSptDialog.Execute then
      ScriptFileName := OpenSptDialog.FileName
    else
      Application.Terminate;
  end else begin
    ScriptFileName := ParamStr(1);
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  InitScript;
  CtrlList.SetMain(Self);
  if CallSptFile(ScriptFileName) = False then
  begin
    Close;
    Application.Terminate;
  end;
  SetWindowLong(Handle, GWL_EXSTYLE, WS_EX_TOPMOST)

  //SetForegroundWindow(Handle);
end;

function TMainForm.CallSptFile(FileName: string): Boolean;
begin
  Result := False;
  if not FileExists(FileName) then Exit;
  ResetScript;
  CallScript(FileName);
  while (Script.IsRunning) and (Script.Suspended = False) do
      DoScript(0);
  if Script.ErrStr<>'' then
  begin
      MessageBox(Handle, PChar(Script.ErrStr), '运行错误', MB_OK + MB_ICONSTOP
        + MB_TOPMOST);
      ExitCode := 1;
  end;
  Result := Script.IsRunning;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  CtrlList.ClearAll;
end;

function TMainForm.CallScriptFuntion(fid: Integer; P: array of TVar): TVar;
begin
  Script.CallFuntion(fid, P);
  if Script.ErrStr<>'' then
  begin
      MessageBox(Handle, PChar(Script.ErrStr), '运行错误', MB_OK + MB_ICONSTOP
        + MB_TOPMOST);
      ExitCode := 1;
  end;
  if not Script.IsRunning then
  begin
     Close;
     Application.Terminate;
  end;

end;

end.
