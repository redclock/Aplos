(**********************************************
     Aplos脚本运行单元
     姚春晖   编写
     版权所有  2003.5
 **********************************************)
unit Script;

interface
uses
   Windows,
   SysUtils,
   SptBin ,
   SptConst,
   StackUnit,
   SptFunc,
   Oper,
   Math,
{$IFDEF APLOS_CONSOLE}
   Keyboard,
{$ENDIF}
{$IFDEF APLOS_WIN}
   SptCtrl,
{$ENDIF}
   FastStr
   ;
type
    TLocalManager = class;
    TGCVarStack   = class;
    TVarArray     = array of TVar;
    { 脚本运行时的类 }
    TScript=class
    private
      Level     : Byte;        { 在脚本调用栈的位置 }
      Counter   : Integer;     { 计时器 }
      SptRun    : SptFile;     { 被执行脚本的二进制文件 }
      NextScript: TScript;     { 子脚本 }
      Parent    : TScript;     { 父脚本 }
      Err       :Boolean;      { 是否出错 }
      procedure Calc(op: Byte);{ 一个运算符 }
      function  ExecFunction(fid: Byte): TVar;    { 执行系统函数 }
{$IFDEF APLOS_CONSOLE}
      function  ExecConFunction(fid: Byte; P: TVarArray; n: Integer): TVar;    { 执行系统控制台函数 }
{$ENDIF}
{$IFDEF APLOS_WIN}
      function  ExecWinFunction(fid: Byte; P: TVarArray; n: Integer): TVar;    { 执行系统窗口函数 }
{$ENDIF}
      procedure LetArrCmd;                            { 为数组赋值的命令 }
    public
      Vars      : array[0..255] of TVar;   { 私有变量 }
      NumStack  : TGCVarStack;             { 数字栈   }
//      OprStack,                          { 操作符栈 }
      AddrStack : TStack;                  { 地址栈   }
      LocalManager: TLocalManager;
      Locking   : Boolean;     { 是否被锁定 }
      Waiting   : Boolean;     { 是否在等待 }
      Running   : Boolean;     { 是否正在运行 }
      LastOpr   : TCmdType;        { 上一指令 }
      function ExecuteOne(LagCount:Integer):TCmdType;  { 执行一条指令 }
      function GetTop: TScript;
      procedure Restart;                           { 从头执行 }
      procedure Run(LagCount:Integer);             { 运行 }
      procedure Error(s: string);                  { 出错 }
      constructor Create(P:TScript;SB:SptFile);overload;
      constructor Create(P:TScript;FileName:string);overload;
      destructor  Free;
    end;

    TScriptThread = class
    private
      Root: TScript;
      NumStack  : TGCVarStack ;            { 数字栈   }
//      OprStack,                          { 操作符栈 }
      AddrStack : TStack;                  { 地址栈   }
    public
      Running   : Boolean;
      constructor Create(RootScript: SPTFile); overload;
      constructor Create(RootScriptFile: string); overload;
      function    GetTop: TScript;
      procedure   Run(LagCount: Integer);
      destructor  Free;
    end;

    TScheduleItem = record
       ID       : Integer;
       Spt      : string;
       StartTime: Integer;
    end;

    TScheduleList = class
    private
       Items: array of TScheduleItem;
       Count: Integer;
       Capacity: Integer;
    public
       constructor Create;
       function GetCount: Integer;
       function Add(FileName: string; Time: Integer): Integer;
       function Find(FileName: string): Integer;
       procedure Delete(ID: Integer);
       procedure Clear;
       procedure Update;
    end;

    TArrayType = array of TVar;

    TArrayManager = class
    private
       Count: Integer;
       Capacity: Integer;
       Used: array of Boolean;
       Ref: array of Integer;
       NeedCollectCount: Integer;
    public
       Items: array of TArrayType;
       constructor Create;
       function    AvailableID(ID: Integer): Boolean;
       function    GetCount: Integer;
       function    GetBound(ID: Integer): Integer;
       procedure   Resize(ID: Integer; NewSize: Integer);
       function    Add(Capa: Integer): Integer;
       procedure   Delete(ID: Integer);
       procedure   AddRef(ID: Integer; n: Integer);
       procedure   CollectCarbage;
       procedure   Clear;
       destructor  Free;
    end;

    TLocalManager = class
    private
       Count: Integer;
       FScript: TScript;
       BaseStack: TStack;
       procedure Extend(ToLen: Integer);
    public
       Items: array of TVar;
       constructor Create(Owner: TScript);
       function GetValue(id: Integer): TVar;
       function GetVarRef(id: Integer): PVar;
       procedure SetValue(id: Integer; v: TVar);
       procedure NewFrame(Len: Integer);
       procedure PopFrame;
       procedure   Clear;
       destructor  Free;
    end;

    TGCVarStack = class(TVarStack)
      procedure Push(n: TVar); override;
      function Pop: TVar; override;
    end;
const
   MAX_THREAD = 100;
var
   ErrStr:string;                       { 出错信息 }

   PublicVars   : array[0..255] of TVar; { 公有变量 }
   ScriptThreads: array[0..MAX_THREAD] of TScriptThread;    { 脚本线程列表 }
   ThreadIndex  : Integer = 0;                { 当前的线程 }
   Schedule     : TScheduleList;
   ArrayManager : TArrayManager;
{$IFDEF APLOS_WIN}
   CtrlList     : TCtrlList;
{$ENDIF}
   procedure CallScript(FileName:string);overload;
   procedure CallScript(SB:SPTFile);overload;
   function CallFuntion(fid: Integer; P: array of TVar): TVar;
   procedure DoScript(LagCount:Integer);
   procedure ResetScript;
   function  IsRunning:Boolean;         { 是否正有脚本运行 }
   function  Suspended:Boolean;
   function  VarValue(id:integer): TVar;
   function CurrentScript: TScript;

