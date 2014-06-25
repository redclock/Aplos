unit Oper;

interface
uses
   StackUnit;

procedure AddVar(var a, b: TVar);
procedure SubVar(var a, b: TVar);
procedure MulVar(var a, b: TVar);
procedure DivVar(var a, b: TVar);
procedure ModVar(var a, b: TVar);
procedure EqVar(var a, b: TVar);
procedure NoEqVar(var a, b: TVar);
procedure MoreVar(var a, b: TVar);
procedure NoMoreVar(var a, b: TVar);
procedure NoLessVar(var a, b: TVar);
procedure LessVar(var a, b: TVar);
procedure NotVar(var a: TVar);
procedure AndVar(var a, b: TVar);
procedure OrVar(var a, b: TVar);
procedure XorVar(var a, b: TVar);
procedure NegVar(var a: TVar);
procedure ArrVar(var a, b: TVar);

implementation
uses
  Script;
procedure AddVar(var a, b: TVar);
begin
  if (a.VarType = VT_INT) then
  begin

    if (b.VarType = VT_INT) then
      Inc(a.IntValue, b.IntValue)
    else if (b.VarType = VT_FLOAT) then
    begin
      a.VarType := VT_FLOAT;
      a.FloatValue := a.IntValue + b.FloatValue;
    end else
      ErrStr := '运算类型不匹配';

  end else if (a.VarType = VT_FLOAT) then
  begin

    if (b.VarType = VT_INT) then
      a.FloatValue := a.FloatValue + b.IntValue
    else if (b.VarType = VT_FLOAT) then
      a.FloatValue := a.FloatValue + b.FloatValue
    else
      ErrStr := '运算类型不匹配';

  end else if (a.VarType = VT_STR) then
  begin
    if (b.VarType = VT_STR) then
      a.StrValue := a.StrValue + b.StrValue
    else
      ErrStr := '运算类型不匹配';
  end else
    ErrStr := '运算类型不匹配';

end;

procedure SubVar(var a, b: TVar);
begin
  if (a.VarType = VT_INT) then
  begin

    if (b.VarType = VT_INT) then
      Dec(a.IntValue, b.IntValue)
    else if (b.VarType = VT_FLOAT) then
    begin
      a.VarType := VT_FLOAT;
      a.FloatValue := a.IntValue - b.FloatValue;
    end else
      ErrStr := '运算类型不匹配';

  end else if (a.VarType = VT_FLOAT) then
  begin

    if (b.VarType = VT_INT) then
      a.FloatValue := a.FloatValue - b.IntValue
    else if (b.VarType = VT_FLOAT) then
      a.FloatValue := a.FloatValue - b.FloatValue
    else
      ErrStr := '运算类型不匹配';

  end else
    ErrStr := '运算类型不匹配';

end;

procedure MulVar(var a, b: TVar);
  function MakeStrN(s: string; n: Integer): string;
  begin
    Result := '';
    while n > 0 do
    begin
      Result := Result + s;
      Dec(n);
    end;
  end;

begin
  if (a.VarType = VT_INT) then
  begin

    if (b.VarType = VT_INT) then
      a.IntValue := a.IntValue * b.IntValue
    else if (b.VarType = VT_FLOAT) then
    begin
      a.VarType := VT_FLOAT;
      a.FloatValue := a.IntValue * b.FloatValue
    end else if (b.VarType = VT_STR) then
    begin
      a.VarType := VT_STR;
      a.StrValue := MakeStrN(b.StrValue, a.IntValue)
    end else
      ErrStr := '运算类型不匹配';

  end else if (a.VarType = VT_FLOAT) then
  begin

    if (b.VarType = VT_INT) then
      a.FloatValue := a.FloatValue * b.IntValue
    else if (b.VarType = VT_FLOAT) then
      a.FloatValue := a.FloatValue * b.FloatValue
    else
      ErrStr := '运算类型不匹配';

  end else if (a.VarType = VT_STR) then
  begin
    if (b.VarType = VT_INT) then
      a.StrValue := MakeStrN(a.StrValue,  b.IntValue)
    else
      ErrStr := '运算类型不匹配';
  end else
    ErrStr := '运算类型不匹配';

