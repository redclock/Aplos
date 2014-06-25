unit Express;

interface
  uses
   SysUtils,
   SptConst,
   StackUnit,
   DefineVar,
   SptBin,
   SptFunc;
  procedure Expr(s:string);
  procedure SkipSeperator(s:string;var i:integer);
  function GetNum(s:string; var i:Integer): Double; overload;
  function GetNum(s:string; var i:Integer; var IsFloat: Boolean): Double; overload;
  function GetItem(s:string;var i:integer):string;
  function GetId(s:string;var i:integer):string;
  function GetString(s:string;var i:integer):string;
  function GetExpr(s:string;var i:integer):string;
  function FindToken(s: string; sub: string; i:Integer): Integer;

const
   SepCharSet   = [' ',',',#13,#10,#9];      //用于分隔的字符

implementation
  uses compile, FastStr;

{ 跳过分隔符 }
procedure SkipSeperator(s:string;var i:integer);
begin
  while (i<=length(s))and(s[i] in SepCharSet) do inc(i);
end;

{ 从s的第i位寻找sub, 并跳过标识符，括号，字符串内}
{如：(aaa)aaa,返回第二个aaa；  abcd abc, 查abc会找到后一个abc，而不是abcd的子串}
function FindToken(s: string; sub: string; i:Integer): Integer;
var
  kh, j, slen, sublen: Integer;
begin
  kh := 0;
  slen := Length(s);
  sublen := Length(sub);
  j := FastPos(s, sub, slen, sublen, i);
  while (j > 0) do
  begin

    while (i < j) do
    begin
      if (s[i] = '"') then
      begin
        GetString(s, i);
        Continue;
      end;
      if (s[i] in ['a'..'z','A'..'Z','_']) then
      begin
        GetId(s, i);
        Continue;
      end;
      if (s[i]='(') or (s[i]='[') then Inc(kh);
      if (s[i]=')') or (s[i]=']') then Dec(kh);
      Inc(i);
    end;

    if (kh = 0) and (i = j) then
    begin
      if not(s[i] in ['a'..'z','A'..'Z','_']) then
      begin
        Break;
      end else if (GetId(s, i) = sub) then
      begin
        Break;
      end;
    end;

    if (s[i]='(') or (s[i]='[') then Inc(kh);
    if (s[i]=')') or (s[i]=']') then Dec(kh);

    if i = j then Inc(i);
    j := FastPos(s, sub, slen, sublen, i);
  end;
  Result := j;
end;

function GetHex(s:string; var i:Integer): Integer;
const
  MAX_HEX_LEN = 8; //32位数十六进制最大长度
var
  ii: Integer;
  r: LongWord;     //先化为无符号数
begin
  ii := i;
  r  := 0;
  while (i <= Length(s)) and (i - ii < MAX_HEX_LEN) do
  begin
    if (s[i] in ['0'..'9']) then
      r := r * 16 + Ord(s[i]) - Ord('0')
    else if (s[i] in ['a'..'f']) then
      r := r * 16 + Ord(s[i]) - Ord('a') + 10
    else if (s[i] in ['A'..'F']) then
      r := r * 16 + Ord(s[i]) - Ord('A') + 10
    else
      Break;
    Inc(i);  
  end;
  Result := Integer(r);
end;

{ 从s的第i位读数字, 并置i为第一个不是数字的地方}
function GetNum(s:string; var i:Integer; var IsFloat: Boolean): Double; overload;
var
  r: Double;
  d: Double;
begin
   r:=0; IsFloat := False;
   SkipSeperator(s, i);
   if Copy(s, i, 2) = '0x' then
   begin
     Inc(i, 2);
     r := GetHex(s, i);
   end else begin
     while (i<=length(s))and(s[i] in ['0'..'9']) do
        begin r:=r*10+ord(s[i])-ord('0');inc(i);end;
     if (i<Length(s)) and (s[i]='.')then
     begin
       IsFloat := True;
       d := 0.1;
       Inc(i);
       while (i<=length(s))and(s[i] in ['0'..'9']) do
       begin
         r:=r+(ord(s[i])-ord('0'))*d;
         inc(i);
         d:=d*0.1;
       end;
     end;
   end;
   Result := r;
end;

function GetNum(s:string; var i:Integer): Double; overload;
var
  IsFloat: Boolean;
begin
  Result := GetNum(s, i, IsFloat);
end;

{ 从s的第i位读项目, 并置i为第一个不是项目的地方}
function GetItem(s:string; var i:integer):string;
var
  r:string;
  kh: Integer;
begin
  r:=''; kh:=0;
  SkipSeperator(s, i);
  while (i<=length(s))and(not(s[i] in SepCharSet) or (kh>0)) and (kh>=0) do
  begin
    if (s[i] = '"') then
    begin
        r := r + '"' + GetString(s, i) + '"';
        Continue;
    end;
    r:=r+s[i];
    if (s[i]='(') or (s[i]='[') then Inc(kh);
    if (s[i]=')') or (s[i]=']') then Dec(kh);
    inc(i);
  end;
  Result := r;
end;

{ 从s的第i位读标识符, 并置i为第一个不是标识符的地方}
function GetId(s:string;var i:integer):string;
var r:string;
begin
  r:='';
  while (i<=length(s))and not(s[i] in ['a'..'z','A'..'Z','_'])
       do inc(i);
  while (i<=length(s))and (s[i] in ['a'..'z','A'..'Z','_','0'..'9'])
       do begin r:=r+s[i];inc(i);end;
  GetId:=r;
end;

{ 从s的第i位读字符串, 并置i为第一个不是字符串的地方}
function GetString(s:string;var i:integer):string;
var r:string;
begin
  r:='';
  while (i<=length(s))and (s[i]<>#34) do inc(i);
  if (i<=length(s)) then inc(i);

  while (i<=length(s))and (s[i]<>#34) do
  begin
    r:=r+s[i];
    inc(i);
  end;
  if (i<=length(s)) then inc(i);
  GetString:=r;
end;

{ 从s的第i位读表达式, 并置i为第一个不是表达式的地方}

function GetExpr(s:string; var i:integer):string;
const
  EndChar = [',', ':', ';'];
var
  r: string;
  kh: Integer;
begin
  r:=''; kh := 0;
  while (i<=length(s)) do
  begin
    if (s[i] in EndChar) and (kh = 0) then Break;
    if ((s[i] = ')') or (s[i] = ']')) and (kh = 0) then Break;
    if (s[i] = '"') then
    begin
        r := r + '"' + GetString(s, i) + '"';
        Continue;
    end;
    if ((s[i] = '(') or (s[i] = '[')) then Inc(kh);
    if ((s[i] = ')') or (s[i] = ']')) then Dec(kh);
    r := r + s[i];
    Inc(i);
  end;
  GetExpr := r;
end;

///////////////////////////////////
//  编译表达式                   //
///////////////////////////////////

procedure Expr(s:string);
var
 n: Double;
 opf,opc,kh,i,j:integer;
 Stack, OpStack: TStack;
 LastOp: Boolean;  //上一个是否是运算符
 LastOpConst: Integer;
 ts: string;
 Nums: integer;    //数字栈中数字的个数
 IsFloat: Boolean;
begin
 Stack := TStack.Create;
 OpStack := TStack.Create;
 kh   := 0;
 i    := 1;
 Nums := 0;
 LastOp := True;
 LastOpConst := 0;
 while i<=length(s) do
 begin
  case s[i] of                     //是符号
  '!','$','<','>','=',
  '+','-','*','/',
  '%','&','^','|','[':begin
      ts:=s[i];
      if (s[i]='<')and(i<length(s)) then   //是 < 还是 <= 或 <>
         if (s[i+1] in ['=','>'])then
           begin
             ts:=ts+s[i+1];inc(i);
           end;
      if (s[i]='>')and(i<length(s)) then   //是 > 还是 >=
         if (s[i+1] ='=')then
           begin
             ts:=ts+s[i+1];inc(i);
           end;
      if s[i]='-' then                     //是减号还是负号
          if LastOp then begin
              ts:='^-';
          end;
      if s[i] = '$' then
      begin
        Inc(i);
        ts := LowerCase(GetId(s, i));
        Dec(i);
      end;
      if ts = '[' then Inc(kh,PRE_GRADE);

      opc := ConstOfOp(ts);                  //得到操作符的id
      opf := PrecedenceOf(opc);              //得到操作符的优先级

      if opc <=0 then
      begin
        Error('非法运算符:' + ts);
      end;

      if LastOp and (opc in DoubleParamOps)  then
      begin
        Error('运算符中缺少数字或变量');
        Exit;
      end;
      if not(LastOpConst in DoubleParamOps) and not(opc in DoubleParamOps)
         and (Stack.Peek >= opf + kh) then
      begin
        Error('非法使用前导运算符');
        Exit;
      end;

      if not (opc in DoubleParamOps) then Inc(Nums);

      while (Stack.p > 0) and (Stack.Peek >= opf+kh) do  //栈里优先级高的先计算
      begin
         Stack.Pop;
         dMsg('Calculate ' + StrOf(OpStack.Peek));
         Dec(Nums);
         Bin.CurrFunc.WriteCmd(CMD_CALCULATE);
         Bin.CurrFunc.WriteByte(OpStack.Pop);
      end;                                                //压入优先级
      Stack.Push(opf+kh);
      OpStack.Push(opc);
      LastOp:=True;
   end;
   '0'..'9':begin                                         //数字
        if LastOp = False then
        begin
          Error('缺少运算符');
          Exit;
        end;

        n:=GetNum(s, i, IsFloat);
        if IsFloat = False then
        begin
          dMsg('Pushi ' + IntToStr(Trunc(n)));
          Bin.CurrFunc.WriteCmd(CMD_PUSHI);
          Bin.CurrFunc.WriteLong(Trunc(n));
        end else begin
          dMsg('Pushf ' + FloatToStr(n));
          Bin.CurrFunc.WriteCmd(CMD_PUSHF);
          Bin.CurrFunc.WriteFloat(n);
        end;
        LastOp:=False;
        dec(i);
        Inc(Nums);
   end;
   '"':begin                                             //字符串
        if LastOp = False then
        begin
          Error('缺少运算符');
          Exit;
        end;
        ts:=GetString(s,i);
        dMsg('Pushs ' + ts);
        Bin.CurrFunc.WriteCmd(CMD_PUSHS);
        Bin.CurrFunc.WriteString(ts);
        LastOp:=False;
        dec(i);
        Inc(Nums);
   end;
   '.':begin                             //点操作符
       if LastOp then
       begin
         Error('运算符中缺少数字或变量');
         Exit;
       end;
       Inc(i);
       ts:= GetId(s, i);
       j := FindUserFunction(ts);
       if j>=0 then                       // 用户函数
       begin
         CallFunction(UserFuncTable[j], s, i, True);
       end else begin
         j := SptFunc.FindSystemFunction(ts);
         if j>=0 then                       // 系统函数
         begin
           CallFunction(SysFuncTable[j], s, i, True);
         end
       end;
       if j < 0 then
       begin
         Error('缺少函数名');
         Exit;
       end;
       Dec(i);
       LastOp := False;
     end;
   'a'..'z','A'..'Z','_':begin          //标识符
        ts:=GetId(s,i);
        if LowerCase(ts) = 'true' then
        begin
          dMsg('Pushb True');
          Bin.CurrFunc.WriteCmd(CMD_PUSHB);
          Bin.CurrFunc.WriteBoolean(True);
          LastOp:=False;
          dec(i);
          Inc(Nums);
        end else if LowerCase(ts) = 'false' then
        begin
          dMsg('Pushb False');
          Bin.CurrFunc.WriteCmd(CMD_PUSHB);
          Bin.CurrFunc.WriteBoolean(False);
          LastOp:=False;
          dec(i);
          Inc(Nums);
        end else begin
          j := FindUserFunction(ts);
          if j>=0 then                       // 用户函数
          begin
            SkipSeperator(s, i);
            if (i <= Length(s)) and (s[i] = '(') then     //如果有括号, 就是调用
            begin
              CallFunction(UserFuncTable[j], s, i, False);
              if err then Break;
            end else begin                                //否则就是取地址
              Bin.CurrFunc.WriteCmd(CMD_PUSHI);
              Bin.CurrFunc.WriteLong(UserFuncTable[j].Fun_No);
              dMsg('Pushi ' + IntToStr(UserFuncTable[j].Fun_No));
            end;
            Inc(Nums);
            LastOp := False;
            Continue;
          end;
          j := SptFunc.FindSystemFunction(ts);
          if j>=0 then                       // 系统函数
          begin
            CallFunction(SysFuncTable[j], s, i, False);
            dec(i);
            Inc(Nums);
            LastOp := False;
          end else begin
            j:=consts.Find(ts);              //常数名
            if j>=0 then
            begin
              Expr(consts.GetValue(j));
              if err then Exit;
              //dMsg('Pushn '+IntTostr(consts.Values[j]));
              //Bin.CurrFunc.WriteByte(CMD_PUSHI);
              //Bin.CurrFunc.WriteLong(0);
              LastOp:=False;
              Dec(i);
              Inc(Nums);
            end else begin            //变量名
              j:=varid(ts);
              if j<0 then
                  begin Error('未定义的变量:'+ts);exit;end;
              dMsg('Pushv '+ts+' @ '+IntToStr(j));
              Bin.CurrFunc.WriteCmd(CMD_PUSHV);
              Bin.CurrFunc.WriteSmall(j);
              LastOp:=False;
              Dec(i);
              Inc(nums);
            end;
          end;
        end;
   end;
   ']':begin                            //数组下标结束
       Dec(kh,PRE_GRADE);
      end;
   '(':begin                            //左括号
        if not LastOp then
        begin
          Error('缺少运算符');
          Exit;
        end;
        inc(kh,PRE_GRADE);
      end;
   ')':dec(kh,PRE_GRADE);               //右括号
   ' ',#9:;
   else begin
      Error('表达式中出现了错误的字符:'+s[i]);
      break;
   end;
  end;
  if err then break;
  inc(i);
 end;
 while not(err)and(Stack.p>0) do begin     //最后清栈
    Stack.Pop;
    dMsg('Calculate ' + StrOf(OpStack.Peek));
    Dec(Nums);
    Bin.CurrFunc.WriteCmd(CMD_CALCULATE);
    Bin.CurrFunc.WriteByte(OpStack.Pop);
 end;
 Stack.Free;
 OpStack.Free;
 if kh<>0 then begin
    Error('括号不匹配');
    Exit;
 end;
 if Nums<>1 then begin
    Error('表达式错误');
    Exit;
 end;

end;



end.
