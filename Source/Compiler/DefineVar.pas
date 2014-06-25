unit DefineVar;
interface
uses
  SysUtils, SptConst, Classes;

type
  TIdTable=class
     Count:Integer;
     Name:array[0..255] of string;
     constructor Create;
     procedure Clear;
     function Find(v:string):Integer;
     procedure Add(v:string);
     procedure AddSpec(v:string;i:integer);
  end;

  TConstTable=class
  private
     Names: TStringList;
     Values: TStringList;
  public
     constructor Create;
     destructor  Free;
     function    Find( v:string ): Integer;
     procedure   Clear;
     procedure   Add( v:string; n:string);
     function   GetValue(I: Integer): string;
  end;

  function IdentifierIsVarname(Id:string): Boolean;
  function VarId(s:string): Integer;

var
   localvars,                  //函数内的局部变量
   privars,                    //私有变量
   pubvars,                    //公有变量
   sysvars                     //系统变量
   : TIdTable;
   consts: TConstTable;

implementation

function IdentifierIsVarname(Id:string):Boolean;
var i:integer;
begin
  IdentifierIsVarname:=False;
  if (id='') or not(id[1] in ['_','a'..'z','A'..'Z'])then Exit;
  for i:=2 to length(Id) do
    if not(id[i] in ['-','a'..'z','A'..'Z','0'..'9']) then Exit;
  IdentifierIsVarname:=True;
end;


procedure InitSysVars;
begin
  with SysVars do begin
     AddSpec('_Verson',       SYS_VERSION);
     AddSpec('_Timer',        SYS_TIMER);
     AddSpec('_Level',        SYS_LEVEL);
     AddSpec('_VMType',       SYS_VMTYPE);
  end;
end;

function VarId(s:string):integer;
var r:integer;
begin
  VarId:=-1;
  if s='' then exit;
  r:=pubvars.Find(s);
  if r<0 then
  begin
    r:=privars.Find(s);
    if r>=0 then
      inc(r,$0100)
    else begin
      r:=Sysvars.Find(s);
      if r>=0 then inc(r,$0200)
      else begin
        r:=Localvars.Find(s);
        if r>=0 then inc(r,$0300);
      end;
    end;
  end;
  VarID:=r;
end;

procedure TIdTable.Clear;
var i:integer;
  begin
     Count:=0;
     for i:=0 to 255 do Name[i]:='';
end;

function TIdTable.Find(v:string):Integer;
var i:integer;
begin
    Find:=-1;
    if v='' then Exit;
    for i:=0 to 255 do
       if v=Name[i] then
         begin Find:=i;exit;end;
end;

procedure TIdTable.Add(v:string);
begin
  inc(Count);
  Name[Count]:=v;
end;

procedure TIdTable.AddSpec(v:string;i:integer);
begin
  Name[i]:=v;
end;

constructor TIdTable.Create;
begin
 Clear;
end;

{ TConstTable }

procedure TConstTable.Add(v: string; n:string);
var
  I: Integer;
begin
  I := Names.Add(v);
  Values.Insert(I, n);
end;

procedure TConstTable.Clear;
begin
  Names.Clear;
  Values.Clear;
end;

constructor TConstTable.Create;
begin
  Names := TStringList.Create;
  Names.Sorted := True;
  Values := TStringList.Create;
end;

function TConstTable.Find(v: string): Integer;
begin
  if Names.Find(v, Result) = False then Result := -1;
end;

destructor TConstTable.Free;
begin
  Names.Free;
  Values.Free;
end;

function TConstTable.GetValue(I: Integer): string;
begin
  if (I >=0) and (I < Values.Count) then
    Result := Values.Strings[I]
  else
    Result := '';
end;

initialization
  Consts := TConstTable.Create;
  Localvars := TIdTable.Create;
  Privars:=TIdTable.Create;
  Pubvars:=TIdTable.Create;
  Sysvars:=TIdTable.Create;
  InitSysVars;
finalization
  Consts.Free;
  Localvars.Free;
  Privars.Free;
  Pubvars.Free;
  Sysvars.Free;
end.
