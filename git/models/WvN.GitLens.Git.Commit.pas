unit WvN.GitLens.Git.Commit;

interface

uses WvN.GitLens.Git.Author;

type
  TGitCommitLine = record
    Sha:string;
    PreviousSha:string;
    OriginalLine:Integer;
    Line:Integer;
    Code:string;
  end;


  TGitCommit = record
    Author:TAuthor;
    Committer:TAuthor;
    ShortSha:string;
    StashName:String;
    StashNumber:string;
    RepoPath:string;
    Summary:string;
    AuthorDate:TDateTime;
    CommitDate:TDateTime;
    Lines:TArray<TGitCommitLine>;
  end;

implementation

end.
