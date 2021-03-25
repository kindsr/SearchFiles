[Messages]

; SetupWindowTitle=%1 3 (Build 629)

SetupWindowTitle=설치 - %1
SetupAppTitle=설치
UninstallAppTitle=제거
UninstallAppFullTitle=%1 제거
SetupLdrStartupMessage=이 프로그램은 %1을(를) 설치할 것입니다. 계속 하시겠습니까?
LdrCannotCreateTemp=임시 파일을 생성할 수 없습니다. 설치가 중단되었습니다.
LdrCannotExecTemp=임시 폴더 내의 파일을 실행할 수 없습니다. 설치가 중단되었습니다.

; *** Setup common messages
ExitSetupTitle=설치 종료
ExitSetupMessage=설치가 아직 끝나지 않았습니다. 지금 종료하시면, 프로그램은 설치되지 않을 것입니다.%n%n설치를 완료하기 위해선 설치 프로그램을 다시 실행해야 합니다.%n%n설치를 종료하시겠습니까?

; *** Buttons
ButtonBack=< 뒤로(&B)
ButtonNext=다음(&N) >
ButtonInstall=설치(&I)
ButtonOK=확인
ButtonCancel=취소
ButtonYes=예(&Y)
ButtonYesToAll=모두 예(&A)
ButtonNo=아니요(&N)
ButtonNoToAll=모두 아니요(&O)
ButtonFinish=완료(&F)
ButtonBrowse=찾아보기(&B)...
ButtonWizardBrowse=찾아보기(&R)...
ButtonNewFolder=폴더 만들기(&M)

; *** Common wizard text
ClickNext=설치를 계속 하시려면 "다음"을, 종료하시려면 "취소"를 클릭하십시오.
BeveledLabel=
BrowseDialogTitle=폴더 찾아보기
BrowseDialogLabel=아래의 목록에서 폴더를 선택하고 "확인"을 클릭하십시오.
NewFolderName=새 폴더

; *** "Welcome" wizard page
WelcomeLabel1=[name] 의 설치에 오신 것을 환영합니다
WelcomeLabel2=이 프로그램은 [name/ver] 을(를) 설치할 것입니다.%n%n설치를 계속하시기 전에 실행 중인 모든 프로그램의 종료를 권합니다.

; *** "Select Destination Location" wizard page
WizardSelectDir=설치 경로 선택
SelectDirDesc=[name]을 설치할 경로를 선택하십시오.
SelectDirLabel2=[name]을 설치할 경로를 선택한 후 "다음" 버튼을 클릭하십시오.
DiskSpaceMBLabel=[mb] MB의 디스크 공간이 필요합니다.
ToUNCPathname=선택하신 네트워크 경로로 설치할 수 없습니다. 네트워크 드라이브에 설치하시려면, 네트워크 드라이브에 접근할 수 있어야 합니다.
InvalidPath=드라이브 문자를 포함한 전체 경로를 입력하셔야 합니다. 예:%n%nC:\APP%n%n 네트워크 드라이브의 예:%n%n\\server\share
InvalidDrive=설치할 드라이브나 네트워크 경로가 존재하지 않거나 접근할 수 없습니다. 다른 경로를 선택하십시오.
DiskSpaceWarningTitle=디스크 공간이 충분하지 않습니다.
DiskSpaceWarning=이 프로그램을 설치하는 데에 최소 %1 KB 의 여유공간이 필요하나, 선택하신 드라이브는 %2 KB 만 사용 가능합니다.%n%n그래도 계속하시겠습니까?
BadDirName32=경로명에 다음 기호를 사용할수 없습니다.%n%n%1
DirExistsTitle=설치 경로
DirExists=다음 경로가 이미 존재합니다.%n%n%1%n%n이 경로에 설치하시겠습니까?
DirDoesntExistTitle=설치 경로
DirDoesntExist=다음 경로를 찾을수 없습니다.%n%n%1%n%해당 경로를 새로 만드시겠습니까?

; *** "Select Components" wizard page
WizardSelectComponents=구성 요소 설치
SelectComponentsDesc=어떤 구성 요소를 설치하시겠습니까?
SelectComponentsLabel2=설치하고 싶은 구성 요소는 선택하시고, 설치하고 싶지 않은 구성 요소는 선택을 해제하십시오. 설치를 계속할 준비가 되셨으면 "다음"을 클릭하십시오.
FullInstallation=전체 설치
; if possible don't translate 'Compact' as 'Minimal' (I mean 'Minimal' in your language)
CompactInstallation=최소 설치
CustomInstallation=사용자 설치
NoUninstallWarningTitle=기존 구성 요소 존재
NoUninstallWarning=설치 프로그램이 다음 구성 요소가 이미 설치되어 있음을 발견했습니다.%n%n%1%n%n프로그램 제거 시 이 구성 요소 들은 제거되지 않을 것입니다.%n%n그래도 계속 하시겠습니까?
ComponentSize1=%1 KB
ComponentSize2=%1 MB
ComponentsDiskSpaceMBLabel=선택한 구성 요소 설치에 필요한 최소 용량: [mb] MB

