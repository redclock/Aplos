unit SptSys;

interface

uses
  SysUtils,
  SptConst,
  FileStack,
  SptOut,
  Compile,
  SptBin,
  Script
;

type
  TCmdLineOpt = record
     bRun: Boolean;
     bMem: Boolean;
     bHelp: Boolean;
     SrcFile: string;
     DstFile: string;
     DbgFile: string;
  end;

  function GetCmdOpt(var opt: TCmdLineOpt): Boolean;
  function GetHelpStr: string;
  function GetHelloStr: string;
  function CompileSpt(SrcFile: string; Bin: SPTFile; DbgFile: string = ''): Boolean;
  function WriteToBin(DscFile: string; Bin: SPTFile): Boolean;
  function RunSpt(Bin: SPTFile): Boolean;

var
  TotalLines: Integer;
implementation

function GetCmdOpt(var opt: TCmdLineOpt): Boolean;
var
  s: string;
  i: integer;
begin
  opt.bRun      := False;
  opt.bMem      := False;
  opt.SrcFile   := '';
  opt.DstFile   := '';
  opt.DbgFile   := '';
  opt.bHelp     := False;

  for i:=1 to ParamCount do
  begin
    s := ParamStr(i);
    if s[1] = '/' then
    begin
      if Length(s) < 2 then Continue;
      case s[2] of
        'r','R':opt.bRun:=True;
        'm','M':opt.bMem:=True;
        'o','O':begin
              Delete(s, 1, 2);
              if s<>'' then
                if ExtractFileExt(s) = '' then
                  opt.DstFile := s+BinaryFileExt
                else
                  opt.DstFile := s;
            end;
        'n','N':begin
               OutputStdandard := False;
             end;
        'c','C':begin
               Delete(s, 1, 2);
               opt.DbgFile := Trim(s);
             end;
        '?' : opt.bHelp := True;
         else begin
            errWriteln('不认识的开关 /'+s[2]);
            Result := False;
            Exit;
         end;
       end;
     end else begin
       opt.SrcFile := s;
       if opt.DstFile = '' then
         opt.DstFile := ChangeFileExt(opt.SrcFile, BinaryFileExt);
     end;
   end;
   if opt.DbgFile <> '' then OutputDebug := True;
   Result := True;
end;

function GetHelpStr: string;
begin
  Result := '用法: aplos [<File>] [/o<StpFile>] [/m] [/r] [/n] [/c<File>]'#10#13 +
  '      /o : 指定输出文件名'#10#13 +
  '      /m : 在内存中编译'#10#13 +
  '      /r : 编译后运行'#10#13 +
  '      /n : 不输出提示信息'#10#13 +
  '      /c : 将编译过程输出到指定文件'#10#13+
  '示例: aplos hello /ofirst /r';
end;

function GetHelloStr: string;
begin
  Result := 'Aplos脚本编译器.  By Redclock '#10#13 +
  '版权所有    2004.3-2005.5';
end;

function CompileSpt(SrcFile: string; Bin: SPTFile; DbgFile: string = ''): Boolean;
var
  Sources: TFileStack;
  s: string;
  MainIndex: Integer;
begin

  Err:=False;

  Sources := TFileStack.Create(SrcFile);  //file manager
  if Sources.Err then
  begin
    errWriteln('Error:文件 '+SrcFile+' 无法打开.');
    Err := True;
    Sources.Free;
    Result := False;
    Exit;
  end;
  if OutputDebug then
    if debugOpen(DbgFile) = False then
    begin
      errWriteln('Error:无法打开调试文件：'+DbgFile);
      OutputDebug := False;
    end;
  InitCompiler;          //初始化编译器
  MainIndex := Bin.AddFuncDeclare('_main_');
  Bin.NewFunction(MainIndex);       // Add default main function

  while not(err or Sources.IsEmpty) do   //loop for each line
  begin
    if IncludeFile <> '' then            //if need to include file
    begin
      Sources.Add(IncludeFile);
      if Sources.Err then
      begin
        errWriteln('Error:无法包含文件:'+IncludeFile + ' 信息：' + Sources.ErrStr);
        IncludeFile := '';
        Err := True;
        Break;
      end;
      IncludeFile := '';
      dMsg('* 包含文件:'+Sources.ActiveFileName);
    end;
    s := Sources.GetALine;
    if Sources.Err then
    begin
      errWriteln('Error:读文件错误!');
      Err := True;
      Break;
    end;
    s := Trim(s);
    dMsg('#####'+s);
    if (s='') or (s[1]in ['''','/',';']) then     //如果是注释
    begin
      continue;
    end else if (s[1]='@') then                   //如果是标号
    begin
      Delete(s,1,1);
      AddLabel(s);
    end else if (s[1]='#') then                   //如果是编译指令
    begin
      Delete(s,1,1);
      CompileInstruction(s);
    end else begin
      CompileOne(s);                              //语句
    end;
  end;

  EndCompiler;                                    //结束编译器

  if not(Err) and (Bin.CurrFunc.IsMain = False) then
  begin
    errWriteln('函数未结束');
    Err := True;
  end;

  if not Err then
  begin
    Bin.MergeFunctions;
    Bin.DefHeader;
    dMsg('脚本入口点：'+IntToStr(Bin.FuncList[Bin.Header.StartIndex].Address));
  end;

  if Err then begin
    errWriteln('文件:'+Sources.ActiveFileName+':');
    errWriteln('有错误发生 行('+IntToStr(Sources.GetLineNo)+'):');
    errWriteln(s);
  end;
  TotalLines := Sources.AllLines;
  Sources.Free;
  Result := not Err;
end;

function WriteToBin(DscFile: string; Bin: SPTFile): Boolean;
begin
  {$I-}
    Bin.SaveAs(DscFile);
  {$I+}
  if IOResult <> 0 then begin
    errWriteln('Error:无法输出到目标文件.');
    Result := False;
  end else begin
    Result := True;
  end;
end;

function RunSpt(Bin: SPTFile): Boolean;
begin
  //stdWriteln('------- Run --------');
  ResetScript;
  CallScript(Bin);
  while Script.IsRunning do DoScript(0);
  if Script.ErrStr<>'' then
            errWriteln('Runtime Error:' + Script.ErrStr);
  Result := False;          
end;

end.
