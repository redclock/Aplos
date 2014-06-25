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
            errWriteln('����ʶ�Ŀ��� /'+s[2]);
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
  Result := '�÷�: aplos [<File>] [/o<StpFile>] [/m] [/r] [/n] [/c<File>]'#10#13 +
  '      /o : ָ������ļ���'#10#13 +
  '      /m : ���ڴ��б���'#10#13 +
  '      /r : ���������'#10#13 +
  '      /n : �������ʾ��Ϣ'#10#13 +
  '      /c : ��������������ָ���ļ�'#10#13+
  'ʾ��: aplos hello /ofirst /r';
end;

function GetHelloStr: string;
begin
  Result := 'Aplos�ű�������.  By Redclock '#10#13 +
  '��Ȩ����    2004.3-2005.5';
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
    errWriteln('Error:�ļ� '+SrcFile+' �޷���.');
    Err := True;
    Sources.Free;
    Result := False;
    Exit;
  end;
  if OutputDebug then
    if debugOpen(DbgFile) = False then
    begin
      errWriteln('Error:�޷��򿪵����ļ���'+DbgFile);
      OutputDebug := False;
    end;
  InitCompiler;          //��ʼ��������
  MainIndex := Bin.AddFuncDeclare('_main_');
  Bin.NewFunction(MainIndex);       // Add default main function

  while not(err or Sources.IsEmpty) do   //loop for each line
  begin
    if IncludeFile <> '' then            //if need to include file
    begin
      Sources.Add(IncludeFile);
      if Sources.Err then
      begin
        errWriteln('Error:�޷������ļ�:'+IncludeFile + ' ��Ϣ��' + Sources.ErrStr);
        IncludeFile := '';
        Err := True;
        Break;
      end;
      IncludeFile := '';
      dMsg('* �����ļ�:'+Sources.ActiveFileName);
    end;
    s := Sources.GetALine;
    if Sources.Err then
    begin
      errWriteln('Error:���ļ�����!');
      Err := True;
      Break;
    end;
    s := Trim(s);
    dMsg('#####'+s);
    if (s='') or (s[1]in ['''','/',';']) then     //�����ע��
    begin
      continue;
    end else if (s[1]='@') then                   //����Ǳ��
    begin
      Delete(s,1,1);
      AddLabel(s);
    end else if (s[1]='#') then                   //����Ǳ���ָ��
    begin
      Delete(s,1,1);
      CompileInstruction(s);
    end else begin
      CompileOne(s);                              //���
    end;
  end;

  EndCompiler;                                    //����������

  if not(Err) and (Bin.CurrFunc.IsMain = False) then
  begin
    errWriteln('����δ����');
    Err := True;
  end;

  if not Err then
  begin
    Bin.MergeFunctions;
    Bin.DefHeader;
    dMsg('�ű���ڵ㣺'+IntToStr(Bin.FuncList[Bin.Header.StartIndex].Address));
  end;

  if Err then begin
    errWriteln('�ļ�:'+Sources.ActiveFileName+':');
    errWriteln('�д����� ��('+IntToStr(Sources.GetLineNo)+'):');
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
    errWriteln('Error:�޷������Ŀ���ļ�.');
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
