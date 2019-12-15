unit UAlerta;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, StdCtrls, Menus, MShoutProtocol, Requisicao, Versao,
  Buttons, UGlobal, ComObj, ShlObj, ImgList, jpeg, HintBalloon, DateUtils;

type
  TCor = (clBranco, clPreto, clVerde, clVermelho, clAmarelo, clPadrao);

  TOperacao   = (alCheck, alConnect, alWaiting, alTimed);
  TCheck_Op   = (coFree, coBusy, coWaitingTimed);
  TConnect_Op = (coSucess, coFail, coFailWaitingTimed);
  TWaiting_Op = (coFila);

  TfrmAlerta = class(TForm)
    lbl_Texto: TLabel;
    TimerBlendExit: TTimer;
    TimerBlendEnter: TTimer;
    lbltitle: TLabel;
    spClose: TShape;
    lblClose: TLabel;
    lbl_Texto2: TLabel;
    lblMinimize: TLabel;
    spMinimize: TShape;
    imgFundo: TImage;
    img_main: TImage;
    shpBar: TShape;
    imgBar: TImage;
    lbl_Texto3: TLabel;
    imgBlock: TImage;
    imgBarraca: TImage;
    imgWarning: TImage;
    imgOK: TImage;
    PopUpAcoes: TPopupMenu;
    mnuDesocupar: TMenuItem;
    mnuEntrarFila: TMenuItem;
    HBVersoes: THintBalloon;
    pnl_HintVersoes: TPanel;
    lblVersoes: TLabel;
    imgVersoes: TImage;
    pnl_HintFila: TPanel;
    lblFila: TLabel;
    imgFila: TImage;
    lblFooter: TLabel;
    lblTraco: TLabel;
    btnAcoes: TSpeedButton;
    HBFila: THintBalloon;
    imgWaiting: TImage;
    mnuSairFila: TMenuItem;
    TimerAtualizacoes: TTimer;
    mnuConectar: TMenuItem;
    mnuSolicitarVersao: TMenuItem;
    pnl_HintPC: TPanel;
    ImgPC: TImage;
    HBPc: THintBalloon;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormShow(Sender: TObject);
    procedure TimerBlendExitTimer(Sender: TObject);
    procedure TimerBlendEnterTimer(Sender: TObject);
    procedure lblCloseMouseEnter(Sender: TObject);
    procedure lblCloseMouseLeave(Sender: TObject);
    procedure imgFundoMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure mnuDesocuparClick(Sender: TObject);
    procedure mnuEntrarFilaClick(Sender: TObject);
    procedure btnAcoesClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure TimerAtualizacoesTimer(Sender: TObject);
    procedure mnuSairFilaClick(Sender: TObject);
    procedure mnuConectarClick(Sender: TObject);
  private
    fMinimized:Boolean;
    fHeightOriginal:Integer;
    fHeightBar:Integer;
    fImageList:TImageList;
    fQtdeFila, fQtdeVersoes:Integer;
    fFila:TFila;
    fVersoes:TListVersao;
    fPCConnected:String;
    IsMenuOpen:Boolean;

    TempoExibicao_MiliSeg:Integer;
    AlphaBlendEnter:Boolean;
    AlphaBlendExit:Boolean;
    ValueAlphaBlend:Byte;

    clockBmp, campBMP:TImage;
    BigLabel:TLabel;

    // Mover Form por qualquer Lugar
    procedure WMMove(var Msg: TWMMove); message WM_MOVE;
    procedure LoadConfig();
    procedure BlendEnter();
    procedure BlendExit();
    procedure WMSysCommand(var Msg: TWMSysCommand); Message WM_SysCommand;
    procedure WMMenuSelect(var Msg: TWMMenuSelect); Message WM_MenuSelect;

    procedure Minimize;
    procedure HidePopups;
    procedure SetFila(F:TFila);
    Function  GetFila():TFila;
    procedure SetPCConnected(S:String);
    Function  GetPCConnected():String;
    procedure SetVersoes(V:TListVersao);
    Function  GetVersoes():TListVersao;
    Function  GetOcupante:String;
    procedure AtualizaVersoes;
    procedure AtualizaFila;
    procedure AtualizaPCConnected;
    function Mensagem1:String;
    function Mensagem2:String;
    function Mensagem3:String;
  public
    { Public declarations }
    CaptionHintVersoes:String;
    CanClose:Boolean;
    Handleprincipal:THandle;
    Operacao:TOperacao;
    Compl_Check  :TCheck_Op;
    Compl_Connect:TConnect_OP;
    Compl_Waiting:TWaiting_Op;
    Fields:TValuesList;
    procedure SetAplhaBlend(BlendEnter, BlendExit:Boolean ; Value:Byte ; TimeActive:Integer=0);
    procedure CreateParams(var Params: TCreateParams); override;
    property ImageList : TImageList read fImageList write fImageList;
    property QtdeVersoes : Integer read fQtdeVersoes write fQtdeVersoes;
    property Fila : TFila read GetFila write SetFila;
    property Versoes : TListVersao read GetVersoes write SetVersoes;
    property PCConnected : String read GetPCConnected write SetPCConnected;
  end;

