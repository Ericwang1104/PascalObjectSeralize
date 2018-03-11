program testPascalObjectSeralize;
{

  Delphi DUnit Test Project
  -------------------------
  This project contains the DUnit test framework and the GUI/Console test runners.
  Add "CONSOLE_TESTRUNNER" to the conditional defines entry in the project options
  to use the console test runner.  Otherwise the GUI test runner will be used by
  default.

}

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  DUnitTestRunner,
  Testpascalobject_seralize in 'Testpascalobject_seralize.pas',
  intf_seralizeadapter in '..\intf_seralizeadapter.pas',
  JsonDataObjects in '..\JsonDataObjects.pas',
  pascalobject_seralize in '..\pascalobject_seralize.pas',
  frm_test in 'frm_test.pas' {frmTest},
  delphi_seralizeadapter in '..\delphi_seralizeadapter.pas';

{$R *.RES}

begin
  DUnitTestRunner.RunRegisteredTests;
end.

