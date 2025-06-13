unit FMX.uNotificador;

interface

uses
  System.Generics.Collections,
  Classes,
  FMX.StdCtrls,
  FMX.Types,
  FMX.Forms,
  fmx.Objects,
  System.UITypes;

type
  TTipoMensagem = (msgNormal, msgErro, msgSucesso, msgAtencao);

type
  INotificador = interface
    ['{C7510256-8847-4162-8DE2-273AC85290B9}']
    function Titulo(Value: string): INotificador;
    function Mensagem(Value: string): INotificador;
    function ModeloMensagem(Value: TTipoMensagem): INotificador;
    function TempoExibicao(Value: Cardinal): INotificador;
    procedure ExibirNotificacao;
  end;

type
  TNotificador = class(TInterfacedObject, INotificador)

  strict private
    FPanelNotificacao: TRectangle;
    FPanelListra: TRectangle;
    FLabelTitulo: TLabel;
    FLabelMensagem: TLabel;
    FLabelFechar: TLabel;
    FTimerAnimacao: TTimer;
    FTimerFechar: TTimer;
    procedure AplicarConfiguracaoPadrao;
    procedure ConfigurarFundo;
    procedure ConfigurarListra;
    procedure ConfigurarTitulo;
    procedure ConfigurarMensagem;
    procedure ConfigurarIconeFechar;
    procedure CriarComponentesVisuais;
    procedure CriarTemporizadores;
    procedure LimparComponentes;
    procedure AplicarConfiguracaoComponentes;
    procedure VerificarAlturaNotificacao;
    procedure IniciarTemporizadores;
    procedure FazerAnimacao(Sender: TObject);
    procedure AtualizarPosicao;
    procedure InserirNaListaNotificadores;
    procedure RemoverDaListaNotificadores;
    procedure Fechar(Sender: TObject);

  private
    FTitulo: string;
    FMensagem: string;
    FModeloMensagem: TTipoMensagem;
    FTempoExibicao: Cardinal;
    FAlturaAdicional: Integer;
    function Titulo(Value: string): INotificador;
    function Mensagem(Value: string): INotificador;
    function ModeloMensagem(Value: TTipoMensagem): INotificador;
    function TempoExibicao(Value: Cardinal): INotificador;
    procedure ExibirNotificacao;

  public
    constructor Create;
    destructor Destroy; override;
    class function New: INotificador;
  end;

const
  AlturaDaLinha: Integer = 7;
  TamanhoFonteTitulo: Integer = 14;
  TamanhoFonteMensagem: Integer = 13;

var
  ListaDeNotificadores: TList<INotificador>;

implementation

uses
  System.SysUtils;

{ TNotificador }

constructor TNotificador.Create;
begin
  AplicarConfiguracaoPadrao;
  CriarComponentesVisuais;
  AplicarConfiguracaoComponentes;
  CriarTemporizadores;
  InserirNaListaNotificadores;
end;

destructor TNotificador.Destroy;
begin

  LimparComponentes;
  inherited;
end;

procedure TNotificador.ExibirNotificacao;
begin
  VerificarAlturaNotificacao;
  ConfigurarFundo;
  ConfigurarListra;
  ConfigurarMensagem;
  IniciarTemporizadores;
  AtualizarPosicao;
end;

function TNotificador.Mensagem(Value: string): INotificador;
begin
  if Value = '' then
    raise Exception.Create('Mensagem da notificação não pode ser vazia');

  FMensagem := Value;
  FLabelMensagem.Text := FMensagem;
  Result := Self;
end;

function TNotificador.TempoExibicao(Value: Cardinal): INotificador;
begin
  FTempoExibicao := Value;
  FTimerFechar.Interval := FTempoExibicao;
  Result := Self;
end;

function TNotificador.Titulo(Value: string): INotificador;
begin
  if Value = '' then
    raise Exception.Create('Título da notificação não pode estar em branco');

  FTitulo := Value;
  FLabelTitulo.Text := FTitulo;
  Result := Self;
end;