var
  frmAlerta: TfrmAlerta;

implementation

{$R *.dfm}

{ TfrmAlerta }

procedure TfrmAlerta.FormCreate(Sender: TObject);
Var
  BarraIniciar: HWND; {Barra Iniciar}
  tmAltura: Integer;
  tmRect: TRect;
  I:Integer;
begin
    //localiza o Handle da Barra iniciar
    BarraIniciar    := FindWindow('Shell_TrayWnd', nil);

    //Pega o "retângulo" que envolve a barra e sua altura
    GetWindowRect(BarraIniciar, tmRect);
    tmAltura := tmRect.Bottom - tmRect.Top;

    imgFundo.Align := alCustom;

    // Fixa posição da img_main pois todas as outras herdam posição desta
    img_main.Left  := 23;
    img_main.Top   := 32;
    img_main.Width := 64;
    img_main.Height:= 64;

    Application.HintPause     := 100;
    Application.HintHidePause := 9000;
    Application.HintColor     := $00FFE7CE;

    TimerAtualizacoes.Enabled := False;
    TimerBlendExit.Enabled    := False;
    TimerBlendENter.Enabled   := False;

    With Self Do
    Begin
      Left := (Screen.Width - ClientWidth) - 10;

      if tmRect.Top = -2 then
        tmAltura := 30;

      Top := (Screen.Height - ClientHeight - tmAltura) - 20;
    end;

    // Atribui a todos objetos dos tipos abaixo a Procedure de permitir arrastar FORM
    For I := 0 to ComponentCount - 1 do
    begin
        If Components[i] Is TLabel Then
            TLabel(Components[i]).OnMouseDown  := Self.OnMouseDown
        Else
        If Components[i] Is TImage Then
            TImage(Components[i]).OnMouseDown := Self.OnMouseDown
        Else
        If Components[i] Is TShape Then
            TShape(Components[i]).OnMouseDown := Self.OnMouseDown;
    End;

    Fields := TValuesList.Create;
    fFila  := nil;
end;

procedure TfrmAlerta.FormClose(Sender: TObject; var Action: TCloseAction);
Var
  i:integer;
begin
    HidePopups;

    Action := caFree;
    DesalocarForm(Pointer(Self));
    Self   := nil;
end;

// Faz tela ficar acima de tudo
procedure TfrmAlerta.CreateParams(var Params: TCreateParams);
const
 CS_DROPSHADOW = $00020000;
begin
  inherited;
  Params.WndParent := 0;

  SystemParametersInfo(SPI_SETDROPSHADOW, 0, Pointer(True), 0);
  Params.WindowClass.Style := Params.WindowClass.Style or CS_DROPSHADOW;
end;

// Não permitir Form Sair da tela
procedure TfrmAlerta.WMMove(var Msg: TWMMove);
begin
  if Left < 0 then
     Left := 0;

  if Top < 0 then
     Top := 0;

  if Screen.Width - (Left + Width) < 0 then
     Left := Screen.Width - Width;

  if Screen.Height - (Top + Height) < 0 then
     Top := Screen.Height - Height;
end;

// Mover Form por qualquer Lugar
procedure TfrmAlerta.FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
const
    SC_DRAGMOVE = $F012;
begin
    if Button = mbleft then
    begin
        If UpperCase(TLabel(Sender).Name) = 'LBLCLOSE' Then
           Close
        Else
        If UpperCase(TLabel(Sender).Name) = 'LBLMINIMIZE' Then
        Begin
           Minimize;
        End Else
        Begin
            ReleaseCapture;
            Self.Perform(WM_SYSCOMMAND, SC_DRAGMOVE, 0);
        End;
    end;
end;

