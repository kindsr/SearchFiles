program FtpServer;

uses
  Vcl.Forms,
  OverbyteIcsFtpServ1 in 'OverbyteIcsFtpServ1.pas' {FtpServerForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFtpServerForm, FtpServerForm);
  Application.Run;
end.