function TNotificador.ModeloMensagem(Value: TTipoMensagem): INotificador;
begin
  FModeloMensagem := Value;
  Result := Self;
end;

procedure TNotificador.InserirNaListaNotificadores;
begin
  ListaDeNotificadores.Insert(0, Self);
end;

procedure TNotificador.RemoverDaListaNotificadores;
begin
  ListaDeNotificadores.Remove(Self);
  if ListaDeNotificadores.Count > 0 then
    TNotificador(ListaDeNotificadores[0]).AtualizarPosicao;
end;

procedure TNotificador.AplicarConfiguracaoComponentes;
begin
  ConfigurarFundo;
  ConfigurarListra;
  ConfigurarTitulo;
  ConfigurarMensagem;
  ConfigurarIconeFechar;
end;

procedure TNotificador.IniciarTemporizadores;
begin
  FTimerAnimacao.Enabled := true;
  FTimerFechar.Enabled := true;
end;

class function TNotificador.New: INotificador;
begin
  Result := Self.Create;
end;

procedure TNotificador.VerificarAlturaNotificacao;
var
  lNovasLinhas: Integer;
begin
  lNovasLinhas := Length(FMensagem);
  if (lNovasLinhas / 47) > 3 then
  begin
    lNovasLinhas := Trunc(Length(FMensagem) / 47) + 1;
    FAlturaAdicional := lNovasLinhas * AlturaDaLinha;
  end;
end;

procedure TNotificador.AplicarConfiguracaoPadrao;
begin
  FTempoExibicao := 10000;
  FAlturaAdicional := 0;
  FModeloMensagem := msgNormal;
end;

procedure TNotificador.AtualizarPosicao;
var
  lPosicaoTopAtual: Integer;
  lEspaco: double;
begin
  lPosicaoTopAtual := Application.MainForm.ClientHeight - 5;
  lEspaco:= 5;
  for var Item in ListaDeNotificadores do
  begin
    lPosicaoTopAtual := Trunc(lPosicaoTopAtual - TNotificador(Item)
      .FPanelNotificacao.Height - lEspaco);
    TNotificador(Item).FPanelNotificacao.Position.Y := lPosicaoTopAtual;
  end;
end;

procedure TNotificador.ConfigurarFundo;
begin
  FPanelNotificacao.Parent := Application.MainForm;
  FPanelNotificacao.Height := 120 + FAlturaAdicional;
  FPanelNotificacao.Width := 380;
  FPanelNotificacao.Stroke.Thickness:= 0;
  FPanelNotificacao.Fill.Color := TAlphaColorRec.White;
  FPanelNotificacao.Position.X := Application.MainForm.Width -
    FPanelNotificacao.Width - 10;
  FPanelNotificacao.Position.Y := Application.MainForm.Height -
    FPanelNotificacao.Height - 45;
  FPanelNotificacao.BringToFront;
end;

procedure TNotificador.ConfigurarIconeFechar;
begin
  FLabelFechar.Parent := FPanelNotificacao;
  FLabelFechar.StyledSettings:=[];
  FLabelFechar.TextSettings.Font.Family := 'Segoe MDL2 Assets';
  FLabelFechar.Text := '';
  FLabelFechar.HitTest := true;
  FLabelFechar.Font.Size := 14;
  FLabelFechar.Font.Style := [];
  FLabelFechar.FontColor := TAlphaColorRec.Black;
  FLabelFechar.Position.Y := FLabelTitulo.Position.Y;
  FLabelFechar.Position.x := FLabelTitulo.Width - 15;
  FLabelFechar.BringToFront;
  FLabelFechar.OnClick := Fechar;
end;

procedure TNotificador.Fechar(Sender: TObject);
begin
  RemoverDaListaNotificadores;
  LimparComponentes;
  //destroy;
end;

