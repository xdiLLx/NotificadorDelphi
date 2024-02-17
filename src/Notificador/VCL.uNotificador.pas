unit uNotificador;

interface

uses
  System.Generics.Collections,
  Vcl.StdCtrls,
  Vcl.Graphics,
  Vcl.ExtCtrls,
  Vcl.Controls,
  Classes,
  Vcl.Forms;

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
    FPanelNotificacao: TPanel;
    FPanelListra: TPanel;
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
  AlturaDaLinha: Integer = 12;
  TamanhoFonteTitulo: Integer = 14;
  TamanhoFonteMensagem: Integer = 12;

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
  FLabelMensagem.Caption := FMensagem;
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
  FLabelTitulo.Caption := FTitulo;
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
begin
  lPosicaoTopAtual := Application.MainForm.ClientHeight - 5;

  for var Item in ListaDeNotificadores do
  begin
    lPosicaoTopAtual := lPosicaoTopAtual - TNotificador(Item)
      .FPanelNotificacao.Height - 5;
    TNotificador(Item).FPanelNotificacao.Top := lPosicaoTopAtual;
  end;
end;

procedure TNotificador.ConfigurarFundo;
begin
  FPanelNotificacao.Parent := Application.MainForm;
  FPanelNotificacao.Height := 120 + FAlturaAdicional;
  FPanelNotificacao.Width := 380;
  FPanelNotificacao.DoubleBuffered := true;
  FPanelNotificacao.ParentBackground := false;
  FPanelNotificacao.ParentColor := false;
  FPanelNotificacao.StyleElements := [];
  FPanelNotificacao.DoubleBuffered := true;
  FPanelNotificacao.BevelInner := bvNone;
  FPanelNotificacao.BevelOuter := bvNone;
  FPanelNotificacao.BevelKind := bkTile;
  FPanelNotificacao.Color := clWhite;
  FPanelNotificacao.Left := Application.MainForm.Width -
    FPanelNotificacao.Width - 10;
  FPanelNotificacao.Top := Application.MainForm.Height -
    FPanelNotificacao.Height - 45;
  FPanelNotificacao.BringToFront;
end;

procedure TNotificador.ConfigurarIconeFechar;
begin
  FLabelFechar.Parent := FPanelNotificacao;
  FLabelFechar.StyleElements := [];
  FLabelFechar.Font.Name := 'Segoe MDL2 Assets';
  FLabelFechar.Caption := '';
  FLabelFechar.Font.Size := 14;
  FLabelFechar.Font.Style := [];
  FLabelFechar.Font.Color := clBlack;
  FLabelFechar.Top := FLabelTitulo.Top;
  FLabelFechar.Left := FLabelTitulo.Width - 15;
  FLabelFechar.BringToFront;
  FLabelFechar.OnClick := Fechar;
end;

procedure TNotificador.Fechar(Sender: TObject);
begin
  RemoverDaListaNotificadores;
  LimparComponentes;
end;

procedure TNotificador.ConfigurarListra;
begin
  FPanelListra.Parent := FPanelNotificacao;
  FPanelListra.Align := alBottom;
  FPanelListra.Height := 5;
  FPanelListra.BevelOuter := bvNone;
  FPanelListra.Caption := '';
  FPanelListra.StyleElements := [];
  FPanelListra.ParentBackground := false;
  FPanelListra.ParentColor := false;

  case FModeloMensagem of
    msgNormal:
      begin
        FPanelListra.Color := clHighlight;
      end;
    msgErro:
      begin
        FPanelListra.Color := clRed;
      end;
    msgSucesso:
      begin
        FPanelListra.Color := clLime;
      end;
    msgAtencao:
      begin
        FPanelListra.Color := clYellow;
      end;
  end;

  FPanelListra.SendToBack;
end;

procedure TNotificador.ConfigurarMensagem;
begin
  FLabelMensagem.Parent := FPanelNotificacao;
  FLabelMensagem.StyleElements := [];
  FLabelMensagem.Font.Name := 'Tahoma';
  FLabelMensagem.Font.Size := TamanhoFonteMensagem;
  FLabelMensagem.Font.Style := [];
  FLabelMensagem.Font.Color := $666666;
  FLabelMensagem.Align := alClient;
  FLabelMensagem.AlignWithMargins := true;
  FLabelMensagem.Margins.Top := 5;
  FLabelMensagem.Margins.Left := 10;
  FLabelMensagem.Margins.Bottom := 3;
  FLabelMensagem.Margins.Right := 3;
  FLabelMensagem.Alignment := TAlignment.taLeftJustify;
  FLabelMensagem.WordWrap := true;
  FLabelMensagem.AutoSize := true;
  FLabelMensagem.BringToFront;
end;

procedure TNotificador.ConfigurarTitulo;
begin
  FLabelTitulo.Parent := FPanelNotificacao;
  FLabelTitulo.StyleElements := [];
  FLabelTitulo.Font.Name := 'Roboto';
  FLabelTitulo.Font.Size := TamanhoFonteTitulo;
  FLabelTitulo.Font.Style := [fsBold];
  FLabelTitulo.Font.Color := clBlack;
  FLabelTitulo.Align := alTop;
  FLabelTitulo.AlignWithMargins := true;
  FLabelTitulo.Margins.Top := 10;
  FLabelTitulo.Margins.Left := 10;
  FLabelTitulo.Alignment := TAlignment.taLeftJustify;
  FLabelTitulo.Layout := tlCenter;
end;

procedure TNotificador.CriarComponentesVisuais;
begin
  FPanelNotificacao := TPanel.Create(Application.MainForm);
  FPanelListra := TPanel.Create(FPanelNotificacao);
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
    if (FPanelNotificacao.Left + 5) > Application.MainForm.Width -
      FPanelNotificacao.Width - 15 then
      FPanelNotificacao.Left := FPanelNotificacao.Left - 2
    else
      FTimerAnimacao.Enabled := false;
  except

  end;
end;

procedure TNotificador.LimparComponentes;
begin
  FTimerAnimacao.Enabled:= False;
  FTimerFechar.Enabled:= False;

  FPanelListra.Free;
  FLabelTitulo.Free;
  FLabelMensagem.Free;
  FLabelFechar.Free;
  FTimerAnimacao.Free;
  FTimerFechar.Free;
  FPanelNotificacao.Free;
end;

initialization

ListaDeNotificadores := TList<INotificador>.Create;

finalization

FreeAndNil(ListaDeNotificadores);

end.
