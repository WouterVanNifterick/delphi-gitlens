program GitLensPOC;

uses
  Vcl.Forms,
  GitLensPoc.Main.Form in 'GitLensPoc.Main.Form.pas' {frmMain},
  WvN.GitLens.Console.Capture in '..\WvN.GitLens.Console.Capture.pas',
  WvN.GitLens.Git.User in '..\git\models\WvN.GitLens.Git.User.pas',
  WvN.GitLens.Git.RemoteProvider in '..\git\models\WvN.GitLens.Git.RemoteProvider.pas',
  WvN.GitLens.Git.Commit in '..\git\models\WvN.GitLens.Git.Commit.pas',
  WvN.GitLens.Git.Blame in '..\git\models\WvN.GitLens.Git.Blame.pas',
  WvN.GitLens.Git.Author in '..\git\models\WvN.GitLens.Git.Author.pas',
  WvN.GitLens.Git.BlameParser in '..\git\parsers\WvN.GitLens.Git.BlameParser.pas',
  WvN.GitLens.Utils in '..\WvN.GitLens.Utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
