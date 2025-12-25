[Setup]
AppName=Cotizador
AppVersion=1.0
DefaultDirName={pf}\Cotizador
DefaultGroupName=Cotizador
OutputDir=output
OutputBaseFilename=CotizadorSetup
Compression=lzma
SolidCompression=yes
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs

[Icons]
Name: "{group}\Cotizador"; Filename: "{app}\cotizador.exe"
Name: "{commondesktop}\Cotizador"; Filename: "{app}\cotizador.exe"

[Run]
Filename: "{app}\cotizador.exe"; Description: "Abrir Cotizador"; Flags: nowait postinstall skipifsilent