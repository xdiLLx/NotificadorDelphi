# Notificador Delphi

This repository contains simple notifier components for Delphi applications.
It provides units for both FMX (FireMonkey) and VCL frameworks, allowing applications
to display small notification panels with a title, message, and automatic closing.

## Overview

- **`src/Notificador/FMX.uNotificador.pas`** – Implementation for FMX applications using `TRectangle` and FMX controls.
- **`src/Notificador/VCL.uNotificador.pas`** – Implementation for classic VCL applications using `TPanel` and VCL controls.

Both units expose the `INotificador` interface with a fluent API to configure
the notification text, message type and display time. Notifications slide in from
the bottom-right corner of the main form and close automatically after the
specified period.

## Basic Usage

```delphi
uses
  FMX.uNotificador; { or VCL.uNotificador in a VCL project }

procedure TForm1.Button1Click(Sender: TObject);
begin
  TNotificador.New
    .Titulo('Aviso')
    .Mensagem('Operação realizada com sucesso')
    .ModeloMensagem(msgSucesso)
    .TempoExibicao(5000) { milliseconds }
    .ExibirNotificacao;
end;
```

## Build Requirements

- A modern version of **Embarcadero Delphi** with support for the
  desired framework (FMX or VCL). The code was tested with Delphi 10.x,
  but should compile in recent versions that include generics and the
  FMX library.

Simply add the appropriate unit to your project and call `TNotificador.New`
from your forms to show a notification.