end;

procedure DivVar(var a, b: TVar);
begin
  if (b.VarType = VT_INT) then
  begin
    if b.IntValue = 0 then
    begin
      ErrStr := '除零错误';
      Exit;
    end;
    if (a.VarType = VT_INT) then
    begin
      a.VarType := VT_FLOAT;
      a.FloatValue := a.IntValue / b.IntValue;
    end else if (a.VarType = VT_FLOAT) then
      a.FloatValue := a.FloatValue / b.IntValue
    else
      ErrStr := '运算类型不匹配';

  end else if (b.VarType = VT_FLOAT) then
  begin
    if b.FloatValue = 0 then
    begin
      ErrStr := '除零错误';
      Exit;
    end;
    if (a.VarType = VT_INT) then
    begin
      a.VarType := VT_FLOAT;
      a.FloatValue := a.IntValue / b.FloatValue;
    end else if (a.VarType = VT_FLOAT) then
      a.FloatValue := a.FloatValue / b.FloatValue
    else
      ErrStr := '运算类型不匹配';

  end else
    ErrStr := '运算类型不匹配';

end;

procedure ModVar(var a, b: TVar);
begin
  if a.VarType = VT_FLOAT then ToVarType(a, VT_INT);
  if b.VarType = VT_FLOAT then ToVarType(b, VT_INT);

  if (b.VarType = VT_INT) then
  begin
    if b.IntValue = 0 then
    begin
      ErrStr := '除零错误';
      Exit;
    end;
    if (a.VarType = VT_INT) then
      a.IntValue := a.IntValue mod b.IntValue
    else
      ErrStr := '运算类型不匹配';

  end else
    ErrStr := '运算类型不匹配';
end;

procedure AndVar(var a, b: TVar);
begin
  if (a.VarType = VT_INT) then
  begin

    if (b.VarType = VT_INT) then
    begin
      a.IntValue := a.IntValue and b.IntValue
    end else
      ErrStr := '运算类型不匹配'

  end else if (a.VarType = VT_BOOL) then
  begin

    if (b.VarType = VT_BOOL) then
      a.BoolValue := a.BoolValue and b.BoolValue
    else
      ErrStr := '运算类型不匹配';

  end else
    ErrStr := '运算类型不匹配';

end;

procedure NotVar(var a: TVar);
begin
  if (a.VarType = VT_INT) then
    a.IntValue := not a.IntValue
  else if (a.VarType = VT_BOOL) then
    a.BoolValue := not a.BoolValue
  else
    ErrStr := '运算类型不匹配';
end;

procedure OrVar(var a, b: TVar);
begin
  if (a.VarType = VT_INT) then
  begin

    if (b.VarType = VT_INT) then
    begin
      a.IntValue := a.IntValue or b.IntValue
    end else
      ErrStr := '运算类型不匹配';

  end else if (a.VarType = VT_BOOL) then
  begin

    if (b.VarType = VT_BOOL) then
      a.BoolValue := a.BoolValue or b.BoolValue
    else
      ErrStr := '运算类型不匹配';

  end else
    ErrStr := '运算类型不匹配';

end;

procedure XorVar(var a, b: TVar);
begin
  if (a.VarType = VT_INT) then
  begin

    if (b.VarType = VT_INT) then
    begin
      a.IntValue := a.IntValue xor b.IntValue
    end else
      ErrStr := '运算类型不匹配';

  end else if (a.VarType = VT_BOOL) then
  begin

    if (b.VarType = VT_BOOL) then
      a.BoolValue := a.BoolValue xor b.BoolValue
    else
      ErrStr := '运算类型不匹配';

  end else
    ErrStr := '运算类型不匹配';

end;

procedure MoreVar(var a, b: TVar);
var
  c: TVar;