; *** "Select Additional Tasks" wizard page
WizardSelectTasks=추가 사항 적용
SelectTasksDesc=어떤 사항을 추가로 적용하시겠습니까?
SelectTasksLabel2=[name] 의 설치 과정에서 추가로 적용하고자 하는 사항을 선택하시고, "다음"을 클릭하십시오.

; *** "Select Start Menu Folder" wizard page
WizardSelectProgramGroup=시작 메뉴에 등록
SelectStartMenuFolderDesc=시작 메뉴에 프로그램을 등록합니다.
;SelectStartMenuFolderLabel=시작 메뉴에 등록할 그룹명을 입력하시고 "다음"버튼을 클릭하십시오.
NoIconsCheck=아이콘을 생성할수 없습니다.
MustEnterGroupName=폴더명을 입력하여 주십시오.
BadGroupName=폴더명에 다음 기호를 사용할 수 없습니다.%n%n%1
NoProgramGroupCheck2=시작 메뉴에 폴더를 만들 수 없습니다.

; *** "Ready to Install" wizard page
WizardReady=설치 준비 완료
ReadyLabel1=[name] 을(를) 설치할 준비가 되었습니다.
ReadyLabel2a="설치"를 클릭하여 설치를 시작하시거나, "뒤로"를 클릭하여 설치 내용을 검토하거나 바꾸실 수 있습니다.
ReadyLabel2b="설치"를 클릭하여 설치를 시작하십시오.
ReadyMemoDir=설치할 경로:
ReadyMemoType=설치 종류::
ReadyMemoComponents=설치할 구성요소:
ReadyMemoGroup=시작 메뉴 폴더:
ReadyMemoTasks=추가로 적용되는 옵션:

; *** "Preparing to Install" wizard page
WizardPreparing=설치 준비 중...
PreparingDesc=설치 프로그램이 [name] 을(를) 설치할 준비를 하고 있습니다.
PreviousInstallNotCompleted=이전의 설치나 프로그램 제거 작업이 완료되지 않았습니다. 이전의 설치를 완료하기 위하여 컴퓨터를 재시작 할 필요가 있습니다.%n%n컴퓨터를 재시작 한 후, 설치 프로그램을 재시작하여 [name] 의 설치를 완료하십시오.
CannotContinue=설치를 계속할 수 없습니다. "취소"를 클릭하여 설치를 종료하십시오.

; *** "Installing" wizard page
WizardInstalling=설치 중
InstallingLabel=설치 프로그램이 [name] 을(를) 설치하는 동안 기다려 주십시오.

; *** "Setup Completed" wizard page
;WizardFinished=설치 완료
FinishedHeadingLabel=[name] 설치 완료
FinishedLabelNoIcons=설치 프로그램이 [name] 의 설치를 완료했습니다.
FinishedLabel=설치 프로그램이 [name] 의 설치를 완료했습니다. 설치된 바로 가기를 실행하시면 프로그램이 실행됩니다.
ClickFinish=완료"를 클릭하여 설치를 완료하십시오.
FinishedRestartLabel=[name] 의 설치를 완료하려면 시스템이 다시 시작되어야만 합니다. 지금 시스템을 다시 시작하시겠습니까?
FinishedRestartMessage=[name] 의 설치를 완료하려면 시스템이 다시 시작되어야만 합니다.%n%n지금 시스템을 다시 시작하시겠습니까?
ShowReadmeCheck=README 파일을 읽어보겠습니다.
YesRadio=예, 지금 시스템을 다시 시작하겠습니다(&Y)
NoRadio=아니요, 나중에 시스템을 다시 시작하겠습니다(&N)
RunEntryExec=%1 실행하기
RunEntryShellExec=%1 읽어보기

; *** Installation phase messages
SetupAborted=설치가 완료되지 않았습니다.%n%n문제를 해결하고 설치 프로그램을 다시 시작하십시오.
EntryAbortRetryIgnore=다음 중 선택하십시오

; *** Installation status messages
StatusCreateDirs=폴더 생성 중...
StatusExtractFiles=파일의 압축을 푸는 중...
StatusCreateIcons=바로 가기 생성 중...
StatusCreateIniEntries=INI 엔트리 생성 중...
StatusCreateRegistryEntries=레지스트리 키 생성 중...
StatusRegisterFiles=파일 등록 중...
StatusSavingUninstall=프로그램 제거 정보 저장 중...
StatusRunProgram=설치 마무리 중...
StatusRollback=설치 이전 상태로 되돌리는 중....

