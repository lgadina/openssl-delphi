unit ssl_lib;

interface

var
  SSL_C_LIB : AnsiString = 'libcrypto';
{$IFDEF UNIX}
  SSL_C_EXTENSION : AnsiString = '.so';
   //'libeay32.so';
{$ELSE}
  //SSL_C_LIB : AnsiString = 'libeay32.dll';
  {$IfDef CPU386}
   SSL_C_EXTENSION : AnsiString = '.dll';
  {$Else}
    SSL_C_EXTENSION : AnsiString = '.x64.dll';
  {$EndIf}
{$ENDIF}


function SSLCryptHandle: {$IfDef UNIX}TlibHandle{$ELse}THandle{$EndIf};
function LoadSSLCrypt: Boolean;
function LoadFunctionCLib(const FceName: String; const ACritical : Boolean = True): Pointer;

implementation
uses {$IFDEF UNIX}dynlibs{$ELSE}windows{$ENDIF}, sysutils;

const
   DLLVersions: array[1..21] of string = ('', '.1.1', '.1.0.9', '.1.0.8',
                                      '.1.0.7', '.1.0.6', '.1.0.5', '.1.0.4', '.1.0.3', '1.0.2k',
                                      '.1.0.2', '.1.0.1','.1.0.0','.0.9.8',
                                      '.0.9.7', '.0.9.6', '.0.9.5', '.0.9.4',
                                      '.0.9.3', '.0.9.2', '.0.9.1');


var hCrypt: {$IfDef UNIX}TlibHandle{$ELse}THandle{$EndIf} = 0;

function SSLCryptHandle: {$IfDef UNIX}TlibHandle{$ELse}THandle{$EndIf};
begin
  Result := hCrypt;
end;

function LoadSSLCrypt: Boolean;
var i: Integer;
begin
 Result := hCrypt <> 0;
 if not Result then
 begin
  {$IFDEF UNIX}
   for i := Low(DLLVersions) to High(DLLVersions) do
   begin
    try
     hCrypt := LoadLibrary(SSL_C_LIB+SSL_C_EXTENSION+DLLVersions[i]);
    except
    end;
    if hCrypt <> 0 then
     Break;
   end;
  {$ELSE}
    hCrypt := LoadLibraryA(PAnsiChar(SSL_C_LIB + SSL_C_EXTENSION));
  {$ENDIF}
 end;
  Result := hCrypt <> 0;
end;


function LoadFunctionCLib(const FceName: String; const ACritical : Boolean = True): Pointer;
begin
  if LoadSSLCrypt then
  begin
    {$IFDEF UNIX}
     Result := GetProcAddress(SSLCryptHandle, PChar(FceName));
    {$ELSE}
    Result := Windows.GetProcAddress(SSLCryptHandle, PChar(FceName));
    {$ENDIF}
    if ACritical then
    begin
      if Result = nil then begin
  {$ifdef fpc}
       raise Exception.CreateFmt('Error loading library. Func %s'#13#10'%s', [FceName, SysErrorMessage(GetLastOSError)]);
  {$else}
       raise Exception.CreateFmt('Error loading library. Func %s'#13#10'%s', [FceName, SysErrorMessage(GetLastError)]);
  {$endif}
      end;
    end;
  end else
    raise Exception.CreateFmt('Error loading library. Not found '+SSL_C_LIB+SSL_C_EXTENSION, [FceName, SysErrorMessage(GetLastOSError)]);
end;

initialization

finalization
 if hCrypt <> 0 then
  FreeLibrary(hCrypt);

end.
