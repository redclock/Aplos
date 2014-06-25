unit SptCtrl;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

const Main = 0;
const EVT_CLICK      = 0;
const EVT_MOUSEMOVE  = 1;
const EVT_MOUSEUP    = 2;
const EVT_MOUSEDOWN  = 3;
const EVT_KEYDOWN    = 4;
const EVT_KEYUP      = 5;
const EVT_KEYPRESS   = 6;
const EVT_PAINT      = 7;

const MAX_EVT        = 8;

type
  TCtrlKind = (ckForm, ckStatic, ckButton,
               ckCombo, ckEdit, ckCheck,
               ckRadio, ckList, ckPanel);

  TCtrl = TWinControl;

  TEventList = array [0..MAX_EVT - 1] of Integer;

  TEventHandler = class
  private
    EventTable: array[0..255] of TEventList;
    procedure DoOnClick(Sender: TObject);
    procedure DoOnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DoOnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DoOnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DoOnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DoOnKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DoOnKeyPress(Sender: TObject; var Key: Char);
    procedure DoOnPaint(Sender: TObject);
  public
    procedure AddEvent(EvtId: Integer; C: TCtrl;
                  FuncId: Integer; Kind: TCtrlKind);
  end;

  TCtrlList = class
  private
    Items: array[0..255] of TCtrl;
    Kind : array[0..255] of TCtrlKind;
    Events: TEventHandler;
    procedure Error(e: string);
    function GetIDNotUsed: Integer;
  public
    Err: Boolean;
    ErrStr: string;
    Count: Integer;
    procedure SetMain(Main: TForm);
    function  GetMain: TForm;
    function AddStatic(Parent: Integer; Txt: string; x, y, w, h: Integer): Integer;
    function AddButton(Parent: Integer; Txt: string; x, y, w, h: Integer): Integer;
    function AddEdit(Parent: Integer;   Txt: string; x, y, w, h: Integer): Integer;
    function AddCheck(Parent: Integer;  Txt: string; x, y, w, h: Integer; Ck: Boolean): Integer;
    function AddRadio(Parent: Integer;  Txt: string; x, y, w, h: Integer; Ck: Boolean): Integer;
    function AddCombo(Parent: Integer;  Txt: string; x, y, w, h: Integer; CanEdit: Boolean): Integer;
    function AddList(Parent: Integer;  Txt: string; x, y, w, h: Integer): Integer;
    function AddPanel(Parent: Integer;  Txt: string; x, y, w, h: Integer): Integer;
    function GetCtrl(I: Integer): TCtrl;
    procedure DelObject(I: Integer);
    procedure SetText(I: Integer; Txt: string);
    function  GetText(I: Integer): string;
    procedure SetEnabled(I: Integer; en: Boolean);
    function  GetEnabled(I: Integer): Boolean;
    procedure SetVisible(I: Integer; Vis: Boolean);
    function  GetVisible(I: Integer): Boolean;
    function  GetHandle(I: Integer): Integer;
    procedure SetSize(I: Integer; w, h: Integer);
    procedure SetPos(I: Integer; x, y: Integer);
    procedure SetEvent(I: Integer; EvtId: Integer; Fid: Integer);
    function  GetStyle(I: Integer; IsEx: Boolean): Integer;
    procedure SetStyle(I: Integer; Style: Integer; IsEx: Boolean);
    procedure SetAlign(I: Integer; NewAlign: Byte);
    procedure TextOut(I: Integer; X, Y: Integer; Txt: string);
    procedure DrawBox(I: Integer; X1, Y1, X2, Y2: Integer; Fill: Boolean);
    procedure Ellipse(I: Integer; X1, Y1, X2, Y2: Integer);

    procedure ClearAll;
    constructor Create;
    destructor  Free;
  end;


implementation

uses
  StackUnit, Script, fmMain;

{ TCtrlList }

function TCtrlList.AddButton(Parent: Integer; Txt: string; x,
  y, w, h: Integer): Integer;
var
  I: Integer;
  P: TCtrl;
begin
  Result := -1;
  P := GetCtrl(Parent);
  if Err then Exit;
  I := GetIDNotUsed;
  Result := I;
  if I < 0 then
  begin
    Error('控件太多');
    Exit;
  end;
  Items[I] := TButton.Create(nil);
  Kind[I] := ckButton;
  with (Items[I] as TButton) do
  begin
    Caption := Txt;
    Tag := I;
    Parent := P;
    Top := y; Left := x; Width := w; Height := h;
    Visible := True;
  end;
  Inc(Count);
