unit SptOut;

interface

function  stdOpen: Boolean;
procedure stdWrite(s: string);
procedure stdWriteln(s: string);
procedure stdClose;

function  errOpen: Boolean;
procedure errWrite(s: string);
procedure errWriteln(s: string);
procedure errClose;

function  debugOpen(FileName: string): Boolean;
procedure debugWrite(s: string);
procedure debugWriteln(s: string);
procedure debugClose;

function OpenAll: Boolean;
procedure CloseAll;
var
  //CompileDebugOutputFilename: string='compile output.txt';
  OutputDebug:      Boolean = False;
  OutputStdandard:  Boolean = True;
  OutputError:      Boolean = True;

implementation

var
  cdo:text;

function stdOpen: Boolean;
begin
  Result := True;
end;

procedure stdWrite(s: string);
begin
  if OutputStdandard then Write(s);
end;

procedure stdWriteln(s: string);
begin
  if OutputStdandard then Writeln(s);
end;

procedure stdClose;
begin
end;

function debugOpen(FileName: string): Boolean;
begin
  {$I-}
  AssignFile(cdo, FileName);
  Rewrite(cdo);
  {$I+}
  Result := IOResult = 0;
end;

procedure debugWrite(s: string);
begin
  if OutputDebug then Write(cdo, s);
end;

procedure debugWriteln(s: string);
begin
  if OutputDebug then Writeln(cdo, s);
end;

procedure debugClose;
begin
  {$I-}
  CloseFile(cdo);
  {$I+}
end;

function errOpen: Boolean;
begin
  Result := True;
end;

procedure errWrite(s: string);
begin
  if OutputError then Write(s);
end;

procedure errWriteln(s: string);
begin
  if OutputError then Writeln(s);
end;

procedure errClose;
begin
end;

function OpenAll: Boolean;
begin
  Result := stdOpen and errOpen;
  if Result = False then CloseAll;
end;

procedure CloseAll;
begin
  stdClose;
  errClose;
  debugClose;
end;
end.
