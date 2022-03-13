unit WvN.GitLens.Options.Frame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Grids, WvN.GitLens.Theme,
  Vcl.ValEdit, System.Rtti;

type
  TOptionsFrame = class(TFrame)
  private
    FTheme: TWvNGitLensTheme;
    procedure ChangeColor(Sender: TObject);
    procedure SetTheme(const Value: TWvNGitLensTheme);
    procedure ShowTheme;
  public
    property Theme:TWvNGitLensTheme read FTheme write SetTheme;
    procedure CreateEditor(Name:string; Value:TColor; RowNum:Integer);
    constructor Create(AOwner: TComponent); override;
  end;

implementation

{$R *.dfm}

{ TOptionsFrame }

procedure TOptionsFrame.ChangeColor(Sender: TObject);
begin
  if not (Sender is TColorBox) then Exit;
  var colbox := Sender as TColorBox;
  var field := TRTTIContext.Create.GetType(TypeInfo(TWvNGitLensTheme)).GetField(colBox.Name);
  if field=nil then exit;
  field.SetValue(@Theme, colBox.Selected);
end;

constructor TOptionsFrame.Create(AOwner: TComponent);
begin
  inherited;

  ShowTheme;
end;

procedure TOptionsFrame.CreateEditor(Name: string; Value: TColor; RowNum: Integer);
begin
    var row := TPanel.Create(self);
    row.Parent := self;
    row.Left := 8;
    row.Top := RowNum * 30;
    row.Width := 500;
    row.Height := 28;
    row.BevelOuter := bvRaised;
    row.Caption := '';
    row.Show;

    var lbl:= TLabel.Create(row);
    lbl.AutoSize := False;
    lbl.Left := 8;
    lbl.Top := 3;
    lbl.Width := 100;
    lbl.Height := 25;
    lbl.Caption := Name +':';
    lbl.Parent := row;
    lbl.Show;

    var ColBox := TColorBox.Create(row);
    ColBox.Parent := row;
    ColBox.Left := 8 + lbl.Left + lbl.Width;
    ColBox.Top  := 3;
    ColBox.Width := 150;
    ColBox.Height := 22;
    ColBox.Name := Name;
    ColBox.Style := [cbStandardColors, cbExtendedColors, cbSystemColors, cbCustomColor];
    ColBox.OnChange := ChangeColor;
    ColBox.DefaultColorColor := Value;
    ColBox.Selected := Value;
    ColBox.Show;

end;

procedure TOptionsFrame.SetTheme(const Value: TWvNGitLensTheme);
begin
  FTheme := Value;
  ShowTheme;
end;

procedure TOptionsFrame.ShowTheme;
begin
  var i := 0;
  for var field in TRTTIContext.Create.GetType(TypeInfo(TWvNGitLensTheme)).GetFields do
  begin
    CreateEditor(field.Name, Field.GetValue( @FTheme ).AsInt64, i);
    Inc(i);
  end;
end;

end.
