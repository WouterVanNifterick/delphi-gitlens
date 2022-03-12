unit WvN.GitLens.Options;

interface

uses
  Vcl.Forms,
  ToolsAPI,
  WvN.GitLens.Options.Frame,
  WvN.GitLens.Utils,
  WvN.GitLens.Theme,
  System.SysUtils,
  System.UITypes;

type
  TDLightAddInOptions = class(TInterfacedObject, INTAAddInOptions)
  private
    FFrame: TOptionsFrame;
  public
    OnPaint:TProc;
    procedure DialogClosed(Accepted: Boolean);
    procedure FrameCreated(AFrame: TCustomFrame);
    function GetArea: string;
    function GetCaption: string;
    function GetFrameClass: TCustomFrameClass;
    function GetHelpContext: Integer;
    function ValidateContents: Boolean;
    function IncludeInIDEInsight: Boolean;
  end;

implementation

{ TDLightAddInOptions }

uses
  System.IniFiles, System.Rtti;

procedure TDLightAddInOptions.DialogClosed(Accepted: Boolean);
begin
  if Accepted then
  begin
    DLightTheme := FFrame.Theme;
    DLightTheme.SaveToFile;
    OnPaint;
  end;
end;

procedure TDLightAddInOptions.FrameCreated(AFrame: TCustomFrame);
begin
  FFrame := TOptionsFrame(AFrame);
  DLightTheme.LoadFromFile;
  FFrame.Theme := DLightTheme;
//  FFrame.cbTextColor.Selected := DLightTheme.TextColor;
//  FFrame.cbBackgroundColor.Selected := DLightTheme.BackgroundColor;
//  FFrame.UpdatePreview(;
end;

function TDLightAddInOptions.GetArea: string;
begin
  Result := GetUIString(uisDebuggerOptions);
end;

function TDLightAddInOptions.GetCaption: string;
begin
  Result := 'DLight';
end;

function TDLightAddInOptions.GetFrameClass: TCustomFrameClass;
begin
  Result := TOptionsFrame;
end;

function TDLightAddInOptions.GetHelpContext: Integer;
begin
  Result := 0;
end;

function TDLightAddInOptions.IncludeInIDEInsight: Boolean;
begin
  Result := True;
end;

function TDLightAddInOptions.ValidateContents: Boolean;
begin
  Result := True;
end;

end.