procedure TfrmAlerta.FormShow(Sender: TObject);
begin
    LoadConfig;

    // BlendEnter = Entrada suave
    if (AlphaBlendEnter) And (ValueAlphaBlend > 0) Then
    Begin
       // BlendEnter não pode ser codificado no OnShow. Então Chama TimerBlendEnter
       Self.AlphaBlendValue := 0;
       TimerBlendEnter.Enabled := True;
    End Else
    Begin
       if TempoExibicao_MiliSeg > -1 then
          TimerBlendExit.Enabled := True;
    end;
end;

procedure TfrmAlerta.AtualizaVersoes;
Var S:String;
begin
    If not Assigned(Versoes) Then
      Exit;

    S := Versoes.ListToFormatedString(fsDesc_Enter);

    if S = '' Then
    begin
        pnl_HintVersoes.Visible := False;
        imgVersoes.Visible := False;
        lblVersoes.Visible := False;

        imgVersoes.ShowHint       := False;
        lblVersoes.ShowHint       := False;
    end Else
    begin
        lblVersoes.Caption := IntToStr(Versoes.Count);

        pnl_HintVersoes.Visible   := True;
        imgVersoes.Visible        := True;
        lblVersoes.Visible        := True;

        If Operacao = alConnect Then
        Begin
           imgVersoes.Cursor   := crHandPoint;
           imgVersoes.Hint     := 'Alterar';
           imgVersoes.ShowHint := True;
        End;

        With HBVersoes Do
        Begin
            DelToolInfo;
            Text := s;
            AddToolInfo(Handle, pnl_HintVersoes.Handle);
        End;
    end;
end;

procedure TfrmAlerta.AtualizaFila;
Var
  t, s:String;
begin
    If not Assigned(Self.Fila) or (Self.Fila=nil) Or (Self.Fila.Count = 0) Then
    Begin
        pnl_HintFila.Visible := False;
        imgFila.Visible := False;
        lblFila.Visible := False;
    end Else
    Begin
        pnl_HintFila.Visible := True;
        imgFila.Visible  := True;
        lblFila.Visible  := True;
        imgFila.ShowHint := True;
        lblFila.ShowHint := True;

        t  := 'Fila';
        s  := Fila.FilaToFormatedStr(fsNumber_Name_IP);

        With HBFila Do
        Begin
            DelToolInfo;
            Style := sbInformation;
            Text  := s;
            AddToolInfo(Handle, pnl_HintFila.Handle);
        End;

        lblFila.Caption := IntToStr( Fila.Count );
        If Operacao = alWaiting Then
        Begin
            lbltitle.Caption   := Mensagem2;
        End;
    end;
end;


procedure TfrmAlerta.LoadConfig;
var
  bmp:TBitmap;
  idx:integer;
