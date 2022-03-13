unit GitLensPoc.Main.Form;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Threading, Vcl.StdCtrls,
  System.IOUtils,
  WvN.GitLens.Console.Capture,
  WvN.GitLens.Git.Blame,
  WvN.GitLens.Git.BlameParser,
  WvN.GitLens.Git.User,
  WvN.GitLens.Utils, Vcl.ComCtrls;


type
  TfrmMain = class(TForm)
    ListView1: TListView;
    procedure FormCreate(Sender: TObject);
    procedure ListView1Data(Sender: TObject; Item: TListItem);
  private
  public
    FLines:TArray<string>;
    FGitBlame:TGitBlame;
    function GetLensText(LineNum:integer):string;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}


procedure TfrmMain.FormCreate(Sender: TObject);
begin
  var FCurrentFile := 'C:\dev\delphi\delphi-vanessa\Source\Core\uVanessaConst.pas';
  FLines := TFile.ReadAllLines(FCurrentFile);
  SetCurrentDir(ExtractFilePath(FCurrentFile));

  CaptureConsoleOutputASync('git --no-pager blame --line-porcelain '+FCurrentFile,
  procedure(s:string)
  begin
    var CurrentUser : TGitUser;
    var repoPath := ExtractFilePath(FCurrentFile);

    CurrentUser.Name  := 'Wouter van Nifterick';
    CurrentUser.Email := 'woutervannifterck@gmail.com';
    FGitBlame := TGitBlameParser.Parse(s, repoPath, CurrentUser);
    listview1.Items.Count := length(FGitBlame.lines);
    listview1.Refresh;
  end)

end;

function TfrmMain.GetLensText(LineNum: integer): string;
begin
  var line := FGitBlame.lines[LineNum];
  for var c in FGitBlame.commits do
    if c.ShortSha = line.Sha then
    begin
      var author := c.Author.name;
      var age := now - c.AuthorDate;
      var ageStr := TimeSpanToShortStr(age);
      var msg := c.Summary;
      var txt := format('%s, %s ago • %s',[author, ageStr, msg]);
      Exit(txt);
    end;

  Result := '';
end;

procedure TfrmMain.ListView1Data(Sender: TObject; Item: TListItem);
begin
  var LineNumber := Item.Index;

  if LineNumber > High(FLines) then
    Exit;

  Item.Caption := Item.Index.ToString;
  Item.SubItems.Add(FLines[LineNumber]);
  Item.SubItems.Add(GetLensText(LineNumber));

end;

end.
