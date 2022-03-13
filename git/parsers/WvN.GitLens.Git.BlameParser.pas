unit WvN.GitLens.Git.BlameParser;

interface

uses
  System.SysUtils,
  System.StrUtils,
  System.DateUtils,
  WvN.GitLens.Git.Author,
  WvN.GitLens.Git.Blame,
  WvN.GitLens.Git.Commit,
  WvN.GitLens.Git.User

    ;

type
  TBlameEntry = record
    isCommitted:Boolean;
    sha: string;

    line: Integer;
    originalLine: Integer;
    lineCount: Integer;
    code :string;

    Author: string;
    authorDate: string;
    authorTimeZone: string;
    authorEmail: string;

    committer: string;
    committerDate: string;
    committerTimeZone: string;
    committerEmail: string;

    previousSha: string;
    previousPath: string;

    path: string;

    summary: string;
  end;

  TGitBlameParser = record
    class function CleanEmail(const email:string):string; static;
    class function Parse(data: string; repoPath: string; currentUser: TGitUser): TGitBlame;static;

    class procedure ParseEntry(var entry: TBlameEntry; repoPath: string;
      var commits: TArray<TGitCommit>; var authors: TArray<TGitBlameAuthor>;
      var lines: TArray<TGitCommitLine>; currentUser: TGitUser);static;
  end;

implementation

{ TGitBlameParser }

// Sample data:

// 6b3486437e13e947c0d7b6c2cc34850a2a38d978 1 1 23
// author Wouter van Nifterick
// author-mail <someemail@gmail.com>
// author-time 1647122613
// author-tz +0100
// committer Wouter van Nifterick
// committer-mail <someemailgmail.com>
// committer-time 1647122613
// committer-tz +0100
// summary Initial commit
// boundary
// filename WvN.GitLens.pas
// unit WvN.GitLens.pas

// Expects to receive the output of:
// git --no-pager blame --line-porcelain <FILE>

class function TGitBlameParser.CleanEmail(const email: string): string;
begin
  Result := email
              .Trim
              .TrimLeft(['<'])
              .TrimRight(['>']);
end;

class function TGitBlameParser.Parse(data: string; repoPath: string; currentUser: TGitUser): TGitBlame;
begin
  var entry := default (TBlameEntry);
  var commits: TArray<TGitCommit> := [];
  var authors: TArray<TGitBlameAuthor> := [];
  var lines: TArray<TGitCommitLine> := [];
  const NoCommitSha = '0000000000000000000000000000000000000000';

  for var line in data.Split([#$A]) do
  begin
    var lineParts := (line+' ').Split([' ']);

    var key:= lineParts[0];
    var value := line.Substring(key.length + 1).trim();

    if entry.sha = '' then
    begin
      if length(lineParts) < 3 then Continue;
      if not TryStrToInt(lineParts[1], entry.originalLine) then Continue;
      if not TryStrToInt(lineParts[2], entry.line) then Continue;
      entry.lineCount := 1;
      entry.sha := key;
      entry.isCommitted := key <> NoCommitSha;
      Continue;
    end else
    if key = 'author'         then entry.Author            := ifthen(Entry.isCommitted, value, 'You')                         else
    if key = 'author-mail'    then entry.authorEmail       := ifthen(Entry.isCommitted, CleanEmail(value), currentUser.email) else
    if key = 'author-time'    then entry.authorDate        := value                                                           else
    if key = 'author-tz'      then entry.authorTimeZone    := value                                                           else
    if key = 'committer'      then entry.committer         := ifthen(Entry.isCommitted, value, 'You')                         else
    if key = 'committer-mail' then entry.committerEmail    := ifthen(Entry.isCommitted, CleanEmail(Value), currentUser.email) else
    if key = 'committer-time' then entry.committerDate     := value                                                           else
    if key = 'committer-tz'   then entry.committerTimeZone := value                                                           else
    if key = 'summary'        then entry.summary           := value                                                           else
    if key = 'previous'       then entry.previousSha       := value                                                           else
    if key = 'previous'       then entry.previousPath      := string.Join(' ', copy(lineParts, 2, 255))                       else
    if key = 'filename'       then entry.path              := value                                                           else
    if Entry.path <> ''       then begin
                                     entry.code := line.Trim.Replace('n++','');
                                     // Since the filename marks the end of a commit, parse the Entry and clear it for the next
                                     ParseEntry(entry, repoPath, commits, authors, lines, currentUser);
                                     entry := default (TBlameEntry);
                                     continue;
                                   end;
  end;

  // count number of lines per author
  for var c in commits do
  begin
    if c.Author.name = '' then
      Continue;
    for var i := 0 to high(authors) do
      if authors[i].name = c.Author.name then
        Inc(authors[i].lineCount, length(c.lines));
  end;

  Result.repoPath := repoPath;
  Result.authors := authors;
  Result.commits := commits;
  Result.lines := lines;
end;

class procedure TGitBlameParser.ParseEntry(var entry: TBlameEntry; repoPath: string;
  var commits: TArray<TGitCommit>; var authors: TArray<TGitBlameAuthor>;
  var lines: TArray<TGitCommitLine>; currentUser: TGitUser);
begin
  var CommitFound := false;
  var Commit:TGitCommit;

  for Commit in commits do
  begin
    if Commit.ShortSha = entry.sha then
    begin
      CommitFound := true;
      Break;
    end;
  end;
  if not CommitFound then
  begin
    if Entry.Author = '' then
    begin
      Entry.author := currentUser.Name;
      Entry.authorEmail := currentUser.Email;
    end;

    var AuthorFound := False;
    for var a in Authors do
      if a.name = entry.Author then
        AuthorFound := True;

    if not AuthorFound then
    begin
      var a : TGitBlameAuthor;
      a.name := Entry.Author;
      a.lineCount := 0;
      Authors := Authors + [a];
    end;
    commit.RepoPath := repoPath;
    commit.Author.name := entry.Author;
    commit.Author.email := entry.authorEmail;
    commit.ShortSha := entry.sha;
    commit.Summary := entry.summary;
    commit.CommitDate := UnixToDateTime(StrToInt64(entry.committerDate));
    commit.AuthorDate := UnixToDateTime(StrToInt64(entry.authorDate));

    commits := commits + [commit];
  end;

  for var i:=0 to Entry.lineCount-1 do
  begin
    var line : TGitCommitLine;
    line.sha := Entry.sha;
    line.PreviousSha := commit.ShortSha;
		line.OriginalLine:= entry.originalLine + i;
    line.line := entry.line + i;
    line.Code := entry.code;

    Commit.lines := Commit.lines + [line];
    lines := lines + [line];
  end;


end;

end.
