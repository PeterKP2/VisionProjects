program BasicDemo;

{$mode objfpc}{$H+}

uses
  Interfaces, // Задължително за LCL приложения!
  Forms, 
  CameraParamsUnit,
  MainUnit,
  PixelTypeUnit,
  ToolFunctionUnit;

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.