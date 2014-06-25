program WinApl;

uses
  Forms,
  SysUtils,
  fmMain in 'fmMain.pas' {MainForm},
  SptCtrl in 'SptCtrl.pas',
  Script in '..\Compiler\Script.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Aplos ÔËÐÐÆ÷ for Windows 0.51';
  Application.CreateForm(TMainForm, MainForm);
try
  Application.Run;
except
  on E:Exception do Application.MessageBox('Error', PChar(E.Message), 0);
end;
end.
