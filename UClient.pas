unit UClient;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, StdCtrls, Menus, ScktComp, MShoutProtocol,
  ImgList, Buttons, UGlobal, IdBaseComponent, IdComponent, Usuario, Versao, Requisicao, INIFiles, CoolTrayIcon,
  WinSkinData, UAlerta, DateUtils, CheckLst, UListVersoes, ShellAPI, DB,
  DBClient;

const
   MSClient_Version = '1.0.0';

type
  TTipoOperacao   = (opConnect, opCheckToken);
  TTipoDisconnect = (dcManual, dcKicked, dcNoPing);                      
  TTipoServico    = (tsOn, tsOff, tsStopReconect);
  TWho            = (whAll, whFirst, whNone);
  TBCastMsg       = (bcFila, bcClose, bcUSR_TOKEN, bcSecondsLeft, bcPCConnected);
  TForce          = (fcNone = 0, fcTimedForm_Close = 1);
  TExtraTag       = (exManual, exKicked);
  TExtraTags      = set of TExtraTag;

  TfrmMshoutClient = class(TForm, IArquitetura)
    PageControl1: TPageControl;
    tsConfiguracoes: TTabSheet;
    PopupMenu: TPopupMenu;
    lbl2: TLabel;
    edt_port: TEdit;
    Label1: TLabel;
    edt_host: TEdit;
    lbl3: TLabel;
    lbl_Servidor: TLabel;
    bvl1: TBevel;
    Label3: TLabel;
    Label4: TLabel;
    edt_name: TEdit;
    ClientSocket1: TClientSocket;
    TrayIcon: TCoolTrayIcon;
    mnuCheckDisponibilidade: TMenuItem;
    N1: TMenuItem;
    mnuFechar: TMenuItem;
    mnuIniciar: TMenuItem;
    mnuConfig: TMenuItem;
    ImageList1: TImageList;
    mnuConectar: TMenuItem;
    SkinData1: TSkinData;
    pnl_EmUso: TPanel;
    img1: TImage;
    Shape1: TShape;
    Label2: TLabel;
    N2: TMenuItem;
    TimerPing: TTimer;
    TimerReconnect: TTimer;
    lbl4: TLabel;
    lblStatus: TLabel;
    memLog: TRichEdit;
    lbl1: TLabel;
    pnl1: TPanel;
    btnDisponibilidade: TSpeedButton;
    btnPing: TSpeedButton;
    btnConectar: TSpeedButton;
    btnIniciar: TSpeedButton;
    lbl5: TLabel;
    CycleReconnect: TImageList;
    lblVersion: TLabel;
    Label5: TLabel;
    procedure ClientSocket1Connect(Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientSocket1Disconnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientSocket1Error(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure FormCreate(Sender: TObject);
    procedure edt_hostExit(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure mnuConfigClick(Sender: TObject);
    procedure mnuFecharClick(Sender: TObject);
    procedure TrayIconDblClick(Sender: TObject);
    procedure mnuIniciarClick(Sender: TObject);
    procedure btnIniciarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnDisponibilidadeClick(Sender: TObject);
    procedure mnuConectarClick(Sender: TObject);
    procedure mnuCheckDisponibilidadeClick(Sender: TObject);
    procedure btnPingClick(Sender: TObject);
    procedure TimerPingTimer(Sender: TObject);
    procedure TimerReconnectTimer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnConectarClick(Sender: TObject);
    procedure lblCloseClick(Sender: TObject);
  private
    { Private declarations }
    HandleAlerta:THandle;

    frAlertaFixo:^TfrmAlerta;

    TentandoReconectar:Boolean;
    StrVersoes:String;
    ListaVersoes:TListVersao;
    Fila:TFila;
    sLastOcupante, sLastPCConnected:String;
    DTEntrouFila:TDateTime;
    Force:TForce;

    procedure WMSysCommand(var Msg: TWMSysCommand);   Message WM_SysCommand;
    procedure WMLiberarToken(var Msg: TWMSysCommand); Message WM_LiberarToken;
    procedure WMEntrarFila(var Msg: TWMSysCommand); Message WM_EntrarFila;
    procedure WMSairFila(var Msg: TWMSysCommand); Message WM_SairFila;
    procedure WMConectar(var Msg: TWMSysCommand);     Message WM_Conectar;
    procedure ZeraVars;
    procedure TravaCampos();
    Procedure ReadINIFile();
    Procedure GravaIniFile();
    Procedure Inicia_Servico(Servico: TTipoServico ; ExtraTags:TExtraTags=[]);
    function  TokenDisconect(Silent:Boolean=False):Boolean;
    function  LocalDisconect( TipoDisconnect:TTipoDisconnect=dcManual ):Boolean;
    procedure CriaTela(ATyp:TTypeForm ; AVersoes:TListVersao ; AOutput:TOutput);
    procedure SetTOKEN(Value:Boolean);
    procedure PING(Silent:Boolean=False);
    procedure Reconectar(Ativar:Boolean);
    procedure AtualizaStatus;
    procedure ConectarVersoes(Sender: TObject ; sVersoes:String='');
    Function  Executa(Op : TTipoOperacao ; sVersoes:String=''):Boolean;
    procedure PreparaFilaNoClient(strFila:String ; AvisaForms:Boolean ; TpSender:Twho);
    procedure BroadCast_MsgToForms(FormsMode:TShowMode ; ATyp:TTypeForm ; Sender:TWho ; Msg:TBCastMsg ; Value:Variant);

  public
    { Public declarations }
    procedure AddLog(Msg:String ; Cor:TColor=clBlack  ; Sty:TFontStyles=[]);
    procedure AtualizaEDITs();
    procedure AtualizaCFGs();
    procedure AtualizaVisibilidades();

  end;

  type
    Execucao = (exMstsc);

  TClientHandleThread = class(TThread)
  private
    StrInput:String;
    FClientSkt:TClientSocket;
    fMainHandle:HWND;
    fExecucao:Execucao;
    fValue1:Variant;
  protected
    procedure Execute; override;
  public
    property ClientSocket : TClientSocket read FClientSkt write FClientSkt;
    property Execucao : Execucao read fExecucao write fExecucao;
    property Value1 : Variant read fValue1 write fValue1;
  end;

var
  frmMshoutClient: TfrmMshoutClient;

  Tempo, iQtdPings:Integer;
  ObjLog:^TRichEdit;
  H:THandle;
  ClientHandleThread: TClientHandleThread;

  //CFG Vars
  cfg_IPControl,
  cfg_Host,
  cfg_Nome:String;
  cfg_Port:Integer;

  //INI Vars
  INI_Title: String;
  INI_Minimized, INI_StartActive, INI_AutoConnect: Boolean;

  Sep, SubSep:String;

const
  cnst_TempoEsperaMS = 3000;
  cnst_Thread_terminate = 'thread'+_+'terminate';

implementation

{$R *.dfm}

{ TClientHandleThread }

procedure TClientHandleThread.Execute;
var
  ei:TShellExecuteInfo;
begin
   Case Execucao Of
      exMstsc :
      Begin
         Try
           try
              While Not Terminated Do
              Begin
                  ei.cbSize       := SizeOf(ei);
                  ei.fMask        := SEE_MASK_NOCLOSEPROCESS;
                  ei.Wnd          := Handle;
                  ei.lpVerb       := 'open';
                  ei.lpFile       := 'mstsc';
                  ei.lpParameters := PChar( VarToStrDef(Value1, '') );
                  ei.lpDirectory  := nil;
                  ei.nShow        := SW_NORMAL;

                  ShellExecuteEx(@ei);

                  WaitForSingleObject(ei.hProcess, INFINITE);

                  CloseHandle(ei.hProcess);
                                                          
                  Windows.SendMessage( fMainHandle , WM_LIBERARTOKEN, SC_CLOSE, WM_Silent);
                  Terminate;
              End;
           Except
             raise;
           End;
         Finally
           Self.Destroy;
         end;
      end Else
         Self.Destroy;
   End;
end;

{ TFrmMShoutClient }

procedure TfrmMshoutClient.ReadINIFile;
Var
  INIFile:TIniFile;
Begin
    If not FileExists( sPath + 'MShoutClient.ini' ) Then
       raise Exception.Create('Arquivo de inicialização não encontrado.'+#13+ sPath + 'MShoutClient.ini');
   INIFile  :=  TIniFile.Create(sPath + 'MShoutClient.ini');

    Try
      // Extrai informações do arquivo de inicialização e atribui as variaveis globais
      cfg_Host      := INIFile.ReadString('GERAL','HOST','');

      If (cfg_Host <> '') And IsWrongIP(cfg_Host) then
      Begin
          MessageDlg('Parâmetro de inicialização "HOST" inválido. ('+ cfg_Host +')',mtError,[mbOK],0);
          cfg_Host := '';
      End;
      cfg_Port      := StrToIntDef( INIFile.ReadString('GERAL','PORT',''),0);
      cfg_Nome      := INIFile.ReadString('GERAL','NOME','');
      INI_Title     := INIFile.ReadString('GERAL','Title','MShout');

      If INIFile.ReadString('GERAL','Start_Minimized','F') = 'T' Then
        INI_Minimized := True
      Else
        INI_Minimized := False;

      If INIFile.ReadString('GERAL','Start_Active','F') = 'T' Then
        INI_StartActive := True
      Else
        INI_StartActive := False;

      If INIFile.ReadString('GERAL','Auto_Connect','F') = 'T' Then
        INI_AutoConnect := True
      Else
        INI_AutoConnect := False;
    Finally
      INIFile.Free;
    End;
end;

procedure TfrmMshoutClient.GravaIniFile;
Var INIFile:TIniFile;
begin
    If not FileExists( sPath + 'MShoutClient.ini' ) Then
       Exit;
    INIFile       :=  TIniFile.Create(sPath + 'MShoutClient.ini');
    Try
      INIFile.WriteString('GERAL','HOST', cfg_Host);
      INIFile.WriteString('GERAL','PORT', IntToStr(cfg_Port));
      INIFile.WriteString('GERAL','NOME', cfg_Nome);
    Finally
      INIFile.Free;
    End;
end;

procedure TfrmMshoutClient.WMSysCommand(var Msg: TWMSysCommand);
var
  sMsg:String;
  H:HWND;
begin
    Case (Msg.CmdType) of
      SC_MINIMIZE:
      Begin
          H := FindWindow(nil, sHideTitle);
          If H <> 0 Then
             frmListVersoes.Close;

          Application.Minimize;
          TrayIcon.HideMainForm;
          sMsg := 'Aplicação em execução.';
          TrayIcon.ShowBalloonHint(cnst_NomeClient, sMsg, bitInfo, 10);
      End;
      SC_MAXIMIZE:
      Begin
          TrayIcon.ShowMainForm;
      End
      Else
        Inherited
    End;
end;

procedure TfrmMshoutClient.AddLog(Msg: String ; Cor:TColor=clBlack ; Sty:TFontStyles=[]);
Var
  sStart: word;
  sHora:String;
Const
  cnst_HoraTam = 8;
begin
    sHora := FormatDateTime('hh:nn:ss',Now()) + ' - ';

    sStart := Length(ObjLog.Text);
    ObjLog.Lines.Add( sHora + Msg);

    // Cor Horario
    ObjLog.SelStart            := sStart;
    ObjLog.SelLength           := cnst_HoraTam;
    ObjLog.SelAttributes.Color := clGray;
    ObjLog.SelAttributes.Style := [fsBold];

    // Cor Texto
    ObjLog.SelStart            := sStart + Length(sHora);
    ObjLog.SelLength           := Length(ObjLog.Text);
    ObjLog.SelAttributes.Color := Cor;
    ObjLog.SelAttributes.Style := Sty;
    Application.Processmessages;

    ObjLog.SelStart            := Length(ObjLog.Text);
    ObjLog.SelLength           := 0;
end;

procedure TfrmMshoutClient.Inicia_Servico(Servico: TTipoServico ; ExtraTags:TExtraTags=[]);
begin
    Try
      if Servico  = tsOn Then
      Begin
          ClientSocket1.Host   := cfg_Host;
          ClientSocket1.Port   := cfg_Port;
          ZeraVars;

          Try
            If Not ClientSocket1.Active Then
               ClientSocket1.Active  := True;
          Except
            raise;
          End;
      end Else
      if Servico  = tsOff Then
      Begin
          Try
            SetTOKEN(False);

            If ClientSocket1.Active Then
               ClientSocket1.Active := False;
          Except
            On E : Exception Do
            Begin
                AddLog(E.Message, clRed);
            End;
          End;
      end else
      if Servico  = tsStopReconect Then
      Begin
          if not ClientSocket1.Active and (TentandoReconectar) then
          Begin
             Reconectar(False);
             AddLog('Reconexão interrompida pelo usuário.');
             TrayIcon.Hint := INI_Title + ' (port: '+ IntToStr(cfg_Port) + ')';
          end;
      End;

      AtualizaVisibilidades;
      AtualizaStatus;

      if (exKicked In ExtraTags) then
      Begin
         AddLog('Usuário foi desconectado pelo servidor.');
      end;
    Except
      On E : ESocketError Do
      Begin
          If Not TentandoReconectar Then
             AddLog(E.Message + ' ('+ cfg_Host + ':'+ IntToStr(cfg_Port) +')', clRed)
          Else
             AddLog('Tentando reconexão...', clOlive);

          If Servico = tsOn then
             E.Message := 'Não foi possível conectar ao servidor. ('+ cfg_Host + ':'+ IntToStr(cfg_Port) +')'
          Else
             E.Message := 'Erro ao desconectar do servidor. ('+ cfg_Host + ':'+ IntToStr(cfg_Port) +')';
          raise;
      End;

      On E : EThread Do
      Begin

      End;

      On E : Exception Do
      Begin
          raise;
      End;
    End;
end;

procedure TfrmMshoutClient.ClientSocket1Connect(Sender: TObject; Socket: TCustomWinSocket);
Var
  sOut_MsgError, sOut_IPControl:String;
  bmp:TBitmap;
begin
    sOut_MsgError  := '';
    sOut_IPControl := '';

    If TClientProtocol.sendLogin(Edt_Name.Text, ClientSocket1, sOut_IPControl, sOut_MsgError, StrVersoes, Sep, SubSep) Then
    Begin
        bmp := TBitmap.Create;
        ImageList1.GetBitmap(2,bmp);

        AddLog( 'Conectado a: ' + ClientSocket1.Host );
        mnuIniciar.ImageIndex  := 2;
        btnIniciar.Glyph       := bmp;

        TListVersao.DecodeVersoesToList(StrVersoes, Sep , SubSep , ListaVersoes );

        if Assigned(Fila) Then
           FreeAndNil(Fila);

        cfg_IPControl := sOut_IPControl;
        AtualizaEDITs;
        TravaCampos;
        TimerPing.Enabled := True;
    end else
    Begin
        AddLog( 'Falha ao conectar a: ' + ClientSocket1.Host +' - ServerErro: '+ GetLastError, clred );
    end;
end;

procedure TfrmMshoutClient.ClientSocket1Disconnect(Sender: TObject; Socket: TCustomWinSocket);
var
  bmp:TBitmap;
begin
    AddLog( 'Desconectado' );

    bmp := TBitmap.Create;
    ImageList1.GetBitmap(1,bmp);

    mnuIniciar.ImageIndex := 1;
    btnIniciar.Glyph      := bmp;

    cfg_IPControl := '';
    AtualizaEDITs;

    If Assigned(ListaVersoes) Then
       ListaVersoes.Clear;

    TravaCampos;
    TimerPing.Enabled := False;
end;

procedure TfrmMshoutClient.ClientSocket1Error(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
const
   Err_ForcedDisconnect = 10054;
   Err_Asyncronous = 10053;
begin
    case ErrorCode of
      Err_Asyncronous :
        Begin
           Abort;
        end;
      Err_ForcedDisconnect :
        Begin
           Inicia_Servico( tsOff , [exKicked] );
        end;
    End;
end;

procedure TfrmMshoutClient.ZeraVars;
begin
    TrayIcon.Hint := INI_Title + ' (port: '+ IntToStr(cfg_Port) + ')';
    frAlertaFixo       := nil;
    sLastOcupante      := '';
    sLastPCConnected   := '';

    IamTimed           := False;
    Force              := fcNone;

    If Assigned(ListaVersoes) Then
    Begin
        ListaVersoes.Clear;
        FreeAndNil(ListaVersoes);
        ListaVersoes  := TListVersao.Create;
    End;

    SetTOKEN(False);
end;

procedure TfrmMshoutClient.FormCreate(Sender: TObject);
Var
   HandleINI:TIniFile;
Begin
    Try
      ReadINIFile;
    Except
      On E : Exception Do
      Begin
         MessageDlg( E.Message, mtError,[mbOK],0 );
         Application.Terminate;
      End;
    End;

    // Ativa Skin
    SkinData1.Active := True;

    lblVersion.Caption := 'v'+ MSClient_Version;

    TrayIcon.IconList  := ImageList1;
    TrayIcon.IconIndex := 0;
    Application.ProcessMessages;

    Self.Caption  := INI_Title;

    PageControl1.ActivePage := tsConfiguracoes;
    lblStatus.Caption := '';
    btnPing.Hint      := 'Ping no Servidor';

    btnIniciar.ShowHint         := True;
    btnConectar.ShowHint        := True;
    btnDisponibilidade.ShowHint := True;
    btnPing.ShowHint            := True;
    TimerPing.Enabled           := False;
    TentandoReconectar          := False;

    AtualizaVisibilidades;

    AtualizaEDITs;
    ObjLog             := @memLog; // ObjLog Recebe posição da memória de memLog
    ObjLog.Clear;

    SetLength(ArrayOfForms,99);
    ZeraVars;

//    HandleINI := TIniFile.Create('C:\Projetos\MShout_Client\Handle.ini');
//    HandleINI.WriteString('HANDLE','HANDLE', IntToStr( Self.Handle ) );
//    FreeAndNil(HandleINI);
end;

// Sincroniza Campos do Form com Informacoes das Variaveis de Config
procedure TfrmMshoutClient.AtualizaEDITs();
begin
    edt_port.Text        := IntToStr(cfg_Port);
    edt_host.Text        := cfg_Host;
    edt_name.Text        := cfg_Nome;
    lbl_Servidor.Caption := cfg_IPControl;
end;

// Atualiza Variáveis com valores digitados nos campos do FOrm
procedure TfrmMshoutClient.AtualizaCFGs();
begin
    cfg_Port      := StrToIntDef(edt_port.Text,0);
    If ( Trim(edt_host.Text) <> '' ) And ( Not IsWrongIP(edt_host.Text) ) Then
       cfg_Host   := edt_host.Text
    Else
       cfg_Host   := '';
    cfg_Nome      := Copy(edt_name.Text,1,15);
    AtualizaEdits;
end;

// Faz todos campos do Form ficarem HABILITADOS ou DESABILITADOS
procedure TfrmMshoutClient.TravaCampos;
Var I:Integer;
begin
    For I := 0 to ComponentCount - 1 do
    begin
        If (Components[i] Is TEdit) And (TEdit(Components[i]).Tag = 1) Then
        Begin
            If ClientSocket1.Active Then
               TEdit(Components[i]).Enabled := False
            Else
            Begin
               If Not TentandoReconectar Then
                 TEdit(Components[i]).Enabled := True
               Else
                 TEdit(Components[i]).Enabled := False;
            End;
        End Else
        If (Components[i] Is TLabel) And (TLabel(Components[i]).Tag = 1) Then
        Begin
            If ClientSocket1.Active Then
               TLabel(Components[i]).Enabled := False
            Else
            Begin
               If Not TentandoReconectar Then
                 TLabel(Components[i]).Enabled := True
               Else
                 TLabel(Components[i]).Enabled := False;
            End;
        End;
    End;
end;
                    
// Todos Campos editáveis chamam AtualizaCFGs ao perderem o Foco
procedure TfrmMshoutClient.edt_hostExit(Sender: TObject);
begin
    AtualizaCFGs;
end;

procedure TfrmMshoutClient.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    If ( ClientSocket1.Active ) And (MessageDlg('Finalizar aplicação?', mtInformation,[mbYes,mbNo],0) = mrNo) Then
    begin
      Abort;
    end;

    Try
       SetTOKEN(False);
       Inicia_Servico(tsOff);
       GravaINIFile;
    Except
    End;
end;

// Mostra Form Configuracoes e Traz ele pra frente
procedure TfrmMshoutClient.mnuConfigClick(Sender: TObject);
begin
    Self.Visible:= True;
    BringWindowToTop(Application.Handle);
end;

procedure TfrmMshoutClient.mnuFecharClick(Sender: TObject);
begin
    Try
      Inicia_Servico(tsOff);
    Finally
      Close;
    End;
end;

procedure TfrmMshoutClient.TrayIconDblClick(Sender: TObject);
begin
    mnuConfigClick(Sender);
end;

procedure TfrmMshoutClient.mnuIniciarClick(Sender: TObject);
begin
    btnIniciarClick(Sender);
    if ClientSocket1.Active Then
       TrayIcon.ShowBalloonHint(cnst_NomeClient, 'Conectado', bitWarning, 10)
    Else
       TrayIcon.ShowBalloonHint(cnst_NomeClient, 'Desconectado', bitWarning, 10);
end;

procedure TfrmMshoutClient.btnIniciarClick(Sender: TObject);
begin
    If Self.Visible Then
      Perform(WM_NEXTDLGCTL,0,0);

    Try
      if ClientSocket1.Active then
      begin
          Try
            If OcupandoTOKEN Then
            Begin
                SendMessage( frmMshoutClient.Handle , WM_LIBERARTOKEN, SC_CLOSE, 0);
            End;
          Except
            On E : Exception Do
            Begin
                AddLog(E.Message, clRed);
                raise;
            End;
          End;

          Inicia_Servico(tsOff);
      end else
      begin
          if (Not TentandoReconectar) Or (Sender Is TTimer) Then
             Inicia_Servico(tsOn)
          else
             Inicia_Servico(tsStopReconect);
      end;
    Except
       on E : Exception Do
       begin
          If not (Sender Is TTimer) Then
          Begin
              AddLog(E.Message, clRed);
              raise;
          End;
       end;
    end;
end;

function TfrmMshoutClient.Executa(Op : TTipoOperacao ; sVersoes:String='' ):Boolean;
Var
  sOut_MsgError, MsgError, sMsgErr, S, sInput, sOutput, OTP:string;
  sOut_Livre:Boolean;
  sOut_UsrOcupando:TUsuario;
  sOut_HoraServidor:TDateTime;
  VersoesGerando:TListVersao;
  idx:Integer;
  PC_Connected:String;
begin
    Result            := False;
    sOut_MsgError     := '';
    sOut_Livre        := False;
    sOut_UsrOcupando  := nil;
    sOut_HoraServidor := 0;
    If Assigned(Fila) Then
       sInput := sInput + 'FILAVERSION=' + IntToStr(Fila.FilaVersion);

    Try
        If Op = opConnect Then
        Begin
            If TClientProtocol.sendConnectCheck(ClientSocket1, cnst_Connect, sVersoes, sOut_Livre, sOut_UsrOcupando, sOut_HoraServidor, sOut_MsgError, sInput, sOutput) Then
            Begin
                frmAlerta := nil;
                Application.CreateForm(TfrmAlerta, frmAlerta);

                frmAlerta.ImageList := ImageList1;

                // Lista de Versoes
                TListVersao.DecodeVersoesToList(sVersoes,Sep, SubSep, VersoesGerando);

                // Fila
                S := TRequisicoes.GetRequisicaoStr(TFila, sOutput);
                If (S <> '') And ( (( Assigned(Fila)) And (S <> Fila.FilaString)) or (not Assigned(Fila))) Then
                Begin
                    PreparaFilaNoClient(S, False, whNone);
                end;

                If (LerDynamicParam(sOutput, '$PCCONNECTED', otp, True, True) > -1) Then
                Begin
                    PC_Connected := otp;
                end;

                if sOut_Livre Then
                Begin
                    SetTOKEN(True);
                    AlocarForm( Pointer(frmAlerta), smFixed, tfConnected );

                    If IamTimed Then
                    Begin
                       BroadCast_MsgToForms(smFixed, tfTimed, whFirst, bcClose, '');
                       IamTimed := False;
                    End;

                    AddLog('Ocupando servidor ('+ cfg_IPControl  +')');
                    With frmAlerta do
                    Begin
                        Handleprincipal          := frmMshoutClient.Handle;
                        Operacao                 := alConnect;
                        Compl_Connect            := coSucess;
                        SetAplhaBlend(True,False, 255, 0);
                        Fila                     := Self.Fila;
                        Versoes                  := VersoesGerando;
                        PCConnected              := PC_Connected;

                        Fields.Value['HORA_OCUPACAO'] := FloatToStr( Now() );

                        Show;

                        Result := True;               
                    End;
                End else
                Begin
                    AddLog('Tentativa de ocupar sem sucesso.'#13'Servidor ocupado.', clMaroon);
                    AlocarForm( Pointer(frmAlerta), smTemorary, tfCheck );

                    With frmAlerta do
                    Begin
                        Handleprincipal          := frmMshoutClient.Handle;
                        Operacao                 := alConnect;
                        If LerDynamicParam(sOutput, '$TIMEFORUSR', otp, True, True) > -1 Then
                           Compl_Connect := coFailWaitingTimed
                        Else
                           Compl_Connect := coFail;


                        SetAplhaBlend(True, True, 255, 4000);
                        Fila                     := Self.Fila;
                        Versoes                  := VersoesGerando;
                        PCConnected              := PC_Connected;

                        Fields.Value['TEMPO']    := FloatToStr( sOut_HoraServidor );
                        Fields.Value['OCUPANTE'] := sOut_UsrOcupando.Nome + ' ('+ sOut_UsrOcupando.IP +')';

                        Show;
                    End;
                end;
            end else
            Begin
                MsgError := GetLastError;
                If MsgError = cnst_OpAborted then
                Begin
                    ClientSocket1.Active := False;
                    Reconectar(True);
                end;

                sMsgErr := 'Falha ao tentar ocupar TOKEN: ' + ClientSocket1.Host +' - ServerError: '+ MsgError;
                AddLog( sMsgErr, clRed );
                raise Exception.Create(sMsgErr);
            end;
        End Else
        If Op = opCheckToken Then
        Begin
            If TClientProtocol.sendConnectCheck(ClientSocket1, cnst_CheckToken, sVersoes, sOut_Livre, sOut_UsrOcupando, sOut_HoraServidor, sOut_MsgError, sInput, sOutput) Then
            Begin
                frmAlerta := nil;
                Application.CreateForm(TfrmAlerta, frmAlerta);
                frmAlerta.ImageList := ImageList1;

                // Lista de versoes
                TListVersao.DecodeVersoesToList(sVersoes,Sep, SubSep, VersoesGerando);

                // Fila
                S := TRequisicoes.GetRequisicaoStr(TFila, sOutput);
                If (S <> '') And ( (( Assigned(Fila)) And (S <> Fila.FilaString)) or (not Assigned(Fila))) Then
                Begin
                    PreparaFilaNoClient(S, False, whNone);
                end;

                If (LerDynamicParam(sOutput, '$PCCONNECTED', otp, True, True) > -1) Then
                Begin
                    PC_Connected := otp;
                end;

                if sOut_Livre Then
                Begin
                    AddLog('Verificando disponibilidade('+ cfg_IPControl +'): #Livre', clGreen);
                    AlocarForm( Pointer(frmAlerta), smTemorary, tfCheck );

                    With frmAlerta do
                    Begin
                        Handleprincipal          := frmMshoutClient.Handle;
                        Operacao                 := alCheck;
                        Compl_Check              := coFree;
                        SetAplhaBlend(True, True, 255, 4000);
                        Fila                     := Self.Fila;
                        Versoes                  := VersoesGerando;
                        PCConnected              := PC_Connected;

                        Show;

                        Result := True;
                    End;
                end Else
                Begin
                    AlocarForm( Pointer(frmAlerta), smTemorary, tfCheck );

                    With frmAlerta do
                    Begin
                        Handleprincipal    := frmMshoutClient.Handle;

                        Fields.Value['TEMPO']    := FloatToStr( sOut_HoraServidor );
                        Fields.Value['OCUPANTE'] := sOut_UsrOcupando.Nome + ' ('+ sOut_UsrOcupando.IP +')';

                        Operacao                 := alCheck;
                        If LerDynamicParam(sOutput, '$TIMEFORUSR', otp, True, True) > -1 Then
                           Compl_Check := coWaitingTimed
                        Else
                           Compl_Check := coBusy;

                        SetAplhaBlend(True, True, 255, 4000);

                        CanClose                 := True;
                        Fila                     := Self.Fila;
                        Versoes                  := VersoesGerando;
                        PCConnected              := PC_Connected;

                        AddLog('Verificando disponibilidade('+ cfg_IPControl +'): #Ocupado há '+ GetDifTempoFmt( FloatToDateTime(StrToFloat(Fields.Value['TEMPO']))) + ' Por: ' + Fields.Value['OCUPANTE'] + #13 + VersoesGerando.ListToFormatedString(fsDesc_Virgula), clOlive);
                        Show;
                    End;
                end;
            end else
            Begin
                sMsgErr := 'Falha ao tentar verificar TOKEN: ' + ClientSocket1.Host +' - ServerError: '+ sOut_MsgError;
                AddLog( sMsgErr, clRed );
                raise Exception.Create(sMsgErr);
            end;
        end;
    Finally
        FreeAndNil(VersoesGerando);
    End;

    AtualizaVisibilidades;
end;

procedure TfrmMshoutClient.FormShow(Sender: TObject);
var
  H : HWnd;
begin
    {$IFNDEF DEBUG}
       H := FindWindow(Nil,'MShout_Client');
       if H <> 0 then ShowWindow(H,SW_HIDE);
    {$ENDIF}
end;

procedure TfrmMshoutClient.btnDisponibilidadeClick(Sender: TObject);
begin
    Executa(opCheckToken);
end;

procedure TfrmMshoutClient.SetTOKEN(Value:Boolean);
begin
   OcupandoTOKEN     := Value;
   pnl_EmUso.Visible := Value;
   iQtdPings         := 0;
end;

procedure TfrmMshoutClient.mnuConectarClick(Sender: TObject);
begin
    btnConectarClick(Sender);
end;

procedure TfrmMshoutClient.AtualizaVisibilidades;
begin
    mnuCheckDisponibilidade.Caption := 'Tem Alguém no "'+ cfg_IPControl +'" ?';
    btnDisponibilidade.Hint         := 'Verificar Disponibilidade';

    mnuCheckDisponibilidade.Visible := ClientSocket1.Active;
    btnDisponibilidade.Enabled      := ClientSocket1.Active;

    If OcupandoTOKEN Then
        mnuConectar.Caption  := 'Desocupar servidor "'+ cfg_IPControl +'"'
    Else
        mnuConectar.Caption  := 'Acessar servidor "'+ cfg_IPControl + '"';
        
    btnConectar.Hint     := mnuConectar.Caption;

    if ClientSocket1.Active then
    Begin
        btnIniciar.Hint    := 'Parar Serviço';
        mnuIniciar.Caption := 'Parar Serviço';
    End Else
    Begin
        If Not TentandoReconectar then
        Begin
            btnIniciar.Hint    := 'Iniciar Serviço';
            mnuIniciar.Caption := 'Iniciar Serviço';
        End else
        Begin
            btnIniciar.Hint    := 'Interromper Reconexão';
            mnuIniciar.Caption := 'Interromper Reconexão';
        end;
    end;

    mnuConectar.Visible := ClientSocket1.Active;
    btnConectar.Enabled := ClientSocket1.Active;
    btnPing.Enabled     := ClientSocket1.Active;
end;

procedure TfrmMshoutClient.mnuCheckDisponibilidadeClick(Sender: TObject);
begin
    btnDisponibilidadeClick(Sender);
end;

procedure TfrmMshoutClient.WMLiberarToken(var Msg: TWMSysCommand);
begin
    Case (Msg.CmdType) of
      SC_CLOSE:
      Begin
          if Not TokenDisconect( Msg.Key = WM_Silent ) then
             if not (Msg.Key = WM_Silent) Then
                raise Exception.Create('Ocorreu um erro inexperado ao tentar liberar o TOKEN.'#13'(TokenDisconect)');
      End
      Else
        Inherited
    End;
end;

function TfrmMshoutClient.TokenDisconect(Silent:Boolean=False): Boolean;
Var
  sOut_MsgError, sMsgErr:String;
begin
   sOut_MsgError := '';
   Result := False;

   If (Not OcupandoTOKEN) and (not Silent) Then
      raise Exception.Create('<Client ASSERT> Erro ao tentar desconectar Token.');
   Try
     If TClientProtocol.sendDisconect( ClientSocket1, sOut_MsgError ) then
     Begin
       Result := LocalDisconect;
       AtualizaVisibilidades;
     End else
     Begin
         If Not Silent Then
         Begin
             sMsgErr := 'Falha ao tentar desocupar TOKEN: ' + ClientSocket1.Host +' - ServerError: '+ GetLastError;
             AddLog( sMsgErr , clRed);
             raise Exception.Create(sMsgErr);
         End;
     end;
   except
       if not Silent then
          raise;
   End;
end;

procedure TfrmMshoutClient.btnPingClick(Sender: TObject);
begin
    Ping(False);
end;

procedure TfrmMshoutClient.TimerPingTimer(Sender: TObject);
begin
    Try
        TimerPing.Enabled := False;

        If ClientSocket1.Active Then
        Begin
            Try
              Ping(True);
            Except
              Inc(iQtdPings);
              if iQtdPings = cnst_MaxQtdePing Then
              Begin
                 LocalDisconect(dcNoPing);
                 Reconectar(True);
              end;
            End;
        End;
    Finally
       TimerPing.Enabled := True;
    End;
end;

procedure TfrmMshoutClient.PING(Silent:Boolean=False);
var
  ms:Word;
  MsgError, sInput, sOutPut, S, otp:String;
  idx:Integer;
begin
    Try
      If Not Silent Then AddLog('Ping');

      If Assigned(Fila) Then
         sInput := sInput + 'FILAVERSION=' + IntToStr(Fila.FilaVersion);

      If Find(tfWaiting, idx) Then
      Begin
         If sInput <> '' Then
            sInput := sInput + _ ;
         sInput := sInput + 'USR_TOKEN=' + BoolToStrF(True);
      End;

      If Find(smFixed, idx) Then
      Begin
         If sInput <> '' Then
            sInput := sInput + _ ;
         sInput := sInput + 'PCCONNECTED=' + BoolToStrF(True);
      End;

      If (    OcupandoToken And TClientProtocol.FastCheckToken(ClientSocket1, MsgError, sInput, sOutPut)) Or  // Ping para ocupante é FastCheck
         (not OcupandoToken And TClientProtocol.sendPING(ClientSocket1, ms, sInput, sOutPut, Silent))  Then   // Ping para demais usuários é sendPing
      Begin
         iQtdPings := 0;
         If Not Silent Then
            AddLog('Pong: '+ IntToStr(ms) +'ms');
                
         S := TRequisicoes.GetRequisicaoStr(TFila, sOutput);
         If ((S <> '') And ( (( Assigned(Fila)) And (S <> Fila.FilaString))) or
            (not Assigned(Fila) And (S <> '')) or
            (Assigned(Fila) And (Fila.FilaString <> '') And (S = ''))) Then
         Begin
             PreparaFilaNoClient(S, True, whAll);
         end;

         S := '';
         If LerDynamicParam(sOutput, '$USR_TOKENNOME', otp, True, True) > -1 Then
            S := S + otp;
         If LerDynamicParam(sOutput, '$USR_TOKENIP', otp, True, True) > -1 Then
            S := S + ' (' + otp + ')';

         If ( S <> '' ) or
            ((S  = '' ) And (sLastOcupante <> '')) Then
         Begin
             sLastOcupante := S;
             BroadCast_MsgToForms(smFixed, tfWaiting, whFirst, bcUSR_TOKEN, S);
         End;

         S := '';
         If LerDynamicParam(sOutput, '$PCCONNECTED', otp, True, True) > -1 Then
            S := S + otp;

         If ( S <> '' ) or
            ((S  = '' ) And (sLastPCConnected <> '')) Then
         Begin
            sLastPCConnected := S;
            BroadCast_MsgToForms(smFixed, tfNone, whAll, bcPCConnected, otp);
         end;

         S := '';
         If LerDynamicParam(sOutput, '$SECONDSLEFT', otp, True, True) > -1 Then
         Begin
            S := S + otp;
            If Not IamTimed Then
            Begin
                Try
                  StrToInt(S);
                Except
                  raise EConvertError.Create('Erro ao converter $SECONDSLEFT. ('+ S +')');
                End;
                BroadCast_MsgToForms(smFixed, tfWaiting, whFirst, bcClose, '');

                frmAlerta := nil;
                Application.CreateForm(TfrmAlerta, frmAlerta);
                AlocarForm( Pointer(frmAlerta), smFixed, tfTimed );

                AddLog('Sua vez', clBlue);
                With frmAlerta do
                Begin
                    Handleprincipal          := frmMshoutClient.Handle;
                    Operacao                 := alTimed;
                    CanClose                 := False;
                    ImageList                := ImageList1;
                    SetAplhaBlend(False,False, 255, 0);
                    Fila                     := Self.Fila;

                    Fields.Value['SECONDSLEFT'] := otp;

                    If LerDynamicParam(sOutput, '$PCCONNECTED', otp, True, True) > -1 Then
                       PCConnected := OTP;

                    IamTimed := True;
                    Show;
                End;
            end Else
            Begin
                BroadCast_MsgToForms(smFixed, tfTimed, whFirst, bcSecondsLeft, S);
            end;
         End;

         S := '';
         If ((LerDynamicParam(sOutput, '$LOSTTIME', otp, True, True) > -1) And ( StrToBoolDef(otp, False) )) or
            (Force = fcTimedForm_Close) Then
         Begin
             AddLog('Seu tempo para ocupar o servidor expirou.', clRed);
             IamTimed := False;
             BroadCast_MsgToForms(smFixed, tfTimed, whFirst, bcClose, WM_Internal);
         End;
      end Else
      Begin
         If OcupandoToken Then
         Begin
             MsgError := GetLastError;
             If MsgError <> '' Then
             Begin
                LocalDisconect(dcNoPing);
                raise Exception.Create(MsgError);
             End Else
             Begin
                LocalDisconect(dcKicked);
             end;
         End Else
         Begin
             raise Exception.Create('Ping falhou');
         end;
      End;
    Except
      On E : Exception Do
      Begin
         AddLog(E.Message, clRed);
         raise;
      End;
    End;
end;

function TfrmMshoutClient.LocalDisconect( TipoDisconnect:TTipoDisconnect = dcManual ):Boolean;
var
  H       : HWnd;
  Idx     : Integer;
  wasToken: Boolean;
  ATF     : TTypeForm;
  I       : Integer;
begin
     Result   := False;
     wasToken := OcupandoTOKEN;

     SetTOKEN(False);
     Fila := nil;

     // Fechar telas de OCUPANDO e WAITING
     For I:= 1 To 2 Do
     Begin
         Case I Of
           2 : If (TipoDisconnect = dcManual) Then
                  Continue;
         End;

         ATF := IIF(I = 1, tfConnected, tfWaiting);

         H := 0;
         frAlertaFixo := Locate(smFixed, ATF, idx);
         If Assigned(frAlertaFixo) Then
            H := TFrmAlerta(frAlertaFixo).Handle;

         if H <> 0 then
         begin
            Windows.SendMessage( H, WM_SysCommand, SC_Close, WM_Internal);
            frmAlerta := nil;
            frAlertaFixo := nil;
         End;
     End;

     If wasToken Then
     Begin
         case TipoDisconnect of
           dcManual:  AddLog('Token Liberado');
           dcKicked:  AddLog('Token Liberado (Kicked)');
           dcNoPing:  AddLog('Token Liberado (No Ping)');
         End;
     End;
     
     Result := True;
end;

procedure TfrmMshoutClient.Reconectar(Ativar: Boolean);
begin
    TentandoReconectar := Ativar;
    AtualizaVisibilidades;

    If TentandoReconectar then
    Begin
       AtualizaStatus;
       TrayIcon.IconList      := CycleReconnect;
       TrayIcon.IconIndex     := 1;
       TrayIcon.CycleInterval := 300;
       TrayIcon.CycleIcons    := True;
       TrayIcon.Hint          := 'MShout - Reconectando...';

       TimerReconnect.Enabled := True;
    end Else
    begin
       TimerReconnect.Enabled := False;
       TrayIcon.CycleIcons := False;
       TrayIcon.IconList   := ImageList1;
       TrayIcon.IconIndex  := 0;
    end;
end;

procedure TfrmMshoutClient.TimerReconnectTimer(Sender: TObject);
Var
  bmp:TBitmap;
begin
    // Ativo somendo enquanto tentando Reconectar
    If TentandoReconectar Then
    begin
        TimerReconnect.Enabled := False;
        btnIniciarClick(Sender);
        If Not ClientSocket1.Active Then
        Begin
           TrayIcon.Hint := 'Reconectando...';
           TimerReconnect.Enabled := True;
        End Else
        Begin
           TrayIcon.CycleIcons    := False;
           TrayIcon.IconList      := ImageList1;
           TrayIcon.IconIndex     := 0;
        end;
    end Else
    Begin
       TimerReconnect.Enabled := False;
       TrayIcon.CycleIcons    := False;
       TrayIcon.IconList      := ImageList1;
       TrayIcon.IconIndex     := 0;
    end;

    AtualizaVisibilidades;
    AtualizaStatus;
end;

procedure TfrmMshoutClient.AtualizaStatus;
begin
    If ClientSocket1.Active Then
    begin
       lblStatus.Caption    := 'Ligado';
       lblStatus.Font.Color := clGreen;
    end Else
    Begin
       If Not TentandoReconectar Then
       Begin
           lblStatus.Caption    := 'Desligado';
           lblStatus.Font.Color := clRed;
       End Else
       Begin
           lblStatus.Caption    := 'Reconectando';
           lblStatus.Font.Color := clOlive;
       end;
    end;

    lblStatus.Font.Style := [fsBold];
end;

procedure TfrmMshoutClient.FormDestroy(Sender: TObject);
begin
    If Assigned(ListaVersoes) Then
       ListaVersoes.Clear;
    FreeAndNil( ListaVersoes );
    FreeAndNil( Fila );
end;

procedure TfrmMshoutClient.ConectarVersoes(Sender: TObject ; sVersoes:String='' );
begin
    If OcupandoTOKEN Then
    Begin
        Windows.SendMessage( frmMshoutClient.Handle , WM_LIBERARTOKEN, SC_CLOSE, 0);
        AtualizaVisibilidades;
        Exit;
    End;

    If Executa(opConnect, sVersoes)  Then
    Begin
       If INI_AutoConnect Then
       Begin
         Try
            ClientHandleThread := TClientHandleThread.Create(False);

            With ClientHandleThread Do
            Begin
                FreeOnTerminate := True;
                fMainHandle     := Self.Handle;
                Execucao        := exMstsc;
                if FileExists( sPath + 'connection.rdp' ) then
                   Value1 := sPath + 'connection.rdp'
                else
                   Value1 := '/v: '+ cfg_IPControl;
                Resume;
            end;
         Except
           On E : Exception Do
           Begin
              raise Exception.Create('Erro ao executar "mstsc": '+ E.Message);
           End;
         End;
       End;
    End;
end;

procedure TfrmMshoutClient.btnConectarClick(Sender: TObject);
Var
  H:HWND;
  BarraIniciar: HWND; {Barra Iniciar}
  tmAltura: Integer;
  tmRect: TRect;
begin
    H := FindWindow(nil, sHideTitle);

    If OcupandoTOKEN then
    begin
        Windows.SendMessage( frmMshoutClient.Handle , WM_LIBERARTOKEN, SC_CLOSE, 0);
        Exit;
    end;

    if H = 0 then
    Begin
        frmListVersoes := TfrmListVersoes.Create(Self, True);
        frmListVersoes.HandlePrincipal := frmMshoutClient.Handle;
        frmListVersoes.SenderObj       := Sender;

        frmListVersoes.PreencheListBoxVersoes(ListaVersoes);

        //localiza o Handle da Barra iniciar
        BarraIniciar    := FindWindow('Shell_TrayWnd', nil);

        //Pega o "retângulo" que envolve a barra e sua altura
        GetWindowRect(BarraIniciar, tmRect);
        tmAltura := tmRect.Bottom - tmRect.Top;

        With frmListVersoes Do
        Begin
          Left := (Screen.Width - ClientWidth) - 10;

          if tmRect.Top = -2 then
            tmAltura := 30;

          Top := (Screen.Height - ClientHeight - tmAltura) - 10;
        end;

        frmListVersoes.Show;
    End Else
    Begin
        Try
          frmListVersoes.Close;
        except
          FreeAndNil( frmListVersoes );
        End;
    end;
end;

procedure TfrmMshoutClient.lblCloseClick(Sender: TObject);
begin
    Close;
end;

procedure TfrmMshoutClient.WMConectar(var Msg: TWMSysCommand);
var
  S:string;
begin
    Case (Msg.CmdType) of
      SC_MENUITEM:
        Begin
            S := ListaVersoes.ListToString(Sep, SubSep, frmListVersoes.GetCheckedIndexes(ListaVersoes) );
            ConectarVersoes( mnuConectar, S );
            frmListVersoes.Close;
        End;
      SC_SPEEDBUTTON:
        begin
            S := ListaVersoes.ListToString(Sep, SubSep, frmListVersoes.GetCheckedIndexes(ListaVersoes) );
            ConectarVersoes( BtnConectar, S );
            frmListVersoes.Close;
        end;
      SC_CONECTAR_RECURSV:
        begin
            btnConectarClick( BtnConectar );
        end;
    Else
       Inherited
    End;
end;

procedure TfrmMshoutClient.PreparaFilaNoClient(strFila: String ; AvisaForms:Boolean ; TpSender:Twho);
begin
    If Assigned(Fila) Then
       FreeAndNil(Fila);

    If StrFila <> '' Then
       TFila.SplitFila(strFila, frmMshoutClient, Sep, SubSep, Fila);

    If AvisaForms Then
       BroadCast_MsgToForms(smFixed, tfNone, TpSender, bcFila, '');
end;

procedure TfrmMshoutClient.WMEntrarFila(var Msg: TWMSysCommand);
var
  Input:TInput;
  Output:TOutput;
  VersoesGerando:TListVersao;
begin
    Input := TInput.Create;
    Input.ClientSocket := ClientSocket1;
    If Msg.CmdType = SC_ATUALIZAR Then
       Input.Fields.Value['ATUALIZAR'] := '1'
    Else
       Input.Fields.Value['ATUALIZAR'] := '0';

    Output := TOutput.Create;
    Try
      Try
        If TClientProtocol.sendEntrarNaFila(Input, Output) Then
        Begin
            // Fila
            If (Output.Fields.FieldExists('FILA') ) And (Output.Fields.Value['FILA'] <> '') And ( (( Assigned(Fila)) And (Output.Fields.Value['FILA'] <> Fila.FilaString)) or (not Assigned(Fila))) Then
            Begin
                PreparaFilaNoClient(Output.Fields.Value['FILA'], True, whAll);
            end;

            // Lista de Versoes
            TListVersao.DecodeVersoesToList(Output.Fields.Value['VERSOES'],Sep, SubSep, VersoesGerando);

            CriaTela(tfWaiting, VersoesGerando, Output);
        end;
      Except
        On E : Exception Do
        Begin
            AddLog('WMEntrarFila: ' + E.Message, clRed);
        end;
      End;
    Finally
      FreeAndNil(Input);
      FreeAndNil(Output);
      FreeAndNil(VersoesGerando);
    End;
end;

procedure TfrmMshoutClient.WMSairFila(var Msg: TWMSysCommand);
var
  Input:TInput;
  Output:TOutput;
begin
    If (Msg.CmdType <> SC_DESISTENCIA) And
       (Msg.CmdType <> SC_CHEGOUVEZ) Then
       AddLog('WMSairFila: CmdType inválido.'+#13+ IntToStr(Msg.CmdType), clRed);

    Input := TInput.Create;
    Input.ClientSocket := ClientSocket1;
    If Msg.CmdType = SC_DESISTENCIA Then
       Input.Fields.Value['TIPO_SAIDA'] := cnst_SairFilaDesistiu
    Else
    If Msg.CmdType = SC_CHEGOUVEZ Then
       Input.Fields.Value['TIPO_SAIDA'] := cnst_SairFilaChegouVez;

    Output := TOutput.Create;
    Try
      Try
        If TClientProtocol.sendSairFila(Input, Output) Then
        Begin
          If Msg.CmdType = SC_DESISTENCIA Then
          Begin
             BroadCast_MsgToForms(smFixed, tfWaiting, whFirst, bcClose, '');
          End Else
          If Msg.CmdType = SC_CHEGOUVEZ Then
          Begin
             Input.Fields.Value['TIPO_SAIDA'] := cnst_SairFilaChegouVez;
          End;
        End;
      Except
        On E : Exception Do
        Begin
            AddLog('WMSairFila: ' + E.Message, clRed);
        end;
      End;
    Finally
      FreeAndNil(Input);
      FreeAndNil(Output);
    End;
end;

procedure TfrmMshoutClient.BroadCast_MsgToForms(FormsMode:TShowMode ; ATyp:TTypeForm ; Sender:TWho ; Msg:TBCastMsg ; Value:Variant);
Var
  idx:Integer;
  Mem:^TfrmAlerta;
  Achou:Boolean;
begin
    Achou := False;
    idx := -1;
    
    repeat
        If FormsMode = smNone Then
        Begin
            If ATyp = tfNone Then
               raise Exception.Create('Não é permitido fazer um BroadCast nulo.')
            else
               Mem := Locate(ATyp, idx);
        end Else
        Begin
            If ATyp = tfNone Then
               Mem := Locate(FormsMode, idx)
            else
               Mem := Locate(FormsMode, ATyp, idx);
        end;

        If Assigned(Mem) And (TFrmAlerta(Mem).Handle > 0) Then
        Begin
           If Msg = bcFila Then
              TfrmAlerta(Mem).Fila := Self.Fila
           Else
           If Msg = bcClose Then
              Windows.SendMessage( TfrmAlerta(Mem).Handle , WM_SYSCOMMAND, SC_CLOSE, WM_Internal)
           Else
           If Msg = bcUSR_TOKEN Then
              TfrmAlerta(Mem).Fields.Value['USR_TOKEN'] := VarToStr(Value)
           Else
           If Msg = bcSecondsLeft Then
              TfrmAlerta(Mem).Fields.Value['SECONDSLEFT'] := VarToStr(Value)
           Else
           If Msg = bcPCConnected Then
              TfrmAlerta(Mem).PCConnected := VarToStr(Value);

           Achou := True;
        end;

        Inc(idx);
    until ((Sender = whFirst) And (Achou)) or (idx > cnst_MaxQtdForms);
end;

procedure TfrmMshoutClient.CriaTela(ATyp: TTypeForm; AVersoes:TListVersao ; AOutput:TOutput);
Var
  S:String;
begin
    If ATyp = tfWaiting Then
    Begin
            frmAlerta := nil;
            Application.CreateForm(TfrmAlerta, frmAlerta);
            AlocarForm( Pointer(frmAlerta), smFixed, tfWaiting );

            DTEntrouFila := Now();
            AddLog('Entrou na Fila', clBlue);
            With frmAlerta do
            Begin
                Handleprincipal          := frmMshoutClient.Handle;
                Operacao                 := alWaiting;
                ImageList                := ImageList1;
                SetAplhaBlend(False,False, 255, 0);
                Fila                     := Self.Fila;
                If AVersoes<>nil Then
                   Versoes               := AVersoes;

                Fields.Value['TEMPO_ENTRADA_FILA'] := FloatToStr( DTEntrouFila );

                If AOutput.Fields.FieldExists('PCCONNECTED') Then
                   PCConnected := AOutput.Fields.Value['PCCONNECTED'];

                Begin
                    S := '';
                    If AOutput.Fields.FieldExists('USR_TOKENNOME') Then
                       S := S + AOutput.Fields.Value['USR_TOKENNOME'];
                    If AOutput.Fields.FieldExists('USR_TOKENIP') Then
                       S := S + ' (' + AOutput.Fields.Value['USR_TOKENIP'] + ')';

                    If S <> '' Then
                       Fields.Value['USR_TOKEN'] := S;
                End;

                Show;
            End;
    end Else
       raise Exception.Create('Tipo desconhecido de TTypeForm.');
end;

end.