begin
    bmp := TBitmap.Create;

    btnAcoes.Caption   := 'Ações';
    ImageList.GetBitmap(11,btnAcoes.Glyph);
    btnAcoes.Width     := 85;
    BtnAcoes.Visible   := True;

    mnuDesocupar.Visible  := False;
    mnuEntrarFila.Visible := False;
    mnuSairFila.Visible   := False;
    mnuConectar.Visible   := False;
    mnuSolicitarVersao.Visible := False;

    lbl_Texto.Caption  := '';
    lbl_Texto2.Caption := '';
    lbl_Texto3.Caption := '';

    Case Operacao of
      alConnect :
      begin
         If Compl_Connect = coSucess then
         Begin
             lbl_Texto.Font.Color  := clBlue;
             lbl_Texto2.Font.Color := clBlue;
             lbl_Texto3.Font.Color := clBlue;

             lbl_Texto.Caption := 'Acesso Permitido';
             lbltitle.Caption  := 'Ocupando Servidor';
             CanClose          := False;

             mnuDesocupar.Visible := True;

             ImageList.GetBitmap(14,bmp);
             ClockBMP := TImage.Create(Self);
             With ClockBMP Do
             Begin
                 Picture.Bitmap := bmp;
                 Parent         := Self;
                 AutoSize       := True;
                 Left           := lbl_Texto2.Left + (lbl_Texto2.Width div 2) - (lbl_Texto2.Canvas.TextWidth(lbl_Texto2.Caption) div 2) - 5;
                 Top            := lbl_Texto2.Top;
                 Visible        := False;
                 Transparent    := True;
             End;

             TimerAtualizacoes.Enabled := True;

             ImageList.GetBitmap(5,bmp);
             img_main.Picture.Bitmap := imgBarraca.Picture.Bitmap;

             AtualizaVersoes;
             AtualizaFila;
             AtualizaPCConnected;
         end Else
         If Compl_Connect = coFail then
         Begin
             lbl_Texto.Font.Color  := clRed;
             lbl_Texto2.Font.Color := clRed;
             lbl_Texto3.Font.Color := clRed;

             lbl_Texto.Caption := 'Servidor Ocupado';
             lbltitle.Caption  := 'Servidor Ocupado';
             CanClose          := True;

             mnuEntrarFila.Visible := not Find(tfWaiting, idx) And (not Find(tfTimed, idx));

             ImageList.GetBitmap(2,bmp);
             img_main.Picture.Bitmap := imgBlock.Picture.Bitmap;
         end Else
         If Compl_Connect = coFailWaitingTimed then
         Begin
             lbl_Texto.Font.Color  := clRed;
             lbl_Texto2.Font.Color := clRed;
             lbl_Texto3.Font.Color := clRed;

             lbl_Texto.Caption  := 'Aguardando ocupação';
             lbl_Texto2.Caption := 'De: '+ GetOcupante;

             lbltitle.Caption  := 'Aguardando ocupação de usuário';
             CanClose          := True;

             mnuEntrarFila.Visible := not Find(tfWaiting, idx) And (not Find(tfTimed, idx));

             ImageList.GetBitmap(12,bmp);
             img_main.Picture.Bitmap := imgBlock.Picture.Bitmap;

             AtualizaVersoes;
             AtualizaFila;
             AtualizaPCConnected;
         end;
      end;
      alCheck :
      begin
         If Compl_Check = coFree then
         Begin
             AtualizaFila;
             AtualizaPCConnected;

             If (not Assigned(Fila)) or (Assigned(Fila) And (Fila.Count = 0)) Then
             Begin
                 lbl_Texto.Font.Color  := clBlue;
                 lbl_Texto2.Font.Color := clBlue;
                 lbl_Texto3.Font.Color := clBlue;

                 lbl_Texto.Caption := 'Servidor Livre!';
                 lbltitle.Caption  := 'Servidor Livre';
                 CanClose          := True;

                 mnuConectar.Visible    := True;
                 ImageList.GetBitmap(5,bmp);

                 img_main.Picture.Bitmap := imgOK.Picture.Bitmap;
             end Else
             Begin
                 lbl_Texto.Font.Color  := clBlue;
                 lbl_Texto2.Font.Color := clBlue;
                 lbl_Texto3.Font.Color := clBlue;

                 lbl_Texto.Caption := 'Necessário entrar na Fila';
                 lbltitle.Caption  := 'Fila';
                 CanClose          := True;

                 mnuEntrarFila.Visible    := True;

                 ImageList.GetBitmap(2,bmp);
                 img_main.Picture.Bitmap   := imgBlock.Picture.Bitmap;
                 TimerAtualizacoes.Enabled := True;
             end;
         end Else
         If Compl_Check = coBusy then
         Begin
             lbl_Texto.Font.Color  := clOlive;
             lbl_Texto2.Font.Color := clOlive;
             lbl_Texto3.Font.Color := clOlive;

             lbl_Texto.Caption  := 'Servidor Ocupado há ' + GetDifTempoFmt( FloatToDateTime(StrToFloat(Self.Fields.Value['TEMPO'])) );
             lbl_Texto2.Caption := 'Por: '+ GetOcupante;
             lbltitle.Caption   := 'Servidor Ocupado';
                                                                   // lembrar descomentar
             mnuEntrarFila.Visible := not Find(tfWaiting, idx) And // not Find(tfConnected, idx);

             ImageList.GetBitmap(6,bmp);
             img_main.Picture.Bitmap := imgWarning.Picture.Bitmap;
             TimerAtualizacoes.Enabled := True;

             AtualizaVersoes;
             AtualizaFila;
             AtualizaPCConnected;
         end Else
         If Compl_Check = coWaitingTimed then
         Begin
             lbl_Texto.Font.Color  := clRed;
             lbl_Texto2.Font.Color := clRed;
             lbl_Texto3.Font.Color := clRed;

             lbl_Texto.Caption  := 'Aguardando ocupação';
             lbl_Texto2.Caption := 'De: '+ GetOcupante;

             lbltitle.Caption  := 'Aguardando ocupação de usuário';
             CanClose          := True;

             mnuEntrarFila.Visible := (not Find(tfWaiting, idx)) And (not Find(tfTimed, idx));

             ImageList.GetBitmap(12,bmp);
             img_main.Picture.Bitmap := imgBlock.Picture.Bitmap;

             AtualizaVersoes;
             AtualizaFila;
             AtualizaPCConnected;
         end;
      End;
      alWaiting :
      begin
         If Compl_Waiting = coFila then
         Begin
             lbl_Texto.Font.Color  := clBlue;
             lbl_Texto2.Font.Color := clBlue;
             lbl_Texto3.Font.Color := clBlue;

             lbl_Texto.Caption  := Mensagem1;
             lbltitle.Caption   := Mensagem2;

             ImageList.GetBitmap(14,bmp);
             ClockBMP           := TImage.Create(Self);
             With ClockBMP Do
             Begin
                 Picture.Bitmap := bmp;
                 Parent         := Self;
                 AutoSize       := True;
                 Left           := lbl_Texto.Left + (lbl_Texto.Width div 2) - (lbl_Texto.Canvas.TextWidth(lbl_Texto.Caption) div 2) - 5;
                 Top            := lbl_Texto.Top;
                 Visible        := False;
                 Transparent    := True;
             End;

             FreeAndNil(bmp);
             bmp := TBitmap.Create;
             ImageList.GetBitmap(15,bmp);
             CampBMP           := TImage.Create(Self);
             With CampBMP Do
             Begin
                 Picture.Bitmap := bmp;
                 Parent         := Self;
                 AutoSize       := True;
                 Left           := lbl_Texto2.Left + (lbl_Texto2.Width div 2) - (lbl_Texto2.Canvas.TextWidth(lbl_Texto2.Caption) div 2) - 20;
                 Top            := lbl_Texto2.Top;
                 Visible        := False;
                 Transparent    := True;
             End;

             mnuSairFila.Visible := True;

             FreeAndNil(bmp);
             bmp := TBitmap.Create;
             ImageList.GetBitmap(12,bmp);
             img_main.Picture.Bitmap   := imgWaiting.Picture.Bitmap;
             TimerAtualizacoes.Enabled := True;

             AtualizaVersoes;
             AtualizaFila;
             AtualizaPCConnected;
         end;
      End;
      alTimed :
      begin
         lbl_Texto.Font.Color  := clBlue;
         lbl_Texto2.Font.Color := clBlue;
         lbl_Texto3.Font.Color := clBlue;

         lbl_Texto.Caption  := 'Chegou sua vez';
         lbl_Texto2.Caption := 'Favor ocupar no tempo estipulado';
         lbl_Texto3.Caption := 'Resta: ';
         lbltitle.Caption   := 'Cronômetro';

         BigLabel           := TLabel.Create(Self);
         With BigLabel Do
         Begin
             Caption        := Self.Fields.Value['SECONDSLEFT'];
             Parent         := Self;
             AutoSize       := False;
             Width          := img_main.Width;
             Height         := img_main.Height;
             Font.Size      := 30;
             Alignment      := taCenter;
             Font.Color     := clBlack;
             Font.Name      := 'Arial';
             Font.Style     := [fsBold];
             Layout         := tlCenter;
             Left           := img_main.Left;
             Top            := img_main.Top;
             Visible        := True;
             Transparent    := True;
         End;

         ImageList.GetBitmap(14,bmp);
         ClockBMP           := TImage.Create(Self);
         With ClockBMP Do
         Begin
             Picture.Bitmap := bmp;
             Parent         := Self;
             AutoSize       := True;
             Left           := lbl_Texto3.Left + (lbl_Texto3.Width div 2) - (lbl_Texto3.Canvas.TextWidth(lbl_Texto3.Caption) div 2) - 5;
             Top            := lbl_Texto3.Top;
             Visible        := False;
             Transparent    := True;
         End;

         ImageList.GetBitmap(14,bmp);
         mnuConectar.Visible       := True;
         TimerAtualizacoes.Enabled := True;

         AtualizaVersoes;
         AtualizaFila;
         AtualizaPCConnected;
      end;
    End;

    imgBar.Picture.Bitmap   := bmp;

    lbl_Texto.Left   := img_main.Left + img_main.Width;
    lbl_Texto2.Left  := img_main.Left + img_main.Width;
    lbl_Texto3.Left  := img_main.Left + img_main.Width;

    lbl_Texto.Width  := (Self.Width) - (img_main.Left + img_main.Width) - 5;
    lbl_Texto2.Width := (Self.Width) - (img_main.Left + img_main.Width) - 5;
    lbl_Texto3.Width := (Self.Width) - (img_main.Left + img_main.Width) - 5;

    spClose.Visible  := CanClose;
    lblClose.Visible := CanClose;

    PopUpAcoes.Images := ImageList;
    fMinimized        := False;
    fHeightOriginal   := Self.Height;
    fHeightBar        := shpBar.Height;

    If TempoExibicao_MiliSeg > 0 Then
       TimerBlendExit.Interval := TempoExibicao_MiliSeg;

    If not CanClose Then
    Begin
       spMinimize.Left  := spClose.Left;
       lblMinimize.Left := lblClose.Left;
    end;

    FreeAndNil(bmp);
