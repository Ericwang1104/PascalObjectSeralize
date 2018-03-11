unit pascalobject_seralize;

interface

uses  Classes,TypInfo,graphics,  Variants, SysUtils,StrUtils,
{$IFDEF  FPC}
  base64,dbugintf,
{$ELSE}
  System.NetEncoding,
{$ENDIF}
intf_SeralizeadApter;
const
  ROOT_OBJECT = 'XMLPersistent';

 tkPersistent = [tkInteger, tkChar, tkEnumeration, tkSet, tkClass, tkInterface,
    tkFloat, tkWChar, tkString, tkLString,{$IFDEF  FPC}tkAString,{$ENDIF} tkWString, tkUString, tkVariant,
    tkInt64, tkRecord, tkArray, tkDynArray, tkUnknown];
  tkObj = [tkClass, tkInterface];
  tkStr = [tkString, tkLString, tkWString, tkUString{$IFDEF  FPC},tkAString {$ENDIF}];
  tkValue = tkPersistent - tkObj;
  tkOthers = [tkMethod];
  tkAll = tkPersistent + tkOthers;
  IID_IStreamPersist: TGUID = '{B8CD12A3-267A-11D4-83DA-00C04F60B2DD}';

type
  TReaderClass= class of TObjectReader;
  TWriterClass= class of TObjectWriter;
  TCollectionClass = class of TCollection;

  { TDynamicBuilder }

  TDynamicBuilder = class(TComponent)
  public
    class function BuildCollection(aClassName: string;
      CollectionItemClass: TCollectionItemClass): TCollection;
    class function BuildCollectionItem(aClassName: string;
      Collection: TCollection): TCollectionItem;
    class function BuildComponent(const aClassName: string;
      const AOwner: TComponent = nil): TComponent;
    class function BuildPersistent(aClassName: string): TPersistent;
  end;




  TObjectFilter = class(TComponent)
  private
    FIAdp:IDataAdapter;
  public
    property Adapter:IDataAdapter read FIAdp write FIAdp;
  end;

  { TObjectWriter }

  TObjectWriter = class(TObjectFilter)
  strict private
  private
    procedure WriteProperties(const Obj: TPersistent; Prop: PPropInfo;
      Node: IDataNode);
    procedure SetClassType(const Obj: TPersistent; Nde: IDataNode);
    procedure SetPersistentType(const Obj: TPersistent; const Node: IDataNode);
  strict protected
    procedure SavelCollectionItem(const Obj: TPersistent; const Node: IDataNode);
    procedure WriteNodeData(const Obj: TPersistent; const Nde: IDataNode);
  protected
    procedure WriteObject(Prop: PPropInfo; Node: IDataNode; Obj: TObject);
      virtual; abstract;
    procedure WriteChildObject(const Obj: TPersistent; Node: IDataNode); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    procedure WriteObjectToFile(FileName:string;const Obj: TPersistent);
    function WriteObjectToString(const Obj: TPersistent): string;
  published
  end;

  { TObjectReader }

  TObjectReader = class(TObjectFilter)
  private
    function PropIsReadOnly(Pinfo: PPropInfo): boolean;
    procedure ReadSeralizeObject(Obj: TPersistent; Node: IDataNode; PProp:
        PPropInfo);
    procedure SetSeralizePropValue(Obj: TPersistent; Value: Variant; PProp:
        PPropInfo);
  protected
    procedure ReadObject(Obj: TObject; const PropNode: IDataNode);
      virtual; abstract;
    procedure ReadChildObject(Obj: TPersistent; Node: IDataNode); virtual;
    procedure ReadPersistentFromNode(Node: IDataNode; Instance: TPersistent); virtual;
    function ReadValueFromNode(Node: IDataNode): Variant;
  public
    procedure ReadNodeToObject(const Node: IDataNode; Obj: TPersistent);
    procedure ReadFileToObject(const FileName:string;Obj:TPersistent);
  published
  end;

  TMyCustomReader = class(TObjectReader)
  private
    procedure ReadPicture(const Pic: TPicture; const Node: IDataNode);
    procedure ReadStream(Stream: TStream; Node: IDataNode);
    procedure ReadStrings(Obj: TStrings; Node: IDataNode);
  protected
    procedure ReadObject(Obj: TObject; const PropNode: IDataNode); override;
    procedure ReadChildObject(Obj: TPersistent; Node: IDataNode); override;
  published
  end;

  { TMyCustomWriter }

  TMyCustomWriter = class(TObjectWriter)
  private
    procedure SaveGraphic(Obj: TGraphic; Node: IDataNode);
    procedure SaveStream(const Stream: TStream; Node: IDataNode);
    procedure SaveTStrins(const Obj: TStrings; const Node: IDataNode);
  protected
    procedure WriteObject(Prop: PPropInfo; Node: IDataNode;
      Obj: TObject); override;
    procedure WriteChildObject(const Obj: TPersistent; Node: IDataNode); override;
  public

  published
    procedure SavePicture(Pic: TPicture; Node: IDataNode);

  end;

