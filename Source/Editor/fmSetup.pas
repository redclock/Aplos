unit fmSetup;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Registry;

type
  TSetupForm = class(TForm)
    Edit1: TEdit;
    Edit2: TEdit;
    CheckBox1: TCheckBox;
    Label1: TLabel;
    Label2: TLabel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    OpenDialog1: TOpenDialog;
    btnAPL: TButton;
    btnRun: TButton;
    Button3: TButton;
    Button4: TButton;
    Label3: TLabel;
    Edit3: TEdit;
    btnWin: TButton;
    procedure FormCreate(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure btnAPLClick(Sender: TObject);
    procedure btnRunClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure btnWinClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SetupForm: TSetupForm;
  APLOSNAME: string = 'aplos.exe';
  RUNAPLNAME: string = 'runapl.exe';
  WINAPLNAME: string = 'winapl.exe';
  DELAYED: Boolean=True;
  DEBUGOUT: string = 'compile output.txt';
var
  ThisPath: string;

implementation

{$R *.dfm}

function AssignToAPL(strFileExtension,
         strDiscription,strExeFileName : string ) : boolean;
var
 registerTemp : TRegistry;
begin
 registerTemp := TRegistry.Create;
 with registerTemp do
    begin
      RootKey:=HKEY_CLASSES_ROOT;
      if not OpenKey( '.' + strFileExtension, true ) then
      begin
        result := false;
        exit;
      end;
      WriteString('',strFileExtension + '_Script_File');
      CloseKey;
      if not OpenKey(strFileExtension + '_Script_File', true ) then
      begin
        result := false;
        exit;
      end;
      WriteString('',strDiscription);
      CloseKey;
      if not OpenKey(strFileExtension + '_Script_File\DefaultIcon', true ) then
      begin
        result := false;
        exit;
      end;
      WriteString('',ThisPath + 'Aplos.ico');
      CloseKey;
      if not OpenKey(strFileExtension + '_Script_File\shell\open\command', true ) then
      begin
        result := false;
        exit;
      end;
      WriteString('','"' + strExeFileName + '" "%1"');
      CloseKey;
      if not OpenKey(strFileExtension + '_Script_File\shell\compile', true ) then
      begin
        result := false;
        exit;
      end;
      WriteString('', '编译');
      CloseKey;
      if not OpenKey(strFileExtension + '_Script_File\shell\compile\command', true ) then
      begin
        result := false;
        exit;
      end;
      WriteString('', '"' + APLOSNAME + '" "%1"');
      CloseKey;
      if not OpenKey(strFileExtension + '_Script_File\shell\run', true ) then
      begin
        result := false;
        exit;
      end;
      WriteString('', '运行');
      CloseKey;
      if not OpenKey(strFileExtension + '_Script_File\shell\run\command', true ) then
      begin
        result := false;
        exit;
      end;
      WriteString('', '"' + APLOSNAME + '" /n /m /r "%1"');
      CloseKey;
      Free;
    end;
  Result := True;
end;


function AssignToSPT(strFileExtension, strDiscription: string) : boolean;
var
 registerTemp : TRegistry;
begin
 registerTemp := TRegistry.Create;
 with registerTemp do
    begin
      RootKey:=HKEY_CLASSES_ROOT;
      if not OpenKey( '.' + strFileExtension, true ) then
      begin
        result := false;
        exit;
      end;
      WriteString('',strFileExtension + '_Script_File');
      CloseKey;
      if not OpenKey(strFileExtension + '_Script_File\DefaultIcon', true ) then
      begin
        result := false;
        exit;
      end;
      WriteString('',ThisPath + 'spt.ico');
      CloseKey;
      if not OpenKey(strFileExtension + '_Script_File', true ) then
      begin
        result := false;
        exit;
      end;
      WriteString('',strDiscription);
      CloseKey;
      if not OpenKey(strFileExtension + '_Script_File\shell\open\command', true ) then
      begin
        result := false;
        exit;
      end;
      WriteString('','"' + RUNAPLNAME + '" /d "%1"');
      CloseKey;
      Free;
    end;
   Result := True;
end;


procedure TSetupForm.FormCreate(Sender: TObject);
begin
  Edit1.Text := APLOSNAME;
  Edit2.Text := RUNAPLNAME;
  Edit2.Text := WINAPLNAME;
  CheckBox1.Checked := DELAYED;
end;

procedure TSetupForm.BitBtn1Click(Sender: TObject);
begin
  APLOSNAME := Edit1.Text;
  RUNAPLNAME := Edit2.Text;
  WINAPLNAME := Edit3.Text;
  DELAYED := CheckBox1.Checked;
end;

procedure TSetupForm.btnAPLClick(Sender: TObject);
begin
  OpenDialog1.FileName := Edit1.Text;
  if OpenDialog1.Execute then
    Edit1.Text := OpenDialog1.FileName;
end;

procedure TSetupForm.btnRunClick(Sender: TObject);
begin
  OpenDialog1.FileName := Edit2.Text;
  if OpenDialog1.Execute then
    Edit2.Text := OpenDialog1.FileName;
end;

procedure TSetupForm.btnWinClick(Sender: TObject);
begin
  OpenDialog1.FileName := Edit3.Text;
  if OpenDialog1.Execute then
    Edit3.Text := OpenDialog1.FileName;
end;

procedure TSetupForm.Button3Click(Sender: TObject);
begin
  if AssignToAPL('apl', 'Aplos脚本源文件', Application.ExeName) then
    ShowMessage('关联成功')
  else
    ShowMessage('关联失败');
end;

procedure TSetupForm.Button4Click(Sender: TObject);
begin
  if AssignToSPT('spt', 'Aplos已编译脚本') then
    ShowMessage('关联成功')
  else
    ShowMessage('关联失败');

end;


end.
