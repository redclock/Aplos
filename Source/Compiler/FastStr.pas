unit FastStr;

interface

Type
  TFastPosProc = function(
    const aSourceString, aFindString : String;
    const aSourceLen, aFindLen, StartPos : integer
    ) : integer;

function FastReplace(
    var aSourceString : String;
    const aFindString, aReplaceString : String;
    CaseSensitive : Boolean = False) : String;

function FastPos(
  const aSourceString, aFindString : String;
  const aSourceLen, aFindLen, StartPos : integer
  ) : integer;

function FastPosNoCase(
  const aSourceString, aFindString : String;
  const aSourceLen, aFindLen, StartPos : integer
  ) : integer;

function FastPosNoCaseNoUpcaseFindString(
  const aSourceString, aFindString : String;
  const aSourceLen, aFindLen, StartPos : integer
  ) : integer;

function IsBeginOfString(
  const aSubString,aSourceString:String;
  const aSubLen,aSourceLen:integer
  ):boolean;

implementation

function IsBeginOfString(
  const aSubString,aSourceString:String;
  const aSubLen,aSourceLen:integer
  ):boolean;
begin
  if (aSourceLen < aSubLen) or (aSubLen = 0) then
  begin
    result := false;
    exit;
  end;

  asm
    push ESI
    push EDI
    push EBX

    //如果aSourceLen小于aFindLen，退出
    Mov ECX, aSourceLen
    Mov EAX, aSubLen
    Sub ECX, EAX
    JL  @Result0

    mov EDI, aSourceString
    mov ESI, aSubString

    //比较第一个字母
    Mov  Al, [ESI]
    Mov  Ah, [EDI]
    cmp  Ah,Al
    //不相同就直接退出
    jne  @Result0

    //相同，开始比较字符串
    mov  EBX, aSubLen
    //取SubString最后一个字符和SourceString对应字符
    dec  EBX

    //如果这时候已经遇到0，表示匹配结束（第一个字符已经比较）
    Jz @EndOfMatch

    @CompareNext:
    // 取SubString最后一个字符
    mov  Al, [ESI+EBX]
    // 取SourceString对应字符
    mov  Ah, [EDI+EBX]
    // 比较
    cmp  Al, Ah
    // 如果不一样，退出
    jne   @Result0

    // 如果一样，EBX减一
    Dec  EBX
    // 如果EBX <> 0 ("J"ump "N"ot "Z"ero),
    // 继续比较
    Jnz  @CompareNext

    // EBX等于0，比较结束。
    @EndOfMatch:
    mov  Result, 1
    jmp  @TheEnd

    @Result0:
    mov  Result, 0

    @TheEnd:
    pop  EBX
    pop  EDI
    pop  ESI
  end;
end;



// This TYPE declaration will become apparent later.
//The first thing to note here is that I’m passing the SourceLength and FindL
//ength. As neither Source nor Find will alter at any point during FastReplace
//, there’s no need to call the LENGTH subroutine each time!
function FastPos(
  const aSourceString, aFindString : String;
  const aSourceLen, aFindLen, StartPos : integer
  ) : integer;
begin
  // Next, we determine how many bytes we need to
  // scan to find the "start" of aFindString.
// Remove by SunLujiang
{
  SourceLen := aSourceLen;
  SourceLen := SourceLen - aFindLen;
  if (StartPos-1) > SourceLen then begin
    Result := 0;
    Exit;
  end;
  SourceLen := SourceLen - StartPos;
  SourceLen := SourceLen +2;
}
// Remove end

  // The ASM starts here.
  asm
    // Delphi uses ESI, EDI, and EBX a lot,
    // so we must preserve them.
    push ESI
    push EDI
    push EBX

// Add by SunLujiang
    Mov ECX, aSourceLen
    Mov EAX, aFindLen
    Sub ECX, EAX
    JL  @Result0
    Mov EAX, StartPos
    Dec EAX
    Sub ECX, EAX
    JL  @Result0
    Inc ECX
// Add end

    // Get the address of sourceString[1]
    // and Add (StartPos-1).
    // We do this for the purpose of finding
    // the NEXT occurrence, rather than
    // always the first!
    mov EDI, aSourceString
    add EDI, StartPos
    Dec EDI
    // Get the address of aFindString.
    mov ESI, aFindString
    // Note how many bytes we need to
    // look through in aSourceString
    // to find aFindString.

