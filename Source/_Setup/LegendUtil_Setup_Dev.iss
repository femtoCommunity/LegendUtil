; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "LegendUtil Dev Build"
#define MyAppVersion "0.1.0"
#define MyAppReleaseChannel "dev"
#define MyAppReleaseNumber "20230206.024847"
#define MyAppVersionText "0.1.0-dev.20230206.024847"
#define MyAppPublisher "femto Community Software Development Team"
#define MyAppCopyrighter "Milkeyyy"
#define MyAppURL "https://github.com/femtoCommunity/LegendUtil"
#define MyAppSupportURL "https://discord.gg/bMf9dDjndC"
#define MyAppExeName "LegendUtil.exe"
#define MyAppAssocName MyAppName + " File"
#define MyAppAssocExt ".myp"
#define MyAppAssocKey StringChange(MyAppAssocName, " ", "") + MyAppAssocExt

[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{8656120F-49DA-42CC-BFD2-BD58D15DE0BD}
AppName={#MyAppName}
AppVersion={#MyAppVersionText}
VersionInfoVersion={#MyAppVersion}
AppVerName={#MyAppName}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppCopyright=Copyright (C) 2023 {#MyAppCopyrighter}
AppSupportURL={#MyAppSupportURL}
AppUpdatesURL={#MyAppURL}
DefaultDialogFontName=Yu Gothic UI
DefaultDirName={autopf}\{#MyAppName}
DisableDirPage=yes
ChangesAssociations=yes
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
LicenseFile=..\..\_Pack\LegendUtil\License.txt
DisableWelcomePage=no
WizardImageStretch=yes
WizardImageFile=..\..\Resources\Logo\LegendUtil_Setup_Banner_White.bmp
WizardSmallImageFile=..\..\Resources\Logo\LegendUtil_Icon_128x128.bmp
; Remove the following line to run in administrative install mode (install for all users.)
PrivilegesRequired=lowest
OutputDir=..\..\_Pack
OutputBaseFilename=LegendUtil_Setup
SetupIconFile=..\..\Resources\Logo\LegendUtil_Icon.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "japanese"; MessagesFile: "compiler:Languages\Japanese.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "..\..\_Pack\LegendUtil\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\..\_Pack\LegendUtil\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Registry]
Root: HKA; Subkey: "Software\Classes\{#MyAppAssocExt}\OpenWithProgids"; ValueType: string; ValueName: "{#MyAppAssocKey}"; ValueData: ""; Flags: uninsdeletevalue
Root: HKA; Subkey: "Software\Classes\{#MyAppAssocKey}"; ValueType: string; ValueName: ""; ValueData: "{#MyAppAssocName}"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\{#MyAppAssocKey}\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\{#MyAppExeName},0"
Root: HKA; Subkey: "Software\Classes\{#MyAppAssocKey}\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\{#MyAppExeName}"" ""%1"""
Root: HKA; Subkey: "Software\Classes\Applications\{#MyAppExeName}\SupportedTypes"; ValueType: string; ValueName: ".myp"; ValueData: ""

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent
Filename: "{app}\{#MyAppExeName}"; Parameters: "/AfterUpdate {#MyAppVersion}" ; Flags: nowait skipifnotsilent

[Messages]
BeveledLabel={#MyAppName} Setup [App Version: {#MyAppVersionText}]