function StreamToBase64String(const stream:TStream):string;
procedure Base64StringToStream(Stream:TStream;base64Str:string);
implementation

function StreamToBase64String(const stream: TStream): string;
var
  {$IFDEF FPC}
    B64:TBase64EncodingStream;
  {$ELSE}
    B64:TBase64Encoding;
  {$ENDIF}
  str:TStringStream;
begin
  {$IFDEF  FPC}
  str :=TStringStream.Create('');
  B64:=TBase64EncodingStream.Create(str);
  try
    Stream.Position:=0;
    B64.CopyFrom(stream,stream.Size);
    result :=str.DataString;
  finally
    FreeAndNil(B64);
    FreeAndNil(Str);
  end;
  {$ELSE}
    b64 :=TBase64Encoding.Create;
    str :=TStringStream.Create('');
    try
      stream.Position :=0;
      B64.Encode(stream,str);
      Result :=str.DataString;
    finally
      FreeAndNil(Str);
      FreeAndNil(B64);
    end;
  {$ENDIF}
end;

procedure Base64StringToStream(Stream: TStream; base64Str: string);
var
  {$IFDEF  FPC}
  B64:TBase64DecodingStream;
  {$ELSE}
    B64 :TBase64Encoding;
  {$ENDIF}
  str:TStringStream;

begin
  //
  {$IFDEF  FPC}
  str :=TstringStream.Create(Base64Str);
  B64 :=TBase64DecodingStream.Create(str);
  try
    Stream.CopyFrom(B64,B64.Size);
  finally
    FreeAndNil(Str);
    FreeAndNil(B64);
  end;
  {$ELSE}
  str :=TStringStream.Create;
  B64 :=TBase64Encoding.Create;
  try
    str.WriteString(base64Str);
    str.Position :=0;
    B64.Decode(str,Stream);
  finally
    FreeAndNil(B64);
    FreeAndNil(str);
  end;
  {$ENDIF}
end;






{ ******************************* TDynamicBuilder ******************************** }
class function TDynamicBuilder.BuildCollection(aClassName: string;
  CollectionItemClass: TCollectionItemClass): TCollection;
begin
  result := TCollectionClass(FindClass(ClassName)).Create(CollectionItemClass);
end;

class function TDynamicBuilder.BuildCollectionItem(aClassName: string;
  Collection: TCollection): TCollectionItem;
begin
  result := TCollectionItemClass(FindClass(aClassName)).Create(Collection);
end;

class function TDynamicBuilder.BuildComponent(const aClassName: string;
  const AOwner: TComponent): TComponent;
begin
  result := TComponentClass(FindClass(aClassName)).Create(AOwner);
end;

