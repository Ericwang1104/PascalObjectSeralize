unit fpc_seralizeadapter;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, intf_seralizeadapter, Laz_XMLRead, Laz2_DOM;
type

  { TFPCXmlNode }

  TFPCXmlNode=class(TInterfacedObject,IDataNode)
   //
  strict private
    function GetAttributes(Name: string): string;
    function GetChildItem(Index:integer): IDataNode;
    function GetValue: string;
    procedure SetAttributes(Name: string; AValue: string);
    procedure SetValue(AValue: variant);
    procedure SetValue(AValue: string);
    function AddChild(const Name:string):IDataNode;
    function ChildCount:integer;
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

function TFPCXmlNode.GetAttributes(Name: string): string;
begin

end;

function TFPCXmlNode.GetChildItem(Index: integer): IDataNode;
begin

end;

function TFPCXmlNode.GetValue: string;
begin

end;

procedure TFPCXmlNode.SetAttributes(Name: string; AValue: string);
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
begin

end;

procedure TFPCXmlAdapter.LoadFromFile(const Filename: string);
begin
  //
  ReadXMLFile(fDoc,FileName);
end;

procedure TFPCXmlAdapter.SaveToFile(const FileName: string);
begin
 //
end;

end.