end;

procedure TfrmAlerta.TimerBlendExitTimer(Sender: TObject);
begin
    TimerBlendExit.Enabled := False;
    BlendExit;
end;

procedure TfrmAlerta.BlendEnter;
Var I:Integer;
begin
  Try
    Self.Enabled := False;
    if (AlphaBlendEnter) And (ValueAlphaBlend > 0) Then
    Begin
       For I:= 0 To ValueAlphaBlend Do
       Begin
         Self.AlphaBlendValue := I;
         Self.Update;
         Self.Show;
         Application.ProcessMessages;
         Sleep(1);
       end;

       if TempoExibicao_MiliSeg > -1 then
          TimerBlendExit.Enabled := True;
    end else
    Begin
       if ValueAlphaBlend > 0 then
         Self.AlphaBlendValue := ValueAlphaBlend
       Else
         Self.AlphaBlendValue := 255;
    end;
  Finally
    Self.Enabled := True;
  End;
end;

procedure TfrmAlerta.TimerBlendEnterTimer(Sender: TObject);
begin
    TimerBlendEnter.Enabled := False;
    BlendEnter();
end;

procedure TfrmAlerta.lblCloseMouseEnter(Sender: TObject);
begin
    TLabel(Sender).Font.Color  := clBlack;
    If UpperCase(TLabel(Sender).Name) = 'LBLCLOSE' Then
       spClose.Pen.Color    := clBlack
    Else
       spMinimize.Pen.Color := clBlack
