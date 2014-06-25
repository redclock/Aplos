{********************************
 * 游戏脚本编译器               *
 *      二进制文件              *
 *         姚春晖 2004          *
 ********************************}
unit SptBin;

interface

uses SysUtils, SptConst;

const
  SPT_FILE_FLAG         = 1129794633;
  SPT_THIS_VERSION      = $00000001;
  SPT_MAX_FUNCTION      = 10;
  SPT_FUNC_BUF_LEN      = 65535;
  SPT_CODE_BEGIN_MARK   = $AABBCCDD;
type
  TByteArray = array[0..32767] of Byte;
  PByteArray = ^TByteArray;
  PLong = ^Longint;
  PSmall = ^Smallint;

  TSPTHeader = packed record
      Flag      :Integer;
      Version   :Integer;
      Len       :Integer;
      PrivSize  :Integer;
      StartIndex:Word;
      Locked    :ByteBool;
      FuncCount :Word;
      Reserve   :array[0..40] of Byte;
  end;


  TFunctionBlock = class
  public
      Len       :Integer;
      Position  :Integer;
      MaxLen    :Integer;
      Data      :PByteArray;
      IsMain    :Boolean;
      FuncIndex :Integer;

      constructor Create(Max:Integer);
      destructor  Free;
      procedure   Clear;

      procedure   WriteLong(x:Longint);
      procedure   WriteSmall(x:Smallint);
      procedure   WriteByte(x:Byte);
      procedure   WriteString(x:string);
      procedure   WriteFloat(x:Double);
      procedure   WriteBoolean(x:Boolean);
      procedure   WriteCmd(x: TCmdType);

      function    ReadLong:    Longint;
      function    ReadFloat:   Double;
      function    ReadSmall:   Smallint;
      function    ReadByte:    Byte;
      function    ReadString:  string;
      function    ReadBoolean: Boolean;
      function    ReadCmd:     TCmdType;

      function    EOF:Boolean;
  end;

  TUserFuncRec = packed record        //函数表项
        Address     : Integer;
        LoacalSize  : Byte;
        DeinfedOnly : Boolean;
  end;


  SPTFile = class(TFunctionBlock)
  private
      FuncStackItems :array[0..SPT_MAX_FUNCTION] of TFunctionBlock;
      FuncStackCount :Integer;
  public
      Header    :TSPTHeader;
      FuncList  : array of TUserFuncRec;
      FuncNames : array of string;
      constructor Create(Max:Integer);overload;
      destructor  Free;overload;
      function    CurrFunc: TFunctionBlock;
      function    GetFuncCount :Integer;
      procedure   Clear;overload;
      procedure   DefHeader;
      procedure   SaveAs(FileName:string);
      procedure   LoadFrom(FileName:string);
      procedure   MergeFunctions;
      function    NewFunction(Index: Integer): Integer;
      function    AddFuncDeclare(Name: string): Integer;
      function    FindFuncByName(Name: string): Integer;
  end;


  function CopySPTFile(Source: SPTFile): SPTFile;


implementation

function CopySPTFile(Source: SPTFile): SPTFile;
var
  ns: SptFile;
begin
  ns := SPTFile.Create(Source.Len + 10);
  ns.Header := Source.Header;
  ns.Len:=Source.Len;
  System.Move(Source.Data^, ns.Data^, Source.Len);
  CopySPTFile := ns;
end;

{ STPFile }

procedure TFunctionBlock.Clear;
begin
  Len:=0;
  Position:=0;
end;

constructor TFunctionBlock.Create(Max: Integer);
begin
  MaxLen:=Max;
  IsMain:=True;
  GetMem(Data,MaxLen);
  Clear;
end;

function TFunctionBlock.EOF: Boolean;
begin
  EOF:=(Len<=Position);
end;

destructor TFunctionBlock.Free;
begin
  FreeMem(Data,MaxLen);
end;

