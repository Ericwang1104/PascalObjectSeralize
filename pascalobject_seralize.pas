unit pascalobject_seralize;

interface

uses  TypInfo, Graphics, Variants, SysUtils, base64, intf_SeralizeadApter,
  dbugintf, Classes;

const
  ROOT_OBJECT = 'XMLPersistent';

 tkPersistent = [tkInteger, tkChar, tkEnumeration, tkSet, tkClass, tkInterface,
    tkFloat, tkWChar, tkString, tkLString,tkAString, tkWString, tkUString, tkVariant,
    tkInt64, tkRecord, tkArray, tkDynArray, tkUnknown];
  tkObj = [tkClass, tkInterface];
  tkStr = [tkString, tkLString, tkWString, tkUString,tkAString];
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
    procedure WriteNodeData(const Obj: TPersistent; const Nde: IDataNode);
  strict protected
    procedure SavelCollectionItem(const Obj: TPersistent; const Node: IDataNode);
  protected
    procedure WriteObject(Prop: PPropInfo; Node: IDataNode; Obj: TObject);
      virtual; abstract;
    procedure WritePersistentObject(const Obj: TPersistent;
      Node: IDataNode); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    procedure WriteObjectToFile(FileName:string;const Obj: TPersistent);
  published
  end;

  { TObjectReader }

  TObjectReader = class(TObjectFilter)
  private
    function PropIsReadOnly(Pinfo: PPropInfo): boolean;
    procedure ReadXMLObject(Obj: TPersistent; Node: IDataNode; PProp: PPropInfo);
    procedure SetXMLPropValue(Obj: TPersistent; Value: Variant;
      PProp: PPropInfo);
  protected
    procedure ReadCollection(Collection: TCollection; Node: IDataNode);
    procedure ReadObject(Obj: TObject; const PropNode: IDataNode);
      virtual; abstract;
    procedure ReadPersistent(Obj: TPersistent; Node: IDataNode); virtual;
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
    procedure ReadPersistent(Obj: TPersistent; Node: IDataNode); override;
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
    procedure WritePersistentObject(const Obj: TPersistent;
      Node: IDataNode); override;
  public

  published
    procedure SavePicture(Pic: TPicture; Node: IDataNode);

  end;

function StreamToBase64String(const stream:TStream):string;
procedure Base64StringToStream(Stream:TStream;base64Str:string);
implementation

function StreamToBase64String(const stream: TStream): string;
var
  B64:TBase64EncodingStream;
  str:TStringStream;
begin
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
end;

procedure Base64StringToStream(Stream: TStream; base64Str: string);
var
  B64:TBase64DecodingStream;
  str:TStringStream;

begin
  //
  str :=TstringStream.Create(Base64Str);
  B64 :=TBase64DecodingStream.Create(str);
  try
    Stream.CopyFrom(B64,B64.Size);
  finally
    FreeAndNil(Str);
    FreeAndNil(B64);
  end;
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

procedure TObjectWriter.WritePersistentObject(const Obj: TPersistent;
  Node: IDataNode);
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
      Child :=Node.AddChild(CompChild.Name);
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
          ObjNOde := Node.AddChild(string(Prop^.Name));
          if Assigned(PropObj) then
            WriteNodeData(TPersistent(PropObj), ObjNOde);
        end
        else
        begin
          ObjNOde := Node.AddChild(string(Prop^.Name));
          if Assigned(PropObj) then
            WriteObject(Prop, ObjNOde, PropObj);
        end;
      end;
    tkInterface:
      begin
        IPropObj := GetInterfaceProp(Obj, string(Prop^.Name));
      end;
    tkMethod:
      begin
        Node.Attributes[string(Prop^.Name)] :=
          GetPropValue(Obj, string(Prop^.Name));
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
    tkString, tkLString, tkWString, tkUString,tkAString:
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
  intI: Integer;
  PropObj: TObject;
  Child: IDataNode;
begin
  if Obj is TCollection then
  begin
    for intI := 0 to (Obj as TCollection).Count - 1 do
    begin
      PropObj := (Obj as TCollection).Items[intI];
      Child := Node.AddChild('Item');
      WriteNodeData((PropObj as TPersistent), Child);
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

procedure TObjectWriter.WriteNodeData(const Obj: TPersistent;
  const Nde: IDataNode);
var
  intI: Integer;
  PList: PPropList;
  intPropCount: Integer;
  PPInfo: PPropInfo;
begin
  SetPersistentType(Obj, Nde);
  SetClassType(Obj, Nde);

  // Save Collection
  WritePersistentObject(Obj, Nde);

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
end;

function TObjectReader.PropIsReadOnly(Pinfo: PPropInfo): boolean;
begin
  result := Pinfo^.SetProc = nil;
end;

procedure TObjectReader.ReadCollection(Collection: TCollection; Node:
    IDataNode);