end;

procedure TfrmAlerta.lblCloseMouseLeave(Sender: TObject);
begin
    TLabel(Sender).Font.Color  := clGray;
    If UpperCase(TLabel(Sender).Name) = 'LBLCLOSE' Then
       spClose.Pen.Color    := clGray
    Else
       spMinimize.Pen.Color := clGray
end;

procedure TfrmAlerta.WMSysCommand(var Msg: TWMSysCommand);
var sMsg:String;
begin
    Case (Msg.CmdType) of
      SC_CLOSE:
      Begin
          If Msg.Key <> WM_Internal Then
             Abort;
          Close;
      End
      Else
        Inherited
    End;
end;

procedure TfrmAlerta.BlendExit;
begin
    If AlphaBlendExit then
    begin
      Try
        HidePopups;
        Self.Enabled := False;
        while Self.AlphaBlendValue > 0 Do
        Begin
          Self.AlphaBlendValue := Self.AlphaBlendValue - 1;
          Self.Update;
          Self.Show;
          Application.ProcessMessages;
          Sleep(1);
        end;
      Finally
        Self.Enabled := True;
      End;

      Close;
    end else
    Begin
      Close;
    end;
end;

procedure TfrmAlerta.Minimize;
begin
    fMinimized   := not fMinimized;
    Self.Enabled := False;
    Try
      If fMinimized Then
      Begin
          Self.Height := fHeightBar;
      end Else
      Begin
          Self.Height := fHeightOriginal;
      End;

      If Operacao = alWaiting Then
      Begin
          lbltitle.Caption   := Mensagem2
      End;
    Finally
      Self.Enabled := True;
    End;
end;

procedure TfrmAlerta.imgFundoMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
    if not Self.Focused Then
       Self.SetFocus;
end;

function TfrmAlerta.GetFila: TFila;
begin
    Result := fFila;
end;

procedure TfrmAlerta.SetFila(F: TFila);
begin
    fFila := F;
    AtualizaFila;
end;

function TfrmAlerta.GetVersoes: TListVersao;
begin
    Result := fVersoes;
end;

procedure TfrmAlerta.SetVersoes(V: TListVersao);
begin
    fVersoes := V;
    AtualizaVersoes;
end;

procedure TfrmAlerta.mnuDesocuparClick(Sender: TObject);
begin
    Windows.SendMessage( Handleprincipal , WM_LIBERARTOKEN, SC_CLOSE, 0);
