unit fpc_seralizeadapter;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, intf_seralizeadapter, Laz_XMLRead, Laz2_DOM, Laz_XMLWrite;
type

  { TFPCXmlNode }
  TFPCXmlNode=class(TInterfacedObject,IDataNode)

  strict private
    function GetAttributes(Name: string): string;
    function GetChildItem(Index:integer): IDataNode;
    function GetNodeName: string;
    function GetValue: string;
    procedure SetAttributes(Name: string; AValue: string);
    procedure SetNodeNameNodeName(AValue: string);
    procedure SetValue(AValue: variant);
    procedure SetValue(AValue: string);
    function AddChild(const Name:string):IDataNode;
    function ChildCount:integer;
  protected
    fNode:TDOMNode;
    function BuilDataNode(const Node:TDOMNode):IDataNode;
  end;
  TFPCJsonNode=class(TInterfacedObject)

  end;

  { TFPCXmlAdapter }

  TFPCXmlAdapter=class(TInterfacedObject,IDataAdapter)

  strict private


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

function TFPCXmlNode.GetValue: string;
begin
  result :=fNode.NodeValue;
end;

procedure TFPCXmlNode.SetAttributes(Name: string; AValue: string);
begin
  fNode.Attributes.GetNamedItem(Name).NodeValue:=Avalue;
end;

procedure TFPCXmlNode.SetNodeNameNodeName(AValue: string);
begin

end;

procedure TFPCXmlNode.SetValue(AValue: variant);
begin

end;

procedure TFPCXmlNode.SetValue(AValue: string);
begin

end;

function TFPCXmlNode.AddChild(const Name: string): IDataNode;
begin

end;

function TFPCXmlNode.ChildCount: integer;
begin

end;

{ TFPCXmlAdapter }

destructor TFPCXmlAdapter.Destroy;
begin
  if Assigned(fDoc) then
    FreeAndNil(fDoc);
  inherited ;
end;

function TFPCXmlAdapter.GetRootNode: IDataNode;
var
  xmlNode:TFPCXmlNode;
begin
  xmlNode :=TFPCXmlNode.Create;
  xmlNode.fNode :=fDoc;
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