class function TDynamicBuilder.BuildPersistent(aClassName: string): TPersistent;
begin
  result := TPersistentClass(FindClass(ClassName)).Create
end;

{ ******************************* TObjectFilter ******************************* }
constructor TObjectWriter.Create(AOwner: TComponent);
begin
  inherited;
  (* TODO: extracted code
    self.InitXMLHead;
    FXMLDoc.Encoding :='UTF-8';
  *)
end;

procedure TObjectWriter.WriteChildObject(const Obj: TPersistent; Node:
    IDataNode);
var
  I:integer;
  comp,CompChild:Tcomponent;
  Child:IDataNode;
begin
  if Obj is TCollection then
  begin
    SavelCollectionItem(Obj, Node);
    exit;
  end else
  if Obj is TComponent then
  begin
    Comp :=Obj as Tcomponent;
    for I := 0 to Comp.ComponentCount-1 do
    begin
      CompChild :=comp.Components[I];
      Child :=Node.AddChild;
      WriteNodeData(CompChild,Child);

    end;
  end;
end;

procedure TObjectWriter.WriteProperties(const Obj: TPersistent;
  Prop: PPropInfo; Node: IDataNode);
var
  PropObj: TObject;
  IPropObj: IInterface;
  ObjNOde: IDataNode;
  cClassName:string;
begin
  case Prop^.PropType^.Kind of
    tkClass:
      begin
        PropObj := GetObjectProp(Obj, string(Prop^.Name));
        if PropObj is TPersistent then
        begin
          ObjNOde := Node.AddPropObj(string(Prop^.Name));
          if Assigned(PropObj) then
          begin
            WriteNodeData(TPersistent(PropObj), ObjNOde);
            WriteObject(Prop,ObjNode,PropObj);
          end
        end
        else
        begin
          ObjNOde := Node.AddPropObj(string(Prop^.Name));
          if Assigned(PropObj) then
            WriteObject(Prop, ObjNOde, PropObj);
        end;
      end;
    tkInterface:
      begin
        //IPropObj := GetInterfaceProp(Obj, string(Prop^.Name));
      end;
    tkMethod:
      begin
        {Node.Attributes[string(Prop^.Name)] :=
          GetPropValue(Obj, string(Prop^.Name)); }
      end;
    tkEnumeration:
      begin
        Node.Attributes[string(Prop^.Name)] :=
          GetEnumProp(Obj, string(Prop^.Name));
      end;
    tkSet:
      begin
        Node.Attributes[string(Prop^.Name)] :=
          GetSetProp(Obj, string(Prop^.Name));
      end;
    tkUnknown, tkInteger, tkChar, tkFloat, tkWChar, tkVariant, tkInt64:
      begin
        Node.Attributes[string(Prop^.Name)] :=
          GetPropValue(Obj, string(Prop^.Name));
      end;
    tkString, tkLString, tkWString, tkUString{$IFDEF FPC},tkAString{$ENDIF}:
      begin
        Node.Attributes[string(Prop^.Name)] :=
          GetPropValue(Obj, string(Prop^.Name));
      end;
    tkArray, tkDynArray:
      begin
        Node.Attributes[string(Prop^.Name)] :=
          GetPropValue(Obj, string(Prop^.Name));
      end;
    tkRecord:
      begin
        Node.Attributes[string(Prop^.Name)] :=
          GetPropValue(Obj, string(Prop^.Name));
      end;
  end;
end;

procedure TObjectWriter.SavelCollectionItem(const Obj: TPersistent; const
    Node: IDataNode);
var
  I: Integer;
  PropObj: TObject;
  Child: IDataNode;
  Comp:TComponent;
begin
  if Obj is TCollection then
  begin
    for I := 0 to (Obj as TCollection).Count - 1 do
    begin
      PropObj := (Obj as TCollection).Items[I];
      Child := Node.AddChild();
      WriteNodeData((PropObj as TPersistent), Child);
    end;
  end else
  if Obj is TComponent then
  begin
    for I := 0 to (obj as TComponent).ComponentCount-1 do
    begin
      Comp:=(obj as TComponent).Components[I];
      Child :=Node.AddChild();
      WriteNodeData(Comp,Child);
    end;
  end;
