program Server;

uses
  WinApi.Windows,
  Forms,
  Main in 'Main.pas' {RecvForm},
  UDM_Oracle in 'UDM_Oracle.pas' {DM_ORACLE: TDataModule},
  OverbyteIcsIniFiles in 'OverbyteIcsIniFiles.pas';

{$R *.res}

var
  hm: THandle;
begin
  hm := CreateMutex(Nil, False, 'ServerMutex');
  if WaitforSingleObject(hm, 0) <> Wait_TimeOut then
  begin
    Application.Initialize;
    Application.Title := 'Server: MsgCommunicator. (c) 2014 dyddyd';
    Application.CreateForm(TDM_ORACLE, DM_ORACLE);
  Application.CreateForm(TRecvForm, RecvForm);
  Application.Run;
  end;
end.