end;


function TCtrlList.AddCheck(Parent: Integer; Txt: string; x, y, w, h: Integer;
  Ck: Boolean): Integer;
var
  I: Integer;
  P: TCtrl;
begin
  Result := -1;
  P := GetCtrl(Parent);
  if Err then Exit;
  I := GetIDNotUsed;
  Result := I;
  if I < 0 then
  begin
    Error('控件太多');
    Exit;
  end;
  Items[I] := TCheckBox.Create(nil);
  Kind[I] := ckCheck;
  with (Items[I] as TCheckBox) do
  begin
    Caption := Txt;
    Tag := I;
    Parent := P;
    Top := y; Left := x; Width := w; Height := h;
    Visible := True;
    Checked := Ck;
  end;
  Inc(Count);
end;


function TCtrlList.AddCombo(Parent: Integer; Txt: string; x, y, w, h: Integer;
  CanEdit: Boolean): Integer;
var
  I: Integer;
  P: TCtrl;
begin
  Result := -1;
  P := GetCtrl(Parent);
  if Err then Exit;
  I := GetIDNotUsed;
  Result := I;
  if I < 0 then
  begin
    Error('控件太多');
    Exit;
  end;
  Items[I] := TComboBox.Create(nil);
  Kind[I] := ckCombo;
  with (Items[I] as TComboBox) do
  begin
    Text := Txt;
    Tag := I;
    Parent := P;
    Top := y; Left := x; Width := w; Height := h;
    if CanEdit then
      Style := csDropDown
    else
      Style := csDropDownList;
    Visible := True;
  end;
  Inc(Count);
end;


function TCtrlList.AddEdit(Parent: Integer; Txt: string; x, y, w,
  h: Integer): Integer;
var
  I: Integer;
  P: TCtrl;
begin
  Result := -1;
  P := GetCtrl(Parent);
  if Err then Exit;
  I := GetIDNotUsed;
  Result := I;
  if I < 0 then
  begin
    Error('控件太多');
    Exit;
  end;
  Items[I] := TMemo.Create(nil);
  Kind[I] := ckEdit;
  with (Items[I] as TMemo) do
  begin
    Text := Txt;
    Tag := I;
    Parent := P;
    Top := y; Left := x; Width := w; Height := h;
    Visible := True;
    WordWrap := False;
  end;
  Inc(Count);
end;

function TCtrlList.AddList(Parent: Integer; Txt: string; x, y, w,
  h: Integer): Integer;
var
  I: Integer;
  P: TCtrl;
begin
  Result := -1;
  P := GetCtrl(Parent);
  if Err then Exit;
  I := GetIDNotUsed;
  Result := I;
  if I < 0 then
  begin
    Error('控件太多');
    Exit;
  end;
  Items[I] := TListBox.Create(nil);
  Kind[I] := ckList;
  with (Items[I] as TListBox) do
  begin
    AddItem(Txt, nil);
    Tag := I;
    Parent := P;
    Top := y; Left := x; Width := w; Height := h;
    Visible := True;
  end;
  Inc(Count);
end;

function TCtrlList.AddPanel(Parent: Integer; Txt: string; x, y, w,
  h: Integer): Integer;
var
  I: Integer;
  P: TCtrl;
begin
  Result := -1;
  P := GetCtrl(Parent);
  if Err then Exit;
  I := GetIDNotUsed;
  Result := I;
  if I < 0 then
  begin
    Error('控件太多');
    Exit;
  end;
  Items[I] := TPanel.Create(nil);
  Kind[I] := ckPanel;
  with (Items[I] as TPanel) do
  begin
    Caption := Txt;
    Tag := I;
    Parent := P;
    Top := y; Left := x; Width := w; Height := h;
    Visible := True;
  end;
  Inc(Count);
end;

function TCtrlList.AddRadio(Parent: Integer; Txt: string; x, y, w,
  h: Integer; Ck: Boolean): Integer;
var
  I: Integer;
  P: TCtrl;
begin
  Result := -1;
  P := GetCtrl(Parent);
  if Err then Exit;
  I := GetIDNotUsed;
  Result := I;
  if I < 0 then
  begin
    Error('控件太多');
    Exit;
  end;
  Items[I] := TRadioButton.Create(nil);
  Kind[I] := ckRadio;
  with (Items[I] as TRadioButton) do
  begin
    Caption := Txt;
    Tag := I;
    Parent := P;
    Top := y; Left := x; Width := w; Height := h;
    Visible := True;
    Checked := Ck;
  end;
  Inc(Count);
