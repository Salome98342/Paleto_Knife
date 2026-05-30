import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controllers/chef_controller.dart';
import '../controllers/economy_controller.dart';
import '../controllers/game_controller.dart';
import '../services/firebase_auth_service.dart';
import '../ui/theme/paleto_colors.dart';
import 'login_screen.dart';
import 'profile_edit_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<FirebaseAuthService>(
      builder: (context, authService, _) {
        final user = authService.currentUser;
        if (user == null) return _buildNotLoggedIn();

        return Consumer3<GameController, ChefController, EconomyController>(
          builder: (context, gameController, chefController, ecoController, _) {
            return Scaffold(
              backgroundColor: PaletoColors.bgDeep,
              appBar: _buildAppBar(),
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildProfileHeader(user),
                    const SizedBox(height: 24),
                    _buildProfileInfoSection(user),
                    const SizedBox(height: 24),
                    _buildChefSection(chefController, gameController),
                    const SizedBox(height: 24),
                    _buildGameStatsSection(gameController, chefController),
                    const SizedBox(height: 24),
                    _buildResetSection(gameController),
                    const SizedBox(height: 24),
                    _buildResourcesSection(gameController, ecoController),
                    const SizedBox(height: 24),
                    _buildActionsSection(authService, gameController),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: PaletoColors.btnNeutral,
      elevation: 0,
      title: Text(
        'MI PERFIL',
        style: GoogleFonts.pressStart2p(
          fontSize: 14,
          color: PaletoColors.textPrimary,
          letterSpacing: 2,
        ),
      ),
      centerTitle: true,
      iconTheme: const IconThemeData(color: PaletoColors.textPrimary),
    );
  }

  Widget _buildProfileHeader(UserModel user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: PaletoColors.borderDark, width: 3),
          color: PaletoColors.btnNeutral,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              offset: const Offset(3, 3),
              blurRadius: 0,
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: PaletoColors.borderDark, width: 3),
                color: PaletoColors.btnNeutralLt,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(2, 2),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                  ? Image.network(
                      user.avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildDefaultAvatar(),
                    )
                  : _buildDefaultAvatar(),
            ),
            const SizedBox(height: 16),
            Text(
              user.username,
              textAlign: TextAlign.center,
              style: GoogleFonts.pressStart2p(
                fontSize: 16,
                color: PaletoColors.textPrimary,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user.email,
              textAlign: TextAlign.center,
              style: GoogleFonts.robotoMono(
                fontSize: 12,
                color: PaletoColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            if (user.bio != null && user.bio!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: PaletoColors.borderDark, width: 2),
                  color: PaletoColors.bgDeep,
                ),
                child: Text(
                  user.bio!,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.robotoMono(
                    fontSize: 11,
                    color: PaletoColors.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: PaletoColors.borderDark,
      child: Center(
        child: Text('👤', style: GoogleFonts.pressStart2p(fontSize: 50)),
      ),
    );
  }

  Widget _buildProfileInfoSection(UserModel user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'INFORMACIÓN',
            style: GoogleFonts.pressStart2p(
              fontSize: 12,
              color: PaletoColors.textPrimary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('MIEMBRO DESDE', _formatDate(user.createdAt)),
          const SizedBox(height: 8),
          _buildInfoRow('ÚLTIMO ACCESO', _formatDate(user.lastLogin)),
          if (user.favoriteColor != null && user.favoriteColor!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildInfoRow('COLOR FAVORITO', user.favoriteColor!),
          ],
        ],
      ),
    );
  }

  Widget _buildChefSection(
    ChefController chefController,
    GameController gameController,
  ) {
    final chef = chefController.activeChef;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CHEF FAVORITO',
            style: GoogleFonts.pressStart2p(
              fontSize: 12,
              color: PaletoColors.textPrimary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: PaletoColors.borderDark, width: 3),
              color: PaletoColors.btnNeutral,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  offset: const Offset(2, 2),
                  blurRadius: 0,
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(chef.icon, size: 48, color: PaletoColors.textPrimary),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chef.name.toUpperCase(),
                        style: GoogleFonts.pressStart2p(
                          fontSize: 12,
                          color: PaletoColors.textPrimary,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'NIVEL ${gameController.currentLevel}',
                        style: GoogleFonts.robotoMono(
                          fontSize: 10,
                          color: PaletoColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'HP: ${chef.currentHp.toInt()}',
                        style: GoogleFonts.robotoMono(
                          fontSize: 10,
                          color: PaletoColors.rarityCommon,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameStatsSection(
    GameController gameController,
    ChefController chefController,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ESTADÍSTICAS DEL JUEGO',
            style: GoogleFonts.pressStart2p(
              fontSize: 12,
              color: PaletoColors.textPrimary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: PaletoColors.borderDark, width: 2),
              color: PaletoColors.btnNeutral,
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DEL JUGADOR',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 9,
                    color: PaletoColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                _buildStatRow(
                  'Daño Base',
                  gameController.baseDamage.toStringAsFixed(1),
                ),
                _buildStatRow(
                  'Velocidad de Ataque',
                  gameController.attackSpeed.toStringAsFixed(2),
                ),
                _buildStatRow(
                  'Crítico',
                  '${(gameController.critChance * 100).toStringAsFixed(1)}%',
                ),
                _buildStatRow(
                  'Multiplicador de Crítico',
                  '${gameController.critMultiplier.toStringAsFixed(2)}x',
                ),
                _buildStatRow(
                  'Precisión',
                  '${(gameController.accuracy * 100).toStringAsFixed(1)}%',
                ),
                _buildStatRow(
                  'Bonus de Oro',
                  '+${(gameController.goldBonus * 100).toStringAsFixed(1)}%',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: PaletoColors.borderDark, width: 2),
              color: PaletoColors.btnNeutral,
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DEL MINIJUEGO',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 9,
                    color: PaletoColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                _buildStatRow(
                  'Vida Máxima',
                  chefController.activeChef.currentHp.toInt().toString(),
                ),
                _buildStatRow(
                  'Daño Total',
                  chefController.getTotalDamage('').toStringAsFixed(1),
                ),
                _buildStatRow(
                  'Cadencia',
                  '${chefController.activeChef.currentFireRate.toStringAsFixed(2)}s',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetSection(GameController gameController) {
    final resetState = gameController.gameState.resetState;
    final tokensToGain = resetState.calculateTokensForReset(
      gameController.currentLevel,
    );
    final canReset = resetState.canReset(gameController.currentLevel);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'REINICIO (PRESTIGE)',
            style: GoogleFonts.pressStart2p(
              fontSize: 12,
              color: PaletoColors.textPrimary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: PaletoColors.borderDark, width: 2),
              color: PaletoColors.btnNeutral,
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatRow(
                  'Tokens Disponibles',
                  tokensToGain.toStringAsFixed(0),
                ),
                _buildStatRow(
                  'Reinicios Totales',
                  resetState.totalResets.toString(),
                ),
                _buildStatRow(
                  'Nivel Máximo Alcanzado',
                  resetState.highestLevelReached.toString(),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: _buildNESButton(
                    label: canReset
                        ? 'REALIZAR REINICIO'
                        : 'NIVEL INSUFICIENTE (150+)',
                    backgroundColor: canReset
                        ? PaletoColors.btnPrimary
                        : PaletoColors.btnNeutralDk,
                    onPressed: canReset
                        ? () => _showResetDialog(gameController)
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourcesSection(
    GameController gameController,
    EconomyController ecoController,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RECURSOS',
            style: GoogleFonts.pressStart2p(
              fontSize: 12,
              color: PaletoColors.textPrimary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: PaletoColors.borderDark, width: 2),
              color: PaletoColors.btnNeutral,
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatRow('Oro', gameController.gold.toStringAsFixed(0)),
                _buildStatRow('Monedas', ecoController.coins.toString()),
                _buildStatRow('Gemas', ecoController.gems.toString()),
                _buildStatRow(
                  'Fragmentos de Cuchillo',
                  gameController.knifeFragments.toString(),
                ),
                _buildStatRow(
                  'Cofres de Reliquia',
                  gameController.relicChests.toString(),
                ),
                _buildStatRow(
                  'Corazones de Culto',
                  gameController.cultHearts.toString(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection(
    FirebaseAuthService authService,
    GameController gameController,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'OPCIONES',
            style: GoogleFonts.pressStart2p(
              fontSize: 12,
              color: PaletoColors.textPrimary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          _buildActionButton('EDITAR PERFIL', PaletoColors.btnNeutral, () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
            );
          }),
          const SizedBox(height: 8),
          _buildActionButton('GUARDAR JUEGO', PaletoColors.btnPrimary, () {
            gameController.saveGame();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Progreso guardado',
                  style: GoogleFonts.pressStart2p(fontSize: 10),
                ),
                backgroundColor: PaletoColors.rarityCommon,
                duration: const Duration(milliseconds: 800),
              ),
            );
          }),
          const SizedBox(height: 8),
          _buildActionButton(
            'CERRAR SESIÓN',
            PaletoColors.btnSecondary,
            () => _showLogoutConfirmation(authService),
          ),
          const SizedBox(height: 8),
          _buildActionButton(
            'ELIMINAR CUENTA',
            const Color.fromARGB(255, 120, 60, 60),
            () => _showDeleteConfirmation(authService),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: PaletoColors.borderDark, width: 2),
        color: PaletoColors.btnNeutral,
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.pressStart2p(
              fontSize: 9,
              color: PaletoColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.robotoMono(
              fontSize: 10,
              color: PaletoColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.robotoMono(
                fontSize: 9,
                color: PaletoColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.robotoMono(
              fontSize: 10,
              color: PaletoColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    Color color,
    VoidCallback? onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            color: color,
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
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.pressStart2p(
                fontSize: 11,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNESButton({
    required String label,
    required Color backgroundColor,
    VoidCallback? onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
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
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.pressStart2p(
              fontSize: 11,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }

  void _showResetDialog(GameController gameController) {
    final resetState = gameController.gameState.resetState;
    final tokensToGain = resetState.calculateTokensForReset(
      gameController.currentLevel,
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: PaletoColors.bgPanel,
        title: Text(
          'REINICIO (PRESTIGE)',
          style: GoogleFonts.pressStart2p(
            fontSize: 12,
            color: PaletoColors.textPrimary,
          ),
        ),
        content: Text(
          'Al reiniciar obtendrás ${tokensToGain.toStringAsFixed(0)} tokens.\n\nPerderás: Nivel y Oro\n\nConservarás: Técnicas, Sous-chefs, Equipo y Gemas',
          style: GoogleFonts.robotoMono(
            fontSize: 11,
            color: PaletoColors.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'CANCELAR',
              style: GoogleFonts.pressStart2p(fontSize: 10),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              gameController.tryPerformReset();
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '¡Reinicio completado!',
                    style: GoogleFonts.pressStart2p(fontSize: 10),
                  ),
                  backgroundColor: PaletoColors.rarityCommon,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: PaletoColors.btnPrimary,
            ),
            child: Text(
              'REINICIAR',
              style: GoogleFonts.pressStart2p(fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(FirebaseAuthService authService) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: PaletoColors.bgPanel,
        title: Text(
          '¿CERRAR SESIÓN?',
          style: GoogleFonts.pressStart2p(
            fontSize: 12,
            color: PaletoColors.textPrimary,
          ),
        ),
        content: Text(
          'Tu progreso se guardará automáticamente.',
          style: GoogleFonts.robotoMono(
            fontSize: 11,
            color: PaletoColors.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'CANCELAR',
              style: GoogleFonts.pressStart2p(fontSize: 10),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await authService.signOut();
              if (!mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: PaletoColors.btnSecondary,
            ),
            child: Text(
              'CERRAR SESIÓN',
              style: GoogleFonts.pressStart2p(fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(FirebaseAuthService authService) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: PaletoColors.bgPanel,
        title: Text(
          '⚠️ ELIMINAR CUENTA',
          style: GoogleFonts.pressStart2p(fontSize: 12, color: Colors.red),
        ),
        content: Text(
          '¡Esta acción NO se puede deshacer!\n\nSe eliminarán:\n- Tu cuenta\n- Todos tus datos\n- Tu progreso de juego',
          style: GoogleFonts.robotoMono(
            fontSize: 10,
            color: PaletoColors.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'CANCELAR',
              style: GoogleFonts.pressStart2p(fontSize: 10),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await authService.deleteUserAccount();
              if (!mounted) return;
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cuenta eliminada'),
                    backgroundColor: Colors.red,
                  ),
                );
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      authService.errorMessage ?? 'Error al eliminar cuenta',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              'ELIMINAR',
              style: GoogleFonts.pressStart2p(fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotLoggedIn() {
    return Scaffold(
      backgroundColor: PaletoColors.bgDeep,
      appBar: AppBar(
        backgroundColor: PaletoColors.btnNeutral,
        title: Text(
          'MI PERFIL',
          style: GoogleFonts.pressStart2p(
            fontSize: 14,
            color: PaletoColors.textPrimary,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No has iniciado sesión',
              textAlign: TextAlign.center,
              style: GoogleFonts.pressStart2p(
                fontSize: 14,
                color: PaletoColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: PaletoColors.btnPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: Text(
                'INICIAR SESIÓN',
                style: GoogleFonts.pressStart2p(
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }
}
