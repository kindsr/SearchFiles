unit FolderMon;

interface

uses
  SysUtils
  , Classes
  , Windows
  ;

type
  TFolderAction =
    (
      faNew
      , faRemoved
      , faModified
      , faRenamedOld
      , faRenamedNew
    );

const
  FOLDER_ACTION_NAMES: array[TFolderAction] of string =
    ( 'New', 'Removed', 'Modified', 'OldName', 'NewName');

type
  TFolderItemInfo=record
    Name  : string;
    Action: TFolderAction;
  end;

  TChangeType =
    (
      ctFileName
      , ctDirName
      , ctAttr
      , ctSize
      , ctLastWriteTime
      , ctLastAccessTime
      , ctCreationTime
      , ctSecurityAttr
    );

  TChangeTypes = set of TChangeType;
  TFolderMon=class;
  TFolderChangeEvent = procedure (Sender: TFolderMon; AFolderItem: TFolderItemInfo) of object;
  TFolderMon=class
  private
    FFolder: string;
    FWorker: TThread;
    FMonitoredChanges: TChangeTypes;
    FMonitorSubFolders: Boolean;
    FOnFOlderChange: TFolderChangeEvent;
    FOnDeactivated: TNotifyEvent;
    FOnActivated: TNotifyEvent;
    procedure SetFolder(const Value: string);
    function GetIsActive: Boolean;
    procedure SetIsActive(const Value: Boolean);
    procedure SetMonitoredChanges(const Value: TChangeTypes);
    procedure SetMonitorSubFolders(const Value: Boolean);
  public
    destructor Destroy; override;

    procedure Activate;
    procedure Deactivate;

    property Folder: string read FFolder write SetFolder;
    property IsActive: Boolean read GetIsActive write SetIsActive;
    property MonitoredChanges : TChangeTypes read FMonitoredChanges write SetMonitoredChanges;
    property MonitorSubFolders: Boolean read FMonitorSubFolders write SetMonitorSubFolders;
    property OnFolderChange: TFolderChangeEvent read FOnFOlderChange write FOnFolderChange;
    property OnActivated: TNotifyEvent read FOnActivated write FOnActivated;
    property OnDeactivated: TNotifyEvent read FOnDeactivated write FOnDeactivated;
  end;

implementation

const
  NOTIFY_FILTERS: array[TChangeType] of DWORD =
    (
      FILE_NOTIFY_CHANGE_FILE_NAME     // ctFileName
      , FILE_NOTIFY_CHANGE_DIR_NAME    // ctDirName
      , FILE_NOTIFY_CHANGE_ATTRIBUTES  // ctAttr
      , FILE_NOTIFY_CHANGE_SIZE        // ctSize
      , FILE_NOTIFY_CHANGE_LAST_WRITE  // ctLastWriteTime
      , FILE_NOTIFY_CHANGE_LAST_ACCESS // ctLastAccessTime
      , FILE_NOTIFY_CHANGE_CREATION    // ctCreationTime
      , FILE_NOTIFY_CHANGE_SECURITY    // ctSecurityAttr
    );

type
  TFolderMonWorker=class(TThread)
  private
    Owner: TFolderMon;
    FFolder: THandle;
    FMonFilter: DWord;
    FFolderItemInfo: TFolderItemInfo;
    procedure SetUp;
    procedure TearDown;
    procedure DoFolderItemChange;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwner: TFolderMon); reintroduce;
  end;

{ TFolderMon }

procedure TFolderMon.Activate;
begin
  if IsActive then
    Exit;

  if FMonitoredChanges=[] then
    raise Exception.Create('Please specify event(s) to be monitored');
  if not DirectoryExists(FFolder) then
    raise Exception.Create('Please supply valid/existing folder');

  FWorker := TFolderMonWorker.Create(Self);
  if Assigned(FOnActivated) then
    FOnActivated(Self);
end;

procedure TFolderMon.Deactivate;
begin
  if not IsActive then
    Exit;

  with TFolderMonWorker(FWorker) do
  begin
    Owner := nil;
    Terminate;
  end;
  FWorker := nil;
  if Assigned(FOnDeactivated) then
    FOnDeactivated(Self);
end;

destructor TFolderMon.Destroy;
begin
  Deactivate;
  inherited;
end;

function TFolderMon.GetIsActive: Boolean;
begin
  Result := FWorker <> nil;
end;