end;
function TCtrlList.AddStatic(Parent: Integer; Txt: string; x,
  y, w, h: Integer): Integer;
var
  I: Integer;
  P: TCtrl;
begin
  Result := -1;
  P := GetCtrl(Parent);
  if Err then Exit;
  I := GetIDNotUsed;
  Result := I;
  if I < 0 then
  begin
    Error('控件太多');
    Exit;
  end;
  Items[I] := TStaticText.Create(nil);
  Kind[I] := ckStatic;
  with (Items[I] as TStaticText) do
  begin
    AutoSize := True;
    Caption := Txt;
    Tag := I;
    Parent := P;
    Top := y; Left := x; Width := w; Height := h;
    Visible := True;
  end;
  Inc(Count);
end;

procedure TCtrlList.ClearAll;
var
  I: Integer;
begin
  if Count <= 1 then Exit;
  for I := 1 to 255 do
    if Items[I] <> nil then
    begin
      try
       Items[I].Free;
     except
      end;
      Items[I] := nil;
    end;
  Count := 1;
  Err := False;
end;

constructor TCtrlList.Create;
begin
  FillChar(Items, SizeOf(Items), 0);
  Count := 1;
  Events := TEventHandler.Create;
end;

procedure TCtrlList.DelObject(I: Integer);
begin
  if (I >= 0) and (I<=255) and (Items[I] <>nil) then
  begin
    try
      Items[I].Free;
    except
    end;
  end else
    Error('非法控件标识');
  Dec(Count);
end;

procedure TCtrlList.Error(e: string);
begin
  Err := True;
  ErrStr := e;
end;

destructor TCtrlList.Free;
begin
  ClearAll;
  Events.Free;
end;

function TCtrlList.GetCtrl(I: Integer): TCtrl;
begin
  if (I >= 0) and (I<=255) and (Items[I] <> nil) then
    Result := Items[I]
  else begin
    Error('非法控件标识');
    Result := nil;
  end;
end;

function TCtrlList.GetEnabled(I: Integer): Boolean;
var
  C: TCtrl;
begin
  Result := False;
  C := GetCtrl(I);
  if Err then Exit;
  Result := C.Enabled;
end;

function TCtrlList.GetHandle(I: Integer): Integer;
var
  C: TCtrl;
begin
  Result := 0;
  C := GetCtrl(I);
  if Err then Exit;
  Result := C.Handle;
end;
function TCtrlList.GetIDNotUsed: Integer;
var
  I: Integer;
begin
  Result := -1;
  if Count >= 256 then
    Result := -1
  else if Items[Count] = nil then
    Result := Count
  else  begin
    for I := 1 to 255 do
      if Items[I] = nil then Result := I;
  end;
end;

function TCtrlList.GetMain: TForm;
begin
  Result := Items[0] as TForm;
end;

function TCtrlList.GetText(I: Integer): string;
var
  C: TCtrl;
begin
  Result := '';
  C := GetCtrl(I);
  if Err then Exit;
  case Kind[I] of
    ckForm:     Result := (C as TForm).Caption;
    ckStatic:   Result := (C as TStaticText).Caption;
    ckButton:   Result := (C as TButton).Caption;
    ckCombo:   Result := (C as TComboBox).Text;
    ckEdit:   Result := (C as TMemo).Text;
    ckCheck:   Result := (C as TCheckBox).Caption;
    ckRadio:   Result := (C as TRadioButton).Caption;
    ckList:   Result := (C as TListBox).Items.Text;
    ckPanel:   Result := (C as TPanel).Caption;
  end;
end;

function TCtrlList.GetVisible(I: Integer): Boolean;
var
  C: TCtrl;
begin
  Result := False;
  C := GetCtrl(I);
  if Err then Exit;
  Result := C.Visible;
end;

function TCtrlList.GetStyle(I: Integer; IsEx: Boolean): Integer;
var
  C: TCtrl;
begin
  C := GetCtrl(I);
  if IsEx then
     Result := GetWindowLong(C.Handle, GWL_EXSTYLE)
  else
     Result := GetWindowLong(C.Handle, GWL_STYLE);
end;

