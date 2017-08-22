unit fpc_seralizeadapter;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, intf_seralizeadapter, fpjson, dbugintf, variants,
  Laz_XMLRead, Laz2_DOM, Laz_XMLWrite;
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
    procedure SetData(AValue: string);
    function GetData: string;
  protected
    fDoc:TDOMDocument;
    fNode:TDOMNode;
    function BuilDataNode(const Node:TDOMNode):IDataNode;
  end;
  {TFPCJsonNode=class(TInterfacedObject,IDataNode)

  end;}


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
  TFPCJsonNode=class(TInterfacedObject,IDataNode)
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
      procedure SetData(AValue: string);
      function GetData: string;

    protected
      fDoc:TJsonObject;
      fNode:TJSOnData;
      function BuilDataNode(const Node:TJsonData):IDataNode;
  end;

    { TFPCJsonAdapter }

  TFPCJsonAdapter=class(TInterfacedObject,IDataAdapter)
    function NewDoc:IDataNode;
    function GetRootNode:IDataNode;
    procedure  LoadFromFile(const Filename:string);
    procedure SaveToFile(const FileName:string);

  private
    fDoc:TJsonObject;
  public
    destructor Destroy;override;
  end;
implementation

{ TFPCJsonNode }

function TFPCJsonNode.GetAttributes(Name: string): string;
begin
  if FNode is TJSonData then
  begin
    result :=(FNode as TJsonObject).Get(Name);
  end else
  begin
    assert(false,'fnode is not a object');
  end;
end;

function TFPCJsonNode.GetChildItem(Index: integer): IDataNode;
var
  data:TJsonData;
begin
  Data :=fNode.Items[Index];
  result :=self.BuilDataNode(Data);
end;

function TFPCJsonNode.GetNodeName: string;
begin
  if fNode is TJsonobject then
  begin
    result :=(FNode as TJsonObject).Names[0];
  end else
  begin
    result :='';
  end;
end;

function TFPCJsonNode.GetValue: variant;
begin
  result :=FNode.AsJSON;
end;

procedure TFPCJsonNode.SetAttributes(Name: string; AValue: string);
var
  JD:TJSOnData;
  Jobj:TJsonObject;
begin
  if FNode is TJsonObject then
  begin
    JObj :=FNode as TJsonObject;
    JD :=Jobj.Find(Name);
    if not Assigned(JD)then
    begin
      (FNode as TJsonObject).Add(Name,AValue);
    end else
    begin
      JD :=(FNode as TJsonObject).Find(Name);
      jd.AsString:=AValue;
    end;
  end;
end;

procedure TFPCJsonNode.SetNodeName(AValue: string);
begin
  //
end;

procedure TFPCJsonNode.SetValue(AValue: variant);

begin
  FNode.Value:=AValue;

end;

function TFPCJsonNode.AddChild(const Name: string): IDataNode;
var
  JObj:TJsonObject;
  Child:TJsonObject;
begin
  JObj :=FNode as TJsonObject;
  Child :=TJsonObject.Create();
  JObj.Add(Name,Child);
  result :=BuilDataNode(Child);
end;

function TFPCJsonNode.ChildCount: integer;
begin
  result :=FNode.Count;
end;

function TFPCJsonNode.ChildByName(const Name: string): IDataNode;
var
  JD:TJSOnData;
begin
  JD :=(FNode as TJsonObject).Find(Name);
  if Assigned(JD) then
  begin
    result :=BuilDataNode(JD);
  end;
end;

procedure TFPCJsonNode.SetData(AValue: string);
begin
 (FNode as TJSonObject).Add('CDATA',AValue);
end;

function TFPCJsonNode.GetData: string;
begin
  result :=(FNode as TJsonObject).Get('CDATA');
end;



function TFPCJsonNode.BuilDataNode(const Node: TJsonData): IDataNode;
var
  JNode:TFPCJsonNode;
begin
  JNode :=TFPCJsonNode.Create;
  JNode.fDoc :=self.fDoc;
  JNode.fNode :=Node;
  result :=JNode;
end;

{ TFPCJsonAdapter }

function TFPCJsonAdapter.NewDoc: IDataNode;
begin
 Fdoc :=GetJson('{JSONOBJECT:{}}') as TJsonObject;
end;

function TFPCJsonAdapter.GetRootNode: IDataNode;
var
  Node:TFPCJsonNode;
  JObj:TJsonObject;
begin
  JObj :=FDoc.Find('JSONOBJECT') as TJsonObject;
  Node :=TFPCJsonNode.Create;
  Node.fNode :=JObj;
  Node.fDoc :=fDOc;
  result :=Node;
end;

procedure TFPCJsonAdapter.LoadFromFile(const Filename: string);
var
  FS:TFileStream;
begin
  FS :=TFileStream.Create(FileName,fmopenRead);
  try
    FS.Position:=0;
    if not Assigned(Fdoc) then FreeAndNil(FDoc);
    FDoc :=GetJson(FS) as TJsonObject;
  finally
    FreeAndNil(FS);
  end;
end;

procedure TFPCJsonAdapter.SaveToFile(const FileName: string);
var
  FS:TFileStream;
begin
  FS :=TFileStream.Create(FileName,fmcreate);
  try
    FDoc.FormatJSON([foUseTabchar]);
    Fdoc.DumpJSON(FS);

  finally
    FreeAndNil(FS);
  end;
end;

destructor TFPCJsonAdapter.Destroy;
begin
  if Assigned(FDoc) then
    FreeAndNil(FDoc);
  inherited ;
end;

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
  result :=fNode.NodeName;
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
  result :=FNode.ChildNodes.Count;
end;

function TFPCXmlNode.ChildByName(const Name: string): IDataNode;
var
  Node:TDOMNode;
begin
  Node :=FNode.FindNode(Name);
  result :=BuilDataNode(Node);
end;

procedure TFPCXmlNode.SetData(AValue: string);
var
  xmlNode :TFPCXmlNode;
  CData:TDOMCDataSection;
begin
  CData :=fDoc.CreateCDATASection(AVAlue);
  fNode.AppendChild(CData);


end;

function TFPCXmlNode.GetData: string;
begin
  result :=FNode.FindNode('#cdata-section').NodeValue;
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

