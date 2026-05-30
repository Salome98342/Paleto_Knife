import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../services/firebase_auth_service.dart';
import '../ui/theme/paleto_colors.dart';

/// Pantalla para editar el perfil del usuario
class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  String? _selectedFavoriteColor;
  bool _isLoading = false;
  // _selectedImage not needed; upload is handled directly via service

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<FirebaseAuthService>(
      context,
      listen: false,
    );
    final currentUser = authService.currentUser;

    _usernameController = TextEditingController(
      text: currentUser?.username ?? '',
    );
    _bioController = TextEditingController(text: currentUser?.bio ?? '');
    _selectedFavoriteColor = currentUser?.favoriteColor;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PaletoColors.bgDeep,
      appBar: AppBar(
        backgroundColor: PaletoColors.btnNeutral,
        elevation: 0,
        title: Text(
          'EDITAR PERFIL',
          style: GoogleFonts.pressStart2p(
            fontSize: 14,
            color: PaletoColors.textPrimary,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: PaletoColors.textPrimary),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildSectionTitle('CAMBIAR NOMBRE'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _usernameController,
                hint: 'Tu nombre de usuario',
                maxLength: 20,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('BIOGRAFÍA'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _bioController,
                hint: 'Cuéntanos sobre ti...',
                maxLines: 4,
                maxLength: 200,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('COLOR FAVORITO'),
              const SizedBox(height: 12),
              _buildColorPicker(),
              const SizedBox(height: 24),
              _buildSectionTitle('IMAGEN DE PERFIL'),
              const SizedBox(height: 12),
              _buildImageSection(),
              const SizedBox(height: 32),
              _buildSaveButton(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.pressStart2p(
        fontSize: 11,
        color: PaletoColors.textPrimary,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    int? maxLength,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: PaletoColors.borderDark, width: 2),
        color: PaletoColors.btnNeutral,
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        maxLength: maxLength,
        style: GoogleFonts.robotoMono(
          fontSize: 12,
          color: PaletoColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.robotoMono(
            fontSize: 11,
            color: PaletoColors.textSecondary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(12),
          counterStyle: GoogleFonts.robotoMono(
            fontSize: 10,
            color: PaletoColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildColorPicker() {
    final colors = {
      'Rojo': Colors.red,
      'Azul': Colors.blue,
      'Verde': Colors.green,
      'Amarillo': Colors.yellow,
      'Púrpura': Colors.purple,
      'Rosa': Colors.pink,
      'Naranja': Colors.orange,
      'Cian': Colors.cyan,
    };

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: colors.entries.map((entry) {
        final isSelected = _selectedFavoriteColor == entry.key;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedFavoriteColor = entry.key;
            });
          },
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: entry.value,
              border: Border.all(
                color: isSelected ? Colors.white : PaletoColors.borderDark,
                width: isSelected ? 3 : 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: entry.value.withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? Center(
                    child: Text(
                      '✓',
                      style: GoogleFonts.pressStart2p(
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      entry.key,
                      style: GoogleFonts.pressStart2p(
                        fontSize: 8,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildImageSection() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: PaletoColors.borderDark, width: 2),
        color: PaletoColors.btnNeutral,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: PaletoColors.borderDark, width: 2),
            ),
            child: Consumer<FirebaseAuthService>(
              builder: (context, authService, _) {
                final avatar = authService.currentUser?.avatarUrl;
                if (avatar != null && avatar.isNotEmpty) {
                  return Image.network(
                    avatar,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => Center(
                      child: Text(
                        '📷',
                        style: GoogleFonts.pressStart2p(fontSize: 50),
                      ),
                    ),
                  );
                }
                return Container(
                  color: PaletoColors.bgDeep,
                  child: Center(
                    child: Text(
                      '📷',
                      style: GoogleFonts.pressStart2p(fontSize: 50),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSmallButton('GALERÍA', () async {
                  setState(() => _isLoading = true);
                  final authService = Provider.of<FirebaseAuthService>(
                    context,
                    listen: false,
                  );
                  final success = await authService.pickAndUploadAvatar(
                    source: ImageSource.gallery,
                  );
                  if (!mounted) return;
                  setState(() => _isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Avatar subido'
                            : (authService.errorMessage ??
                                  'Error al subir avatar'),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSmallButton('CÁMARA', () async {
                  setState(() => _isLoading = true);
                  final authService = Provider.of<FirebaseAuthService>(
                    context,
                    listen: false,
                  );
                  final success = await authService.pickAndUploadAvatar(
                    source: ImageSource.camera,
                  );
                  if (!mounted) return;
                  setState(() => _isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Avatar subido'
                            : (authService.errorMessage ??
                                  'Error al subir avatar'),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallButton(String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: PaletoColors.btnNeutral,
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: 0.8),
              width: 2,
            ),
            left: BorderSide(
              color: Colors.white.withValues(alpha: 0.8),
              width: 2,
            ),
            bottom: BorderSide(
              color: Colors.black.withValues(alpha: 0.8),
              width: 2,
            ),
            right: BorderSide(
              color: Colors.black.withValues(alpha: 0.8),
              width: 2,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.pressStart2p(
              fontSize: 9,
              color: PaletoColors.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: _isLoading ? null : _saveProfile,
        child: Container(
          decoration: BoxDecoration(
            color: PaletoColors.btnNeutral,
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.8),
                width: 3,
              ),
              left: BorderSide(
                color: Colors.white.withValues(alpha: 0.8),
                width: 3,
              ),
              bottom: BorderSide(
                color: Colors.black.withValues(alpha: 0.8),
                width: 3,
              ),
              right: BorderSide(
                color: Colors.black.withValues(alpha: 0.8),
                width: 3,
              ),
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(2, 2),
                blurRadius: 0,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: _isLoading
              ? Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        PaletoColors.textPrimary,
                      ),
                      strokeWidth: 3,
                    ),
                  ),
                )
              : Center(
                  child: Text(
                    'GUARDAR CAMBIOS',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 12,
                      color: PaletoColors.textPrimary,
                      letterSpacing: 1,
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (_usernameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El nombre de usuario no puede estar vacío'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authService = Provider.of<FirebaseAuthService>(
      context,
      listen: false,
    );
    final success = await authService.updateUserProfile(
      username: _usernameController.text.trim(),
      bio: _bioController.text.trim(),
      favoriteColor: _selectedFavoriteColor,
    );

    if (mounted) {
      setState(() => _isLoading = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Perfil actualizado'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authService.errorMessage ?? 'Error al guardar'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
