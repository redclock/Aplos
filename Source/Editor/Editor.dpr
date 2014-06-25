program Editor;

uses
  Forms,
  Form1Unit in 'Form1Unit.pas' {MainForm},
  fmAbout in 'fmAbout.pas' {AboutBox},
  fmSetup in 'fmSetup.pas' {SetupForm},
  unitShowHelp in 'unitShowHelp.pas',
  APLOS in 'APLOS.pas',
  dlgSearchText in 'Search\dlgSearchText.pas' {TextSearchDialog},
  dlgConfirmReplace in 'Search\dlgConfirmReplace.pas' {ConfirmReplaceDialog},
  dlgReplaceText in 'Search\dlgReplaceText.pas' {TextReplaceDialog},
  unitSearch in 'unitSearch.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.CreateForm(TSetupForm, SetupForm);
  Application.CreateForm(TConfirmReplaceDialog, ConfirmReplaceDialog);
  Application.Run;
end.
