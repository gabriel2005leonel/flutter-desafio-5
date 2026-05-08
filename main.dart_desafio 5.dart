import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() {
  runApp(const Sistema());
}

class Sistema extends StatelessWidget {
  const Sistema({super.key});

  @override
  Widget build(BuildContext context) {

    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TelaPrincipal(),
    );
  }
}

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() =>
      _TelaPrincipalState();
}

class _TelaPrincipalState
    extends State<TelaPrincipal> {

  double eixoX = 0;
  double eixoY = 0;
  double eixoZ = 0;

  double posicaoMouseX = 0;
  double posicaoMouseY = 0;

  bool detectado = false;

  bool bloquearMensagem = false;

  StreamSubscription? acelerometro;

  @override
  void initState() {
    super.initState();

    if (!kIsWeb) {

      acelerometro =
          accelerometerEventStream().listen(
        (valor) {

          salvarValores(
            valor.x,
            valor.y,
            valor.z,
          );
        },
      );
    }
  }

  void salvarValores(
    double valorX,
    double valorY,
    double valorZ,
  ) {

    bool movimento =
        valorX.abs() > 8;

    setState(() {
      eixoX = valorX;
      eixoY = valorY;
      eixoZ = valorZ;
      detectado = movimento;
    });

    if (movimento) {
      mostrarNotificacao();
    }
  }

  void mostrarNotificacao() {

    if (bloquearMensagem) {
      return;
    }

    bloquearMensagem = true;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Movimento Detectado',
        ),
      ),
    );

    Future.delayed(
      const Duration(seconds: 2),
      () {
        bloquearMensagem = false;
      },
    );
  }

  void detectarMouse(
    PointerEvent evento,
  ) {

    double valorX =
        evento.position.dx -
            posicaoMouseX;

    double valorY =
        evento.position.dy -
            posicaoMouseY;

    salvarValores(
      valorX,
      valorY,
      0,
    );

    posicaoMouseX =
        evento.position.dx;

    posicaoMouseY =
        evento.position.dy;
  }

  @override
  void dispose() {
    acelerometro?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return MouseRegion(
      onHover:
          kIsWeb ? detectarMouse : null,

      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Detector de Movimento',
          ),
        ),

        body: Center(
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [

              Text(
                'X: ${eixoX.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                ),
              ),

              Text(
                'Y: ${eixoY.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                ),
              ),

              Text(
                'Z: ${eixoZ.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              detectado
                  ? const Text(
                      'MOVIMENTO DETECTADO',
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.red,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}