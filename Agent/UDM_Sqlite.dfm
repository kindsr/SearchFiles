object DM_SQLITE: TDM_SQLITE
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 337
  Width = 462
  object UniConnection1: TUniConnection
    ProviderName = 'SQLite'
    Database = 'C:\COMIS4S\Bin\AppLog.db'
    SpecificOptions.Strings = (
      
        'SQLite.ClientLibrary=C:\Documents and Settings\yongho\'#48148#53461' '#54868#47732'\'#50472#50893#49828'\' +
        'bin\sqlite3.dll'
      'SQLite.EncryptionKey=cwox!@#$%')
    Server = 'cwox'
    LoginPrompt = False
    Left = 40
    Top = 24
  end
  object SQLiteUniProvider1: TSQLiteUniProvider
    Left = 136
    Top = 24
  end
  object UniQuery1: TUniQuery
    Connection = UniConnection1
    Transaction = UniTransaction1
    SQL.Strings = (
      'select * from TOPTION')
    Left = 40
    Top = 96
  end
  object UniTransaction1: TUniTransaction
    DefaultConnection = UniConnection1
    Left = 240
    Top = 24
  end
  object UniQuery2: TUniQuery
    Connection = UniConnection1
    Transaction = UniTransaction1
    SQL.Strings = (
      'select * from TOPTION')
    Left = 136
    Top = 96
  end
end
