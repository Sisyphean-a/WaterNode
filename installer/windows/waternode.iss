#define MyAppName "WaterNode"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "WaterNode"
#define MyAppExeName "waternode.exe"
#define BuildDir "..\..\build\windows\x64\runner\Release"
#define OutputDir "..\..\dist\windows"

[Setup]
AppId={{8C5B40BB-27D0-42A0-9D9B-2E040F6F7C30}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\WaterNode
DefaultGroupName=WaterNode
DisableProgramGroupPage=yes
OutputDir={#OutputDir}
OutputBaseFilename=WaterNode Setup
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
ArchitecturesInstallIn64BitMode=x64compatible
UninstallDisplayIcon={app}\{#MyAppExeName}
SetupIconFile=..\..\windows\runner\resources\app_icon.ico

[Languages]
Name: "chinesesimp"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "创建桌面快捷方式"; GroupDescription: "附加任务:"

[Files]
Source: "{#BuildDir}\*"; DestDir: "{app}"; Excludes: "*.pdb,*.lib,*.exp,*.ilk"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\WaterNode"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\WaterNode"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "启动 WaterNode"; Flags: nowait postinstall skipifsilent
