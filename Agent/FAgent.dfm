object SenderForm: TSenderForm
  Left = 217
  Top = 161
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Agent'
  ClientHeight = 554
  ClientWidth = 654
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #47569#51008' '#44256#46357
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 15
  object WebBrowser1: TWebBrowser
    Left = 346
    Top = 8
    Width = 300
    Height = 150
    TabOrder = 5
    ControlData = {
      4C000000021F0000810F00000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E126208000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
  object Panel1: TPanel
    Left = 0
    Top = 481
    Width = 654
    Height = 73
    Align = alBottom
    TabOrder = 0
    Visible = False
    object Label3: TLabel
      Left = 12
      Top = 40
      Width = 25
      Height = 15
      Caption = 'Data'
    end
    object Label4: TLabel
      Left = 356
      Top = 12
      Width = 36
      Height = 15
      Caption = 'Repeat'
    end
    object Label5: TLabel
      Left = 236
      Top = 12
      Width = 63
      Height = 15
      Caption = 'Line Length'
    end
    object CountLabel: TLabel
      Left = 396
      Top = 40
      Width = 33
      Height = 15
      Caption = 'Count'
    end
    object DataEdit: TEdit
      Left = 48
      Top = 36
      Width = 177
      Height = 23
      ImeName = 'Microsoft IME 2010'
      TabOrder = 0
      Text = 'DataEdit'
    end
    object RepeatEdit: TEdit
      Left = 400
      Top = 8
      Width = 37
      Height = 23
      ImeName = 'Microsoft IME 2010'
      TabOrder = 2
      Text = 'RepeatEdit'
    end
    object ContCheckBox: TCheckBox
      Left = 460
      Top = 6
      Width = 65
      Height = 17
      Alignment = taLeftJustify
      Caption = 'Continous'
      TabOrder = 3
    end
    object LengthEdit: TEdit
      Left = 300
      Top = 8
      Width = 41
      Height = 23
      ImeName = 'Microsoft IME 2010'
      TabOrder = 1
      Text = 'LengthEdit'
    end
    object DisplayDataCheckBox: TCheckBox
      Left = 444
      Top = 21
      Width = 81
      Height = 17
      Alignment = taLeftJustify
      Caption = 'Display Data'
      TabOrder = 4
    end
    object UseDataSentCheckBox: TCheckBox
      Left = 428
      Top = 36
      Width = 97
      Height = 17
      Alignment = taLeftJustify
      Caption = 'Use onDataSent'
      TabOrder = 5
    end
    object PauseButton: TButton
      Left = 292
      Top = 36
      Width = 49
      Height = 21
      Caption = '&Pause'
      TabOrder = 6
    end
    object AutoStartButton: TButton
      Left = 348
      Top = 36
      Width = 41
      Height = 21
      Caption = '&Auto'
      TabOrder = 7
    end
    object LingerCheckBox: TCheckBox
      Left = 477
      Top = 52
      Width = 48
      Height = 17
      Alignment = taLeftJustify
      Caption = 'Linger'
      TabOrder = 8
    end
    object Button1: TButton
      Left = 560
      Top = 24
      Width = 75
      Height = 25
      Caption = 'Button1'
      TabOrder = 9
      Visible = False
      OnClick = Button1Click
    end
  end
  object DisplayMemo: TMemo
    Left = 0
    Top = 41
    Width = 654
    Height = 44
    Align = alTop
    ImeName = 'Microsoft IME 2010'
    TabOrder = 1
  end
  object lvServer: TListView
    Left = 0
    Top = 85
    Width = 654
    Height = 366
    Align = alClient
    Columns = <
      item
        Caption = #50896#48376
      end
      item
        Caption = #45216#51676'/'#49884#44036
      end
      item
        Caption = #44221#47196
      end>
    TabOrder = 2
    ViewStyle = vsReport
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 451
    Width = 654
    Height = 30
    Panels = <
      item
        Width = 500
      end>
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 654
    Height = 41
    Align = alTop
    TabOrder = 3
    object Label1: TLabel
      Left = 8
      Top = 12
      Width = 33
      Height = 15
      Caption = 'Server'
    end
    object Label2: TLabel
      Left = 144
      Top = 12
      Width = 22
      Height = 15
      Caption = 'Port'
    end
    object ServerEdit: TEdit
      Left = 48
      Top = 8
      Width = 89
      Height = 23
      ImeName = 'Microsoft IME 2010'
      TabOrder = 0
      Text = 'ServerEdit'
    end
    object PortEdit: TEdit
      Left = 168
      Top = 8
      Width = 57
      Height = 23
      ImeName = 'Microsoft IME 2010'
      TabOrder = 1
      Text = 'PortEdit'
    end
    object btnAction: TButton
      Left = 236
      Top = 9
      Width = 45
      Height = 21
      Caption = '&Start'
      TabOrder = 2
      OnClick = btnActionClick
    end
    object Button2: TButton
      Left = 287
      Top = 9
      Width = 75
      Height = 21
      Caption = 'Send Msg'
      TabOrder = 3
      OnClick = Button2Click
    end
  end
  object DirListBox: TListBox
    Left = 525
    Top = 348
    Width = 121
    Height = 97
    ItemHeight = 15
    TabOrder = 6
  end
  object RzTrayIcon1: TRzTrayIcon
    Hint = 'Agent'
    Left = 608
    Top = 116
  end
  object Timer1: TTimer
    Interval = 60000
    OnTimer = Timer1Timer
    Left = 528
    Top = 304
  end
  object Timer2: TTimer
    Left = 568
    Top = 304
  end
  object Timer3: TTimer
    Left = 608
    Top = 304
  end
end