implementation
var
  ThreadCount: Integer;
  FSuspend: Boolean;

function  Suspended:Boolean;
begin
  Suspended := FSuspend;
end;
function  IsRunning:Boolean;
begin
  IsRunning := ThreadCount > 0;
end;

procedure ResetScript;
var
  I: Integer;
begin
   ThreadCount := 0;
   ThreadIndex := 0;
   for I := 0 to MAX_THREAD do
   begin
     if ScriptThreads[I] <> nil then
     begin
       ScriptThreads[I].Free;
       ScriptThreads[I] := nil;
     end;
   end;
   for I := 0 to 255 do PublicVars[I] := CreateVar(0);
   Schedule.Clear;
{$IFDEF APLOS_WIN}
   CtrlList.ClearAll;
{$ENDIF}
end;

function CurrentScript: TScript;
begin
  if ScriptThreads[ThreadIndex] = nil then
  begin
    CurrentScript := nil;
  end else begin
    CurrentScript := ScriptThreads[ThreadIndex].GetTop;
  end;
end;
    
procedure CallScript(FileName:string);
var
  I, P: Integer;
begin
  P := 0;
  FSuspend := False;
  for I := 1 to MAX_THREAD do
  begin
    if ScriptThreads[I] = nil then
    begin
      P := I;
      Break;
    end;
  end;
  ScriptThreads[P] := TScriptThread.Create(FileName);
  ThreadIndex := P;
  Inc(ThreadCount);
  ScriptThreads[P].Run(0);
end;

procedure CallScript(SB:SPTFile);
var
  I, P: Integer;
begin
  P := 0;
  for I := 1 to MAX_THREAD do
  begin
    if ScriptThreads[I] = nil then
    begin
      P := I;
      Break;
    end;
  end;
  ScriptThreads[P] := TScriptThread.Create(SB);
  ThreadIndex := P;
  Inc(ThreadCount);
  ScriptThreads[P].Run(0);
end;

function CallFuntion(fid: Integer; P: array of TVar): TVar;
var
  Spt: TScript;
  I: Integer;
begin
  Result := CreateVar(0);
  Spt := CurrentScript;
  if Spt = nil then Exit;
  for I := Low(P) to High(P) do
  begin
    Spt.NumStack.Push(P[I]);
  end;
  Spt.AddrStack.Push(-1);
  Spt.LocalManager.NewFrame(10);
  Spt.SptRun.Position := Spt.SptRun.FuncList[fid].Address;
  FSuspend := False;
  while (Script.IsRunning) and (Script.Suspended = False) do
      DoScript(0);
  if (Script.IsRunning) then
  begin
    Spt := CurrentScript;
    if Spt.NumStack.P <= 0 then
      ErrStr := '数字栈下溢出'
    else
      Result := Spt.NumStack.Pop;
  end;
end;
procedure DoScript(LagCount:Integer);
var
  R, I: Integer;
begin
  R := 0;
  for I := 0 to MAX_THREAD do
  begin
    if ScriptThreads[I] <> nil then
    begin
      ThreadIndex := I;
      ScriptThreads[I].Run(LagCount);
      if ScriptThreads[I].Running then
      begin
        Inc(R);
      end else begin
        ScriptThreads[I].Free;
        ScriptThreads[I] := nil;
        Dec(ThreadCount);
      end;
    end;
    if R >= ThreadCount then Break;
  end;
  Schedule.Update;
end;

function  GetVarRef(id: Integer): PVar;
begin
  Result := nil;
  case (id and $FF00) of
    $0000: Result := @PublicVars[id];
    $0100: Result := @CurrentScript.Vars[id - $0100];
    $0200: Result := nil;
    $0300: begin
             id := id and $00FF;
             Result := CurrentScript.LocalManager.GetVarRef(id);
           end;
  end;
end;

function  VarValue(id: Integer): TVar;
begin
  VarValue:=CreateVar(0);
  case (id and $FF00) of
    $0000: VarValue:=PublicVars[id];
    $0100: VarValue:=CurrentScript.Vars[id - $0100];
    $0200: case (id and $00FF) of
             SYS_VERSION : VarValue := CreateVar(0);
             SYS_TIMER : VarValue := CreateVar(GetTickCount);
             SYS_LEVEL : VarValue := CreateVar(CurrentScript.Level);
             {$IFDEF APLOS_CONSOLE}
             SYS_VMTYPE : VarValue := CreateVar(1);
             {$ENDIF}
             {$IFDEF APLOS_WIN}
             SYS_VMTYPE : VarValue := CreateVar(2);
             {$ENDIF}
            end;
    $0300: begin
             id := id and $00FF;
             VarValue := CurrentScript.LocalManager.GetValue(id);
           end;
  end;
end;

procedure SetVar(id:integer; Value:TVar);

var
  OldVar: TVar;
  IsSystem: Boolean;
begin
  IsSystem := False;
  case (id and $FF00) of
    $0000: begin
       OldVar := PublicVars[id];
       PublicVars[id] := Value;
    end;
    $0100:
    begin
      OldVar := CurrentScript.Vars[id - $0100];
      CurrentScript.Vars[id - $0100]:=Value;
    end;
    $0200:begin

       IsSystem := True;
     end;
     $0300: begin
         id := id and $00FF;
         OldVar := CurrentScript.LocalManager.GetValue(id);
         CurrentScript.LocalManager.SetValue(id, Value);
       end;
  end;
  //if id <> 0 then
  begin
    if Value.VarType = VT_ARRAY then
       ArrayManager.AddRef(Value.ArrayValue, 1);
    if not( IsSystem ) and ( OldVar.VarType = VT_ARRAY ) then
    begin
      ArrayManager.AddRef(OldVar.ArrayValue, -1);
    end;
  end;
end;



procedure WriteVar(v: TVar);
var
  I : Integer;
