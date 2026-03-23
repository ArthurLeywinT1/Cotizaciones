[Setup]
AppName=Cotizaciones
AppVersion=1.0
DefaultDirName={userappdata}\Cotizaciones
DefaultGroupName=Cotizaciones
DisableDirPage=no
OutputDir=output
OutputBaseFilename=CotizacionesSetup
Compression=lzma
SolidCompression=yes
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs ignoreversion

[Icons]
Name: "{group}\Cotizaciones"; Filename: "{app}\cotizador.exe"
Name: "{commondesktop}\Cotizaciones"; Filename: "{app}\cotizador.exe"

[Run]
Filename: "{app}\cotizador.exe"; Description: "Abrir Cotizaciones"; Flags: nowait postinstall skipifsilent
