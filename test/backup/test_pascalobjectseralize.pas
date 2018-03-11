unit test_pascalobjectseralize;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, typinfo, pascalobject_seralize, intf_seralizeadapter,
  fpc_seralizeadapter, dateutils, base64, dbugintf, dbugmsg, frm_Test, fpcunit,
  testutils, testregistry;

type

  { TDataItem }

  TDataItem =Class(TcollectionItem)
  private
    FDateTime: TDateTime;
    fdbl: double;
    FInteger: integer;
    FStr: string;
  published
    property testInteger:integer read FInteger write FInteger;
    property testDate:TDateTime read FDateTime write FDateTime;
    property testString:string read FStr write FStr;
    property testFloat:double read fdbl write fdbl;
  end;

  { TDataCollection }

  TDataCollection=class(TCollection)

  private
    FName: string;
    function GetDataItem(Index: integer): TDataItem;
  public
    function AddDataItem:TDataItem;
    property DataItem[Index:integer]:TDataItem read GetDataItem;
  published
    property datacollectionName:string read FName write FName;
  end;
  { TestPascalSeralize }

  TestPascalSeralize=class(TTestCase)
  protected
    Ffrm:TfrmTest;
    procedure Setup;override;
    procedure TearDown;override;
  published
    procedure TestGetPropInfo;
  end;

  { TestSearalizeObject }

  TestSearalizeObject= class(TTestCase)
  protected
    FW:TMyCustomWriter;
    FR:TMyCustomReader;

    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestReadfrmTest;
    procedure TestWritefrmTest;
    procedure TestWriteCollection;
    procedure TEstReadCollection;

    procedure TestWriteFrmTest_JsonAdapter;
    procedure TestReadFrmTest_JsonAdapter;
    procedure TestWriteCollection_Json;
    procedure TestReadCollection_Json;
    procedure TestWriterCollection_XML;
    procedure TestReadCollection_XML;
  end;
function SampleDataPath:string;
implementation

function SampleDataPath: string;
begin
  result :=GetCurrentDir+'\testData\';
end;

{ TDataCollection }

function TDataCollection.GetDataItem(Index: integer): TDataItem;
begin
  result :=self.Items[Index] as TDataItem;
end;

function TDataCollection.AddDataItem: TDataItem;
begin
  result :=TDataItem.Create(self);
end;



{ TestPascalSeralize }

procedure TestPascalSeralize.Setup;
begin
  inherited ;
  fFrm :=TfrmTest.Create(nil);
end;

procedure TestPascalSeralize.TearDown;
begin
  FreeAndNil(fFrm);
  inherited ;
end;

procedure TestPascalSeralize.TestGetPropInfo;
var
  I: Integer;
  PList: PPropList;
  intPropCount: Integer;
  PInfo: PPropInfo;
begin


  // Save Collection
  intPropCount := GetTypeData(ffrm.ClassInfo)^.PropCount;
  GetMem(PList, intPropCount * SizeOf(Pointer));
  try
  intPropCount := GetPropList(ffrm.ClassInfo, tkAny, PList);
  for I := 0 to intPropCount-1 do
  begin
    PInfo :=PList^[I];

    {$IFOPT D+}
    //Please run C:\lazarus\tools\debugserver\debugserver.exe

      SendInteger('Prop Index:',Pinfo^.PropProcs);
      SendDebug('PropName:'+Pinfo^.Name);
    {$ENDIF}
  end;
  SendSeparator;
  finally
    FreeMem(PList, intPropCount * SizeOf(Pointer));
  end;


end;

procedure TestSearalizeObject.TestWritefrmTest;
var
  Iadp:IDataAdapter;
  frm:TfrmTest;
begin
  iadp :=TFPCXmlAdapter.Create;
  frm :=TfrmTest.Create(nil);
  try
  fW.Adapter :=Iadp;
  frm.Image1.Picture.LoadFromFile(SampleDataPath+'test.png');
  frm.ShowModal;
  fw.WriteObjectToFile(SampleDataPath+'test.xml',frm);
  finally
    FreeAndnil(frm);
  end;

end;

procedure TestSearalizeObject.TestWriteCollection;
var
  coll:TDataCollection;
  Item:TDataItem;
  IAdp:TFPCXmlAdapter;
begin
  Coll :=TDatacollection.Create(TdataItem);
  IAdp :=TFPCXmlAdapter.Create;
  try
    Coll.datacollectionName:='TestDataName';

    Item :=coll.AddDataItem;
    item.testDate:=now;
    item.testFloat:=3.14;
    item.testInteger:=28;
    item.testString:='hello world';
    fw.Adapter :=IAdp;
    fw.WriteObjectToFile(SampleDataPath+'testCollection.xml',Coll);

  finally
    FreeAndNil( Coll);
  end;
end;

procedure TestSearalizeObject.TEstReadCollection;
var
  coll:TDataCollection;
  Item:TDataItem;
  IAdp:TFPCXmlAdapter;
begin
  Coll :=TDatacollection.Create(TdataItem);
  IAdp :=TFPCXmlAdapter.Create;
  try
    fr.Adapter :=IAdp;
    fr.ReadFileToObject(SampleDataPath+'testcollection.xml',coll);
    checkequals(Coll.datacollectionName,'TestDataName');
    Item :=Coll.DataItem[0];

    checkequals(item.testString,'hello world');
    checkequals(item.testInteger,28);
    checkequals(item.testFloat,3.14);
    checkequals(YearOf(item.testDate),yearOf(now));

  finally
     FreeAndNil( Coll);
  end;

