unit frm_Test;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, ActnList;

type

  { TfrmTest }

  TfrmTest = class(TForm)
  published
    actTest: TAction;
    ActionList1: TActionList;
    Button1: TButton;
    Image1: TImage;
    procedure actTestExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmTest: TfrmTest;

implementation

{$R *.lfm}

{ TfrmTest }

procedure TfrmTest.FormCreate(Sender: TObject);
begin

end;

procedure TfrmTest.actTestExecute(Sender: TObject);
begin

end;

end.

