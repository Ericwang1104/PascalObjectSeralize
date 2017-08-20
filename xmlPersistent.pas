unit XMLPersistent;

interface

uses  TypInfo, Graphics, Laz_XMLRead, laz2_XMLRead, Laz_XMLWrite, Laz_DOM,
  Laz2_DOM, Variants, SysUtils, base64, Classes;

const
  ROOT_OBJECT = 'XMLPersistent';

{  tkPersistent = [tkInteger, tkChar, tkEnumeration, tkSet, tkClass, tkInterface,
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
  end;

  TObjectWriter = class(TObjectFilter)
  strict private
  private
    procedure WriteProperties(const Obj: TPersistent; Prop: PPropInfo;
      Node: TDOMNode);
    procedure SetClassType(const Obj: TPersistent; Nde: TDOMNode);
    procedure SetPersistentType(const Obj: TPersistent; const Node: TDOMNode);
    procedure WriteXMLData(const Obj: TPersistent; const Nde: TDOMNode);
  strict protected
    procedure SavelCollectionItem(const Obj: TPersistent; const Node: TDOMNode);
  protected
    procedure WriteObject(Prop: PPropInfo; Node: TDOMNode; Obj: TObject);
      virtual; abstract;
    procedure WritePersistentObject(const Obj: TPersistent;
      Node: TDOMNode); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    procedure WriteObjectToXML(const Node: TDOMNode; const Obj: TPersistent);
  published
  end;

  TObjectReader = class(TObjectFilter)
  private
    function PropIsReadOnly(Pinfo: PPropInfo): boolean;
    procedure ReadXMLObject(Obj: TPersistent; Node: TDOMNode; PProp: PPropInfo);
    procedure SetXMLPropValue(Obj: TPersistent; Value: Variant;
      PProp: PPropInfo);
  protected
    procedure ReadCollection(Collection: TCollection; Node: TDOMNode);
    procedure ReadObject(Obj: TObject; const PropNode: TDOMNode);
      virtual; abstract;
    procedure ReadPersistent(Obj: TPersistent; Node: TDOMNode); virtual;
    procedure ReadPersistentFromXML(Node: TDOMNode; Instance: TPersistent); virtual;
    function ReadValueFromXML(Node: TDOMNode): Variant;
  public
    procedure ReadNodeToObject(const Node: TDOMNode; Obj: TPersistent);
  published
  end;

  TMyCustomReader = class(TObjectReader)
  private
    procedure ReadPicture(const Pic: TPicture; const Node: TDOMNode);
    procedure ReadStream(Stream: TStream; Node: TDOMNode);
    procedure ReadStrings(Obj: TStrings; Node: TDOMNode);
  protected
    procedure ReadObject(Obj: TObject; const PropNode: TDOMNode); override;
    procedure ReadPersistent(Obj: TPersistent; Node: TDOMNode); override;
  published
  end;

  TMyCustomWriter = class(TObjectWriter)
  private
    procedure SaveGraphic(Obj: TGraphic; Node: TDOMNode);
    procedure SaveStream(Stream: TStream; Node: TDOMNode);
    procedure SaveTStrins(const Obj: TStrings; const Node: TDOMNode);
  protected
    procedure WriteObject(Prop: PPropInfo; Node: TDOMNode;
      Obj: TObject); override;
    procedure WritePersistentObject(const Obj: TPersistent;
      Node: TDOMNode); override;
  public
  published
    procedure SavePicture(Pic: TPicture; Node: TDOMNode);
  end;

procedure LoadObjFromFile(const Obj: TPersistent; const FileName: string; const
    ClassName: string = 'TMyCustomReader');
procedure SaveObjToFile(const Obj: TPersistent; const FileName: string; const
    ClassName: string = 'TMyCustomWriter');
procedure LoadObjFromStream(const Obj: TPersistent; const aStream: TStream;
    const ClassName: string = 'TMyCustomReader');
procedure SaveObjToStream(Obj: TPersistent; const aStream: TStream; const
    ClassName: string = 'TMyCustomWriter');
}
implementation

{procedure LoadObjFromFile(const Obj: TPersistent; const FileName: string; const
    ClassName: string = 'TMyCustomReader');
var
  aDoc:TXMLDocument;
  reader: TObjectReader;
begin

  reader := TReaderClass( Findclass(ClassName)).Create(nil);
  try

    Laz_XMLRead.ReadXMLFile(aDoc,FileName);
    {Xml.Encoding := 'UTF-8';
    Xml.LoadFromFile(FileName);
    reader.ReadNodeToObject(Xml.DocumentElement, Obj); }
    reader.ReadNodeToObject(aDoc,obj);
  finally
    FreeAndNil(reader);

  end;
end;

procedure SaveObjToFile(const Obj: TPersistent; const FileName: string; const
    ClassName: string = 'TMyCustomWriter');
var

  Writer: TObjectWriter;
  aDoc:TXMLDocument;
begin

  Writer :=TWriterClass(FindClass(ClassName)).Create(nil);
  try
    {Xml.AddChild('XMLOBJECT');
    Writer.WriteObjectToXML(Xml.DocumentElement, Obj);
    Xml.SaveToFile(FileName);}
    writexml(aDoc,FileName);
  finally
    FreeAndNil(Writer);
  end;
end;

procedure LoadObjFromStream(const Obj: TPersistent; const aStream: TStream;
    const ClassName: string = 'TMyCustomReader');
var
  reader: TObjectReader;
  aDoc:TXMLDocument;
begin
  reader := TReaderClass(Findclass(ClassName)).Create(nil);
  try
    aStream.Position := 0;
    {Xml.Encoding := 'UTF-8';
    if aStream.Size > 0 then
    begin
      Xml.LoadFromStream(aStream);
      reader.ReadNodeToObject(Xml.DocumentElement, Obj);
    end; }
    Laz_XMLRead.ReadXMLFile(aDoc,aStream);
    reader.ReadNodeToObject(aDoc,obj);
  finally
    FreeAndNil(reader);
  end;
end;

procedure SaveObjToStream(Obj: TPersistent; const aStream: TStream; const
    ClassName: string = 'TMyCustomWriter');
var
  aDoc:TXMLDocument;
  Writer: TObjectWriter;
begin
  Writer := TWriterClass(FindClass(ClassName)).Create(nil);
  try
    {Xml.AddChild('XMLOBJECT');
    Writer.WriteObjectToXML(Xml.DocumentElement, Obj);
    Xml.SaveToStream(aStream);}
    Writer.WriteObjectToXML(aDoc,obj);

    Laz_XMLWrite.WriteXML(aDoc,aStream);
  finally
    FreeAndNil(Writer);
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
  Node: TDOMNode);
begin
  if Obj is TCollection then
  begin
    SavelCollectionItem(Obj, Node);
    exit;
  end;
end;

procedure TObjectWriter.WriteProperties(const Obj: TPersistent;
  Prop: PPropInfo; Node: TDOMNode);
var
  PropObj: TObject;
  IPropObj: IInterface;
  ObjNOde: TDOMNode;
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
        IPropObj := GetInterfaceProp(Obj, string(Prop.Name));
      end;
    tkMethod:
      begin
        Node.Attributes[string(Prop.Name)] :=
          GetPropValue(Obj, string(Prop.Name));
      end;
    tkEnumeration:
      begin
        Node.Attributes[string(Prop.Name)] :=
          GetEnumProp(Obj, string(Prop.Name));
      end;
    tkSet:
      begin
        Node.Attributes[string(Prop.Name)] :=
          GetSetProp(Obj, string(Prop.Name));
      end;
    tkUnknown, tkInteger, tkChar, tkFloat, tkWChar, tkVariant, tkInt64:
      begin
        Node.Attributes[string(Prop.Name)] :=
          GetPropValue(Obj, string(Prop.Name));
      end;
    tkString, tkLString, tkWString, tkUString:
      begin
        Node.Attributes[string(Prop.Name)] :=
          GetPropValue(Obj, string(Prop.Name));
      end;
    tkArray, tkDynArray:
      begin
        Node.Attributes[string(Prop.Name)] :=
          GetPropValue(Obj, string(Prop.Name));
      end;
    tkRecord:
      begin
        Node.Attributes[string(Prop.Name)] :=
          GetPropValue(Obj, string(Prop.Name));
      end;
  end;
end;

procedure TObjectWriter.SavelCollectionItem(const Obj: TPersistent; const
    Node: TDOMNode);
var
  intI: Integer;
  PropObj: TObject;
  Child: TDOMNode;
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

procedure TObjectWriter.SetClassType(const Obj: TPersistent; Nde: TDOMNode);

begin
  Nde.Attributes['ClassType'] := Obj.ClassName;
end;

procedure TObjectWriter.SetPersistentType(const Obj: TPersistent;
  const Node: TDOMNode);
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

procedure TObjectWriter.WriteObjectToXML(const Node: TDOMNode;
  const Obj: TPersistent);
begin
  WriteXMLData(Obj, Node);
end;

procedure TObjectWriter.WriteXMLData(const Obj: TPersistent;
  const Nde: TDOMNode);
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
  result := Pinfo.SetProc = nil;
end;

procedure TObjectReader.ReadCollection(Collection: TCollection; Node:
    TDOMNode);
var
  intI: Integer;
  Child: TDOMNode;
  FItem: TCollectionItem;
begin
  for intI := 0 to Node.ChildNodes.Count - 1 do
  begin
    if Node.ChildNodes[intI].Name = 'Item' then
    begin
      Child := Node.ChildNodes[intI];
      FItem := TDynamicBuilder.BuildCollectionItem
        (Child.Attributes['ClassType'], Collection);
      ReadPersistentFromXML(Child, FItem);
    end;
  end;
end;

procedure TObjectReader.ReadPersistentFromXML(Node: TDOMNode; Instance:
    TPersistent);
var
  intI: Integer;
  intPropCount: Integer;
  PProp: PPropInfo;
  PList: PPropList;
  PropNode: TDOMNode;
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
        SetXMLPropValue(Instance, Node.Attributes[string(PProp.Name)], PProp);
      end;
    end;

    for intI := 0 to GetPropList(Instance.ClassInfo, tkObj, PList, False) - 1 do
    begin
      PProp := PList^[intI];
      if PProp.PropType^.Kind = tkClass then
      begin

        PropNode := Node.Find(string(PProp.Name));
        Obj := GetObjectProp(Instance, string(PProp.Name));
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

procedure TObjectReader.ReadPersistent(Obj: TPersistent; Node: TDOMNode);
begin
  if Obj is TCollection then
  begin
    ReadCollection((Obj as TCollection), Node);
    exit;
  end ;

end;

function TObjectReader.ReadValueFromXML(Node: TDOMNode): Variant;
begin
  result := Node.NodeValue;
end;

procedure TObjectReader.ReadXMLObject(Obj: TPersistent; Node: TDOMNode;
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

procedure TObjectReader.ReadNodeToObject(const Node: TDOMNode;
  Obj: TPersistent);
begin
  ReadPersistentFromXML(Node, Obj);
end;

procedure TObjectReader.SetXMLPropValue(Obj: TPersistent; Value: Variant;
  PProp: PPropInfo);
begin
  if Value <> '' then
  begin
    case PProp.PropType^.Kind of
      tkEnumeration:
        begin
          SetEnumProp(Obj, string(PProp.Name), Value);
        end;
      tkMethod:
        begin
          // SetMethodProp();
          // SetMethodProp(Obj,PProp.Name);
        end;
      tkString:
        SetStrProp(Obj, string(PProp.Name), Value);
      tkWString:
        SetWideStrProp(Obj, string(PProp.Name), Value);
      tkLString:
        SetStrProp(Obj, string(PProp.Name), Value);
    else
      begin
        SetPropValue(Obj, string(PProp.Name), Value);
      end;
    end;
  end
  else
  begin
    //
  end
end;

procedure TMyCustomReader.ReadObject(Obj: TObject; const PropNode: TDOMNode);
begin
  inherited;
  // 增加对TStream的支持
  if Obj is TStream then
  begin
    ReadStream(TStream(Obj), PropNode);
  end;
end;

procedure TMyCustomReader.ReadPersistent(Obj: TPersistent; Node: TDOMNode);
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
  const Node: TDOMNode);
var
  str: TStringStream;
  MemStream: TMemoryStream;
begin
  str := TStringStream.Create(Node.NodeValue);
  MemStream := TMemoryStream.Create;
  try
    str.Position := 0;
    DecodeStream(str, MemStream);
    MemStream.Position := 0;
    Pic.Bitmap.LoadFromStream(MemStream);
  finally
    FreeAndNil(str);
    FreeAndNil(MemStream);
  end;
end;

procedure TMyCustomReader.ReadStream(Stream: TStream; Node: TDOMNode);
var
  str: TStringStream;
begin
  str := TStringStream.Create(Node.NodeValue);
  try
    str.Position := 0;
    Stream.Position := 0;
    DecodeStream(str, Stream);
  finally
    FreeAndNil(str);
  end;
end;

procedure TMyCustomReader.ReadStrings(Obj: TStrings; Node: TDOMNode);
var
  intI: Integer;
begin
  for intI := 0 to Node.ChildNodes.Count - 1 do
  begin
    Obj.Add(Node.ChildNodes[intI].NodeValue);
  end;
end;

procedure TMyCustomWriter.SaveGraphic(Obj: TGraphic; Node: TDOMNode);
var
  Stream: TMemoryStream;
  str: TStringStream;
begin
  if Obj.Empty then
    exit;
  Stream := TMemoryStream.Create;
  str := TStringStream.Create('');
  try
    str.Position := 0;
    Obj.SaveToStream(Stream);
    Stream.Position := 0;
    EncodeStream(Stream, str);
    Node.NodeValue := str.DataString;
  finally
    FreeAndNil(str);
    FreeAndNil(Stream);
  end;
end;

procedure TMyCustomWriter.SavePicture(Pic: TPicture; Node: TDOMNode);
var
  Stream: TMemoryStream;
  str: TStringStream;
begin
  Stream := TMemoryStream.Create();
  str := TStringStream.Create('');
  try
    str.Position := 0;
    if Assigned(Pic) then
    begin
      Pic.Bitmap.SaveToStream(Stream);
      Stream.Position := 0;
      EncodeStream(Stream, str);
      Node.NodeValue := str.DataString;
    end;
  finally
    FreeAndNil(str);
    FreeAndNil(Stream);
  end;
end;

procedure TMyCustomWriter.SaveStream(Stream: TStream; Node: TDOMNode);
var
  str: TStringStream;
begin
  str := TStringStream.Create('');
  try
    str.Position := 0;
    Stream.Position := 0;
    EncodeStream(Stream, str);
    Node.NodeValue := str.DataString;
  finally
    FreeAndNil(str);
  end;
end;

procedure TMyCustomWriter.SaveTStrins(const Obj: TStrings;
  const Node: TDOMNode);
var
  intI: Integer;
  Child: TDOMNode;
begin
  for intI := 0 to Obj.Count - 1 do
  begin
    Child := Node.AddChild('StringItem');
    Child.NodeValue := Obj.Strings[intI];
  end;
end;

procedure TMyCustomWriter.WriteObject(Prop: PPropInfo; Node: TDOMNode;
  Obj: TObject);
begin
  inherited;
  // 增加对TStream类的支持
  if Obj is TStream then
  begin
    SaveStream(TStream(Obj), Node);
  end;
end;

procedure TMyCustomWriter.WritePersistentObject(const Obj: TPersistent;
  Node: TDOMNode);
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
  RegisterClass(TMyCustomWriter); }
end.
