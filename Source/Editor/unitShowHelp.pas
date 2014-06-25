unit unitShowHelp;

interface
uses
  Windows, Messages, SysUtils, Classes;


procedure ShowHelpFile(Handle: THandle; FileName: string);

implementation

const
  HH_DISPLAY_TOC   = $0001;
  HH_DISPLAY_TOPIC = $0000;
  HH_CLOSE_ALL     = $0012;
  HH_DISPLAY_INDEX = $0002;
  HH_HELP_CONTEXT  = $000F;
  HH_DISPLAY_SEARCH= $0003;
  HH_DISPLAY_TEXT_POPUP = $000E;

type
  HH_FTS_Query = record
    cbStruct : integer; // sizeof structure
    fUniCodeStrings : bool; // true if all strings are unicode
    pszSearchQuery : PChar; // string with the search query
    iProximity : longint; // word proximity
    fStemmedSearch : bool; // true for stemmed search only
    fTitleOnly : bool; // true for title search only
    fExecute : bool; // true to initiate the search
    pszWindow : PChar; // window to display in
  end; // HH_FTS_Query

  HH_POPUP = record
    cbStruct: integer;       // sizeof this structure
    hinst: longint;          // instance handle for string resource
    idString: UINT;          // string resource id, or text id if pszFile is specified in HtmlHelp call
    pszText: LPCTSTR;        // used if idString is zero
    pt: TPOINT;              // top center of popup window
    clrForeground: COLORREF; // use -1 for default
    clrBackground: COLORREF; // use -1 for default
    rcMargins: TRECT;        // amount of space between edges of window and text, -1 for each member to ignore
    pszFont: LPCTSTR;        // facename, point size, char set, BOLD ITALIC UNDERLINE
   end;



function HtmlHelp(hwndCaller: HWND; pszFile: PChar; uCommand: UINT;
    dwData: PDWORD): HWND; stdcall; external 'hhctrl.ocx' Name 'HtmlHelpA';

procedure ShowHelpFile(Handle: THandle; FileName: string);
begin
  HtmlHelp(Handle, PChar(FileName), HH_DISPLAY_TOPIC, nil);
end;

end.