begin
  c.VarType := VT_BOOL;
  if (a.VarType = VT_INT) then
  begin

    if (b.VarType = VT_INT) then
      c.BoolValue := a.IntValue > b.IntValue
    else if (b.VarType = VT_FLOAT) then
      c.BoolValue := a.IntValue > b.FloatValue
    else
      ErrStr := '运算类型不匹配';

  end else if (a.VarType = VT_FLOAT) then
  begin

    if (b.VarType = VT_INT) then
      c.BoolValue := a.FloatValue > b.IntValue
    else if (b.VarType = VT_FLOAT) then
      c.BoolValue := a.FloatValue > b.FloatValue
    else
      ErrStr := '运算类型不匹配';

  end else if (a.VarType = VT_STR) then
  begin
    if (b.VarType = VT_STR) then
      c.BoolValue := a.StrValue > b.StrValue
    else
      ErrStr := '运算类型不匹配';
  end else
    ErrStr := '运算类型不匹配';

  a := c;
end;

procedure LessVar(var a, b: TVar);
var
  c: TVar;
begin
  c.VarType := VT_BOOL;
  if (a.VarType = VT_INT) then
  begin

    if (b.VarType = VT_INT) then
      c.BoolValue := a.IntValue < b.IntValue
    else if (b.VarType = VT_FLOAT) then
      c.BoolValue := a.IntValue < b.FloatValue
    else
      ErrStr := '运算类型不匹配';

  end else if (a.VarType = VT_FLOAT) then
  begin

    if (b.VarType = VT_INT) then
      c.BoolValue := a.FloatValue < b.IntValue
    else if (b.VarType = VT_FLOAT) then
      c.BoolValue := a.FloatValue < b.FloatValue
    else
      ErrStr := '运算类型不匹配';

  end else if (a.VarType = VT_STR) then
  begin
    if (b.VarType = VT_STR) then
      c.BoolValue := a.StrValue < b.StrValue
    else
      ErrStr := '运算类型不匹配';
  end else
    ErrStr := '运算类型不匹配';

  a := c;
end;

procedure NoMoreVar(var a, b: TVar);
var
  c: TVar;
begin
  c.VarType := VT_BOOL;
  if (a.VarType = VT_INT) then
  begin

    if (b.VarType = VT_INT) then
      c.BoolValue := a.IntValue <= b.IntValue
    else if (b.VarType = VT_FLOAT) then
      c.BoolValue := a.IntValue <= b.FloatValue
    else
      ErrStr := '运算类型不匹配';

  end else if (a.VarType = VT_FLOAT) then
  begin

    if (b.VarType = VT_INT) then
      c.BoolValue := a.FloatValue <= b.IntValue
    else if (b.VarType = VT_FLOAT) then
      c.BoolValue := a.FloatValue <= b.FloatValue
    else
      ErrStr := '运算类型不匹配';

  end else if (a.VarType = VT_STR) then
  begin
    if (b.VarType = VT_STR) then
      c.BoolValue := a.StrValue <= b.StrValue
    else
      ErrStr := '运算类型不匹配';
  end else
    ErrStr := '运算类型不匹配';

  a := c;
end;

procedure NoLessVar(var a, b: TVar);
var
  c: TVar;
begin
  c.VarType := VT_BOOL;
  if (a.VarType = VT_INT) then
  begin

    if (b.VarType = VT_INT) then
      c.BoolValue := a.IntValue >= b.IntValue
    else if (b.VarType = VT_FLOAT) then
      c.BoolValue := a.IntValue >= b.FloatValue
    else
      ErrStr := '运算类型不匹配';

  end else if (a.VarType = VT_FLOAT) then
  begin

    if (b.VarType = VT_INT) then
      c.BoolValue := a.FloatValue >= b.IntValue
    else if (b.VarType = VT_FLOAT) then
      c.BoolValue := a.FloatValue >= b.FloatValue
    else
      ErrStr := '运算类型不匹配';

  end else if (a.VarType = VT_STR) then
  begin
    if (b.VarType = VT_STR) then
      c.BoolValue := a.StrValue >= b.StrValue
    else
      ErrStr := '运算类型不匹配';
  end else
    ErrStr := '运算类型不匹配';

  a := c;
end;

procedure EqVar(var a, b: TVar);
var
  c: TVar;
