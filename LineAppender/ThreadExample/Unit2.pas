unit Unit2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls,
  Unit1, PingU, System.Win.TaskbarCore, Vcl.Taskbar;

type
  TForm2 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    ProgressBar1: TProgressBar;
    Edit1: TEdit;
    Button4: TButton;
    Edit2: TEdit;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormDblClick(Sender: TObject);
  private
    { Private declarations }
    FMaxNum: Integer;
    AdderThread: TPrimeAdder;
    function GetComputerFromXpath(_Xpath:String):String;
    function GetActualComputerName(_ComputeName,_XPathComputerName:String):String;
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

function TForm2.GetComputerFromXpath(_Xpath:String):String;
var
  tmpPath : String;

  function  GetCompName:string;
  var
    CompName: array [0..MAX_COMPUTERNAME_LENGTH+1] of Char;
    CompSize: DWord;
  begin
    CompSize := SizeOf(CompName);
    if GetComputerName(CompName, CompSize) then
      Result := CompName
    else
      Result := '';
  end;

begin
  Result := _xpath;
  if Result = '' then
    Exit;

  tmpPath :=  _Xpath  ;
  if pos('\\',tmpPath) = 1 then //file contains Network name.
     begin
       Delete(tmpPath,1,2);
       Result := copy(tmpPath,1,Pos('\',tmpPath)-1);
     end
  else
    Result := GetCompName;
end;

function TForm2.GetActualComputerName(_ComputeName,_XPathComputerName:String):String;
begin
  Result := Trim(_ComputeName);
  if Result = '' then
    Result := GetComputerFromXpath(trim(_XPathComputerName));
end;

procedure TForm2.Button1Click(Sender: TObject);
begin
  if Assigned(AdderThread) then
    AdderThread.Paused := False;
//  begin
//    AdderThread     := TPrimeAdder.Create(True);
//    AdderThread.Max := FMaxNum;
//  end;
end;

procedure TForm2.Button2Click(Sender: TObject);
begin
  if Assigned(AdderThread) then
    AdderThread.Paused := True;
end;

procedure TForm2.Button3Click(Sender: TObject);
begin
  if Assigned(AdderThread) then //19/6/2007 - Kobi A
  begin
    AdderThread.Sleep(100);
//    AdderThread.FreeOnTerminate := True;
    AdderThread.Terminate;
    if AdderThread.Suspended then
      AdderThread.Start;
//    FreeAndNil(AdderThread);
//    AdderThread.WaitFor;
//    AdderThread.FreeOnTerminate := False;
  end;
end;

procedure TForm2.Button4Click(Sender: TObject);
var
  sError: String;
begin
  if PingByThread(GetActualComputerName(Edit1.Text, Edit2.Text), 750, sError) then
    ShowMessage('Online')
  else
    ShowMessage('Offline ' + sError);
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
//  FMaxNum                     := 100;
//  AdderThread                 := TPrimeAdder.Create(True);
//  AdderThread.Max             := FMaxNum;
//  AdderThread.FreeOnTerminate := True;
end;

procedure TForm2.FormDblClick(Sender: TObject);
begin
  Edit1.Text := 'NJ_WIN10_D10';
  Edit2.Text := '\\127.0.0.1\Office\Tra';
end;

procedure TForm2.FormDestroy(Sender: TObject);
begin
//  if Assigned(AdderThread) then
//    FreeAndNil(AdderThread);
end;

procedure TForm2.FormShow(Sender: TObject);
begin
//  AdderThread.Start;
end;

end.