begin
  case v.VarType of
    VT_INT: Write(v.IntValue);
    VT_FLOAT: Write(FloatToStr(v.FloatValue));
    VT_STR: Write(v.StrValue);
    VT_BOOL: Write(v.BoolValue);
    VT_ARRAY:
    begin
      Write('(');
      if ArrayManager.GetBound(v.ArrayValue) > 0 then
      begin
        WriteVar(ArrayManager.Items[v.ArrayValue][0]);
      end;
      for I := 1 to ArrayManager.GetBound(v.ArrayValue) - 1 do
      begin
        Write(',');
        WriteVar(ArrayManager.Items[v.ArrayValue][I]);
      end;
      Write(')');
    end;
  end
end;

{ TScript }
procedure TScript.LetArrCmd;
var
  v: TVar;
  i: Integer;
begin
  if NumStack.p >= 3 then
  begin
    if NumStack.Peek.VarType <> VT_INT  then
    begin
      Error('数组下标不是整型');
      Exit;
    end;
    i := NumStack.Pop.IntValue;
    v := NumStack.Pop;

    if (v.VarType <> VT_ARRAY) or
       (not ArrayManager.AvailableID(v.ArrayValue)) then
    begin
      Error('非法数组');
      Exit;
    end;

    if (i >= ArrayManager.GetBound(v.ArrayValue))
         or (i < 0) then
    begin
      Error('下标越界');
      Exit;
    end;

    if ArrayManager.Items[v.ArrayValue][i].VarType = VT_ARRAY then
      ArrayManager.AddRef(ArrayManager.Items[v.ArrayValue][i].ArrayValue, -1);
    ArrayManager.Items[v.ArrayValue][i] := NumStack.Peek;
    if ArrayManager.Items[v.ArrayValue][i].VarType = VT_ARRAY then
      ArrayManager.AddRef(ArrayManager.Items[v.ArrayValue][i].ArrayValue, 1);
    NumStack.Pop;
  end else begin
    Error('数字栈下溢出');
    Exit;
  end;
end;


procedure TScript.Error(s: string);
begin
    Err := True;
    ErrStr := s;
    Running := False;
end;

constructor TScript.Create(P: TScript; SB:SPTFile);
begin
  SptRun:=SB;
  Parent:=p;
  if Parent=nil then
  begin
    Level := 0;
  end else begin
    Level := Parent.Level+1;
    NumStack := Parent.NumStack;
//    OprStack := Parent.OprStack;
    AddrStack:= Parent.AddrStack;
//    VarStack := Parent.VarStack;
  end;
  LocalManager := TLocalManager.Create(Self);

  NextScript := nil;

  if SptRun.Header.Flag <> SPT_FILE_FLAG then
  begin
    Error('不是合法的脚本文件!');
  end;

  if SptRun.Header.Version > SPT_THIS_VERSION then
  begin
    Error('脚本文件版本不正确!');
  end;
  if SptRun.Header.Locked then Locking := True;
  if ErrStr = '' then
  begin
    Restart;
    Running    := True;
  end;

end;

constructor TScript.Create( P: TScript; FileName: string);
begin
  SptRun:=SptFile.Create(65536);
  ErrStr:='';
  try
    SptRun.LoadFrom(FileName);
    Create(P,SptRun);
  except
    ErrStr := '无法打开文件：' + FileName;
  end;
end;


procedure TScript.Calc(op: Byte);
var
  a,b:TVar;
begin
  if op in DoubleParamOps then
  begin
     if NumStack.p>1 then begin
         b:=NumStack.Pop;
         a:=NumStack.Pop;
     end else begin
         Error('数字栈下溢出');
         Exit;
     end;
  end else begin
     if NumStack.p>0 then begin
         a:=NumStack.Pop;
         b.VarType:=VT_INT;
     end else begin
         Error('数字栈下溢出');
         Exit;
     end;
  end;
  case op of
     OPR_ADD : AddVar(a, b);
     OPR_SUB : SubVar(a, b);
     OPR_MUL : MulVar(a, b);
     OPR_DIV : DivVar(a, b);
     OPR_MOD : ModVar(a, b);
     OPR_ARR : ArrVar(a, b);
     OPR_NOT : NotVar(a);
     OPR_AND : AndVar(a, b);
     OPR_OR  : OrVar(a, b);
     OPR_XOR : XorVar(a, b);
     OPR_MORE : MoreVar(a, b);
     OPR_LESS : LessVar(a, b);
     OPR_NOMORE : NoMoreVar(a, b);
     OPR_NOLESS : NoLessVar(a, b);
     OPR_EQ  : EqVar(a, b);
     OPR_NOEQ : NoEqVar(a, b);
     OPR_NEG : NegVar(a);
     OPR_POS : ;
     OPR_TOINT  : ToVarType(a, VT_INT);
     OPR_TOFLOAT: ToVarType(a, VT_FLOAT);
     OPR_TOSTR  : ToVarType(a, VT_STR);
     OPR_TOBOOL : ToVarType(a, VT_BOOL);

  end;
  if ErrStr <> '' then
  begin
    Error(ErrStr);
  end;  
  NumStack.Push(a);
end;

function TScript.ExecuteOne(LagCount:Integer): TCmdType;
var
  Cmd: TCmdType;
  sn: Smallint;
  ln: Longint;
  bn: Byte;
  fn: Double;
  booln: Boolean;
  strn:string;
  a: TVar;
  p: PVar;
begin
  ExecuteOne := CMD_NOP;
