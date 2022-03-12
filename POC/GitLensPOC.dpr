program GitLensPOC;

uses
  Vcl.Forms,
  GitLensPoc.Main.Form in 'GitLensPoc.Main.Form.pas' {Form2};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
