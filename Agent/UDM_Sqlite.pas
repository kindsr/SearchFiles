unit UDM_Sqlite;

interface

uses
  System.SysUtils, System.Classes, Vcl.Dialogs, DBAccess, Uni, Data.DB, MemDS, UniProvider, SQLiteUniProvider;

type
  TDM_SQLITE = class(TDataModule)
    UniConnection1: TUniConnection;
    SQLiteUniProvider1: TSQLiteUniProvider;
    UniQuery1: TUniQuery;
    UniTransaction1: TUniTransaction;
    UniQuery2: TUniQuery;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DM_SQLITE: TDM_SQLITE;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TDM_SQLITE.DataModuleCreate(Sender: TObject);
begin
    try
        UniConnection1.Database := GetCurrentDir + '\AppLog.db';
        UniConnection1.SpecificOptions.Values['ClientLibrary'] := GetCurrentDir + '\sqlite3.dll';
        UniConnection1.SpecificOptions.Values['EncryptionKey'] := 'applog!@#$%';
        UniConnection1.Connected := True;
    except
        ShowMessage('로컬 데이터베이스 파일이 손상되었습니다.');
        Halt;
    end;
end;

end.
