unit SptFunc;

interface

uses SptConst, StackUnit;

const
//   MAX_LABEL    = 255;
//   MAX_GOTO     = 1000;

    FUNC_NULL = 0;             //System Functions
    FUNC_TYPE = 1;
    FUNC_VAR  = 2;
    FUNC_CALLAT    = 3;

    FUNC_ADDTIMER  = 8;
    FUNC_DELTIMER  = 9;
    FUNC_FINDTIMER = 10;
    FUNC_NEWARRAY  = 11;
    FUNC_RESIZE    = 12;
    FUNC_LEN       = 13;

    FUNC_ASC       = 14;
    FUNC_CHR       = 15;

    FUNC_RND       = 18;
    FUNC_SIN       = 19;
    FUNC_COS       = 20;
    FUNC_ATAN      = 21;
    FUNC_LN        = 22;
    FUNC_EXP       = 23;
    FUNC_SQRT      = 24;

    FUNC_STRPOS    = 30;
    FUNC_STRSUB    = 31;
    FUNC_STRDEL    = 32;
    FUNC_STRINSERT = 33;

    FUNC_MSGBOX    = 43;
    FUNC_READKEY   = 44;
    FUNC_SENDMESSAGE = 45;

    FUNC_WRITE     = 51;
    FUNC_WRITELN   = 52;
    FUNC_READINT   = 53;
    FUNC_READFLOAT = 54;
    FUNC_READSTRING= 55;

    FUNC_SETTEXT     = 80;
    FUNC_GETTEXT     = 81;
    FUNC_GETENABLED  = 82;
    FUNC_SETENABLED  = 83;
    FUNC_GETVISIBLE  = 84;
    FUNC_SETVISIBLE  = 85;
    FUNC_GETHANDLE   = 86;
    FUNC_SETSIZE     = 87;
    FUNC_SETPOS      = 88;

    FUNC_DELOBJECT   = 89;
    FUNC_ADDSTATIC   = 90;
    FUNC_ADDBUTTON   = 91;
    FUNC_ADDEDIT     = 92;
    FUNC_ADDCOMBOBOX = 93;
    FUNC_ADDCHECKBOX = 94;
    FUNC_ADDRADIOBOX = 95;
    FUNC_ADDLISTBOX  = 96;
    FUNC_ADDPANEL    = 97;

    FUNC_SETEVENT    = 100;
    FUNC_SETSTYLE = 101;
    FUNC_GETSTYLE = 102;
    FUNC_SETALIGN = 103;

    FUNC_TEXTOUT  = 110;
    FUNC_DRAWBOX  = 111;

    MAX_SYS_FUNC   = 128;

type

   TFuncDef = record
        Fun_No      : Integer;
        Name        : string;
        ParamCount  : Integer;
        ReturnValue : Boolean;
        IsSys       : Boolean;
        ByCompiler  : Boolean;
        ParamType   : array[0..10] of TVarType;

   end;


const
    MAX_USER_FUNC = 255;

var
    UserFuncTable: array[0..MAX_USER_FUNC] of TFuncDef;
    SysFuncTable: array[0..MAX_SYS_FUNC] of TFuncDef;
    UserFuncCount :Integer = 0;

function FindSystemFunction(Name: string): Integer;
function FindUserFunction(Name: string): Integer; overload;
function FindUserFunction(Id: Integer): Integer; overload;

implementation

function FindSystemFunction(Name: string): Integer;
var
  I: Integer;
begin
  for I := 0 to MAX_SYS_FUNC do
  begin
    if Name = SysFuncTable[I].Name then
    begin
      Result := I;
      Exit;
    end;
  end;
  Result := -1;
end;

function FindUserFunction(Name: string): Integer;
var
  I: Integer;
begin
  for I := 0 to UserFuncCount - 1 do
  begin
    if Name = UserFuncTable[I].Name then
    begin
      Result := I;
      Exit;
    end;
  end;
  Result := -1;
end;