end;

procedure TObjectWriter.SetClassType(const Obj: TPersistent; Nde: IDataNode);

begin
  Nde.Attributes['ClassType'] := Obj.ClassName;
end;

procedure TObjectWriter.SetPersistentType(const Obj: TPersistent;
  const Node: IDataNode);
begin

  if Obj is TCollection then
  begin
    Node.Attributes['PersistentType'] := 'TCollection';
  end
  else
  begin
    if Obj is TCollectionItem then
    begin
      Node.Attributes['PersistentType'] := 'TCollectionItem';
    end
    else
    begin
      if Obj is TComponent then
      begin
        Node.Attributes['PersistentType'] := 'TComponent';
      end
      else
      begin
        if Obj is TGraphic then
        begin
          Node.Attributes['PersistentType'] := 'TGraphic';
        end
        else
        begin
          if Obj is TPicture then
          begin
            Node.Attributes['PersistentType'] := 'TPicture';
          end
          else
          begin
            Node.Attributes['PersistentType'] := 'TPersistent';
          end;

        end;
      end;
    end;
  end;
end;

procedure TObjectWriter.WriteObjectToFile(FileName: string;
  const Obj: TPersistent);
var
  Node:IDataNode;
begin
  fiadp.NewDoc;
  Node :=fiadp.RootNode;
  WriteNodeData(Obj,Node);
  FIAdp.SaveToFile(FileName);
end;

procedure TObjectWriter.WriteNodeData(const Obj: TPersistent; const Nde:
    IDataNode);
var
  intI: Integer;
  PList: PPropList;
  intPropCount: Integer;
  PPInfo: PPropInfo;
begin
  intPropCount := GetTypeData(Obj.ClassInfo)^.PropCount;
  GetMem(PList, intPropCount * SizeOf(Pointer));
  try
    intPropCount := GetPropList(Obj.ClassInfo, tkAny, PList);
    for intI := 0 to intPropCount - 1 do
    begin
      PPInfo := PList^[intI];
      WriteProperties(Obj, PPInfo, Nde);

    end;

  finally
    FreeMem(PList, intPropCount * SizeOf(Pointer));
  end;
  //SetPersistentType(Obj, Nde);
  SetClassType(Obj, Nde);

  // Save Collection
  WriteChildObject(Obj, Nde);
end;

function TObjectWriter.WriteObjectToString(const Obj: TPersistent): string;
var
  Node:IDataNode;
begin
  fiadp.NewDoc;
  Node :=fiadp.RootNode;
  WriteNodeData(Obj,Node);
  result :=FIAdp.GetSeralzieString;
end;

function TObjectReader.PropIsReadOnly(Pinfo: PPropInfo): boolean;
begin
  result := Pinfo^.SetProc = nil;
end;

procedure TObjectReader.ReadPersistentFromNode(Node: IDataNode; Instance:
    TPersistent);
var
  intI: Integer;
  intPropCount: Integer;
  PProp: PPropInfo;
  PList: PPropList;
  PropNode: IDataNode;
  Obj: TObject;