end;

procedure TfrmAlerta.mnuEntrarFilaClick(Sender: TObject);
begin
    TimerBlendExit.Enabled := False;
    Windows.SendMessage( Handleprincipal , WM_ENTRARFILA, SC_ATUALIZAR, 0);
    Close;
end;

procedure TfrmAlerta.btnAcoesClick(Sender: TObject);
Var
  X, Y:Word;
begin
    X := Self.Left + btnAcoes.Left + btnAcoes.Width;
    Y := Self.Top + btnAcoes.Top;
    PopUpAcoes.Popup( X, Y);
end;

procedure TfrmAlerta.SetAplhaBlend(BlendEnter, BlendExit: Boolean; Value: Byte; TimeActive: Integer);
begin
    TempoExibicao_MiliSeg  := TimeActive;
    AlphaBlendEnter        := BlendEnter;
    AlphaBlendExit         := BlendExit;
    ValueAlphaBlend        := Value;
end;

procedure TfrmAlerta.FormDestroy(Sender: TObject);
begin
    FreeAndNil(Fields);
    FreeAndNil(ClockBMP);
    FreeAndNil(CampBMP);
    FreeAndNil(BigLabel);
    HBFila.DelToolInfo;
    HBPC.DelToolInfo;
    HBVersoes.DelToolInfo;
end;

function TfrmAlerta.GetOcupante: String;
begin
    Result := Self.Fields.Value['OCUPANTE'];
end;

procedure TfrmAlerta.WMMenuSelect(var Msg: TWMMenuSelect);
begin
    inherited;
    IsMenuOpen := not ((msg.MenuFlag and $FFFF > 0) And (msg.Menu = 0));
end;

procedure TfrmAlerta.HidePopups;
begin
    PostMessage(Handle, WM_LBUTTONDOWN, MK_LBUTTON, 0);
    PostMessage(Handle, WM_LBUTTONUP, MK_LBUTTON, 0);
end;

procedure TfrmAlerta.TimerAtualizacoesTimer(Sender: TObject);
Var
  iQtdGlyph, MinLeft, Dif:Integer;
begin
    if Operacao = alConnect Then
    Begin
        If Fields.FieldExists('HORA_OCUPACAO') Then
           lbl_Texto2.Caption  := 'Há: ' + GetDifTempoFmt( FloatToDateTime(StrToFloat(Self.Fields.Value['HORA_OCUPACAO'])) );

        If Assigned(ClockBMP) Then
           If not (lbl_Texto2.Visible) or (lbl_Texto2.Caption = '') Then
              ClockBMP.Visible := False
           else
           Begin
              ClockBMP.Visible := True;
              ClockBMP.Left    := lbl_Texto2.Left + (lbl_Texto2.Width div 2) - (lbl_Texto2.Canvas.TextWidth(lbl_Texto2.Caption) div 2) - 20;
              Inc(iQtdGlyph);
           End;
    end else
    if Operacao = alWaiting Then
    Begin
        iQtdGlyph := 0;
        MinLeft   := 0;

        If Fields.FieldExists('TEMPO_ENTRADA_FILA') Then
           lbl_Texto.Caption  := 'Há: ' + GetDifTempoFmt( FloatToDateTime(StrToFloat(Self.Fields.Value['TEMPO_ENTRADA_FILA'])) );

        If Fields.FieldExists('USR_TOKEN') Then
           lbl_Texto2.Caption  := Mensagem3;

        If Assigned(ClockBMP) Then
           If not (lbl_Texto.Visible) or (lbl_Texto.Caption = '') Then
              ClockBMP.Visible := False
           else
           Begin
              ClockBMP.Visible := True;
              ClockBMP.Left    := lbl_Texto.Left + (lbl_Texto.Width div 2) - (lbl_Texto.Canvas.TextWidth(lbl_Texto.Caption) div 2) - 20;
              Inc(iQtdGlyph);
           End;
        If Assigned(CampBMP) Then
           If not (lbl_Texto2.Visible) or (lbl_Texto2.Caption = '') Then
              CampBMP.Visible := False
           else
           Begin
              CampBMP.Visible := True;
              CampBMP.Left  := lbl_Texto2.Left + (lbl_Texto2.Width div 2) - (lbl_Texto2.Canvas.TextWidth(lbl_Texto2.Caption) div 2) - 20;
              Inc(iQtdGlyph);
           End;

        If iQtdGlyph > 1 Then
        Begin
            If Assigned(ClockBMP) Then
               MinLeft := ClockBMP.Left;

            If Assigned(CampBMP) And (CampBMP.Left < MinLeft) Then
               MinLeft := CampBMP.Left;

            If Assigned(ClockBMP) Then ClockBMP.Left := MinLeft;
            If Assigned(CampBMP)  Then CampBMP.Left  := MinLeft;
        end;
    End Else
    if (Operacao = alCheck) And (Compl_Check = coBusy) Then
    Begin
        If Fields.FieldExists('TEMPO') Then
           lbl_Texto.Caption  := Mensagem1;
    End Else
    if (Operacao = alCheck) And (Compl_Check = coFree) Then
    Begin

    End Else
    if (Operacao = alTimed) Then
    Begin
        If Fields.FieldExists('SECONDSLEFT') Then
           lbl_Texto3.Caption  := 'Tempo: ' + Self.Fields.Value['SECONDSLEFT'];

        If Assigned(BigLabel) Then
        Begin
           If StrToInt(BigLabel.Caption) > 0 Then
              BigLabel.Caption  := IntToStr(StrToInt(BigLabel.Caption) - 1);

           If (StrToInt(BigLabel.Caption) <= 5) And Fields.FieldExists('SECONDSLEFT') And (Self.Fields.Value['SECONDSLEFT'] <> '') Then
           Begin
               BigLabel.Caption  := Self.Fields.Value['SECONDSLEFT'];
           end;

           lbl_Texto3.Caption  := 'Tempo: ' + BigLabel.Caption;

           If (StrToInt(BigLabel.Caption) < 10) And (BigLabel.Font.Color <> clRed) Then
              BigLabel.Font.Color := clRed;
        End;

        If Assigned(ClockBMP) Then
           If not (lbl_Texto3.Visible) or (lbl_Texto3.Caption = '') Then
              ClockBMP.Visible := False
           else
           Begin
              ClockBMP.Visible := True;
              ClockBMP.Left    := lbl_Texto3.Left + (lbl_Texto3.Width div 2) - (lbl_Texto3.Canvas.TextWidth(lbl_Texto3.Caption) div 2) - 20;
              Inc(iQtdGlyph);
           End;
    End;
