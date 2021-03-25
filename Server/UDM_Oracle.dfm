object DM_ORACLE: TDM_ORACLE
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 241
  Width = 357
  object UniConnection1: TUniConnection
    ProviderName = 'oracle'
    SpecificOptions.Strings = (
      'oracle.Direct=True')
    Username = 'system'
    Server = '127.0.0.1:1521:XE'
    LoginPrompt = False
    Left = 40
    Top = 56
    EncryptedPassword = '9EFF9BFF92FF96FF91FF'
  end
  object UniQuery1: TUniQuery
    Connection = UniConnection1
    Left = 40
    Top = 128
  end
  object UniDataSource1: TUniDataSource
    Left = 128
    Top = 56
  end
  object OracleUniProvider1: TOracleUniProvider
    Left = 128
    Top = 128
  end
end