begin
  c.VarType := VT_BOOL;
  if (a.VarType = VT_INT) then
  begin

    if (b.VarType = VT_INT) then
      c.BoolValue := a.IntValue = b.IntValue
    else if (b.VarType = VT_FLOAT) then
      c.BoolValue := a.IntValue = b.FloatValue
    else
      c.BoolValue := False;

  end else if (a.VarType = VT_FLOAT) then
  begin

    if (b.VarType = VT_INT) then
      c.BoolValue := a.FloatValue = b.IntValue
    else if (b.VarType = VT_FLOAT) then
      c.BoolValue := a.FloatValue = b.FloatValue
    else
      c.BoolValue := False;

  end else if (a.VarType = VT_STR) then
  begin
    if (b.VarType = VT_STR) then
      c.BoolValue := a.StrValue = b.StrValue
    else
      c.BoolValue := False;

  end else if (a.VarType = VT_BOOL) then
  begin
    if (b.VarType = VT_BOOL) then
      c.BoolValue := a.BoolValue = b.BoolValue
    else
      c.BoolValue := False;

  end else if (a.VarType = VT_ARRAY) then
  begin
    if (b.VarType = VT_ARRAY) then
      c.BoolValue := a.ArrayValue = b.ArrayValue
    else
      c.BoolValue := False;

  end else
    ErrStr := '运算类型不匹配';

  a := c;
end;

procedure NoEqVar(var a, b: TVar);
var
  c: TVar;
begin
  c.VarType := VT_BOOL;
  if (a.VarType = VT_INT) then
  begin

    if (b.VarType = VT_INT) then
      c.BoolValue := a.IntValue <> b.IntValue
    else if (b.VarType = VT_FLOAT) then
      c.BoolValue := a.IntValue <> b.FloatValue
    else
      c.BoolValue := True;

  end else if (a.VarType = VT_FLOAT) then
  begin

    if (b.VarType = VT_INT) then
      c.BoolValue := a.FloatValue <> b.IntValue
    else if (b.VarType = VT_FLOAT) then
      c.BoolValue := a.FloatValue <> b.FloatValue
    else
      c.BoolValue := True;

  end else if (a.VarType = VT_STR) then
  begin
    if (b.VarType = VT_STR) then
      c.BoolValue := a.StrValue <> b.StrValue
    else
      c.BoolValue := True;
  end else if (a.VarType = VT_BOOL) then

  begin
    if (b.VarType = VT_BOOL) then
      c.BoolValue := a.BoolValue <> b.BoolValue
    else
      c.BoolValue := True;
  end else if (a.VarType = VT_ARRAY) then
  begin
    if (b.VarType = VT_ARRAY) then
      c.BoolValue := a.ArrayValue <> b.ArrayValue
    else
      c.BoolValue := True;
  end else
    ErrStr := '运算类型不匹配';

  a := c;
end;

procedure NegVar(var a: TVar);
begin
  if (a.VarType = VT_INT) then
    a.IntValue := - a.IntValue
  else if (a.VarType = VT_FLOAT) then
    a.FloatValue := - a.FloatValue
  else if (a.VarType = VT_BOOL) then
    a.BoolValue := not a.BoolValue
  else
    ErrStr := '运算类型不匹配';
end;

procedure ArrVar(var a, b: TVar);
var
  I, Arr: Integer;
begin
  if (b.VarType = VT_INT) then
  begin
    I := b.IntValue;
    if (a.VarType = VT_ARRAY) then     //数组取下标
    begin
      Arr := a.ArrayValue;
      if not ArrayManager.AvailableID(Arr) then
      begin
         ErrStr := '非法数组';
         Exit;
      end;
      if (I >= ArrayManager.GetBound(Arr)) or (I < 0) then
      begin
         ErrStr := '下标越界';
         Exit;
      end;
      a := ArrayManager.Items[Arr][I];
    end else if (a.VarType = VT_STR) then
    begin                                    //字符串取字符
      if (I > 0) and (I <= Length(a.StrValue)) then
      begin
        a.StrValue := a.StrValue[I];
      end else begin
        a.StrValue := '';
      end;
    end else begin
      ErrStr := '运算类型不匹配';
    end;
  end else begin
    ErrStr := '数组下标不是整型';
  end;
end;

end.
