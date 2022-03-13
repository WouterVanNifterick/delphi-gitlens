unit WvN.GitLens.Options;

interface

uses
  Vcl.Forms,
  ToolsAPI,
  WvN.GitLens.Options.Frame,
  WvN.GitLens.Theme,
  System.SysUtils,
  System.UITypes;

type
  TWvNGitLensAddInOptions = class(TInterfacedObject, INTAAddInOptions)
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

{ TWvNGitLensAddInOptions }

uses
  System.IniFiles, System.Rtti;

procedure TWvNGitLensAddInOptions.DialogClosed(Accepted: Boolean);
begin
  if Accepted then
  begin
    WvNGitLensTheme := FFrame.Theme;
    WvNGitLensTheme.SaveToFile;
    OnPaint;
  end;
end;

procedure TWvNGitLensAddInOptions.FrameCreated(AFrame: TCustomFrame);
begin
  FFrame := TOptionsFrame(AFrame);
  WvNGitLensTheme.LoadFromFile;
  FFrame.Theme := WvNGitLensTheme;
//  FFrame.cbTextColor.Selected := WvNGitLensTheme.TextColor;
//  FFrame.cbBackgroundColor.Selected := WvNGitLensTheme.BackgroundColor;
//  FFrame.UpdatePreview(;
end;

function TWvNGitLensAddInOptions.GetArea: string;
begin
  Result := 'Debugger Options';
end;

function TWvNGitLensAddInOptions.GetCaption: string;
begin
  Result := 'WvNGitLens';
end;

function TWvNGitLensAddInOptions.GetFrameClass: TCustomFrameClass;
begin
  Result := TOptionsFrame;
end;

function TWvNGitLensAddInOptions.GetHelpContext: Integer;
begin
  Result := 0;
end;

function TWvNGitLensAddInOptions.IncludeInIDEInsight: Boolean;
begin
  Result := True;
end;

function TWvNGitLensAddInOptions.ValidateContents: Boolean;
begin
  Result := True;
end;

end.