repeat
  if SptRun.EOF then
  begin
     Running:=False;
     Result := CMD_NOP;
     Exit;
  end;
  Cmd:=SptRun.ReadCmd;

  case Cmd of
    CMD_NOP: { Writeln('NOOP!')};
    CMD_PUSHI :begin
                 ln:=SptRun.ReadLong;
                 if NumStack.p<StackUnit.Max then
                 begin
                    a.VarType := VT_INT;
                    a.IntValue := ln;
                    NumStack.Push(a)
                 end else begin
                    Error('数字栈上溢出');
                    Exit;
                 end;
               end;
    CMD_PUSHF :begin
                 fn:=SptRun.ReadFloat;
                 if NumStack.p<StackUnit.Max then
                 begin
                    a.VarType := VT_FLOAT;
                    a.FloatValue := fn;
                    NumStack.Push(a)
                 end else begin
                    Error('数字栈上溢出');
                    Exit;
                 end;
               end;
    CMD_PUSHS :begin
                 strn:=SptRun.ReadString;
                 if NumStack.p<StackUnit.Max then
                 begin
                    a.VarType := VT_STR;
                    a.StrValue := strn;
                    NumStack.Push(a)
                 end else begin
                    Error('数字栈上溢出');
                    Exit;
                 end;
               end;
    CMD_PUSHB :begin
                 booln:=SptRun.ReadBoolean;
                 if NumStack.p<StackUnit.Max then
                 begin
                    a.VarType := VT_BOOL;
                    a.BoolValue := booln;
                    NumStack.Push(a)
                 end else begin
                    Error('数字栈上溢出');
                    Exit;
                 end;
               end;
    CMD_PUSHV :begin
                 sn:=SptRun.ReadSmall;
                 if NumStack.p<StackUnit.Max then
                    NumStack.Push(VarValue(sn))
                 else begin
                    Error('数字栈上溢出');
                    Exit;
                 end;
               end;
    CMD_POP   :begin
                 sn:=SptRun.ReadSmall;
                 if NumStack.p > 0 then
                 begin
                   if sn >= 0 then
                   begin
                     a:=NumStack.Pop;
                     SetVar(sn, a);
                   end;
                 end else begin
                    Error('数字栈下溢出');
                    Exit;
                 end;
               end;

    CMD_POPNULL: begin
                 if NumStack.p <= 0 then
                 begin
                    Error('数字栈下溢出');
                    Exit;
                 end;
                 NumStack.Pop;
               end;

    CMD_CALCULATE :begin
               Calc(SptRun.ReadByte);
               if Err then Exit;
              end;
    CMD_LETARR: begin
               LetArrCmd;
             end;
    CMD_IF   :begin
                ln:=SptRun.ReadLong;
                if NumStack.p>0 then
                begin
                  a := NumStack.Pop;
                  ToVarType(a, VT_BOOL);
                  if a.BoolValue then Inc(SptRun.Position, ln - 4);
                  //Writeln('if ', SptRun.Position);
                end else begin
                  Error('数字栈下溢出');
                  Exit;
                end;
              end;
    CMD_IFNOT :begin
                ln:=SptRun.ReadLong;
                if NumStack.p>0 then
                begin
                  a := NumStack.Pop;
                  ToVarType(a, VT_BOOL);
                  if not a.BoolValue then Inc(SptRun.Position, ln - 4);
                  //Writeln('if not ',SptRun.Position);
                end else begin
                  Error('数字栈下溢出');
                  Exit;
                end;
               end;
    CMD_GOTO :begin
                ln:=SptRun.ReadLong;
                Inc(SptRun.Position, ln - 4);
                //('goto ',SptRun.Position);
              end;
    CMD_INC  :begin
                sn:= SptRun.ReadSmall;
                p := GetVarRef(sn);
                if p <> nil then
                begin
                  Inc(p.IntValue);
                end;
              end;
    CMD_DEC  :begin
                sn:= SptRun.ReadSmall;
                p := GetVarRef(sn);
                if p <> nil then
                begin
                  Dec(p.IntValue);
                end;
              end;
    CMD_EXIT :begin
                Running:=False;
              end;
    CMD_THREAD :begin
                 strn := SptRun.ReadString;
                 CallScript(strn);
               end;
    CMD_LOCK   :begin
                  Locking:=True;
               end;
    CMD_UNLOCK  :begin
                  Locking:=False;
               end;
    CMD_CALL  :begin
                 strn := SptRun.ReadString;
                 NextScript := TScript.Create(Self, strn);
                 NextScript.Run(0);
               end;
    CMD_CALLAT :begin
                  if 0 >= NumStack.p then
                  begin
                    Error('数字栈下溢出');
                    Exit;
                  end;
                  if AddrStack.p>=StackUnit.Max then
                  begin
                    Error('地址栈上溢出');
                    Exit;
                  end;
                  a := NumStack.Pop;
                  ToVarType(a, VT_INT);
                  AddrStack.Push(SptRun.Position);
                  LocalManager.NewFrame(10);
                  SptRun.Position := SptRun.FuncList[a.IntValue].Address;
               end;
    CMD_SYSFUNC  :begin
                  bn := SptRun.ReadByte;
                  if NumStack.p>=StackUnit.Max then
                  begin
                    Error('数字栈上溢出');
                    Exit;
                  end;
                  NumStack.Push(ExecFunction(bn));
               end;
    CMD_USERFUNC  :begin
                  ln := SptRun.ReadLong;
                  if AddrStack.p>=StackUnit.Max then
                  begin
                    Error('地址栈上溢出');
                    Exit;
                  end;
                  AddrStack.Push(SptRun.Position);
                  LocalManager.NewFrame(10);
                  SptRun.Position := SptRun.FuncList[ln].Address;
               end;
    CMD_RETURN   :begin
                  if AddrStack.p<1 then
                  begin
                    Error('地址栈下溢出');
                    Exit;
                  end;
                  ln := AddrStack.Pop;
                  if ln >= 0 then
                    SptRun.Position := ln
                  else
                    FSuspend := True;
                  LocalManager.PopFrame;
                 end;
    CMD_SUSPEND  :begin
                  FSuspend := True;
                 end;
    else    begin
              Error('Unknown command:'+IntToStr(Integer(Cmd)));
            end;
  end;
  ArrayManager.CollectCarbage;                 //在此做垃圾回收
  until (Err) or (not Running) or (Locking=False) or (Suspended);
  Result := Cmd;
