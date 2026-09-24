# SENAI CheckIn

Atividade do Módulo 5 de Programação para Dispositivos Móveis: registro de ponto e diário de campo com câmera, GPS e SQLite.

## Executar

Projeto Android (Android 7/API 24 ou superior), com Flutter 3.44/Dart 3.12 ou superior, conforme o SDK configurado no projeto.

```sh
flutter pub get
flutter run
```

Selecione um dispositivo Android ou emulador com câmera e localização configuradas. Este projeto contém somente a plataforma Android.

## Fluxo de uso

1. Toque em **Novo registro**.
2. Capture uma foto com a câmera e autorize o acesso quando solicitado.
3. Obtenha a localização e permita o acesso ao GPS. A precisão deve ser de até 100 metros.
4. Preencha uma observação opcional de até 500 caracteres e salve.
5. Confira a mensagem e o som de confirmação, depois abra o registro no histórico para ver os detalhes e o mapa.

O cadastro funciona sem internet. O mapa externo pode precisar de conexão. O som respeita o volume do dispositivo.

## Organização

- `lib/main.dart`: tema e inicialização.
- `lib/registro_model.dart`: dados e conversão para SQLite.
- `lib/registro_dbhelper.dart`: criação do banco, inserção e listagem.
- `lib/hardware_service.dart`: permissões, câmera e GPS.
- `lib/registro_page.dart`: histórico e recuperação de foto interrompida pelo Android.
- `lib/cadastro_page.dart`: formulário, cópia permanente da foto e salvamento.
- `lib/detalhes_page.dart`: foto, observação, coordenadas e mapa.
- `assets/sounds/confirmacao.wav`: som de confirmação gerado para o projeto.

Estrutura baseada nos exemplos locais de geolocator e notas com SQLite, usando widgets Stateful/Stateless e navegação com MaterialPageRoute.

## Dados e tratamento de falhas

Tabela `registros`: `id`, `data_hora` (UTC), `latitude`, `longitude`, `precisao`, `observacao` e `caminho_da_foto`. Datas são exibidas no horário local.

As fotos são copiadas do cache da câmera para a pasta privada `imagens` do aplicativo antes da inserção no banco. Uma falha de inserção remove a cópia recém-criada. Os registros persistem ao fechar o app; limpar os dados ou desinstalar o aplicativo remove o armazenamento local.

Permissões negadas mostram orientação; bloqueio permanente oferece acesso às configurações. GPS desligado oferece acesso à configuração de localização. A leitura tem limite de 25 segundos e permite nova tentativa. Não são usadas coordenadas fictícias ou uma última posição desconhecida como substituição. Coordenadas obtidas há mais de dois minutos são atualizadas ao salvar.

O Android pode encerrar o processo durante a câmera: `retrieveLostData` recupera a foto no início e abre um novo formulário para obter GPS e observação novamente. O botão salvar fica bloqueado durante operações, evitando toques duplicados. Falha de áudio não desfaz um registro já salvo.

## Validação

```sh
flutter analyze
flutter test
flutter build apk --debug
```

Os testes automatizados verificam a conversão dos campos do registro, preservação do instante, coordenadas e omissão do id em novos registros para permitir sua geração pelo banco. Eles não substituem a prova de uso dos plugins no Android.

Validação executada: `flutter analyze` sem problemas, `flutter test` com 2 testes aprovados e `flutter build apk --debug` concluído. APK disponível em `build/app/outputs/flutter-apk/app-debug.apk`. Nenhum dispositivo Android estava conectado para a prova de uso dos sensores.

### Roteiro manual para apresentação (pendente de execução em dispositivo)

- [ ] Autorizar câmera e GPS; capturar foto, obter coordenadas, salvar e ouvir o som.
- [ ] Fechar e reabrir o aplicativo; conferir histórico, foto e dados persistidos.
- [ ] Negar permissões e depois bloquear permanentemente; conferir mensagens e configurações.
- [ ] Desligar o GPS; ativá-lo pela orientação do aplicativo e tentar novamente.
- [ ] Testar localização aproximada/imprecisa e tempo limite; repetir em local aberto.
- [ ] Cancelar a câmera; confirmar que nenhum registro incompleto foi salvo.
- [ ] Tocar em salvar sem foto ou GPS; conferir a validação.
- [ ] Abrir detalhes e o mapa; conferir se as coordenadas correspondem ao local.
- [ ] Salvar dois registros distintos e conferir ordem do mais recente para o mais antigo.
- [ ] Testar sem internet e com fonte ampliada no Android.

Na apresentação, explique o caminho **permissões → câmera/GPS → arquivo e SQLite → confirmação → histórico**. Destaque a diferença entre o cache temporário da câmera e a cópia permanente, além dos tratamentos de permissão negada e GPS indisponível.

## Documentação consultada

- [image_picker 1.2.3](https://pub.dev/packages/image_picker): biblioteca mostrada no enunciado, captura e recuperação de imagens.
- [geolocator](https://pub.dev/packages/geolocator): leitura de localização.
- [permission_handler](https://pub.dev/packages/permission_handler): permissões em tempo de execução.
