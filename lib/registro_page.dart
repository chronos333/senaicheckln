import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'cadastro_page.dart';
import 'detalhes_page.dart';
import 'registro_dbhelper.dart';
import 'registro_model.dart';

Widget fotoRegistro(String caminho, {double? largura, double altura = 200}) =>
    Image.file(
      File(caminho),
      width: largura,
      height: altura,
      fit: BoxFit.cover,
      errorBuilder: (_, error, stack) => SizedBox(
        width: largura,
        height: altura,
        child: const Center(
          child: Icon(
            Icons.broken_image_outlined,
            semanticLabel: 'Foto indisponível',
          ),
        ),
      ),
    );

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});
  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  late Future<List<Registro>> _registros;
  bool _abrindo = false;

  @override
  void initState() {
    super.initState();
    _registros = RegistroDbhelper.instance.listar();
    WidgetsBinding.instance.addPostFrameCallback((_) => _recuperarFoto());
  }

  Future<void> _recuperarFoto() async {
    // O Android pode encerrar o app enquanto a câmera está aberta.
    if (!Platform.isAndroid) return;
    setState(() => _abrindo = true);
    try {
      final resposta = await ImagePicker().retrieveLostData();
      if (!mounted) return;
      if (resposta.files?.isNotEmpty ?? false) {
        await _novo(foto: resposta.files!.first);
      } else if (resposta.exception != null) {
        throw resposta.exception!;
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Não foi possível recuperar a foto. Faça uma nova captura.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _abrindo = false);
    }
  }

  Future<void> _atualizar() async {
    final consulta = RegistroDbhelper.instance.listar();
    setState(() => _registros = consulta);
    try {
      await consulta;
    } catch (_) {
      /* O FutureBuilder exibe a falha. */
    }
  }

  Future<void> _novo({XFile? foto}) async {
    setState(() => _abrindo = true);
    final salvo = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => CadastroPage(fotoRecuperada: foto)),
    );
    if (!mounted) return;
    setState(() => _abrindo = false);
    if (salvo == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro salvo com sucesso!')),
      );
      await _atualizar();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('SENAI CheckIn'),
      actions: [
        IconButton(
          onPressed: _atualizar,
          icon: const Icon(Icons.refresh),
          tooltip: 'Atualizar registros',
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _abrindo ? null : () => _novo(),
      icon: const Icon(Icons.add_location_alt_outlined),
      label: const Text('Novo registro'),
    ),
    body: SafeArea(
      child: FutureBuilder<List<Registro>>(
        future: _registros,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Não foi possível carregar os registros.'),
                  TextButton(
                    onPressed: _atualizar,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }
          final registros = snapshot.data ?? [];
          if (registros.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.assignment_outlined, size: 72),
                    SizedBox(height: 16),
                    Text(
                      'Seu diário de campo começa aqui',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Toque em Novo registro para registrar sua visita com foto e localização.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _atualizar,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: registros.length,
              separatorBuilder: (_, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final registro = registros[index];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: fotoRegistro(
                        registro.caminhoDaFoto,
                        largura: 64,
                        altura: 64,
                      ),
                    ),
                    title: Text(registro.dataFormatada),
                    titleTextStyle: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                    subtitle: Text(
                      '${registro.observacao.isEmpty ? "Sem observação" : registro.observacao}\n${registro.coordenadas}',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DetalhesPage(registro: registro),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    ),
  );
}
