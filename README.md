# SENAI CheckIn

Aplicativo desenvolvido para a atividade do **Módulo 5 — Programação para Dispositivos Móveis**, com foco no registro de ponto e diário de campo utilizando recursos de hardware do dispositivo.

O **SENAI CheckIn** permite registrar informações de uma atividade presencial por meio de **foto, localização GPS e observação**, armazenando os dados localmente com **SQLite**.

---

## Tecnologias utilizadas

* **Flutter 3.44+**
* **Dart 3.12+**
* **Android**
* **SQLite**
* **GPS / Geolocalização**
* **Câmera**
* **Gerenciamento de permissões**
* **Material Design**

### Principais bibliotecas

* `image_picker` — captura e recuperação de imagens.
* `geolocator` — obtenção da localização do dispositivo.
* `permission_handler` — gerenciamento das permissões.
* SQLite — armazenamento local dos registros.

---

## Funcionalidades

O aplicativo possui as seguintes funcionalidades:

*  Captura de fotos utilizando a câmera.
*  Obtenção da localização atual por GPS.
*  Adição de observações aos registros.
*  Armazenamento local utilizando SQLite.
*  Histórico de registros realizados.
*  Visualização das fotos salvas.
*  Visualização da localização em mapa.
*  Som de confirmação após o cadastro.
*  Controle das permissões de câmera e localização.
*  Recuperação de fotos caso o Android encerre o aplicativo durante o uso da câmera.
*  Tratamento de erros e situações como GPS desligado ou permissões negadas.

---

## Como executar

### Pré-requisitos

* Flutter 3.44 ou superior
* Dart 3.12 ou superior
* Android 7.0 / API 24 ou superior
* Android Studio ou outro ambiente configurado para desenvolvimento Flutter
* Dispositivo Android ou emulador

### Instalação

Clone o projeto e entre na pasta:

```bash
git clone <URL_DO_REPOSITORIO>
cd senaicheckln
```

Instale as dependências:

```bash
flutter pub get
```

Execute o aplicativo:

```bash
flutter run
```

> O projeto possui somente a plataforma Android. Para utilizar todas as funcionalidades, recomenda-se executar em um dispositivo ou emulador com câmera e localização disponíveis.

---

## Fluxo do aplicativo

O funcionamento principal segue o seguinte fluxo:

```text
Novo registro
      ↓
Permissão da câmera
      ↓
Captura da foto
      ↓
Permissão de localização
      ↓
Obtenção do GPS
      ↓
Observação
      ↓
Salvamento
      ↓
SQLite + arquivo da foto
      ↓
Confirmação
      ↓
Histórico
      ↓
Detalhes + mapa
```

### Criando um registro

1. Acesse **Novo registro**.
2. Autorize o acesso à câmera quando solicitado.
3. Capture uma foto.
4. Autorize o acesso à localização.
5. Obtenha a posição atual do dispositivo.
6. Adicione uma observação, se necessário.
7. Salve o registro.
8. O aplicativo armazena os dados no SQLite e salva permanentemente a imagem.
9. Uma confirmação é apresentada ao usuário.
10. O registro pode ser consultado posteriormente no histórico.

---

##  Armazenamento de dados

Os registros são armazenados localmente em uma tabela chamada:

```text
registros
```

### Campos

| Campo             | Descrição                          |
| ----------------- | ---------------------------------- |
| `id`              | Identificador do registro          |
| `data_hora`       | Data e hora do registro em UTC     |
| `latitude`        | Latitude obtida pelo GPS           |
| `longitude`       | Longitude obtida pelo GPS          |
| `precisao`        | Precisão da localização            |
| `observacao`      | Observação adicionada pelo usuário |
| `caminho_da_foto` | Caminho da imagem armazenada       |

As datas são armazenadas em UTC e apresentadas ao usuário de acordo com o horário local.

As imagens capturadas pela câmera são inicialmente armazenadas no cache temporário do aplicativo. Antes do registro ser salvo no banco, a imagem é copiada para a pasta privada `imagens`, garantindo sua persistência.

---

## Tratamento de erros

O aplicativo possui tratamentos para diferentes situações durante a utilização.

### Permissões

Quando uma permissão é negada, o aplicativo apresenta uma orientação ao usuário.

Em casos de bloqueio permanente da permissão, o aplicativo orienta o usuário a acessar as configurações do sistema.

### GPS

Caso a localização esteja desativada, o usuário é orientado a ativar o serviço de localização.

