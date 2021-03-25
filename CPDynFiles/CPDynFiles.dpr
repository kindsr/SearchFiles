program CPDynFiles;

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

procedure SyncDynFile(AIpAddr, AFolder, AFileName: string);
var
  sLogFileName: string;
  slList: TStringList;
  aFilePath: TArray<String>;
  i, repNo: Integer;
  sSeq, sFileName, sDateTime, sStatus: string;
  sIpFolder: string;
  sSrcFileName, sDestPath, sDestFileName: string;
begin
    if AIpAddr = '127.0.0.1' then
      AIpAddr := '172.24.33.151';

    sIpFolder := AFolder + '\dyn\' + AIpAddr;
    sLogFileName := AFolder + '\dyn\' + ExtractFileName(AFileName);

    slList := TStringList.Create;
    slList.LoadFromFile(sLogFileName);

    for i := 0 to slList.Count - 1 do
    begin
        aFilePath := slList.Strings[i].Split(['|']);
        sSeq := Trim(aFilePath[1]);
        sFileName := Trim(aFilePath[2]);
        sDateTime := Trim(aFilePath[3]);
        sStatus   := Trim(aFilePath[4]);

        sSrcFileName := sIpFolder + '\' + sSeq + ExtractFileExt(sFileName);
        sDestPath := AFolder + '\' + AIpAddr + '\' + StringReplace(ExtractFilePath(sFileName),':','',[rfReplaceAll]);
        sDestFileName := sDestPath + ExtractFileName(sFileName);

        //sStatus 가 Removed, OldName이면 삭제 New, Modified, NewName이면 삭제 후 복사
        if (sStatus = 'Removed') or (sStatus = 'OldName') then
        begin
            try
                if FileExists(sDestFileName) then
                    DeleteFile(PChar(sDestFileName));
                if FileExists(sSrcFileName) then
                    DeleteFile(PChar(sSrcFileName));
            except
            end;
        end
        else if (sStatus = 'New') or (sStatus = 'Modified') or (sStatus = 'NewName') then
        begin
            try
                ForceDirectories(sDestPath);
                if FileExists(sDestFileName) then
                    DeleteFile(PChar(sDestFileName));
                CopyFile(PChar(sSrcFileName), PChar(sDestFileName), False);
                if (FileExists(sDestFileName)) and (sDateTime <> '') then
                    SetFileDateTime(sDestFileName, StrToDateTime(sDateTime));
                if FileExists(sSrcFileName) then
                    DeleteFile(PChar(sSrcFileName));
            except
            end;
        end;
    end;

    FreeAndNil(slList);
end;

var
  FIpAddr: string;
  FFolder: string;
  FFileName: string;
begin
  try
    { TODO -oUser -cConsole Main : Insert code here }
    if ParamCount >= 3 then
    begin
      FIpAddr := ParamStr(1);
      FFolder := ParamStr(2);
      FFileName := ParamStr(3);

      SyncDynFile(FIpAddr, FFolder, FFileName);
    end;
  except
//    on E: Exception do
//      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
