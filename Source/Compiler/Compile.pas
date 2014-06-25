{********************************
 * Aplos脚本编译器              *
 *    编译单元                  *
 *    姚春晖(redclock)2004      *
 ********************************}
unit Compile;
{$Define _SPT_DEBUG_}
interface

uses
   SysUtils,
   SptConst,
   StackUnit,
   DefineVar,
   SptBin,
   SptFunc,
   SptOut,
   SptClass,
   Express,
   Classes,
   FastStr;
var
   err:Boolean;
   Bin:SptFile;
   IncludeFile: string = '';         //是否需要包含文件
   Explicited: Boolean;

procedure CompileOne(s:string);
procedure InitCompiler;
procedure EndCompiler;
procedure AddLabel(s:string);
procedure CompileInstruction(s: string);
procedure Error(e: string);
procedure dMsg(s: string);
procedure CallFunction(var Func: TFuncDef;
              var s: string; var i: Integer; IsMethod: Boolean);

implementation


const
   MAX_LABEL    = 255;
   MAX_GOTO     = 1000;

   CTRL_FOR     = 0;
   CTRL_WHILE   = 1;
   CTRL_REPEAT  = 2;

type

   TGoto = record
       Addr:Integer;
       LabelName:string;
   end;

   TLabel=record
       Addr:Integer;
       Name:string;
   end;

   TLoopCtrlStack = class(TStack)
   protected
     //Continue 语句的地址
     ContinueAddrs: array[0..StackUnit.Max] of array[0..100] of LongInt;
     //Break 语句的地址
     BreakAddrs:    array[0..StackUnit.Max] of array[0..100] of LongInt;
     ContinueCount: array[0..StackUnit.Max] of Integer;
     BreakCount:array[0..StackUnit.Max] of Integer;
   public
     //块结束时填充所有Continue语句的跳转地址
     procedure FillContinues(I: Integer);
     //块结束时填充所有Continue语句的跳转地址
     procedure FillBreaks(I: Integer);
     //当前位置添加一个Continue
     procedure AddContinue(Pos: Integer);
     //当前位置添加一个Break
     procedure AddBreak(Pos: Integer);

     procedure Push(n: Integer); override;
     function  Pop: Integer; override;
   end;

   TForStack = class(TLoopCtrlStack)
   public
                                                    //arr是for前的地址
       IsUp:array[0..StackUnit.Max] of Boolean;     //是 to 还是 downto
       VarId:array[0..StackUnit.Max] of SmallInt;   //循环变量的地址
       Addr2s:array[0..StackUnit.Max] of Longint;   //退出for的goto的地址
       constructor Create;
       procedure Push(Addr:Integer;aUp:Boolean;Id,Addr2:Integer); overload;
       function Pop(var Up:Boolean;var Id,Addr2:Integer):Integer; overload;
   end;

   TIFStack = class(TStack)
   public
       LastIsElse: array[0..StackUnit.Max] of Boolean;
       ElseCount: array[0..StackUnit.Max] of Integer;
       Elses: array[0..StackUnit.Max] of array [0..100] of Longint; //块执行完写goto的地址
       constructor Create;
       procedure PushElse(ELSEAddr: Integer);
   end;

   TWhileStack = class(TLoopCtrlStack)
   public
       Addr2s: array[0..StackUnit.Max] of Longint;
       constructor Create;
       procedure Push(Addr:Integer;Addr2:Integer);
       function Pop(var Addr2:Integer): Integer;
   end;

   TRepeatStack = class(TLoopCtrlStack)
   public
       constructor Create;
       procedure Push(n: Integer); override;
   end;

   TFuncControl = class
   public
     IFStack      : TIFStack;
     ForStack     : TForStack;
     RepeatStack  : TRepeatStack;
     WhileStack   : TWhileStack;
     LoopStack    : TStack;
     Labels       :array[0..MAX_LABEL] of TLabel;
     Gotos        :array[0..MAX_GOTO] of TGoto;
     LCount,GCount:Integer;
     constructor  Create;
     destructor   Free;
   end;

   TCommandProc = procedure(s: string);    //编译每个命令的过程类型

   TCommandList = class                    //命令列表
   private
     CmdNames: TStringList;
     Procs: TList;
   public
     procedure Add(CmdName: string; Proc: TCommandProc);
     function CallCmd(CommandLine: string): Boolean;
     constructor Create;
     destructor Free;
   end;


var
  MainControl: TFuncControl;       // 主函数的控制语句
  CurrControl: TFuncControl;       // 当前函数的控制语句
  CurrClass:   TSptClass;          // 当前在哪个函数的定义中（一般为nil）
  IsInClassDefination: Boolean;    // 是在类定义中还是在代码中（包括类方法的代码）

  CommandList : TCommandList;      // 命令列表

procedure InitCommandList; forward;
procedure ByCompilerFunction(FuncNo: Integer); forward;

//出错
procedure Error(e: string);
begin
   errWriteln('Compile Error:' + e + '.');
   Err:=True;
end;

//输出编译后的目标码
procedure dMsg(s: string);
begin
  debugWriteln(s);
end;

// 字符串id是否已经被定义成标识符
function IDHasDefined(id: string): Boolean;
begin
  Result := (consts.Find(id)>=0)
           or(privars.find(id)>=0)
           or(pubvars.find(id)>=0)
           or(localvars.Find(id)>=0)
           or(Bin.FindFuncByName(id)>=0);
end;


