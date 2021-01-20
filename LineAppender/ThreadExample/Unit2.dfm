object Form2: TForm2
  Left = 0
  Top = 0
  Caption = 'Form2'
  ClientHeight = 134
  ClientWidth = 444
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDblClick = FormDblClick
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 77
    Top = 40
    Width = 75
    Height = 25
    Caption = 'Start Thread'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 176
    Top = 40
    Width = 75
    Height = 25
    Caption = 'Pause Thread'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 272
    Top = 40
    Width = 75
    Height = 25
    Caption = 'Stop Thread'
    TabOrder = 2
    OnClick = Button3Click
  end
  object ProgressBar1: TProgressBar
    Left = 40
    Top = 88
    Width = 369
    Height = 17
    TabOrder = 3
  end
  object Edit1: TEdit
    Left = 40
    Top = 8
    Width = 89
    Height = 21
    Hint = 'Computer Name'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 4
    Text = 'Computer Name'
  end
  object Button4: TButton
    Left = 272
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Ping'
    TabOrder = 5
    OnClick = Button4Click
  end
  object Edit2: TEdit
    Left = 160
    Top = 8
    Width = 91
    Height = 21
    Hint = 'X Path'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 6
    Text = 'X Path'
  end
end
