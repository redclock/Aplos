{+-----------------------------------------------------------------------------+
 | Class:       TAplosSyn
 | Created:     2005-08-19
 | Last change: 2005-08-19
 | Author:      redclock
 | Description: Aplos Scripting Language
 | Version:     1.0
 |
 | Copyright (c) 2005 redclock. All rights reserved.
 |
 | Generated with SynGen.
 +----------------------------------------------------------------------------+}

unit APLOS;

{$I SynEdit.inc}

interface

uses
  SysUtils,
  Classes,
{$IFDEF SYN_CLX}
  QControls,
  QGraphics,
{$ELSE}
  Windows,
  Controls,
  Graphics,
{$ENDIF}
  SynEditTypes,
  SynEditHighlighter;

type
  TtkTokenKind = (
    tkComment,
    tkIdentifier,
    tkIns,
    tkKey,
    tkLabels,
    tkNull,
    tkSpace,
    tkString,
    tkUnknown);

  TRangeState = (rsUnKnown, rsComment1, rsComment2, rsString, rsLabels, rsIns);

  TProcTableProc = procedure of object;

  PIdentFuncTableFunc = ^TIdentFuncTableFunc;
  TIdentFuncTableFunc = function: TtkTokenKind of object;

const
  MaxKey = 102;

type
  TAplosSyn = class(TSynCustomHighlighter)
  private
    fLine: PChar;
    fLineNumber: Integer;
    fProcTable: array[#0..#255] of TProcTableProc;
    fRange: TRangeState;
    Run: LongInt;
    fStringLen: Integer;
    fToIdent: PChar;
    fTokenPos: Integer;
    fTokenID: TtkTokenKind;
    fIdentFuncTable: array[0 .. MaxKey] of TIdentFuncTableFunc;
    fCommentAttri: TSynHighlighterAttributes;
    fIdentifierAttri: TSynHighlighterAttributes;
    fInsAttri: TSynHighlighterAttributes;
    fKeyAttri: TSynHighlighterAttributes;
    fLabelsAttri: TSynHighlighterAttributes;
    fSpaceAttri: TSynHighlighterAttributes;
    fStringAttri: TSynHighlighterAttributes;
    function KeyHash(ToHash: PChar): Integer;
    function KeyComp(const aKey: string): Boolean;
    function Func12: TtkTokenKind;
    function Func15: TtkTokenKind;
    function Func23: TtkTokenKind;
    function Func26: TtkTokenKind;
    function Func28: TtkTokenKind;
    function Func35: TtkTokenKind;
    function Func37: TtkTokenKind;
    function Func38: TtkTokenKind;
    function Func39: TtkTokenKind;
    function Func41: TtkTokenKind;
    function Func43: TtkTokenKind;
    function Func46: TtkTokenKind;
    function Func47: TtkTokenKind;
    function Func48: TtkTokenKind;
    function Func50: TtkTokenKind;
    function Func56: TtkTokenKind;
    function Func57: TtkTokenKind;
    function Func58: TtkTokenKind;
    function Func63: TtkTokenKind;
    function Func64: TtkTokenKind;
    function Func65: TtkTokenKind;
    function Func68: TtkTokenKind;
    function Func71: TtkTokenKind;
    function Func76: TtkTokenKind;
    function Func91: TtkTokenKind;
    function Func96: TtkTokenKind;
    function Func98: TtkTokenKind;
    function Func101: TtkTokenKind;
    function Func102: TtkTokenKind;
    procedure IdentProc;
    procedure UnknownProc;
    function AltFunc: TtkTokenKind;
    procedure InitIdent;
    function IdentKind(MayBe: PChar): TtkTokenKind;
    procedure MakeMethodTables;
    procedure NullProc;
    procedure SpaceProc;
    procedure CRProc;
    procedure LFProc;
    procedure Comment1OpenProc;
    procedure Comment1Proc;
    procedure Comment2OpenProc;
    procedure Comment2Proc;
    procedure StringOpenProc;
    procedure StringProc;
    procedure LabelsOpenProc;
    procedure LabelsProc;
    procedure InsOpenProc;
    procedure InsProc;
  protected
    function GetIdentChars: TSynIdentChars; override;
    function GetSampleSource: string; override;
    function IsFilterStored: Boolean; override;
  public
    constructor Create(AOwner: TComponent); override;
    {$IFNDEF SYN_CPPB_1} class {$ENDIF}
    function GetLanguageName: string; override;
    function GetRange: Pointer; override;
    procedure ResetRange; override;
    procedure SetRange(Value: Pointer); override;
    function GetDefaultAttribute(Index: integer): TSynHighlighterAttributes; override;
    function GetEol: Boolean; override;
    function GetTokenID: TtkTokenKind;
    procedure SetLine(NewValue: String; LineNumber: Integer); override;
    function GetToken: String; override;
    function GetTokenAttribute: TSynHighlighterAttributes; override;
    function GetTokenKind: integer; override;
    function GetTokenPos: Integer; override;
    procedure Next; override;
  published
    property CommentAttri: TSynHighlighterAttributes read fCommentAttri write fCommentAttri;
    property IdentifierAttri: TSynHighlighterAttributes read fIdentifierAttri write fIdentifierAttri;
    property InsAttri: TSynHighlighterAttributes read fInsAttri write fInsAttri;
    property KeyAttri: TSynHighlighterAttributes read fKeyAttri write fKeyAttri;
    property LabelsAttri: TSynHighlighterAttributes read fLabelsAttri write fLabelsAttri;
    property SpaceAttri: TSynHighlighterAttributes read fSpaceAttri write fSpaceAttri;
    property StringAttri: TSynHighlighterAttributes read fStringAttri write fStringAttri;
  end;

implementation

uses
  SynEditStrConst;

{$IFDEF SYN_COMPILER_3_UP}
resourcestring
{$ELSE}
const
{$ENDIF}
  SYNS_FilterAplos = 'Aplos Script|(*.apl)';
  SYNS_LangAplos = 'Aplos';
  SYNS_AttrIns = 'Ins';
  SYNS_AttrLabels = 'Labels';

var
  Identifiers: array[#0..#255] of ByteBool;
  mHashTable : array[#0..#255] of Integer;

procedure MakeIdentTable;
var
  I, J: Char;
begin
  for I := #0 to #255 do
  begin
    case I of
      '_', 'a'..'z', 'A'..'Z': Identifiers[I] := True;
    else
      Identifiers[I] := False;
    end;
    J := UpCase(I);
    case I in ['_', 'A'..'Z', 'a'..'z'] of
      True: mHashTable[I] := Ord(J) - 64
    else
      mHashTable[I] := 0;
    end;
  end;
end;

procedure TAplosSyn.InitIdent;
var
  I: Integer;
  pF: PIdentFuncTableFunc;
begin
  pF := PIdentFuncTableFunc(@fIdentFuncTable);
  for I := Low(fIdentFuncTable) to High(fIdentFuncTable) do
  begin
    pF^ := AltFunc;
    Inc(pF);
  end;
  fIdentFuncTable[12] := Func12;
  fIdentFuncTable[15] := Func15;
  fIdentFuncTable[23] := Func23;
  fIdentFuncTable[26] := Func26;
  fIdentFuncTable[28] := Func28;
  fIdentFuncTable[35] := Func35;
  fIdentFuncTable[37] := Func37;
  fIdentFuncTable[38] := Func38;
  fIdentFuncTable[39] := Func39;
  fIdentFuncTable[41] := Func41;
  fIdentFuncTable[43] := Func43;
  fIdentFuncTable[46] := Func46;
  fIdentFuncTable[47] := Func47;
  fIdentFuncTable[48] := Func48;
  fIdentFuncTable[50] := Func50;
  fIdentFuncTable[56] := Func56;
  fIdentFuncTable[57] := Func57;
  fIdentFuncTable[58] := Func58;
  fIdentFuncTable[63] := Func63;
  fIdentFuncTable[64] := Func64;
  fIdentFuncTable[65] := Func65;
  fIdentFuncTable[68] := Func68;
  fIdentFuncTable[71] := Func71;
  fIdentFuncTable[76] := Func76;
  fIdentFuncTable[91] := Func91;
  fIdentFuncTable[96] := Func96;
  fIdentFuncTable[98] := Func98;
  fIdentFuncTable[101] := Func101;
  fIdentFuncTable[102] := Func102;
end;

function TAplosSyn.KeyHash(ToHash: PChar): Integer;
begin
  Result := 0;
  while ToHash^ in ['_', 'a'..'z', 'A'..'Z'] do
  begin
    inc(Result, mHashTable[ToHash^]);
    inc(ToHash);
  end;
  fStringLen := ToHash - fToIdent;
end;

function TAplosSyn.KeyComp(const aKey: String): Boolean;
var
  I: Integer;
  Temp: PChar;
begin
  Temp := fToIdent;
  if Length(aKey) = fStringLen then
  begin
    Result := True;
    for i := 1 to fStringLen do
    begin
      if mHashTable[Temp^] <> mHashTable[aKey[i]] then
      begin
        Result := False;
        break;
      end;
      inc(Temp);
    end;
  end
  else
    Result := False;
end;

function TAplosSyn.Func12: TtkTokenKind;
begin
  if KeyComp('dec') then Result := tkKey else Result := tkIdentifier;
end;

function TAplosSyn.Func15: TtkTokenKind;
begin
  if KeyComp('if') then Result := tkKey else Result := tkIdentifier;
end;

function TAplosSyn.Func23: TtkTokenKind;
begin
  if KeyComp('end') then Result := tkKey else Result := tkIdentifier;
end;

function TAplosSyn.Func26: TtkTokenKind;
begin
  if KeyComp('inc') then Result := tkKey else Result := tkIdentifier;
end;

function TAplosSyn.Func28: TtkTokenKind;
begin
  if KeyComp('call') then Result := tkKey else Result := tkIdentifier;
end;

function TAplosSyn.Func35: TtkTokenKind;
begin
  if KeyComp('to') then Result := tkKey else Result := tkIdentifier;
end;

function TAplosSyn.Func37: TtkTokenKind;
begin
  if KeyComp('break') then Result := tkKey else Result := tkIdentifier;
end;

function TAplosSyn.Func38: TtkTokenKind;
begin
  if KeyComp('endif') then Result := tkKey else Result := tkIdentifier;
end;

function TAplosSyn.Func39: TtkTokenKind;
begin
  if KeyComp('for') then Result := tkKey else Result := tkIdentifier;
end;

function TAplosSyn.Func41: TtkTokenKind;
begin
  if KeyComp('lock') then Result := tkKey else
    if KeyComp('else') then Result := tkKey else Result := tkIdentifier;
end;

function TAplosSyn.Func43: TtkTokenKind;
begin
  if KeyComp('false') then Result := tkKey else Result := tkIdentifier;
end;

function TAplosSyn.Func46: TtkTokenKind;
begin
  if KeyComp('wend') then Result := tkKey else Result := tkIdentifier;
end;

function TAplosSyn.Func47: TtkTokenKind;
begin
  if KeyComp('pop') then Result := tkKey else Result := tkIdentifier;
end;

function TAplosSyn.Func48: TtkTokenKind;
begin
  if KeyComp('declare') then Result := tkKey else Result := tkIdentifier;
end;

function TAplosSyn.Func50: TtkTokenKind;
begin
  if KeyComp('open') then Result := tkKey else Result := tkIdentifier;
end;

function TAplosSyn.Func56: TtkTokenKind;
begin
  if KeyComp('thread') then Result := tkKey else Result := tkIdentifier;
end;

function TAplosSyn.Func57: TtkTokenKind;
begin
  if KeyComp('goto') then Result := tkKey else
    if KeyComp('while') then Result := tkKey else Result := tkIdentifier;
end;

function TAplosSyn.Func58: TtkTokenKind;
begin
  if KeyComp('exit') then Result := tkKey else Result := tkIdentifier;
end;

function TAplosSyn.Func63: TtkTokenKind;
begin
  if KeyComp('public') then Result := tkKey else
    if KeyComp('next') then Result := tkKey else Result := tkIdentifier;
end;

function TAplosSyn.Func64: TtkTokenKind;
begin
  if KeyComp('push') then Result := tkKey else
    if KeyComp('true') then Result := tkKey else Result := tkIdentifier;
end;

function TAplosSyn.Func65: TtkTokenKind;
begin
  if KeyComp('repeat') then Result := tkKey else Result := tkIdentifier;
end;

function TAplosSyn.Func68: TtkTokenKind;
begin
  if KeyComp('include') then Result := tkKey else Result := tkIdentifier;
end;

function TAplosSyn.Func71: TtkTokenKind;
begin
  if KeyComp('const') then Result := tkKey else Result := tkIdentifier;
end;

function TAplosSyn.Func76: TtkTokenKind;
begin
  if KeyComp('unlock') then Result := tkKey else
    if KeyComp('until') then Result := tkKey else Result := tkIdentifier;
end;

function TAplosSyn.Func91: TtkTokenKind;
begin
  if KeyComp('downto') then Result := tkKey else
    if KeyComp('private') then Result := tkKey else Result := tkIdentifier;
end;

function TAplosSyn.Func96: TtkTokenKind;
begin
  if KeyComp('return') then Result := tkKey else Result := tkIdentifier;
end;

function TAplosSyn.Func98: TtkTokenKind;
begin
  if KeyComp('suspend') then Result := tkKey else Result := tkIdentifier;
end;

function TAplosSyn.Func101: TtkTokenKind;
begin
  if KeyComp('continue') then Result := tkKey else Result := tkIdentifier;
end;

function TAplosSyn.Func102: TtkTokenKind;
begin
  if KeyComp('function') then Result := tkKey else Result := tkIdentifier;
end;

function TAplosSyn.AltFunc: TtkTokenKind;
begin
  Result := tkIdentifier;
end;

function TAplosSyn.IdentKind(MayBe: PChar): TtkTokenKind;
var
  HashKey: Integer;
begin
  fToIdent := MayBe;
  HashKey := KeyHash(MayBe);
  if HashKey <= MaxKey then
    Result := fIdentFuncTable[HashKey]
  else
    Result := tkIdentifier;
end;

procedure TAplosSyn.MakeMethodTables;
var
  I: Char;
begin
  for I := #0 to #255 do
    case I of
      #0: fProcTable[I] := NullProc;
      #10: fProcTable[I] := LFProc;
      #13: fProcTable[I] := CRProc;
      '/': fProcTable[I] := Comment1OpenProc;
      '''': fProcTable[I] := Comment2OpenProc;
      '"': fProcTable[I] := StringOpenProc;
      '@': fProcTable[I] := LabelsOpenProc;
      '#': fProcTable[I] := InsOpenProc;
      #1..#9,
      #11,
      #12,
      #14..#32 : fProcTable[I] := SpaceProc;
      'A'..'Z', 'a'..'z', '_': fProcTable[I] := IdentProc;
    else
      fProcTable[I] := UnknownProc;
    end;
end;

procedure TAplosSyn.SpaceProc;
begin
  fTokenID := tkSpace;
  repeat
    inc(Run);
  until not (fLine[Run] in [#1..#32]);
end;

procedure TAplosSyn.NullProc;
begin
  fTokenID := tkNull;
end;

procedure TAplosSyn.CRProc;
begin
  fTokenID := tkSpace;
  inc(Run);
  if fLine[Run] = #10 then
    inc(Run);
end;

procedure TAplosSyn.LFProc;
begin
  fTokenID := tkSpace;
  inc(Run);
end;

procedure TAplosSyn.Comment1OpenProc;
begin
  Inc(Run);
  if (fLine[Run] = '/') then
  begin
    fRange := rsComment1;
    Comment1Proc;
    fTokenID := tkComment;
  end
  else
    fTokenID := tkIdentifier;
end;

procedure TAplosSyn.Comment1Proc;
begin
  fTokenID := tkComment;
  repeat
    if (fLine[Run] = '#') and
       (fLine[Run + 1] = '1') and
       (fLine[Run + 2] = '3') then
    begin
      Inc(Run, 3);
      fRange := rsUnKnown;
      Break;
    end;
    if not (fLine[Run] in [#0, #10, #13]) then
      Inc(Run);
  until fLine[Run] in [#0, #10, #13];
end;

procedure TAplosSyn.Comment2OpenProc;
begin
  Inc(Run);
  fRange := rsComment2;
  Comment2Proc;
  fTokenID := tkComment;
end;

procedure TAplosSyn.Comment2Proc;
begin
  fTokenID := tkComment;
  repeat
    if (fLine[Run] = '#') and
       (fLine[Run + 1] = '1') and
       (fLine[Run + 2] = '3') then
    begin
      Inc(Run, 3);
      fRange := rsUnKnown;
      Break;
    end;
    if not (fLine[Run] in [#0, #10, #13]) then
      Inc(Run);
  until fLine[Run] in [#0, #10, #13];
end;

procedure TAplosSyn.StringOpenProc;
begin
  Inc(Run);
  fRange := rsString;
  StringProc;
  fTokenID := tkString;
end;

procedure TAplosSyn.StringProc;
begin
  fTokenID := tkString;
  repeat
    if (fLine[Run] = '"') then
    begin
      Inc(Run, 1);
      fRange := rsUnKnown;
      Break;
    end;
    if not (fLine[Run] in [#0, #10, #13]) then
      Inc(Run);
  until fLine[Run] in [#0, #10, #13];
end;

procedure TAplosSyn.LabelsOpenProc;
begin
  Inc(Run);
  fRange := rsLabels;
  LabelsProc;
  fTokenID := tkLabels;
end;

procedure TAplosSyn.LabelsProc;
begin
  fTokenID := tkLabels;
  repeat
    if (fLine[Run] = '#') and
       (fLine[Run + 1] = '1') and
       (fLine[Run + 2] = '3') then
    begin
      Inc(Run, 3);
      fRange := rsUnKnown;
      Break;
    end;
    if not (fLine[Run] in [#0, #10, #13]) then
      Inc(Run);
  until fLine[Run] in [#0, #10, #13];
end;

procedure TAplosSyn.InsOpenProc;
begin
  Inc(Run);
  fRange := rsIns;
  InsProc;
  fTokenID := tkIns;
end;

procedure TAplosSyn.InsProc;
begin
  fTokenID := tkIns;
  repeat
    if (fLine[Run] = '#') and
       (fLine[Run + 1] = '1') and
       (fLine[Run + 2] = '3') then
    begin
      Inc(Run, 3);
      fRange := rsUnKnown;
      Break;
    end;
    if not (fLine[Run] in [#0, #10, #13]) then
      Inc(Run);
  until fLine[Run] in [#0, #10, #13];
end;

constructor TAplosSyn.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fCommentAttri := TSynHighLighterAttributes.Create(SYNS_AttrComment);
  fCommentAttri.Style := [fsItalic];
  fCommentAttri.Foreground := clNavy;
  AddAttribute(fCommentAttri);

  fIdentifierAttri := TSynHighLighterAttributes.Create(SYNS_AttrIdentifier);
  AddAttribute(fIdentifierAttri);

  fInsAttri := TSynHighLighterAttributes.Create(SYNS_AttrIns);
  fInsAttri.Foreground :=  $00FF6FB7;
  AddAttribute(fInsAttri);

  fKeyAttri := TSynHighLighterAttributes.Create(SYNS_AttrReservedWord);
  fKeyAttri.Style := [];
  fKeyAttri.Foreground := clBlue;
  AddAttribute(fKeyAttri);

  fLabelsAttri := TSynHighLighterAttributes.Create(SYNS_AttrLabels);
  fLabelsAttri.Foreground := clGreen;
  AddAttribute(fLabelsAttri);

  fSpaceAttri := TSynHighLighterAttributes.Create(SYNS_AttrSpace);
  AddAttribute(fSpaceAttri);

  fStringAttri := TSynHighLighterAttributes.Create(SYNS_AttrString);
  fStringAttri.Foreground := clRed;
  AddAttribute(fStringAttri);

  SetAttributesOnChange(DefHighlightChange);
  InitIdent;
  MakeMethodTables;
  fDefaultFilter := SYNS_FilterAplos;
  fRange := rsUnknown;
end;

procedure TAplosSyn.SetLine(NewValue: String; LineNumber: Integer);
begin
  fLine := PChar(NewValue);
  Run := 0;
  fLineNumber := LineNumber;
  Next;
end;

procedure TAplosSyn.IdentProc;
begin
  fTokenID := IdentKind((fLine + Run));
  inc(Run, fStringLen);
  while Identifiers[fLine[Run]] do
    Inc(Run);
end;

procedure TAplosSyn.UnknownProc;
begin
{$IFDEF SYN_MBCSSUPPORT}
  if FLine[Run] in LeadBytes then
    Inc(Run,2)
  else
{$ENDIF}
  inc(Run);
  fTokenID := tkUnknown;
end;

procedure TAplosSyn.Next;
begin
  fTokenPos := Run;
    begin
      fRange := rsUnknown;
      fProcTable[fLine[Run]];
    end;
end;

function TAplosSyn.GetDefaultAttribute(Index: integer): TSynHighLighterAttributes;
begin
  case Index of
    SYN_ATTR_COMMENT    : Result := fCommentAttri;
    SYN_ATTR_IDENTIFIER : Result := fIdentifierAttri;
    SYN_ATTR_KEYWORD    : Result := fKeyAttri;
    SYN_ATTR_STRING     : Result := fStringAttri;
    SYN_ATTR_WHITESPACE : Result := fSpaceAttri;
  else
    Result := nil;
  end;
end;

function TAplosSyn.GetEol: Boolean;
begin
  Result := fTokenID = tkNull;
end;

function TAplosSyn.GetToken: String;
var
  Len: LongInt;
begin
  Len := Run - fTokenPos;
  SetString(Result, (FLine + fTokenPos), Len);
end;

function TAplosSyn.GetTokenID: TtkTokenKind;
begin
  Result := fTokenId;
end;

function TAplosSyn.GetTokenAttribute: TSynHighLighterAttributes;
begin
  case GetTokenID of
    tkComment: Result := fCommentAttri;
    tkIdentifier: Result := fIdentifierAttri;
    tkIns: Result := fInsAttri;
    tkKey: Result := fKeyAttri;
    tkLabels: Result := fLabelsAttri;
    tkSpace: Result := fSpaceAttri;
    tkString: Result := fStringAttri;
    tkUnknown: Result := fIdentifierAttri;
  else
    Result := nil;
  end;
end;

function TAplosSyn.GetTokenKind: integer;
begin
  Result := Ord(fTokenId);
end;

function TAplosSyn.GetTokenPos: Integer;
begin
  Result := fTokenPos;
end;

function TAplosSyn.GetIdentChars: TSynIdentChars;
begin
  Result := ['_', 'a'..'z', 'A'..'Z'];
end;

function TAplosSyn.GetSampleSource: string;
begin
  Result := '''test '#13#10 
            ;
end;

function TAplosSyn.IsFilterStored: Boolean;
begin
  Result := fDefaultFilter <> SYNS_FilterAplos;
end;

{$IFNDEF SYN_CPPB_1} class {$ENDIF}
function TAplosSyn.GetLanguageName: string;
begin
  Result := SYNS_LangAplos;
end;

procedure TAplosSyn.ResetRange;
begin
  fRange := rsUnknown;
end;

procedure TAplosSyn.SetRange(Value: Pointer);
begin
  fRange := TRangeState(Value);
end;

function TAplosSyn.GetRange: Pointer;
begin
  Result := Pointer(fRange);
end;

initialization
  MakeIdentTable;
{$IFNDEF SYN_CPPB_1}
  RegisterPlaceableHighlighter(TAplosSyn);
{$ENDIF}
end.
