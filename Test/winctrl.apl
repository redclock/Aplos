const Main = 0
const EVT_CLICK      = 0
const EVT_MOUSEMOVE  = 1
const EVT_MOUSEUP    = 2
const EVT_MOUSEDOWN  = 3
const EVT_KEYDOWN    = 4
const EVT_KEYUP      = 5
const EVT_KEYPRESS   = 6
const EVT_PAINT      = 7

const AL_NONE     = 0
const AL_TOP      = 1
const AL_BOTTOM   = 2
const AL_LEFT     = 3
const AL_RIGHT    = 4
const AL_CLIENT   = 5

const WS_OVERLAPPED       = 0x00000000
const WS_POPUP            = 0x80000000
const WS_CHILD            = 0x40000000
const WS_MINIMIZE         = 0x20000000
const WS_VISIBLE          = 0x10000000
const WS_DISABLED         = 0x08000000
const WS_CLIPSIBLINGS     = 0x04000000
const WS_CLIPCHILDREN     = 0x02000000
const WS_MAXIMIZE         = 0x01000000
const WS_CAPTION          = 0x00C00000     // WS_BORDER | WS_DLGFRAME
const WS_BORDER           = 0x00800000
const WS_DLGFRAME         = 0x00400000
const WS_VSCROLL          = 0x00200000
const WS_HSCROLL          = 0x00100000
const WS_SYSMENU          = 0x00080000
const WS_THICKFRAME       = 0x00040000
const WS_GROUP            = 0x00020000
const WS_TABSTOP          = 0x00010000

const WS_MINIMIZEBOX      = 0x00020000
const WS_MAXIMIZEBOX      = 0x00010000


const WS_TILED            = WS_OVERLAPPED
const WS_ICONIC           = WS_MINIMIZE
const WS_SIZEBOX          = WS_THICKFRAME
const WS_TILEDWINDOW      = WS_OVERLAPPEDWINDOW

// Common Window Styles

const WS_OVERLAPPEDWINDOW = (WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX)

const WS_POPUPWINDOW      = (WS_POPUP | WS_BORDER | WS_SYSMENU)

const WS_CHILDWINDOW      = (WS_CHILD)

//* Extended Window Styles */
const WS_EX_DLGMODALFRAME     = 0x00000001
const WS_EX_NOPARENTNOTIFY    = 0x00000004
const WS_EX_TOPMOST           = 0x00000008
const WS_EX_ACCEPTFILES       = 0x00000010
const WS_EX_TRANSPARENT       = 0x00000020

const WS_EX_MDICHILD          = 0x00000040
const WS_EX_TOOLWINDOW        = 0x00000080
const WS_EX_WINDOWEDGE        = 0x00000100
const WS_EX_CLIENTEDGE        = 0x00000200
const WS_EX_CONTEXTHELP       = 0x00000400

const WS_EX_RIGHT             = 0x00001000
const WS_EX_LEFT              = 0x00000000
const WS_EX_RTLREADING        = 0x00002000
const WS_EX_LTRREADING        = 0x00000000
const WS_EX_LEFTSCROLLBAR     = 0x00004000
const WS_EX_RIGHTSCROLLBAR    = 0x00000000

const WS_EX_CONTROLPARENT     = 0x00010000
const WS_EX_STATICEDGE        = 0x00020000
const WS_EX_APPWINDOW         = 0x00040000


const WS_EX_OVERLAPPEDWINDOW  = (WS_EX_WINDOWEDGE | WS_EX_CLIENTEDGE)
const WS_EX_PALETTEWINDOW     = (WS_EX_WINDOWEDGE | WS_EX_TOOLWINDOW | WS_EX_TOPMOST)

const WS_EX_LAYERED           = 0x00080000

const WS_EX_NOINHERITLAYOUT   = 0x00100000 // Disable inheritence of mirroring by children
const WS_EX_LAYOUTRTL         = 0x00400000 // Right to left mirroring
const WS_EX_COMPOSITED        = 0x02000000
const WS_EX_NOACTIVATE        = 0x08000000
