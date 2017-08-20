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
    procedure TestAddAttribute;
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
var
  FirstNode:TDOMNode;
begin
  FirstNode :=fDoc.ChildNodes[0];

  checkequals(FirstNode.NodeName,'XMLOBJECT');

end;

procedure TXMLAccessTest.TestAccessXMLAttribute;
var
  FirstNode:TDOMNode;
begin
  FirstNode :=fDoc.ChildNodes[0];
  Checkequals(Firstnode.Attributes.Item[0].NodeValue,'TComponent');

  checkequals(FirstNode.Attributes.GetNamedItem('PersistentType').NodeValue,'TComponent');
  Checkequals(Firstnode.Attributes.GetNamedItem('ClassType').NodeValue,'TCodeLib');
end;

procedure TXMLAccessTest.TestAddAttribute;
var
  FirstNode:TDOMNode;
  attrNode:TDOMAttr;
  attrs:TDOMNamedNodeMap;
begin
  FirstNode :=fDoc.ChildNodes[0];
  attrNode :=fDoc.CreateAttribute('wac');
  (FirstNode as  TDomElement).SetAttribute('wac','test');

  WriteXML(fDoc,'e:\test.xml');
end;

procedure TFpcAdapterTest.XMLTest;

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

