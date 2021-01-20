unit PingU;

interface
uses
  Winapi.Windows, System.SysUtils, System.Classes, Winapi.ActiveX, 
  System.SyncObjs,
  Vcl.Dialogs;


type
  TSunB = packed record
    s_b1, s_b2, s_b3, s_b4: byte;
  end;

  TSunW = packed record
    s_w1, s_w2: word;
  end;

  PIPAddr = ^TIPAddr;
  TIPAddr = record
    case integer of
      0: (S_un_b: TSunB);
      1: (S_un_w: TSunW);
      2: (S_addr: longword);
  end;

 IPAddr = TIPAddr;

function IcmpCreateFile : THandle; stdcall; external 'icmp.dll';
function IcmpCloseHandle (icmpHandle : THandle) : boolean; stdcall; external 'icmp.dll'
function IcmpSendEcho (IcmpHandle : THandle; DestinationAddress : IPAddr;
    RequestData : Pointer; RequestSize : Smallint;
    RequestOptions : pointer;
    ReplyBuffer : Pointer;
    ReplySize : DWORD;
    Timeout : DWORD) : DWORD; stdcall; external 'icmp.dll';


function Ping(InetAddress : string; Timeout: DWORD = 0) : boolean;

// Kobi A (TNK 222794)
// Ping is called by a thread and the timeout is handled by TEvent instance
function PingByThread(const Addr: string; const Timeout: Cardinal; var ErrorMsg:string): Boolean;

implementation

uses
  Winapi.WinSock;


type

  // Kobi A (TNK 222794)  to be used only by the PingByThread function
  TPingThread = class(TThread)
  private
    FEvent:TEvent;
    PingAddress: string;
    Timeout: Cardinal;
    FPingResult:Boolean;
    FErrorMsg:string;
    function DoPing(Ping_Timeout: Cardinal):Boolean;// Kobi A (TNK 222794)
    
  protected
    procedure Execute; override;

  public
    constructor Create(_Address:string; const _Event:TEvent; const InternalTimeout:Cardinal = 250); reintroduce; // Kobi A (TNK 222794)
    destructor Destroy; override;
    procedure ClearEvent;

    property PingResult:Boolean read FPingResult;
    property ErrorMsg:string read FErrorMsg;

  end;


function Fetch(var AInput: string; const ADelim: string = ' '; const ADelete: Boolean = true)
 : string;
var
  iPos: Integer;
begin
  if ADelim = #0 then begin
    // AnsiPos does not work with #0
    iPos := Pos(ADelim, AInput);
  end else begin
    iPos := Pos(ADelim, AInput);
  end;
  if iPos = 0 then begin
    Result := AInput;
    if ADelete then begin
      AInput := '';
    end;
  end else begin
    result := Copy(AInput, 1, iPos - 1);
    if ADelete then begin
      Delete(AInput, 1, iPos + Length(ADelim) - 1);
    end;
  end;
end;

procedure TranslateStringToTInAddr(AIP: string; var AInAddr);
var
  phe: PHostEnt;
  pac:  PAnsiChar;
  GInitData: TWSAData;
begin
  WSAStartup($101, GInitData);
  try
    phe := GetHostByName(PAnsiChar(AnsiString(AIP)));
    if Assigned(phe) then
    begin
      pac := phe^.h_addr_list^;
      if Assigned(pac) then
      begin
        with TIPAddr(AInAddr).S_un_b do begin
          s_b1 := Byte(pac[0]);
          s_b2 := Byte(pac[1]);
          s_b3 := Byte(pac[2]);
          s_b4 := Byte(pac[3]);
        end;
      end
      else
      begin
        raise Exception.Create('Error getting IP from HostName');
      end;
    end
    else
    begin
      raise Exception.Create('Error getting HostName');
    end;
  except
    FillChar(AInAddr, SizeOf(AInAddr), #0);
  end;
  WSACleanup;
end;

function Ping(InetAddress : string; Timeout: DWORD = 0) : boolean;
var
 Handle : THandle;
 InAddr : IPAddr;
 DW : DWORD;
 rep : array[1..128] of byte;
begin
  result := false;
  Handle := IcmpCreateFile;
  if Handle = INVALID_HANDLE_VALUE then
   Exit;
  TranslateStringToTInAddr(InetAddress, InAddr);
  DW := IcmpSendEcho(Handle, InAddr, nil, 0, nil, @rep, 128, Timeout);
  Result := (DW <> 0);
  IcmpCloseHandle(Handle);
end;


// Kobi A (TNK 222794)
constructor TPingThread.Create(_Address:string; const _Event:TEvent; const InternalTimeout:Cardinal);
begin
  inherited Create(True);
  Timeout     := InternalTimeout;    
  ReturnValue := 0; // Initialize it
  PingAddress := _Address;
  FEvent      := _Event;
  FPingResult := False;
  FreeOnTerminate := True;
end;

// Kobi A (TNK 222794)
procedure TPingThread.ClearEvent;
begin
  FEvent := nil;
end;

// Kobi A (TNK 222794)
destructor TPingThread.Destroy;
begin
//  ShowMessage('Destroyed');
  inherited;
end;

function TPingThread.DoPing(Ping_Timeout: Cardinal):Boolean;
begin
  FPingResult:= Ping(PingAddress, Ping_Timeout);
  Result := FPingResult;
end;

// Kobi A (TNK 222794)
procedure TPingThread.Execute;
begin
  try
    ReturnValue := 1; // indicating start execute
    // Kobi A (TNK 222794) try twich with timeout and one infinit
    if not DoPing(Timeout) then
      if not DoPing(Timeout) then
        DoPing(0);
    ReturnValue := 2; // indicating end with no error
    if Assigned(FEvent) then FEvent.SetEvent;
  except
    on E:Exception do
    begin
      FErrorMsg := E.Message;
      ReturnValue := 3; // indicating end with error
    end;
  end;
end;

// Kobi A (TNK 222794)
function PingByThread(const Addr: string; const Timeout: Cardinal; var ErrorMsg:string): Boolean;
var
  PingThread:TPingThread;
  Event :TEvent;
  EventName:string;
  G:TGUID;
begin
  Result:= False;
  if CreateGUID(G) = S_OK then
    EventName:= GUIDToString(G)
  else
  begin
    Sleep(2);
    EventName := IntToStr(GetTickCount);
  end;

  Event := TEvent.Create(nil, True, False, EventName);
  try
    PingThread:= TPingThread.Create(Addr, Event, Timeout Div 3);
    PingThread.Start;
    if Event.WaitFor(Timeout) <> wrSignaled then
      PingThread.Sleep(10); //PingThread.Terminate;

    if PingThread.ReturnValue > 1 then // in case the thread execute was finished prior it was suspended
    begin
      if PingThread.ReturnValue = 2 then // finished with no error
        Result:= PingThread.PingResult
      else
      begin // Finished with error
        Result:= False;
        ErrorMsg := PingThread.ErrorMsg;
      end;
//        PingThread.Terminate;
//      PingThread.Free; // since it was finished free it
    end
    else
      try // Since even when sespended of freeing the thread it will wait for the ping to be finished, let it resume and free itself on termination
        ErrorMsg := 'Timeout';
//        PingThread.Terminate;
//        PingThread.ClearEvent;
//        PingThread.FreeOnTerminate := True;
//        PingThread.Start;
      except
        // Ignore thread exception if occurs
      end;
    ShowMessage(PingThread.ErrorMsg);
//    PingThread.Terminate;
  finally
    Event.Free;
  end;
end;

end.
