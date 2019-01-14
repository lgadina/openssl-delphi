// JCL_DEBUG_EXPERT_GENERATEJDBG OFF
// JCL_DEBUG_EXPERT_INSERTJDBG OFF
// JCL_DEBUG_EXPERT_DELETEMAPFILE OFF
program myprime;

{$APPTYPE CONSOLE}

{$R *.res}


uses
  System.SysUtils,
  ssl_lib in '..\ssl_lib.pas',
  ssl_asn in '..\ssl_asn.pas',
  ssl_err in '..\ssl_err.pas',
  ssl_objects in '..\ssl_objects.pas',
  ssl_util in '..\ssl_util.pas',
  ssl_const in '..\ssl_const.pas',
  ssl_types in '..\ssl_types.pas',
  ssl_bio in '..\ssl_bio.pas',
  ssl_bn in '..\ssl_bn.pas';

procedure callback(_type, _num: TC_INT; p3: Pointer ); cdecl;
begin
 case _type of
 0: Write('.');
 1: Write('+', #13#10);
 2: Write('*', #13#10);
 end;
end;

var r: PBIGNUM;
    bp: PBIO;
    a: TC_INT;
    buf: AnsiString;
    Res: AnsiString;
    num: TC_INT;
begin
  try

    if ParamCount > 0 then
       Num := StrToIntDef(ParamStr(1), 1024)
    else
      Num := 1024;
    writeln('Generate a strong prime ', Num, ' bits');
    SSL_InitBN;
    SSL_InitBIO;
    r := BN_new();
    BN_generate_prime(r, Num, 1, nil, nil, callback, nil);
    if r = nil  then
    begin
      Writeln(ERR_GetFullErrorString);
      Halt(0);
    end;
    Buf := BN_bn2hex(r);
    Writeln('BN_bn2hex: ', buf);

    bp := BIO_new(BIO_s_mem);
    BN_print(bp, r);
     Writeln('BN_print: ',BIO_ReadAnsiString(bp));
    BN_free(r);
    { TODO -oUser -cConsole Main : Insert code here }
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
