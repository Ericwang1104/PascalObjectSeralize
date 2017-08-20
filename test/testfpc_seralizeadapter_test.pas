unit testfpc_seralizeadapter_test;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpc_seralizeadapter, intf_seralizeadapter, Laz_XMLRead,
  Laz2_DOM, fpcunit, testutils, testregistry;

type

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

procedure TFpcAdapterTest.XMLTest;
var
  FileName:string;
  aDoc:TXMLDocument;
  node1,Node2:TDOMNode;
  Count :integer;
begin
  FileName :='E:\myproject\Mysoftware\test\testdata\test.xml';
  ReadXMLFile(aDoc,FileName);
  try
    Count :=adoc.ChildNodes.Count;
    Node1 :=adoc.ChildNodes[0];
    Node2 :=aDoc.ChildNodes[1];
    checkequals( Node1.NodeName,'aaa');

  finally
    FreeAndnil(aDoc);
  end;
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

  RegisterTest(TFpcAdapterTest);
end.

