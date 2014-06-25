{********************************
 *  Aplos二进制控制台运行器     *
 *     主程序                   *
 *    姚春晖(redclock)2004      *
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
  Writeln('Aplos Script控制台运行器  By Redclock');
  Writeln('版权所有      2004.8');
  Writeln('用法: runapl [<File>] [/d]');
  Writeln('说明: /d : 运行完成后等待按键');
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
             Writeln('不认识的开关 /',s[2]);
             Halt(1);
           end;
        end;
      end else FileName:=s;
    end;
    if FileName='' then
    begin
       Write('SPT 文件:');
       Readln(FileName);
    end;
    if Pos('.',FileName)=0 then
       FileName:=FileName+BinaryFileExt;
    if not FileExists(FileName) then
    begin
       Writeln('找不到文件: ',FileName);
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
      Writeln('按任意键结束...');
      ReadKey;
    end;
end.

