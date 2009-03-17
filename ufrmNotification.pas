unit ufrmNotification;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Gradient, StdCtrls, Contnrs;

type
  TfrmNotification = class(TForm)
    Gradient1: TGradient;
    lblTitle: TLabel;
    lblDescription: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormClick(Sender: TObject);
  private
    { Private declarations }
    FBirthTime : TDateTime;
  public
    { Public declarations }
    Constructor Create(AOwner : TComponent; Title, Description : String); Reintroduce;
    Procedure CreateParams(var Params: TCreateParams); override;
    Procedure Show; Reintroduce;

    Property BirthTime : TDateTime Read FBirthTime;
  end;

  TNotificationList = Class(TList)
  private
  protected
    function Get(Index: Integer): TfrmNotification;
    procedure Put(Index: Integer; Item: TfrmNotification);
  public
    function Add(Item: TfrmNotification): Integer;
    property Items[Index: Integer]: TfrmNotification read Get write Put; default;
  End; {TNotificationList}

implementation

{$R *.DFM}

Uses
  uMain;

Const
  lwColorKey : Integer = $1;
  lwAlpha : Integer = $2;

Function SetLayeredWindowAttributes(Hwnd : THandle; crKey : Integer; Alpha : Byte; dwFlags : LongWord) : Boolean; stdcall; External user32;

{ TfrmNotification }

Constructor TfrmNotification.Create(AOwner : TComponent; Title, Description : String);
Begin
  Inherited Create(AOwner);
  lblTitle.Caption := Title;
  lblDescription.Caption := Description;
  FBirthTime := Now();
End;

procedure TfrmNotification.CreateParams(var Params: TCreateParams);
Const
  WS_EX_LAYERED : Cardinal = $80000;
  WS_EX_TRANSPARENT : Cardinal = $20;
begin
  inherited;
  Params.ExStyle := Params.ExStyle Or WS_EX_LAYERED;// Or WS_EX_TRANSPARENT;
end;

procedure TfrmNotification.FormCreate(Sender: TObject);
begin
//  SetLayeredWindowAttributes(Handle, 0, 0, lwAlpha);
end;

procedure TfrmNotification.Show;
Var
  x : Integer;
begin
  Visible := True;

  For x := 0 To 200 Do
  Begin
    SetLayeredWindowAttributes(Handle, 0, x, lwAlpha);
    Application.ProcessMessages();
    Sleep(1);
  End;
end;

{ TNotificationList }

function TNotificationList.Add(Item: TfrmNotification): Integer;
begin
  Result := Inherited Add(Item);
end;

function TNotificationList.Get(Index: Integer): TfrmNotification;
begin
  Result := Inherited Get(Index);
end;

procedure TNotificationList.Put(Index: Integer; Item: TfrmNotification);
begin
  Inherited Put(Index, Item);
end;

procedure TfrmNotification.FormClick(Sender: TObject);
begin
  Close();
end;

procedure TfrmNotification.FormClose(Sender: TObject; var Action: TCloseAction);
Var
  x : Integer;
begin
  For x := 200 DownTo 0 Do
  Begin
    SetLayeredWindowAttributes(Handle, 0, x, lwAlpha);
    Application.ProcessMessages();
    Sleep(1);
  End;
end;

end.