procedure TFolderMon.SetFolder(const Value: string);
begin
  if LowerCase(FFolder)=LowerCase(Value) then
    Exit;

  if IsActive then
    raise Exception.Create('Currently still actively monitoring a folder. Please deactivate before changing monitored folder.');

  FFolder := Value;
end;

procedure TFolderMon.SetIsActive(const Value: Boolean);
begin
  if Value then
    Activate
  else
    Deactivate;
end;

procedure TFolderMon.SetMonitoredChanges(const Value: TChangeTypes);
begin
  if FMonitoredChanges = Value then
    Exit;

  if IsActive then
    raise Exception.Create('The monitor must be deactivated before changing the monitored event(s)');
  FMonitoredChanges := Value;
end;

procedure TFolderMon.SetMonitorSubFolders(const Value: Boolean);
begin
  if FMonitorSubFolders=Value then
    Exit;

  if IsActive then
    raise Exception.Create('Please deactivate the monitor first');

  FMonitorSubFolders := Value;
end;

{ TFolderMonWorker }

constructor TFolderMonWorker.Create(AOwner: TFolderMon);
begin
  Owner := AOwner;
  if Owner=nil then
    raise Exception.Create('Reference to TFolderMon instance must be specified');

  inherited Create(False);
  FreeOnTerminate := True;
  SetUp;
end;

const
  FILE_LIST_DIRECTORY = $0001;

type
  _FILE_NOTIFY_INFORMATION=packed record
    NextEntryOffset: DWORD;
    Action: DWORD;
    FileNameLength: DWORD;
    FileName: WideChar;
  end;
  FILE_NOTIFY_INFORMATION = _FILE_NOTIFY_INFORMATION;
  PFILE_NOTIFY_INFORMATION = ^FILE_NOTIFY_INFORMATION;

procedure TFolderMonWorker.DoFolderItemChange;
begin
  if Assigned(Owner) and Assigned(Owner.FOnFolderChange) then
    Owner.FOnFOlderChange(Owner, FFolderItemInfo);
end;

procedure TFolderMonWorker.Execute;
const
  cBufSize = 32 * 1024;  // 32k
var
  B: Pointer;
  vCount: DWord;
  vOffset: DWord;
  vFileInfo: PFILE_NOTIFY_INFORMATION;
begin
  GetMem(B, cBufSize);
  try
    while not Terminated do
    begin
      if Owner=nil then
        Exit;

      if ReadDirectoryChangesW(FFolder
                               , B
                               , cBufSize
                               , Owner.MonitorSubFolders
                               , FMonFilter
                               , @vCount
                               , nil
                               , nil
                              )
         and (vCount > 0) then
      begin
        if Owner=nil then
          Exit;

        vFileInfo := B;
        repeat
          vOffset := vFileInfo.NextEntryOffset;

          FFolderItemInfo.Name := WideCharLenToString(@vFileInfo^.FileName, vFileInfo^.FileNameLength);
          SetLength(FFolderItemInfo.Name, vFileInfo^.FileNameLength div 2);
          case vFileInfo^.Action of
            FILE_ACTION_ADDED           : FFolderItemInfo.Action := faNew;
            FILE_ACTION_REMOVED         : FFolderItemInfo.Action := faRemoved;
            FILE_ACTION_MODIFIED        : FFolderItemInfo.Action := faModified;
            FILE_ACTION_RENAMED_OLD_NAME: FFolderItemInfo.Action := faRenamedOld;
            FILE_ACTION_RENAMED_NEW_NAME: FFolderItemInfo.Action := faRenamedNew;
          end;
          Synchronize(DoFolderItemChange);
          PByte(vFileInfo) := PByte(DWORD(vFileInfo) + vOffset);
        until vOffset=0;
      end;
    end;
  finally
    TearDown;
    FreeMem(B, cBufSize);
  end;
end;

procedure TFolderMonWorker.SetUp;
var
  i: TChangeType;
begin
  FFolder := CreateFile(PChar(Owner.Folder)
                        , FILE_LIST_DIRECTORY or GENERIC_READ
                        , FILE_SHARE_READ or FILE_SHARE_WRITE or FILE_SHARE_DELETE
                        , nil
                        , OPEN_EXISTING
                        , FILE_FLAG_BACKUP_SEMANTICS
                        , 0);

  FMonFilter := 0;
  for i := Low(TChangeType) to High(TChangeType) do
    if i in Owner.MonitoredChanges then
      FMonFilter := FMonFilter or NOTIFY_FILTERS[i];
end;

procedure TFolderMonWorker.TearDown;
begin
  CloseHandle(FFolder);
end;

end.