begin
  //intPropCount :=GetTypeData(Instance.ClassInfo).
  intPropCount :=GetpropList(Instance,PList);
  GetMem(PList, intPropCount * SizeOf(Pointer));
 // intPropCount =GetpropList(Instance,PList);

  try
    for intI := 0 to GetPropList(Instance.ClassInfo, tkValue, PList,
      False) - 1 do
    begin
      PProp := PList^[intI];
      if not PropIsReadOnly(PProp) then
      begin
        SetSeralizePropValue(Instance, Node.Attributes[string(PProp^.Name)], PProp);
      end;
    end;
    for intI := 0 to GetPropList(Instance.ClassInfo, tkObj, PList, False) - 1 do
    begin
      PProp := PList^[intI];
      if PProp^.PropType^.Kind = tkClass then
      begin
        PropNode := Node.PropObjByName(string(PProp^.Name));
        Obj := GetObjectProp(Instance, string(PProp^.Name));
        if (Obj is TPersistent) and Assigned(PropNode) then
        begin
          ReadSeralizeObject(Obj as TPersistent, PropNode, PProp);
          ReadObject(Obj,PropNode);
        end
        else if Assigned(PropNode) then
        begin
          ReadObject(Obj, PropNode);
        end;
      end
      else
      begin
        // Interface Support
      end;
    end;
  finally
    FreeMem(PList, intPropCount * SizeOf(Pointer));
  end;
  ReadChildObject(Instance, Node);
  intPropCount := GetTypeData(Instance.ClassInfo)^.PropCount;

 end;

procedure TObjectReader.ReadChildObject(Obj: TPersistent; Node: IDataNode);
var
  Comp,CompChild:TComponent;
  I:integer;
  ChildNode:IDataNode;
  Item:TCollectionItem;
  Collection:TCollection;
begin
  if Obj is TCollection then
  begin
    Collection :=obj as TCollection;
    for I := 0 to Node.ChildCount - 1 do
    begin

      ChildNode := Node.ChildItem[I];
      Item := TDynamicBuilder.BuildCollectionItem (ChildNode.Attributes['ClassType'], Collection);
      ReadPersistentFromNode(ChildNode, Item);

    end;
  end  else
  if Obj is TComponent then
  begin
    comp :=obj as TComponent;
    for I := 0 to comp.ComponentCount-1 do
    begin
      Compchild :=comp.Components[I];
      ChildNode :=Node.ChildItem[I];
      //ReadPersistentFromNode(ChildNode,compChild);
      ReadPersistentFromNode(ChildNode,CompChild);
    end;
  end;

end;

function TObjectReader.ReadValueFromNode(Node: IDataNode): Variant;
begin
  result := Node.Value;
end;

procedure TObjectReader.ReadSeralizeObject(Obj: TPersistent; Node: IDataNode;
    PProp: PPropInfo);
begin
  if Obj is TPersistent then
  begin
    ReadPersistentFromNode(Node, Obj);
  end
  else
  begin
    ReadObject(Obj, Node);
  end;
end;

procedure TObjectReader.ReadNodeToObject(const Node: IDataNode;
  Obj: TPersistent);

begin
  ReadPersistentFromNode(Node, Obj);
end;

procedure TObjectReader.ReadFileToObject(const FileName: string;
  Obj: TPersistent);

begin
  FIAdp.LoadFromFile(FileName);
 self.ReadNodeToObject(FIAdp.RootNode,Obj);
end;

procedure TObjectReader.SetSeralizePropValue(Obj: TPersistent; Value: Variant;
    PProp: PPropInfo);
begin
  if Value <> '' then
  begin
    case PProp^.PropType^.Kind of
      tkEnumeration:
        begin
          SetEnumProp(Obj, string(PProp^.Name), Value);
        end;
      tkMethod:
        begin
          // SetMethodProp();
          // SetMethodProp(Obj,PProp.Name);
        end;
      tkString:
        SetStrProp(Obj, string(PProp^.Name), Value);
      tkWString:
        SetWideStrProp(Obj, string(PProp^.Name), Value);
      tkLString:
        SetStrProp(Obj, string(PProp^.Name), Value);
      {$IFDEF  FPC}
      tkAString:
        SetStrProp(Obj, string(PProp^.Name), Value);
      {$ENDIF}
    else
      begin
        SetPropValue(Obj, string(PProp^.Name), Value);
      end;
    end;
  end
  else
  begin
    //
  end
end;

