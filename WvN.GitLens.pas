unit WvN.GitLens;

interface

uses
  System.IOUtils;

{$IFNDEF CONDITIONALEXPRESSIONS}
  {$MESSAGE ERROR '10 Seattle or higher is required'}
{$ELSE}
  {$IF RTLVersion < 30.0}
    {$MESSAGE ERROR '10 Seattle or higher is required'}
  {$IFEND}
{$ENDIF}

procedure Register;

implementation

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Classes, System.IniFiles,
  System.UITypes, System.UIConsts, System.RTLConsts, System.Rtti, System.TypInfo,
  System.Generics.Collections, System.Generics.Defaults, Vcl.Graphics,
  Vcl.Controls, ToolsAPI,
  WvN.GitLens.Console.Capture,
  WvN.GitLens.Git.Blame,
  WvN.GitLens.Git.BlameParser,
  WvN.GitLens.Git.User,
  WvN.GitLens.Options,
  WvN.GitLens.Options.Frame,
  WvN.GitLens.Utils
;

type


  TIDENotifier = class(TNotifierObject, IOTAIDENotifier)
  private
    FEditorNotifiers: TList<IOTAEditorNotifier>;
  public
    constructor Create;
    destructor Destroy; override;

    { IOTAIDENotifier }
    procedure FileNotification(NotifyCode: TOTAFileNotification; const FileName: string; var Cancel: Boolean);
    procedure BeforeCompile(const Project: IOTAProject; var Cancel: Boolean); overload;
    procedure AfterCompile(Succeeded: Boolean); overload;
  end;

  TEditorNotifier = class(TNotifierObject, IOTANotifier, IOTAEditorNotifier)
  private
    FSourceEditor: IOTASourceEditor;
    FEditViewNotifiers: TList<INTAEditViewNotifier>;
    FNotifierIndex: Integer;
    procedure RemoveNotifiers;
  public
    constructor Create(ASourceEditor: IOTASourceEditor);
    destructor Destroy; override;

    { IOTANotifier }
    procedure Destroyed;
    { IOTAEditorNotifier }
    procedure ViewNotification(const View: IOTAEditView; Operation: TOperation);
    procedure ViewActivated(const View: IOTAEditView);
  end;

  TEditViewNotifier = class(TNotifierObject, IOTANotifier, INTAEditViewNotifier)
  private
    FEditView: IOTAEditView;
    FNotifierIndex: Integer;
    procedure RemoveNotifier;
  public
    constructor Create(AEditView: IOTAEditView);
    destructor Destroy; override;

    { IOTANotifier }
    procedure Destroyed;
    { INTAEditViewNotifier }
    procedure EditorIdle(const View: IOTAEditView);
    procedure BeginPaint(const View: IOTAEditView; var FullRepaint: Boolean);
    procedure PaintLine(const View: IOTAEditView; LineNumber: Integer;
      const LineText: PAnsiChar; const TextWidth: Word; const LineAttributes: TOTAAttributeArray;
      const Canvas: TCanvas; const TextRect: TRect; const LineRect: TRect; const CellSize: TSize);
    procedure EndPaint(const View: IOTAEditView);
  end;

var
  FCurrentFile:string;
  FWvNGitLensEnabled: Boolean;
  FIDENotifierIndex: Integer = -1;
  FWvNGitLensAddInOptions: TWvNGitLensAddInOptions = nil;
  FCurrentBuffer: IOTAEditBuffer;
  FRepaintAll: Boolean;
  FLeftGutterProp: PPropInfo;
  FGitBlame:TGitBlame;

{ TIDENotifier }

constructor TIDENotifier.Create;
var
  moduleServices: IOTAModuleServices;
  module: IOTAModule;
  editor: IOTASourceEditor;
begin
  inherited;
  FEditorNotifiers := TList<IOTAEditorNotifier>.Create;

  moduleServices := BorlandIDEServices as IOTAModuleServices;
  for var i := 0 to moduleServices.ModuleCount-1 do
  begin
    module := moduleServices.Modules[i];

    for var j := 0 to module.ModuleFileCount-1 do
      if Supports(module.ModuleFileEditors[j], IOTASourceEditor, editor) then
        FEditorNotifiers.Add(TEditorNotifier.Create(editor));
  end;
end;

destructor TIDENotifier.Destroy;
var
  i: Integer;
begin
  for i := 0 to FEditorNotifiers.Count-1 do
    FEditorNotifiers[i].Destroyed;
  FEditorNotifiers.Free;
  inherited;
end;

procedure TIDENotifier.FileNotification(NotifyCode: TOTAFileNotification;
  const FileName: string; var Cancel: Boolean);
begin
end;

procedure TIDENotifier.BeforeCompile(const Project: IOTAProject; var Cancel: Boolean);
begin
end;

procedure TIDENotifier.AfterCompile(Succeeded: Boolean);
begin
end;

{ TEditorNotifier }

constructor TEditorNotifier.Create(ASourceEditor: IOTASourceEditor);
var
  i: Integer;
begin
  inherited Create;
  FEditViewNotifiers := TList<INTAEditViewNotifier>.Create;
  FSourceEditor := ASourceEditor;

  FNotifierIndex := FSourceEditor.AddNotifier(Self);
  for i := 0 to FSourceEditor.EditViewCount-1 do
  begin
    FEditViewNotifiers.Add(TEditViewNotifier.Create(FSourceEditor.EditViews[i]));
  end;
end;

destructor TEditorNotifier.Destroy;
begin
  RemoveNotifiers;
  FEditViewNotifiers.Free;
  inherited;