end;

procedure TfrmAlerta.mnuSairFilaClick(Sender: TObject);
begin
    Windows.SendMessage( Handleprincipal , WM_SAIRFILA, SC_DESISTENCIA, 0);
    Close;
end;

function TfrmAlerta.Mensagem1: String;
begin
    Result := '';
    Try
      If Fields.FieldExists('TEMPO') Then
         Result := 'Servidor Ocupado há ' + GetDifTempoFmt( FloatToDateTime(StrToFloat(Self.Fields.Value['TEMPO'])) );
    Except
       Result := '(Error)';
    End;
end;

function TfrmAlerta.Mensagem2: String;
begin
    Result := '(Error)';
    Try
      if not fMinimized Then
         Result := 'Aguardando na Fila'
      Else
         Result := 'Aguardando na Fila: ' + IntToStr(Fila.Count);
    Except
    end;
end;

procedure TfrmAlerta.mnuConectarClick(Sender: TObject);
begin
    Windows.SendMessage( Handleprincipal , WM_CONECTAR, SC_CONECTAR_RECURSV, 0);
    If Operacao <> alTimed Then
       Close;
end;

function TfrmAlerta.Mensagem3: String;
begin
    Result := '';
    Try
      If Fields.FieldExists('USR_TOKEN') Then
         Result := Self.Fields.Value['USR_TOKEN']
    Except
       Result := '(Error)';
    End;
end;

function TfrmAlerta.GetPCConnected: String;
begin
    Result := fPCConnected;
end;

procedure TfrmAlerta.SetPCConnected(S: String);
begin
    fPCConnected := S;
    AtualizaPCConnected;
end;

procedure TfrmAlerta.AtualizaPCConnected;
Var
  t, s:String;
begin
    If Self.fPCConnected = '' Then
    Begin
        pnl_HintPC.Visible := False;
        imgPC.Visible := False;
    end Else
    Begin
        pnl_HintPC.Visible := True;
        imgPC.Visible  := True;
        imgPC.ShowHint := True;

        With HBPc Do
        Begin
            DelToolInfo;
            Style := sbInformation;
            Text  := fPCConnected;
            AddToolInfo(Handle, pnl_HintPC.Handle);
        End;
    end;
end;

end.
