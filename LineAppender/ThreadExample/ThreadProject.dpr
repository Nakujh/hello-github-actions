program ThreadProject;

uses
  Vcl.Forms,
  Unit2 in 'Unit2.pas' {Form2},
  Unit1 in 'Unit1.pas',
  PingU in 'PingU.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
// Site Builder note:  Release: 
// Runner Machine note:  Release:  (2021-01-19 22:47:37.305230)
// Runner Machine note:  Release:  (19/01/2021 22:50:52)
// Runner Machine note:  Release:  (19/01/2021 22:56:27)
// Runner Machine note:  Release:  (19/01/2021 22:50:52) 19/01/2021 23:46:45
// Runner Machine note:  Release:  (20/01/2021 00:28:43)