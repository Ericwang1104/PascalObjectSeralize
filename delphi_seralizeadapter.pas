unit delphi_seralizeadapter;

interface

uses
  Classes,SysUtils,JsonDataObjects,intf_seralizeadapter;

type
  TDJsonNode = class(TInterfacedObject, IDataNode)
    strict private
    function AddChild: IDataNode;
    function AddPropObj(const Name: string): IDataNode;
    function PropObjByName(const Name:string): IDataNode;
    function ChildCount: integer;
    function GetAttributes(Name: string): string;
    function GetChildItem(Index:integer): IDataNode;
    function GetData: string;
    function GetNodeName: string;
    function GetValue: variant;
    procedure SetAttributes(Name: string; AValue: string);
    procedure SetData(AValue: string);
    procedure SetNodeName(AValue: string);
    procedure SetValue(AValue: variant);
    function GetDumpText:string;
    private
    protected
    fDoc: TJsonObject;
    FJSon: TJsonObject;
    FParent: TJsonObject;
    function BuildDataNode(const Node: TJsonObject): IDataNode;
  public
  end;

  TDJsonAdapter = class(TInterfacedObject, IDataAdapter)
  strict private
    function GetRootNode: IDataNode;
    function GetSeralzieString: string;
    procedure LoadFromFile(const FileName:string);
    function NewDoc: IDataNode;
    procedure SaveToFile(const FileName:string);
  private
    FJ: TJsonObject;
  public
    destructor Destroy; override;
  end;

implementation

destructor TDJsonAdapter.Destroy;
begin
  if Assigned(FJ) then
    FreeAndNil(FJ);
  inherited;
end;

function TDJsonAdapter.GetRootNode: IDataNode;
var
  Node:TDJsonNode;
  JObj:TJsonObject;
begin

  JObj := FJ.O['JSONOBJECT'];
  Node :=TDJsonNode.Create;
  Node.FJSon :=JObj;
  Node.FParent :=FJ;
  Node.fDoc :=FJ;
  result :=Node;
end;

function TDJsonAdapter.GetSeralzieString: string;
begin
  result :=FJ.ToJSON();
end;

procedure TDJsonAdapter.LoadFromFile(const FileName:string);
begin
  if Assigned(FJ) then FreeAndNil(FJ);
  FJ :=TJsonObject.Create;
  FJ.LoadFromFile(FileName);
end;

function TDJsonAdapter.NewDoc: IDataNode;
begin
  if Assigned(FJ) then FreeAndNil(FJ);
  FJ :=TJsonObject.Create;
end;

procedure TDJsonAdapter.SaveToFile(const FileName:string);
begin
  FJ.SaveToFile(FileName,false);

end;

function TDJsonNode.AddChild: IDataNode;
var
  JObj:TJsonObject;
  Arr:TJsonArray;
begin
  Arr :=FJSon.A['ITEMS'];
  Jobj :=Arr.AddObject;
  Result :=BuildDataNode(JObj);
end;

function TDJsonNode.AddPropObj(const Name: string): IDataNode;
var
  JObj:TJsonObject;
begin
  JObj :=FJSon.O[LowerCase(Name)];
  Result :=BuildDataNode(JObj);
end;

function TDJsonNode.BuildDataNode(const Node: TJsonObject): IDataNode;
var
  JNode:TDJsonNode;
begin
  JNode :=TDJsonNode.Create;
  JNode.fDoc :=self.fDoc;
  JNode.FJSon :=Node;
  JNode.FParent := FJSon;
  result :=JNode;
end;

function TDJsonNode.PropObjByName(const Name:string): IDataNode;
var
  JObj:TJsonObject;
begin
  JObj :=FJSon.O[LowerCase(Name)];
  if Assigned(JObj) then
  begin
    result :=BuildDataNode(JObj)
  end else
  begin
    result :=nil;
  end;
end;

function TDJsonNode.ChildCount: integer;
begin
  Result :=FJSon.A['ITEMS'].Count;
end;

function TDJsonNode.GetAttributes(Name: string): string;
begin
  result :=FJSon.S[LowerCase(Name)];
end;

function TDJsonNode.GetChildItem(Index: integer): IDataNode;
var
  Obj:TJsonObject;
begin
  Obj :=FJSon.A['ITEMS'].O[Index];
  result :=BuildDataNode(Obj);
end;

function TDJsonNode.GetData: string;
begin
  result :=FJSon.Values['cdata'].Value;
end;

function TDJsonNode.GetDumpText: string;
begin
  result :=FJSon.ToJSON(true);
end;

function TDJsonNode.GetNodeName: string;
begin
  result :=FJSon.S['name'];
end;

function TDJsonNode.GetValue: variant;
begin
  result :=FJSon.Values['value'].VariantValue;
end;

procedure TDJsonNode.SetAttributes(Name, AValue: string);
begin
  FJSon.S[LowerCase(Name)] :=AValue;
end;

procedure TDJsonNode.SetData(AValue: string);
begin
  FJSon.Values['cdata'].Value :=AValue;
end;

procedure TDJsonNode.SetNodeName(AValue: string);
begin
  FJSon.S['name'] :=AValue;
end;

procedure TDJsonNode.SetValue(AValue: variant);
begin
  FJSon.Values['value'].VariantValue :=AValue;
end;

end.
