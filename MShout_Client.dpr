program MShout_Client;

uses
  Forms,
  Windows,
  Messages,
  UClient in 'UClient.pas' {frmMshoutClient},
  MShoutProtocol in '..\Lib\MShoutProtocol\MShoutProtocol.pas',
  Usuario in '..\MShout\Usuario.pas',
  UAlerta in 'UAlerta.pas' {frmAlerta},
  UListVersoes in 'UListVersoes.pas' {frmListVersoes},
  UGlobal in '..\MShout\UGlobal.pas';

{$R *.res}
var
  H : HWnd;
begin
  H := FindWindow('TfrmMshoutClient', nil);
  {$IFNDEF DEBUG}
  if H <> 0 then
  begin
      Windows.SendMessage(H, WM_SysCommand, SC_Maximize, 0);
  End Else
  {$ENDIF}
  Begin
      Application.Initialize;
      Application.CreateForm(TfrmMshoutClient, frmMshoutClient);
      Application.Run;
  end;
end.
