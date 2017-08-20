program pascalobject_seralize_test;

{$mode objfpc}{$H+}
uses
  Interfaces, Forms,GuiTestRunner, testfpc_seralizeadapter_test,
test_pascalobjectseralize, frm_Test;

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGuiTestRunner, TestRunner);
  Application.CreateForm(TfrmTest, frmTest);
  Application.Run;
end.

