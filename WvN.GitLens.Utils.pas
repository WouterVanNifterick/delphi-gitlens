unit WvN.GitLens.Utils;

interface

function TimeSpanToShortStr(span: TDateTime): String;

implementation

uses
  System.DateUtils, System.SysUtils, System.StrUtils;

function TimeSpanToShortStr(span: TDateTime): String;
begin
  Result := '';
  var ms:int64 := abs(Round(span / OneMilliSecond));

       if ms < 1000                        then Result := (ms div 1                         ).ToString + ' milliseconds'
  else if ms < 1000*60                  *5 then Result := (ms div (1000                    )).ToString + ' seconds'
  else if ms < 1000*60*60               *5 then Result := (ms div (1000*60                 )).ToString + ' minutes'
  else if ms < 1000*60*60*24            *2 then Result := (ms div (1000*60*60              )).ToString + ' hours'
  else if ms < int64(1000*60*60*24)    *60 then Result := (ms div (1000*60*60*24           )).ToString + ' days'
  else if ms < int64(1000*60*60*24)*365 *2 then Result := (ms div (int64(1000*60*60*24)*30 )).ToString + ' months'
  else                                          Result := (ms div (int64(1000*60*60*24)*365)).ToString + ' years';
end;

end.