function FindUserFunction(Id: Integer): Integer;
var
  I: Integer;
begin
  for I := 0 to UserFuncCount - 1 do
  begin
    if Id = UserFuncTable[I].Fun_No then
    begin
      Result := I;
      Exit;
    end;
  end;
  Result := -1;
end;

///////////////控制台专用函数////////////////
procedure InitConsoleFunctions;
begin
  //ReadKey(boolean)
  with SysFuncTable[FUNC_READKEY] do
  begin
    Name := 'ReadKey';
    ParamCount := 1;
    ParamType[0] := VT_BOOL;
  end;

  //Write(...)
  with SysFuncTable[FUNC_WRITE] do
  begin
    Name := 'Write';
    ParamCount := -1;
  end;
  //Writeln(...)
  with SysFuncTable[FUNC_WRITELN] do
  begin
    Name := 'Writeln';
    ParamCount := -1;
  end;
  //ReadInt()
  with SysFuncTable[FUNC_READINT] do
  begin
    Name := 'ReadInt';
    ParamCount := 0;
  end;
  //ReadFloat()
  with SysFuncTable[FUNC_READFLOAT] do
  begin
    Name := 'ReadFloat';
    ParamCount := 0;
  end;
  //ReadString()
  with SysFuncTable[FUNC_READSTRING] do
  begin
    Name := 'ReadString';
    ParamCount := 0;
  end;

end;