function TFunctionBlock.ReadString: string;
var
  sLen:Byte;
  r:string[255];
begin
  sLen:=ReadByte;
  if sLen+Position>Len then sLen:=Len-Position;
  System.Move(Data^[Position-1],r,sLen+1);
  Inc(Position,SLen);
  ReadString:=r;
end;

function TFunctionBlock.ReadByte: Byte;
begin
  ReadByte:=Byte(Data^[Position]);
  inc(Position);
end;

function TFunctionBlock.ReadLong: Longint;
begin
  //System.Move(Data^[Position],R,4);
  ReadLong := (PLong(@Data^[Position]))^;
  inc(Position,4);
end;

function TFunctionBlock.ReadSmall: Smallint;
begin
    //System.Move(Data^[Position],R,2);
    ReadSmall := (PSmall(@Data^[Position]))^;
    inc(Position,2);
end;

procedure TFunctionBlock.WriteByte(x: Byte);
begin
  Data^[Position]:=x;
  Inc(Position);
  if Len<Position then Len:=Position;
end;

procedure TFunctionBlock.WriteLong(x: Longint);
begin
  System.Move(x,Data^[Position],sizeof(Longint));
  Inc(Position,4);
  if Len<Position then Len:=Position;
end;

procedure TFunctionBlock.WriteSmall(x: Smallint);
begin
  System.Move(x,Data^[Position],sizeof(Smallint));
  Inc(Position,2);
  if Len<Position then Len:=Position;
end;

procedure TFunctionBlock.WriteString(x: string);
var
  r:string[255];
begin
  r:=x;
  System.Move(r,Data^[Position],Length(r)+1);
  inc(Position,Length(r)+1);
  if Len<Position then Len:=Position;
end;

function TFunctionBlock.ReadFloat: Double;
begin
  ReadFloat := (PDouble(@Data^[Position]))^;
  Inc(Position,SizeOf(Double));
end;

procedure TFunctionBlock.WriteFloat(x: Double);
begin
  System.Move(x,Data^[Position],sizeof(Double));
  Inc(Position,SizeOf(Double));
  if Len<Position then Len:=Position;
end;

function TFunctionBlock.ReadBoolean: Boolean;
begin
  ReadBoolean := (PBoolean(@Data^[Position]))^;
  Inc(Position,SizeOf(Boolean));
end;

procedure TFunctionBlock.WriteBoolean(x: Boolean);
begin
  System.Move(x,Data^[Position],sizeof(Boolean));
  Inc(Position,SizeOf(Boolean));
  if Len<Position then Len:=Position;
end;

{ TSPTFile }

procedure SPTFile.LoadFrom(FileName: string);
var
  f: file;
  Fc, Start, Temp: Integer;
begin
  AssignFile(f,FileName);
{$I-}
  Reset(f,1);
{$I+}
  if IOResult <> 0 then Exit;
  Clear;
  if FileSize(f)<SizeOf(Header) then
  begin
    Header.Flag := 0;
    Exit;
  end;
  System.Seek(f,0);
  BlockRead(f, Header, SizeOf(Header));
  Fc := Header.FuncCount;
  Start := SizeOf(Header) + SizeOf(TUserFuncRec)*Fc;
  if Start > FileSize(f) then
  begin
    Header.Flag := 0;
    Exit;
  end;
  SetLength(FuncList, Fc);
  BlockRead(f, FuncList[0], SizeOf(TUserFuncRec) * Fc);

  BlockRead(f, Temp, SizeOf(SPT_CODE_BEGIN_MARK));

  Len := Header.Len;
  if Header.Flag <> SPT_FILE_FLAG then Exit;
  if Len + Start > FileSize(f) then
        Len :=FileSize(f) - Start;

  BlockRead(f,Data^,Len);
  CloseFile(f);
end;

procedure SPTFile.SaveAs(FileName: string);
var
  f:file;
  Temp: Cardinal;
