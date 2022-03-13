unit WvN.GitLens.Git.Blame;

interface

uses WvN.GitLens.Git.Commit;

type
  TGitBlameAuthor = record
    name: string;
    lineCount: Integer;
  end;

  TGitBlame = record
    repoPath: string;
    authors: TArray<TGitBlameAuthor>;
    commits: TArray<TGitCommit>;
    lines: TArray<TGitCommitLine>;
  end;

  TGitBlameLine = record
    author: TGitBlameAuthor;
    Commit: TGitCommit;
    line: TGitCommitLine;
  end;

  TGitBlameCommitLines = record
    author: TGitBlameAuthor;
    Commit: TGitCommit;
    lines: TArray<string>;
  end;

implementation

end.
