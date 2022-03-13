object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'Git Lens Test'
  ClientHeight = 888
  ClientWidth = 1201
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 15
  object ListView1: TListView
    Left = 0
    Top = 0
    Width = 1201
    Height = 888
    Align = alClient
    Columns = <
      item
      end
      item
        Width = 300
      end
      item
        AutoSize = True
      end>
    OwnerData = True
    TabOrder = 0
    ViewStyle = vsReport
    OnData = ListView1Data
  end
end
