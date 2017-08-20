unit pascalobject_seralize;

interface

uses  TypInfo, Graphics, Variants, SysUtils, base64,intf_SeralizeadApter, Classes;

const
  ROOT_OBJECT = 'XMLPersistent';

 tkPersistent = [tkInteger, tkChar, tkEnumeration, tkSet, tkClass, tkInterface,
    tkFloat, tkWChar, tkString, tkLString, tkWString, tkUString, tkVariant,
    tkInt64, tkRecord, tkArray, tkDynArray, tkUnknown];
  tkObj = [tkClass, tkInterface];
  tkStr = [tkString, tkLString, tkWString, tkUString];
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
    procedure WriteXMLData(const Obj: TPersistent; const Nde: IDataNode);
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
    procedure ReadPersistentFromXML(Node: IDataNode; Instance: TPersistent); virtual;
    function ReadValueFromXML(Node: IDataNode): Variant;
  public
    procedure ReadNodeToObject(const Node: IDataNode; Obj: TPersistent);
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

  TMyCustomWriter = class(TObjectWriter)
  private
    procedure SaveGraphic(Obj: TGraphic; Node: IDataNode);
    procedure SaveStream(Stream: TStream; Node: IDataNode);
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



implementation






{ ******************************* TDynamicBuilder ******************************** }
class function TDynamicBuilder.BuildCollection(aClassName: string;
  CollectionItemClass: TCollectionItemClass): TCollection;
begin
  result := TCollectionClass(FindClass(ClassName)).Create(CollectionItemClass);
end;

class function TDynamicBuilder.BuildCollectionItem(aClassName: string;
  Collection: TCollection): TCollectionItem;
begin
  result := TCollectionItemClass(FindClass(ClassName)).Create(Collection);
end;

class function TDynamicBuilder.BuildComponent(const aClassName: string;
  const AOwner: TComponent): TComponent;
begin
  result := TComponentClass(FindClass(ClassName)).Create(AOwner);
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
      WriteXMLData(CompChild,Child);

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

          WriteXMLData(TPersistent(PropObj), ObjNOde);
        end
        else
        begin
          ObjNOde := Node.AddChild(string(Prop^.Name));
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
    tkString, tkLString, tkWString, tkUString:
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
      WriteXMLData((PropObj as TPersistent), Child);
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
  WriteXMLData(Obj,Node);
  FIAdp.SaveToFile(FileName);
end;

procedure TObjectWriter.WriteXMLData(const Obj: TPersistent;
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
      ReadPersistentFromXML(Child, FItem);
    end;
  end;
end;

procedure TObjectReader.ReadPersistentFromXML(Node: IDataNode; Instance:
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
begin
  if Obj is TCollection then
  begin
    ReadCollection((Obj as TCollection), Node);
    exit;
  end ;

end;

function TObjectReader.ReadValueFromXML(Node: IDataNode): Variant;
begin
  result := Node.Value;
end;

procedure TObjectReader.ReadXMLObject(Obj: TPersistent; Node: IDataNode;
  PProp: PPropInfo);
begin
  if Obj is TPersistent then
  begin
    ReadPersistentFromXML(Node, Obj);
  end
  else
  begin
    ReadObject(Obj, Node);
  end;
end;

procedure TObjectReader.ReadNodeToObject(const Node: IDataNode;
  Obj: TPersistent);
begin
  ReadPersistentFromXML(Node, Obj);
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
  str: TStringStream;
  Base64:TBase64DecodingStream;
begin
  str := TStringStream.Create(Node.Value);
  Base64:=TBase64DecodingStream.Create(str);
  try
    str.Position := 0;
    base64.Position:=0;
    Pic.Bitmap.LoadFromStream(Base64);
  finally
    FreeAndNil(str);
    FreeAndNil(Base64);
  end;
end;

procedure TMyCustomReader.ReadStream(Stream: TStream; Node: IDataNode);
var
  str: TStringStream;
  b64Stream:TBase64DecodingStream;
begin
  str := TStringStream.Create(Node.Value);
  b64Stream :=TBase64DecodingStream.Create(str);
  try
    str.Position := 0;
    Stream.Position := 0;
    stream.CopyFrom(b64Stream,b64Stream.Size);
  finally
    FreeAndNil(str);
  end;
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
  Stream: TMemoryStream;
  str: TStringStream;
  bs64:TBase64EncodingStream;

begin
  obj.ClassName;
  if Obj.Empty then
    exit;
  Stream := TMemoryStream.Create;
  str := TStringStream.Create('');
  try
    str.Position := 0;
    Obj.SaveToStream(Stream);
    Stream.Position := 0;
    bs64:=TBase64EncodingStream.Create(stream);
    try
      bs64.Position:= 0;
      str.CopyFrom(bs64,bs64.Size);
      Node.Value := str.DataString;
    finally
      FreeAndNil(bs64);
    end;
  finally
    FreeAndNil(str);
    FreeAndNil(Stream);
  end;
end;

procedure TMyCustomWriter.SavePicture(Pic: TPicture; Node: IDataNode);
var
  Mem: TMemoryStream;
  str: TStringStream;
  bs64:TBase64EncodingStream;
  n:string;
begin
  Mem := TMemoryStream.Create();
  str := TStringStream.Create('');
  try
    if Assigned(Pic) then
    begin
      Pic.Bitmap.SaveToStream(Mem);
      Mem.Position := 0;
      bs64:=TBase64EncodingStream.Create(str);
      try
        Bs64.CopyFrom(Mem,mem.Size);
        n :=Node.NodeName;
        Node.Value := str.DataString;
      finally
        FreeAndNil(BS64);
      end;

    end;
  finally
    FreeAndNil(str);
    FreeAndNil(Mem);
  end;
end;

procedure TMyCustomWriter.SaveStream(Stream: TStream; Node: IDataNode);
var
  str: TStringStream;
  bs64:TBase64EncodingStream;
begin
  str := TStringStream.Create('');
  try
    str.Position := 0;
    Stream.Position := 0;
    bs64 :=TBase64EncodingStream.Create(stream);
    try
      bs64.Position:=0;
      str.CopyFrom(bs64,bs64.Size);
      Node.Value := str.DataString;

    finally
      FreeAndnil(Bs64);
    end;
  finally
    FreeAndNil(str);
  end;
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
