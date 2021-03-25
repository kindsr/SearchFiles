unit uFileMonLog;

interface

uses
  Windows, SysUtils;

type

  TCriticalSection = class
  protected
    FCriticalSection: TRTLCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Lock;
    procedure UnLock;
  end;

  TFileMonLog = class
  protected
    mFileLoggerLock: TCriticalSection;
    mFileName: string;
    mPath: string;

    mData: string;
    FLogFile: TextFile;
    FIsReWriteFile: Boolean;
    FIsShowDateTime: Boolean;
    FIsLog: Boolean;
  private
    procedure InitFileLog;
    function FormatMessage(const Msg: string): String;
  published
    property IsReWriteFile: Boolean read FIsReWriteFile write FIsReWriteFile;
    property IsShowDateTime: Boolean read FIsShowDateTime write FIsShowDateTime;
  public
    procedure WriteLogMsg(const sMsg: String);
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

constructor TFileMonLog.Create;
begin
  inherited Create;
  FIsReWriteFile := False;
  FIsShowDateTime := True;
  FIsLog := FALSE;
  mFileLoggerLock := TCriticalSection.Create;
  InitFileLog;
end;

procedure TFileMonLog.InitFileLog;
begin
  mData := FormatDateTime('yyyymmdd', Now());
  mPath := ExtractFilePath(ParamStr(0)) + 'FileMonLog';
  if not  DirectoryExists(mPath) then CreateDir(mPath);

  mFileName := ExtractFilePath(ParamStr(0)) + 'FileMonLog\' + mData + '.log';

  try
    AssignFile(FLogFile, mFileName);
    if(FileExists(mFileName)) then
      append(FLogFile)
    else
      rewrite(FLogFile);

    FIsLog := True;
  except
    FIsLog := False;
  end;
end;

destructor TFileMonLog.Destroy;
begin
  FreeAndNil(mFileLoggerLock);
  if FIsLog then CloseFile(FLogFile);
  inherited Destroy;
end;

function TFileMonLog.FormatMessage(const Msg: string): string;
begin
  if FIsShowDateTime then
    Result := FormatDateTime('hh:nn:ss', Now) + ' ';

  Result := Result + Msg;
end;

procedure TFileMonLog.WriteLogMsg(const sMsg: string);
begin
  try
    mFileLoggerLock.Lock;

    Writeln(FLogFile, FormatMessage(sMsg));
    flush(FLogFile);
  finally
    mFileLoggerLock.UnLock;
  end;
end;

{ TCriticalSection }

constructor TCriticalSection.Create;
begin
  inherited Create;

  InitializeCriticalSection(FCriticalSection);
end;

destructor TCriticalSection.Destroy;
begin
  DeleteCriticalSection(FCriticalSection);

  inherited Destroy;
end;

procedure TCriticalSection.Lock;
begin
  EnterCriticalSection(FCriticalSection);
end;

procedure TCriticalSection.UnLock;
begin
  LeaveCriticalSection(FCriticalSection);
end;

end.