var
  intI: Integer;
  Child: IDataNode;
  FItem: TCollectionItem;
begin
  for intI := 0 to Node.ChildCount - 1 do
  begin
    if Node.ChildItem[intI].NodeName = 'Item' then
    begin
      Child := Node.ChildItem[intI];
      FItem := TDynamicBuilder.BuildCollectionItem
        (Child.Attributes['ClassType'], Collection);
      ReadPersistentFromNode(Child, FItem);
    end;
  end;
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
  ReadPersistent(Instance, Node);
  intPropCount := GetTypeData(Instance.ClassInfo)^.PropCount;
  GetMem(PList, intPropCount * SizeOf(Pointer));
  try
    for intI := 0 to GetPropList(Instance.ClassInfo, tkValue, PList,
      False) - 1 do
    begin
      PProp := PList^[intI];
      if not PropIsReadOnly(PProp) then
      begin
        SetXMLPropValue(Instance, Node.Attributes[string(PProp^.Name)], PProp);
      end;
    end;
    for intI := 0 to GetPropList(Instance.ClassInfo, tkObj, PList, False) - 1 do
    begin
      PProp := PList^[intI];
      if PProp^.PropType^.Kind = tkClass then
      begin
        PropNode := Node.ChildByName(string(PProp^.Name));
        Obj := GetObjectProp(Instance, string(PProp^.Name));
        if (Obj is TPersistent) and Assigned(PropNode) then
        begin
          ReadXMLObject(Obj as TPersistent, PropNode, PProp);
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

end;

procedure TObjectReader.ReadPersistent(Obj: TPersistent; Node: IDataNode);
var
  Comp,CompChild:TComponent;
  I:integer;
  ChildNode:IDataNode;
begin
  if Obj is TCollection then
  begin
    ReadCollection((Obj as TCollection), Node);
    exit;
  end  else
  if Obj is TComponent then
  begin
    comp :=obj as TComponent;
    for I := 0 to comp.ComponentCount-1 do
    begin
      Compchild :=comp.Components[I];
      ChildNode :=Node.ChildByName(compchild.Name);
      ReadPersistentFromNode(ChildNode,compChild);
    end;
  end;

end;

function TObjectReader.ReadValueFromNode(Node: IDataNode): Variant;
begin
  result := Node.Value;
end;

procedure TObjectReader.ReadXMLObject(Obj: TPersistent; Node: IDataNode;
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
 self.ReadNodeToObject(Fiadp.RootNode,Obj);
end;

procedure TObjectReader.SetXMLPropValue(Obj: TPersistent; Value: Variant;
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
      tkAString:
        SetStrProp(Obj, string(PProp^.Name), Value);
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

procedure TMyCustomReader.ReadPersistent(Obj: TPersistent; Node: IDataNode);
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
begin
  Mem := TmemoryStream.Create();
  try
    //第0项用于保存 数据data
    Base64StringToStream(MEM,Node.childItem[0].Value);
    MEm.Position:=0;
    Pic.Bitmap.LoadFromStream(MEM);
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
    Obj.SaveToStream(Mem);
    Node.addData( StreamToBase64String(Mem));
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
      pic.Bitmap.SaveToStream(Mem);
      Node.AddData(StreamToBase64String(Mem));
    end;
  finally
    FreeAndNil(Mem);
  end;
end;

procedure TMyCustomWriter.SaveStream(const Stream: TStream; Node: IDataNode);

begin
  Node.AddData(StreamToBase64String(Stream));
end;

procedure TMyCustomWriter.SaveTStrins(const Obj: TStrings;
  const Node: IDataNode);
var
  intI: Integer;
  Child: IDataNode;
begin
  for intI := 0 to Obj.Count - 1 do
  begin
    Child := Node.AddChild('StringItem');
    Child.Value := Obj.Strings[intI];
  end;
end;

procedure TMyCustomWriter.WriteObject(Prop: PPropInfo; Node: IDataNode;
  Obj: TObject);
begin

  // 增加对TStream类的支持
  if Obj is TStream then
  begin
    SaveStream(TStream(Obj), Node);
  end;
end;

procedure TMyCustomWriter.WritePersistentObject(const Obj: TPersistent;
  Node: IDataNode);
begin
  inherited;
  if Obj is TStrings then
  begin
    SaveTStrins(TStrings(Obj), Node);
    exit;
  end;

  if Obj is TGraphic then
  begin
    SaveGraphic(TIcon(Obj), Node);
    exit;
  end;

  if Obj is TPicture then
  begin
    SavePicture(TPicture(Obj), Node);
    exit;
  end;
end;
initialization
  RegisterClass(TObjectReader);
  RegisterClass(TObjectWriter);
  RegisterClass(TMyCustomReader);
  RegisterClass(TMyCustomWriter);
end.
