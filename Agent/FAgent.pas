unit FAgent;

interface

{$I ver.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, DateUtils,
  Dialogs, ExtCtrls, StdCtrls, Vcl.OleCtrls, WinInet, ActiveX, ComObj, WinSock,
  OverbyteIcsIniFiles, OverbyteIcsWndControl, OverbyteIcsFtpCli, OverbyteIcsUtils,
  System.Zip, RzTray, Vcl.ComCtrls, uFileLog, uEventLog, uFileMonLog, FolderMon,
  MsgComBase, MsgClient, MsgConst, MsgTypes, OverbyteIcsLogger, SHDocVw;

const
  WM_AUTO_START      = WM_USER + 1;
  WM_CLOSE_REQUEST   = WM_USER + 2;
  RUN_SIGNATURE = FALSE;
  IS_TEST       = FALSE;
  IP_LOCAL      = '172.24.33.151';
  IP_DEV        = '10.210.5.217';
  IP_CARD       = '10.222.21.31';
  IP_CAPITAL    = '10.210.8.217';
  IP_COMERCIAL  = '10.209.6.217';

type
  TSenderForm = class(TForm)
    Panel1: TPanel;
    Label3: TLabel;
    DataEdit: TEdit;
    Label4: TLabel;
    RepeatEdit: TEdit;
    ContCheckBox: TCheckBox;
    DisplayMemo: TMemo;
    Label5: TLabel;
    LengthEdit: TEdit;
    DisplayDataCheckBox: TCheckBox;
    UseDataSentCheckBox: TCheckBox;
    PauseButton: TButton;
    CountLabel: TLabel;
    AutoStartButton: TButton;
    LingerCheckBox: TCheckBox;
    RzTrayIcon1: TRzTrayIcon;
    lvServer: TListView;
    Button1: TButton;
    StatusBar1: TStatusBar;
    Panel2: TPanel;
    Label1: TLabel;
    ServerEdit: TEdit;
    Label2: TLabel;
    PortEdit: TEdit;
    FtpClient1: TFtpClient;
    Timer1: TTimer;
    DirListBox: TListBox;
    MsgClient1: TMsgClient;
    btnAction: TButton;
    Timer2: TTimer;
    Button2: TButton;
    Timer3: TTimer;
    IcsLogger1: TIcsLogger;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FtpClient1BgException(Sender: TObject; E: Exception; var CanClose: Boolean);
    procedure MsgClient1ReceiveTextMessage(const FromUserID: Cardinal; const SendingDate, DeliveryDate: TDateTime; const Text: AnsiString);
    procedure MsgClient1ReceiveUnicodeTextMessage(const FromUserID: Cardinal; const SendingDate, DeliveryDate: TDateTime; const Text: WideString);
    procedure MsgClient1ServerShutdown(Sender: TObject);
    procedure btnActionClick(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Timer3Timer(Sender: TObject);
  private
    FileLogger: TFileLog;
    EventLogger: TEventLog;
    FileMonLogger: TFileMonLog;
    FFolderMon: TFolderMon;
    FFolderMonE: TFolderMon;
    FIniFileName : String;
    FInitialized : Boolean;
    iSeq: Integer;
    iMonSeq: Integer;
    FSelUserName    : string;
    FSelPassword    : string;
    FSender         : string;
    FSchedRealDiv   : string;   // 스케줄실시간구분 : 01=스케줄, 02=실시간
    FDegree         : Integer;  // 차수
    FDegreeSeq      : Integer;  // 차수에 대한 순번
    FStcDynDiv      : string;   // 정적동적구분 : 01=적정수집(전체), 02=동적수집(증분)
    FCltStrtDm      : string;   // 수집시작일시
    FCltEndDm       : string;   // 수집종료일시
    FModCltStrtDm2  : string;   // 동적으로 수행할 수집시작시간
    FModCltEndDm2   : string;   // 동적으로 수행할 수집종료시간
    // 에이전트 수행상태
    // 0:서버로부터메시지받음 10:파일검색시작 20:파일검색종료 30:파일전송중 40:파일전송완료
    // 50:스케쥴대기 60:증분수집 70:증분파일전송중 80:증분파일전송완료
    FStatus         : Integer;
    FLastRunDate    : string;
    FLastRunTime    : string;
    FLastDynDate    : string;
    FLastDynTime    : string;
    FUserID         : string;
    procedure Display(Msg : String);
    procedure DoSearch(const Path: String; const FileExts: TStringList); overload;
    procedure DoSearch(const Path: String; const FileExts, FileSignatures: TStringList); overload;
    procedure FindAllFiles(const Path, FileExt: String); overload;
    procedure FindAllFiles(const Path, FileExt, FileSignature: String); overload;
    procedure FtpSendFiles(fc: TFtpClient; logFile: string);
    procedure FtpSendDynFiles(fc: TFtpClient; logFile: string);
    function  GetLocalIP: string;
    procedure CheckUpdate;
    function  GetFileDateTime(FileName: string): TDateTime;
    function  SetFileDateTime(const FileName: String; const FileDate: TDateTime): Boolean;
    function  GetMonthNumberofName(AMonth: string): Integer; overload;
    function  GetMonthNumberofName(AMonth: string; AFormatSettings: array of string): Integer; overload;
    function  IsFileinUse(FileName: TFileName): Boolean;
    procedure SetConnectParams;
    procedure GetConnectParams;
    procedure DoConnect;
    procedure DoDisconnect;
    function  PortTCP_IsOpen(dwPort: Word; ipAddressStr: AnsiString): boolean;
    procedure VisualizeLogged;
    procedure AddMessage(const FromUserID: Cardinal; const Text: String; const MsgDate: TDateTime);
    procedure HandleFolderChange(ASender: TFolderMon; AFolderItem: TFolderItemInfo);
    procedure DoMonitoring;
    procedure UpdateIniFile;
  public
    { Delarations publiques }
  end;

var
  SenderForm: TSenderForm;

implementation

{$R *.DFM}
uses
    UDM_Sqlite;

const
    SectionData     = 'Data';
    KeyPort         = 'Port';
    KeyServer       = 'Server';
    SectionWindow   = 'Agent';
    KeySender       = 'Sender';
    KeySelUserName  = 'SelUserName';
    KeySelPassword  = 'SelPassword';
    KeySchedRealDiv = 'SchedRealDiv';
    KeyDegree       = 'Degree';
    KeyDegreeSeq    = 'DegreeSeq';
    KeyStcDynDiv    = 'StcDynDiv';
    KeyCltStrtDm    = 'CltStrtDm';
    KeyCltEndDm     = 'CltEndDm';
    KeyModCltStrtDm2= 'ModCltStrtDm2';
    KeyModCltEndDm2 = 'ModCltEndDm2';
    KeyStatus       = 'Status';
    KeyLastRunDate  = 'LastRunDate';
    KeyLastRunTime  = 'LastRunTime';
    KeyLastDynDate  = 'LastDynDate';
    KeyLastDynTime  = 'LastDynTime';

const
    MAGICNUMBER_DRM   = $53444353;          // drm 걸려있는것
    MAGICNUMBER_PDF   = $46445025;
    MAGICNUMBER_XLS   = $e11ab1a1e011cfd0;  // Microsoft Office Compound Document File CaseWare Working Papers Compressed Client File
    MAGICNUMBER_XLSX  = $0006001404034b50;  // DOCX, PPTX, XLSX Microsoft Office Open XML Format Document
    MAGICNUMBER_ZIP   = $04034b50;          // Archive - PkZip Archive File
    MAGICNUMBER_ZIP1  = $4554494c4b50;      // PKLITE Zip Archive
    MAGICNUMBER_ZIP2  = $5870534b50;        // PKSFX Self=Extracting Executable Compressed File
    MAGICNUMBER_ZIP3  = $70695a6e6957;      // WinZip Compressed archive

    MAGICNUMBEREX_JAR   = $0008001404034b50; // Java Archive
    MAGICNUMBEREX_JAR1  = $0800000a04034b50; // Java Archive

const
    monthnames: array[1..12] of string = ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TSenderForm.FormCreate(Sender: TObject);
begin
    EventLogger := TEventLog.Create;
    FileMonLogger := TFileMonLog.Create;
    FFolderMon := TFolderMon.Create;
    FFolderMon.OnFolderChange := HandleFolderChange;
    FFolderMonE := TFolderMon.Create;
    FFolderMonE.OnFolderChange := HandleFolderChange;
//    FIniFileName := GetCurrentDir + '\Agent.ini';  //OverbyteIcsIniFiles.GetIcsIniFileName;
    FIniFileName := ExtractFilePath(ParamStr(0)) + 'Agent.ini';  //OverbyteIcsIniFiles.GetIcsIniFileName;

    lvServer.Columns[0].Width := 150;
    lvServer.Columns[1].Width := 100;
    lvServer.Columns[2].Width := 300;
    lvServer.Clear;

//    clbContactList.Color := clMemu;
    MsgClient1ServerShutdown(Sender);
    SetConnectParams;
    VisualizeLogged;
end;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TSenderForm.FormShow(Sender: TObject);
var
    IniFile : TIcsIniFile;
begin
  if FileExists(ExtractFilePath(ParamStr(0))) then
    FInitialized := False;

  if not FInitialized then
  begin
    FInitialized := TRUE;
    IniFile      := TIcsIniFile.Create(FIniFileName);
    try
      PortEdit.Text        := IniFile.ReadString(SectionData, KeyPort, '30001');

      // 카드 : 10.222.21.31
      // 캐피탈 : 10.210.8.217
      // 커머셜 : 10.209.6.217
      if IS_TEST then
        ServerEdit.Text      := IniFile.ReadString(SectionData, KeyServer, IP_LOCAL)
      else
        ServerEdit.Text      := IniFile.ReadString(SectionData, KeyServer, IP_DEV); // 개발Server IP

//        ServerEdit.Text      := IniFile.ReadString(SectionData, KeyServer, IP_CARD);       // 카드 IP
//        ServerEdit.Text      := IniFile.ReadString(SectionData, KeyServer, IP_CAPITAL);    // 캐피탈 IP
//        ServerEdit.Text      := IniFile.ReadString(SectionData, KeyServer, IP_COMERCIAL);  // 커머셜 IP

      FSender         := IniFile.ReadString(SectionWindow,   KeySender          , 'WAS');
      FSelUserName    := IniFile.ReadString(SectionWindow,   KeySelUserName     , 'checkagent');
      FSelPassword    := IniFile.ReadString(SectionWindow,   KeySelPassword     , 'checkagent');
      FSchedRealDiv   := IniFile.ReadString(SectionWindow,   KeySchedRealDiv    , '');
      FDegree         := IniFile.ReadInteger(SectionWindow,  KeyDegree          , 0);
      FDegreeSeq      := IniFile.ReadInteger(SectionWindow,  KeyDegreeSeq       , 0);
      FStcDynDiv      := IniFile.ReadString(SectionWindow,   KeyStcDynDiv       , '');
      FCltStrtDm      := IniFile.ReadString(SectionWindow,   KeyCltStrtDm       , '');
      FCltEndDm       := IniFile.ReadString(SectionWindow,   KeyCltEndDm        , '');
      FModCltStrtDm2  := IniFile.ReadString(SectionWindow,   KeyModCltStrtDm2   , '');
      FModCltEndDm2   := IniFile.ReadString(SectionWindow,   KeyModCltEndDm2    , '');
      // 에이전트 수행상태
      // 0:서버로부터메시지받음 10:파일검색시작 20:파일검색종료 30:파일전송중 40:파일전송완료
      // 50:스케쥴대기 60:증분수집 70:증분파일전송중 80:증분파일전송완료
      FStatus         := IniFile.ReadInteger(SectionWindow,  KeyStatus          , 0);
      FLastRunDate    := IniFile.ReadString(SectionWindow,   KeyLastRunDate     , '');
      FLastRunTime    := IniFile.ReadString(SectionWindow,   KeyLastRunTime     , '');
      FLastDynDate    := IniFile.ReadString(SectionWindow,   KeyLastDynDate     , '');
      FLastDynTime    := IniFile.ReadString(SectionWindow,   KeyLastDynTime     , '');
    finally
      IniFile.Free;
    end;
  end;

  CheckUpdate;

  btnActionClick(Self);
end;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TSenderForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
  IniFile : TIcsIniFile;
begin
  IniFile := TIcsIniFile.Create(FIniFileName);
  try
    IniFile.WriteString(SectionData,    KeyPort            , PortEdit.text);
    IniFile.WriteString(SectionData,    KeyServer          , ServerEdit.text);
    IniFile.WriteString(SectionWindow,  KeySender          , FSender);
    IniFile.WriteString(SectionWindow,  KeySelUserName     , FSelUserName);
    IniFile.WriteString(SectionWindow,  KeySelPassword     , FSelPassword);
    IniFile.WriteString(SectionWindow,  KeySchedRealDiv    , FSchedRealDiv);
    IniFile.WriteInteger(SectionWindow, KeyDegree          , FDegree);
    IniFile.WriteInteger(SectionWindow, KeyDegreeSeq       , FDegreeSeq);
    IniFile.WriteString(SectionWindow,  KeyStcDynDiv       , FStcDynDiv);
    IniFile.WriteString(SectionWindow,  KeyCltStrtDm       , FCltStrtDm);
    IniFile.WriteString(SectionWindow,  KeyCltEndDm        , FCltEndDm);
    IniFile.WriteString(SectionWindow,  KeyModCltStrtDm2   , FModCltStrtDm2);
    IniFile.WriteString(SectionWindow,  KeyModCltEndDm2    , FModCltEndDm2);
    IniFile.WriteInteger(SectionWindow, KeyStatus          , FStatus);
    IniFile.WriteString(SectionWindow,  KeyLastRunDate     , FLastRunDate);
    IniFile.WriteString(SectionWindow,  KeyLastRunTime     , FLastRunTime);
    IniFile.WriteString(SectionWindow,  KeyLastDynDate     , FLastDynDate);
    IniFile.WriteString(SectionWindow,  KeyLastDynTime     , FLastDynTime);
    IniFile.UpdateFile;
  finally
    IniFile.Free;
  end;

  DoDisconnect;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TSenderForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(EventLogger);
  FreeAndNil(FileMonLogger);
  FreeAndNil(FFolderMon);
  FreeAndNil(FFolderMonE);
end;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TSenderForm.Display(Msg : String);
begin
  if DisplayMemo.lines.Count > 200 then
    DisplayMemo.Clear;
  DisplayMemo.Lines.Add(Msg);
end;

procedure TSenderForm.btnActionClick(Sender: TObject);
begin
  if btnAction.Caption = '&Stop' then
  begin
    btnAction.Caption := '&Start';
    DoDisconnect;
  end
  else
  begin
    try
      btnAction.Caption := '&Stop';
      DoConnect;
    except
      EventLogger.WriteLogMsg('Cannot connect to server');
      end;
  end;
end;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TSenderForm.Button1Click(Sender: TObject);
var
  slAllFiles: TStringList;
  slAllFilesSig: TStringList;
  slTargetPaths: TStringList;
  i: Integer;
  szFileName: string;
  res: Integer;
begin
  Timer3.Enabled := False;
  Timer1.Enabled := False;

  res := MsgClient1.SendMessage(0, 'FILESCANSTART');
  if (res = MSG_COMMAND_OK) then
  begin
    EventLogger.WriteLogMsg('FILESCANSTART');
    // 에이전트 수행상태
    // 0:서버로부터메시지받음 10:파일검색시작 20:파일검색종료 30:파일전송중 40:파일전송완료
    // 50:스케쥴대기 60:증분수집 70:증분파일전송중 80:증분파일전송완료
    FStatus := 10;
  end
  else
  begin
    EventLogger.WriteLogMsg('Fail to SendMessage : FILESCANSTART  ' + IntToStr(res));
    FStatus := 11;
  end;

  UpdateIniFile;

  lvServer.Clear;
  iSeq := 0;

  szFileName := ExtractFilePath(ParamStr(0)) + 'Log\' + 'FileScan' + '.txt';
  DeleteFile(szFileName);

  FileLogger := TFileLog.Create;
  slAllFiles := TStringList.Create;
  slAllFilesSig := TStringList.Create;

  if not RUN_SIGNATURE then
  begin
    slAllFiles.Add('pdf');
    slAllFiles.Add('doc');
    slAllFiles.Add('docx');

    slAllFiles.Add('ppt');
    slAllFiles.Add('pptx');
    slAllFiles.Add('xls');
    slAllFiles.Add('xlsx');
    slAllFiles.Add('zip');
    slAllFiles.Add('txt');
  end
  else
  begin
    slAllFiles.Add('*');
    slAllFilesSig.Add(MAGICNUMBER_DRM.ToHexString);
    slAllFilesSig.Add(MAGICNUMBER_PDF.ToHexString);
    slAllFilesSig.Add(MAGICNUMBER_XLS.ToHexString);
    slAllFilesSig.Add(MAGICNUMBER_XLSX.ToHexString);
//    slAllFilesSig.Add(MAGICNUMBER_ZIP.ToHexString);
    slAllFilesSig.Add(MAGICNUMBER_ZIP1.ToHexString);
    slAllFilesSig.Add(MAGICNUMBER_ZIP2.ToHexString);
    slAllFilesSig.Add(MAGICNUMBER_ZIP3.ToHexString);
  end;

  slTargetPaths := TStringList.Create;
  slTargetPaths.Add('C:\');

  if DirectoryExists('D:\') then
    slTargetPaths.Add('D:\');

  if DirectoryExists('E:\') then
    slTargetPaths.Add('E:\');

  if DirectoryExists('F:\') then
    slTargetPaths.Add('F:\');

  // Thread Process
  if not RUN_SIGNATURE then
  begin
    for i := 0 to slTargetPaths.Count - 1 do
    begin
      DoSearch(slTargetPaths.Strings[i], slAllFiles);
    end;
  end
  else
  begin
    for i := 0 to slTargetPaths.Count - 1 do
    begin
      DoSearch(slTargetPaths.Strings[i], slAllFiles, slAllFilesSig);
      end;
  end;

  res := MsgClient1.SendMessage(0, 'FILESCANEND');
  if (res = MSG_COMMAND_OK) then
  begin
    EventLogger.WriteLogMsg('FILESCANEND');
    // 에이전트 수행상태
    // 0:서버로부터메시지받음 10:파일검색시작 20:파일검색종료 30:파일전송중 40:파일전송완료
    // 50:스케쥴대기 60:증분수집 70:증분파일전송중 80:증분파일전송완료
    FStatus := 20;
  end
  else
  begin
    EventLogger.WriteLogMsg('Fail to SendMessage : FILESCANEND  ' + IntToStr(res));
    FStatus := 21;
  end;

  UpdateIniFile;

  FreeAndNil(FileLogger);
  FreeAndNil(slTargetPaths);
  FreeAndNil(slAllFiles);
  FreeAndNil(slAllFilesSig);

//    Sleep(1000);
  // File Send
  FtpSendFiles(FtpClient1, szFileName);
  Timer1.Enabled := True;
  Timer3.Enabled := True;
end;

procedure TSenderForm.Button2Click(Sender: TObject);
var
  res : Integer;
begin
  // 증분실행
  // 모니터링 잠시 중단
  FFolderMon.Deactivate;
  // 로그정보 읽어오기
  FreeAndNil(FileMonLogger);
  FtpSendDynFiles(FtpClient1, ExtractFilePath(ParamStr(0)) + 'FileMonLog\' + FormatDateTime('yyyymmdd', Now()) + '.log');
  // 새 로그파일 생성
  iMonSeq := 0;
  FileMonLogger := TFileMonLog.Create;
  // 모니터링시작
  DoMonitoring;
end;

procedure TSenderForm.DoSearch(const Path: String; const FileExts: TStringList);
var
  SR: TSearchRec;
  i: Integer;
begin
    Application.ProcessMessages;
    StatusBar1.Panels[0].Text := Path;
    Application.ProcessMessages;
    for i:=0 to FileExts.Count-1 do
    begin
      FindAllFiles(Path, '*.' + FileExts.Strings[i]);
    end;

  if FindFirst(Path + '*.*', faDirectory, SR) = 0 then
    try
      repeat
        if ((SR.Attr and faDirectory) <> 0) and (SR.Name[1] <> '.') then
        begin
          DoSearch(Path + SR.Name + '\', FileExts);
        end;
      until (FindNext(SR) <> 0);
    finally
      SysUtils.FindClose(SR);
    end;
end;

procedure TSenderForm.DoSearch(const Path: String; const FileExts, FileSignatures: TStringList);
var
  SR: TSearchRec;
  i: Integer;
begin
    Application.ProcessMessages;
    StatusBar1.Panels[0].Text := Path;
    Application.ProcessMessages;
    for i:=0 to FileExts.Count-1 do
    begin
      FindAllFiles(Path, '*.*', FileSignatures.Strings[i]);
    end;

  if FindFirst(Path + '*.*', faDirectory, SR) = 0 then
    try
      repeat
        if ((SR.Attr and faDirectory) <> 0) and (SR.Name[1] <> '.') then
        begin
          DoSearch(Path + SR.Name + '\', FileExts, FileSignatures);
        end;
      until (FindNext(SR) <> 0);
    finally
      SysUtils.FindClose(SR);
    end;
end;

procedure TSenderForm.FindAllFiles(const Path, FileExt: String);
var
  SR: TSearchRec;
begin
  if FindFirst(Path + FileExt, faArchive, SR) = 0 then
  begin
    try
      repeat
        if (FileExt <> '*.*') and ( LowerCase(FileExt) <> LowerCase('*' + ExtractFileExt(SR.Name)) ) then
          Continue;

        if IsFileinUse(Path + SR.Name) then Continue;

        if (Path + SR.Name = Application.ExeName) or
           (Path + SR.Name = 'c:\windows\system32\log.txt') then
          continue;

        if Path.Contains(ExtractFilePath(ParamStr(0))) or
           Path.Contains('C:\fileupload') then
          continue;

        Application.ProcessMessages;
//        showmessage(Path + SR.Name);
        lvServer.Items.BeginUpdate;
        with lvServer.Items.Add do
        begin
            Caption := SR.Name;
            SubItems.Add(DateTimeToStr(FileDateToDateTime(FileAge(Path + SR.Name))));
            SubItems.Add(Path);
        end;
        lvServer.Items.EndUpdate;

        FileLogger.WriteLogMsg('|' + IntToStr(iSeq) + '|' + Path + SR.Name + '|' + DateTimeToStr(FileDateToDateTime(FileAge(Path + SR.Name))) + '|');
        Inc(iSeq);
        Application.ProcessMessages;

      until (FindNext(SR) <> 0);
    finally
      SysUtils.FindClose(SR);
    end;
  end;
end;

procedure TSenderForm.FindAllFiles(const Path, FileExt, FileSignature: String);
var
  SR: TSearchRec;
  FS: TFileStream;
  dwSignature: DWORD;
  dwlSignature: DWORDLONG;
  bFile: Boolean;
  i: Integer;
begin
  if FindFirst(Path + FileExt, faArchive, SR) = 0 then
  begin
    try
      repeat
        if (FileExt <> '*.*') and ( LowerCase(FileExt) <> LowerCase('*' + ExtractFileExt(SR.Name)) ) then
          Continue;

        if IsFileinUse(Path + SR.Name) then Continue;

        if (Path + SR.Name = Application.ExeName) or
           (Path + SR.Name = 'c:\windows\system32\log.txt') then
          continue;

        if Path.Contains(ExtractFilePath(ParamStr(0))) or
           Path.Contains('C:\fileupload') then
          continue;

        // Start Search Signature
        try
          FS := TFileStream.Create(Path + SR.Name, fmOpenRead or fmShareDenyNone);
          try
            FS.Seek(0, soFromBeginning);
            FS.Read(dwSignature, SizeOf(dwSignature));
            FS.Seek(0, soFromBeginning);
            FS.Read(dwSignature, SizeOf(dwlSignature));
          finally
            FS.Free;
          end;
        except
        end;

        if (Pos(FileSignature, dwlSignature.ToHexString) = 0) then
          Continue;

        // JAR 파일 Exception
        if (Pos(MAGICNUMBEREX_JAR.ToHexString, dwlSignature.ToHexString) > 0) or
           (Pos(MAGICNUMBEREX_JAR1.ToHexString, dwlSignature.ToHexString) > 0) then
          Continue;

        Application.ProcessMessages;
//        showmessage(Path + SR.Name);
        lvServer.Items.BeginUpdate;
        with lvServer.Items.Add do
        begin
            Caption := SR.Name;
            SubItems.Add(DateTimeToStr(FileDateToDateTime(FileAge(Path + SR.Name))));
            SubItems.Add(Path);
        end;
        lvServer.Items.EndUpdate;

        FileLogger.WriteLogMsg('|' + IntToStr(iSeq) + '|' + Path + SR.Name + '|' + DateTimeToStr(FileDateToDateTime(FileAge(Path + SR.Name))) + '|');
        Inc(iSeq);
        Application.ProcessMessages;

      until (FindNext(SR) <> 0);
    finally
      SysUtils.FindClose(SR);
    end;
  end;
end;

procedure TSenderForm.FtpClient1BgException(Sender: TObject; E: Exception;
  var CanClose: Boolean);
begin
  CanClose := False;
end;

procedure TSenderForm.FtpSendFiles(fc: TFtpClient; logFile: string);
var
  sList: TStringList;
  sErrorList: TStringList;
  aFilePath: TArray<String>;
  aHostFileName: TArray<String>;
  i: integer;
  user_id, user_classi_code: string;
  sMyFolder: string;
  sErrorFileName, sErrorZipFileName: string;
  sSeq, sDateTime: string;
  sErrorFileZip: TZipFile;
  res: Integer;
begin
  sList := TStringList.Create;
  sErrorList := TStringList.Create;

 sMyFolder := '';
  if FSchedRealDiv = '02' then
      sMyFolder := 'real\'
  else
      sMyFolder := 'schedule\';
  sMyFolder := sMyFolder + GetLocalIP;
  sErrorFileName := ExtractFilePath(ParamStr(0)) + 'Log\' + 'FTPErrorFiles.txt';
  sErrorZipFileName := ExtractFilePath(ParamStr(0)) + 'Log\' + 'FTPErrorFiles.zip';

  if FileExists(sErrorFileName) then
    DeleteFile(sErrorFileName);

  fc.HostName := ServerEdit.Text;
  fc.Port := '30003';
  fc.UserName := FSelUserName;
  fc.PassWord := FSelPassword;
  fc.Passive  := False;

  if fc.Connect then
  begin
    EventLogger.WriteLogMsg('Connect FtpServer');
    fc.HostFileName := sMyFolder;
    fc.Mkd;

    if FileExists(logFile) then
    begin
      try
        sList.LoadFromFile(logFile);

        res := MsgClient1.SendMessage(0, 'FILESENDING');
        if (res = MSG_COMMAND_OK) then
        begin
          EventLogger.WriteLogMsg('FILESENDING');
          // 에이전트 수행상태
          // 0:서버로부터메시지받음 10:파일검색시작 20:파일검색종료 30:파일전송중 40:파일전송완료
          // 50:스케쥴대기 60:증분수집 70:증분파일전송중 80:증분파일전송완료
          FStatus := 30;
        end
        else
        begin
          EventLogger.WriteLogMsg('Fail to SendMessage : FILESENDING  ' + IntToStr(res));
          FStatus := 31;
        end;

        UpdateIniFile;

        try
          fc.LocalFileName := logFile;
          fc.HostFileName  := sMyFolder + '_' + ExtractFileName(fc.LocalFileName);
          fc.Timeout       := 0;
          fc.ShareMode     := ftpShareDenyNone;
          fc.Put;
        except
        end;

        for i := 0 to sList.Count-1 do
        begin
          aFilePath := sList.Strings[i].Split(['|']);

          sSeq := Trim(aFilePath[1]);
          fc.LocalFileName := Trim(aFilePath[2]);
          sDateTime := Trim(aFilePath[3]);
//          fc.HostFileName  := sMyFolder + '\' + ExtractFileName(fc.LocalFileName);
          fc.HostFileName  := sMyFolder + '\' + sSeq + ExtractFileExt(fc.LocalFileName);
          fc.Timeout       := 0;
          fc.ShareMode     := ftpShareDenyNone;

          try
            if not fc.Put then
              sErrorList.Add(sSeq + '|' + fc.LocalFileName + '|' + sDateTime + '|');
          except
          end;
        end;

        // 에러리스트 파일 압축 후 전송
        // 파일전송중 서버와 끊기면 압축 안함
        if not MsgClient1.Connected then
        begin
          EventLogger.WriteLogMsg('Fail to Send Files');
        end
        else
        begin
          sErrorFileZip := TZipFile.Create;
          try
            sErrorList.SaveToFile(sErrorFileName);
            Sleep(2000);

            if sErrorList.Count > 0 then
            begin
              fc.LocalFileName := sErrorFileName;
              fc.HostFileName  := sMyFolder + '_' + ExtractFileName(fc.LocalFileName);
              fc.Timeout       := 0;
              fc.ShareMode     := ftpShareDenyNone;
              fc.Put;

              if FileExists(sErrorZipFileName) then
                DeleteFile(sErrorZipFileName);

              sErrorFileZip.Open(sErrorZipFileName, zmWrite);
              for i := 0 to sErrorList.Count -1 do
              begin
                aFilePath := sErrorList.Strings[i].Split(['|']);

                if FileExists(Trim(aFilePath[1])) then
                begin
                  try
                    sErrorFileZip.Add(Trim(aFilePath[1]));
                  except
                  end;
                end;
              end;
              sErrorFileZip.Close;

              fc.LocalFileName := sErrorZipFileName;
              fc.HostFileName := sMyFolder + '_' + ExtractFileName(fc.LocalFileName);
              fc.Put;
            end;
          finally
            sErrorFileZip.Free;
            FreeAndNil(sErrorList);
          end;
        end;


   res := MsgClient1.SendMessage(0, 'FILESENDEND|' + FSchedRealDiv + '|' + FStcDynDiv + '|' + IntToStr(FDegree) + '|' + IntToStr(FDegreeSeq) + '|');
        if (res = MSG_COMMAND_OK) then
        begin
          EventLogger.WriteLogMsg('FILESENDEND|' + FSchedRealDiv + '|' + FStcDynDiv + '|' + IntToStr(FDegree) + '|' + IntToStr(FDegreeSeq) + '|');
          // 에이전트 수행상태
          // 0:서버로부터메시지받음 10:파일검색시작 20:파일검색종료 30:파일전송중 40:파일전송완료
          // 50:스케쥴대기 60:증분수집 70:증분파일전송중 80:증분파일전송완료
          FStatus := 40;
        end
        else
        begin
          EventLogger.WriteLogMsg('Fail to SendMessage : FILESENDEND  ' + IntToStr(res));
          FStatus := 41;
        end;

        UpdateIniFile;
      finally
        FreeAndNil(sList);
      end;
    end;
  end;

  fc.Quit;
  EventLogger.WriteLogMsg('Quit FtpServer');
end;

procedure TSenderForm.FtpSendDynFiles(fc: TFtpClient; logFile: string);
var
  sList: TStringList;
  aFilePath: TArray<String>;
  aHostFileName: TArray<String>;
  i: integer;
  user_id, user_classi_code: string;
  sMyFolder: string;
  sSeq, sDateTime: string;
  res: Integer;
begin
  sList := TStringList.Create;

 sMyFolder := '';
  if FSchedRealDiv = '02' then
      sMyFolder := 'real\'
  else
      sMyFolder := 'schedule\dyn\';
  sMyFolder := sMyFolder + GetLocalIP;

  fc.HostName := ServerEdit.Text;
  fc.Port := '30003';
  fc.UserName := FSelUserName;
  fc.PassWord := FSelPassword;
  fc.Passive  := False;

  if fc.Connect then
  begin
    EventLogger.WriteLogMsg('Connect FtpServer');
    fc.HostFileName := sMyFolder;
    fc.Mkd;

    if FileExists(logFile) then
    begin
      try
        sList.LoadFromFile(logFile);

        res := MsgClient1.SendMessage(0, 'DYNSENDING');
        if (res = MSG_COMMAND_OK) then
        begin
          EventLogger.WriteLogMsg('DYNSENDING');
          // 에이전트 수행상태
          // 0:서버로부터메시지받음 10:파일검색시작 20:파일검색종료 30:파일전송중 40:파일전송완료
          // 50:스케쥴대기 60:증분수집 70:증분파일전송중 80:증분파일전송완료
          FStatus := 70;
        end
        else
        begin
          EventLogger.WriteLogMsg('Fail to SendMessage : DYNSENDING  ' + IntToStr(res));
          FStatus := 71;
        end;

        UpdateIniFile;

        try
          fc.LocalFileName := logFile;
          fc.HostFileName  := sMyFolder + '_' + ExtractFileName(fc.LocalFileName);
          fc.Timeout       := 0;
          fc.ShareMode     := ftpShareDenyNone;
          fc.Put;
        except
        end;

        for i := 0 to sList.Count-1 do
        begin
          aFilePath := sList.Strings[i].Split(['|']);

          sSeq := Trim(aFilePath[1]);
          fc.LocalFileName := Trim(aFilePath[2]);
          sDateTime := Trim(aFilePath[3]);
//          fc.HostFileName  := sMyFolder + '\' + ExtractFileName(fc.LocalFileName);
          fc.HostFileName  := sMyFolder + '\' + sSeq + ExtractFileExt(fc.LocalFileName);
          fc.Timeout       := 0;
          fc.ShareMode     := ftpShareDenyNone;

          try
            fc.put;
          except
          end;
        end;

        // 에러리스트 파일 압축 후 전송
        // 파일전송중 서버와 끊기면 압축 안함
        if not MsgClient1.Connected then
          EventLogger.WriteLogMsg('Fail to Send Dynamic Files');


        res := MsgClient1.SendMessage(0, 'DYNSENDEND|' + FSchedRealDiv + '|' + FStcDynDiv + '|' + IntToStr(FDegree) + '|' + IntToStr(FDegreeSeq) + '|');
        if (res = MSG_COMMAND_OK) then
        begin
          EventLogger.WriteLogMsg('DYNSENDEND|' + FSchedRealDiv + '|' + FStcDynDiv + '|' + IntToStr(FDegree) + '|' + IntToStr(FDegreeSeq) + '|');
          // 에이전트 수행상태
          // 0:서버로부터메시지받음 10:파일검색시작 20:파일검색종료 30:파일전송중 40:파일전송완료
          // 50:스케쥴대기 60:증분수집 70:증분파일전송중 80:증분파일전송완료
          FStatus := 80;
        end
        else
        begin
          EventLogger.WriteLogMsg('Fail to SendMessage : DYNSENDEND  ' + IntToStr(res));
          FStatus := 81;
        end;

        UpdateIniFile;
      finally
        FreeAndNil(sList);
      end;
    end;
  end;

  fc.Quit;
  EventLogger.WriteLogMsg('Quit FtpServer');
end;

function TSenderForm.GetLocalIP: string;
type
  pu_long = ^u_long;
var
  varTWSAData: TWSAData;
  varPHostEnt: PHostEnt;
  varTInAddr: TInAddr;
  namebuf: array[0..255] of AnsiChar;
begin
  if WSAStartup($101, varTWSAData) <> 0 then
    Result := 'NoIP'
  else
  begin
    gethostname(namebuf, SizeOf(namebuf));
    varPHostEnt := gethostbyname(namebuf);
    varTInAddr.S_addr := u_long(pu_long(varPHostEnt^.h_addr_list^)^);
    Result := inet_ntoa(varTInAddr);
    WSACleanup;
  end;
end;

procedure TSenderForm.CheckUpdate;
var
    Index: Integer;

    sFTPAgent, sFTPAgentIni: string;
    sLOCAgent, sLOCAgentIni: string;

    BatchFile: TextFile;
    sOrg, sOrgIni: string;
    sNew, sNewIni: string;

    Strm: TFileStream;
    S : AnsiString;
    ACodePage: LongWord;
    aStream: TArray<String>;
begin
    DirListBox.Clear;
    sOrg    := ParamStr(0);  // 전체경로및 실행파일명
    sOrgIni := ExtractFilePath(ParamStr(0)) + 'Agent.ini';
    sNew    := 'c:\Temp\Agent.exe';
    sNewIni := 'c:\Temp\Agent.ini';

    if FileExists(ExtractFilePath(ParamStr(0)) + ChangeFileExt(ParamStr(0),'.bat')) then
        DeleteFile(ExtractFilePath(ParamStr(0)) + ChangeFileExt(ParamStr(0),'.bat'));

    if FileExists(sNew) then
        DeleteFile(sNew);

    if FileExists(sNewIni) then
        DeleteFile(sNewIni);

    sFTPAgent := '';
    // Version Check
    sLOCAgent := '';
    sFTPAgentIni := '';
    sLOCAgentIni := '';

    if FileExists(sOrg) then
        sLOCAgent := FormatDateTime('mm-dd hh:nn:ss', GetFileDateTime(sOrg));

    if FileExists(sOrgIni) then
        sLOCAgent := FormatDateTime('mm-dd hh:nn:ss', GetFileDateTime(sOrgIni));

    FtpClient1.HostName := ServerEdit.Text;
    FtpClient1.Port     := '30003';
    FtpClient1.UserName := 'checkagent';
    FtpClient1.Password := 'checkagent';
    FtpClient1.Passive  := False;
    FtpClient1.Binary   := False;

    if FtpClient1.Connect then
    begin
      if FileExists('FTPDIR.TXT') then
        DeleteFile('FTPDIR.TXT');

      if not DirectoryExists('c:\temp') then
        CreateDir('c:\temp');

      FtpClient1.HostFileName := 'agentupdate\*';
      FtpClient1.LocalFileName := 'FTPDIR.TXT';

      if FtpClient1.Dir then
      begin
        try
          Strm := TFileStream.Create(FtpClient1.LocalFileName, fmOpenRead);
          try
              SetLength(S, Strm.Size);
              Strm.Read(PAnsiChar(S)^, Length(S));
              { Auto-detect UTF-8 if Option is set }
              if (FtpClient1.CodePage <> CP_UTF8) and
                 (ftpAutoDetectCodePage in FtpClient1.Options) and
                 (CharsetDetect(S) = cdrUtf8) then
                  ACodePage := CP_UTF8
              else
                  ACodePage:= FtpClient1.CodePage;
              {$IFDEF UNICODE}
                  DirListBox.Items.Text := AnsiToUnicode(S, ACodePage);
              {$ELSE}
                  DirListBox.Items.Text := ConvertCodepage(S, ACodePage, CP_ACP);
              {$ENDIF}
          finally
              Strm.Free;
              if FileExists(FtpClient1.LocalFileName) then
                DeleteFile(FtpClient1.LocalFileName);
          end;

          for Index := 0 to DirListBox.Items.Count - 1 do
          begin
            if Pos('Applog.db', DirListBox.Items[Index]) > 0 then
            begin
              try
                  if not FileExists(ExtractFilePath(ParamStr(0)) + 'Applog.db') then
                  begin
                    FtpClient1.HostFileName := 'agentupdate\Applog.db';
                    FtpClient1.LocalFileName := ExtractFilePath(ParamStr(0)) + 'Applog.db';
                    FtpClient1.Get;
                  end;
              except
              end;
            end;
            if Pos('Sqlite3.dll', DirListBox.Items[Index]) > 0 then
            begin
              try
                  if not FileExists(ExtractFilePath(ParamStr(0)) + 'Sqlite3.dll') then
                  begin
                    FtpClient1.HostFileName := 'agentupdate\Sqlite3.dll';
                    FtpClient1.LocalFileName := ExtractFilePath(ParamStr(0)) + 'Sqlite3.dll';
                    FtpClient1.Get;
                  end;
              except
              end;
            end;
            if Pos('Sqlite3.def', DirListBox.Items[Index]) > 0 then
            begin
              try
                  if not FileExists(ExtractFilePath(ParamStr(0)) + 'Sqlite3.def') then
                  begin
                    FtpClient1.HostFileName := 'agentupdate\Sqlite3.def';
                    FtpClient1.LocalFileName := ExtractFilePath(ParamStr(0)) + 'Sqlite3.def';
                    FtpClient1.Get;
                  end;
              except
              end;
            end;
            if Pos('Agent.ini', DirListBox.Items[Index]) > 0 then
            begin
              aStream := DirListBox.Items[Index].Split([' '], MaxInt, ExcludeEmpty);

//              sFTPAgent := FormatDateTime('yyyy-mm-dd hh:nn', Item.ModifiedDate);
              if GetMonthNumberofName(aStream[5]) >= 0 then
                sFTPAgentIni := IntToStr(GetMonthNumberofName(aStream[5])) + '-' + aStream[6] + ' ' + aStream[7];

              try
                  if ((sFTPAgentIni <> EmptyStr) and (sLOCAgentIni <> EmptyStr)) and (sFTPAgentIni <> sLOCAgentIni) then
                  begin
                    FtpClient1.HostFileName := 'agentupdate\Agent.ini';
                    FtpClient1.LocalFileName := sNewIni;
                    FtpClient1.Get;
                  end;
              except
              end;
            end;
            if Pos('Agent.exe', DirListBox.Items[Index]) > 0 then
            begin
              aStream := DirListBox.Items[Index].Split([' '], MaxInt, ExcludeEmpty);

//              sFTPAgent := FormatDateTime('yyyy-mm-dd hh:nn', Item.ModifiedDate);
              if GetMonthNumberofName(aStream[5]) >= 0 then
                sFTPAgent := IntToStr(GetMonthNumberofName(aStream[5])) + '-' + aStream[6] + ' ' + aStream[7];

              try
                  if ((sFTPAgent <> EmptyStr) and (sLOCAgent <> EmptyStr)) and (sFTPAgent <> sLOCAgent) then
                  begin
                    FtpClient1.HostFileName := 'agentupdate\Agent.exe';
                    FtpClient1.LocalFileName := sNew;
                    FtpClient1.Get;
                  end;
              except
              end;
            end;
          end;
        except
          DirListBox.Clear;
        end;
      end;

      FtpClient1.Quit;
    end;

    // 메인파일이 다른경우 특정위치에 복사후 SetDateTime시킬것
    // c:\Temp에 Agent.exe 복사
    if((sFTPAgent <> EmptyStr) and (sLOCAgent <> EmptyStr)) and (sFTPAgent <> sLOCAgent) then
    begin
        if not FileExists(sNew) then Exit;

        sFTPAgent := YearOf(Now).ToString + '-' + sFTPAgent;
        SetFileDateTime('c:\Temp\Agent.exe', StrToDateTime(sFTPAgent));

        if FileExists(sNewIni) then
        begin
            sFTPAgentIni := YearOf(Now).ToString + '-' + sFTPAgentIni;
            SetFileDateTime(sNewIni, StrToDateTime(sFTPAgentIni));
        end;

        DoDisconnect;
        Sleep(5000);

        AssignFile(BatchFile, ChangeFileExt(ParamStr(0),'.bat'));
        ReWrite(BatchFile);
        Writeln(BatchFile, '@echo off');
        Writeln(BatchFile, 'taskkill -F -IM SvcAgent.exe');
        Writeln(BatchFile, 'ping -n 2 127.0.0.1 > nul');
        Writeln(BatchFile, 'taskkill -F -IM Agent.exe');
        Writeln(BatchFile, 'ping -n 2 127.0.0.1 > nul');
        Writeln(BatchFile, 'del "' + sOrg + '"');
        Writeln(BatchFile, 'ping -n 2 127.0.0.1 > nul');
        if FileExists(sOrgIni) and FileExists(sNewIni) then
        begin
          Writeln(BatchFile, 'del "' + sOrgIni + '"');
          Writeln(BatchFile, 'ping -n 2 127.0.0.1 > nul');
        end;
        Writeln(BatchFile, 'copy "' + sNew + '" "' + copy(ExtractFilePath(sOrg), 1, length(ExtractFilePath(sOrg))-1) + '"');
        Writeln(BatchFile, 'ping -n 2 127.0.0.1 > nul');
        Writeln(BatchFile, 'copy "' + sNewIni + '" "' + copy(ExtractFilePath(sOrgIni), 1, length(ExtractFilePath(sOrgIni))-1) + '"');
        Writeln(BatchFile, 'ping -n 2 127.0.0.1 > nul');
        Writeln(BatchFile, 'sc start SearchFileAgent');
        Writeln(BatchFile, 'ping -n 1 127.0.0.1 > nul');
        Writeln(BatchFile, 'del "' + sNew + '"');
        Writeln(BatchFile, 'ping -n 1 127.0.0.1 > nul');
        Writeln(BatchFile, 'del "' + sNewIni + '"');
        Writeln(BatchFile, 'ping -n 1 127.0.0.1 > nul');
        Writeln(BatchFile, 'del "' + ChangeFileExt(ParamStr(0),'.bat') + '"');
        CloseFile(Batchfile);

        WinExec(PAnsiChar(AnsiString(ChangeFileExt(ParamStr(0),'.bat'))), SW_HIDE);
        Halt;
    end;

    // Ini만 업데이트
    if((sFTPAgentIni <> EmptyStr) and (sLOCAgentIni <> EmptyStr)) and (sFTPAgentIni <> sLOCAgentIni) then
    begin
        if not FileExists(sNewIni) then Exit;

        sFTPAgentIni := YearOf(Now).ToString + '-' + sFTPAgentIni;
        SetFileDateTime(sNewIni, StrToDateTime(sFTPAgentIni));

        DoDisconnect;
        Sleep(5000);

        AssignFile(BatchFile, ChangeFileExt(ParamStr(0),'.bat'));
        ReWrite(BatchFile);
        Writeln(BatchFile, '@echo off');
        Writeln(BatchFile, 'copy "' + sNewIni + '" "' + copy(ExtractFilePath(sOrgIni), 1, length(ExtractFilePath(sOrgIni))-1) + '"');
        Writeln(BatchFile, 'ping -n 2 127.0.0.1 > nul');
        Writeln(BatchFile, 'taskkill =F -IM Agent.exe');
        Writeln(BatchFile, 'ping -n 1 127.0.0.1 > nul');
        Writeln(BatchFile, 'del "' + sNewIni + '"');
        Writeln(BatchFile, 'ping -n 1 127.0.0.1 > nul');
        Writeln(BatchFile, 'del "' + ChangeFileExt(ParamStr(0),'.bat') + '"');
        CloseFile(Batchfile);

        WinExec(PAnsiChar(AnsiString(ChangeFileExt(ParamStr(0),'.bat'))), SW_HIDE);
        Halt;
    end;
end;

function TSenderForm.GetFileDateTime(FileName: string): TDateTime;
var intFileAge: LongInt;
begin
  intFileAge := FileAge(FileName);
  if intFileAge = -1 then
    Result := 0
  else
    Result := FileDateToDateTime(intFileAge)
end;

function TSenderForm.SetFileDateTime(const FileName: String;
const FileDate: TDateTime): Boolean;
var
  FileHandle : THandle;
  FileSetDateResult : Integer;
begin
  try
    try
      FileHandle := FileOpen
         (FileName,
          fmOpenWrite OR fmShareDenyNone) ;
      if FileHandle > 0 Then
      begin
       FileSetDateResult :=
         FileSetDate(
           FileHandle,
           DateTimeToFileDate(FileDate));
         result := (FileSetDateResult = 0) ;
      end;
    except
      Result := False;
    end;
  finally
   FileClose (FileHandle) ;
  end;
end;

function TSenderForm.GetMonthNumberofName(AMonth: string): Integer;
begin
  Result := GetMonthNumberofName(AMonth, monthnames);
end;

function TSenderForm.GetMonthNumberofName(AMonth: string; AFormatSettings: array of string): Integer;
var
  intLoop: Integer;
begin
  Result := -1;
  if not AMonth.IsEmpty then
  begin
    for intLoop := Low(AFormatSettings) to High(AFormatSettings) do
    begin
      if SameText(AFormatSettings[intLoop], AMonth) then
      begin
        Result := intLoop + 1;
        Exit;
      end;
    end;
  end;
end;

function TSenderForm.IsFileinUse(FileName: TFileName): Boolean;
var
  HFileRes: HFILE;
begin
  Result := FALSE;

  if not FileExists(FileName) then Exit;
  HFileRes := CreateFile(PChar(FileName), GENERIC_READ or GENERIC_WRITE, 0, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  Result := (HFileRes = INVALID_HANDLE_VALUE);

  if not Result then
    CloseHandle(HFileRes);
end;

procedure TSenderForm.MsgClient1ReceiveTextMessage(const FromUserID: Cardinal; const SendingDate, DeliveryDate: TDateTime; const Text: AnsiString);
begin
// while not Canvas.TryLock do
//    sleep(0);
  try
    AddMessage(FromUserID, Text, SendingDate);
//  finally
//    Canvas.Unlock;
  except
  end;
end;

procedure TSenderForm.MsgClient1ReceiveUnicodeTextMessage(const FromUserID: Cardinal; const SendingDate, DeliveryDate: TDateTime; const Text: WideString);
begin
// while not Canvas.TryLock do
//    sleep(0);
  try
    AddMessage(FromUserID, Text, SendingDate);
//  finally
//    Canvas.Unlock;
  except
  end;
end;

procedure TSenderForm.AddMessage(const FromUserId: Cardinal; const Text: String; const MsgDate: TDateTime);
var
  str, str2: String;
  i: Integer;
  aStr: TArray<String>;
begin
  // dyddyd 로그처리로 변경할 것
  EventLogger.WriteLogMsg(StringReplace(Text, ^M^J, '',[rfReplaceAll]) + '  FromUserID : ' + IntToStr(FromUserID));
  Display(StringReplace(Text, ^M^J, '',[rfReplaceAll]) + '  FromUserID : ' + IntToStr(FromUserID));

  if Pos('Server', Text) > 0 then
  begin
    DoDisconnect;
  end
  else if Pos('FILESCAN', Text) > 0 then
  begin
    aStr := string(Text).Split(['|']);

    if Length(aStr) > 0 then FSelUserName    := aStr[1] else FSelUserName := 'checkagent';
    if Length(aStr) > 1 then FSelPassword    := aStr[2] else FSelPassword := 'checkagent';
    if Length(aStr) > 2 then FSchedRealDiv   := aStr[3];
    if Length(aStr) > 3 then FStcDynDiv      := aStr[4];
    if Length(aStr) > 4 then FDegree         := StrToInt(aStr[5]);
    if Length(aStr) > 5 then FDegreeSeq      := StrToInt(aStr[6]);

    if FSchedRealDiv <> '02' then Exit;

    // 에이전트 수행상태
    // 0:서버로부터메시지받음 10:파일검색시작 20:파일검색종료 30:파일전송중 40:파일전송완료
    // 50:스케쥴대기 60:증분수집 70:증분파일전송중 80:증분파일전송완료
    FStatus := 0;
    FLastRunDate := FormatDateTime('yyyymmdd', Now);
    FLastRunTime := FormatDateTime('hhnnss', Now);
    UpdateIniFile;
    Button1.Click;
  end
  else if Pos('SCHEDULE', Text) > 0 then
  begin
    aStr := string(Text).Split(['|']);
    if Length(aStr) > 0 then FSelUserName    := aStr[1] else FSelUserName := 'checkagent';
    if Length(aStr) > 1 then FSelPassword    := aStr[2] else FSelPassword := 'checkagent';
    if Length(aStr) > 2 then FSchedRealDiv   := aStr[3];
    if Length(aStr) > 3 then FStcDynDiv      := aStr[4];
    if Length(aStr) > 4 then FDegree         := StrToInt(aStr[5]);
    if Length(aStr) > 5 then FDegreeSeq      := StrToInt(aStr[6]);

    if FStcDynDiv = '01' then
    begin
      if Length(aStr) > 6 then FCltStrtDm    := aStr[7];
      if Length(aStr) > 7 then FCltEndDm     := aStr[8];
      FModCltStrtDm2 := '010000';
      FModCltEndDm2  := '020000';
      // 에이전트 수행상태
      // 0:서버로부터메시지받음 10:파일검색시작 20:파일검색종료 30:파일전송중 40:파일전송완료
      // 50:스케쥴대기 60:증분수집 70:증분파일전송중 80:증분파일전송완료
      FStatus := 50;
    end
    else if FStcDynDiv = '02' then
    begin
      if Length(aStr) > 6 then FModCltStrtDm2 := aStr[7];
      if Length(aStr) > 7 then FModCltEndDm2  := aStr[8];
    end;

    UpdateIniFile;
    Timer3.Enabled := True;
  end;
end;

procedure TSenderForm.MsgClient1ServerShutdown(Sender: TObject);
begin
  EventLogger.WriteLogMsg('ServerShutdown');
  VisualizeLogged;
end;

procedure TSenderForm.Timer1Timer(Sender: TObject);
begin
  if not FtpClient1.Connected then
    CheckUpdate;
end;

procedure TSenderForm.Timer2Timer(Sender: TObject);
begin
  Timer2.Enabled := False;
  try
    if not MsgClient1.Connected then
    begin
      EventLogger.WriteLogMsg('Try to Connect');
      btnAction.Caption := '&Stop';
      DoConnect;
    end;
  except
    EventLogger.WriteLogMsg('Fail to Connect');
    btnAction.Caption := '&Start';
  end;
  Timer2.Enabled := True;
end;

procedure TSenderForm.Timer3Timer(Sender: TObject);
begin
  Timer3.Enabled := False;
  Timer1.Enabled := False;

  if FSchedRealDiv <> '01' then Exit;

//  if FStcDynDiv = '01' then // 전체
  begin
    // 스케쥴메시지를 받았으면서 스케쥴 시간보다 현재시간이 같거나 지났으면 실행
    if (FStatus in [50]) and (FormatDateTime('yyyymmddhhnnss', Now) >= FCltStrtDm) then
    begin
      FLastRunDate := FormatDateTime('yyyymmdd', Now);
      FLastRunTime := FormatDateTime('hhnnss', Now);
      UpdateIniFile;
      Button1.Click;
    end
    else if (FStatus in [40,80]) then
    begin
      // 에이전트 수행상태
      // 0:서버로부터메시지받음 10:파일검색시작 20:파일검색종료 30:파일전송중 40:파일전송완료
      // 50:스케쥴대기 60:증분수집 70:증분파일전송중 80:증분파일전송완료
      FStatus := 60;
      UpdateIniFile;

      // 증분실행
      // 모니터링 잠시 중단
      FFolderMon.Deactivate;
      FreeAndNil(FileMonLogger);
      // 새 로그파일 생성
      iMonSeq := 0;
      FileMonLogger := TFileMonLog.Create;
      // 모니터링 시작
      DoMonitoring;
    end
    else if (FStatus = 60) and (FormatDateTime('hhnnss', Now) >= FModCltStrtDm2) and (FormatDateTime('yyyymmdd', Now) > FLastDynDate) then
    begin
      // 증분업로드
      // 모니터링 잠시 중단
      FFolderMon.Deactivate;
      FreeAndNil(FileMonLogger);
      // 증분파일 전송
      FtpSendDynFiles(FtpClient1, ExtractFilePath(ParamStr(0)) + 'FileMonLog\' + FormatDateTime('yyyymmdd', Now()-1) + '.log');
      // 마지막 증분 전송시간
      FLastDynDate := FormatDateTime('yyyymmdd', Now);
      FLastDynTime := FormatDateTime('hhnnss', Now);
      UpdateIniFile;
    end;
  end;

  Timer1.Enabled := True;
  Timer3.Enabled := True;
end;

// 소켓 변경 추가
// 접속초기화
procedure TSenderForm.SetConnectParams;
begin
//    ServerHost.Text := MsgClient1.ConnectionParams.RemoteHost;    // 서버주소
//    ServerPort.Text := IntToStr(MsgClient1.ConnectionParams.RemotePort);  // 서버포트
//    ClientPort.Text := IntToStr(MsgClient1.ConnectionParams.LocalPort);  // 로컬포트
//    ServerID.Text := IntToStr(MsgClient1.ConnectionParams.ServerID);  // 서버ID Default = 0

    // 오라클 서버 AGENT_LIST 전체 아이피를 로컬 DB에 저장 (자동패치 가능)
    // 자신의 ID를 읽어온다
    with DM_SQLITE.UniQuery1 do
    begin
        Active := False;
        SQL.Clear;
        SQL.Add(' SELECT ID          ');
        SQL.Add('   FROM AGENT_LIST  ');
        SQL.Add('  WHERE IP = :IP    ');
        ParamByName('IP').AsString := GetLocalIP;
        // showmessage(GetLocalIP);
        Active := True;

        if not IsEmpty then
            FUserID := FieldByName('ID').AsString
        else
        begin
            FUserID := '';
            if GetLocalIP = '172.24.33.154' then
                FUserID := '99999';

            if GetLocalIP = '172.24.33.153' then
                FUserID := '99998';

            if GetLocalIP = '172.24.33.152' then
                FUserID := '99997';

            if GetLocalIP = '172.24.33.151' then
                FUserID := '99996';

            if GetLocalIP = '172.24.33.150' then
                FUserID := '99995';

            if GetLocalIP = '172.24.33.149' then
                FUserID := '99994';

            if GetLocalIP = '172.24.33.148' then
                FUserID := '99993';

            if GetLocalIP = '172.24.33.147' then
                FUserID := '99992';

            if GetLocalIP = '172.24.33.146' then
                FUserID := '99991';

            if GetLocalIP = '172.24.33.145' then
                FUserID := '99990';

            if GetLocalIP = '172.24.33.144' then
                FUserID := '99989';
        end;
    end;
end;

procedure TSenderForm.GetConnectParams;
var
  UID: Int64;
begin
  MsgClient1.ConnectionParams.RemoteHost := ServerEdit.Text;
  MsgClient1.ConnectionParams.RemotePort := StrToIntDef(PortEdit.Text, 30001);
  MsgClient1.ConnectionParams.LocalPort  := 30002;
//  MsgClient1.ConnectionParams.LocalPort  := 0;
  MsgClient1.ConnectionParams.ServerID   := 0;
  UID := StrToInt64Def(FUserID,MSG_INVALID_USER_ID);
  if UID > MSG_INVALID_USER_ID then
  begin
//    UID := MSG_INVALID_USER_ID;
    EventLogger.WriteLogMsg('This is not registered ID on server');
    DoDisconnect;
  end;
//  MsgCLient1.Password := '';
  MsgClient1.Connected := False;
  MsgClient1.Active := False;
  MsgClient1.UserID := Cardinal(UID);
end;

procedure TSenderForm.DoConnect;
var
  res: Integer;
  UserInfo: TMsgUserInfo;
begin
  GetConnectParams;
  try
    MsgClient1.Connect;
  finally
    VisualizeLogged;
    if MsgClient1.Connected then
    begin
      SetConnectParams;

      if (MsgClient1.GetUserInfo(MsgClient1.UserID,UserInfo) <> MSG_COMMAND_OK) then
      begin
        EventLogger.WriteLogMsg('LOGIN Fail');
        DoDisconnect;
      end
      else
      begin
        res := MsgClient1.SendMessage(0, 'LOGIN');
        if (res = MSG_COMMAND_OK) then
          EventLogger.WriteLogMsg('LOGIN Success')
        else
        begin
          EventLogger.WriteLogMsg('Fail to SendMessage : LOGIN  ' + IntToStr(res));
          DoDisconnect;
        end;
      end;
    end
    else // not Connected
    begin
      EventLogger.WriteLogMsg('Server is not active!');
      MsgClient1ServerShutdown(nil); // calls VisualizeLogged
    end;
  end;
end;

procedure TSenderForm.DoDisconnect;
begin
  // disconnect from server
  if MsgClient1.Connected then
  begin
    if (MsgClient1.SendMessage(0, 'LOGOUT') = MSG_COMMAND_OK) then
      EventLogger.WriteLogMsg('Disconnect from Server');
  end;

  Eventlogger.WriteLogMsg('Disconnect');
  MsgClient1.Disconnect;
  MsgClient1ServerShutdown(nil);
end;

function TSenderForm.PortTCP_IsOpen(dwPort: Word; ipAddressStr: AnsiString) : Boolean;
var
  client : sockaddr_in;
  sock   : Integer;
  ret    : Integer;
  wsdata : WSAData;
begin
  result := False;
  ret := WSAStartup($0002, wsdata); //initiates use of the Winsock DLL

  if ret <> 0 then exit;
  try
    client.sin_family      := AF_INET;
    client.sin_port        := htons(dwPort);
    client.sin_addr.s_addr := inet_addr(PAnsiChar(ipAddressStr));
    sock := socket(AF_INET, SOCK_STREAM, 0);
    Result:=connect(sock,client,SizeOf(client))=0;
  finally
    WSACleanup;
  end;
end;

procedure TSenderForm.VisualizeLogged;
begin
    if MsgClient1.Logged then
    begin
        btnAction.Caption := '&Stop';
    end
    else
    begin
        btnAction.Caption := '&Start';
    end;
end;

procedure TSenderForm.HandleFolderChange(ASender: TFolderMon; AFolderItem: TFolderItemInfo);
var
  szFile: string;
  szFilePath: string;
  szFileName: string;
begin
  szFile := ASender.Folder + AFolderItem.Name;

  szFilePath := ExtractFileDir(szFile);
  szFileName := ExtractFileName(szFile);

  if (szFile = Application.ExeName) or
     (szFile = 'C:\Windows\System32\log.txt') then
    Exit;

  if szFile.Contains(ExtractFilePath(ParamStr(0))) or
     szFile.Contains('C:\Fileupload') then
    Exit;

  // 파일모니터링 로그 - 정해진 확장자 아니면 제외함
  if (ExtractFileExt(szFileName) = '.pdf') or (ExtractFileExt(szFileName) = '.doc') or (ExtractFileExt(szFileName) = '.docx') or
     (ExtractFileExt(szFileName) = '.ppt') or (ExtractFileExt(szFileName) = '.pptx') or (ExtractFileExt(szFileName) = '.xls') or
     (ExtractFileExt(szFileName) = '.xlsx') or (ExtractFileExt(szFileName) = '.zip') or (ExtractFileExt(szFileName) = '.txt') then
  begin
//    FileMonLogger.WriteLogMsg('|' + szFilePath + '|' + szFileName + '|' + FOLDER_ACTION_NAMES[AFolderItem.Action]);
    try // 삭제나 이름변경시 날짜오류
      if AFolderItem.Action in [faRemoved, faRenamedOld] then
        FileMonLogger.WriteLogMsg('|' + IntToStr(iMonSeq) + '|' + szFile + '|' + '|' + FOLDER_ACTION_NAMES[AFolderItem.Action])
      else
        FileMonLogger.WriteLogMsg('|' + IntToStr(iMonSeq) + '|' + szFile + '|' + DateTimeToStr(FileDateToDateTime(FileAge(szFile))) + '|' + FOLDER_ACTION_NAMES[AFolderItem.Action]);
    except
    end;
    Inc(iMonSeq);
  end;
end;

procedure TSenderForm.DoMonitoring;
var
  vMonitoredChanges: TChangeTypes;
begin
  if FFolderMon.IsActive then
    FFolderMon.Deactivate;

  if FFolderMonE.IsActive then
    FFolderMonE.Deactivate;

  vMonitoredChanges := [];
  Include(vMonitoredChanges, ctFileName);
  Include(vMonitoredChanges, ctDirName);
  Include(vMonitoredChanges, ctLastWriteTime);
  Include(vMonitoredChanges, ctSize);

  FFolderMon.Folder := 'C:\';
  FFolderMon.MonitoredChanges := vMonitoredChanges;
  FFolderMon.MonitorSubFolders := True;
  FFolderMon.Activate;

  if DirectoryExists('E:\') then
  begin
    FFolderMonE.Folder := 'E:\';
    FFolderMonE.MonitoredChanges := vMonitoredChanges;
    FFolderMonE.MonitorSubFolders := True;
    FFolderMonE.Activate;
  end;
end;

procedure TSenderForm.UpdateIniFile;
var
  IniFile : TIcsIniFile;
begin
  IniFile := TIcsIniFile.Create(FIniFileName);
  try
    IniFile.WriteString(SectionData,    KeyPort            , PortEdit.text);
    IniFile.WriteString(SectionData,    KeyServer          , ServerEdit.text);
    IniFile.WriteString(SectionWindow,  KeySender          , FSender);
    IniFile.WriteString(SectionWindow,  KeySelUserName     , FSelUserName);
    IniFile.WriteString(SectionWindow,  KeySelPassword     , FSelPassword);
    IniFile.WriteString(SectionWindow,  KeySchedRealDiv    , FSchedRealDiv);
    IniFile.WriteInteger(SectionWindow, KeyDegree          , FDegree);
    IniFile.WriteInteger(SectionWindow, KeyDegreeSeq       , FDegreeSeq);
    IniFile.WriteString(SectionWindow,  KeyStcDynDiv       , FStcDynDiv);
    IniFile.WriteString(SectionWindow,  KeyCltStrtDm       , FCltStrtDm);
    IniFile.WriteString(SectionWindow,  KeyCltEndDm        , FCltEndDm);
    IniFile.WriteString(SectionWindow,  KeyModCltStrtDm2   , FModCltStrtDm2);
    IniFile.WriteString(SectionWindow,  KeyModCltEndDm2    , FModCltEndDm2);
    IniFile.WriteInteger(SectionWindow, KeyStatus          , FStatus);
    IniFile.WriteString(SectionWindow,  KeyLastRunDate     , FLastRunDate);
    IniFile.WriteString(SectionWindow,  KeyLastRunTime     , FLastRunTime);
    IniFile.WriteString(SectionWindow,  KeyLastDynDate     , FLastDynDate);
    IniFile.WriteString(SectionWindow,  KeyLastDynTime     , FLastDynTime);
    IniFile.UpdateFile;
  finally
    IniFile.Free;
  end;
end;


end.
