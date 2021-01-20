unit Unit1;

interface

uses System.SysUtils, System.Classes, System.SyncObjs,
     Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls;

type
   TPrimeAdder = class(TThread)
  private
    FMax, FTotal, FPosition: Integer;
    FEvent: TEvent;
    FPaused: Boolean;
    procedure SetPaused(const Value: Boolean);
  protected
    procedure Execute; override;
    procedure ShowTotal;
    procedure UpdateProgress;
    function IsPrime(N: Integer): Boolean;
  public
    constructor Create(const bPaused: Boolean = false);
    destructor Destroy; override;

    property Max: Integer read FMax write FMax;
    property Paused: Boolean read FPaused write SetPaused;
  end;

implementation

uses Unit2;

constructor TPrimeAdder.Create(const bPaused: Boolean);
begin
  FPaused := bPaused;
  FEvent := TEvent.Create(nil, true, not fPaused, '');
  inherited Create(True);
  FreeOnTerminate := True;
end;

destructor TPrimeAdder.Destroy;
begin
//  Terminate;
  FEvent.SetEvent;
//  WaitFor;
  FreeAndNil(FEvent);
  Terminate;
  inherited;
end;

procedure TPrimeAdder.Execute;
var
  I, Tot: Integer;
//label
//  GotoLabel;
begin
  Tot := 0;
//  GotoLabel:
    while not Terminated do
    begin
      FEvent.WaitFor(INFINITE);
      FPosition := 0;
      for I := 1 to FMax do
      begin
        if IsPrime(I) then
          Tot := Tot + I;
        if I mod (FMax div 100) = 0 then
        begin
          FPosition := I * 100 div FMax;
          Synchronize(UpdateProgress);
        end;
//        if I = FMax then
//          goto GotoLabel;
      end;
    end;
    FTotal := Tot;
    Synchronize(ShowTotal);
//  FreeOnTerminate := True;
end;

function TPrimeAdder.IsPrime(N: Integer): Boolean;
var
  M: Integer;
begin
  if N = 1 then
  begin
    Result := False;
    exit;
  end;
  for M := 2 to (N div 2) do
    if N mod M = 0 then
    begin
      Result := False;
      exit;
    end;
  Result := True;
end;

procedure TPrimeAdder.SetPaused(const Value: Boolean);
begin
  if (not Terminated) and (FPaused <> Value) then
  begin
    FPaused := Value;
    if FPaused then
      FEvent.ResetEvent
    else
      FEvent.SetEvent;
  end;
end;

procedure TPrimeAdder.ShowTotal;
begin
  Form2.ProgressBar1.Position := 0;
  ShowMessage('Thread: ' + IntToStr (FTotal));
end;

procedure TPrimeAdder.UpdateProgress;
begin
  Form2.ProgressBar1.Position := FPosition;
end;

end.