end;

procedure TestSearalizeObject.TestWriteFrmTest_JsonAdapter;
var
  Iadp:IDataAdapter;
  frm:TfrmTest;
begin
  iadp :=TFPCJsonAdapter.Create;
  frm :=TfrmTest.Create(nil);
  try
  fW.Adapter :=Iadp;
  frm.Image1.Picture.LoadFromFile(SampleDataPath+'test.png');
  frm.ShowModal;
  fw.WriteObjectToFile(SampleDataPath+'test.json',frm);
  finally
    FreeAndnil(frm);
  end;
end;

procedure TestSearalizeObject.TestReadFrmTest_JsonAdapter;
var
  Iadp:IDataAdapter;
  frm:TfrmTest;
begin
  iadp :=TFPCJsonAdapter.Create;
  frm :=TfrmTest.Create(nil);
  try
    fr.Adapter :=Iadp;
    fr.ReadFileToObject(SampleDataPath+'test.json',frm) ;
    frm.ShowModal;
  finally
    FreeAndnil(frm);
  end;


end;

procedure TestSearalizeObject.TestWriteCollection_Json;
var
  coll:TDataCollection;
  Item:TDataItem;
  IAdp:IDataAdapter;
begin
  Coll :=TDatacollection.Create(TdataItem);
  IAdp :=TFPCJsonAdapter.Create;
  try
    Coll.datacollectionName:='TestDataName';

    Item :=coll.AddDataItem;
    item.testDate:=now;
    item.testFloat:=3.14;
    item.testInteger:=28;
    item.testString:='hello world';
    fw.Adapter :=IAdp;
    fw.WriteObjectToFile(SampleDataPath+'testCollection.Json',Coll);

  finally
    FreeAndNil( Coll);
  end;

end;

procedure TestSearalizeObject.TestReadCollection_Json;
var
  coll:TDataCollection;
  Item:TDataItem;
  IAdp:IDataAdapter;
begin
  Coll :=TDatacollection.Create(TdataItem);
  IAdp :=TFPCJsonAdapter.Create;
  try
    fr.Adapter :=IAdp;
    fr.ReadFileToObject(SampleDataPath+'testcollection.Json',coll);
    checkequals(Coll.datacollectionName,'TestDataName');
    Item :=Coll.DataItem[0];

    checkequals(item.testString,'hello world');
    checkequals(item.testInteger,28);
    checkequals(item.testFloat,3.14);
    checkequals(YearOf(item.testDate),yearOf(now));

  finally
     FreeAndNil( Coll);
  end;

end;

procedure TestSearalizeObject.TestWriterCollection_XML;
var
  coll:TDataCollection;
  Item:TDataItem;
  IAdp:IDataAdapter;
begin
  Coll :=TDatacollection.Create(TdataItem);
  IAdp :=TFPCXmlAdapter.Create;
  try
    Coll.datacollectionName:='TestDataName';

    Item :=coll.AddDataItem;
    item.testDate:=now;
    item.testFloat:=3.14;
    item.testInteger:=28;
    item.testString:='hello world';
    fw.Adapter :=IAdp;
    fw.WriteObjectToFile(SampleDataPath+'testCollection.XML',Coll);

  finally
    FreeAndNil( Coll);
  end;
end;

procedure TestSearalizeObject.TestReadCollection_XML;
var
  coll:TDataCollection;
  Item:TDataItem;
  IAdp:IDataAdapter;
begin
  Coll :=TDatacollection.Create(TdataItem);
  IAdp :=TFPCXmlAdapter.Create;
  try
    fr.Adapter :=IAdp;
    fr.ReadFileToObject(SampleDataPath+'testcollection.Json',coll);
    checkequals(Coll.datacollectionName,'TestDataName');
    Item :=Coll.DataItem[0];

    checkequals(item.testString,'hello world');
    checkequals(item.testInteger,28);
    checkequals(item.testFloat,3.14);
    checkequals(YearOf(item.testDate),yearOf(now));

  finally
     FreeAndNil( Coll);
  end;
end;

procedure TestSearalizeObject.SetUp;
begin
  FW :=TMyCustomWriter.Create(nil);
  Fr :=TMyCustomReader.Create(nil);
end;

procedure TestSearalizeObject.TearDown;
begin
  FreeAndnil(Fr);
  FreeAndNil(FW);
end;



procedure TestSearalizeObject.TestReadfrmTest;
var
  Iadp:IDataAdapter;
  frm:TfrmTest;
begin
  iadp :=TFPCXmlAdapter.Create;
  frm :=TfrmTest.Create(nil);
  try
    fr.Adapter :=Iadp;
    fr.ReadFileToObject(SampleDataPath+'test.xml',frm) ;
    frm.ShowModal;
  finally
    FreeAndnil(frm);
  end;


end;





initialization
  RegisterClass(TDatacollection);
  RegisterClass(TDataItem);
  RegisterTest(TestPascalSeralize);
  RegisterTest(TestSearalizeObject);
end.

