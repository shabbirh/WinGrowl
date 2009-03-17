unit uMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,
  IdGlobal, IdBaseComponent, IdComponent, IdUDPBase, IdUDPServer, IdSocketHandle,
  ufrmNotification, ExtCtrls;

type
  TfrmMain = class(TForm)
    IdUDPServer1: TIdUDPServer;
    lstLog: TListBox;
    Button1: TButton;
    tmrHoover: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure IdUDPServer1Status(ASender: TObject;
      const AStatus: TIdStatus; const AStatusText: String);
    procedure IdUDPServer1UDPRead(Sender: TObject; AData: TBytes;
      ABinding: TIdSocketHandle);
    procedure Button1Click(Sender: TObject);
    procedure tmrHooverTimer(Sender: TObject);
  private
    { Private declarations }
    FNotifications : TNotificationList;
  public
    { Public declarations }
    Procedure Log(s: String; a : Array Of Const);
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.DFM}

Uses
  uGrowlTypes,
  md5;

{ TForm1 }

procedure TfrmMain.Log(s: String; a : Array Of Const);
begin
  lstLog.Items.Add(Format(s, a));
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  FNotifications := TNotificationList.Create();
  IdUDPServer1.Active := True;
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
    GPacket := TGrowlPacket.Create(AData, '');

    Case GPacket.Header.PacketType Of
      GROWL_TYPE_REGISTRATION: Begin
        RegPacket := GPacket.GetRegistractionPacket();
        Log('Got a reg packet from %s', [RegPacket.AppName]);
        Log('Notifications: '#13#10+RegPacket.Notifications.Text, []);
      End;

      GROWL_TYPE_NOTIFICATION: Begin
        Log('Got a notify packet', []);
        NotPacket := GPacket.GetNotificationPacket();
        Log(NotPacket.Notification, []);
        Log(NotPacket.Title, []);
        Log(NotPacket.Description, []);
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

procedure TfrmMain.Button1Click(Sender: TObject);
Var
  frmNotification : TfrmNotification;
begin
  frmNotification := TfrmNotification.Create(Self, 'Title', 'Description');
  frmNotification.Show();
  FNotifications.Add(frmNotification);
end;

procedure TfrmMain.tmrHooverTimer(Sender: TObject);
Var
  x : Integer;
begin
  // Clean up the old notifications...
  For x := (FNotifications.Count - 1) DownTo 0 Do
  Begin
    If (FNotifications.Items[x].BirthTime < (Now() - EncodeTime(0, 0, 3, 0))) Then
    Begin
      If (FNotifications.Items[x].Visible) Then
      Begin
        Log('Hiding notification %s', [FNotifications.Items[x].lblTitle.Caption]);
        FNotifications.Items[x].Close();
      End Else Begin
        Log('Removing notification %s', [FNotifications.Items[x].lblTitle.Caption]);
        FNotifications.Items[x].Free();
        FNotifications.Delete(x);
      End;
    End;
  End;
end;

end.