end;

destructor TScript.Free;
var
  I : Integer;
begin
 if Assigned(SptRun) then SptRun.Free;
 SptRun := nil;
 if Assigned(NextScript) then NextScript.Free;
 NextScript := nil;
 LocalManager.Free;
 for I := 0 to 255 do
   if Vars[I].VarType = VT_ARRAY then
   begin
     ArrayManager.AddRef(Vars[I].ArrayValue, -1);
   end;
end;

procedure TScript.Restart;
begin
  SptRun.Position := SptRun.FuncList[SptRun.Header.StartIndex].Address;
  LastOpr:=CMD_NOP;
  Locking:=False;
  Counter:=0;
  Running:=True;
  Waiting:=False;
  FillChar(Vars,0,SizeOf(vars));
  Err :=False;
end;

procedure TScript.Run(LagCount: Integer);
begin
  if NextScript <> nil then
  begin
    NextScript.Run(LagCount);
    if NextScript.Running = False then
    begin
      NextScript.Free;
      NextScript := nil;
    end;
  end else begin
    LastOpr := ExecuteOne(LagCount);
  end;
  if ErrStr <> '' then Running := False;

end;

function TScript.ExecFunction(fid: Byte): TVar;
var
  P: TVarArray;
  I, n: Integer;
begin
  with SysFuncTable[fid] do
  begin
    Result := CreateVar(0);
    if ParamCount < 0 then
      n := NumStack.Pop.IntValue
    else
      n := ParamCount;
    SetLength(P, n);
    for I := n-1 downto 0 do
    begin
      P[I] := NumStack.Pop;
      if (ParamType[I] <> VT_ANY) and (ParamCount > 0) then
      begin
        ToVarType(P[I], ParamType[I]);
      end;
    end;
    case Fun_No of
      FUNC_NULL: Result := CreateVar(0);
      FUNC_RND : Result := CreateVar(Random(P[0].IntValue));
      FUNC_NEWARRAY: begin
         Result.VarType := VT_ARRAY;
         Result.ArrayValue := ArrayManager.Add(P[0].IntValue);
      end;
      FUNC_RESIZE: begin
         ArrayManager.Resize(P[0].ArrayValue, P[1].IntValue);
      end;

      FUNC_LEN: begin
         Result.VarType := VT_INT;
         case P[0].VarType of
         VT_INT: Result.IntValue := SizeOf(Integer);
         VT_FLOAT: Result.IntValue := SizeOf(Double);
         VT_BOOL: Result.IntValue := SizeOf(Boolean);
         VT_STR:  Result.IntValue := Length(P[0].StrValue);
         else
           Result.IntValue := ArrayManager.GetBound(P[0].ArrayValue);
         end;
      end;

      FUNC_SIN: begin
         Result := CreateVar(Sin(P[0].FloatValue));
      end;
      FUNC_COS: begin
         Result := CreateVar(Cos(P[0].FloatValue));
      end;
      FUNC_ATAN: begin
         Result := CreateVar(ArcTan(P[0].FloatValue));
      end;
      FUNC_LN: begin
         Result := CreateVar(Ln(P[0].FloatValue));
      end;
      FUNC_EXP: begin
         Result := CreateVar(Exp(P[0].FloatValue));
      end;
      FUNC_SQRT: begin
         Result := CreateVar(Sqrt(P[0].FloatValue));
      end;

      FUNC_TYPE : Result := CreateVar(Integer(P[0].VarType));
      FUNC_VAR : Result := VarValue(P[0].IntValue);
      FUNC_ADDTIMER : begin
           Result := CreateVar(Schedule.Add(P[0].StrValue, P[1].IntValue));
      end;
      FUNC_DELTIMER : begin
           Schedule.Delete(P[0].IntValue);
      end;
      FUNC_FINDTIMER : begin
           Result := CreateVar(Schedule.Find(P[0].StrValue));
      end;
      FUNC_ASC : begin
           if P[0].StrValue <> '' then
               Result := CreateVar(Ord(P[0].StrValue[1]))
      end;
      FUNC_CHR : begin
           Result := CreateVar(Char(P[0].IntValue));
      end;
      FUNC_STRPOS : begin
           Result := CreateVar( FastPos(P[0].StrValue, P[1].StrValue,
                             Length(P[0].StrValue), Length(P[1].StrValue),
                             P[2].IntValue) );
      end;
      FUNC_STRSUB : begin
           Result := CreateVar(Copy(P[0].StrValue, P[1].IntValue, P[2].IntValue));
      end;
      FUNC_STRDEL : begin
           Result.VarType := VT_STR;
           Result.StrValue:= P[0].StrValue;
           Delete(Result.StrValue, P[1].IntValue, P[2].IntValue);
      end;
      FUNC_STRINSERT : begin
           Result.VarType := VT_STR;
           Result.StrValue:= P[0].StrValue;
           Insert(P[1].StrValue, Result.StrValue, P[2].IntValue);
      end;
      FUNC_SENDMESSAGE : begin
           Result := CreateVar(
             SendMessage(P[0].IntValue, P[1].IntValue,
                         P[2].IntValue, P[3].IntValue)
             );
      end;
     else begin
       {$IFDEF APLOS_CONSOLE}
        Result := ExecConFunction(fid, P, n);
       {$ENDIF}
       {$IFDEF APLOS_WIN}
        Result := ExecWinFunction(fid, P, n);
       {$ENDIF}
      end;
    end;
    SetLength(P, 0);
  end;
end;




function TScript.GetTop: TScript;
begin
  if NextScript <> nil then
    GetTop := NextScript.GetTop
  else
    GetTop := Self;
