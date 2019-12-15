unit UListVersoes;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, CheckLst, Buttons, ExtCtrls, Usuario, Versao, MShoutProtocol, Menus, UGlobal;

type
  TfrmListVersoes = class(TForm)
    pnlVersoes: TPanel;
    lbl6: TLabel;
    shpClose: TShape;
    lblClose: TLabel;
    chkLst_ListaVersoes: TCheckListBox;
    shp1: TShape;
    pnl1: TPanel;
    lblQtde: TLabel;
    btnConectarVersoes: TSpeedButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure lblCloseClick(Sender: TObject);
    procedure chkLst_ListaVersoesClickCheck(Sender: TObject);
    procedure lblCloseMouseEnter(Sender: TObject);
    procedure lblCloseMouseLeave(Sender: TObject);
    procedure btnConectarVersoesClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    fSemPai:Boolean;
    fHandlePrincipal:THandle;
    fSender:TObject;
    function CountCheck(chkLst:TCheckListBox):Integer;
  public
    { Public declarations }
    fArrayIDVersoes:Array of String;
    fArrayIDVersoesChecked:ArrayOfInteger;

    procedure CreateParams(var Params: TCreateParams); override;
    procedure PreencheListBoxVersoes(Lista:TListVersao);
    function GetCheckedIndexes(pListaVersoes :TListVersao):ArrayOfInteger;

    constructor Create(AOwner: TComponent ; pSemPai:Boolean); overload;
    property  SemPai : Boolean read fSemPai write fSemPai;
    property  HandlePrincipal : THandle read fHandlePrincipal write fHandlePrincipal;
    property  SenderObj : TObject read fSender write fSender;
  end;

var
  frmListVersoes: TfrmListVersoes;

const
  sHideTitle = '$Versões';

implementation

{$R *.dfm}

{ TfrmListVersoes }

procedure TfrmListVersoes.PreencheListBoxVersoes(Lista: TListVersao);
var
  i:Integer;
begin
    chkLst_ListaVersoes.Clear;
    SetLength(fArrayIDVersoes, Lista.Count);

    for i := 0 To (Lista.Count-1) Do
    begin
        chkLst_ListaVersoes.Items.Add(Lista.Items[i].Nome);
        fArrayIDVersoes[i] := Lista.Items[i].ID;
    end;
end;

procedure TfrmListVersoes.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Action         := caFree;
    frmListVersoes := nil;
end;

procedure TfrmListVersoes.lblCloseClick(Sender: TObject);
begin
    Close;
end;

procedure TfrmListVersoes.chkLst_ListaVersoesClickCheck(Sender: TObject);
begin
    lblQtde.Caption := 'Versões: ' + IntToStr(CountCheck(chkLst_ListaVersoes));
end;

function TfrmListVersoes.CountCheck(chkLst: TCheckListBox): Integer;
var
  I:Integer;
begin
    Result := 0;
    for I:= 0 To chkLst_ListaVersoes.Count-1 Do
    Begin
        If chkLst_ListaVersoes.Checked[I] then
           Inc(Result);
    end;
end;

procedure TfrmListVersoes.lblCloseMouseEnter(Sender: TObject);
begin
    shpClose.Visible := True;
end;

procedure TfrmListVersoes.lblCloseMouseLeave(Sender: TObject);
begin
    shpClose.Visible := False;
end;

procedure TfrmListVersoes.CreateParams(var Params: TCreateParams);
begin
  inherited;
  if SemPai Then
     Params.WndParent := 0;
end;

constructor TfrmListVersoes.Create(AOwner: TComponent ; pSemPai: Boolean);
begin
    SemPai := pSemPai;
    inherited Create(AOwner);

    Self.Caption := sHideTitle;
end;

procedure TfrmListVersoes.btnConectarVersoesClick(Sender: TObject);
begin
    If CountCheck(chkLst_ListaVersoes) <= 0 then
        Exit;

    if SenderObj Is TSpeedButton Then
       Windows.SendMessage( fHandleprincipal , WM_CONECTAR , SC_SPEEDBUTTON, 0)
    Else
    if SenderObj Is TMenuItem  Then
       Windows.SendMessage( fHandleprincipal , WM_CONECTAR , SC_MENUITEM, 0);
end;

function TfrmListVersoes.GetCheckedIndexes(pListaVersoes :TListVersao):ArrayOfInteger;
var
  Cnt:Integer;
  Idx, i:Integer;
begin
    Cnt := 0;

    for i := 0 To (pListaVersoes.Count-1) Do
    begin
        If chkLst_ListaVersoes.Checked[i] Then
           Inc(Cnt);
    end;

    SetLength(fArrayIDVersoesChecked, Cnt);
    Idx := 0;

    for i := 0 To (pListaVersoes.Count-1) Do
    begin
        If chkLst_ListaVersoes.Checked[i] Then
        Begin
           fArrayIDVersoesChecked[Idx] := i;
           Inc(Idx);
        End;
    end;

    Result := fArrayIDVersoesChecked;
end;

procedure TfrmListVersoes.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
    If Key = VK_ESCAPE Then
       Close;
end;

end.
