unit uMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ufrmNotification, ExtCtrls, ShellAPI,
  // All these are needed by Indy to compile.
  IdBaseComponent, IdComponent, IdUDPBase, IdUDPServer, IdGlobal, IdSocketHandle;

Const
  WM_NOTIFY_ICON = WM_USER+100;

type
  TfrmMain = class(TForm)
    IdUDPServer1: TIdUDPServer;
    lstLog: TListBox;
    btnTest: TButton;
    btnDelayedTest: TButton;
    Timer1: TTimer;
    btnClearLog: TButton;
    procedure FormCreate(Sender: TObject);
    procedure IdUDPServer1Status(ASender: TObject;
      const AStatus: TIdStatus; const AStatusText: String);
    procedure IdUDPServer1UDPRead(Sender: TObject; AData: TBytes;
      ABinding: TIdSocketHandle);
    procedure btnTestClick(Sender: TObject);
    procedure btnDelayedTestClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure btnClearLogClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    Procedure OnMinimize(Sender : TObject);
    Procedure OnNotifyIcon(Var Message : TMessage); Message WM_NOTIFY_ICON;
  private
    { Private declarations }
    FLogFile : TFileStream;
    FNotifyIconData : TNotifyIconData;
  public
    { Public declarations }
    Procedure Log(s: String; a : Array Of Const);
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.DFM}
{$R ..\Shared\WinXP.RES}

Uses
  uGrowlTypes,
  md5;

{ TForm1 }

procedure TfrmMain.Log(s: String; a : Array Of Const);
Var
  LogStr : String;
begin
  LogStr := Format(s, a);
  lstLog.Items.Add(LogStr);
  lstLog.ItemIndex := lstLog.Items.Count - 1;

  LogStr := LogStr+#13#10;
  FLogFile.WriteBuffer(LogStr[1], Length(LogStr));
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  If (Not FileExists('Log.txt')) Then
    TFileStream.Create('Log.txt', fmCreate).Free();

  FLogFile := TFileStream.Create('Log.txt', fmOpenWrite Or fmShareDenyWrite);
  FLogFile.Position := FLogFile.Size;
  
  IdUDPServer1.Active := True;
  With FNotifyIconData Do
  Begin
    cbSize := SizeOf(FNotifyIconData);
    Wnd := Handle;
    uID := 1;
    uFlags := NIF_TIP Or NIF_MESSAGE Or NIF_ICON;
    uCallbackMessage := WM_NOTIFY_ICON;
    hIcon := Application.Icon.Handle;
    szTip := 'WinGrowl';
  End; {With}

  Shell_NotifyIcon(NIM_ADD, @FNotifyIconData);

  TfrmNotification.Factory('WinGrowl - Loaded', 'WinGrowl is now running');
end;

procedure TfrmMain.IdUDPServer1Status(ASender: TObject;
  const AStatus: TIdStatus; const AStatusText: String);
begin
  Log(AStatusText, []);
end;

procedure TfrmMain.IdUDPServer1UDPRead(Sender: TObject; AData: TBytes; ABinding: TIdSocketHandle);
Var
  GPacket : TGrowlPacket;
  RegPacket : TGrowlRegistrationPacket;
  NotPacket : TGrowlNotificationPacket;
begin
  GPacket := Nil;
  RegPacket := Nil;
  NotPacket := Nil;
  
  Try
    Log('Received a %d byte packet:', [Length(AData)]);
    Log('%s', [BytesToString(AData)]);
    GPacket := TGrowlPacket.Create(AData, 'password');

    Case GPacket.Header.PacketType Of
      GROWL_TYPE_REGISTRATION: Begin
        RegPacket := GPacket.GetRegistractionPacket();
        Log('Got a reg packet from %s', [RegPacket.AppName]);
        Log('Notifications: '#13#10+RegPacket.Notifications.Text, []);
      End;

      GROWL_TYPE_NOTIFICATION: Begin
        Log('Got a notify packet', []);
        NotPacket := GPacket.GetNotificationPacket();
        TfrmNotification.Factory(NotPacket.Title+' - '+NotPacket.Notification, NotPacket.Description);
      End;
    End; {Case}
  Except
    On E: Exception Do
    Begin
      Log('Exception: %s', [E.Message]);
      
      If (GPacket <> Nil) Then
        GPacket.Free();

      If (RegPacket <> Nil) Then
        RegPacket.Free();

      If (NotPacket <> Nil) Then
        NotPacket.Free();
    End;
  End;
end;

procedure TfrmMain.btnTestClick(Sender: TObject);
begin
  TfrmNotification.Factory('Test', 'Testing the growl');
end;

procedure TfrmMain.btnDelayedTestClick(Sender: TObject);
begin
  Timer1.Enabled := True;
end;

procedure TfrmMain.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;
  btnTest.Click();
end;

procedure TfrmMain.btnClearLogClick(Sender: TObject);
begin
  lstLog.Clear();
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  FLogFile.Free();
  Shell_NotifyIcon(NIM_DELETE, @FNotifyIconData);
end;

procedure TfrmMain.OnMinimize(Sender: TObject);
begin
  Hide();
  ShowWindow(Application.Handle, SW_HIDE);
end;

procedure TfrmMain.OnNotifyIcon(var Message: TMessage);
begin
   If (Message.LParam = WM_LBUTTONDBLCLK) Then
   Begin
    ShowWindow(Application.Handle, SW_SHOW);
    Show();
    BringToFront();
    Application.BringToFront();
    Application.Restore();
  End;
end;

end.
