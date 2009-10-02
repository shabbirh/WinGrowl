program WinGrowl;

uses
  Forms,
  uMain in 'uMain.pas' {frmMain},
  uGrowlTypes in 'uGrowlTypes.pas',
  md5 in 'md5.pas',
  uIntegerList in 'uIntegerList.pas',
  ufrmNotification in 'ufrmNotification.pas' {frmNotification},
  uNotificationList in 'uNotificationList.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.ShowMainForm := False;
  Application.Title := 'WinGrowl';
  Application.CreateForm(TfrmMain, frmMain);
  Application.OnMinimize := frmMain.OnMinimize;
  Application.Run;
end.