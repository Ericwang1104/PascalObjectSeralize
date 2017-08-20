unit testfpc_seralizeadapter_test;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpc_seralizeadapter,Forms, intf_seralizeadapter, Laz_XMLRead,
  Laz2_DOM, laz2_XMLWrite, Laz_XMLWrite, fpcunit, testutils, testregistry;

type

  { TXMLAccessTest }

  TXMLAccessTest=class(TTestCase)
  private
    fDoc:TXMLDocument;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestReadXML;
    Procedure TestAccessXMLAttribute;
  end;

  TFpcAdapterTest= class(TTestCase)
  private
    FXML:TFPCXmlAdapter;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure XMLTest;
  end;

implementation

{ TXMLAccessTest }

procedure TXMLAccessTest.SetUp;
var
  Path:string;
begin
  Path :=GetCurrentDir();
  ReadXMLFile(fDoc,Path+'\testdata\test.xml');
end;

procedure TXMLAccessTest.TearDown;
begin
  if Assigned(fDoc) then
  begin
    FreeAndnil(fDoc);
  end;
end;

procedure TXMLAccessTest.TestReadXML;
begin
  checkequals(fDoc.NodeName,'aaa');

end;

procedure TXMLAccessTest.TestAccessXMLAttribute;
begin

end;

procedure TFpcAdapterTest.XMLTest;
var
  FileName:string;
  aDoc:TXMLDocument;
  node1,Node2:TDOMNode;
  Count :integer;
begin

end;

procedure TFpcAdapterTest.SetUp;
begin
  Fxml :=TFPCXmlAdapter.Create;
end;

procedure TFpcAdapterTest.TearDown;
begin
  FreeandNil(FXML);
end;

initialization
  RegisterTest(TXMLAccessTest);
  RegisterTest(TFpcAdapterTest);
end.