; *** Uninstaller messages
UninstallNotFound="%1" 파일이 존재하지 않습니다. 프로그램을 제거할 수 없습니다.
UninstallOpenError="%1" 파일을 열 수 없습니다. 프로그램을 제거할 수 없습니다
UninstallUnsupportedVer=프로그램 제거 정보 파일인 "%1" 이(가) 이 버전의 제거 프로그램이 인식할 수 없는 형식으로 되어 있습니다. 프로그램을 제거할 수 없습니다
UninstallUnknownEntry=알 수 없는 엔트리 (%1) 가 프로그램 제거 정보 파일에 기록되어 있습니다
ConfirmUninstall=%1 와(과) 그 구성 요소들을 완전히 제거하시겠습니까?
UninstallOnlyOnWin64=이 프로그램은 64비트 Windows 에서만 제거됩니다.
OnlyAdminCanUninstall=이 프로그램은 Administrator 권한이 있는 사용자만 제거하실 수 있습니다.
UninstallStatusLabel=%1 이(가) 제거되는 동안 기다려 주십시오.
UninstalledAll=%1 이(가) 완전히 제거되었습니다.
UninstalledMost=%1 의 제거가 끝났습니다.%n%n일부 항목은 제거할 수 없었습니다. 관련 항목들을 직접 제거하시기 바랍니다.
UninstalledAndNeedsRestart=%1 의 제거를 완료하려면, 컴퓨터가 다시 시작되어야 합니다.%n%n지금 컴퓨터를 다시 시작하시겠습니까?
UninstallDataCorrupted="%1" 파일이 손상되었습니다. 프로그램을 제거할 수 없습니다

; *** Uninstallation phase messages
ConfirmDeleteSharedFileTitle=공유 파일을 삭제하시겠습니까?
ConfirmDeleteSharedFile2=시스템은 다음 공유 파일이 어떤 프로그램에서도 사용되지 않음을 발견했습니다. 다음 공유 파일을 삭제하시겠습니까?%n%n만약 이 공유 파일들이 다른 프로그램들에 의해서 사용된다면, 이 공유 파일 삭제 후 다른 프로그램들이 제대로 작동하지 않을 수 있습니다. 확실하지 않다면 "아니요" 를 클릭하십시오. 파일을 남겨두어도 시스템에 영향을 끼치지 않습니다.
SharedFileNameLabel=파일 이름:
SharedFileLocationLabel=경로:
WizardUninstalling=설치 제거 상태
StatusUninstalling=%1 제거 중...

NameAndVersion=%1 버전 %2
AdditionalIcons=아이콘 생성:
CreateDesktopIcon=바탕 화면에 아이콘 생성(&D)
CreateQuickLaunchIcon=빠른 실행에 아이콘 생성(&Q)
ProgramOnTheWeb=웹 상의 %1
UninstallProgram=%1 제거
LaunchProgram=%1 실행
AssocFileExtension=%2 확장자를 %1 에 연결(&A)
AssocingFileExtension=%2 확장자를 %1 에 연결 중...

[CustomMessages]

DialogFontName=굴림
DialogFontSize=9
WelcomeFontName=굴림
WelcomeFontSize=12
TitleFontName=굴림
TitleFontSize=29
CopyrightFontName=굴림
CopyrightFontSize=9

[LangOptions]

[Setup]
AppVersion=0.1
AppCopyright=
AppName=Agent 0.1a
AppVerName=Agent 0.1a
AppPublisher=
AppPublisherURL=http://www.
AppSupportURL=http://www.
AppUpdatesURL=http://www.
DefaultDirName={pf}\Agent
DefaultGroupName=Agent
OutputBaseFilename=Agent-Setup

DisableStartupPrompt=yes
DisableProgramGroupPage=yes

;WizardImageFile=WizModernImage.bmp
;WizardSmallImageFile=WizModernSmallImage.bmp

; uncomment the following line if you want your installation to run on NT 3.51 too.
; MinVersion=4,3.51

Compression=lzma/ultra

[Tasks]
; MinVersion: 4,4
; MinVersion: 4,4

[Files]
Source: Agent.exe; DestDir: {app}
Source: Agent.ini; DestDir: {app}
Source: InstallSVC.bat; DestDir: {app}
Source: SvcAgent.exe; DestDir: {app}
Source: UninstallSVC.bat; DestDir: {app}

[Run]
Filename: {app}\InstallSVC.bat; WorkingDir: {app}; Flags: postinstall
[UninstallDelete]
Name: {app}\Agent.exe; Type: files
Name: {app}\Agent.ini; Type: files
Name: {app}\InstallSVC.bat; Type: files
Name: {app}\SvcAgent.exe; Type: files
Name: {app}\UninstallSVC.bat; Type: files
Name: {app}\Log; Type: filesandordirs
