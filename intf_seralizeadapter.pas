unit intf_seralizeadapter;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;
const
  DATA_NODE_INTERFACE='{33427852-44EE-4EA8-A339-29C082DF3499}';
  Data_ADAPTER_INTERFACE='{69CFA652-6127-45FC-934E-FD48871E33DF}';
type
  { TDataNode }

  IDataNode=Interface(IUnknown)
  [DATA_NODE_INTERFACE]
    function GetAttributes(Name: string): string;
    function GetChildItem(Index:integer): IDataNode;
    function GetValue: string;
    procedure SetAttributes(Name: string; AValue: string);
    procedure SetValue(AValue: variant);
    procedure SetValue(AValue: string);

    function AddChild(const Name:string):IDataNode;
    function ChildCount:integer;
    Property ChildItem[Index:integer]:IDataNode read GetChildItem;
    property Value:string read GetValue write SetValue;
    property Attributes[Name:string]:string read GetAttributes write SetAttributes;
  end;

  { IDataAdapter }

  IDataAdapter=interface(IUnknown)
  [Data_ADAPTER_INTERFACE]
  function GetRootNode: IDataNode;
    procedure LoadFromFile(const FileName:string);
    procedure SaveToFile(const FileName:string);
    property RootNode:IDataNode read GetRootNode;
  end;



implementation



{ TDataNode }



end.