{  删除语句中的注释  }
procedure DeleteComment(var s: string);
var i:integer;
begin
  i := 1;
  while i<=Length(s) do
  begin
    if s[i]=#34 then                  //跳过字符串
    begin
      repeat
        Inc(i);
      until (i>Length(s)) or (s[i]=#34);
      Dec(i);
    end else if s[i]='''' then
    begin
      Break;
    end else if (s[i]='/') and (i<Length(s)) and (s[i+1]='/') then
    begin
      Break;
    end;
    Inc(i);
  end;
  s := Copy(s, 1, i-1);
end;

{ 初始化编译器 }
procedure InitCompiler;
begin
  MainControl := TFuncControl.Create;
  CurrControl := MainControl;
  Explicited  := False;
  IsInClassDefination := False;
  CurrClass   := nil;

  dMsg('* 编译开始');
  InitCommandList;
end;

{ 结束编译器 }
procedure EndCompiler;
var
  I, J: Integer;
begin
  if MainControl = CurrControl then  //当前在主函数中
  begin
    MainControl.Free;
  end else begin                     //当前在自定义函数中
    MainControl.Free;
    CurrControl.Free;
    if not err then Error('文件异常结尾');
  end;
  if not err then
  begin
    for I := 0  to Bin.Header.FuncCount - 1 do
    begin
      if Bin.FuncList[I].DeinfedOnly then
      begin
        J := FindUserFunction(I);
        Error('函数 '+UserFuncTable[J].Name+' 只声明未定义。');
      end;
    end;
  end;
  if CommandList <> nil then
  begin
    FreeAndNil( CommandList );
  end;
  dMsg('* 结束编译');
end;                               //关闭"compile output"


procedure CompileInstruction(s: string);
var
  IsOn: Boolean;
  I: Integer;
  Inst: string;
begin
  I := 1;
  Inst := LowerCase(GetId(s, I));
  IsOn := LowerCase(GetId(s, i)) <> 'off';
  if Inst = 'setlock' then
  begin
     Bin.Header.Locked := IsOn
  end else  Inst = 'explicit' then
  begin

     Explicited := IsOn;
  end
end;

{ 编译调用函数的语句 }
procedure CallFunction(var Func: TFuncDef; var s: string;
                       var i: Integer; IsMethod: Boolean);
var
  argc: Integer;
  ts: string;
  ParamNeed: Integer;
begin
  while((i<=Length(s))and(s[i] in SepCharSet)) do Inc(i);  //跳过前导空格
  if (i>Length(s)) or (s[i]<>'(') then                     //找"("
  begin
    Error('找不到左括号');
    Exit;
  end;

  if (IsMethod) then                 //如果按方法方式调用，就少一个参数
  begin
    if Func.ParamCount = 0 then
    begin
      Error('函数('+Func.Name+')参数太多');
      Exit;
    end;
    ParamNeed := Func.ParamCount - 1;
  end else begin
    ParamNeed := Func.ParamCount;
  end;

  Inc(i);
  argc := 0;

  while (i <= Length(s))do                  //读取每个参数
  begin
    ts := Trim(GetExpr(s, i));
    if ts = '' then
    begin
      Inc(i);
      Break;
    end;
    if (Func.ParamCount>=0) and (argc >= ParamNeed)
    then begin
      Error('函数('+Func.Name+')参数太多');
      Exit;
    end;
    Expr(ts);
    if err then Exit;
    Inc(argc);
    Inc(i);
    if s[i-1] = ')' then Break;
  end;

{  while (j<=Length(s))and(kh>=0) do
  begin
    if (kh=0) and ((s[j]=',') or (s[j]=')')) then
    begin
      if s[j]=')' then Dec(kh);
      ts:=Trim(Copy(s, i, j-i));
      if ts<>'' then
      begin
        if (Func.ParamCount>=0) and (argc >= Func.ParamCount)
        then begin
          Error('函数('+Func.Name+')参数太多');
          Exit;
        end;
        Expr(ts);
        if err then Exit;
        Inc(argc);
      end;
      i:=j+1;
    end else if s[j] = '(' then Inc(kh)
    else if s[j] = ')' then Dec(kh);
    Inc(j);
  end;
  if (j>Length(s))and(kh>0) then
  begin
    Error('括号不匹配');
    Exit;
  end;}
  if (Func.ByCompiler) then
  begin
    ByCompilerFunction(Func.Fun_No);
  end else begin
    if (argc < ParamNeed) then
    begin
      Error('函数('+ Func.Name + ')参数太少');
      Exit;
    end;
    if (Func.ParamCount < 0) then       //如果是不定参数函数,现压入参数个数
    begin
      if IsMethod then
      begin
        dMsg('Pushi '+IntToStr(argc + 1));
        Bin.CurrFunc.WriteCmd(CMD_PUSHI);
        Bin.CurrFunc.WriteLong(argc + 1);
      end else begin
        dMsg('Pushi '+IntToStr(argc));
        Bin.CurrFunc.WriteCmd(CMD_PUSHI);
        Bin.CurrFunc.WriteLong(argc);
      end;
    end;
    if Func.IsSys then
    begin
      //如果是系统函数
      Bin.CurrFunc.WriteCmd(CMD_SYSFUNC);
      Bin.CurrFunc.WriteByte(Func.Fun_No);
      dMsg('Call System Function:'+Func.Name+'()');
    end else begin
      //否则是用户函数
      Bin.CurrFunc.WriteCmd(CMD_USERFUNC);
      Bin.CurrFunc.WriteLong(Func.Fun_No);
      dMsg('Call User Function:'+Func.Name+'()'
                       + ' # ' + IntToStr(Func.Fun_No));
    end;
  end;
end;

{ 建立标号 }
procedure AddLabel(s:string);
var
  p:Boolean;    //是否曾经建立过此标号
  i:Integer;
begin
  p:=False;
  s:=Trim(s);
  with CurrControl do
  begin
    for i:=1 to LCount do
      if Labels[i].Name=s then
      begin
         p:=True;
         Break;
      end;
    if p then begin
      Error('二次定义标号:'+s);
      Exit;
    end;
    if LCount>=MAX_LABEL then
       Error('标号太多')
    else begin
       inc(LCount);
       Labels[LCount].Name:=s;
       Labels[LCount].Addr:=Bin.CurrFunc.Position;
       dMsg('* 新标号:'+s+' @ '+IntToStr(Bin.CurrFunc.Position));
    end;
  end;
end;

{ PRIVATE 语句 }
procedure cmdPrivate(s:string);
var
   id:string;
   i:integer;
begin
     i:=1;
     id:=GetId(s,i);
     while id<>'' do               //依次读取每个变量名
     begin
        if Bin.CurrFunc.IsMain then   //是主函数的话, 就新建私有变量
        begin
          if IDHasDefined(id) then      //已经定义过吗
          begin
             Error('二次定义标识符:'+id);
             exit;
          end;
          if privars.Count>=255 then
          begin
             Error('私有变量过多');
             exit;
          end;
          privars.add(id);
          dMsg('* 新私有变量:'+id+' @ '+IntTostr(privars.Count+$0100));
        end else begin                //否则就新建局部变量
          if localvars.Find(id) > 0 then      //局部变量只要局部未定义就可以了
          begin
             Error('二次定义局部标识符:'+id);
             exit;
          end;
          if localvars.Count>=255 then
          begin
             Error('局部变量过多');
             exit;
          end;
          localvars.add(id);
          dMsg('* 新局部变量:'+id+' @ '+IntTostr(localvars.Count+$0300));
        end;
        id:=GetId(s,i);
     end;
end;

procedure cmdPublic(s:string);
var id:string;
    i,addr:integer;
begin
  i:=1;
  id:=GetId(s,i);
  while id<>'' do
  begin
    if IDHasDefined(id) then
    begin
      Error('二次定义标识符'+id);
      exit;
    end;
    addr:=Trunc(GetNum(s,i));
    if (addr<1)or(addr>255)then
    begin
      Error('地址超出范围');
      exit;
    end;
    pubvars.addspec(id,addr);
    dMsg('* 新公有变量 '+id+' @ '+Inttostr(addr));
    id:=GetId(s,i);
  end;
end;

procedure cmdConst(s:string);
var
  id:string;
  i: Integer;
  value:string;
begin
  i:=1;
  id:=GetId(s,i);
  if IDHasDefined(id) then
  begin
     Error('二次定义标识符'+id);
     exit;
  end;
  i:=Pos('=', s);
  if  i=0 then begin
     Error('未找到 "="');
     Exit;
  end;
  Delete(s,1,i);
  value:=Trim(s);
  consts.Add(id,value);
  dMsg('* 新常量 '+id+' = '+value);
end;




procedure cmdInclude(s:string);
begin
  s := Trim(s);
  if Pos('.', s) = 0 then s := s+SourceFileExt;
  IncludeFile := s;
end;

procedure cmdPush(s:string);
begin
  Expr(s);
end;


procedure cmdPop(s: string);
var
  v, i, j: Integer;
begin
  s := Trim(s);
  if s = '' then
  begin
    Error('缺少变量');
    Exit;
  end;
  if s[Length(s)] = ']' then                 ////被赋值函数为数组expr1[expr2]
  begin
    i := FastPos(s, '[', Length(s), 1, 1);   //找到匹配的[
    j := 0;
    while (i > 0) do
    begin
      j := FindToken(s, ']', i + 1);
      if (j = Length(s)) or (j = 0) then Break;
      i := FastPos(s, '[', Length(s), 1, i + 1);
    end;
    if ( i <= 0 ) or ( j <> Length(s) ) then
    begin
      Error('括号不匹配');
      Exit;
    end;
    Expr(Copy(s, 1, i-1));
    if Err then Exit;
    Expr(Copy(s, i+1, j-i-1));
    if Err then Exit;
    dMsg('LetArr');
    Bin.CurrFunc.WriteCmd(CMD_LETARR);
  end else begin                             //为简单变量
    if not IdentifierIsVarname(s) then
    begin
      Error('变量名错误');
      Exit;
    end;
    v := varid(s);
    if v<0 then
      if Explicited then
        begin Error('未定义的变量:'+s);exit;end
      else begin
        cmdPrivate(s);
        if err then Exit;
        v := VarId(s);
      end;
    dMsg('Pop '+s+' @ '+IntToStr(v));
    Bin.CurrFunc.WriteCmd(CMD_POP);
    Bin.CurrFunc.WriteSmall(v);
  end;
end;


procedure cmdInc(s:string);
var
  v:Integer;
begin
  s:=Trim(s);
  v:=VarId(s);
  if v<0 then                           //如果变量不是简单变量
  begin                                 //化为s=s+1
    Expr(s+'+1');
    if err then Exit;
    cmdPop(s);
  end else begin
    Bin.CurrFunc.WriteCmd(CMD_INC);
    Bin.CurrFunc.WriteSmall(v);
    dMsg('Inc '+s+' @ '+IntToStr(v));
  end;
end;

procedure cmdDec(s:string);
var
  v:Integer;
begin
  s:=Trim(s);
  v:=VarId(s);
  if v<0 then                           //如果变量不是简单变量
  begin                                 //化为s=s-1
    Expr(s+'-1');
    if err then Exit;
    cmdPop(s);
  end else begin
    Bin.CurrFunc.WriteCmd(CMD_DEC);
    Bin.CurrFunc.WriteSmall(v);
    dMsg('Dec '+s+' @ '+IntToStr(v));
  end;
end;

procedure cmdLet(s:string);
var
  I: Integer;
begin
  I := FindToken(s, '=', 1);
  if I = 0 then
  begin
    Error('没有赋值号 "=" ');
    Exit;
  end;
  Expr(Copy(s, I+1, Length(s)));
  if err then exit;
  cmdPop(Trim(Copy(s, 1, I-1)));
end;

procedure cmdIf(s:string);
var
  P,i,Addr:Integer;
begin
  i := 1;
  Expr(GetExpr(s, i));
  dMsg('If Not Then <addr>');
  Bin.CurrFunc.WriteCmd(CMD_IFNOT);
  P := Bin.CurrFunc.Position;
  Bin.CurrFunc.WriteLong(0);
  if (i<=Length(s)) and (s[i] = ':') then   {**IF <expression> :Command Style**}
  begin
    CompileOne(Trim(Copy(s, i+1, Length(s))));
    Addr := Bin.CurrFunc.Position - P;
    System.Move(Addr, Bin.CurrFunc.Data^[P], SizeOf(LongInt));
  end else begin                            {**IF <expression> Style**}
    CurrControl.IfStack.Push(P);
    with CurrControl.IFStack do
    begin
      LastIsElse[p] := False;
    end;
  end;
end;

procedure cmdElse(s:string);
var
  Addr, Addr2:Integer;
  ts: string;
  i: Integer;
begin
  with CurrControl.IFStack do
  begin
    if p<=0 then
    begin
      Error('Else 没有 If 匹配');
      Exit;
    end;
    if LastIsElse[p] then
    begin
      Error('Else 之后不能再有 Else');
      Exit;
    end;
  end;
  dMsg('GoTo <addr>');
  Bin.CurrFunc.WriteCmd(CMD_GOTO);
  CurrControl.IFStack.PushElse(Bin.CurrFunc.Position);
  Bin.CurrFunc.WriteLong(0);
  Addr  := CurrControl.IfStack.Peek;
  Addr2 := Bin.CurrFunc.Position - Addr;
  System.Move(Addr2,Bin.CurrFunc.Data^[Addr],SizeOf(Longint));
  I := 1;
  ts := GetId(S ,I);
  if LowerCase(ts) = 'if' then   //Else If
  begin
    Delete(s, 1, i-1);
    Expr(s);
    if err then Exit;
    dMsg('IfNot <Addr>');
    Bin.CurrFunc.WriteCmd(CMD_IFNOT);
    CurrControl.IFStack.SetTop(Bin.CurrFunc.Position);
    Bin.CurrFunc.WriteLong(0);
  end else begin                //Else only
    CurrControl.IFStack.LastIsElse[CurrControl.IFStack.p] := True;
  end;
end;

procedure cmdEndIf(s:string);
var
  Addr, Addr2, Addr3: Integer;
begin
  with CurrControl.IFStack do
  begin
    if p<=0 then
    begin
      Error('EndIf 没有 If 匹配');
      Exit;
    end;
    Addr2 := Bin.CurrFunc.Position;
    while ElseCount[p] > 0 do  //将所有if/else块的最后一个跳转地址添上
    begin
      Dec(ElseCount[p]);
      Addr:=Elses[p,ElseCount[p]];
      Addr3 := Addr2 - Addr;
      System.Move(Addr3, Bin.CurrFunc.Data^[Addr], SizeOf(Longint));
    end;
    Addr := Pop;
    if LastIsElse[p + 1] = False then  //将最后一个IF/ELSE IF的跳转地址添上
    begin
      Addr3 := Addr2 - Addr;
      System.Move(Addr3, Bin.CurrFunc.Data^[Addr], SizeOf(Longint));
    end;
  end;

end;

procedure cmdGoto(s: string);
begin
  s:=Trim(s);
  with CurrControl do
  begin
    if GCount>=MAX_GOTO then
       Error('GoTo语句太多')
    else begin
       dMsg('Goto '+s);
       Bin.CurrFunc.WriteCmd(CMD_GOTO);
       inc(GCount);
       Gotos[GCount].LabelName:=s;
       Gotos[GCount].Addr:=Bin.CurrFunc.Position;
       Bin.CurrFunc.WriteLong(0);
    end;
  end;
end;

procedure cmdNext(s:string);
var
  Addr,
  Addr2,
  Addr3: Integer;
  v:     Integer;
  Up:    Boolean;
begin
  if CurrControl.ForStack.p <= 0 then
  begin
     Error('Next 没有 For 匹配');
     Exit;
  end;

  CurrControl.ForStack.FillContinues(CurrControl.ForStack.p);

  Addr := CurrControl.ForStack.Pop(Up,v,Addr2);

  if Up then
  begin
     Bin.CurrFunc.WriteCmd(CMD_INC);
     dMsg('Inc <for_var> @'+IntToStr(v));
  end else begin
     Bin.CurrFunc.WriteCmd(CMD_DEC);
     dMsg('Inc <for_var> @'+IntToStr(v));
  end;
  Bin.CurrFunc.WriteSmall(v);

  Bin.CurrFunc.WriteCmd(CMD_GOTO);
  Addr := Addr - Bin.CurrFunc.Position;
  Bin.CurrFunc.WriteLong(Addr);
  dMsg('Goto *'+IntToStr(Addr));

  Addr3 := Bin.CurrFunc.Position - Addr2;
  System.Move(Addr3, Bin.CurrFunc.Data^[Addr2],4);

  CurrControl.ForStack.FillBreaks(CurrControl.ForStack.p + 1);
end;

procedure cmdFor(s:string);
var i,j:integer;
    ts,lcmd:string;
begin
  if CurrControl.ForStack.p>=StackUnit.Max then
  begin
    Error('For 语句太多');
    Exit;
  end;
  i := Pos(':', s);
  lcmd := #0;
  if i>0 then
  begin
     lcmd := Copy(s, i+1, Length(s));
     Delete(s, i, Length(s));
  end;
  i:=Pos('downto',LowerCase(s));
  if i>0 then     {**For ... downto ...**}
  begin
    cmdLet(Copy(s,1,i-1));
    if Err then Exit;
    j:=1;
    ts:=GetId(s,j);
    delete(s,1,i+6);
    j:=Bin.CurrFunc.Position;
    Bin.CurrFunc.WriteCmd(CMD_PUSHV);
    Bin.CurrFunc.WriteSmall(VarId(ts));
    dMsg('Pushv '+ts+' @ '+IntToStr(VarId(ts)));
    Expr(s);
    Bin.CurrFunc.WriteCmd(CMD_CALCULATE);
    Bin.CurrFunc.WriteByte(OPR_LESS);
    dMsg('Calculate <');
    if Err then Exit;
    Bin.CurrFunc.WriteCmd(CMD_IF);
    CurrControl.ForStack.Push(j,False,VarId(ts),Bin.CurrFunc.Position);
    Bin.CurrFunc.WriteLong(0);
    dMsg('If <Addr>');
  end else begin
    i:=Pos('to',LowerCase(s));
    if i=0 then
    begin
      Error('For 语句中找不到 To 或 DownTo');
      Exit;
    end;
    cmdLet(Copy(s,1,i-1));
    if Err then Exit;
    j:=1;
    ts:=GetId(s,j);
    delete(s,1,i+2);
    j:=Bin.CurrFunc.Position;
    Bin.CurrFunc.WriteCmd(CMD_PUSHV);
    Bin.CurrFunc.WriteSmall(VarId(ts));
    dMsg('Pushv '+ts+' @ '+IntToStr(VarId(ts)));
    Expr(s);
    Bin.CurrFunc.WriteCmd(CMD_CALCULATE);
    Bin.CurrFunc.WriteByte(OPR_MORE);
    dMsg('Calculate >');
    if Err then Exit;
    Bin.CurrFunc.WriteCmd(CMD_IF);
    CurrControl.ForStack.Push(j,True,VarId(ts),Bin.CurrFunc.Position);
    Bin.CurrFunc.WriteLong(0);
    dMsg('If <Addr>');
  end;
  if lcmd<>#0 then
  begin
    CompileOne(lcmd);
    cmdNext('');
  end;
end;

procedure cmdWend(s:string);
var
  Addr,Addr2,Addr3:Integer;
begin
  if CurrControl.WhileStack.p<=0 then
  begin
     Error('Wend 没有 While 匹配');
     Exit;
  end;
  CurrControl.WhileStack.FillContinues(CurrControl.WhileStack.p);
  Bin.CurrFunc.WriteCmd(CMD_GOTO);
  Addr:=CurrControl.WhileStack.Pop(Addr2)-Bin.CurrFunc.Position;
  Bin.CurrFunc.WriteLong(Addr);
  dMsg('Goto *'+IntToStr(Addr));
  Addr3 := Bin.CurrFunc.Position - Addr2;
  System.Move(Addr3,Bin.CurrFunc.Data^[Addr2],4);
  CurrControl.WhileStack.FillBreaks(CurrControl.WhileStack.p + 1);

end;

procedure cmdWhile(s:string);
var i, j : integer;
    lcmd : string;
begin
  if CurrControl.WhileStack.p>=StackUnit.Max then
  begin
    Error('While语句太多');
    Exit;
  end;
  i := Pos(':', s);
  lcmd := #0;
  if i>0 then
  begin
     lcmd := Copy(s, i+1, Length(s));
     Delete(s, i, Length(s));
  end;
  j:=Bin.CurrFunc.Position;
  Expr(s);
  if Err then Exit;
  Bin.CurrFunc.WriteCmd(CMD_IFNOT);
  CurrControl.WhileStack.Push(j,Bin.CurrFunc.Position);
  Bin.CurrFunc.WriteLong(0);
  dMsg('If Not <Addr>');
  if lcmd<>#0 then
  begin
    CompileOne(lcmd);
    cmdWend('');
  end;
end;


procedure cmdRepeat(s:string);
begin
  if CurrControl.RepeatStack.p>=StackUnit.Max then
  begin
    Error('Repeat语句太多');
    Exit;
  end;
  CurrControl.RepeatStack.Push(Bin.CurrFunc.Position);
end;

procedure cmdUntil(s:string);
var
  Addr  :Integer;
begin
  if CurrControl.RepeatStack.p<=0 then
  begin
     Error('Until 没有 Repeat 匹配');
     Exit;
  end;
  CurrControl.RepeatStack.FillContinues(CurrControl.RepeatStack.p);
  Expr(s);
  Bin.CurrFunc.WriteCmd(CMD_IFNOT);
  Addr:=CurrControl.RepeatStack.Pop - Bin.CurrFunc.Position;
  Bin.CurrFunc.WriteLong(Addr);
  dMsg('If Not Then *'+IntToStr(Addr));
  CurrControl.RepeatStack.FillBreaks(CurrControl.RepeatStack.p + 1);
end;

procedure cmdBreak(s: string);
var
  dm: string;
begin
  if CurrControl.LoopStack.p <= 0 then
  begin
    Error('非循环中使用 Break');
    Exit;
  end;
  dm := 'Goto ';
  Bin.CurrFunc.WriteCmd(CMD_GOTO);
  case CurrControl.LoopStack.Peek of
     CTRL_FOR: begin
        CurrControl.ForStack.AddBreak(Bin.CurrFunc.Position);
        dm := dm + '<Next * >';
     end;
     CTRL_WHILE: begin
        CurrControl.WhileStack.AddBreak(Bin.CurrFunc.Position);
        dm := dm + '<Wend * >';
     end;
     CTRL_REPEAT: begin
        CurrControl.RepeatStack.AddBreak(Bin.CurrFunc.Position);
        dm := dm + '<Until * >';
     end;
  end;
  Bin.CurrFunc.WriteLong(0);
  dMsg(dm);
end;

procedure cmdContinue(s: string);
var
  dm: string;
begin
  if CurrControl.LoopStack.p <= 0 then
  begin
    Error('非循环中使用 Continue');
    Exit;
  end;
  dm := 'Goto ';
  Bin.CurrFunc.WriteCmd(CMD_GOTO);
  case CurrControl.LoopStack.Peek of
     CTRL_FOR: begin
        CurrControl.ForStack.AddContinue(Bin.CurrFunc.Position);
        dm := dm + '< * Next>';
     end;
     CTRL_WHILE: begin
        CurrControl.WhileStack.AddContinue(Bin.CurrFunc.Position);
        dm := dm + '< * Wend>';
     end;
     CTRL_REPEAT: begin
        CurrControl.RepeatStack.AddContinue(Bin.CurrFunc.Position);
        dm := dm + '< * Until>';
     end;
  end;
  Bin.CurrFunc.WriteLong(0);
  dMsg(dm);
end;

procedure cmdExit(s: string);
begin
  Bin.CurrFunc.WriteCmd(CMD_EXIT);
  dMsg('Exit');
end;

procedure cmdLock(s: string);
begin
  Bin.CurrFunc.WriteCmd(CMD_LOCK);
  dMsg('Lock');
end;

procedure cmdUnLock(s: string);
begin
  Bin.CurrFunc.WriteCmd(CMD_UNLOCK);
  dMsg('UnLock');
end;

procedure cmdSuspend(s: string);
begin
  Bin.CurrFunc.WriteCmd(CMD_SUSPEND);
  dMsg('Suspend');
end;

procedure cmdCall(s: string);
begin
  s:=Trim(s);
  if Pos('.', s)=0 then s := s+ BinaryFileExt;
  Bin.CurrFunc.WriteCmd(CMD_CALL);
  Bin.CurrFunc.WriteString(s);
  dMsg('Call '+s);
end;

procedure cmdThread(s: string);
begin
  s:=Trim(s);
  if Pos('.', s)=0 then s := s+ BinaryFileExt;
  Bin.CurrFunc.WriteCmd(CMD_THREAD);
  Bin.CurrFunc.WriteString(s);
  dMsg('Thread '+s);
end;


{ 试图以LET语句解释 }
function TryLet(s:string):Boolean;
var i : integer;
begin
  TryLet := False;
  i := FindToken(s, '=', 1);
  if i = 0 then Exit;
  TryLet := True;
  cmdLet(s);
end;

{ 试图以函数/表达式解释 }
function TryFunc(s:string):Boolean;
var
  i, j: integer;
  ts: string;
begin
//  Result := False;
//  i := 1;
//  ts := GetId(s, i);
//  if ts = '' then Exit;
//  j := FindUserFunction(ts);
//  if j>=0 then                        // 用户函数
//  begin
//    CallFunction(UserFuncTable[j], s, i);
//    Result := True;
//  end else begin
//    j := SptFunc.FindSystemFunction(ts);
//    if j>=0 then                       // 系统函数
//    begin
//      CallFunction(SysFuncTable[j], s, i);
//      Result := True;
//    end
//  end;
  Result := True;
  Expr(s);
  if (Result) and not(err) then
  begin
    dMsg('Pop Null');                 // 弹出返回值放入空变量
    Bin.CurrFunc.WriteCmd(CMD_POPNULL);
  end;
end;

procedure DeclareFunction(s: string);
var
  ts, s1: string;
  I, J: Integer;
  Unlimit: Boolean;
  argc: Integer;
begin
  I := 1;
  Unlimit := False;
  ts := GetId(s,I);
  if  LowerCase(ts) = 'open' then
  begin
    ts := GetId(s,I);
    Unlimit := True;
  end;
  if IDHasDefined(ts) then
  begin
    Error('二次定义标识符:'+ts);
    Exit;
  end;
//  if funcs.Count>=255 then
//  begin
//     Error('函数定义过多');
//     exit;
//  end;
  if Unlimit then
  begin
    argc := -1;
  end else begin
    while((i<=Length(s))and(s[i] in SepCharSet)) do Inc(i);
    if (i>Length(s)) or (s[i]<>'(') then
    begin
      Error('找不到左括号');
      Exit;
    end;
    argc := 0;
    s1 := GetId(s, i);
    while s1<>'' do
    begin
      if IDHasDefined(s1) then
      begin
        Error('二次定义标识符:'+ts);
        exit;
      end;
      Inc(argc);
      s1 := GetId(s, i);
    end;
  end;

  J := Bin.AddFuncDeclare(ts);

  Inc(UserFuncCount);
  I := UserFuncCount - 1;
  dMsg('声明新函数:('+s+') # '+IntToStr(I)+', No.='+IntToStr(J));

  with UserFuncTable[I] do
  begin
    Fun_No := J;
    Name := ts;
    ParamCount := argc;
    ReturnValue := True;
    IsSys := False;
  end;

end;

procedure DefineFunction(s: string);
var
  I, J, argc: Integer;
  ts: string;
  s1: string;
  Unlimit: Boolean;
  args: array[0..100] of string;
begin
  s := Trim(s);
  I := 1;
  Unlimit := False;
  ts := GetId(s,I);
  if  LowerCase(ts) = 'open' then
  begin
    ts := GetId(s,I);
    Unlimit := True;
  end;

  J := FindUserFunction(ts);

  if J < 0 then
  begin
    DeclareFunction(s);
    if Err then Exit;
    J := FindUserFunction(ts);
  end;

  if Unlimit then
  begin
    argc := -1;
  end else begin
    while((i<=Length(s))and(s[i] in SepCharSet)) do Inc(i);
    if (i>Length(s)) or (s[i]<>'(') then
    begin
      Error('找不到左括号');
      Exit;
    end;
    argc := 0;
    s1 := GetId(s, I);
    while s1<>'' do
    begin
      args[argc] := s1;
      Inc(argc);
      s1 := GetId(s, I);
    end;
  end;

  if (argc <> UserFuncTable[J].ParamCount) then
  begin
    Error('函数声明和定义不一致');
    Exit;
  end;

  I := Bin.NewFunction(UserFuncTable[J].Fun_No);

  if  I < 0 then
  begin
    Error('太多的函数定义');
    Exit;
  end;

  if I > 1 then
  begin
    Error('函数不能嵌套定义');
    Exit;
  end;

  dMsg('定义新函数:('+s+') # '+IntToStr(J)+', No.='+IntToStr(UserFuncTable[J].Fun_No));


  CurrControl :=  TFuncControl.Create;

  for J := argc - 1 downto 0 do
  begin
    cmdPrivate(args[J]);
    if err then Exit;
    cmdPop(args[J]);
    if err then Exit;
  end;

end;

procedure cmdReturn(s: string);
begin
  if CurrControl = MainControl then
  begin
    cmdExit('');
  end else begin
    s := Trim(s);
    if s<>'' then
    begin
      Expr(s);
      if Err then Exit;
    end else begin
      cmdPush('0');     //如果没有返回值, 默认返回0
    end;
    Bin.CurrFunc.WriteCmd(CMD_RETURN);
    dMsg('Return');
  end;
end;

procedure EndFunction(s: string);
begin
  if CurrControl = MainControl then
  begin
    Error('End 找不到 Function');
    Exit;
  end;
  CurrControl.Free;
  CurrControl := MainControl;
  if Err then Exit;
  if Bin.CurrFunc.IsMain then
  begin
    Error('多余的函数结束命令');
    Exit;
  end;
  s := Trim(s);
  if s<>'' then
  begin
    Expr(s);
    if Err then Exit;
  end else begin
    cmdPush('0');     //如果没有返回值, 默认返回0
  end;

  Bin.CurrFunc.WriteCmd(CMD_RETURN);
  dMsg('Return');
  Bin.MergeFunctions;
  dMsg('* 函数结束');
  localvars.Clear;
end;

procedure funcCallAt;
begin
  Bin.CurrFunc.WriteCmd(CMD_CALLAT);
  dMsg('CallAt');
end;

///////////////////////////////////
//  编译一条指令                 //
///////////////////////////////////
procedure CompileOne(s:string);
begin
  s:=Trim(s);
  DeleteComment(s);
  if CommandList.CallCmd(s) = False then
  begin
     if not(TryLet(s)) and not(TryFunc(s)) then
        Error('未知命令:'+s);
  end;
end;

{ TForStack }

constructor TForStack.Create;
begin
  inherited Create;
end;


function TForStack.Pop(var Up:Boolean;var Id,Addr2:Integer): Integer;
begin
  Up:=IsUp[p];
  Id:=VarId[p];
  Addr2:=Addr2s[p];
  Pop:=inherited Pop;
end;

procedure TForStack.Push(Addr:Integer;aUp:Boolean;Id,Addr2:Integer);
begin
  inherited Push(Addr);
  VarId[p]:=Id;
  IsUp[p]:=aUp;
  Addr2s[p]:=Addr2;
  CurrControl.LoopStack.Push(CTRL_FOR);
end;

{ TWhileStack }

constructor TWhileStack.Create;
begin
  inherited Create;
end;

function TWhileStack.Pop(var Addr2: Integer): Integer;
begin
  Addr2:=Addr2s[p];
  Pop:=inherited Pop;
end;

procedure TWhileStack.Push(Addr, Addr2: Integer);
begin
  inherited Push(Addr);
  CurrControl.LoopStack.Push(CTRL_WHILE);
  Addr2s[p]:=Addr2;
end;

{ TRepeatStack }

constructor TRepeatStack.Create;
begin
  inherited;
end;

procedure TRepeatStack.Push(n: Integer);
begin
  inherited;
  CurrControl.LoopStack.Push(CTRL_REPEAT);
end;

{ TFuncControl }

constructor TFuncControl.Create;
begin
  IFStack:= TIFStack.Create;
  ForStack:= TForStack.Create;
  WhileStack:= TWhileStack.Create;
  RepeatStack:= TRepeatStack.Create;
  LCount:=0;
  GCount:=0;
  LoopStack := TStack.Create;
end;

destructor TFuncControl.Free;
var
  I, J, Addr: Integer;
  P: Boolean;
begin
  if not(Err)and(IfStack.p<>0)then
  begin
     Error('If,Else和Endif不匹配');
  end;
  IFStack.Free;
  if not(Err)and(ForStack.p<>0)then
  begin
     Error('For/Next不匹配');
  end;
  ForStack.Free;
  if not(Err)and(WhileStack.p<>0)then
  begin
     Error('While/Wend不匹配');
  end;
  WhileStack.Free;

  if not(Err)and(RepeatStack.p<>0)then
  begin
     Error('Repeat/Until不匹配');
  end;
  RepeatStack.Free;

  LoopStack.Free;

  if not(Err) then
  begin
    dMsg('* 更新 Goto 地址');
    for I:=1 to GCount do
    begin
       P:=False;
       for J:=1 to LCount do
       if Labels[J].Name=Gotos[I].LabelName then
       begin
         P:=True;Break;
       end;
       if not P then begin
         Error('找不到标号 '+Gotos[I].LabelName);
         Exit;
       end;
//       Inc(Labels[J].Addr, Bin.Position);
       Addr := Labels[J].Addr - Gotos[I].Addr;
       System.Move(Addr, Bin.CurrFunc.Data^[Gotos[I].Addr], Sizeof(Longint));
     end;
  end;
end;

{ TIFStack }

constructor TIFStack.Create;
begin
  inherited Create;
end;

procedure TIFStack.PushElse(ELSEAddr: Integer);
begin
  Elses[p, ElseCount[p]] := ELSEAddr;
  Inc(ElseCount[p]);
end;

{ TLoopCtrlStack }

procedure TLoopCtrlStack.AddBreak(Pos: Integer);
begin
  BreakAddrs[P][BreakCount[P]] := Pos;
  Inc(BreakCount[P]);
end;

procedure TLoopCtrlStack.AddContinue(Pos: Integer);
begin
  ContinueAddrs[P][ContinueCount[P]] := Pos;
  Inc(ContinueCount[P]);
end;

procedure TLoopCtrlStack.FillBreaks(I: Integer);
var
  J: Integer;
  Addr: LongInt;
begin
  for J := 0 to BreakCount[I] - 1 do
  begin
    Addr := Bin.CurrFunc.Position - BreakAddrs[I][J];
    System.Move(Addr,
          Bin.CurrFunc.Data^[BreakAddrs[I][J]], Sizeof(Longint));
  end;
end;

procedure TLoopCtrlStack.FillContinues(I: Integer);
var
  J: Integer;
  Addr: LongInt;
begin
  for J := 0 to ContinueCount[I] - 1 do
  begin
    Addr := Bin.CurrFunc.Position - ContinueAddrs[I][J];
    System.Move(Addr, Bin.CurrFunc.Data^[ContinueAddrs[I][J]], Sizeof(Longint));
  end;
end;

function TLoopCtrlStack.Pop: Integer;
begin
  Pop := inherited Pop;
  CurrControl.LoopStack.Pop;
end;

procedure TLoopCtrlStack.Push(n: Integer);
begin
  inherited;
  ContinueCount[p] := 0;
  BreakCount[p] := 0;
end;


{ TCommandList }

procedure TCommandList.Add(CmdName: string; Proc: TCommandProc);
begin
  CmdNames.Add(CmdName);
  Procs.Add(@Proc);
end;

function TCommandList.CallCmd(CommandLine: string): Boolean;
var
  I: Integer;
  Cmd : string;
begin
  Result := True;
  CommandLine := Trim(CommandLine);
  if CommandLine = '' then Exit;
  I := 1;
  Cmd:=Trim(LowerCase(GetId(CommandLine, I)));
  I := CmdNames.IndexOf(Cmd);
  if I < 0 then
  begin
    Result := False;
    Exit;
  end;
  Delete(CommandLine, 1, Length(Cmd));
  TCommandProc(Procs.Items[I])(CommandLine);
end;

constructor TCommandList.Create;
begin
  CmdNames := TStringList.Create;
  Procs := TList.Create;
end;

destructor TCommandList.Free;
begin
  CmdNames.Free;
  Procs.Free;
end;

procedure InitCommandList;
begin
  CommandList := TCommandList.Create;
  CommandList.Add('private',         cmdPrivate);
  CommandList.Add('public',          cmdPublic);
  CommandList.Add('const',           cmdConst);
  CommandList.Add('push',            cmdPush);
  CommandList.Add('pop',             cmdPop);
  //CommandList.Add('read',            cmdRead);
  //CommandList.Add('write',           cmdWrite);
  //CommandList.Add('writeln',         cmdWriteln);
  CommandList.Add('if',              cmdIf);
  CommandList.Add('else',            cmdElse);
  CommandList.Add('endif',           cmdEndIf);
  CommandList.Add('goto',            cmdGoto);
  CommandList.Add('for',             cmdFor);
  CommandList.Add('next',            cmdNext);
  CommandList.Add('inc',             cmdInc);
  CommandList.Add('dec',             cmdDec);
  CommandList.Add('exit',            cmdExit);
  CommandList.Add('include',         cmdInclude);
  CommandList.Add('lock',            cmdLock);
  CommandList.Add('unlock',          cmdUnlock);
  CommandList.Add('while',           cmdWhile);
  CommandList.Add('wend',            cmdWend);
  CommandList.Add('repeat',          cmdRepeat);
  CommandList.Add('until',           cmdUntil);
  CommandList.Add('call',            cmdCall);
  CommandList.Add('thread',          cmdThread);
  CommandList.Add('break',           cmdBreak);
  CommandList.Add('continue',        cmdContinue);
  CommandList.Add('declare',         DeclareFunction);
  CommandList.Add('function',        DefineFunction);
  CommandList.Add('end',             EndFunction);
  CommandList.Add('return',          cmdReturn);
  CommandList.Add('suspend',         cmdSuspend);

end;

procedure ByCompilerFunction(FuncNo: Integer);
begin
  case FuncNo of
    FUNC_CALLAT: funcCallAt;
  end;
end;
end.
