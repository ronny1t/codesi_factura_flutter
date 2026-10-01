import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _cedulaController = TextEditingController();

  bool _cargando = false;
  bool _ocultarCedula = true;

  @override
  void dispose() {
    _emailController.dispose();
    _cedulaController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _cargando = true;
    });

    try {
      final respuesta = await AuthService.login(
        email: _emailController.text,
        cedula: _cedulaController.text,
      );

      if (!mounted) return;

      final usuarioData = respuesta['usuario'];

      if (usuarioData == null || usuarioData is! Map) {
        throw Exception(
          'El servidor no devolvió la información del usuario.',
        );
      }

      final usuario = Map<String, dynamic>.from(
        usuarioData,
      );

      final nombre = usuario['nombre']?.toString() ?? 'Usuario';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Bienvenido $nombre',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            usuario: usuario,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      String mensaje = e.toString();

      if (mensaje.startsWith('Exception: ')) {
        mensaje = mensaje.substring('Exception: '.length);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 450,
              ),
              child: Card(
                elevation: 6,
                shadowColor: Colors.black12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // LOGO
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.receipt_long_rounded,
                            size: 42,
                            color: Colors.blue.shade700,
                          ),
                        ),

                        const SizedBox(height: 24),

                        const Text(
                          'Sistema de Facturación',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Universidad',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // EMAIL
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'Correo institucional',
                            hintText: 'usuario@universidad.edu.ec',
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          validator: (value) {
                            final email = value?.trim() ?? '';

                            if (email.isEmpty) {
                              return 'Ingrese su correo institucional';
                            }

                            if (!email.contains('@')) {
                              return 'Ingrese un correo válido';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 18),

                        // CÉDULA
                        TextFormField(
                          controller: _cedulaController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          obscureText: _ocultarCedula,
                          maxLength: 10,
                          onFieldSubmitted: (_) {
                            if (!_cargando) {
                              _iniciarSesion();
                            }
                          },
                          decoration: InputDecoration(
                            labelText: 'Cédula',
                            hintText: '0601234567',
                            prefixIcon: const Icon(
                              Icons.badge_outlined,
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _ocultarCedula =
                                      !_ocultarCedula;
                                });
                              },
                              icon: Icon(
                                _ocultarCedula
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            counterText: '',
                          ),
                          validator: (value) {
                            final cedula = value?.trim() ?? '';

                            if (cedula.isEmpty) {
                              return 'Ingrese su cédula';
                            }

                            if (!RegExp(r'^\d{10}$')
                                .hasMatch(cedula)) {
                              return 'La cédula debe tener 10 dígitos';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 28),

                        // BOTÓN LOGIN
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed:
                                _cargando ? null : _iniciarSesion,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.blue.shade700,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  Colors.blue.shade200,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(14),
                              ),
                            ),
                            child: _cargando
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Iniciar sesión',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        Text(
                          'Acceso con credenciales institucionales',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}