end;

{$IFDEF APLOS_CONSOLE}

function TScript.ExecConFunction(fid: Byte; P: TVarArray; n: Integer): TVar;
var
  A: TVar;
  I: Integer;
begin
  Result := CreateVar(0);
  case fid of
    FUNC_READKEY : begin
      if P[0].BoolValue then
      begin
        Result := CreateVar(Ord(ReadKey));
      end else begin
        if KeyPressed then
          Result := CreateVar(Ord(ReadKey))
        else
          Result := CreateVar(-1);
      end;
    end;
    FUNC_WRITE : begin
      for I := 0 to n - 1 do
      begin
        WriteVar(P[I]);
      end
    end;
    FUNC_WRITELN : begin
      for I := 0 to n - 1 do
      begin
        WriteVar(P[I]);
      end;
      Writeln;
    end;
    FUNC_READINT : begin
       try
          Read(A.IntValue);
       except
          A.IntValue := 0;
       end;
       A.VarType := VT_INT;
       Result := A;
    end;
    FUNC_READFLOAT : begin
       try
          Read(A.FloatValue);
       except
          A.FloatValue := 0.0;
       end;
       A.VarType := VT_FLOAT;
       Result := A;
    end;
    FUNC_READSTRING : begin
       Read(A.StrValue);
       while A.StrValue = '' do Readln(A.StrValue);
       A.VarType := VT_STR;
       Result := A;
    end;
    FUNC_MSGBOX : begin
       Result := CreateVar(
               MessageBox(0, PChar(P[0].StrValue),
                             PChar(P[1].StrValue),
                             P[2].IntValue)
               );
    end;

  end;
end;
{$ENDIF}

{$IFDEF APLOS_WIN}
function TScript.ExecWinFunction(fid: Byte; P: TVarArray; n: Integer): TVar;
begin
  Result := CreateVar(0);
  case fid of
    FUNC_MSGBOX : begin
       Result := CreateVar(
               MessageBox(CtrlList.GetMain.Handle, PChar(P[0].StrValue),
                             PChar(P[1].StrValue),
                             P[2].IntValue)
               );
    end;

    FUNC_SETTEXT: begin
         CtrlList.SetText(P[0].IntValue, P[1].StrValue);
    end;
    FUNC_GETTEXT: begin
         Result := CreateVar( CtrlList.GetText(P[0].IntValue) );
    end;
    FUNC_SETENABLED: begin
         CtrlList.SetEnabled(P[0].IntValue, P[1].BoolValue);
    end;
    FUNC_GETENABLED: begin
         Result := CreateVar( CtrlList.GetEnabled(P[0].IntValue) );
    end;
    FUNC_SETVISIBLE: begin
         CtrlList.SetVisible(P[0].IntValue, P[1].BoolValue);
    end;
    FUNC_GETVISIBLE: begin
         Result := CreateVar( CtrlList.GetVisible(P[0].IntValue) );
    end;
    FUNC_GETHANDLE: begin
         Result := CreateVar( CtrlList.GetHandle(P[0].IntValue) );
     end;
    FUNC_SETSIZE: begin
         CtrlList.SetSize(P[0].IntValue, P[1].IntValue, P[2].IntValue);
     end;
    FUNC_SETPOS: begin
         CtrlList.SetPos(P[0].IntValue, P[1].IntValue, P[2].IntValue);
     end;
    FUNC_DELOBJECT: begin
         CtrlList.DelObject(P[0].IntValue);
     end;
    FUNC_ADDSTATIC: begin
         Result := CreateVar(CtrlList.AddStatic(
                             P[0].IntValue,      //parent
                             P[1].StrValue,      //text
                             P[2].IntValue,      //x
                             P[3].IntValue,      //y
                             P[4].IntValue,      //w
                             P[5].IntValue       //h
                              ) );
     end;
    FUNC_ADDBUTTON: begin
         Result := CreateVar(CtrlList.AddButton(
                             P[0].IntValue,      //parent
                             P[1].StrValue,      //text
                             P[2].IntValue,      //x
                             P[3].IntValue,      //y
                             P[4].IntValue,      //w
                             P[5].IntValue       //h
                             ) );
     end;
    FUNC_ADDEDIT: begin
         Result := CreateVar(CtrlList.AddEdit(
                             P[0].IntValue,      //parent
                             P[1].StrValue,      //text
                             P[2].IntValue,      //x
                             P[3].IntValue,       //y
                             P[4].IntValue,      //w
                             P[5].IntValue       //h
                             ) );
     end;
    FUNC_ADDLISTBOX: begin
         Result := CreateVar(CtrlList.AddList(
                             P[0].IntValue,      //parent
                             P[1].StrValue,      //text
                             P[2].IntValue,      //x
                             P[3].IntValue,      //y
                             P[4].IntValue,      //w
                             P[5].IntValue       //h
                             ) );
     end;
    FUNC_ADDCHECKBOX: begin
         Result := CreateVar(CtrlList.AddCheck(
                             P[0].IntValue,      //parent
                             P[1].StrValue,      //text
                             P[2].IntValue,      //x
                             P[3].IntValue,      //y
                             P[4].IntValue,      //w
                             P[5].IntValue,       //h
                             P[6].BoolValue       //checked

                             ) );
     end;
    FUNC_ADDRADIOBOX: begin
         Result := CreateVar(CtrlList.AddRadio(
                             P[0].IntValue,      //parent
                             P[1].StrValue,      //text
                             P[2].IntValue,      //x
                             P[3].IntValue,      //y
                             P[4].IntValue,      //w
                             P[5].IntValue,       //h
                             P[6].BoolValue       //checked
                             ) );
     end;
    FUNC_ADDCOMBOBOX: begin
         Result := CreateVar(CtrlList.AddCombo(
                             P[0].IntValue,      //parent
                             P[1].StrValue,      //text
                             P[2].IntValue,      //x
                             P[3].IntValue,      //y
                             P[4].IntValue,      //w
                             P[5].IntValue,       //h
                             P[6].BoolValue       //STYLE
                             ) );
     end;
     FUNC_ADDPANEL: begin
         Result := CreateVar(CtrlList.AddPanel(
                             P[0].IntValue,      //parent
                             P[1].StrValue,      //text
                             P[2].IntValue,      //x
                             P[3].IntValue,      //y
                             P[4].IntValue,      //w
                             P[5].IntValue,       //h
                             ) );
     end;
     FUNC_SETEVENT: begin
         if (P[2].IntValue < 0) or (P[2].IntValue >= SptRun.Header.FuncCount)
         then begin
           Error('回调函数错');
         end else begin;
           CtrlList.SetEvent(P[0].IntValue, P[1].IntValue, P[2].IntValue);
         end;
     end;
     FUNC_SETSTYLE: begin
           CtrlList.SetStyle(P[0].IntValue, P[1].IntValue, P[2].BoolValue);
     end;
     FUNC_GETSTYLE: begin
           CtrlList.GetStyle(P[0].IntValue, P[1].BoolValue);
     end;
     FUNC_SETALIGN: begin
           CtrlList.SetAlign(P[0].IntValue, P[1].IntValue);
     end;
     FUNC_TEXTOUT: begin
           CtrlList.TextOut(P[0].IntValue, P[1].IntValue, P[2].IntValue,
                            P[3].StrValue,);
     end;
     FUNC_DRAWBOX: begin
           CtrlList.DrawBox(P[0].IntValue, P[1].IntValue, P[2].IntValue,
                            P[3].IntValue, P[4].IntValue, p[5].BoolValue);
     end;

  end;
  if CtrlList.Err then Error(CtrlList.ErrStr);
