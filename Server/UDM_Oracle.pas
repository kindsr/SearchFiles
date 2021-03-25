unit UDM_Oracle;

interface

uses
  System.SysUtils, System.Classes, Vcl.Dialogs, UniProvider, Data.DB, DBAccess, Uni, MemDS, OracleUniProvider;

type
  TDM_ORACLE = class(TDataModule)
    UniConnection1: TUniConnection;
    UniQuery1: TUniQuery;
    UniDataSource1: TUniDataSource;
    OracleUniProvider1: TOracleUniProvider;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DM_ORACLE: TDM_ORACLE;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TDM_ORACLE.DataModuleCreate(Sender: TObject);
begin
    with UniConnection1 do
    begin
        Connected := False;
        ProviderName := 'oracle';
        Server := '127.0.0.1:1521:XE';
        Username := 'system';
        Password := 'admin';

        try
            Connected := True;
        except
            begin
                ShowMessage('데이터베이스 연결을 확인 하세요');
                Halt;
            end;
        end;
    end;
end;

end.