procedure TCtrlList.SetEnabled(I: Integer; en: Boolean);
var
  C: TCtrl;
begin
  C := GetCtrl(I);
  if Err then Exit;
  C.Enabled := en;
end;

procedure TCtrlList.SetEvent(I, EvtId, Fid: Integer);
var
  C: TCtrl;
begin
  C := GetCtrl(I);
  if Err then Exit;
  Events.AddEvent(EvtId, C, Fid, Kind[I]);
end;

procedure TCtrlList.SetMain(Main: TForm);
begin
  Items[0] := Main;
end;

procedure TCtrlList.SetPos(I, x, y: Integer);
var
  C: TCtrl;
begin
  C := GetCtrl(I);
  if Err then Exit;
  C.Left := x;
  C.Top := y;
end;

procedure TCtrlList.SetSize(I, w, h: Integer);
var
  C: TCtrl;
begin
  C := GetCtrl(I);
  if Err then Exit;
  C.Width := w;
  C.Height := h;
end;


procedure TCtrlList.SetText(I: Integer; Txt: string);
var
  C: TCtrl;
begin
  C := GetCtrl(I);
  if Err then Exit;
  case Kind[I] of
    ckForm:     (C as TForm).Caption := Txt;
    ckStatic:   (C as TStaticText).Caption := Txt;
    ckButton:   (C as TButton).Caption := Txt;
    ckCombo:    (C as TComboBox).Text := Txt;
    ckEdit:     (C as TMemo).Lines.Text := Txt;
    ckCheck:    (C as TCheckBox).Caption := Txt;
    ckRadio:    (C as TRadioButton).Caption := Txt;
    ckList:     (C as TListBox).Items.Text := Txt;
    ckPanel:    (C as TPanel).Caption := Txt;
  end;
end;
procedure TCtrlList.SetVisible(I: Integer; Vis: Boolean);
var
  C: TCtrl;
begin
  C := GetCtrl(I);
  if Err then Exit;
  C.Visible := Vis;
end;

procedure TCtrlList.SetStyle(I, Style: Integer;
  IsEx: Boolean);
var
  C: TCtrl;
begin
  C := GetCtrl(I);
  if IsEx then
     SetWindowLong(C.Handle, GWL_EXSTYLE, Style)
  else
     SetWindowLong(C.Handle, GWL_STYLE, Style);
end;

procedure TCtrlList.SetAlign(I: Integer; NewAlign: Byte);
var
  C: TCtrl;
begin
  C := GetCtrl(I);
  if NewAlign in [Byte(Low(TAlign))..Byte(High(TAlign))] then
      C.Align := TAlign(NewAlign);
end;



procedure TCtrlList.TextOut(I, X, Y: Integer; Txt: string);
var
  C: TCtrl;
begin
  C := GetCtrl(I);
  if Kind[I] = ckForm then
  begin
    TForm(C).Canvas.TextOut(X, Y, Txt);
  end;
end;

procedure TCtrlList.DrawBox(I, X1, Y1, X2, Y2: Integer; Fill: Boolean);
var
  C: TCtrl;
begin
  C := GetCtrl(I);
  if Kind[I] = ckForm then
  begin
    if Fill then
      TForm(C).Canvas.FillRect(Rect(X1, Y1, X2, Y2))
    else
      TForm(C).Canvas.Rectangle(Rect(X1, Y1, X2, Y2));
  end;
end;


procedure TCtrlList.Ellipse(I, X1, Y1, X2, Y2: Integer);
var
  C: TCtrl;
begin
  C := GetCtrl(I);
  if Kind[I] = ckForm then
  begin
    TForm(C).Canvas.Ellipse(Rect(X1, Y1, X2, Y2))
  end;
end;

{ TEventHandler }

procedure TEventHandler.AddEvent(EvtId: Integer; C: TCtrl;
  FuncId: Integer; Kind: TCtrlKind);
var
  I: Integer;