A obtenção da localização possui um limite de tempo de **25 segundos**, permitindo uma nova tentativa caso a primeira falhe.

O aplicativo não utiliza coordenadas fictícias ou uma localização antiga desconhecida como substituição.

Localizações com mais de dois minutos são atualizadas antes do salvamento.

### Câmera

O Android pode encerrar o processo do aplicativo enquanto a câmera está aberta.

Para essa situação, o aplicativo utiliza `retrieveLostData` para recuperar a imagem perdida e permitir que o usuário continue o cadastro.

### Salvamento

O botão de salvamento é bloqueado durante operações para evitar registros duplicados.

Caso ocorra uma falha na inserção do registro, a imagem recém-copiada também é removida.

Uma falha no áudio de confirmação não interfere em um registro que já foi salvo corretamente.

---

## Organização do projeto

```text
lib/
├── main.dart
├── registro_model.dart
├── registro_dbhelper.dart
├── hardware_service.dart
├── registro_page.dart
├── cadastro_page.dart
└── detalhes_page.dart

assets/
└── sounds/
    └── confirmacao.wav
```

### Principais arquivos

| Arquivo                  | Responsabilidade                                 |
| ------------------------ | ------------------------------------------------ |
| `main.dart`              | Inicialização e configuração do aplicativo       |
| `registro_model.dart`    | Modelo dos registros e conversão dos dados       |
| `registro_dbhelper.dart` | Criação e gerenciamento do banco SQLite          |
| `hardware_service.dart`  | Câmera, GPS e permissões                         |
| `registro_page.dart`     | Histórico dos registros e recuperação de fotos   |
| `cadastro_page.dart`     | Cadastro e salvamento de novos registros         |
| `detalhes_page.dart`     | Exibição da foto, observação, coordenadas e mapa |
| `confirmacao.wav`        | Som de confirmação do cadastro                   |

---

## Validação

Para verificar o projeto, utilize:

```bash
flutter analyze
```

```bash
flutter test
```

```bash
flutter build apk --debug
```

Os testes automatizados verificam:

* Conversão dos dados do registro.
* Preservação do instante do registro.
* Coordenadas de localização.
* Omissão do `id` em novos registros para permitir sua geração pelo banco.

Os testes automatizados não substituem a validação dos recursos de hardware diretamente no Android.

### Status da validação

*  `flutter analyze`
*  `flutter test`
*  2 testes automatizados aprovados
*  `flutter build apk --debug`
*  APK gerado em:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

A validação dos recursos físicos de câmera e GPS depende de um dispositivo Android ou emulador compatível.

---

## 📋 Checklist de apresentação

* [ ] Autorizar câmera e GPS.
* [ ] Capturar uma foto.
* [ ] Obter a localização.
* [ ] Criar e salvar um registro.
* [ ] Conferir o som de confirmação.
* [ ] Fechar e abrir novamente o aplicativo.
* [ ] Verificar a persistência dos registros.
* [ ] Testar permissões negadas.
* [ ] Testar bloqueio permanente de permissões.
* [ ] Testar GPS desligado.
* [ ] Testar localização aproximada/imprecisa.
* [ ] Testar tempo limite da localização.
* [ ] Cancelar a câmera.
* [ ] Tentar salvar sem foto.
* [ ] Tentar salvar sem localização.
* [ ] Abrir os detalhes de um registro.
* [ ] Conferir a localização no mapa.
* [ ] Criar mais de um registro.
* [ ] Conferir a ordem dos registros.
* [ ] Testar o aplicativo sem internet.

---

## Objetivo do projeto

O projeto foi desenvolvido com o objetivo de aplicar conceitos de **desenvolvimento mobile**, integração com recursos de hardware e persistência de dados.

O fluxo principal integra:

```text
Permissões
    ↓
Câmera + GPS
    ↓
Arquivo da imagem
    ↓
SQLite
    ↓
Confirmação
    ↓
Histórico
    ↓
Visualização dos detalhes
```

Dessa forma, o projeto demonstra a utilização de recursos nativos do dispositivo em conjunto com uma aplicação Flutter.

---

## Documentação

* [image_picker](https://pub.dev/packages/image_picker)
* [geolocator](https://pub.dev/packages/geolocator)
* [permission_handler](https://pub.dev/packages/permission_handler)

---

## Projeto

**SENAI CheckIn**

Projeto acadêmico desenvolvido para o módulo de **Programação para Dispositivos Móveis — SENAI**.