end;

procedure TEditorNotifier.Destroyed;
begin
  RemoveNotifiers;
end;

procedure TEditorNotifier.ViewNotification(const View: IOTAEditView; Operation: TOperation);
begin
  if Operation = opInsert then
    FEditViewNotifiers.Add(TEditViewNotifier.Create(View));
end;

procedure TEditorNotifier.ViewActivated(const View: IOTAEditView);
begin
  FCurrentFile := View.Buffer.FileName;
  var repoPath := ExtractFilePath(FCurrentFile);
  SetCurrentDir(repoPath);
  CaptureConsoleOutputASync('git --no-pager blame --line-porcelain "' + FCurrentFile+'"',
  procedure(s:string)
  begin
    var CurrentUser : TGitUser;
    CurrentUser.Name  := 'Wouter van Nifterick';
    CurrentUser.Email := 'woutervannifterck@gmail.com';
    FGitBlame := TGitBlameParser.Parse(s, repoPath, CurrentUser);
  end)
end;

procedure TEditorNotifier.RemoveNotifiers;
var
  i: Integer;
begin
  for i := 0 to FEditViewNotifiers.Count-1 do
    FEditViewNotifiers[i].Destroyed;
  FEditViewNotifiers.Clear;

  if Assigned(FSourceEditor) and (FNotifierIndex >= 0) then
  begin
    FSourceEditor.RemoveNotifier(FNotifierIndex);
    FNotifierIndex := -1;
    FSourceEditor := nil;
  end;
end;

{ TEditViewNotifier }

constructor TEditViewNotifier.Create(AEditView: IOTAEditView);
begin
  inherited Create;
  FEditView := AEditView;
  FNotifierIndex := FEditView.AddNotifier(Self);
end;

destructor TEditViewNotifier.Destroy;
begin
  RemoveNotifier;
  inherited;
end;

procedure TEditViewNotifier.Destroyed;
begin
  RemoveNotifier;
end;

procedure TEditViewNotifier.EditorIdle(const View: IOTAEditView);
begin
end;

procedure TEditViewNotifier.BeginPaint(const View: IOTAEditView; var FullRepaint: Boolean);
begin
end;


procedure TEditViewNotifier.PaintLine(
  const View: IOTAEditView;
  LineNumber: Integer;
  const LineText: PAnsiChar;
  const TextWidth: Word; const LineAttributes: TOTAAttributeArray;
  const Canvas: TCanvas; const TextRect: TRect; const LineRect: TRect; const CellSize: TSize);
begin
  if LineNumber < 1 then
    Exit;

  if LineNumber>Length(FGitBlame.lines) then
    Exit;

  if LineNumber <> View.CursorPos.Line then
    Exit;


  var line := FGitBlame.lines[LineNumber-1];
  for var c in FGitBlame.commits do
    if c.ShortSha = line.Sha then
    begin
      var author := c.Author.name;
      var age := now - c.AuthorDate;
      var ageStr := TimeSpanToShortStr(age);

      var msg := c.Summary;

      var txt := format('%s, %s ago • %s',[author, ageStr, msg]);
      Canvas.Brush.Style := bsClear;
      Canvas.Font.Color := $666666;
      Canvas.TextOut(TextRect.Right + (CellSize.cx * 8), TextRect.Top, txt);
    end;
end;

procedure TEditViewNotifier.EndPaint(const View: IOTAEditView);
begin
end;

procedure TEditViewNotifier.RemoveNotifier;
begin
  if Assigned(FEditView) and (FNotifierIndex >= 0) then
  begin
    FEditView.RemoveNotifier(FNotifierIndex);
    FNotifierIndex := -1;
    FEditView := nil;
  end;
end;

procedure DoRepaint;
var
  i: Integer;
begin
  FRepaintAll := True;
  if FCurrentBuffer <> nil then
    for i := 0 to FCurrentBuffer.EditViewCount-1 do
      FCurrentBuffer.EditViews[i].Paint;
end;

procedure Register;
  function GetPropInfo(const QualifiedClassName, PropName: string): PPropInfo;
  var
    ctx: TRttiContext;
    typ: TRttiType;
    prop: TRttiProperty;
  begin
    typ := ctx.FindType(QualifiedClassName);
    if typ = nil then Exit(nil);
    prop := typ.GetProperty(PropName);
    if prop = nil then Exit(nil);
    Result := TRttiInstanceProperty(prop).PropInfo;
  end;

begin
  FIDENotifierIndex := (BorlandIDEServices as IOTAServices).AddNotifier(TIDENotifier.Create);
  FWvNGitLensAddInOptions := TWvNGitLensAddInOptions.Create;
  FWvNGitLensAddinOptions.OnPaint :=
    procedure
    begin
      if FWvNGitLensEnabled then
        DoRepaint;
    end;

  (BorlandIDEServices as INTAEnvironmentOptionsServices).RegisterAddInOptions(FWvNGitLensAddInOptions);

  FLeftGutterProp := GetPropInfo('EditorControl.TEditControl', 'LeftGutter');

end;

procedure Unregister;
begin
  if FIDENotifierIndex >= 0 then
    (BorlandIDEServices as IOTAServices).RemoveNotifier(FIDENotifierIndex);
  (BorlandIDEServices as INTAEnvironmentOptionsServices).UnregisterAddInOptions(FWvNGitLensAddInOptions);
  FWvNGitLensAddInOptions := nil;
end;

initialization

finalization
  Unregister;
end.
