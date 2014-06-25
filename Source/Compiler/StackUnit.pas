unit StackUnit;
interface
uses
   SysUtils;
const
    Max=511;
type
  TStack=class
       arr:array[1..MAX] of integer;
       p:integer;
       procedure Push(n: Integer); virtual;
       procedure SetTop(n: Integer);
       function Pop: Integer; virtual;
       function Peek: Integer;

       constructor Create;
  end;

  TVarType = (VT_INT, VT_FLOAT, VT_BOOL, VT_STR, VT_ARRAY, VT_ANY);

  PVar = ^TVar;
  TVar = record
     StrValue:   string;
     case VarType: TVarType of
      VT_INT:   ( IntValue:   Integer );
      VT_FLOAT: ( FloatValue: Double  );
      VT_BOOL:  ( BoolValue:  Boolean);
      VT_ARRAY: ( ArrayValue: Integer);
  end;

  TVarStack = class
     Arr:array[1..MAX] of TVar;
     P:integer;
     procedure Push(n: TVar); virtual;
     procedure SetTop(n: TVar);
     function Pop: TVar; virtual;
     function Peek: TVar;

     constructor Create;
  end;

 function CreateVar(v: Integer): TVar; overload;
 function CreateVar(v: string): TVar; overload;
 function CreateVar(v: Double): TVar; overload;
 function CreateVar(v: Boolean): TVar; overload;

 procedure ToVarType(var v: TVar; ToType: TVarType);

implementation

 procedure ToVarType(var v: TVar; ToType: TVarType);
 begin
   case ToType of
     VT_INT: begin
       case v.VarType of
         VT_INT: ;
         VT_FLOAT: v.IntValue := Trunc(v.FloatValue);
         VT_BOOL: v.IntValue := Ord(v.BoolValue);
         VT_STR:  v.IntValue := StrToIntDef(v.StrValue, 0);
       end;
     end;

     VT_FLOAT:  begin
       case v.VarType of
         VT_INT: v.FloatValue := v.IntValue;
         VT_FLOAT: ;
         VT_BOOL: v.FloatValue := Ord(v.BoolValue);
         VT_STR:  v.FloatValue := StrToFloatDef(v.StrValue, 0);
       end;
     end;

     VT_BOOL:  begin
       case v.VarType of
         VT_INT: v.BoolValue := v.IntValue <> 0;
         VT_FLOAT: v.BoolValue := Trunc(v.FloatValue) <> 0;
         VT_BOOL: ;
         VT_STR:  v.BoolValue := StrToBoolDef(v.StrValue, False);
       end;
     end;

     VT_STR: begin
       case v.VarType of
         VT_INT: v.StrValue := IntToStr(v.IntValue);
         VT_FLOAT: v.StrValue := FloatToStr(v.FloatValue);
         VT_BOOL: v.StrValue := BoolToStr(v.BoolValue);
         VT_STR: ;
       end;
     end;
   end;
   v.VarType := ToType;
 end;

 function CreateVar(v: Integer): TVar;
 begin
   Result.VarType := VT_INT;
   Result.IntValue := v;
 end;

 function CreateVar(v: string): TVar;
 begin
   Result.VarType := VT_STR;
   Result.StrValue := v;
 end;

 function CreateVar(v: Double): TVar;
 begin
   Result.VarType := VT_FLOAT;
   Result.FloatValue := v;
 end;

 function CreateVar(v: Boolean): TVar;
 begin
   Result.VarType := VT_BOOL;
   Result.BoolValue := v;
 end;

 procedure TStack.Push(n:integer);
 begin
   inc(p);arr[p]:=n;
 end;

 function TStack.Pop:integer;
 begin
   Pop:=0;
   if p<=0 then begin
     exit;
   end;
   dec(p);Pop:=arr[p+1];
 end;

 constructor TStack.Create;
 begin
   inherited Create;
   p:=0;
 end;

 function TStack.Peek: Integer;
 begin
   Peek:=0;
   if p<=0 then begin
     exit;
   end;
   Peek:=arr[p];
 end;

procedure TStack.SetTop(n: Integer);
begin
   if p<=0 then begin
     exit;
   end;
   arr[p] := n;
end;

{ TVarStack }

constructor TVarStack.Create;
begin
   inherited Create;
   p:=0;
end;

function TVarStack.Peek: TVar;
begin
   Peek.VarType:=VT_INT;
   if p<=0 then begin
     exit;
   end;
   Peek:=arr[p];
end;

function TVarStack.Pop: TVar;
begin
   Pop.VarType:=VT_INT;
   if p<=0 then begin
     exit;
   end;
   dec(p);
   Pop:=arr[p+1];
end;

procedure TVarStack.Push(n: TVar);
begin
   inc(p);arr[p]:=n;
end;

procedure TVarStack.SetTop(n: TVar);
begin
   if p<=0 then begin
     exit;
   end;
   arr[p] := n;
end;

end.