end;
{$ENDIF}

{ TScriptThread }

constructor TScriptThread.Create(RootScript: SPTFile);
begin
  NumStack:=TGCVarStack.Create;
//  OprStack:=TStack.Create;
  AddrStack:=TStack.Create;
  Root := TScript.Create(nil, RootScript);
  Root.NumStack := NumStack;
//  Root.OprStack := OprStack;
  Root.AddrStack:= AddrStack;
  Running := True;
end;

constructor TScriptThread.Create(RootScriptFile: string);
begin
  NumStack:=TGCVarStack.Create;
//  OprStack:=TStack.Create;
  AddrStack:=TStack.Create;
  Root := TScript.Create(nil, RootScriptFile);
  Root.NumStack := NumStack;
//  Root.OprStack := OprStack;
  Root.AddrStack:= AddrStack;
  Running := True;
end;

destructor TScriptThread.Free;
begin
  Root.Free;
  NumStack.Free;
//  OprStack.Free;
  AddrStack.Free;
end;

function TScriptThread.GetTop: TScript;
begin
  GetTop := Root.GetTop;
end;

procedure TScriptThread.Run(LagCount: Integer);
begin
  if Running then
  begin
    try
      Root.Run(LagCount);
      Running := Root.Running;
    except
      on E: Exception do
      begin
        ErrStr := '内部异常：' + E.Message;
        Running := False;
      end;
    end;
  end;

end;

{ TScheduleList }

function TScheduleList.Add(FileName: string; Time: Integer): Integer;
var
  I, J, ID, P: Integer;
  ST: Integer;
begin
  Inc(Count);
  ST := Integer(GetTickCount) + Time;
  if Count > Capacity then             //如果没有足够空间
  begin
    Capacity := Capacity * 2;          //空间增加一倍
    SetLength(Items, Capacity);
  end;
  ID := 0;
  for I := 1 to Count do               //找到一个没用过的ID
  begin
    P := -1;
    for J := 0 to Count - 2 do
      if Items[J].ID = I then
      begin
        P := J; Break;
      end;
      if P < 0 then
      begin
        ID := I; Break;
      end;
  end;
  P := Count - 1;                     //按时间顺序排序插入列表
  for I := Count -2 downto 0 do
  begin
    if Items[I].StartTime <= ST then Break;
    Dec(P);
    Items[I + 1] := Items[I];
  end;
  Items[P].ID := ID;
  Items[P].Spt := FileName;
  Items[P].StartTime := ST;
  Add := ID;                           //返回ID值
end;

procedure TScheduleList.Clear;
begin
  Capacity := 100;
  SetLength(Items, Capacity);
  Count := 0;
end;

constructor TScheduleList.Create;
begin
  Clear;
end;

procedure TScheduleList.Delete(ID: Integer);
var
  I, J: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    if Items[I].ID = ID then
    begin
      for J := I + 1 to Count - 1 do Items[I - 1] := Items[I];
      Dec(Count);
      Break;
    end;
  end;
end;

//按文件名查找
function TScheduleList.Find(FileName: string): Integer;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    if FileName = Items[I].Spt then
    begin
      Result := Items[I].ID;
      Exit;
    end;
  end;
  Result := -1;
end;

function TScheduleList.GetCount: Integer;
begin
  GetCount := Count;
end;

procedure TScheduleList.Update;
var
  I, P, T: Integer;
begin
  T := GetTickCount;
  P := 0;
  for I := 0 to Count -1 do
  begin
    if T >= Items[I].StartTime then
    begin
      Inc(P);
      CallScript(Items[I].Spt);
    end else begin
      Break;
    end;
  end;
  if P > 0 then
    for I := P to Count - 1 do
    begin
      Items[I-P] := Items[I];
    end;
  Dec(Count, P);
end;

{ TArrayManager }

function TArrayManager.Add(Capa: Integer): Integer;
var
  I : Integer;
