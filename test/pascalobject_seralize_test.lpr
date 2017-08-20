program pascalobject_seralize_test;

{$mode objfpc}{$H+}
uses
  Interfaces, Forms,GuiTestRunner, testfpc_seralizeadapter_test;

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGuiTestRunner, TestRunner);
  Application.Run;
end.

