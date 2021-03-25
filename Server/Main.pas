unit Main;

interface


{$I ver.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DB, ExtCtrls, Grids, ComCtrls,
  MsgServer, MsgComBase, MsgConst, MsgTypes, OverbyteIcsWSocket,
  OverbyteIcsWndControl, OverbyteIcsFtpSrv, OverbyteIcsOneTimePw,
  MemDS, DBAccess, Uni, OverbyteIcsLogger;

const
  Guest = ' - GUEST -';
  WM_DESTROY_SOCKET = WM_USER + 1;
  FOLDER_TEST   = 'c:\fileupload';
  FOLDER_RUN    = 'E:\download';
  IS_TEST       = False;
  IP_LOCAL      = '172.24.33.151';
  IP_DEV        = '10.210.5.217';
  IP_CARD       = '10.222.21.31';
  IP_CAPITAL    = '10.210.8.217';
  IP_COMERCIAL  = '10.209.6.217';

type
  TRecvForm = class(TForm)
    Pages: TPageControl;
    Control: TTabSheet;
    Send: TTabSheet;
    Incoming: TTabSheet;
    ServerStart: TButton;
    ServerStop: TButton;
    Label1: TLabel;
    MsgServer1: TMsgServer;
    Label10: TLabel;
    sgConnectedUsers: TStringGrid;
    ServerSend: TButton;
    ServerToID: TEdit;
    ServerMsg: TRichEdit;
    Label2: TLabel;
    Label3: TLabel;
    ServerIncoming: TRichEdit;
    Sent: TTabSheet;
    Label4: TLabel;
    ServerSent: TRichEdit;
    Users: TTabSheet;
    sgAllUsers: TStringGrid;
    Label5: TLabel;
    SelectedUserID: TEdit;
    DeleteUser: TButton;
    DisconnectUser: TButton;
    Label6: TLabel;
    LocalPort: TEdit;
    Timer1: TTimer;
    GroupBox1: TGroupBox;
    cbOnTimer: TCheckBox;
    cbConnected: TCheckBox;
    UserCount: TLabel;
    OnLineCount: TLabel;
    GuestCount: TLabel;
    cbLogged: TCheckBox;
    cbRegistration: TCheckBox;
    cbInfoChanged: TCheckBox;
    Interval: TEdit;
    Label7: TLabel;
    ServerSettings: TRichEdit;
    Label8: TLabel;
    Label9: TLabel;
    LocalHost: TEdit;
    ServerID: TEdit;
    Label11: TLabel;
    uqryVDI: TUniQuery;
    FtpServer1: TFtpServer;
    WSocket1: TWSocket;
    Button1: TButton;
    Button2: TButton;
    IcsLogger1: TIcsLogger;
    procedure FormCreate(Sender: TObject);
    procedure ServerStartClick(Sender: TObject);
    procedure ServerStopClick(Sender: TObject);
    procedure MsgServer1ReceiveTextMessage(const FromUserID: Cardinal; const SendingDate,DeliveryDate: TDateTime; const Text: AnsiString);
    procedure MsgServer1ReceiveUnicodeTextMessage(const FromUserID: Cardinal; const SendingDate, DeliveryDate: TDateTime; const Text: WideString);
    procedure ServerSendClick(Sender: TObject);
    procedure MsgServer1AfterConnect(Sender: TObject);
    procedure sgConnectedUsersSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure MsgServer1BeforeDisconnect(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure sgAllUsersSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure DisconnectUserClick(Sender: TObject);
    procedure DeleteUserClick(Sender: TObject);
    procedure FillGrids;
    procedure FillCounts;
    procedure ClearGrid(Grid: TStringGrid);
    procedure Timer1Timer(Sender: TObject);
    procedure MsgServer1AfterServerStart(Sender: TObject);
    procedure MsgServer1BeforeServerStop(Sender: TObject);
    procedure MsgServer1AfterDisconnect(Sender: TObject);
    procedure IntervalChange(Sender: TObject);
    procedure MsgServer1UserInfoChanged(const UserID: Cardinal);
    procedure MsgServer1UserRegistered(const UserID: Cardinal);
    procedure MsgServer1UserLogoff(const UserID: Cardinal);
    procedure MsgServer1UserLogon(const UserID: Cardinal);
    procedure SetParams;
    procedure GetParams;
    procedure PagesChanging(Sender: TObject; var AllowChange: Boolean);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure WSocket1SessionAvailable(Sender: TObject; ErrCode: Word);
    procedure FormShow(Sender: TObject);
    procedure FtpServer1Authenticate(Sender: TObject; Client: TFtpCtrlSocket; UserName, Password: TFtpString; var Authenticated: Boolean);
    procedure FtpServer1OtpGetPassword(Sender: TObject; Client: TFtpCtrlSocket; UserName: TFtpString; var UserPassword: string);
    procedure FtpServer1OtpMethod(Sender: TObject; Client: TFtpCtrlSocket; UserName: TFtpString; var OtpMethod: TOtpMethod);
    procedure FtpServer1ClientConnect(Sender: TObject; Client: TFtpCtrlSocket; AError: Word);
  private
    FIniFileName      : String;
    FInitialized      : Boolean;
    FClients          : TList;
    FOtpMethod        : TOtpMethod;
    FOtpSequence      : Integer;
    FOtpSeed          : String;
    FIniRoot          : String;
    //관리자 페이지 인터페이스
    FSender           : string;   // WAS
    FSchedRealDiv     : string;   // 스케쥴실시간구분 : 01=스케쥴, 02=실시간
    FDegree           : Integer;  // 차수
    FDegreeSeq        : Integer;  // 차수에대한순번
    FStcDynDiv        : string;   // 정적동적구분 : 01=정적수집(전체), 02=동적수집(증분)
    FCltStrtDm        : string;   // 수집시작일시
    FCltEndDm         : string;   // 수집종료일시
    FModCltStrtDm2    : string;   // 동적으로 수행할 수집시작시간
    FModCltEndDm2     : string;   // 동적으로 수행할 수집종료시간
    FRunCount         : Integer;  // 수행중인 에이전트 수
    FFinishCount      : Integer;  // 완료된 에이전트 수
    function  GetFtpInfo: String;
    procedure RemoveDirectoryAll(ADir: string);
    procedure RemoveDirofIP(AIpAddr, ASchedRealDiv, AStcDynDiv: string);
    procedure ClientDataAvailable(Sender: TObject; Error: Word);
    procedure ClientSessionClosed(Sender: TObject; Error: Word);
    procedure WMDestroySocket(var msg: TMessage);
    procedure ExecAgent(ASchedRealDiv, AStcDynDiv: String; ADegree, ADegreeSeq: Integer);
    procedure ExecSchedAgent(ASchedRealDiv, AStcDynDiv: String; ADegree, ADegreeSeq: Integer; ACltStrtDm, ACltEndDm, AModCltStrtDm2, AModCltEndDm2: string);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  RecvForm:            TRecvForm;
  IncomingMessages: String;

implementation

{$R *.dfm}

uses OverbyteIcsIniFiles, UDM_Oracle;

const
    { server Ini file layout }
    SectionWindow   = 'Server';
    KeyTop          = 'Top';
    KeyLeft         = 'Left';
    KeyWidth        = 'Width';
    KeyHeight       = 'Height';
    SectionData     = 'Data';
    KeyPort         = 'Port';
    KeyLinger       = 'Linger';
    KeyBanner       = 'SendBanner';

    { account INI file layout }
    KeyPassword         = 'Password';
    KeyHomeDir          = 'HomeDir';
    KeyOtpMethod        = 'OtpMethod';
    KeyForceHomeDir     = 'ForceHomeDir';
    KeyHidePhysicalPath = 'HidePhysicalPath';
    KeyReadOnly         = 'ReadOnly';
    KeyForceSsl         = 'ForceSsl';
    KeyMaxKB            = 'MaxKB';


procedure TRecvForm.SetParams;
begin
  ServerID.Text := IntToStr(MsgServer1.ServerID);
  LocalHost.Text := MsgServer1.LocalHost;
  LocalPort.Text := IntToStr(MsgServer1.LocalPort);
end;

procedure TRecvForm.GetParams;
begin
  MsgServer1.ServerID := StrToInt(ServerID.Text );
  MsgServer1.ConnectionParams.LocalHost := LocalHost.Text;
  MsgServer1.ConnectionParams.LocalPort := StrToInt(LocalPort.Text);
end;

procedure TRecvForm.FormCreate(Sender: TObject);
begin
  FIniRoot := LowerCase(ExtractFilePath(Application.ExeName)); // ftpaccounts.ini ftp접속시 otp암호를 위한 ini파일
  FIniFileName := GetCurrentDir + '\Server.ini';
  FClients := TList.Create;

  SetParams;
// grids headers
  sgConnectedUsers.ColCount := 4;
  sgConnectedUsers.RowCount := 1;
  sgConnectedUsers.ColWidths[0] := 40;
  sgConnectedUsers.ColWidths[1] := 45;
  sgConnectedUsers.ColWidths[3] := 40;
  sgConnectedUsers.Colwidths[2] := sgConnectedUsers.ClientWidth - 5 -
                                   sgConnectedUsers.ColWidths[1] -
                                   sgConnectedUsers.ColWidths[3] -
                                   sgConnectedUsers.ColWidths[0];
  sgConnectedUsers.Cells[0,0] := 'ID';
  sgConnectedUsers.Cells[1,0] := 'Name';
  sgConnectedUsers.Cells[2,0] := 'Host';
  sgConnectedUsers.Cells[3,0] := 'Port';
  sgAllUsers.ColCount := 6;
  sgAllUsers.RowCount := 1;
  sgAllUsers.ColWidths[0] := 10;
  sgAllUsers.ColWidths[1] := 40;
  sgAllUsers.ColWidths[2] := 45;
  sgAllUsers.ColWidths[3] := 50;
  sgAllUsers.ColWidths[5] := 40;
  sgAllUsers.ColWidths[4] := sgAllUsers.ClientWidth - 5 -
                             sgAllUsers.ColWidths[0] -
                             sgAllUsers.ColWidths[1] -
                             sgAllUsers.ColWidths[2] -
                             sgAllUsers.ColWidths[3] -
                             sgAllUsers.ColWidths[5];
  sgAllUsers.Cells[0,0] := '?';
  sgAllUsers.Cells[1,0] := 'ID';
  sgAllUsers.Cells[2,0] := 'UID';
  sgAllUsers.Cells[3,0] := 'Name';
  sgAllUsers.Cells[4,0] := 'Host';
  sgAllUsers.Cells[5,0] := 'Port';
// start server
  ServerStartClick(Sender);
//  ServerIncoming.Lines.Add(''); // work around bug with the first add
//  ServerIncoming.Lines.Clear;   // work around bug with the first add
  FillGrids;
  Pages.ActivePage := Users;
end;

procedure TRecvForm.FormShow(Sender: TObject);
begin
//    FtpServer1.MaxClients := 10;
//  FtpServer1.Start;
  WSocket1.Listen;

  if IS_TEST then
  begin
    if not DirectoryExists(FOLDER_TEST + '\schedule\dyn') then
      ForceDirectories(FOLDER_TEST + '\schedule\dyn');
    if not DirectoryExists(FOLDER_TEST + '\real') then
      ForceDirectories(FOLDER_TEST + '\real');
    if not DirectoryExists(FOLDER_TEST + '\agentupdate') then
      CreateDir(FOLDER_TEST + '\agentupdate');
  end
  else
  begin
    if not DirectoryExists(FOLDER_RUN + '\schedule\dyn') then
      ForceDirectories(FOLDER_RUN + '\schedule\dyn');
    if not DirectoryExists(FOLDER_RUN + '\real') then
      ForceDirectories(FOLDER_RUN + '\real');
    if not DirectoryExists(FOLDER_RUN + '\agentupdate') then
      CreateDir(FOLDER_RUN + '\agentupdate');
  end;

  FRunCount := 0;
  FFinishCount := 0;
end;

procedure TRecvForm.FtpServer1Authenticate(Sender: TObject;
  Client: TFtpCtrlSocket; UserName, Password: TFtpString;
  var Authenticated: Boolean);
begin
  if Client.OtpMethod > OtpKeyNoNe then
  begin
    if not Authenticated then exit;
      FOtpSequence := Client.OtpSequence;
      FOtpSeed := Client.OtpSeed;
  end
  else if (Client.AccountPassword <> 'windows') then
  begin
    if ((Client.UserName = UserName) and (Password <> '')) and
       ((Client.AccountPassword = Password) or (Client.AccountPassword = '*')) then { * anonymous logon }
    else
    begin
      Authenticated := FALSE;
    end;
    if Password = 'bad' then
      Authenticated := FALSE;
  end;
  if NOT Authenticated then exit;

  { Set the home and current directory - now done in OtpMethodEvent }
//  Client.HomeDir := RootDirectory.Text;
  if IS_TEST then
    Client.HomeDir := FOLDER_TEST
  else
    Client.HomeDir := FOLDER_RUN + '\schedule';
  Client.Directory := Client.HomeDir;
end;

procedure TRecvForm.FtpServer1ClientConnect(Sender: TObject;
  Client: TFtpCtrlSocket; AError: Word);
begin
  if IS_TEST then
    Client.HomeDir := FOLDER_TEST
  else
    Client.HomeDir := FOLDER_RUN + '\schedule';

  Client.SessIdInfo := Client.GetPeerAddr + '=(Not Logged On)';
  Client.AccountIniName := FIniRoot + 'ftpaccoounts.ini';
  Client.AccountReadOnly := True;
  Client.AccountPassword := '';
end;

procedure TRecvForm.FtpServer1OtpGetPassword(Sender: TObject;
  Client: TFtpCtrlSocket; UserName: TFtpString; var UserPassword: string);
begin
  UserPassword := Client.AccountPassword;
end;

procedure TRecvForm.FtpServer1OtpMethod(Sender: TObject; Client: TFtpCtrlSocket;
  UserName: TFtpString; var OtpMethod: TOtpMethod);
var
    IniFile: TIcsIniFile;
    S: string;
begin
    { look up user account to find One Time Password method, root directory, etc, blank password means no account}
    if NOT FileExists(Client.AccountIniName) then begin
//        InfoMemo.Lines.Add('! Could not find Accounts File: ' + Client.AccountIniName);
        exit;
    end;
//    InfoMemo.Lines.Add('! Opening Accounts file: ' + Client.AccountIniName);
    IniFile := TIcsIniFile.Create(Client.AccountIniName);
    Client.AccountPassword := IniFile.ReadString(UserName, KeyPassword, ''); // keep password to check later
    S := IniFile.ReadString(UserName, KeyOtpMethod, 'none');
    Client.AccountReadOnly := (IniFile.ReadString(UserName, KeyReadOnly, 'true') = 'true');
//    Client.HomeDir := IniFile.ReadString(UserName, KeyHomeDir, 'E:\download\schedule'); // 217 Server

    if IS_TEST then
        Client.HomeDir := FOLDER_TEST
    else
        Client.HomeDir := FOLDER_RUN + '\schedule'; // 217 Server

    Client.Directory := Client.HomeDir;
    if (IniFile.ReadString(UserName, KeyForceHomeDir, 'true') = 'true') then
        Client.Options := Client.Options + [ftpCdUpHome];
    if (IniFile.ReadString(UserName, KeyHidePhysicalPath, 'true') = 'true') then
        Client.Options := Client.Options + [ftpHidePhysicalPath];
    if (IniFile.ReadString(UserName, KeyForceSsl, 'false') = 'true') then
        Client.AccountPassword := ''; // SSL not supported so fail password
    IniFile.Free;

    { sequence and seed }
    OtpMethod := OtpGetMethod(S);
    Client.OtpSequence := FOtpSequence;
    Client.OtpSeed := FOtpSeed;

    { this could be user account information, SQL id or something }
    Client.SessIdInfo := Client.GetPeerAddr + '=' + UserName;
end;

procedure TRecvForm.ServerStartClick(Sender: TObject);
begin
  GetParams;
// start server
  MsgServer1.Active := True;
// show LocalPort
  LocalPort.Text := IntToStr(MsgServer1.ConnectionParams.LocalPort);
// disable/enable buttons
  LocalPort.Enabled := False;
  LocalHost.Enabled := False;
  ServerID.Enabled := False;
  ServerStart.Enabled := False;
  ServerStop.Enabled := True;
  DisconnectUser.Enabled := False;
  DeleteUser.Enabled := False;
end;

procedure TRecvForm.ServerStopClick(Sender: TObject);
begin
// stop server
  MsgServer1.Active := False;
// disable/enable buttons
  LocalPort.Enabled := True;
  LocalHost.Enabled := True;
  ServerID.Enabled := True;
  ServerStart.Enabled := True;
  ServerStop.Enabled := False;
  DisconnectUser.Enabled := False;
  DeleteUser.Enabled := False;
// clear form
  ClearGrid(sgConnectedUsers);
  ClearGrid(sgallUsers);
  ServerToID.Text := '';
end;

// 여기 들어오는 모든 메시지 로그처리 할것
procedure TRecvForm.MsgServer1ReceiveTextMessage(const FromUserID: Cardinal; const SendingDate,DeliveryDate: TDateTime; const Text: AnsiString);
var
  str:          AnsiString;
  UserInfo:     TMsgUserInfo;
  szFolder: string;
  szClient: string;
  dbTable: string;
  aMsg: TArray<String>;
  sSchedRealDiv, sStcDynDiv, sLogFile: string;
  iDegree, iDegreeSeq: Integer;
  sWiseNut: string;
begin
  {
  while not Canvas.TryLock do
    sleep(0);
  }
  try
    str := '#' + IntToStr(FromUserID) + ', ' + DateTimeToStr(SendingDate) + ':';
    try
      UserInfo := MsgServer1.GetUserInfo(FromUserID);
      if (UserInfo.UserID <> MSG_INVALID_USER_ID) then
        str := UserInfo.UserName + ' ' + str;
    except
      str := 'Unregistered User ID = ' + IntToStr(FromUserID) + ' ' + str;
    end;
    IncomingMessages := IncomingMessages+str+' RCnt:'+IntToStr(FRunCount)+' FCnt:'+IntToStr(FFinishCount)+#13;
    IncomingMessages := IncomingMessages+Text+#13;
    if Pages.ActivePage = Incoming then
    begin
      ServerIncoming.Lines.Add(str+' RCnt:'+IntToStr(FRunCount)+' FCnt:'+IntToStr(FFinishCount));
      ServerIncoming.Lines.Add(Text);
    end;

    if Pos('FILESENDEND', Text) > 0 then
    begin
      aMsg := string(Text).Split(['|']);
      if Length(aMsg) > 0 then sSchedRealDiv := aMsg[1];
      if Length(aMsg) > 1 then sStcDynDiv    := aMsg[2];
      if Length(aMsg) > 2 then iDegree       := StrToInt(aMsg[3]);
      if Length(aMsg) > 3 then iDegreeSeq    := StrToInt(aMsg[4]);

      if IS_TEST then
      begin
        if sSchedRealDiv = '02' then
          szFolder := FOLDER_TEST + '\real'
        else
          szFolder := FOLDER_TEST + '\schedule';
      end
      else
      begin
        if sSchedRealDiv = '02' then
          szFolder := FOLDER_RUN + '\real'
        else
          szFolder := FOLDER_RUN + '\schedule';
      end;

      szClient := UserInfo.Host;

      // FileScan.txt 파일을 매핑하여 디렉토리구조생성
      // FDirThread := TDirThread.Create(szClient, szFolder);
      WinExec(PAnsiChar(AnsiString(ExtractFilePath(ParamStr(0)) + 'MDHierarchy.exe ' + szClient + ' ' + szFolder)), SW_HIDE);

      FFinishCount := FFinishCount + 1;

      if (FRunCount = FFinishCount) then
      begin
        // DB Update부분
        with uqryVDI do
        begin
          // PROG_STAT varchar(2)     // 처리상태 : 01=서버수행시작, 02=서버수행종료, 03=타임아웃으로 에이전트 강제 연결종료, 04=이어받기 후 서버수행종료, 10=검색엔진수행시작, 11=검색엔진수행종료
          // SVR_EXEC_END_DT char(8)  // Agent Server 수행종료일자
          // SVR_EXEC_END_TM char(8)  // Agent Server 수행종료시간
          dbTable := 'COMEDI.HSIT_VDI_EXEC_STAT';
          SQL.Clear;
          SQL.Text := Format('update %s set PROG_STAT = :prog_stat, SVR_EXEC_END_DT = :svr_exec_end_dt, SVR_EXEC_END_TM = :svr_exec_end_tm where SCHED_REAL_DIV = %s and DEGREE = s', [dbTable, QuotedStr(sSchedRealDiv), IntToStr(iDegree)]);
          ParamByName('prog_stat').AsString       := '02';
          ParamByName('svr_exec_end_dt').AsString := FormatDateTime('yyyymmdd', Now);
          ParamByName('svr_exec_end_tm').AsString := FormatDateTime('hhnnss', Now);

          ExecSQL;

          Close;
        end;
        FRunCount := 0;
        FFinishCount := 0;

        // 검색엔진 수행 CMD
        if IS_TEST then
          sWiseNut := 'c:\wisenut\sf-1\batch\agent'
        else
          sWiseNut := 'd:\wisenut\sf-1\batch\agent';

        if sSchedRealDiv = '02' then
        begin
          if FileExists(sWiseNut + '\static_realvdi.cmd') then
            WinExec(PAnsiChar(AnsiString(sWiseNut + '\static_realvdi.cmd ' + sSchedRealDiv + ' ' + IntToStr(iDegree) + ' ' + IntToStr(iDegreeSeq) + ' ' + sStcDynDiv)), SW_HIDE);
        end
        else
        begin
          if sStcDynDiv = '02' then
          begin
            if FileExists(sWiseNut + '\dynamic_vdi.cmd') then
              WinExec(PAnsiChar(AnsiString(sWiseNut + '\dynamic_vdi.cmd ' + sSchedRealDiv + ' ' + IntToStr(iDegree) + ' ' + IntToStr(iDegreeSeq) + ' ' + sStcDynDiv)), SW_HIDE);
          end
          else
          begin
            if FileExists(sWiseNut + '\static_vdi.cmd') then
              WinExec(PAnsiChar(AnsiString(sWiseNut + '\static_vdi.cmd ' + sSchedRealDiv + ' ' + IntToStr(iDegree) + ' ' + IntToStr(iDegreeSeq) + ' ' + sStcDynDiv)), SW_HIDE);
          end;
        end;
      end;
    end
    // 증분처리
    else if Pos('DYNSENDEND', Text) > 0 then
    begin
      aMsg := string(Text).Split(['|']);
      if Length(aMsg) > 0 then sSchedRealDiv := aMsg[1];
      if Length(aMsg) > 1 then sStcDynDiv    := aMsg[2];
      if Length(aMsg) > 2 then iDegree       := StrToInt(aMsg[3]);
      if Length(aMsg) > 3 then iDegreeSeq    := StrToInt(aMsg[4]);
      if Length(aMsg) > 4 then sLogFile      := aMsg[5];

      if IS_TEST then
      begin
        if sSchedRealDiv = '02' then
          szFolder := FOLDER_TEST + '\real'
        else
          szFolder := FOLDER_TEST + '\schedule';
      end
      else
      begin
        if sSchedRealDiv = '02' then
          szFolder := FOLDER_RUN + '\real'
        else
          szFolder := FOLDER_RUN + '\schedule';
      end;

      szClient := UserInfo.Host;
      // 172.24.33.151_2-141224.log 파일을 매핑하여 폴더 Sync
      WinExec(PAnsiChar(AnsiString(ExtractFilePath(ParamStr(0)) + 'CPDynFiles.exe ' + szClient + ' ' + szFolder + ' ' + sLogFile)), SW_HIDE);

      // 검색엔진 수행 CMD
      if IS_TEST then
        sWiseNut := 'c:\wisenut\sf-1\batch\agent'
      else
        sWiseNut := 'd:\wisenut\sf-1\batch\agent';

      if sSchedRealDiv = '02' then
      begin
        if FileExists(sWiseNut + '\static_realvdi.cmd') then
          WinExec(PAnsiChar(AnsiString(sWiseNut + '\static_realvdi.cmd ' + sSchedRealDiv + ' ' + IntToStr(iDegree) + ' ' + IntToStr(iDegreeSeq) + ' ' + sStcDynDiv)), SW_HIDE);
      end
      else
      begin
        if sStcDynDiv = '02' then
        begin
          if FileExists(sWiseNut + '\dynamic_vdi.cmd') then
            WinExec(PAnsiChar(AnsiString(sWiseNut + '\dynamic_vdi.cmd ' + sSchedRealDiv + ' ' + IntToStr(iDegree) + ' ' + IntToStr(iDegreeSeq) + ' ' + sStcDynDiv)), SW_HIDE);
        end
        else
        begin
          if FileExists(sWiseNut + '\static_vdi.cmd') then
            WinExec(PAnsiChar(AnsiString(sWiseNut + '\static_vdi.cmd ' + sSchedRealDiv + ' ' + IntToStr(iDegree) + ' ' + IntToStr(iDegreeSeq) + ' ' + sStcDynDiv)), SW_HIDE);
        end;
      end;
    end;

  {
  finally
    Canvas.Unlock;
  }
  except
  end;
end;

// 여기 들어오는 모든 메시지 로그처리 할것
procedure TRecvForm.MsgServer1ReceiveUnicodeTextMessage(const FromUserID: Cardinal; const SendingDate, DeliveryDate: TDateTime; const Text: WideString);
var
  str:          AnsiString;
  UserInfo:     TMsgUserInfo;
  szFolder: string;
  szClient: string;
  dbTable: string;
  aMsg: TArray<String>;
  sSchedRealDiv, sStcDynDiv, sLogFile: string;
  iDegree, iDegreeSeq: Integer;
  sWiseNut: string;
begin
  {
  while not Canvas.TryLock do
    sleep(0);
  }
  try
    str := '#' + IntToStr(FromUserID) + ', ' + DateTimeToStr(SendingDate) + ':';
    try
      UserInfo := MsgServer1.GetUserInfo(FromUserID);
      if (UserInfo.UserID <> MSG_INVALID_USER_ID) then
        str := UserInfo.UserName + ' ' + str;
    except
      str := 'Unregistered User ID = ' + IntToStr(FromUserID) + ' ' + str;
    end;
    IncomingMessages := IncomingMessages+str+' RCnt:'+IntToStr(FRunCount)+' FCnt:'+IntToStr(FFinishCount)+#13;
    IncomingMessages := IncomingMessages+Text+#13;
    if Pages.ActivePage = Incoming then
    begin
      ServerIncoming.Lines.Add(str+' RCnt:'+IntToStr(FRunCount)+' FCnt:'+IntToStr(FFinishCount));
      ServerIncoming.Lines.Add(Text);
    end;

    if Pos('FILESENDEND', string(Text)) > 0 then
    begin
      aMsg := string(Text).Split(['|']);
      if Length(aMsg) > 0 then sSchedRealDiv := aMsg[1];
      if Length(aMsg) > 1 then sStcDynDiv    := aMsg[2];
      if Length(aMsg) > 2 then iDegree       := StrToInt(aMsg[3]);
      if Length(aMsg) > 3 then iDegreeSeq    := StrToInt(aMsg[4]);

      if IS_TEST then
      begin
        if sSchedRealDiv = '02' then
          szFolder := FOLDER_TEST + '\real'
        else
          szFolder := FOLDER_TEST + '\schedule';
      end
      else
      begin
        if sSchedRealDiv = '02' then
          szFolder := FOLDER_RUN + '\real'
        else
          szFolder := FOLDER_RUN + '\schedule';
      end;

      szClient := UserInfo.Host;

      // FileScan.txt 파일을 매핑하여 디렉토리구조생성
      // FDirThread := TDirThread.Create(szClient, szFolder);
      WinExec(PAnsiChar(AnsiString(ExtractFilePath(ParamStr(0)) + 'MDHierarchy.exe ' + szClient + ' ' + szFolder)), SW_HIDE);

      FFinishCount := FFinishCount + 1;

      if (FRunCount = FFinishCount) then
      begin
        // DB Update부분
        with uqryVDI do
        begin
          // PROG_STAT varchar(2)     // 처리상태 : 01=서버수행시작, 02=서버수행종료, 03=타임아웃으로 에이전트 강제 연결종료, 04=이어받기 후 서버수행종료, 10=검색엔진수행시작, 11=검색엔진수행종료
          // SVR_EXEC_END_DT char(8)  // Agent Server 수행종료일자
          // SVR_EXEC_END_TM char(8)  // Agent Server 수행종료시간
          dbTable := 'COMEDI.HSIT_VDI_EXEC_STAT';
          SQL.Clear;
          SQL.Text := Format('update %s set PROG_STAT = :prog_stat, SVR_EXEC_END_DT = :svr_exec_end_dt, SVR_EXEC_END_TM = :svr_exec_end_tm where SCHED_REAL_DIV = %s and DEGREE = s', [dbTable, QuotedStr(sSchedRealDiv), IntToStr(iDegree)]);
          ParamByName('prog_stat').AsString       := '02';
          ParamByName('svr_exec_end_dt').AsString := FormatDateTime('yyyymmdd', Now);
          ParamByName('svr_exec_end_tm').AsString := FormatDateTime('hhnnss', Now);

          ExecSQL;

          Close;
        end;
        FRunCount := 0;
        FFinishCount := 0;

        // 검색엔진 수행 CMD
        if IS_TEST then
          sWiseNut := 'c:\wisenut\sf-1\batch\agent'
        else
          sWiseNut := 'd:\wisenut\sf-1\batch\agent';

        if sSchedRealDiv = '02' then
        begin
          if FileExists(sWiseNut + '\static_realvdi.cmd') then
            WinExec(PAnsiChar(AnsiString(sWiseNut + '\static_realvdi.cmd ' + sSchedRealDiv + ' ' + IntToStr(iDegree) + ' ' + IntToStr(iDegreeSeq) + ' ' + sStcDynDiv)), SW_HIDE);
        end
        else
        begin
          if sStcDynDiv = '02' then
          begin
            if FileExists(sWiseNut + '\dynamic_vdi.cmd') then
              WinExec(PAnsiChar(AnsiString(sWiseNut + '\dynamic_vdi.cmd ' + sSchedRealDiv + ' ' + IntToStr(iDegree) + ' ' + IntToStr(iDegreeSeq) + ' ' + sStcDynDiv)), SW_HIDE);
          end
          else
          begin
            if FileExists(sWiseNut + '\static_vdi.cmd') then
              WinExec(PAnsiChar(AnsiString(sWiseNut + '\static_vdi.cmd ' + sSchedRealDiv + ' ' + IntToStr(iDegree) + ' ' + IntToStr(iDegreeSeq) + ' ' + sStcDynDiv)), SW_HIDE);
          end;
        end;
      end;
    end
    // 증분처리
    else if Pos('DYNSENDEND', string(Text)) > 0 then
    begin
      aMsg := string(Text).Split(['|']);
      if Length(aMsg) > 0 then sSchedRealDiv := aMsg[1];
      if Length(aMsg) > 1 then sStcDynDiv    := aMsg[2];
      if Length(aMsg) > 2 then iDegree       := StrToInt(aMsg[3]);
      if Length(aMsg) > 3 then iDegreeSeq    := StrToInt(aMsg[4]);
      if Length(aMsg) > 4 then sLogFile      := aMsg[5];

      if IS_TEST then
      begin
        if sSchedRealDiv = '02' then
          szFolder := FOLDER_TEST + '\real'
        else
          szFolder := FOLDER_TEST + '\schedule';
      end
      else
      begin
        if sSchedRealDiv = '02' then
          szFolder := FOLDER_RUN + '\real'
        else
          szFolder := FOLDER_RUN + '\schedule';
      end;

      szClient := UserInfo.Host;
      // 172.24.33.151_2-141224.log 파일을 매핑하여 폴더 Sync
      WinExec(PAnsiChar(AnsiString(ExtractFilePath(ParamStr(0)) + 'CPDynFiles.exe ' + szClient + ' ' + szFolder + ' ' + sLogFile)), SW_HIDE);

      // 검색엔진 수행 CMD
      if IS_TEST then
        sWiseNut := 'c:\wisenut\sf-1\batch\agent'
      else
        sWiseNut := 'd:\wisenut\sf-1\batch\agent';

      if sSchedRealDiv = '02' then
      begin
        if FileExists(sWiseNut + '\static_realvdi.cmd') then
          WinExec(PAnsiChar(AnsiString(sWiseNut + '\static_realvdi.cmd ' + sSchedRealDiv + ' ' + IntToStr(iDegree) + ' ' + IntToStr(iDegreeSeq) + ' ' + sStcDynDiv)), SW_HIDE);
      end
      else
      begin
        if sStcDynDiv = '02' then
        begin
          if FileExists(sWiseNut + '\dynamic_vdi.cmd') then
            WinExec(PAnsiChar(AnsiString(sWiseNut + '\dynamic_vdi.cmd ' + sSchedRealDiv + ' ' + IntToStr(iDegree) + ' ' + IntToStr(iDegreeSeq) + ' ' + sStcDynDiv)), SW_HIDE);
        end
        else
        begin
          if FileExists(sWiseNut + '\static_vdi.cmd') then
            WinExec(PAnsiChar(AnsiString(sWiseNut + '\static_vdi.cmd ' + sSchedRealDiv + ' ' + IntToStr(iDegree) + ' ' + IntToStr(iDegreeSeq) + ' ' + sStcDynDiv)), SW_HIDE);
        end;
      end;
    end;

  {
  finally
    Canvas.Unlock;
  }
  except
  end;
end;

procedure TRecvForm.ServerSendClick(Sender: TObject);
var
  str:          String;
  UserInfo:     TMsgUserInfo;
begin
  if ServerToID.Text = '' then
    Exit;
  MsgServer1.SendMessage(Cardinal(StrToInt(ServerToID.Text)), ServerMsg.Text);
  str := '#' + ServerToID.Text + ', ' + TimeToStr(Time) + ':';
  UserInfo := MsgServer1.GetUserInfo(StrToInt(ServerToID.Text));
  if UserInfo.UserName <> '' then
    str := UserInfo.UserName + ' ' + str;
  ServerSent.Lines.Add(str);
  ServerSent.Lines.Add(ServerMsg.Text);
  ServerMsg.Text := '';
end;

procedure TRecvForm.sgConnectedUsersSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
  if (ARow <= 0) or (ARow >= sgConnectedUsers.RowCount) then
    Exit;
  ServerToID.Text := '';
  if (sgConnectedUsers.Cells[0,ARow] <> '') then
   begin
    if (sgConnectedUsers.Cells[0,ARow] <> IntToStr(MSG_INVALID_USER_ID)) then
     begin
       ServerSend.Enabled := True;
       ServerToID.Text := sgConnectedUsers.Cells[0,ARow];
     end
    else
     begin
       ServerSend.Enabled := False;
     end;
   end;
end;

procedure TRecvForm.sgAllUsersSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
  if (ARow <= 0) or (ARow >= sgAllUsers.RowCount) then
    Exit;
  SelectedUserID.Text := '';
  if (sgAllUsers.Cells[1,ARow] <> '') then
   begin
    SelectedUserID.Text := sgAllUsers.Cells[1,ARow];
    DisconnectUser.Enabled := (sgAllUsers.Cells[0,ARow] = '+');
    if (sgAllUsers.Cells[1,ARow] <> IntToStr(MSG_INVALID_USER_ID)) then
     DeleteUser.Enabled := True
    else
     begin
      DisconnectUser.Enabled := False;
      DeleteUser.Enabled := False;
     end;
   end;
end;

procedure TRecvForm.MsgServer1BeforeDisconnect(Sender: TObject);
begin
  ServerToID.Text := '';
end;

procedure TRecvForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  MsgServer1.Active := False;
end;

procedure TRecvForm.DisconnectUserClick(Sender: TObject);
begin
  MsgServer1.DisconnectUser(Cardinal(StrToInt(SelectedUserID.Text)));
  DisconnectUser.Enabled := False;
  DeleteUser.Enabled := True;
  FillGrids;
end;

procedure TRecvForm.DeleteUserClick(Sender: TObject);
var
  UID:        Cardinal;
begin
  UID := Cardinal(StrToInt(SelectedUserID.Text));
  if MsgServer1.IsUserConnected(UID) then
    MsgServer1.DisconnectUser(StrToInt(SelectedUserID.Text));
  if MsgServer1.IsUserExisting(UID) then
    MsgServer1.DeleteUser(UID);
  DeleteUser.Enabled := False;
  DisconnectUser.Enabled := False;
  FillGrids;
end;


procedure TRecvForm.FillCounts;
begin
{
  while not Canvas.TryLock do
    sleep(0);
}
  try
    UserCount.Caption   := 'Users:   '+IntToStr(MsgServer1.UsersCount);
    OnLineCount.Caption := 'OnLine: '+IntToStr(MsgServer1.OnLineUsersCount);
    GuestCount.Caption  := 'Guests: '+IntToStr(MsgServer1.GuestsCount);
{
  finally
   Canvas.Unlock;
}
  except
  end;
end;


procedure TRecvForm.FillGrids;
var Users:    TMsgUserInfoArray;
    i,na,nc:  Integer;
    Clients:  TMsgClientInfoArray;
    id1,id2:  String;
    gr1,gr2:  TGridRect;
begin
{
  while not Canvas.TryLock do
    sleep(0);
}
  try
    MsgServer1.GetUsers(Users);
    MsgServer1.GetClients(Clients);
    FillCounts;
    id1 := ServerToID.Text;
    id2 := SelectedUserID.Text;
    gr1 := sgConnectedUsers.Selection;
    gr2 := sgAllUsers.Selection;
    try
      ClearGrid(sgAllUsers);
      ClearGrid(sgConnectedUsers);
      na := 0;
      nc := 0;
      for i := Low(Users) to High(Users) do
       begin
        if (Users[i].Status = msgOnLine) then
         begin
          Inc(nc);
          if (nc >= sgConnectedUsers.RowCount) then
           sgConnectedUsers.RowCount := nc+1;
          sgConnectedUsers.Cells[0,nc] := IntToStr(Users[i].UserID);
          sgConnectedUsers.Cells[1,nc] := Users[i].UserName;
          sgConnectedUsers.Cells[2,nc] := Users[i].Host;
          sgConnectedUsers.Cells[3,nc] := IntToStr(Users[i].Port);
         end;
        Inc(na);
        if (na >= sgAllUsers.RowCount) then
         sgAllUsers.RowCount := na+1;
        if (Users[i].Status = msgOnLine) then
         sgAllUsers.Cells[0,na] := '+'
        else
         sgAllUsers.Cells[0,na] := '-';
        sgAllUsers.Cells[1,na] := IntToStr(Users[i].UserID);
        sgAllUsers.Cells[2,na] := Users[i].UserName;
        sgAllUsers.Cells[3,na] := Users[i].Department;
        sgAllUsers.Cells[4,na] := Users[i].Host;
        sgAllUsers.Cells[5,na] := IntToStr(Users[i].Port);
       end;
      for i := Low(Clients) to High(Clients) do
       if (Clients[i].UserID = MSG_INVALID_USER_ID) then
        begin
          Inc(nc);
          if (nc >= sgConnectedUsers.RowCount) then
           sgConnectedUsers.RowCount := nc+1;
          sgConnectedUsers.Cells[0,nc] := IntToStr(MSG_INVALID_USER_ID);
          sgConnectedUsers.Cells[1,nc] := Guest;
          sgConnectedUsers.Cells[2,nc] := Clients[i].Host;
          sgConnectedUsers.Cells[3,nc] := IntToStr(Clients[i].Port);
          Inc(na);
          if (na >= sgAllUsers.RowCount) then
           sgAllUsers.RowCount := na+1;
          sgAllUsers.Cells[0,na] := '+';
          sgAllUsers.Cells[1,na] := IntToStr(MSG_INVALID_USER_ID);
          sgAllUsers.Cells[2,na] := Guest;
          sgAllUsers.Cells[3,na] := '';
          sgAllUsers.Cells[4,na] := Clients[i].Host;
          sgAllUsers.Cells[5,na] := IntToStr(Clients[i].Port);
        end;
     for i := 1 to sgAllUsers.RowCount-1 do
      if (sgAllUsers.Cells[1,i] = id2) then
       begin
        gr2.Top := i;
        gr2.Bottom := i;
        sgAllUsers.Selection := gr2;
        SelectedUserID.Text := id2;
        break;
       end;
     for i := 1 to sgConnectedUsers.RowCount-1 do
      if (sgConnectedUsers.Cells[0,i] = id1) then
       begin
        gr1.Top := i;
        gr1.Bottom := i;
        sgConnectedUsers.Selection := gr1;
        ServerToID.Text := id1;
        break;
       end;
    finally
      SetLength(Users,0);
      SetLength(Clients,0);
    end;
{
  finally
   Canvas.Unlock;
}
  except
  end;
end; // FillGrids


{-------------------------------------------------------------
 Procedure: Button1Click
 Author: lyh
 Date: 2014.12.16
 Arguments: Sender: TObject
 History: 사용자 초기화 하기
          HIST_VDI_EXEC_AGENT_LIST
-------------------------------------------------------------}
procedure TRecvForm.Button1Click(Sender: TObject);
var
    UserInfo: TMsgUserInfo;
    i: Integer;
    Users:    TMsgUserInfoArray;
begin
    if Application.MessageBox('사용자 초기화를 하시겠습니까?', '질문', MB_ICONQUESTION + MB_OKCANCEL) = mrCancel then
        Exit;

  // AGENT_LIST : Agent Unique ID (전체 IP목록, 카드, 캐피탈, 커머셜)
  // HIST_VDI_VM : Agent가 설치된 IP목록
  with uqryVDI do
  begin
    Active := False;
    SQL.Clear;
    SQL.Add(' SELECT VIEW_1.ID, VIEW_1.IP, VIEW_2.EMP_ID, VIEW_2.EMP_NAME ');
    SQL.Add('   FROM (SELECT ID, IP                                       ');
    SQL.Add('           FROM AGENT_LIST) VIEW_1,                          ');
    SQL.Add('        (SELECT IP, EMP_ID, EMP_NAME                         ');
    SQL.Add('           FROM HIST_VDI_VM) VIEW_2                          ');
    SQL.Add('  WHERE VIEW_1.IP = VIEW_2.IP                                ');
    SQL.Add('  ORDER BY VIEW_1.IP                                         ');

    Active := True;

    if not IsEmpty then
    begin
      // 기존 Contact List Clear
      MsgServer1.GetUsers(Users);

      for i := Low(Users) to High(Users) do
      begin
        // 접속이 되어있는 경우 접속 해제 (에이전트 에서는 접속되었다 해제되는경우 타이머를 통하여 재접속을 시도한다)
        if (Users[i].Status = msgOnLine) then
          MsgServer1.DisconnectUser(Users[i].UserID);

        MsgServer1.DeleteUser(Users[i].UserID);
      end;

      First;

      repeat
        UserInfo.UserID := Cardinal(FieldByName('ID').AsInteger);
        UserInfo.UserName := FieldByName('EMP_ID').AsString;
        UserInfo.Department := FieldByName('EMP_NM').AsString;
        UserInfo.Host := '';
        UserInfo.Port := 0;
        MsgServer1.InsertUser(UserInfo);

        Next;
      until Eof;
    end;
    Active := False;
  end;
end;

procedure TRecvForm.Button2Click(Sender: TObject);
var
  UserInfo: TMsgUserInfo;
  i: Integer;
  Users: TMsgUserInfoArray;
begin
  // Test
  UserInfo.UserID := 99999;
  UserInfo.UserName := '154';
  UserInfo.Department := '';
  UserInfo.Host := '';
  UserInfo.Port := 0;
  MsgServer1.InsertUser(UserInfo);

  UserInfo.UserID := 99998;
  UserInfo.UserName := '153';
  UserInfo.Department := '';
  UserInfo.Host := '';
  UserInfo.Port := 0;
  MsgServer1.InsertUser(UserInfo);

  UserInfo.UserID := 99997;
  UserInfo.UserName := '152';
  UserInfo.Department := '';
  UserInfo.Host := '';
  UserInfo.Port := 0;
  MsgServer1.InsertUser(UserInfo);

  UserInfo.UserID := 99996;
  UserInfo.UserName := '151';
  UserInfo.Department := '';
  UserInfo.Host := '';
  UserInfo.Port := 0;
  MsgServer1.InsertUser(UserInfo);

  UserInfo.UserID := 99995;
  UserInfo.UserName := '150';
  UserInfo.Department := '';
  UserInfo.Host := '';
  UserInfo.Port := 0;
  MsgServer1.InsertUser(UserInfo);

  UserInfo.UserID := 99994;
  UserInfo.UserName := '149';
  UserInfo.Department := '';
  UserInfo.Host := '';
  UserInfo.Port := 0;
  MsgServer1.InsertUser(UserInfo);

  UserInfo.UserID := 99993;
  UserInfo.UserName := '148';
  UserInfo.Department := '';
  UserInfo.Host := '';
  UserInfo.Port := 0;
  MsgServer1.InsertUser(UserInfo);

  UserInfo.UserID := 99992;
  UserInfo.UserName := '147';
  UserInfo.Department := '';
  UserInfo.Host := '';
  UserInfo.Port := 0;
  MsgServer1.InsertUser(UserInfo);

  UserInfo.UserID := 99991;
  UserInfo.UserName := '146';
  UserInfo.Department := '';
  UserInfo.Host := '';
  UserInfo.Port := 0;
  MsgServer1.InsertUser(UserInfo);

  UserInfo.UserID := 99990;
  UserInfo.UserName := '145';
  UserInfo.Department := '';
  UserInfo.Host := '';
  UserInfo.Port := 0;
  MsgServer1.InsertUser(UserInfo);

  UserInfo.UserID := 99989;
  UserInfo.UserName := '144';
  UserInfo.Department := '';
  UserInfo.Host := '';
  UserInfo.Port := 0;
  MsgServer1.InsertUser(UserInfo);

  Exit;
end;

procedure TRecvForm.ClearGrid(Grid: TStringGrid);
var i: Integer;
begin
  Grid.RowCount := 2;
  Grid.FixedRows := 1;
  for i := 0 to Grid.ColCount-1 do
   Grid.Cells[i,1] := '';
end;

procedure TRecvForm.Timer1Timer(Sender: TObject);
begin
  FillCounts;
  if cbOnTimer.Checked then
    FillGrids;
end;

procedure TRecvForm.MsgServer1AfterServerStart(Sender: TObject);
begin
  Timer1.Enabled := True;
  ServerSettings.Lines.Add('Version: '+MsgServer1.CurrentVersion);
  ServerSettings.Lines.Add('Data path: '+MsgServer1.DataPath);
  ServerSettings.Lines.Add('AllowFiles: '+BoolToStr(MsgServer1.AllowFiles));
  ServerSettings.Lines.Add('============================================');
  ServerSettings.Lines.Add('Network settings:');
  ServerSettings.Lines.Add('----------------------------------------------------------------------------------------');
  ServerSettings.Lines.Add('PacketSize: '+IntToStr(MsgServer1.ConnectionParams.NetworkSettings.PacketSize));
  ServerSettings.Lines.Add('PingClients: '+BoolToStr(MsgServer1.ConnectionParams.NetworkSettings.PingClients));
  ServerSettings.Lines.Add('WaitForPingAnswer: '+IntToStr(MsgServer1.ConnectionParams.NetworkSettings.WaitForPingAnswer));
  ServerSettings.Lines.Add('ServerPingSleep: '+IntToStr(MsgServer1.ConnectionParams.NetworkSettings.ServerPingSleep));
  ServerSettings.Lines.Add('ConnectionParamsTunning: '+BoolToStr(MsgServer1.ConnectionParams.NetworkSettings.ConnectionParamsTunning));
  ServerSettings.Lines.Add('TestPacketCount: '+IntToStr(MsgServer1.ConnectionParams.NetworkSettings.TestPacketCount));
  ServerSettings.Lines.Add('DisconnectRetryCount: '+IntToStr(MsgServer1.ConnectionParams.NetworkSettings.DisconnectRetryCount));
  ServerSettings.Lines.Add('DisconnectDelay: '+IntToStr(MsgServer1.ConnectionParams.NetworkSettings.DisconnectDelay));
  ServerSettings.Lines.Add('ServerReceiveTimeOut: '+IntToStr(MsgServer1.ConnectionParams.NetworkSettings.ServerReceiveTimeOut));
  ServerSettings.Lines.Add('ServerReceiveSleep: '+IntToStr(MsgServer1.ConnectionParams.NetworkSettings.ServerReceiveSleep));
  ServerSettings.Lines.Add('MinServerSendTimeOut: '+IntToStr(MsgServer1.ConnectionParams.NetworkSettings.MinServerSendTimeOut));
  ServerSettings.Lines.Add('ServerSendTimeOut: '+IntToStr(MsgServer1.ConnectionParams.NetworkSettings.ServerSendTimeOut));
  ServerSettings.Lines.Add('ServerWaitForSendSleep: '+IntToStr(MsgServer1.ConnectionParams.NetworkSettings.ServerWaitForSendSleep));
  ServerSettings.Lines.Add('ServerResendDelay: '+IntToStr(MsgServer1.ConnectionParams.NetworkSettings.ServerResendDelay));
  ServerSettings.Lines.Add('ServerRequestDelay: '+IntToStr(MsgServer1.ConnectionParams.NetworkSettings.ServerRequestDelay));
  ServerSettings.Lines.Add('WaitForMessagesSend: '+IntToStr(MsgServer1.ConnectionParams.NetworkSettings.WaitForMessagesSend));
  ServerSettings.Lines.Add('WaitForServerSessionThreadTimeOut: '+IntToStr(MsgServer1.ConnectionParams.NetworkSettings.WaitForServerSessionThreadTimeOut));
  ServerSettings.Lines.Add('ServerThreadsTerminateDelay: '+IntToStr(MsgServer1.ConnectionParams.NetworkSettings.ServerThreadsTerminateDelay));
  ServerSettings.Lines.Add('ServerSessionTerminatorSleep: '+IntToStr(MsgServer1.ConnectionParams.NetworkSettings.ServerSessionTerminatorSleep));
  ServerSettings.Lines.Add('MaxThreadCount: '+IntToStr(MsgServer1.ConnectionParams.NetworkSettings.MaxThreadCount));
  ServerSettings.Lines.Add('============================================');
  ServerSettings.Lines.Add('Encryption settings:');
  ServerSettings.Lines.Add('----------------------------------------------------------------------------------------');
  ServerSettings.Lines.Add('CryptoAlgorithm: '+IntToStr(Integer(MsgServer1.ConnectionParams.CryptoParams.CryptoAlgorithm)));
  ServerSettings.Lines.Add('CryptoMode: '+IntToStr(Integer(MsgServer1.ConnectionParams.CryptoParams.CryptoMode)));
  ServerSettings.Lines.Add('Password: '+MsgServer1.ConnectionParams.CryptoParams.Password);
  ServerSettings.Lines.Add('============================================');
end;

procedure TRecvForm.MsgServer1BeforeServerStop(Sender: TObject);
begin
  Timer1.Enabled := False;
  ServerSettings.Text := '';
end;

procedure TRecvForm.MsgServer1AfterConnect(Sender: TObject);
begin
  FillCounts;
  if cbConnected.Checked then
    FillGrids;
end;

procedure TRecvForm.MsgServer1AfterDisconnect(Sender: TObject);
begin
  FillCounts;
  if cbConnected.Checked then
    FillGrids;
end;

procedure TRecvForm.MsgServer1UserInfoChanged(const UserID: Cardinal);
begin
  FillCounts;
  if cbInfoChanged.Checked then
    FillGrids;
end;

procedure TRecvForm.MsgServer1UserRegistered(const UserID: Cardinal);
begin
  FillCounts;
  if cbRegistration.Checked then
    FillGrids;
end;

procedure TRecvForm.MsgServer1UserLogoff(const UserID: Cardinal);
begin
  FillCounts;
  if cbLogged.Checked then
    FillGrids;
end;

procedure TRecvForm.MsgServer1UserLogon(const UserID: Cardinal);
begin
  FillCounts;
  if cbLogged.Checked then
    FillGrids;
end;

procedure TRecvForm.IntervalChange(Sender: TObject);
begin
  if cbOnTimer.Checked then
   begin
    Timer1.Interval := StrToIntDef(Interval.Text,5000);
    Interval.Text := IntToStr(Timer1.Interval);
   end;
end;

procedure TRecvForm.PagesChanging(Sender: TObject; var AllowChange: Boolean);
begin
// fixed the bug with non-active page
  ServerIncoming.Lines.Clear;
  ServerIncoming.Lines.Add(IncomingMessages);
end;

function TRecvForm.GetFtpInfo : String;
var
  IniFile: TIcsIniFile;
  slList: TStringList;
  iSelected: Integer;
  sSelUserName, sSelPassword: string;
begin
  Result := '';

  if FileExists(FIniRoot + 'ftpaccounts.ini') then
  begin
    slList := TStringList.Create;
    IniFile := TIcsIniFile.Create(FIniRoot + 'ftpaccounts.ini');
    try
      IniFile.ReadSections(slList);

      // UserName, Password 선택
      iSelected := 1 + Random(slList.Count - 1);
      sSelUserName := slList[iSelected];
      sSelPassword := IniFile.ReadString(sSelUserName, KeyPassword, '');
    finally
      IniFile.Free;
      slList.Free;
    end;
  end
  else
    ShowMessage('ftpaccounts.ini 파일이 없습니다.');

  Result := sSelUserName + '|' + sSelPassword;
end;

procedure TRecvForm.RemoveDirofIP(AIpAddr, ASchedRealDiv, AStcDynDiv: string);
begin
  if IS_TEST then
  begin
    if AStcDynDiv = '01' then
    begin
      if ASchedRealDiv = '02' then
      begin
        if DirectoryExists(FOLDER_TEST + '\real\' + AIpAddr) then
          RemoveDirectoryAll(FOLDER_TEST + '\real\' + AIpAddr);
        if FileExists(FOLDER_TEST + '\real\' + AIpAddr + '_FileScan.txt') then
          DeleteFile(FOLDER_TEST + '\real\' + AIpAddr + '_FileScan.txt');
        if FileExists(FOLDER_TEST + '\real\' + AIpAddr + '_FTPErrorFiles.txt') then
          DeleteFile(FOLDER_TEST + '\real\' + AIpAddr + '_FTPErrorFiles.txt');
        if FileExists(FOLDER_TEST + '\real\' + AIpAddr + '_FTPErrorFiles.zip') then
          DeleteFile(FOLDER_TEST + '\real\' + AIpAddr + '_FTPErrorFiles.zip');
      end
      else
        if DirectoryExists(FOLDER_TEST + '\schedule\' + AIpAddr) then
          RemoveDirectoryAll(FOLDER_TEST + '\schedule\' + AIpAddr);
        if FileExists(FOLDER_TEST + '\schedule\' + AIpAddr + '_FileScan.txt') then
          DeleteFile(FOLDER_TEST + '\schedule\' + AIpAddr + '_FileScan.txt');
        if FileExists(FOLDER_TEST + '\schedule\' + AIpAddr + '_FTPErrorFiles.txt') then
          DeleteFile(FOLDER_TEST + '\schedule\' + AIpAddr + '_FTPErrorFiles.txt');
        if FileExists(FOLDER_TEST + '\schedule\' + AIpAddr + '_FTPErrorFiles.zip') then
          DeleteFile(FOLDER_TEST + '\schedule\' + AIpAddr + '_FTPErrorFiles.zip');
      begin
      end;
    end;
  end
  else
  begin
    if AStcDynDiv = '01' then
    begin
      if ASchedRealDiv = '02' then
      begin
        if DirectoryExists(FOLDER_RUN + '\real\' + AIpAddr) then
          RemoveDirectoryAll(FOLDER_RUN + '\real\' + AIpAddr);
        if FileExists(FOLDER_RUN + '\real\' + AIpAddr + '_FileScan.txt') then
          DeleteFile(FOLDER_RUN + '\real\' + AIpAddr + '_FileScan.txt');
        if FileExists(FOLDER_RUN + '\real\' + AIpAddr + '_FTPErrorFiles.txt') then
          DeleteFile(FOLDER_RUN + '\real\' + AIpAddr + '_FTPErrorFiles.txt');
        if FileExists(FOLDER_RUN + '\real\' + AIpAddr + '_FTPErrorFiles.zip') then
          DeleteFile(FOLDER_RUN + '\real\' + AIpAddr + '_FTPErrorFiles.zip');
      end
      else
        if DirectoryExists(FOLDER_RUN + '\schedule\' + AIpAddr) then
          RemoveDirectoryAll(FOLDER_RUN + '\schedule\' + AIpAddr);
        if FileExists(FOLDER_RUN + '\schedule\' + AIpAddr + '_FileScan.txt') then
          DeleteFile(FOLDER_RUN + '\schedule\' + AIpAddr + '_FileScan.txt');
        if FileExists(FOLDER_RUN + '\schedule\' + AIpAddr + '_FTPErrorFiles.txt') then
          DeleteFile(FOLDER_RUN + '\schedule\' + AIpAddr + '_FTPErrorFiles.txt');
        if FileExists(FOLDER_RUN + '\schedule\' + AIpAddr + '_FTPErrorFiles.zip') then
          DeleteFile(FOLDER_RUN + '\schedule\' + AIpAddr + '_FTPErrorFiles.zip');
      begin
      end;
    end;
  end;
end;

procedure TRecvForm.RemoveDirectoryAll(ADir: string);
var
  SR: TSearchRec;
begin
  if FindFirst(ADir + '\*', faAnyFile, SR) = 0 then
  begin
    try
      repeat
        if ((SR.Attr and faDirectory) = faDirectory) and not ((SR.Name = '.') or (SR.Name = '..')) then
        begin
          if DirectoryExists(ADir + '\' + SR.Name) then
          begin
            try
              RemoveDirectoryAll(ADir + '\' + SR.Name);
            except
            end;
          end;
        end
        else
        begin
          if FileExists(ADir + '\' + SR.Name) then
          begin
            try
              DeleteFile(ADir + '\' + SR.Name);
            except
            end;
          end;
        end;
      until (FindNext(SR) <> 0);
    finally
      FindClose(SR);
    end;
  end;

  try
    if DirectoryExists(Adir) then
      RemoveDir(ADir);
  except
  end;
end;

procedure TRecvForm.ClientDataAvailable(Sender : TObject; Error : Word);
var
  Buf    : array [0..127] of AnsiChar;
  Len    : Integer;
  i, j   : Integer;
  str    : AnsiString;
  Msg    : string;
  aMsg   : TArray<String>;
  aCode  : TArray<String>;
  dbTable: string;
begin
  Len := TWSocket(Sender).Receive(@Buf, Sizeof(Buf) - 1);
  if Len <= 0 then
    Exit;

  { Remove any trailing CR/LF}
  while (Len > 0) and (Buf[Len - 1] in [#13, #10]) do
    Dec(Len);
  { Nul terminate the data }
  Buf[Len] := #0;

  if (Buf[0] = #0) and (Buf[1] > #0) then
  begin
    Msg := '';
    for i := 2 to Len do
    begin
      Msg := Msg + Buf[i];
    end;
//    ShowMessage(Msg);
//    Msg:= 'SENDER=WAS|SCHED_REAL_DIV=02|DEGREE=1|DEGREE_SEQ=1|STC_DYN_DIV=01';
    aMsg := Msg.Split(['|']);

    for i := 0 to Length(aMsg) - 1 do
    begin
      aCode := aMsg[i].Split(['=']);
      //SENDER=WAS|SCHED_REAL_DIV=02|DEGREE=1|DEGREE_SEQ=1|STC_DYN_DIV=01
      //SENDER=WAS|SCHED_REAL_DIV=01|DEGREE=1|DEGREE_SEQ=2|STC_DYN_DIV=02|MOD_CLT_STRT_DM2=000000|MOD_CLT_END_DM2=010000
      //SENDER=WAS|SCHED_REAL_DIV=02|DEGREE=1|DEGREE_SEQ=1|STC_DYN_DIV=01|CLT_STRT_DM=20141127000000|CLT_END_DM=20141128010000
      if Pos(aCode[0], 'SENDER') > 0                then FSender        := aCode[1]
      else if Pos(aCode[0], 'SCHED_REAL_DIV') > 0   then FSchedRealDiv  := aCode[1]
      else if Pos(aCode[0], 'DEGREE') > 0           then FDegree        := StrToInt(aCode[1])
      else if Pos(aCode[0], 'DEGREE_SEQ') > 0       then FDegreeSeq     := StrToInt(aCode[1])
      else if Pos(aCode[0], 'STC_DYN_DIV') > 0      then FStcDynDiv     := aCode[1]
      else if Pos(aCode[0], 'CLT_STRT_DM') > 0      then FCltStrtDm     := aCode[1]
      else if Pos(aCode[0], 'CLT_END_DM') > 0       then FCltEndDm      := aCode[1]
      else if Pos(aCode[0], 'MOD_CLT_STRT_DM2') > 0 then FModCltStrtDm2 := aCode[1]
      else if Pos(aCode[0], 'MOD_SLT_END_DM2') > 0  then FModCltEndDm2  := aCode[1];
    end;

    // WAS에서 받은 메시지만 처리
    if FSender = 'WAS' then
    begin
      // SCHED_REAL_DIV에 따라서 다른 함수 호출
      if FSchedRealDiv = '02' then
        ExecAgent(FSchedRealDiv, FStcDynDiv, FDegree, FDegreeSeq)
      else
        ExecSchedAgent(FSchedRealDiv, FStcDynDiv, FDegree, FDegreeSeq, FCltStrtDm, FCltEndDm, FModCltStrtDm2, FModCltEndDm2);
    end;
  end;
end;

procedure TRecvForm.ClientSessionClosed(Sender: TObject; Error: Word);
var
    Cli : TWSocket;
    Itm : Integer;
    I: Integer;
begin
    Cli := Sender as TWSocket;

    Itm := FClients.IndexOf(Cli);

    if Itm >= 0 then
        FClients.Delete(Itm);
    { We can't destroy a TWSocket from a SessionClosed event handler.   }
    { So we post a message to delay destruction until we are out of the }
    { message handler.                                                  }
    PostMessage(Handle, WM_DESTROY_SOCKET, 0, LongInt(Cli));
    // 목록에서도 제거할것
end;

procedure TRecvForm.WMDestroySocket(var msg: TMessage);
begin
    TWSocket(msg.LParam).Destroy;
end;

procedure TRecvForm.WSocket1SessionAvailable(Sender: TObject; ErrCode: Word);
var
    NewClient : TWSocket;
begin
//    TWSocket(Sender).HSocket := WSocket1.Accept;
    NewClient := TWSocket.Create(nil);
    FClients.Add(NewClient);
    NewClient.LineMode            := TRUE;
    NewClient.OnDataAvailable     := ClientDataAvailable;
    NewClient.OnSessionClosed     := ClientSessionClosed;
    NewClient.HSocket             := WSocket1.Accept;
    NewClient.LingerOnOff         := wsLingerOn;
    NewClient.LingerTimeout       := 0;
    NewClient.SetLingerOption;
end;

// 실시간 에이전트
procedure TRecvForm.ExecAgent(ASchedRealDiv, AStcDynDiv: String; ADegree, ADegreeSeq: Integer);
var
  dbTable: string;
begin
  // DB에서 대상 IP확인 후 체크 실행
  with uqryVDI do
  begin
    Active := False;
    SQL.Clear;
    SQL.Add(' SELECT VIEW_1.ID, VIEW_1.IP                       ');
    SQL.Add('   FROM (SELECT ID, IP                             ');
    SQL.Add('           FROM COMEDI.AGENT_LIST) VIEW_1          ');
    SQL.Add('        (SELECT IP                                 ');
    SQL.Add('           FROM COMEDI.HSIT_VDI_EXEC_AGENT_LIST    ');
    SQL.Add('          WHERE SCHED_REAL_DIV = :SCHED_REAL_DIV   ');
    SQL.Add('            AND DEGREE = :DEGREE) VIEW_2           ');
    SQL.Add('  WHERE VIEW_1.IP = VIEW_2.IP                      ');
    SQL.Add('  ORDER BY VIEW_1.ID                               ');
    ParamByName('SCHED_REAL_DIV').AsString := ASchedRealDiv;
    ParamByName('DEGREE').AsInteger := ADegree;
    Active := True;

    // ShowMessage(SQL.Text);

    if not IsEmpty then
    begin
      First;

      repeat
        // ShowMessage(FieldByName('IP').AsString);
        // 온라인 사용자
        if MsgServer1.GetUserInfo(FieldByName('ID').AsInteger).Status = msgOnLine then
        begin
          // 해당IP 디렉토리 삭제
          if FieldByName('IP').AsString = '127.0.0.1' then
            RemoveDirofIP('172.24.33.151', ASchedRealDiv, AStcDynDiv)
          else
            RemoveDirofIP(FieldByName('IP').AsString, ASchedRealDiv, AStcDynDiv);

          // FTP접속 정보 (ftpaccount.ini로 부터 랜덤하게 가져옴) GetFtpInfo = sSelUserName + '|' + sSelPassword
          // 메시지 전송
          MsgServer1.SendMessage(Cardinal(FieldByName('ID').AsInteger), 'FILESCAN|' + GetFtpInfo + '|' + ASchedRealDiv + '|' + AStcDynDiv + '|' + IntToStr(ADegree) + '|' + IntToStr(ADegreeSeq) + '|');
          FRunCount := FRunCount + 1;
        end;

        Next;
      until Eof;

      // PROG_STAT varchar(2)     // 처리상태 : 01=서버수행시작, 02=서버수행종료, 03=타임아웃으로 에이전트 강제 연결종료, 04=이어받기 후 서버수행종료, 10=검색엔진수행시작, 11=검색엔진수행종료
      // SVR_EXEC_STRT_DT char(8) // Agent Server 수행시작일자
      // SVR_EXEC_STRT_TM char(6) // Agent Server 수행시작시간
      dbTable := 'COMEDI.HSIT_VDI_EXEC_STAT';
      SQL.Clear;
      SQL.Text := Format('update %s set PROG_STAT = :prog_stat, SVR_EXEC_STRT_DT = :svr_exec_strt_dt, SVR_EXEC_STRT_TM = :svr_exec_strt_tm where SCHED_REAL_DIV = %s and DEGREE = s', [dbTable, QuotedStr(ASchedRealDiv), IntToStr(ADegree)]);
      ParamByName('prog_stat').AsString       := '02';
      ParamByName('svr_exec_strt_dt').AsString := FormatDateTime('yyyymmdd', Now);
      ParamByName('svr_exec_strt_tm').AsString := FormatDateTime('hhnnss', Now);

      ExecSQL;

      Active := False;
    end;
  end;
end;

// 스케쥴 에이전트
procedure TRecvForm.ExecSchedAgent(ASchedRealDiv, AStcDynDiv: String; ADegree, ADegreeSeq: Integer; ACltStrtDm, ACltEndDm, AModCltStrtDm2, AModCltEndDm2: string);
var
  dbTable: string;
begin
  // DB에서 대상 IP확인 후 체크 실행
  with uqryVDI do
  begin
    Active := False;
    SQL.Clear;
    SQL.Add(' SELECT VIEW_1.ID, VIEW_1.IP                       ');
    SQL.Add('   FROM (SELECT ID, IP                             ');
    SQL.Add('           FROM COMEDI.AGENT_LIST) VIEW_1          ');
    SQL.Add('        (SELECT IP                                 ');
    SQL.Add('           FROM COMEDI.HSIT_VDI_EXEC_AGENT_LIST    ');
    SQL.Add('          WHERE SCHED_REAL_DIV = :SCHED_REAL_DIV   ');
    SQL.Add('            AND DEGREE = :DEGREE) VIEW_2           ');
    SQL.Add('  WHERE VIEW_1.IP = VIEW_2.IP                      ');
    SQL.Add('  ORDER BY VIEW_1.ID                               ');
    ParamByName('SCHED_REAL_DIV').AsString := ASchedRealDiv;
    ParamByName('DEGREE').AsInteger := ADegree;
    Active := True;

    // ShowMessage(SQL.Text);

    if not IsEmpty then
    begin
      First;

      repeat
        // ShowMessage(FieldByName('IP').AsString);
        // 온라인 사용자
        if MsgServer1.GetUserInfo(FieldByName('ID').AsInteger).Status = msgOnLine then
        begin
          // 해당IP 디렉토리 삭제 - 스케쥴은 전체 수집시만
          if AStcDynDiv = '01' then
          begin
            // 해당IP 디렉토리 삭제
            if FieldByName('IP').AsString = '127.0.0.1' then
              RemoveDirofIP('172.24.33.151', ASchedRealDiv, AStcDynDiv)
            else
              RemoveDirofIP(FieldByName('IP').AsString, ASchedRealDiv, AStcDynDiv);

            // FTP접속 정보 (ftpaccount.ini로 부터 랜덤하게 가져옴) GetFtpInfo = sSelUserName + '|' + sSelPassword
            // 메시지 전송
            MsgServer1.SendMessage(Cardinal(FieldByName('ID').AsInteger), 'SCHEDULE|' + GetFtpInfo + '|' + ASchedRealDiv + '|' + AStcDynDiv + '|' + IntToStr(ADegree) + '|' + IntToStr(ADegreeSeq) + '|');
          end
          else
            MsgServer1.SendMessage(Cardinal(FieldByName('ID').AsInteger), 'SCHEDULE|' + GetFtpInfo + '|' + ASchedRealDiv + '|' + AStcDynDiv + '|' + IntToStr(ADegree) + '|' + IntToStr(ADegreeSeq) + '|');
        end;

        Next;
      until Eof;

      Active := False;
    end;
  end;
end;


end.
