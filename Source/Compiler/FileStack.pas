(*******************************************************
 *       FileStack                                            *
 *       116                                            *
 *       版权所有 (C) 2005 Redclock                     *
 *******************************************************)




unit FileStack;

interface
uses
  SysUtils, Classes;
type
  TFileStack=class
  public
     Files: array[1..100] of TextFile;
     Names: array[1..100] of string;
     LineNo: array[1..100] of Integer;
     Count: Integer;
     AllLines: Integer;
     Err: Boolean;
     ErrStr: string;
     function Find(S: string): Boolean;
     function IsEmpty: Boolean;
     function ActiveFileName: string;
     function GetLineNo: Integer;
     function GetALine: string;
     procedure Add(S: string);
     constructor Create(S: string);
     destructor Free;
  end;
implementation


{ TFileStack }
{$I-}
function TFileStack.ActiveFileName: string;
begin
  if Count > 0 then Result := Names[Count]
  else Result :='';
end;

procedure TFileStack.Add(S: string);
begin

  if Find(S) then
  begin
    Err := True;
    ErrStr := '循环引用文件';
    Exit;
  end;
  Inc(Count);

  AssignFile(Files[Count], S);
  Reset(Files[Count]);

  if IOResult<>0 then
  begin
    Err := True;
    ErrStr := '文件IO出错';
    Exit;
  end;
  LineNo[Count] := 0;
  Names[Count] := Trim(LowerCase(ExpandFileName(S)));
  if Eof(Files[Count]) then
  begin
    CloseFile(Files[Count]);
    Dec(Count);
  end;
end;

constructor TFileStack.Create(S: string);
begin
  Count := 0;
  AllLines := 0;
  Err := False;
  Add(S);
end;

function TFileStack.Find(S: string): Boolean;
var
  I: Integer;
begin
  S := Trim(LowerCase(ExpandFileName(S)));
  for I := 1 to Count do
    if S = Names[I] then
    begin
      Result := True;
      Exit;
    end;
  Result := False;
end;

destructor TFileStack.Free;
var
  I: Integer;
begin
  for I := 1 to Count do
    CloseFile(Files[I]);
end;

function TFileStack.GetALine: string;
begin
  Readln(Files[Count], Result);
  Inc(LineNo[Count]);
  Inc(AllLines);
  if IOResult<>0 then begin Err := True; Exit; end;
  if Eof(Files[Count]) then
  begin
    CloseFile(Files[Count]);
    Dec(Count);
  end;
end;

function TFileStack.GetLineNo: Integer;
begin
  if Count > 0 then Result := LineNo[Count]
  else Result :=0;
end;

function TFileStack.IsEmpty: Boolean;
begin
  Result := Count <= 0;
end;

{$I+}
end.