procedure TMyCustomReader.ReadObject(Obj: TObject; const PropNode: IDataNode);
begin

  // 增加对TStream的支持
  if Obj is TStream then
  begin
    ReadStream(TStream(Obj), PropNode);
  end;
end;

procedure TMyCustomReader.ReadChildObject(Obj: TPersistent; Node: IDataNode);
begin
  inherited;
  if Obj is TStrings then
  begin
    self.ReadStrings(TStrings(Obj), Node);
  end;
  if Obj is TPicture then
  begin
    self.ReadPicture(TPicture(Obj), Node);
    exit;
  end;
end;

procedure TMyCustomReader.ReadPicture(const Pic: TPicture;
  const Node: IDataNode);
var
  Mem: TMemorystream;
  str:string;
begin
  Mem := TmemoryStream.Create();
  try
    //第0项用于保存 数据data
    str :=Node.Value;

    Base64StringToStream(MEM,Node.DATA);
    MEm.Position:=0;
    Pic.LoadFromStream(MEM);
    //Pic.LoadFromStream(MEM);
  finally
    FreeAndNil(Mem);
  end;
end;

procedure TMyCustomReader.ReadStream(Stream: TStream; Node: IDataNode);

begin
  Base64StringToStream(Stream,Node.childItem[0].Value);
end;

procedure TMyCustomReader.ReadStrings(Obj: TStrings; Node: IDataNode);
var
  intI: Integer;
begin
  for intI := 0 to Node.ChildCount - 1 do
  begin
    Obj.Add(Node.ChildItem[intI].Value);
  end;
end;

procedure TMyCustomWriter.SaveGraphic(Obj: TGraphic; Node: IDataNode);
var
  Mem: TMemoryStream;
begin
  obj.ClassName;
  if Obj.Empty then
    exit;
  Mem := TMemoryStream.Create;
  try
    mem.Position :=0;
    Obj.SaveToStream(Mem);
    Node.DATA :=StreamToBase64String(Mem);
  finally
    FreeAndNil(Mem);
  end;
end;

procedure TMyCustomWriter.SavePicture(Pic: TPicture; Node: IDataNode);
var
  Mem: TMemoryStream;
begin
  Mem := TMemoryStream.Create();
  try
    if Assigned(Pic) then
    begin
      pic.SaveToStream(Mem);
      Node.DATA :=StreamToBase64String(Mem);
    end;
  finally
    FreeAndNil(Mem);
  end;
end;

procedure TMyCustomWriter.SaveStream(const Stream: TStream; Node: IDataNode);

begin
  Node.DATA :=StreamToBase64String(Stream);
end;

procedure TMyCustomWriter.SaveTStrins(const Obj: TStrings;
  const Node: IDataNode);
var
  intI: Integer;
  Child: IDataNode;
begin
  for intI := 0 to Obj.Count - 1 do
  begin
    Child := Node.AddChild();
    Child.Value := Obj.Strings[intI];
  end;
end;

procedure TMyCustomWriter.WriteObject(Prop: PPropInfo; Node: IDataNode;
  Obj: TObject);
begin
  if Obj is TStrings then
  begin
    SaveTStrins(TStrings(Obj), Node);
  end else
  if Obj is TGraphic then
  begin
    SaveGraphic(TIcon(Obj), Node);
  end else
  if Obj is TPicture then
  begin
    SavePicture(TPicture(Obj), Node);
  end else
  if Obj is TStream then
  begin
    // 增加对TStream类的支持
    SaveStream(TStream(Obj), Node);
  end;
end;

procedure TMyCustomWriter.WriteChildObject(const Obj: TPersistent; Node:
    IDataNode);
begin
  inherited;
 
end;
initialization
  RegisterClass(TObjectReader);
  RegisterClass(TObjectWriter);
  RegisterClass(TMyCustomReader);
  RegisterClass(TMyCustomWriter);
end.
