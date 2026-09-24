import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class RecursoException implements Exception {
  final String mensagem;
  final bool abrirConfiguracoes, ativarGps;
  const RecursoException(
    this.mensagem, {
    this.abrirConfiguracoes = false,
    this.ativarGps = false,
  });
}

class HardwareService {
  final picker = ImagePicker();
  Future<void> _permitir(Permission permissao, String recurso) async {
    final status = await permissao.request();
    if (!status.isGranted) {
      throw RecursoException(
        'Permita o acesso à $recurso para continuar.',
        abrirConfiguracoes: status.isPermanentlyDenied || status.isRestricted,
      );
    }
  }

  Future<XFile?> fotografar() async {
    await _permitir(Permission.camera, 'câmera');
    return picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1600,
      imageQuality: 85,
    );
  }

  Future<Position> localizar() async {
    await _permitir(Permission.locationWhenInUse, 'localização');
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const RecursoException(
        'Ative o GPS e tente novamente.',
        ativarGps: true,
      );
    }
    try {
      final posicao = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 25),
        ),
      );
      if (!posicao.accuracy.isFinite || posicao.accuracy > 100) {
        throw const RecursoException(
          'GPS com baixa precisão. Vá para um local aberto e tente novamente (limite: 100 m).',
        );
      }
      return posicao;
    } on TimeoutException {
      throw const RecursoException(
        'O GPS demorou para responder. Vá para um local aberto e tente novamente.',
      );
    }
  }
}