begin
  Add := 0;
  if Count = Capacity then
  begin
    Inc(Capacity, 100);
    SetLength(Items, Capacity);
    SetLength(Used, Capacity);
    SetLength(Ref, Capacity);
    for I := Count to Capacity - 1 do
    begin
      Used[I] := False;
      Ref[I] := 0;
      SetLength(Items[I], 0);
    end;

    //ErrStr := '太多的数组';
//    Exit;
  end;
  for I := 0 to Capacity - 1 do
  begin
    if not Used[I] then
    begin
      Add := I;
      Used[I] := True;
      SetLength(Items[I], Capa);
      Ref[I] := 0;
      Inc(Count);
      Exit;
    end;
  end;
end;

function TArrayManager.AvailableID(ID: Integer): Boolean;
begin
  AvailableID := (ID >= 0) and (ID < Capacity) and Used[ID];
end;

procedure TArrayManager.Clear;
var
  I : Integer;
begin
  Capacity := 100;
  SetLength(Items, Capacity);
  SetLength(Used, Capacity);
  SetLength(Ref, Capacity);

  Count := 0;
  for I := 0 to Capacity - 1 do
  begin
    Used[I] := False;
    Ref[I] := 0;
    SetLength(Items[I], 0);
  end;
end;

constructor TArrayManager.Create;
begin
  Clear;
end;

procedure TArrayManager.Delete(ID: Integer);
var
  I : Integer;
begin
  if not AvailableID(ID) then
  begin             
    ErrStr:= '对非数组进行数组操作';
    Exit;
  end;
  if Used[ID] then
  begin
    Dec(Count);
    Used[ID] := False;
    for I := 0 to High(Items[ID]) do
    begin
      if Items[ID][I].VarType = VT_ARRAY then
      begin
        AddRef(Items[ID][I].ArrayValue, -1);
      end;
    end;
  end;
  SetLength(Items[ID], 0);
  Ref[ID] := 0;
end;

destructor TArrayManager.Free;
begin
  Clear;
end;

function TArrayManager.GetBound(ID: Integer): Integer;
begin
  GetBound := 0;
  if not AvailableID(ID) then
  begin
    ErrStr:='对非数组进行数组操作';
    Exit;
  end;
  GetBound := High(Items[ID])+1;
end;

function TArrayManager.GetCount: Integer;
begin
  GetCount := Count;
end;

procedure TArrayManager.Resize(ID, NewSize: Integer);
begin
  if not AvailableID(ID) then
  begin
    ErrStr := '对非数组进行了数组操作';
    Exit;
  end;
  SetLength(Items[ID], Abs(NewSize));
end;

procedure TArrayManager.AddRef(ID, n: Integer);
begin
  Inc(Ref[ID], n);
  if Ref[ID] <= 0 then Inc( NeedCollectCount );
end;

procedure TArrayManager.CollectCarbage;
var
  I: Integer;
begin
  if NeedCollectCount > 0 then
  begin
    for I := 0 to Capacity - 1 do
    begin
      if (Used[I]) and (Ref[I] <= 0) then
      begin
        Delete(I);
        Dec(NeedCollectCount);
        if NeedCollectCount <= 0 then Break;
      end;
    end;
    NeedCollectCount := 0;
  end;
end;

{ TLocalManager }

procedure TLocalManager.Clear;
begin
  while BaseStack.p > 0 do PopFrame;
  SetLength(Items, 0);
  Count := 0;
end;

constructor TLocalManager.Create(Owner: TScript);
begin
  FScript := Owner;
  BaseStack := TStack.Create;
  Clear;
end;

procedure TLocalManager.Extend(ToLen: Integer);
var
  I: Integer;
begin
  SetLength(Items, ToLen);
  for I := Count to ToLen - 1 do Items[I] := CreateVar(0);
  Count := ToLen;
end;

destructor TLocalManager.Free;
begin
  Clear;
  BaseStack.Free;
end;

function TLocalManager.GetValue(id: Integer): TVar;
begin
  if BaseStack.p > 0 then
    id := id + BaseStack.Peek;
  if id >= Count then
  begin
    Extend(id+1);
  end;
  Result := Items[id];
end;

function TLocalManager.GetVarRef(id: Integer): PVar;
begin
  if BaseStack.p > 0 then
    id := id + BaseStack.Peek;
  if id >= Count then
  begin
    Extend(id+1);
  end;
  Result := @Items[id];
end;

procedure TLocalManager.NewFrame(Len: Integer);
begin
  BaseStack.Push(Count);
  Extend(Count + Len);
end;

procedure TLocalManager.PopFrame;
var
  I : Integer;
begin
  for I := BaseStack.Peek to Count - 1 do
    if Items[I].VarType = VT_ARRAY then
      ArrayManager.AddRef(Items[I].ArrayValue, -1);
  Count := BaseStack.Pop;
  SetLength(Items, Count);
end;

procedure TLocalManager.SetValue(id: Integer; v: TVar);
begin
  if BaseStack.p > 0 then
    id := id + BaseStack.Peek;
  if id >= Count then
  begin
    Extend(id+1);
  end;
  Items[id] := v;
end;

{ TGCVarStack }

function TGCVarStack.Pop: TVar;
begin
  Result := inherited Pop;
  if Result.VarType = VT_ARRAY then
  begin
    ArrayManager.AddRef(Result.ArrayValue, -1);
  end;
end;

procedure TGCVarStack.Push(n: TVar);
begin
  inherited Push(n);
  if n.VarType = VT_ARRAY then
  begin
    ArrayManager.AddRef(n.ArrayValue, 1);
  end;
end;

initialization
  Randomize;
  Schedule := TScheduleList.Create;
  ArrayManager := TArrayManager.Create;
{$IFDEF APLOS_WIN}
  CtrlList := TCtrlList.Create;
{$ENDIF}
finalization
  ResetScript;
  Schedule.Free;
  ArrayManager.Free;
{$IFDEF APLOS_WIN}
  CtrlList.Free;
{$ENDIF}
end.

