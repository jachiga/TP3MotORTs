import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/custom_button.dart';

class LoginView extends StatefulWidget {
const LoginView({super.key});

@override
State createState() => _LoginViewState();
}

class _LoginViewState extends State {
final _formKey = GlobalKey<FormState>();
final _emailController = TextEditingController();
final _passwordController = TextEditingController();
final AuthService _authService = AuthService();

bool _isLoading = false;
bool _obscurePassword = true;

@override
void dispose() {
_emailController.dispose();
_passwordController.dispose();
super.dispose();
}

Future _handleLogin() async {
if (!_formKey.currentState!.validate()) return;

setState(() => _isLoading = true);

try {
  await _authService.signInWithEmailAndPassword(
    email: _emailController.text,
    password: _passwordController.text,
  );
} on AuthException catch (e) {
  if (!mounted) return;
  _showErrorSnackBar(e.message);
} finally {
  if (mounted) {
    setState(() => _isLoading = false);
  }
}


}

void _showErrorSnackBar(String message) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(message),
backgroundColor: Colors.redAccent,
behavior: SnackBarBehavior.floating,
),
);
}

@override
Widget build(BuildContext context) {
const bgColor = Color(0xFF0B111A);
const cardInputColor = Color(0xFF131D2A);
const textMuted = Color(0xFF8B9CB0);
const brandTeal = Color(0xFF00D2A0);

return Scaffold(
  backgroundColor: bgColor,
  body: SafeArea(
    child: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- BRAND HEADER ---
              Row(
                children: [
                  const Icon(
                    Icons.directions_car_filled_rounded,
                    color: brandTeal,
                    size: 32,
                  ),
                  const SizedBox(width: 8),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                      children: [
                        TextSpan(
                          text: 'mot',
                          style: TextStyle(color: Colors.white),
                        ),
                        TextSpan(
                          text: 'ORTS',
                          style: TextStyle(color: brandTeal),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'El mercado de usados más confiable de Argentina',
                style: TextStyle(
                  color: textMuted,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 36),

              // --- CAMPO EMAIL ---
              const Text(
                'EMAIL O USUARIO',
                style: TextStyle(
                  color: textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'ejemplo@email.com',
                  hintStyle: const TextStyle(color: Color(0xFF4A5B70)),
                  filled: true,
                  fillColor: cardInputColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF1E2C3D)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: brandTeal, width: 1.5),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresá tu email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value.trim())) {
                    return 'Ingresá un email válido';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // --- CAMPO CONTRASEÑA ---
              const Text(
                'CONTRASEÑA',
                style: TextStyle(
                  color: textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                style: const TextStyle(color: Colors.white),
                onFieldSubmitted: (_) => _handleLogin(),
                decoration: InputDecoration(
                  hintText: '••••••••',
                  hintStyle: const TextStyle(color: Color(0xFF4A5B70)),
                  filled: true,
                  fillColor: cardInputColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF1E2C3D)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: brandTeal, width: 1.5),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: textMuted,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresá tu contraseña';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 28),

              // --- BOTÓN PRINCIPAL LOGIN ---
              CustomButton(
                text: 'Iniciar sesión',
                isLoading: _isLoading,
                onPressed: _handleLogin,
              ),

              const SizedBox(height: 28),

              // --- DIVISOR "O CONTINUAR CON" ---
              Row(
                children: [
                  const Expanded(
                    child: Divider(color: Color(0xFF1E2C3D), thickness: 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'o continuar con',
                      style: TextStyle(
                        color: textMuted.withOpacity(0.8),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Divider(color: Color(0xFF1E2C3D), thickness: 1),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // --- BOTÓN GOOGLE ---
              CustomButton(
                text: 'Continuar con Google',
                isSecondary: true,
                icon: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: textMuted, width: 1.5),
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Inicio con Google en desarrollo'),
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),

              // --- FOOTER REGISTRO ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '¿No tienes una cuenta? ',
                    style: TextStyle(color: textMuted, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO: Navegar al Registro
                    },
                    child: const Text(
                      'Regístrate',
                      style: TextStyle(
                        color: brandTeal,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  ),
);


}
}