{------- Windows版专用 --------}
procedure InitWinFunctions;
begin

  //SetText(int, string)
  with SysFuncTable[FUNC_SETTEXT] do
  begin
    Name := 'SetText';
    ParamCount := 2;
    ParamType[0] := VT_INT;
    ParamType[1] := VT_STR;
  end;
  //GetText(int)
  with SysFuncTable[FUNC_GETTEXT] do
  begin
    Name := 'GetText';
    ParamCount := 1;
    ParamType[0] := VT_INT;
  end;
  //SetEnabled(int, string)
  with SysFuncTable[FUNC_SETENABLED] do
  begin
    Name := 'SetEnabled';
    ParamCount := 2;
    ParamType[0] := VT_INT;
    ParamType[1] := VT_STR;
  end;
  //GetEnabled(int)
  with SysFuncTable[FUNC_GETENABLED] do
  begin
    Name := 'GetEnabled';
    ParamCount := 1;
    ParamType[0] := VT_INT;
  end;
  //SetVisible(int, string)
  with SysFuncTable[FUNC_SETVISIBLE] do
  begin
    Name := 'SetVisible';
    ParamCount := 2;
    ParamType[0] := VT_INT;
    ParamType[1] := VT_STR;
  end;
  //GetVisible(int)
  with SysFuncTable[FUNC_GETVISIBLE] do
  begin
    Name := 'GetVisible';
    ParamCount := 1;
    ParamType[0] := VT_INT;
  end;
  //GetHandle(int)
  with SysFuncTable[FUNC_GETHANDLE] do
  begin
    Name := 'GetHandle';
    ParamCount := 1;
    ParamType[0] := VT_INT;
  end;
  //SetSize(int, int, int)
  with SysFuncTable[FUNC_SETSIZE] do
  begin
    Name := 'SetSize';
    ParamCount := 3;
    ParamType[0] := VT_INT;
    ParamType[1] := VT_INT;
    ParamType[2] := VT_INT;
  end;
  //SetPos(int, int, int)
  with SysFuncTable[FUNC_SETPOS] do
  begin
    Name := 'SetPos';
    ParamCount := 3;
    ParamType[0] := VT_INT;
    ParamType[1] := VT_INT;
    ParamType[2] := VT_INT;
  end;
  //DelObject(int)
  with SysFuncTable[FUNC_DELOBJECT] do
  begin
    Name := 'DelObject';
    ParamCount := 1;
    ParamType[0] := VT_INT;
  end;
  //AddStatic(int, string, int, int)
  with SysFuncTable[FUNC_ADDSTATIC] do
  begin
    Name := 'AddStatic';
    ParamCount := 6;
    ParamType[0] := VT_INT;
    ParamType[1] := VT_STR;
    ParamType[2] := VT_INT;
    ParamType[3] := VT_INT;
    ParamType[4] := VT_INT;
    ParamType[5] := VT_INT;
  end;
  //AddButton(int, string, int, int, int, int)
  with SysFuncTable[FUNC_ADDBUTTON] do
  begin
    Name := 'AddButton';
    ParamCount := 6;
    ParamType[0] := VT_INT;
    ParamType[1] := VT_STR;
    ParamType[2] := VT_INT;
    ParamType[3] := VT_INT;
    ParamType[4] := VT_INT;
    ParamType[5] := VT_INT;
  end;
  //AddEdit(int, string, int, int, int, int)
  with SysFuncTable[FUNC_ADDEDIT] do
  begin
    Name := 'AddEdit';
    ParamCount := 6;
    ParamType[0] := VT_INT;
    ParamType[1] := VT_STR;
    ParamType[2] := VT_INT;
    ParamType[3] := VT_INT;
    ParamType[4] := VT_INT;
    ParamType[5] := VT_INT;
  end;
  //AddListBox(int, string, int, int, int, int)
  with SysFuncTable[FUNC_ADDLISTBOX] do
  begin
    Name := 'AddListBox';
    ParamCount := 6;
    ParamType[0] := VT_INT;
    ParamType[1] := VT_STR;
    ParamType[2] := VT_INT;
    ParamType[3] := VT_INT;
    ParamType[4] := VT_INT;
    ParamType[5] := VT_INT;
  end;
  //AddPanel(int, string, int, int, int, int)
  with SysFuncTable[FUNC_ADDPANEL] do
  begin
    Name := 'AddPanel';
    ParamCount := 6;
    ParamType[0] := VT_INT;
    ParamType[1] := VT_STR;
    ParamType[2] := VT_INT;
    ParamType[3] := VT_INT;
    ParamType[4] := VT_INT;
    ParamType[5] := VT_INT;
  end;
  //AddCheckBox(int, string, int, int, int, int, bool)
  with SysFuncTable[FUNC_ADDCHECKBOX] do
  begin
    Name := 'AddCheckBox';
    ParamCount := 7;
    ParamType[0] := VT_INT;
    ParamType[1] := VT_STR;
    ParamType[2] := VT_INT;
    ParamType[3] := VT_INT;
    ParamType[4] := VT_INT;
    ParamType[5] := VT_INT;
    ParamType[6] := VT_BOOL;
  end;
  //AddRadioBox(int, string, int, int, int, int, bool)
  with SysFuncTable[FUNC_ADDRADIOBOX] do
  begin
    Name := 'AddRadioBox';
    ParamCount := 7;
    ParamType[0] := VT_INT;
    ParamType[1] := VT_STR;
    ParamType[2] := VT_INT;
    ParamType[3] := VT_INT;
    ParamType[4] := VT_INT;
    ParamType[5] := VT_INT;
    ParamType[6] := VT_BOOL;
  end;
  //AddComboBox(int, string, int, int, int, int, bool)
  with SysFuncTable[FUNC_ADDCOMBOBOX] do
  begin
    Name := 'AddComboBox';
    ParamCount := 7;
    ParamType[0] := VT_INT;
    ParamType[1] := VT_STR;
    ParamType[2] := VT_INT;
    ParamType[3] := VT_INT;
    ParamType[4] := VT_INT;
    ParamType[5] := VT_INT;
    ParamType[6] := VT_BOOL;
  end;
  //SetEvent(int, int, int)
  with SysFuncTable[FUNC_SETEVENT] do
  begin
    Name := 'SetEvent';
    ParamCount := 3;
    ParamType[0] := VT_INT;
    ParamType[1] := VT_INT;
    ParamType[2] := VT_INT;
  end;
  //SetStyle(int, int, bool)
  with SysFuncTable[FUNC_SETSTYLE] do
  begin
    Name := 'SetStyle';
    ParamCount := 3;
    ParamType[0] := VT_INT;
    ParamType[1] := VT_INT;
    ParamType[2] := VT_BOOL;
  end;
  //GetStyle(int, bool)
  with SysFuncTable[FUNC_GETSTYLE] do
  begin
    Name := 'GetStyle';
    ParamCount := 2;
    ParamType[0] := VT_INT;
    ParamType[1] := VT_BOOL;
  end;
  //SetAlign(int, int)
  with SysFuncTable[FUNC_SETALIGN] do
  begin
    Name := 'SetAlign';
    ParamCount := 2;
    ParamType[0] := VT_INT;
    ParamType[1] := VT_INT;
  end;
  //TextOut(int, int, int, string)
  with SysFuncTable[FUNC_TEXTOUT] do
  begin
    Name := 'TextOut';
    ParamCount := 4;
    ParamType[0] := VT_INT;
    ParamType[1] := VT_INT;
    ParamType[2] := VT_INT;
    ParamType[3] := VT_STR;
  end;
  //DrawBox(int, int, int, int)
  with SysFuncTable[FUNC_DRAWBOX] do
  begin
    Name := 'DrawBox';
    ParamCount := 6;
    ParamType[0] := VT_INT;
    ParamType[1] := VT_INT;
    ParamType[2] := VT_INT;
    ParamType[3] := VT_INT;
    ParamType[4] := VT_INT;
    ParamType[5] := VT_BOOL;
  end;
