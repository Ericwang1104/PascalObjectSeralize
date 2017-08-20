unit testxmlpersistent;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, XMLPersistent, fpcunit, testutils, testregistry;

type

  TTestXmlPersistent= class(TTestCase)
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestHookUp;
  end;

implementation

procedure TTestXmlPersistent.TestHookUp;
begin
  Fail('Write your own test');
end;

procedure TTestXmlPersistent.SetUp;
begin

end;

procedure TTestXmlPersistent.TearDown;
begin

end;

initialization

  RegisterTest(TTestXmlPersistent);
end.