begin
  I := C.Tag;
  if EvtId < MAX_EVT then
  begin
    EventTable[I][EvtId] := FuncId;
    case EvtId of
      EVT_CLICK: begin
        case Kind of
          ckForm: TForm(C).OnClick := DoOnClick;
          ckStatic: TStaticText(C).OnClick := DoOnClick;
          ckEdit: TEdit(C).OnClick := DoOnClick;
          ckButton: TButton(C).OnClick := DoOnClick;
          ckCombo: TComboBox(C).OnClick := DoOnClick;
          ckCheck: TCheckBox(C).OnClick := DoOnClick;
          ckRadio: TRadioButton(C).OnClick := DoOnClick;
          ckList: TListBox(C).OnClick := DoOnClick;
          ckPanel: TPanel(C).OnClick := DoOnClick;
        end;
      end;
      EVT_MOUSEMOVE: begin
        case Kind of
          ckForm: TForm(C).OnMouseMove := DoOnMouseMove;
          ckStatic: TStaticText(C).OnMouseMove := DoOnMouseMove;
          ckEdit: TEdit(C).OnMouseMove := DoOnMouseMove;
          ckButton: TButton(C).OnMouseMove := DoOnMouseMove;
          //ckCombo: TComboBox(C).OnMouseMove := DoOnMouseMove;
          ckCheck: TCheckBox(C).OnMouseMove := DoOnMouseMove;
          ckRadio: TRadioButton(C).OnMouseMove := DoOnMouseMove;
          ckList: TListBox(C).OnMouseMove := DoOnMouseMove;
          ckPanel: TPanel(C).OnMouseMove := DoOnMouseMove;
        end;
      end;
      EVT_MOUSEDOWN: begin
        case Kind of
          ckForm: TForm(C).OnMouseDown := DoOnMouseDown;
          ckStatic: TStaticText(C).OnMouseDown := DoOnMouseDown;
          ckEdit: TEdit(C).OnMouseDown := DoOnMouseDown;
          ckButton: TButton(C).OnMouseDown := DoOnMouseDown;
          //ckCombo: TComboBox(C).OnMouseDown := DoOnMouseDown;
          ckCheck: TCheckBox(C).OnMouseDown := DoOnMouseDown;
          ckRadio: TRadioButton(C).OnMouseDown := DoOnMouseDown;
          ckList: TListBox(C).OnMouseDown := DoOnMouseDown;
          ckPanel: TPanel(C).OnMouseDown := DoOnMouseDown;
        end;
      end;
      EVT_MOUSEUP: begin
        case Kind of
          ckForm: TForm(C).OnMouseUp := DoOnMouseUp;
          ckStatic: TStaticText(C).OnMouseUp := DoOnMouseUp;
          ckEdit: TEdit(C).OnMouseUp := DoOnMouseUp;
          ckButton: TButton(C).OnMouseUp := DoOnMouseUp;
          //ckCombo: TComboBox(C).OnMouseUp := DoOnMouseUp;
          ckCheck: TCheckBox(C).OnMouseUp := DoOnMouseUp;
          ckRadio: TRadioButton(C).OnMouseUp := DoOnMouseUp;
          ckList: TListBox(C).OnMouseUp := DoOnMouseUp;
          ckPanel: TPanel(C).OnMouseUp := DoOnMouseUp;
        end;
      end;
      EVT_KEYDOWN: begin
        case Kind of
          ckForm: TForm(C).OnKeyDown := DoOnKeyDown;
          //ckStatic: TStaticText(C).OnKeyDown := DoOnKeyDown;
          ckEdit: TEdit(C).OnKeyDown := DoOnKeyDown;
          ckButton: TButton(C).OnKeyDown := DoOnKeyDown;
          ckCombo: TComboBox(C).OnKeyDown := DoOnKeyDown;
          ckCheck: TCheckBox(C).OnKeyDown := DoOnKeyDown;
          ckRadio: TRadioButton(C).OnKeyDown := DoOnKeyDown;
          ckList: TListBox(C).OnKeyDown := DoOnKeyDown;
          //ckPanel: TPanel(C).OnKeyDown := DoOnKeyDown;
        end;
      end;
      EVT_KEYUP: begin
        case Kind of
          ckForm: TForm(C).OnKeyUp := DoOnKeyUp;
          //ckStatic: TStaticText(C).OnKeyUp := DoOnKeyUp;
          ckEdit: TEdit(C).OnKeyUp := DoOnKeyUp;
          ckButton: TButton(C).OnKeyUp := DoOnKeyUp;
          ckCombo: TComboBox(C).OnKeyUp := DoOnKeyUp;
          ckCheck: TCheckBox(C).OnKeyUp := DoOnKeyUp;
          ckRadio: TRadioButton(C).OnKeyUp := DoOnKeyUp;
          ckList: TListBox(C).OnKeyUp := DoOnKeyUp;
          //ckPanel: TPanel(C).OnKeyUp := DoOnKeyUp;
        end;
      end;
      EVT_KEYPRESS: begin
        case Kind of
          ckForm: TForm(C).OnKeyPress := DoOnKeyPress;
          //ckStatic: TStaticText(C).OnKeyPress := DoOnKeyPress;
          ckEdit: TEdit(C).OnKeyPress := DoOnKeyPress;
          ckButton: TButton(C).OnKeyPress := DoOnKeyPress;
          ckCombo: TComboBox(C).OnKeyPress := DoOnKeyPress;
          ckCheck: TCheckBox(C).OnKeyPress := DoOnKeyPress;
          ckRadio: TRadioButton(C).OnKeyPress := DoOnKeyPress;
          ckList: TListBox(C).OnKeyPress := DoOnKeyPress;
          //ckPanel: TPanel(C).OnKeyPress := DoOnKeyPress;
        end;
      end;
      EVT_PAINT: begin
        case Kind of
          ckForm: TForm(C).OnPaint := DoOnPaint;
        end;
      end else begin

      end;
    end;
  end;
