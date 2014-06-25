{********************************
 * Aplos�ű�������              *
 *     ������                   *
 *    Ҧ����(redclock)2004      *
 ********************************}
{$APPTYPE CONSOLE}

program aplos;



{%File '..\..\Doc\��־.txt'}
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
   Writeln('��������豸����');
   ExitCode := 1;
   Exit;
 end;

 if  GetCmdOpt(opt) = False then                 //���������в���
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

 if opt.SrcFile = '' then                        //��������û���ļ���
 begin
   stdWriteln('');
   stdWrite('Դ�ļ���');
   Readln(opt.SrcFile);                          //�Ӽ��̶����ļ���
   if opt.DstFile = '' then
     opt.DstFile := ChangeFileExt(opt.SrcFile, SourceFileExt);
 end;

 if (opt.SrcFile <> '') and (Pos('.', opt.SrcFile) = 0) then  //Add extension portion .gcs
    opt.SrcFile := opt.SrcFile + SourceFileExt;

 if not FileExists(opt.SrcFile) then
 begin
   errWriteln('�Ҳ����ļ�: ' + opt.SrcFile);
   ExitCode := 1;
   Exit;
 end;

 Bin:=SptFile.Create(65536);                     //Binary file
 stdWriteln('���ڱ���...');

 try
   if CompileSpt(opt.SrcFile, Bin, opt.DbgFile) = False then   //���б���
   begin
     ExitCode := 1;
     Exit;
   end;
 except
   on E: Exception do
   begin
     errWriteln('�ڲ�����:'+E.Message);
     ExitCode := 1;
     Exit;
   end;  
 end;     

 if opt.bMem = False then                        //д���ļ�
 begin
   stdWriteln('�����Ŀ���ļ�:' + opt.DstFile);
   if WriteToBin(opt.DstFile, Bin) = False then
   begin
     ExitCode := 1;
     Exit;
   end;
   stdWriteln('д�� '+ IntToStr(Bin.Len+SizeOf(Bin.Header)) + ' �ֽ�.');
 end;

 stdWriteln('�ɹ���ɱ���.');
 stdWriteln('OK!');
 stdWriteln('');
 stdWriteln('�ѱ��� ' + IntToStr( TotalLines ) + ' �д���.');

 if opt.bRun then           //����/r ���нű�
 begin
   stdWriteln('------- Run --------');
   RunSpt(Bin);
 end;
 CloseAll;
end.