end;
//////////////////////////////////////////////
//公共系统函数
//////////////////////////////////////////////
procedure InitSystemFunctions;
var
  I: Integer;
begin
  for I := 0 to MAX_SYS_FUNC do
  begin
    with SysFuncTable[I] do
    begin
      Fun_No     := I;
      Name        := '!Reserved';
      ParamCount  := 0;
      ReturnValue := True;
      IsSys       := True;
      ByCompiler  := False;
    end;
  end;
  //__Null()
  with SysFuncTable[FUNC_NULL] do
  begin
    Name := '__Null';
    ParamCount := 0;
  end;
  //Type(any)
  with SysFuncTable[FUNC_TYPE] do
  begin
    Name := 'Type';
    ParamCount := 1;
    ParamType[0] := VT_ANY;
  end;
  //VarAtAddr(int)
  with SysFuncTable[FUNC_VAR] do
  begin
    Name := 'VarAtAddr';
    ParamCount := 1;
    ParamType[0] := VT_INT;
  end;
  //CallAt(int) compiler managed
  with SysFuncTable[FUNC_CALLAT] do
  begin
    Name := 'CallAt';
    ParamCount := 1;
    ParamType[0] := VT_INT;
    ByCompiler := True;
  end;
  //AddTimer(string, int)
  with SysFuncTable[FUNC_ADDTIMER] do
  begin
    Name := 'AddTimer';
    ParamCount := 2;
    ParamType[0] := VT_STR;
    ParamType[1] := VT_INT;
  end;
  //DelTimer(int)
  with SysFuncTable[FUNC_DELTIMER] do
  begin
    Name := 'DelTimer';
    ParamCount := 1;
    ParamType[1] := VT_INT;
  end;
  //FindTimer(string)
  with SysFuncTable[FUNC_FINDTIMER] do
  begin
    Name := 'FindTimer';
    ParamCount := 1;
    ParamType[1] := VT_STR;
  end;
  //NewArray(int)
  with SysFuncTable[FUNC_NEWARRAY] do
  begin
    Name := 'NewArray';
    ParamCount := 1;
    ParamType[0] := VT_INT;
  end;
  //Resize(array, int)
  with SysFuncTable[FUNC_RESIZE] do
  begin
    Name := 'Resize';
    ParamCount := 2;
    ParamType[0] := VT_ARRAY;
    ParamType[1] := VT_INT;
  end;
  //Len(any)
  with SysFuncTable[FUNC_LEN] do
  begin
    Name := 'Len';
    ParamCount := 1;
    ParamType[0] := VT_ANY;
  end;
  //Asc(string)
  with SysFuncTable[FUNC_ASC] do
  begin
    Name := 'Asc';
    ParamCount := 1;
    ParamType[0] := VT_STR;
  end;
  //Asc(int)
  with SysFuncTable[FUNC_CHR] do
  begin
    Name := 'Chr';
    ParamCount := 1;
    ParamType[0] := VT_INT;
  end;
  //Random(int)
  with SysFuncTable[FUNC_RND] do
  begin
    Name := 'Random';
    ParamCount := 1;
    ParamType[0] := VT_INT;
  end;
  //Sin(float)
  with SysFuncTable[FUNC_SIN] do
  begin
    Name := 'Sin';
    ParamCount := 1;
    ParamType[0] := VT_FLOAT;
  end;
  //Cos(float)
  with SysFuncTable[FUNC_COS] do
  begin
    Name := 'Cos';
    ParamCount := 1;
    ParamType[0] := VT_FLOAT;
  end;
  //ArcTan(float)
  with SysFuncTable[FUNC_ATAN] do
  begin
    Name := 'ArcTan';
    ParamCount := 1;
    ParamType[0] := VT_FLOAT;
  end;
  //Ln(float)
  with SysFuncTable[FUNC_LN] do
  begin
    Name := 'Ln';
    ParamCount := 1;
    ParamType[0] := VT_FLOAT;
  end;
  //Exp(float)
  with SysFuncTable[FUNC_EXP] do
  begin
    Name := 'Exp';
    ParamCount := 1;
    ParamType[0] := VT_FLOAT;
  end;
  //Sqrt(float)
  with SysFuncTable[FUNC_SQRT] do
  begin
    Name := 'Sqrt';
    ParamCount := 1;
    ParamType[0] := VT_FLOAT;
  end;
  //StrPos(string, string, int)
  with SysFuncTable[FUNC_STRPOS] do
  begin
    Name := 'StrPos';
    ParamCount := 3;
    ParamType[0] := VT_STR;
    ParamType[1] := VT_STR;
    ParamType[2] := VT_INT;
  end;
  //StrSub(string, int, int)
  with SysFuncTable[FUNC_STRSUB] do
  begin
    Name := 'StrSub';
    ParamCount := 3;
    ParamType[0] := VT_STR;
    ParamType[1] := VT_INT;
    ParamType[2] := VT_INT;
  end;
  //StrDel(string, int, int)
  with SysFuncTable[FUNC_STRDEL] do
  begin
    Name := 'StrDel';
    ParamCount := 3;
    ParamType[0] := VT_STR;
    ParamType[1] := VT_INT;
    ParamType[2] := VT_INT;
  end;
  //StrInsert(string, string, int)
  with SysFuncTable[FUNC_STRINSERT] do
  begin
    Name := 'StrInsert';
    ParamCount := 3;
    ParamType[0] := VT_STR;
    ParamType[1] := VT_STR;
    ParamType[2] := VT_INT;
  end;
  //MsgBox(string, string, int)
  with SysFuncTable[FUNC_MSGBOX] do
  begin
    Name := 'MsgBox';
    ParamCount := 3;
    ParamType[0] := VT_STR;
    ParamType[1] := VT_STR;
    ParamType[2] := VT_INT;
  end;
  //SendMessage(int, int, int, int)
  with SysFuncTable[FUNC_SENDMESSAGE] do
  begin
    Name := 'SendMessage';
    ParamCount := 4;
    ParamType[0] := VT_INT;
    ParamType[1] := VT_INT;
    ParamType[2] := VT_INT;
    ParamType[3] := VT_INT;
  end;
  InitConsoleFunctions;
  InitWinFunctions;


end;

initialization
  InitSystemFunctions;
end.