// Remove by SunLujiang
//    mov ECX, SourceLen
// Remove end

    // Get the first char of aFindString;
    // note how it is done outside of the
    // main loop, as it never changes!
    Mov  Al, [ESI]
    // Now the FindFirstCharacter loop!
    @ScaSB:
    // Get the value of the current
    // character in aSourceString.
    // This is equal to ah := EDI^, that
    // is what the [] are around [EDI].
    Mov  Ah, [EDI]
    // Compare this character with aDestString[1].
    cmp  Ah,Al
    // If they're not equal we don't
    // compare the strings.
    jne  @NextChar
    // If they're equal, obviously we do!
    @CompareStrings:
    // Put the length of aFindLen in EBX.
    mov  EBX, aFindLen
    // We DEC EBX to point to the end of
    // the string; that is, we don't want to
    // add 1 if aFindString is 1 in length!
    dec  EBX

    // add by ShengQuanhu
    // If EBX is zero, then we've successfully
    // compared each character; i.e. it's A MATCH!
    // It will be happened when aFindLen=1
    Jz @EndOfMatch
    //add end

//Here’s another optimization tip. People at this point usually PUSH ESI and
//so on and then POP ESI and so forth at the end–instead, I opted not to chan
//ge ESI and so on at all. This saves lots of pushing and popping!
    @CompareNext:
    // Get aFindString character +
    // aFindStringLength (the last char).
    mov  Al, [ESI+EBX]
    // Get aSourceString character (current
    // position + aFindStringLength).
    mov  Ah, [EDI+EBX]
    // Compare them.
    cmp  Al, Ah
    Jz   @Matches
    // If they don't match, we put the first char
    // of aFindString into Al again to continue
    // looking for the first character.
    Mov  Al, [ESI]
    Jmp  @NextChar
    @Matches:
    // If they match, we DEC EBX (point to
    // previous character to compare).
    Dec  EBX
    // If EBX <> 0 ("J"ump "N"ot "Z"ero), we
    // continue comparing strings.
    Jnz  @CompareNext

    //add by Shengquanhu
    @EndOfMatch:
    //add end

    // If EBX is zero, then we've successfully
    // compared each character; i.e. it's A MATCH!
    // Move the address of the *current*
    // character in EDI.
    // Note, we haven't altered EDI since
    // the first char was found.
    mov  EAX, EDI
    // This is an address, so subtract the
    // address of aSourceString[1] to get
    // an actual character position.
    sub  EAX, aSourceString
    // Inc EAX to make it 1-based,
    // rather than 0-based.
    inc  EAX
    // Put it into result.
    mov  Result, EAX
    // Finish this routine!
    jmp  @TheEnd
    @NextChar:
//This is where I jump to when I want to continue searching for the first char
//acter of aFindString in aSearchString:
    // Point EDI (aFindString[X]) to
    // the next character.
    Mov  Ah, [EDI]//先把第一个字符移到Ah中，后面判断是否中文
    Inc  EDI
    // Dec ECX tells us that we've checked
    // another character, and that we're
    // fast running out of string to check!
    dec  ECX
    // If EBX <> 0, then continue scanning
    // for the first character.

    //add by shengquanhu
    //if ah is chinese char,jump again
    jz   @Result0

    cmp  ah, $80
    jb   @ScaSB
    Inc  EDI
    Dec  ECX
    //add by shengquanhu end

    jnz  @ScaSB

    //add by shengquanhu
    @Result0:
    //add by shengquanhu end

    // If EBX = 0, then move 0 into RESULT.
    mov  Result,0
    // Restore EBX, EDI, ESI for Delphi
    // to work correctly.
    // Note that they're POPped in the
    // opposite order they were PUSHed.
    @TheEnd:
    pop  EBX
    pop  EDI
    pop  ESI

  end;
end;

//This routine is an identical copy of FastPOS except where commented! The ide
//a is that when grabbing bytes, it ANDs them with $df, effectively making the
//m lowercase before comparing. Maybe this would be quicker if aFindString was
// made lowercase in one fell swoop at the beginning of the function, saving a
//n AND instruction each time.
function FastPosNoCase(
  const aSourceString, aFindString : String;
  const aSourceLen, aFindLen, StartPos : integer
  ) : integer;
//var
//  SourceLen:integer;
begin
// Remove by SunLujiang
{
  SourceLen := aSourceLen;
  SourceLen := SourceLen - aFindLen;
  if (StartPos-1) > SourceLen then begin
    Result := 0;
    Exit;
  end;
  SourceLen := SourceLen - StartPos;
  SourceLen := SourceLen +2;
}
// Remove by SunLujiang end
  asm
    push ESI
    push EDI
    push EBX

