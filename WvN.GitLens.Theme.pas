unit WvN.GitLens.Theme;

interface

uses
  System.UITypes, System.IniFiles, System.Rtti, System.SysUtils;

type
  TWvNGitLensTheme = record
    TextColor:TColor;
    BackgroundColor:TColor;
    StringColor:TColor;
    FloatColor:TColor;
    BooleanColor:TColor;
    DateTimeColor:TColor;
    IntegerColor:TColor;
    procedure LoadFromFile;
    procedure SaveToFile;
    function  DetectColor(const Text: string):TColor;
  end;

var
  WvNGitLensTheme:TWvNGitLensTheme;


implementation


{ TOptions }

function TWvNGitLensTheme.DetectColor(const Text: string): TColor;
begin
  Result := TextColor;
  var v:Int64;
  var b:Boolean;
  var f:Extended;
  var d:TDateTime;

       if TryStrToInt64   (Text, v) then Result := IntegerColor
  else if TryStrToBool    (Text, b) then Result := BooleanColor
  else if TryStrToFloat   (Text, f) then Result := FloatColor
  else if TryStrToDateTime(Text, d) then Result := DateTimeColor;
end;

procedure TWvNGitLensTheme.LoadFromFile;
begin
  var ini := TIniFile.Create(ChangeFileExt(GetModuleName(HInstance), '.ini'));
  try
    for var field in TRTTIContext.Create.GetType(TypeInfo(TWvNGitLensTheme)).GetFields do
      field.SetValue(@self, ini.ReadInt64('Colors', field.Name, TColorRec.Lightgray ));
  finally
    ini.Free;
  end;
end;

procedure TWvNGitLensTheme.SaveToFile;
begin
  var ini := TIniFile.Create(ChangeFileExt(GetModuleName(HInstance), '.ini'));
  try
    for var field in TRTTIContext.Create.GetType(TypeInfo(TWvNGitLensTheme)).GetFields do
      ini.WriteInt64('Colors', field.Name, field.GetValue(@self).AsInt64);
  finally
    ini.Free;
  end;
end;


initialization
  WvNGitLensTheme.LoadFromFile;

finalization


end.
