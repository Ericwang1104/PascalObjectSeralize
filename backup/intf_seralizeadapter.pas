unit intf_seralizeadapter;
{$IFDEF  PFC}
{$mode objfpc}{$H+}
{$ENDIF}
interface

uses
  Classes, SysUtils;
const
  DATA_NODE_INTERFACE='{33427852-44EE-4EA8-A339-29C082DF3499}';
  Data_ADAPTER_INTERFACE='{69CFA652-6127-45FC-934E-FD48871E33DF}';
type
  { TDataNode }

  { IDataNode }

  IDataNode=Interface(IInterface)
  [DATA_NODE_INTERFACE]
    function GetAttributes(Name: string): string;
    function GetChildItem(Index:integer): IDataNode;
    function GetDumpText: string;
    function GetNodeName: string;
    function GetValue: variant;
    procedure SetAttributes(Name: string; AValue: string);
    procedure SetNodeName(AValue: string);
    procedure SetValue(AValue: variant);
    function AddChild():IDataNode;
    function AddPropObj(const Name: string): IDataNode;
    function ChildCount:integer;
    function PropObjByName(const Name:string): IDataNode;
    procedure SetData(AValue: string);
    function GetData: string;

    Property ChildItem[Index:integer]:IDataNode read GetChildItem;
    Property DATA:string read GetData write SetData;
    property NodeName:string read GetNodeName write SetNodeName;
    property Value:variant read GetValue write SetValue;
    property Attributes[Name:string]:string read GetAttributes write SetAttributes;
    property DumpText:string read GetDumpText;
  end;

  { IDataAdapter }

  IDataAdapter=interface(IUnknown)
  [Data_ADAPTER_INTERFACE]
    function NewDoc:IDataNode;
    function GetRootNode: IDataNode;
    function GetSeralzieString: string;
    procedure LoadFromFile(const FileName:string);
    procedure SaveToFile(const FileName:string);
    property RootNode:IDataNode read GetRootNode;
  end;



implementation



{ TDataNode }



end.

