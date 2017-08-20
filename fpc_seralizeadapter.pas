unit fpc_seralizeadapter;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, intf_seralizeadapter, variants, Laz_XMLRead, Laz2_DOM,
  Laz_XMLWrite;
type

  { TFPCXmlNode }
  TFPCXmlNode=class(TInterfacedObject,IDataNode)


    function GetAttributes(Name: string): string;
    function GetChildItem(Index:integer): IDataNode;
    function GetNodeName: string;
    function GetValue: variant;
    procedure SetAttributes(Name: string; AValue: string);
    procedure SetNodeName(AValue: string);
    procedure SetValue(AValue: variant);
    function AddChild(const Name:string):IDataNode;
    function ChildCount:integer;
    function ChildByName(const Name:string):IDataNode;
  protected
    fDoc:TDOMDocument;
    fNode:TDOMNode;
    function BuilDataNode(const Node:TDOMNode):IDataNode;
  end;
  TFPCJsonNode=class(TInterfacedObject)

  end;

  { TFPCXmlAdapter }

  TFPCXmlAdapter=class(TInterfacedObject,IDataAdapter)



    function NewDoc:IDataNode;
    function GetRootNode:IDataNode;
    procedure  LoadFromFile(const Filename:string);
    procedure SaveToFile(const FileName:string);

  private
    fDoc:TXMLDocument;
  public
    destructor Destroy;override;

  end;
  TFPCJsonAdapter=class(TInterfacedObject)

  end;

implementation

{ TFPCXmlNode }

function TFPCXmlNode.BuilDataNode(const Node: TDOMNode): IDataNode;
var
  xmlNode:TFPCXmlNode;
begin
  xmlNode :=TFpcXmlNode.Create;
  xmlNode.fDoc :=self.fDoc;
  xmlnode.fNode :=Node;
  result :=xmlNode;

end;

function TFPCXmlNode.GetAttributes(Name: string): string;
begin
  result :=fNode.Attributes.GetNamedItem(Name).NodeValue;
end;

function TFPCXmlNode.GetChildItem(Index: integer): IDataNode;
var
  Node:TDOMNode;
begin
  //result :=fNode.ChildNodes[Index];
  Node :=fNode.ChildNodes[Index];
  result :=self.BuilDataNode(Node);
end;

function TFPCXmlNode.GetNodeName: string;
begin
  result :=fNode.NodeValue;
end;

function TFPCXmlNode.GetValue: variant;
begin
  result :=fNode.NodeValue;
end;

procedure TFPCXmlNode.SetAttributes(Name: string; AValue: string);
var
  attr:TDOMNode;
begin
  attr :=FNode.Attributes.GetNamedItem(Name);
  if Assigned(Attr) then
  begin
    attr.NodeValue:=AValue;
  end else
  begin
    if fNode is TDOMElement then
    begin
      (fNode as TDOMElement).SetAttribute(Name,AValue);
    end else
    begin
      assert(false,'this nod is not a element node');
    end;
  end;
end;

procedure TFPCXmlNode.SetNodeName(AValue: string);
begin
  //
end;

procedure TFPCXmlNode.SetValue(AValue: variant);
begin
  fNode.NodeValue :=VarTostr(AValue);
end;




function TFPCXmlNode.AddChild(const Name: string): IDataNode;
var
  Ele:TDomElement;
begin
  Ele :=fDoc.CreateElement(Name);
  fNode.AppendChild(Ele);
  result :=self.BuilDataNode(Ele);
end;

function TFPCXmlNode.ChildCount: integer;
begin

end;

function TFPCXmlNode.ChildByName(const Name: string): IDataNode;
var
  Node:TDOMNode;
begin
  Node :=FNode.FindNode(Name);
  result :=BuilDataNode(Node);
end;

{ TFPCXmlAdapter }

destructor TFPCXmlAdapter.Destroy;
begin
  if Assigned(fDoc) then
    FreeAndNil(fDoc);
  inherited ;
end;

function TFPCXmlAdapter.NewDoc: IDataNode;
var
  Element:TDomElement;
begin
  if Assigned(fDoc) then
  begin
    FreeAndNil(fDoc);
  end;
  fDoc :=TXMLDocument.Create;
  Element :=fdoc.CreateElement('XMLObject');
  Fdoc.AppendChild(Element);
end;

function TFPCXmlAdapter.GetRootNode: IDataNode;
var
  xmlNode:TFPCXmlNode;
begin
  xmlNode :=TFPCXmlNode.Create;
  xmlNode.fNode :=fDoc.FirstChild;
  xmlNode.fDoc :=fDoc;
  result :=xmlNode;
end;

procedure TFPCXmlAdapter.LoadFromFile(const Filename: string);
begin
  //
  ReadXMLFile(fDoc,FileName);
end;

procedure TFPCXmlAdapter.SaveToFile(const FileName: string);
begin

 WriteXML(fDoc,FileName);
end;



end.

