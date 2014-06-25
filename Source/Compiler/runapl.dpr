{********************************
 *  Aplos�����ƿ���̨������     *
 *     ������                   *
 *    Ҧ����(redclock)2004      *
 ********************************}
program runapl;
{$APPTYPE CONSOLE}
uses
  SysUtils,
  Windows,
  SptConst,
  Script,
  Keyboard;

var
  FileName:string;
  bDelay:Boolean;
procedure HelpMessage;
begin
  Writeln('Aplos Script����̨������  By Redclock');
  Writeln('��Ȩ����      2004.8');
  Writeln('�÷�: runapl [<File>] [/d]');
  Writeln('˵��: /d : ������ɺ�ȴ�����');
  Halt(0);
end;

procedure Prep;
var
   s:string;
   i:integer;
begin
   reset(input);
   bDelay:=false;
   FileName:='';
   for i:=1 to ParamCount do
   begin
      s:=ParamStr(i);
      if s[1]='/' then begin
        if length(s)<2 then continue;
        case s[2] of
           'd','D':bDelay:=True;
           '?':HelpMessage;
           else begin
             Writeln('����ʶ�Ŀ��� /',s[2]);
             Halt(1);
           end;
        end;
      end else FileName:=s;
    end;
    if FileName='' then
    begin
       Write('SPT �ļ�:');
       Readln(FileName);
    end;
    if Pos('.',FileName)=0 then
       FileName:=FileName+BinaryFileExt;
    if not FileExists(FileName) then
    begin
       Writeln('�Ҳ����ļ�: ',FileName);
       Halt(1);
    end;
end;

begin
    Prep;
    ResetScript;
    CallScript(FileName);
    while Script.IsRunning do DoScript(0);
    if Script.ErrStr<>'' then begin
	Writeln('Runtime Error:',Script.ErrStr);
        ExitCode := 1;
    end;
    if bDelay then
    begin
      Writeln('�����������...');
      ReadKey;
    end;
end.