// Add by SunLujiang
    Mov ECX, aSourceLen
    Mov EAX, aFindLen
    Sub ECX, EAX
    JL  @Result0

    Mov EAX, StartPos
    Dec EAX
    Sub ECX, EAX
    JL  @Result0

    Inc ECX
// Add end

    mov EDI, aSourceString
    add EDI, StartPos
    Dec EDI
    mov ESI, aFindString

// Remove by SunLujiang
//    mov ECX, SourceLen
// Remove by SunLujiang end

    Mov  Al, [ESI]

    //add by shengquanhu:just modified the lowercase 'a'..'z'
    cmp Al, $7A
    ja @ScaSB

    cmp Al, $61
    jb @ScaSB
    //end------------------------------------------

    // Make Al uppercase.
    and  Al, $df

    @ScaSB:
    Mov  Ah, [EDI]

    //add by shengquanhu:just modified the lowercase 'a'..'z'
    cmp Ah, $7A
    ja @CompareChar

    cmp Ah, $61
    jb @CompareChar
    //end------------------------------------------

    // Make Ah uppercase.
    and  Ah, $df

    @CompareChar:
    cmp  Ah,Al
    jne  @NextChar
    @CompareStrings:
    mov  EBX, aFindLen
    dec  EBX

    //add by ShengQuanhu
    Jz   @EndOfMatch
    //add end

    @CompareNext:
    mov  Al, [ESI+EBX]
    mov  Ah, [EDI+EBX]

    //add by shengquanhu:just modified the lowercase 'a'..'z'
    cmp Al, $7A
    ja @LowerAh

    cmp Al, $61
    jb @LowerAh
    //end------------------------------------------

    // Make Al and Ah uppercase.
    and  Al, $df

    //add by shengquanhu:just modified the lowercase 'a'..'z'
    @LowerAh:
    cmp Ah, $7A
    ja @CompareChar2

    cmp Ah, $61
    jb @CompareChar2
    //end------------------------------------------

    and  Ah, $df

    @CompareChar2:
    cmp  Al, Ah
    Jz   @Matches
    Mov  Al, [ESI]

    //add by shengquanhu:just modified the lowercase 'a'..'z'
    cmp Al, $7A
    ja @NextChar

    cmp Al, $61
    jb @NextChar
    //end------------------------------------------

    // Make Al uppercase.
    and  Al, $df
    Jmp  @NextChar
    @Matches:
    Dec  EBX
    Jnz  @CompareNext

    //add by Shengquanhu
    @EndOfMatch:
    //add end

    mov  EAX, EDI
    sub  EAX, aSourceString
    inc  EAX
    mov  Result, EAX
    jmp  @TheEnd
    @NextChar:
    mov  ah, [EDI]
    Inc  EDI
    dec  ECX
    //add by shengquanhu
    //if ah is chinese char,jump again
    jz   @Result0
    cmp  ah, $80
    jb   @ScaSB
    Inc  EDI
    Dec  ECX
    //add by shengquanhu end
    jnz  @ScaSB
    @Result0:
    mov  Result,0
    @TheEnd:
    pop  EBX
    pop  EDI
    pop  ESI
  end;
end;

//add by shengquanhu
function FastPosNoCaseNoUpcaseFindString(
  const aSourceString, aFindString : String;
  const aSourceLen, aFindLen, StartPos : integer
  ) : integer;
begin
  asm
    push ESI
    push EDI
    push EBX

    Mov ECX, aSourceLen
    Mov EAX, aFindLen
    Sub ECX, EAX
    JL  @Result0
    Mov EAX, StartPos
    Dec EAX
    Sub ECX, EAX
    JL  @Result0
    Inc ECX

    mov EDI, aSourceString
    add EDI, StartPos
    Dec EDI
    mov ESI, aFindString

    Mov  Al, [ESI]

    @ScaSB:
    Mov  Ah, [EDI]

    cmp Ah, $7A
    ja @CompareChar

    cmp Ah, $61
    jb @CompareChar

    and  Ah, $df

    @CompareChar:
    cmp  Ah,Al
    jne  @NextChar

    @CompareStrings:
    mov  EBX, aFindLen
    dec  EBX
    Jz   @EndOfMatch

    @CompareNext:
    mov  Al, [ESI+EBX]
    mov  Ah, [EDI+EBX]
    cmp Ah, $7A
    ja @CompareChar2

    cmp Ah, $61
    jb @CompareChar2

    and  Ah, $df

    @CompareChar2:
    cmp  Al, Ah
    Jz   @Matches

    Mov  Al, [ESI]
    Jmp  @NextChar

    @Matches:
    Dec  EBX
    Jnz  @CompareNext

    @EndOfMatch:
    mov  EAX, EDI
    sub  EAX, aSourceString
    inc  EAX
    mov  Result, EAX
    jmp  @TheEnd

    @NextChar:
    Mov  ah, [EDI]
    Inc  EDI
    dec  ECX
    jz   @Result0

    cmp  ah, $80
    jb   @ScaSB

    Inc  EDI
    Dec  ECX
    jnz  @ScaSB

    @Result0:
    mov  Result,0

    @TheEnd:
    pop  EBX
    pop  EDI
    pop  ESI
  end;
