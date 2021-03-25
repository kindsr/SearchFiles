unit SvcMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.SvcMgr, Vcl.Dialogs,
  Registry;

type
  TSearchFileAgent = class(TService)
    procedure ServiceAfterInstall(Sender: TService);
    procedure ServiceExecute(Sender: TService);
  private
    { Private declarations }
  public
    function GetServiceController: TServiceController; override;
    { Public declarations }
  end;

var
  SearchFileAgent: TSearchFileAgent;

implementation

{$R *.dfm}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  SearchFileAgent.Controller(CtrlCode);
end;

function TSearchFileAgent.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TSearchFileAgent.ServiceAfterInstall(Sender: TService);
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create(KEY_READ or KEY_WRITE);
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey('\SYSTEM\CurrentControlSet\Services\' + Name, false) then
    begin
      Reg.WriteString('Description', 'Service for Agent');
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
end;

procedure TSearchFileAgent.ServiceExecute(Sender: TService);
const
  SecBetweenRuns = 10;
var
  Count: Integer;
begin
  Count := 0;
  while not Terminated do
  begin
    Inc(Count);
    if Count >= SecBetweenRuns then
    begin
      Count := 0;

      { place your service code here }
      { this is where the action happens }
      WinExec('C:\Program Files\Agent\Agent.exe', SW_SHOW);

    end;
    Sleep(1000);
    ServiceThread.ProcessRequests(False);
  end;
end;

end.
