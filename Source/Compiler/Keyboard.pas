{此文件是从Free Pascal源代码的
 crt.pp中截取部分并修改而来  }
unit Keyboard;
interface
uses Windows;

function KeyPressed : boolean;
function ReadKey: char;

implementation

var
   ScanCode : char;
   SpecialKey : boolean;
   DoingNumChars: Boolean;
   DoingNumCode: Byte;


Function RemapScanCode (ScanCode: word; CtrlKeyState: dword; keycode:word): byte;
  { Several remappings of scancodes are necessary to comply with what
    we get with MSDOS. Special Windows keys, as Alt-Tab, Ctrl-Esc etc.
    are excluded }
var
  AltKey, CtrlKey, ShiftKey: boolean;
const
  {
    Keypad key scancodes:

      Ctrl Norm

      $77  $47 - Home
      $8D  $48 - Up arrow
      $84  $49 - PgUp
      $8E  $4A - -
      $73  $4B - Left Arrow
      $8F  $4C - 5
      $74  $4D - Right arrow
      $4E  $4E - +
      $75  $4F - End
      $91  $50 - Down arrow
      $76  $51 - PgDn
      $92  $52 - Ins
      $93  $53 - Del
  }
  CtrlKeypadKeys: array[$47..$53] of byte =
    ($77, $8D, $84, $8E, $73, $8F, $74, $4E, $75, $91, $76, $92, $93);

begin
  AltKey := ((CtrlKeyState AND
	    (RIGHT_ALT_PRESSED OR LEFT_ALT_PRESSED)) > 0);
  CtrlKey := ((CtrlKeyState AND
	    (RIGHT_CTRL_PRESSED OR LEFT_CTRL_PRESSED)) > 0);
  ShiftKey := ((CtrlKeyState AND SHIFT_PRESSED) > 0);
  if AltKey then begin
    Case KeyCode of
      VK_NUMPAD0 ..
      VK_NUMPAD9    : begin
		       DoingNumChars := true;
		       DoingNumCode := Byte((DoingNumCode * 10) + (KeyCode - VK_NUMPAD0));
		      end;
    end; { case }


    case ScanCode of
    // Digits, -, =
    $02..$0D: inc(ScanCode, $76);
    // Function keys
    $3B..$44: inc(Scancode, $2D);
    $57..$58: inc(Scancode, $34);
    // Extended cursor block keys
    $47..$49, $4B, $4D, $4F..$53:
	      inc(Scancode, $50);
    // Other keys
    $1C:      Scancode := $A6;	 // Enter
    $35:      Scancode := $A4;	 // / (keypad and normal!)
    end
   end
  else if CtrlKey then
    case Scancode of
    // Tab key
    $0F:      Scancode := $94;
    // Function keys
    $3B..$44: inc(Scancode, $23);
    $57..$58: inc(Scancode, $32);
    // Keypad keys
    $35:      Scancode := $95;	 // \
    $37:      Scancode := $96;	 // *
    $47..$53: Scancode := CtrlKeypadKeys[Scancode];
    end
  else if ShiftKey then
    case Scancode of
    // Function keys
    $3B..$44: inc(Scancode, $19);
    $57..$58: inc(Scancode, $30);
    end
  else
    case Scancode of
    // Function keys
    $57..$58: inc(Scancode, $2E); // F11 and F12
  end;
  Result := ScanCode;
end;

function KeyPressed : boolean;
var
  nevents, nread: dword;
  buf : TINPUTRECORD;
  AltKey: Boolean;
  SpecialKey : boolean;
  DoingNumChars: Boolean;
  DoingNumCode: Byte;
begin
  KeyPressed := FALSE;
  if ScanCode <> #0 then
    KeyPressed := TRUE
  else
   begin
     GetNumberOfConsoleInputEvents(TTextRec(input).Handle,nevents);
     while nevents>0 do
       begin
	  ReadConsoleInputA(TTextRec(input).Handle,buf,1,nread);
	  if buf.EventType = KEY_EVENT then
	    if buf.Event.KeyEvent.bKeyDown then
	      begin
		 { Alt key is VK_MENU }
		 { Capslock key is VK_CAPITAL }

		 AltKey := ((Buf.Event.KeyEvent.dwControlKeyState AND
			    (RIGHT_ALT_PRESSED OR LEFT_ALT_PRESSED)) > 0);
		 if not(Buf.Event.KeyEvent.wVirtualKeyCode in [VK_SHIFT, VK_MENU, VK_CONTROL,
						      VK_CAPITAL, VK_NUMLOCK,
						      VK_SCROLL]) then
		   begin
		      keypressed:=true;

		      if (ord(buf.Event.KeyEvent.AsciiChar) = 0) or			    (buf.Event.KeyEvent.dwControlKeyState and
				     (LEFT_ALT_PRESSED or ENHANCED_KEY) > 0) then
			begin
			   if (ord(buf.Event.KeyEvent.AsciiChar) = 13) and
			      (buf.Event.KeyEvent.wVirtualKeyCode = VK_RETURN) then
			     begin
			       SpecialKey:=false;
			       ScanCode:=Chr(13);
			     end
			   else
			     begin
			       SpecialKey := TRUE;
			       ScanCode := Chr(RemapScanCode(Buf.Event.KeyEvent.wVirtualScanCode, Buf.Event.KeyEvent.dwControlKeyState,
					   Buf.Event.KeyEvent.wVirtualKeyCode));
			     end;
			end
		      else
			begin
			   SpecialKey := FALSE;
			   ScanCode := Chr(Ord(buf.Event.KeyEvent.AsciiChar));
			end;

		      if Buf.Event.KeyEvent.wVirtualKeyCode in [VK_NUMPAD0..VK_NUMPAD9] then
			if AltKey then
			  begin
			     Keypressed := false;
			     Specialkey := false;
			     ScanCode := #0;
			  end
			else break;
		   end;
	      end
	     else if (Buf.Event.KeyEvent.wVirtualKeyCode in [VK_MENU]) then
	       if DoingNumChars then
		 if DoingNumCode > 0 then
		   begin
		      ScanCode := Chr(DoingNumCode);
		      Keypressed := true;

		      DoingNumChars := false;
		      DoingNumCode := 0;
		      break
		   end; { if }
	  { if we got a key then we can exit }
	  if keypressed then
	    exit;
	  GetNumberOfConsoleInputEvents(TTextRec(input).Handle,nevents);
       end;
   end;
end;


function ReadKey: char;
begin
  repeat
    Sleep(1);
  until KeyPressed;

  if SpecialKey then begin
    ReadKey := #0;
    SpecialKey := FALSE;
  end
  else begin
    ReadKey := ScanCode;
    ScanCode := #0;
  end;
end;
end.

