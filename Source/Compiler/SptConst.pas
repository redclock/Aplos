
unit SptConst;

interface

const

    OPR_ADD = 1; {OPERATORS}
    OPR_SUB = 2;
    OPR_MUL = 3;
    OPR_DIV = 4;
    OPR_ARR = 5;
    OPR_NOT = 6;
    OPR_AND = 7;
    OPR_OR  = 8;
    OPR_XOR = 9;
    OPR_MORE = 10;
    OPR_LESS = 11;
    OPR_NOMORE = 12;
    OPR_NOLESS = 13;
    OPR_EQ   = 14;
    OPR_NOEQ = 15;
    OPR_NEG = 16;
    OPR_POS = 17;
    OPR_MOD = 18;
    OPR_TOINT = 19;
    OPR_TOFLOAT = 20;
    OPR_TOSTR = 21;
    OPR_TOBOOL = 22;
type
    TCmdType =
    (
           CMD_NOP,
           CMD_PUSHI,
           CMD_PUSHF,
           CMD_PUSHS,
           CMD_PUSHB,
           CMD_PUSHA,  //5
           CMD_PUSHV,
           CMD_POP,
           CMD_POPNULL,
           CMD_CALCULATE,
           CMD_IF,     //10
           CMD_IFNOT,
           CMD_GOTO,
           CMD_EXIT,
           CMD_CALL,
           CMD_THREAD, //15
           CMD_INC,
           CMD_DEC,
           CMD_LOCK,
           CMD_UNLOCK,
           CMD_SYSFUNC,//20
           CMD_USERFUNC,
           CMD_RETURN,
           CMD_LETARR,
           CMD_CALLAT,
           CMD_SUSPEND //25
     );
const
    SYS_VERSION         = 1;  //System variables
    SYS_TIMER           = 2;
    SYS_LEVEL           = 3;
    SYS_VMTYPE          = 4;
    // set of operators which have two parameters
    // (others have one)
    DoubleParamOps = [OPR_ADD, OPR_SUB , OPR_MUL, OPR_DIV, OPR_OR,
        OPR_XOR, OPR_MORE,OPR_LESS, OPR_NOMORE, OPR_NOLESS, OPR_EQ,
        OPR_NOEQ, OPR_AND,OPR_MOD,OPR_ARR];

const
  PRE_GRADE = 8;
const
  SourceFileExt = '.apl';
  BinaryFileExt = '.spt';


function PrecedenceOf(N:Integer):Integer;
function ConstOfOp(s:string):integer;
function StrOf(con:Integer):string;

implementation

function PrecedenceOf(N:Integer):Integer;
begin
 PrecedenceOf:=0;
 case N of
  OPR_NOT ,OPR_TOINT, OPR_TOFLOAT, OPR_TOSTR, OPR_TOBOOL:
              PrecedenceOf:=7;
  OPR_MUL,OPR_DIV,OPR_MOD:
              PrecedenceOf:=6;
  OPR_NEG,OPR_POS:
              PrecedenceOf:=5;
  OPR_ADD,OPR_SUB{,OPR_RND}:
              PrecedenceOf:=4;
  OPR_MORE,OPR_LESS,OPR_NOMORE,OPR_NOLESS:
              PrecedenceOf:=3;
  OPR_EQ,OPR_NOEQ:
              PrecedenceOf:=2;
  OPR_OR, OPR_XOR, OPR_AND:
              PrecedenceOf:=1;
  OPR_ARR:
              PrecedenceOf:=0;
 end;
end;

function ConstOfOp(s:string):integer;
begin
    if s='!' then
      ConstOfOp:=OPR_NOT
  //  else if s='$' then
  //    ConstOfOp:=OPR_ABS
    else if s='<' then
      ConstOfOp:=OPR_LESS
    else if s='>' then
      ConstOfOp:=OPR_MORE
    else if s='<=' then
      ConstOfOp:=OPR_NOMORE
    else if s='>=' then
      ConstOfOp:=OPR_NOLESS
    else if s='<>' then
      ConstOfOp:=OPR_NOEQ
    else if s='=' then
      ConstOfOp:=OPR_EQ
    else if s='+' then
      ConstOfOp:=OPR_ADD
    else if s='-' then
      ConstOfOp:=OPR_SUB
    else if s='^-' then
      ConstOfOp:=OPR_NEG
    else if s='^+' then
      ConstOfOp:=OPR_POS
    else if s='*' then
      ConstOfOp:=OPR_MUL
    else if s='/' then
      ConstOfOp:=OPR_DIV
    else if s='%' then
      ConstOfOp:=OPR_MOD
    else if s='&' then
      ConstOfOp:=OPR_AND
    else if s='^' then
      ConstOfOp:=OPR_XOR
    else if s='|' then
      ConstOfOp:=OPR_OR
    else if s='[' then
      ConstOfOp:=OPR_ARR
    else if s='int' then
      ConstOfOp:=OPR_TOINT
    else if s='float' then
      ConstOfOp:=OPR_TOFLOAT
    else if s='str' then
      ConstOfOp:=OPR_TOSTR
    else if s='bool' then
      ConstOfOp:=OPR_TOBOOL
    else ConstOfOp:=0;
end;

function StrOf(con:Integer):string;
begin
    if con=OPR_NOT then
      StrOf:='!'
 //   else if con=OPR_ABS then
 //     StrOf:='$'
    else if con=OPR_NEG then
      StrOf:='^-'
    else if con=OPR_POS then
      StrOf:='^+'
    else if con=OPR_MORE then
      StrOf:='>'
    else if con=OPR_LESS then
      StrOf:='<'
    else if con=OPR_NOMORE then
      StrOf:='<='
    else if con=OPR_NOLESS then
      StrOf:='>='
    else if con=OPR_EQ then
      StrOf:='='
    else if con=OPR_NOEQ then
      StrOf:='<>'
    else if con=OPR_AND then
      StrOf:='&'
    else if con=OPR_OR then
      StrOf:='|'
    else if con=OPR_XOR then
      StrOf:='^'
    else if con=OPR_ADD then
      StrOf:='+'
    else if con=OPR_SUB then
      StrOf:='-'
    else if con=OPR_MUL then
      StrOf:='*'
    else if con=OPR_DIV then
      StrOf:='/'
    else if con=OPR_MOD then
      StrOf:='%'
    else if con=OPR_ARR then
      StrOf:='[]'
    else if con=OPR_TOINT then
      StrOf:='<integer>'
    else if con=OPR_TOFLOAT then
      StrOf:='<float>'
    else if con=OPR_TOSTR then
      StrOf:='<string>'
    else if con=OPR_TOBOOL then
      StrOf:='<boolean>'
  //  else if con=OPR_RND then
  //    StrOf:='rnd'
end;

end.