end;
//add by shengquanhu end

//My move isn’t as fast as MOVE when source and destination are both DWord al
//igned, but it’s certainly faster when they’re not. As we’re moving charac
//ters in a string, it isn’t very likely at all that both source and destinat
//ion are DWord aligned, so moving bytes avoids the cycle penalty of reading/w
//riting DWords across physical boundaries.
procedure MyMove(
  const Source; var Dest; Count : Integer);
asm
// Note: When this function is called,
// Delphi passes the parameters as follows:
// ECX = Count
// EAX = Const Source
// EDX = Var Dest
  // If there are no bytes to copy, just quit
  // altogether; there's no point pushing registers.
  cmp   ECX,0
  Je    @JustQuit
  // Preserve the critical Delphi registers.
  push  ESI
  push  EDI
  // Move Source into ESI (generally the
  // SOURCE register).
  // Move Dest into EDI (generally the DEST
  // register for string commands).
  // This might not actually be necessary,
  // as I'm not using MOVsb etc.
  // I might be able to just use EAX and EDX;
  // there could be a penalty for not using
  // ESI, EDI, but I doubt it.
  // This is another thing worth trying!
  mov   ESI, EAX
  mov   EDI, EDX
  // The following loop is the same as repNZ
  // MovSB, but oddly quicker!
    @Loop:
  // Get the source byte.
  Mov   AL, [ESI]
  // Point to next byte.
  Inc   ESI
  // Put it into the Dest.
  mov   [EDI], AL
  // Point dest to next position.
  Inc   EDI
  // Dec ECX to note how many we have left to copy.
  Dec   ECX
  // If ECX <> 0, then loop.
  Jnz   @Loop
  // Another optimization note.
  // Many people like to do this.
  // Mov AL, [ESI]
  // Mov [EDI], Al
  // Inc ESI
  // Inc ESI
//There’s a hidden problem here. I won’t go into too much detail, but the Pe
//ntium can continue processing instructions while it’s still working out the
// result of INC ESI or INC EDI. If, however, you use them while they’re stil
//l being calculated, the processor will stop until they’re calculated (a pen
//alty). Therefore, I alter ESI and EDI as far in advance as possible of using
// them.
  // Pop the critical Delphi registers
  // that we've altered.
  pop   EDI
  pop   ESI
    @JustQuit:
end;

//Point 1: I pass VAR aSourceString rather than just aSourceString. This is be
//cause I’ll just be passed a pointer to the data rather than a 10M copy of t
//he data itself, which is much quicker!
function FastReplace(
  var aSourceString : String;
  const aFindString, aReplaceString : String;
  CaseSensitive : Boolean = False) : String;
var
  // Size already passed to SetLength,
  // the REAL size of RESULT.
  ActualResultLen,
  // Position of aFindString is aSourceString.
  CurrentPos,
  // Last position the aFindString was found at.
  LastPos,
  // Bytes to copy (that is, lastpos to this pos).
  BytesToCopy,
  // The "running" result length, not the actual one.
  ResultLen,
  // Length of aFindString, to save
  // calling LENGTH repetitively.
  FindLen,
  // Length of aReplaceString, for the same reason.
  ReplaceLen,
  SourceLen         : Integer;
  // This is where I explain the
  // TYPE TFastPosProc from earlier!
  FastPosProc       : TFastPosProc;

//add by shengquanhu
  theFindString     :String;
//add by shengquanhu end

begin
//As this function has the option of being case-insensitive, I’d need to call
// either FastPOS or FastPOSNoCase. The problem is that you’d have to do this
// within a loop. This is a bad idea, since the result never changes throughou
//t the whole operation–in which case we can determine it in advance, like so
//:

  // I don't think I actually need
  // this, but I don't really mind!
  Result := '';
  // Get the lengths of the strings.
  FindLen := Length(aFindString);
  ReplaceLen := Length(aReplaceString);
  SourceLen := Length(aSourceString);

