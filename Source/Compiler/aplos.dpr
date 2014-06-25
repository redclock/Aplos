{********************************
 * Aplos脚本编译器              *
 *     主程序                   *
 *    姚春晖(redclock)2004      *
 ********************************}
{$APPTYPE CONSOLE}

program aplos;



{%File '..\..\Doc\日志.txt'}
{%File '..\..\Doc\FileList.txt'}

uses
  SysUtils,
  StackUnit in 'StackUnit.pas',
  Compile in 'Compile.pas',
  DefineVar in 'DefineVar.pas',
  Express in 'Express.pas',
  FileStack in 'FileStack.pas',
  Oper in 'Oper.pas',
  SptBin in 'SptBin.pas',
  SptConst in 'SptConst.pas',
  SptFunc in 'SptFunc.pas',
  Script in 'Script.pas',
  SptOut in 'SptOut.pas',
  SptSys in 'SptSys.pas',
  SptClass in 'SptClass.pas';

{Main}
var
  opt: TCmdLineOpt;
begin
 if OpenAll = False then
 begin
   Writeln('建立输出设备出错');
   ExitCode := 1;
   Exit;
 end;

 if  GetCmdOpt(opt) = False then                 //处理命令行参数
 begin
   ExitCode := 1;
   Exit;
 end;

 stdWriteln(GetHelloStr);

 if opt.bHelp then
 begin
   stdWriteln(GetHelpStr);
   ExitCode := 0;
   Exit;
 end;

 if opt.SrcFile = '' then                        //命令行中没有文件名
 begin
   stdWriteln('');
   stdWrite('源文件：');
   Readln(opt.SrcFile);                          //从键盘读入文件名
   if opt.DstFile = '' then
     opt.DstFile := ChangeFileExt(opt.SrcFile, SourceFileExt);
 end;

 if (opt.SrcFile <> '') and (Pos('.', opt.SrcFile) = 0) then  //Add extension portion .gcs
    opt.SrcFile := opt.SrcFile + SourceFileExt;

 if not FileExists(opt.SrcFile) then
 begin
   errWriteln('找不到文件: ' + opt.SrcFile);
   ExitCode := 1;
   Exit;
 end;

 Bin:=SptFile.Create(65536);                     //Binary file
 stdWriteln('正在编译...');

 try
   if CompileSpt(opt.SrcFile, Bin, opt.DbgFile) = False then   //进行编译
   begin
     ExitCode := 1;
     Exit;
   end;
 except
   on E: Exception do
   begin
     errWriteln('内部错误:'+E.Message);
     ExitCode := 1;
     Exit;
   end;  
 end;     

 if opt.bMem = False then                        //写入文件
 begin
   stdWriteln('输出到目标文件:' + opt.DstFile);
   if WriteToBin(opt.DstFile, Bin) = False then
   begin
     ExitCode := 1;
     Exit;
   end;
   stdWriteln('写入 '+ IntToStr(Bin.Len+SizeOf(Bin.Header)) + ' 字节.');
 end;

 stdWriteln('成功完成编译.');
 stdWriteln('OK!');
 stdWriteln('');
 stdWriteln('已编译 ' + IntToStr( TotalLines ) + ' 行代码.');

 if opt.bRun then           //如有/r 运行脚本
 begin
   stdWriteln('------- Run --------');
   RunSpt(Bin);
 end;
 CloseAll;
end.


