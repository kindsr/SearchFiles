program Agent;

uses
  WinApi.Windows,
  Forms,
  OverbyteIcsIniFiles in 'OverbyteIcsIniFiles.pas',
  FAgent in 'FAgent.pas' {SenderForm},
  uFileLog in 'uFileLog.pas',
  uEventLog in 'uEventLog.pas',
  uFileMonLog in 'uFileMonLog.pas',
  FolderMon in 'FolderMon.pas',
  UDM_Sqlite in 'UDM_Sqlite.pas' {DM_SQLITE: TDataModule};

{$R *.RES}

var
  hm: THandle;
begin
  hm := CreateMutex(Nil, False, 'AgentMutex');
  if WaitforSingleObject(hm, 0) <> Wait_TimeOut then
  begin
    Application.Initialize;
    Application.CreateForm(TDM_SQLITE, DM_SQLITE);
    Application.CreateForm(TSenderForm, SenderForm);
    Application.Run;
  end;
end.
