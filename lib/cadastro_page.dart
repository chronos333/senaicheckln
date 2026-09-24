import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'hardware_service.dart';
import 'registro_dbhelper.dart';
import 'registro_model.dart';
import 'registro_page.dart';

class CadastroPage extends StatefulWidget {
  final XFile? fotoRecuperada;
  const CadastroPage({super.key, this.fotoRecuperada});
  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _form = GlobalKey<FormState>();
  final _observacao = TextEditingController();
  final _hardware = HardwareService();
  final _audio = AudioPlayer();
  XFile? _foto;
  Position? _posicao;
  DateTime? _localizadoEm;
  bool _ocupado = false;
  String _etapa = '';

  @override
  void initState() {
    super.initState();
    _foto = widget.fotoRecuperada;
  }

  @override
  void dispose() {
    _observacao.dispose();
    _audio.dispose();
    super.dispose();
  }

  Future<void> _executar(String etapa, Future<void> Function() acao) async {
    setState(() {
      _ocupado = true;
      _etapa = etapa;
    });
    try {
      await acao();
    } on RecursoException catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(erro.mensagem),
          action: erro.abrirConfiguracoes
              ? SnackBarAction(
                  label: 'Configurações',
                  onPressed: openAppSettings,
                )
              : erro.ativarGps
              ? SnackBarAction(
                  label: 'Ativar GPS',
                  onPressed: Geolocator.openLocationSettings,
                )
              : null,
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Não foi possível concluir a operação. Verifique o recurso e tente novamente.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _fotografar() => _executar('Abrindo câmera...', () async {
    final foto = await _hardware.fotografar();
    if (mounted && foto != null) setState(() => _foto = foto);
  });

  Future<void> _localizar() => _executar('Obtendo localização...', () async {
    final posicao = await _hardware.localizar();
    if (mounted) {
      setState(() {
        _posicao = posicao;
        _localizadoEm = DateTime.now();
      });
    }
  });

  Future<void> _salvar() async {
    if (!_form.currentState!.validate()) return;
    if (_foto == null || _posicao == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Capture uma foto e obtenha a localização antes de salvar.',
          ),
        ),
      );
      return;
    }
    await _executar('Salvando registro...', () async {
      // Evita associar um ponto novo a coordenadas antigas.
      if (DateTime.now().difference(_localizadoEm!) >
          const Duration(minutes: 2)) {
        final atual = await _hardware.localizar();
        if (!mounted) return;
        setState(() {
          _posicao = atual;
          _localizadoEm = DateTime.now();
        });
      }
      final agora = DateTime.now();
      final pasta = Directory(
        p.join((await getApplicationDocumentsDirectory()).path, 'imagens'),
      );
      await pasta.create(recursive: true);
      final destino = File(
        p.join(
          pasta.path,
          'registro_${agora.microsecondsSinceEpoch}${p.extension(_foto!.path)}',
        ),
      );
      try {
        await _foto!.saveTo(destino.path);
        await RegistroDbhelper.instance.inserir(
          Registro(
            dataHora: agora,
            latitude: _posicao!.latitude,
            longitude: _posicao!.longitude,
            precisao: _posicao!.accuracy,
            observacao: _observacao.text.trim(),
            caminhoDaFoto: destino.path,
          ),
        );
      } catch (_) {
        // Não deixa uma cópia órfã quando a gravação no banco falha.
        try {
          if (await destino.exists()) await destino.delete();
        } catch (_) {
          /* Preserva o erro original. */
        }
        rethrow;
      }
      // Falha de áudio não transforma um registro salvo em erro nem duplica o ponto.
      try {
        await _audio.play(AssetSource('sounds/confirmacao.wav'));
        await Future<void>.delayed(const Duration(milliseconds: 450));
      } catch (_) {
        /* A confirmação visual continua disponível. */
      }
      if (mounted) Navigator.of(context).pop(true);
    });
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_ocupado,
    child: Scaffold(
      appBar: AppBar(title: const Text('Novo registro')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _form,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text(
                    'Registre sua visita',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'A foto e a localização são obrigatórias. Os dados ficam salvos neste dispositivo.',
                  ),
                  if (widget.fotoRecuperada != null)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        'Foto recuperada após reinício. Obtenha o GPS e complete o registro.',
                      ),
                    ),
                  const SizedBox(height: 20),
                  if (_foto != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: fotoRegistro(_foto!.path),
                    ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _ocupado ? null : _fotografar,
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: Text(
                      _foto == null ? 'Capturar foto' : 'Tirar outra foto',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Localização GPS',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _posicao == null
                                ? 'Localização ainda não obtida.'
                                : 'Latitude: ${_posicao!.latitude.toStringAsFixed(6)}\nLongitude: ${_posicao!.longitude.toStringAsFixed(6)}\nPrecisão: ${_posicao!.accuracy.toStringAsFixed(1)} m',
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: _ocupado ? null : _localizar,
                            icon: const Icon(Icons.my_location),
                            label: Text(
                              _posicao == null
                                  ? 'Obter localização'
                                  : 'Atualizar localização',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _observacao,
                    enabled: !_ocupado,
                    maxLines: 4,
                    maxLength: 500,
                    decoration: const InputDecoration(
                      labelText: 'Observação (opcional)',
                      hintText: 'Descreva a visita ou atividade realizada',
                    ),
                    validator: (texto) => (texto?.trim().length ?? 0) > 500
                        ? 'Use até 500 caracteres.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _ocupado ? null : _salvar,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Salvar registro'),
                  ),
                  if (_ocupado)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const LinearProgressIndicator(),
                          const SizedBox(height: 8),
                          Text(_etapa),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
