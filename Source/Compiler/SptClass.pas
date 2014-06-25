unit SptClass;

interface
uses
  SysUtils, Classes, Contnrs, SptFunc;
type

  TAccessLevel = (AL_PRIVATE, AL_PUBLIC, AL_PROTECTED);

  TSptClass = class;             //forward declaration

  TClassMember = class           //base class of both method and field
  protected
    FAccess: TAccessLevel;
    FOwner: TSptClass;           //the class who owns it
  public
    Name: string;
    function VisibleInPublic: Boolean;  //in other code
    function VisibleInChild: Boolean;   //in child method code
    function VisibleInSelf: Boolean;    //in self method code
    constructor Create(Name: string; Access: TAccessLevel; Owner: TSptClass);
  end;

  TMethodDef = class(TClassMember)
  public
    Func: TFuncDef;                 //the function parameters
    IsVirtual: Boolean;             //whether a virtual method
    constructor Create(Name: string; Access: TAccessLevel; Owner: TSptClass);
  end;

  TFieldDef = class(TClassMember)
  public
    constructor Create(Name: string; Access: TAccessLevel; Owner: TSptClass);
  end;

  TSptClass = class
  private
    FName: string;
    FParent: TSptClass;
    FStartIndex: Integer;             //Member index of ItemList[0]
    ItemList: TObjectList;            //Members
  public
    function AddMethod(Name: string; Access: TAccessLevel): TMethodDef;
    function AddField(Name: string; Access: TAccessLevel): TFieldDef;
    function FindMember(Name: string): Integer;
    function GetMemberCount: Integer;
    function GetMemberAt(I: Integer): TClassMember;
    constructor Create(Name: string; Parent: TSptClass);
    destructor Free;
  end;

implementation

{ TSptClass }

function TSptClass.AddField(Name: string; Access: TAccessLevel): TFieldDef;
begin
  Result := TFieldDef.Create(Name, Access, Self);
  ItemList.Add(Result);
end;

function TSptClass.AddMethod(Name: string; Access: TAccessLevel): TMethodDef;
begin
  Result := TMethodDef.Create(Name, Access, Self);
  ItemList.Add(Result);
end;

constructor TSptClass.Create(Name: string; Parent: TSptClass);
begin
  ItemList := TObjectList.Create(True);
  FName := Name;
  FParent := Parent;
  if Parent = nil then FStartIndex := 0
                  else FStartIndex := Parent.GetMemberCount;
end;

function TSptClass.FindMember(Name: string): Integer;
var
  I: Integer;
begin

  if FParent = nil then
    Result := -1
  else begin                                //Find in parent
    Result := FParent.FindMember(Name);
    if Result > 0 then                      //and if it is visible(not private)
      if GetMemberAt(Result).VisibleInChild = False then Result := -1;
  end;

  if Result < 0 then                        //not found in parent
    for I := 0 to ItemList.Count - 1 do
    begin                                   //in self
      if (ItemList.Items[I] as TClassMember).Name = Name then
      begin
        Result := I + FStartIndex;
        Break;
      end;
    end;

end;

destructor TSptClass.Free;
begin
  ItemList.Free;
end;

function TSptClass.GetMemberAt(I: Integer): TClassMember;
begin
  if (I < 0) or (I >= FStartIndex + ItemList.Count) then
    Result := nil
  else if I < FStartIndex then
    Result := FParent.GetMemberAt(I)
  else
    Result := TClassMember(ItemList.Items[I - FStartIndex]);
end;

function TSptClass.GetMemberCount: Integer;
begin
  if FParent = nil then
    Result := ItemList.Count
  else
    Result := FParent.GetMemberCount + ItemList.Count;  
end;

{ TClassMember }

constructor TClassMember.Create(Name: string; Access: TAccessLevel; Owner: TSptClass);
begin
  Self.Name := Name;
  FAccess := Access;
  FOwner := Owner;
end;

function TClassMember.VisibleInChild: Boolean;
begin
  Result := FAccess <> AL_PRIVATE;
end;

function TClassMember.VisibleInPublic: Boolean;
begin
  Result := FAccess = AL_PUBLIC;
end;

function TClassMember.VisibleInSelf: Boolean;
begin
  Result := True;
end;

{ TMethodDef }

constructor TMethodDef.Create(Name: string; Access: TAccessLevel; Owner: TSptClass);
begin
  inherited Create(Name, Access, Owner);
  Func.IsSys := False;
  Func.ByCompiler := False;
  Func.Name := Name;
end;


{ TFieldDef }

constructor TFieldDef.Create(Name: string; Access: TAccessLevel; Owner: TSptClass);
begin
  inherited Create(Name, Access, Owner);
end;

end.