end;

procedure TEventHandler.DoOnClick(Sender: TObject);
var
  I : Integer;
begin
  if (Script.IsRunning) and (Script.Suspended = False) then Exit;
  I := TWinControl(Sender).Tag;
  MainForm.CallScriptFuntion(EventTable[I][EVT_CLICK], [CreateVar(I)]);
end;

procedure TEventHandler.DoOnKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  I : Integer;
  A : TVar;
begin
  if (Script.IsRunning) and (Script.Suspended = False) then Exit;
  I := TWinControl(Sender).Tag;
  A := MainForm.CallScriptFuntion(EventTable[I][EVT_KEYDOWN],
             [CreateVar(I), CreateVar(Key), CreateVar(Byte(Shift))]);
  ToVarType(A, VT_INT);
  Key := A.IntValue;
end;

procedure TEventHandler.DoOnKeyPress(Sender: TObject; var Key: Char);
var
  I : Integer;
begin
  if (Script.IsRunning) and (Script.Suspended = False) then Exit;
  I := TWinControl(Sender).Tag;
  MainForm.CallScriptFuntion(EventTable[I][EVT_KEYPRESS],
             [CreateVar(I), CreateVar(Key)]);
end;

procedure TEventHandler.DoOnKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  I : Integer;
  A : TVar;
begin
  if (Script.IsRunning) and (Script.Suspended = False) then Exit;
  I := TWinControl(Sender).Tag;
  A := MainForm.CallScriptFuntion(EventTable[I][EVT_KEYUP],
             [CreateVar(I), CreateVar(Key), CreateVar(Byte(Shift))]);
  ToVarType(A, VT_INT);
  Key := A.IntValue;
end;

procedure TEventHandler.DoOnMouseDown(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer);
var
  I : Integer;
begin
  if (Script.IsRunning) and (Script.Suspended = False) then Exit;
  I := TWinControl(Sender).Tag;
  MainForm.CallScriptFuntion( EventTable[I][EVT_MOUSEDOWN],
     [CreateVar(I), CreateVar(Byte(Button)), CreateVar(Byte(Shift)),
        CreateVar(X), CreateVar(Y)] );
end;

procedure TEventHandler.DoOnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  I : Integer;
begin
  if (Script.IsRunning) and (Script.Suspended = False) then Exit;
  I := TWinControl(Sender).Tag;
  MainForm.CallScriptFuntion( EventTable[I][EVT_MOUSEMOVE],
     [CreateVar(I), CreateVar(Byte(Shift)), CreateVar(X), CreateVar(Y)] );
end;

procedure TEventHandler.DoOnMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
var
  I : Integer;
begin
  if (Script.IsRunning) and (Script.Suspended = False) then Exit;
  I := TWinControl(Sender).Tag;
  MainForm.CallScriptFuntion( EventTable[I][EVT_MOUSEUP],
     [CreateVar(I), CreateVar(Byte(Button)), CreateVar(Byte(Shift)), CreateVar(X), CreateVar(Y)] );
end;

procedure TEventHandler.DoOnPaint(Sender: TObject);
var
  I : Integer;
begin
  if (Script.IsRunning) and (Script.Suspended = False) then Exit;
  I := TWinControl(Sender).Tag;
  MainForm.CallScriptFuntion(EventTable[I][EVT_PAINT], [CreateVar(I)]);
end;

end.