procedure TNotificador.ConfigurarListra;
begin
  FPanelListra.Parent := FPanelNotificacao;
  FPanelListra.Align := TAlignLayout.Bottom;
  FPanelListra.Height := 5;
  FPanelListra.Stroke.Thickness:=0;

  case FModeloMensagem of
    msgNormal:
      begin
        FPanelListra.FILL.Color := TAlphaColorRec.Darkblue;
      end;
    msgErro:
      begin
        FPanelListra.FILL.Color := TAlphaColorRec.Red;
      end;
    msgSucesso:
      begin
        FPanelListra.FILL.Color := TAlphaColorRec.Lime;
      end;
    msgAtencao:
      begin
        FPanelListra.FILL.Color := TAlphaColorRec.Yellow;
      end;
  end;

  FPanelListra.SendToBack;
end;

procedure TNotificador.ConfigurarMensagem;
begin
  FLabelMensagem.Parent := FPanelNotificacao;
  FLabelMensagem.StyledSettings:=[];
  FLabelMensagem.Font.Family := 'Tahoma';
  FLabelMensagem.Font.Size := TamanhoFonteMensagem;
  FLabelMensagem.Font.Style := [];
  FLabelMensagem.FontColor := TAlphaColorRec.Darkgray;
  FLabelMensagem.Align := TAlignLayout.Client;
  FLabelMensagem.Margins.Top := 1;
  FLabelMensagem.Margins.Left := 10;
  FLabelMensagem.Margins.Bottom := 1;
  FLabelMensagem.Margins.Right := 3;
  FLabelMensagem.TextSettings.HorzAlign := TTextAlign.Leading;
  FLabelMensagem.WordWrap := true;
  FLabelMensagem.AutoSize := true;
  FLabelMensagem.BringToFront;
end;

procedure TNotificador.ConfigurarTitulo;
begin
  FLabelTitulo.Parent := FPanelNotificacao;
  FLabelTitulo.StyledSettings:=[];
  FLabelTitulo.Font.Family := 'Tahoma';
  FLabelTitulo.Font.Size := TamanhoFonteTitulo;
  FLabelTitulo.Font.Style := [TFontStyle.fsBold];
  FLabelTitulo.FontColor := TAlphaColorRec.Black;
  FLabelTitulo.Align := TAlignLayout.Top;
  FLabelTitulo.Margins.Top := 10;
  FLabelTitulo.Margins.Left := 10;
  FLabelTitulo.TextSettings.HorzAlign := TTextAlign.Leading;
  FLabelTitulo.TextSettings.VertAlign := TTextAlign.Center;
end;

procedure TNotificador.CriarComponentesVisuais;
begin
  FPanelNotificacao := TRectangle.Create(Application.MainForm);
  FPanelListra := TRectangle.Create(FPanelNotificacao);
  FLabelTitulo := TLabel.Create(FPanelNotificacao);
  FLabelMensagem := TLabel.Create(FPanelNotificacao);
  FLabelFechar := TLabel.Create(FPanelNotificacao);
end;

procedure TNotificador.CriarTemporizadores;
begin
  FTimerAnimacao := TTimer.Create(FPanelNotificacao);
  FTimerAnimacao.Interval := 5;
  FTimerAnimacao.Enabled := false;
  FTimerAnimacao.OnTimer := FazerAnimacao;

  FTimerFechar := TTimer.Create(FPanelNotificacao);
  FTimerFechar.Interval := FTempoExibicao;
  FTimerFechar.Enabled := false;
  FTimerFechar.OnTimer := Fechar;
end;

procedure TNotificador.FazerAnimacao(Sender: TObject);
begin
  try
    if (FPanelNotificacao.Position.X + 5) > Application.MainForm.Width -
      FPanelNotificacao.Width - 15 then
      FPanelNotificacao.Position.X := FPanelNotificacao.Position.X - 2
    else
      FTimerAnimacao.Enabled := false;
  except

  end;
end;

procedure TNotificador.LimparComponentes;
begin
  FTimerAnimacao.Enabled:= False;
  FTimerFechar.Enabled:= False;
  FreeAndNil(FPanelNotificacao);
end;

initialization

ListaDeNotificadores := TList<INotificador>.Create;

finalization

FreeAndNil(ListaDeNotificadores);

end.
