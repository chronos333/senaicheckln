import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'registro_model.dart';
import 'registro_page.dart';

class DetalhesPage extends StatelessWidget {
  final Registro registro;
  const DetalhesPage({super.key, required this.registro});

  Future<void> _mapa(BuildContext context) async {
    try {
      final uri = Uri.https('www.google.com', '/maps/search/', {
        'api': '1',
        'query': '${registro.latitude},${registro.longitude}',
      });
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw StateError('Mapa indisponível');
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Não foi possível abrir o mapa. Verifique se há um navegador instalado.',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Registro #${registro.id}')),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: fotoRegistro(registro.caminhoDaFoto, altura: 300),
              ),
              const SizedBox(height: 20),
              Text(
                registro.dataFormatada,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Localização',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      SelectableText(registro.coordenadas),
                      const SizedBox(height: 4),
                      Text(
                        'Precisão do GPS: ${registro.precisao.toStringAsFixed(1)} m',
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => _mapa(context),
                        icon: const Icon(Icons.map_outlined),
                        label: const Text('Ver no mapa'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Observação',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        registro.observacao.isEmpty
                            ? 'Nenhuma observação informada.'
                            : registro.observacao,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
