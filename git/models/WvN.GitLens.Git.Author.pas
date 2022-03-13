unit WvN.GitLens.Git.Author;

interface

uses WvN.GitLens.Git.RemoteProvider;

type
  TAuthor = record
    provider: TRemoteProvider;
    name: string;
    email: string;
    avatarUrl: string;
  end;

implementation

end.
