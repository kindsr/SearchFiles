program MDHierarchy;

{$R *.res}

uses
  System.SysUtils, System.Classes, WinApi.Windows, Vcl.Dialogs;
  
function SetFileDateTime(Const FileName : String; Const FileDate : TDateTime): Boolean;
var
  FileHandle : THandle;
  FileSetDateResult : Integer;
begin
  try
    try
      FileHandle := FileOpen
          (FileName,
           fmOpenWrite OR fmShareDenyNone);
      if FileHandle > 0 Then
      begin
        FileSetDateResult :=
          FileSetDate(
            FileHandle,
            DatetimeToFileDate(FileDate));
          result := (FileSetDateResult = 0);
      end;
    except
      Result := False;
    end;
  finally
    FileClose(FileHandle);
  end;
end;

procedure MakeDirectory(AIpAddr, AFolder: string);
var
  sLogFileName: string;
  slList: TStringList;
  aFilePath: TArray<String>;
  i, repNo: Integer;
  sSeq, sFileName, sDateTime: string;
  sIpFolder, sErrFolder: string;
  sSrcFileName, sDestPath, sDestFileName: string;
begin
    if AIpAddr = '127.0.0.1' then
      AIpAddr := '172.24.33.151';
      
    sIpFolder := AFolder + '\' + AIpAddr;
    sLogFileName := AFolder + '\' + AIpAddr + '_FileScan.txt';
    sErrFolder := AFolder + '\ErrorFiles\' + AIpAddr;
    
    if not DirectoryExists(sErrFolder) then
        ForceDirectories(sErrFolder);

    slList := TStringList.Create;
    slList.LoadFromFile(sLogFileName);
  
    for i := 0 to slList.Count - 1 do
    begin
        aFilePath := slList.Strings[i].Split(['|']);
        sSeq := Trim(aFilePath[1]);
        sFileName := Trim(aFilePath[2]);
        sDateTime := Trim(aFilePath[3]);
    
        sSrcFileName := sIpFolder + '\' + sSeq + ExtractFileExt(sFileName);
        sDestPath := sIpFolder + '\' + StringReplace(ExtractFilePath(sFileName),':','',[rfReplaceAll]);
        sDestFileName := sDestPath + ExtractFileName(sFileName);
    
        repNo := 0;
        while not FileExists(sDestFileName) do
        begin
            if repNo > 2 then
                break;
            ForceDirectories(sDestPath);
            CopyFile(PChar(sSrcFileName), PChar(sDestFileName), False);
            Inc(repNo);
        end;
        
        if FileExists(sDestFileName) then
        begin
            SetFileDateTime(sDestFileName, StrToDateTime(sDateTime));
            
            if FileExists(sSrcFileName) then
            begin
                CopyFile(PChar(sSrcFileName), PChar(sErrFolder), False);
                DeleteFile(PChar(sSrcFileName));
            end;
        end;
    end;

    FreeAndNil(slList);
end;

var
  FIpAddr: string;
  FFolder: string;
begin
  try
    { TODO -oUser -cConsole Main : Insert code here }
    if ParamCount >= 2 then
    begin
      FIpAddr := ParamStr(1);
      FFolder := ParamStr(2);
      
      MakeDirectory(FIpAddr, FFolder);
    end;
  except
//    on E: Exception do
//      Writeln(E.ClassName, ': ', E.Message);
  end;
end.