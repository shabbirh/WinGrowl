object frmNotification: TfrmNotification
  Left = 234
  Top = 114
  BorderIcons = []
  BorderStyle = bsNone
  Caption = 'Notification'
  ClientHeight = 69
  ClientWidth = 288
  Color = clGray
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Arial'
  Font.Style = []
  OldCreateOrder = False
  Position = poDefault
  OnClick = FormClick
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 14
  object Gradient1: TGradient
    Left = 0
    Top = 0
    Width = 288
    Height = 69
    Align = alClient
    BorderColor = clWhite
    BorderWidth = 1
    ColorBegin = clBlack
    ColorEnd = clGray
    Style = gsLinearV
    OnClick = FormClick
  end
  object lblTitle: TLabel
    Left = 8
    Top = 8
    Width = 273
    Height = 19
    AutoSize = False
    Caption = 'lblTitle'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWhite
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
    OnClick = FormClick
  end
  object lblDescription: TLabel
    Left = 8
    Top = 24
    Width = 273
    Height = 41
    AutoSize = False
    Caption = 'lblDescription'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    Transparent = True
    WordWrap = True
    OnClick = FormClick
  end
  object tmrLifetime: TTimer
    Enabled = False
    Interval = 6500
    OnTimer = tmrLifetimeTimer
    Left = 88
    Top = 16
  end
  object tmrFade: TTimer
    Enabled = False
    Interval = 10
    OnTimer = tmrFadeTimer
    Left = 152
    Top = 16
  end
end