//add by shengquanhu
  if SourceLen < FindLen then
  begin
    result := aSourceString;
    exit;
  end;

  theFindString := aFindString;
  if CaseSensitive then
    FastPosProc := FastPOS
  else
  begin
    FastPOSProc := FastPOSNoCaseNoUpcaseFindString;
    CurrentPos := 1;
    while CurrentPos <= FindLen do
    begin
      if theFindString[CurrentPos] >= #$80 then
        Inc(CurrentPos,1)
      else if (theFindString[CurrentPos] > #$60) and (theFindString[CurrentPos] < #$7B) then
        theFindString[CurrentPos] := char(integer(theFindString[CurrentPos]) and $df);
      inc(CurrentPos);
    end;
  end;
//add by shengquanhu end

  // If we already have room for the replacements,
  // then set the length of the result to
  // the length of the SourceString.
  if ReplaceLen <= FindLen then
    ActualResultLen := SourceLen
  else
    // If not, we need to calculate the
    // worst-case scenario.
    // That is, the Source consists ONLY of
    // aFindString, and we're going to replace
    // every one of them!
    ActualResultLen :=
      SourceLen +
      (SourceLen * ReplaceLen div FindLen) +
      ReplaceLen;
  // Set the length of Result; this
  // will assign the memory, etc.
  SetLength(Result,ActualResultLen);
  CurrentPos := 1;
  ResultLen := 0;
  LastPos := 1;
//Again, I’m eliminating an IF statement in a loop by repeating code–this ap
//proach results in very slightly larger code, but if ever you can trade some
//memory in exchange for speed, go for it!
  if ReplaceLen > 0 then begin
    repeat
      // Get the position of the first (or next)
      // aFindString in aSourceString.
      // Note that there's no If CaseSensitive,
      // I just call FastPOSProc, which is pointing
      // to the correct pre-determined routine.

//add by shengquanhu
      CurrentPos :=
        FastPosProc(aSourceString, theFindString,
          SourceLen, FindLen, CurrentPos);
//add by shengquanhu end;

      // If 0, then we're finished.
      if CurrentPos = 0 then
        break;
      // Number of bytes to copy from the
      // source string is CurrentPos - lastPos,
      // i.e. " cat " in "the cat the".
      BytesToCopy := CurrentPos-LastPos;
      // Copy chars from aSourceString
      // to the end of Result.
      MyMove(aSourceString[LastPos],
        Result[ResultLen+1], BytesToCopy);
      // Copy chars from aReplaceString to
      // the end of Result.
      MyMove(aReplaceString[1],
        Result[ResultLen+1+BytesToCopy], ReplaceLen);
      // Remember, using COPY would copy all of
      // the data over and over again.
      // Never fall into this trap (like a certain
      // software company did).
      // Set the running length to
      ResultLen := ResultLen +
        BytesToCopy + ReplaceLen;
      // Set the position in aSourceString to where
      // we want to continue searching from.
      CurrentPos := CurrentPos + FindLen;
      LastPos := CurrentPos;
    until false;
  end else begin
    // You might have noticed If ReplaceLen > 0.
    // Well, if ReplaceLen = 0, then we're deleting the
    // substrings, rather than replacing them, so we
    // don't need the extra MyMove from aReplaceString.
    repeat
//add by shengquanhu
      CurrentPos :=
        FastPosProc(aSourceString, theFindString,
          SourceLen, FindLen, CurrentPos);
//add by shengquanhu end;

      if CurrentPos = 0 then break;
      BytesToCopy := CurrentPos-LastPos;
      MyMove(aSourceString[LastPos],
        Result[ResultLen+1], BytesToCopy);
      ResultLen := ResultLen +
        BytesToCopy + ReplaceLen;
      CurrentPos := CurrentPos + FindLen;
      LastPos := CurrentPos;
    until false;
  end;
//Now that we’ve finished doing all of the replaces, I just need to adjust th
//e length of the final result:
  Dec(LastPOS);
//Now I set the length to the Length plus the bit of string left. That is, " m
//at" when replacing "the" in "sat on the mat".
  SetLength(Result, ResultLen + (SourceLen-LastPos));
  // If there's a bit of string dangling, then
  // add it to the end of our string.
  if LastPOS+1 <= SourceLen then
    MyMove(aSourceString[LastPos+1],
      Result[ResultLen+1],SourceLen-LastPos);
end;

end.