begin
  AssignFile(f, FileName);
  ReWrite(f, 1);
  System.Seek(f, 0);
  BlockWrite(f, Header, SizeOf(Header));
  BlockWrite(f, FuncList[0], SizeOf(TUserFuncRec) * Header.FuncCount);
  Temp := SPT_CODE_BEGIN_MARK;
  BlockWrite(f, Temp, SizeOf(SPT_CODE_BEGIN_MARK));

  BlockWrite(f, Data^,Len);
  CloseFile(f);
end;

procedure SPTFile.DefHeader;
begin
  with Header do
  begin
    Flag := SPT_FILE_FLAG;
    Version := SPT_THIS_VERSION;
    Len := Self.Len;
    FillChar(Reserve, SizeOf(Reserve), 0);
  end;
end;

constructor SPTFile.Create(Max: Integer);
begin
  inherited;
  FuncStackCount := 0;
  Header.FuncCount := 0;
//  WriteByte(CMD_GOTO);
//  WriteLong(-5);
end;

procedure SPTFile.MergeFunctions;
var
  I: Integer;
  Func: TFunctionBlock;
begin
  if FuncStackCount >0 then
  begin
    Func := FuncStackItems[FuncStackCount - 1];
    System.Move(Func.Data^[0],     //first copy code data
                Data^[Position],
                Func.Len);

    I := Func.FuncIndex;

    FuncList[I].Address := Position;
    if Func.IsMain then Header.StartIndex := I;
    Inc(Position, Func.Len);
    Inc(Len, Func.Len);
    Func.Free;
    Dec(FuncStackCount);
  end;
end;

function SPTFile.NewFunction(Index: Integer): Integer;
var
  Func: TFunctionBlock;
begin
  if (FuncStackCount > SPT_MAX_FUNCTION)
     or (Index < 0) or (Index > Header.FuncCount) then
  begin
    Result := -1;
  end else begin
    FuncStackItems[FuncStackCount] := TFunctionBlock.Create(SPT_FUNC_BUF_LEN);
    Func := FuncStackItems[FuncStackCount];
    Func.FuncIndex := Index;
    if FuncStackCount = 0 then
       Func.IsMain := True
    else
       Func.IsMain := False;

    FuncList[Index].DeinfedOnly := False;

    Result := FuncStackCount;
    Inc(FuncStackCount);
  end;
end;

procedure SPTFile.Clear;
begin
  while FuncStackCount > 0 do
  begin
    FuncStackItems[FuncStackCount - 1].Free;
    Dec(FuncStackCount);
  end;
  inherited;
end;

destructor SPTFile.Free;
begin
  Clear;
  inherited;
end;

function SPTFile.CurrFunc: TFunctionBlock;
begin
  Result := FuncStackItems[FuncStackCount - 1];
end;

function SPTFile.GetFuncCount: Integer;
begin
  Result := Header.FuncCount;
end;

function SPTFile.AddFuncDeclare(Name: string): Integer;
begin
  Inc(Header.FuncCount);
  SetLength(FuncList, Header.FuncCount);
  SetLength(FuncNames, Header.FuncCount);
  with FuncList[Header.FuncCount - 1] do
  begin
    Address := 0;
    LoacalSize := 10;
    DeinfedOnly := True;
  end;
  FuncNames[Header.FuncCount - 1] := Name;
  Result := Header.FuncCount - 1;
end;

function SPTFile.FindFuncByName(Name: string): Integer;
var
  I : Integer;
begin
  for I := 0 to Header.FuncCount - 1 do
  begin
    if FuncNames[I] = Name then
    begin
      Result := I;
      Exit;
    end;
  end;
  Result := -1;
end;


function TFunctionBlock.ReadCmd: TCmdType;
begin
  Result := TCmdType(ReadByte);
end;

procedure TFunctionBlock.WriteCmd(x: TCmdType);
begin
  WriteByte(Ord(x));
end;

end.
