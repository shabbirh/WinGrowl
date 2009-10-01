program WinGrowlCLI;

uses
  uMutableGrowlRegistrationPacket,
  uMutableGrowlNotificationPacket,
  IdUDPClient,
  Classes;

{$R *.RES}

Var
  R : TMutableGrowlRegistrationPacket;
  N : TMutableGrowlNotificationPacket;
  U : TIdUDPClient;
  RS, NS : TStream;
  D : String;
  x : Integer;
begin

  R := TMutableGrowlRegistrationPacket.Create();
  R.AppName := ParamStr(1);
  R.Defaults.Add(R.Notifications.Add(ParamStr(2)));
  R.Password := 'password';

  N := TMutableGrowlNotificationPacket.Create();
  N.AppName := R.AppName;
  N.Notification := ParamStr(2);
  N.Title := ParamStr(3);
  N.Description := ParamStr(4)+' ';
  For x := 5 To ParamCount Do
    N.Description := N.Description + ParamStr(x); 
  N.Password := R.Password;

  U := TIdUDPClient.Create();
  U.Host := '127.0.0.1';
  U.Port := 9887;

  RS := R.GetPacket();
  SetLength(D, RS.Size);
  RS.ReadBuffer(D[1], RS.Size);
  RS.Free();
  R.Free();

  U.Send(D);

  NS := N.GetPacket();
  SetLength(D, NS.Size);
  NS.ReadBuffer(D[1], NS.Size);
  NS.Free();
  N.Free();

  U.Send(D);

  U.Free();
end.