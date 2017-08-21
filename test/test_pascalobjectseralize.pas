unit test_pascalobjectseralize;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, typinfo, pascalobject_seralize, intf_seralizeadapter,
  fpc_seralizeadapter, base64, dbugintf, dbugmsg, frm_Test, fpcunit, testutils,
  testregistry;

type

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
    procedure TestrfrmTest;
    procedure TestwfrmTest;
  end;

implementation

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
       SendDebug('PropName:'+Pinfo^.Name);
    {$ENDIF}
  end;
  SendSeparator;
  finally
    FreeMem(PList, intPropCount * SizeOf(Pointer));
  end;


end;

procedure TestSearalizeObject.TestwfrmTest;
var
  Iadp:IDataAdapter;
  frm:TfrmTest;
begin
  iadp :=TFPCXmlAdapter.Create;
  frm :=TfrmTest.Create(nil);
  try
  fW.Adapter :=Iadp;
  frm.ShowModal;
  fw.WriteObjectToFile('e:\test.xml',frm);
  finally
    FreeAndnil(frm);
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

procedure TestSearalizeObject.TestrfrmTest;
var
  Iadp:IDataAdapter;
  frm:TfrmTest;
begin
  iadp :=TFPCXmlAdapter.Create;
  frm :=TfrmTest.Create(nil);
  try

    fr.Adapter :=Iadp;
    fr.ReadFileToObject('e:\test.xml',frm) ;
    frm.ShowModal;
  finally
    FreeAndnil(frm);
  end;


end;





initialization
  RegisterTest(TestPascalSeralize);
  RegisterTest(TestSearalizeObject);
end.

