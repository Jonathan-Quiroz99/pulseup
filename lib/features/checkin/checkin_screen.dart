import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../services/api_service.dart';
import '../../widgets/ui/app_scaffold.dart';
import '../../widgets/ui/empty_state.dart';
import '../../widgets/ui/section_header.dart';

import '../auth/user_session.dart';
import '../onboarding/section_guide.dart';

import 'models/checkin_record.dart';
import 'services/checkin_service.dart';

import 'widgets/checkin_empty_state.dart';
import 'widgets/checkin_history_tile.dart';
import 'widgets/latest_checkin_card.dart';
import 'widgets/membership_status_card.dart';
import 'widgets/qr_card.dart';

class CheckinScreen extends StatefulWidget {
  const CheckinScreen({super.key});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
  final CheckinService _checkinService = CheckinService();
  final ApiService _apiService = ApiService();

  bool _loading = true;
  List<CheckinRecord> _checkins = [];

  // Mini tutorial de Check-In.
  final _qrKey = GlobalKey();
  final _statusKey = GlobalKey();
  final _historyKey = GlobalKey();
  bool _guideChecked = false;

  @override
  void initState() {
    super.initState();
    SectionGuide.attach(this, () => SectionGuide.show(context, _guideSteps()));
    _loadCheckins();
  }

  @override
  void dispose() {
    SectionGuide.detach(this);
    super.dispose();
  }

  List<GuideStep> _guideSteps() => [
        GuideStep(
          target: _qrKey,
          icon: Icons.qr_code_2_rounded,
          title: 'Tu credencial',
          body: 'Al llegar al gimnasio, muestra este código en recepción. '
              'Sube el brillo de la pantalla si no lo leen a la primera.',
        ),
        GuideStep(
          target: _statusKey,
          icon: Icons.verified_outlined,
          title: 'Estado de tu membresía',
          body: 'Si dice Pendiente o Vencido, recepción no podrá darte '
              'acceso: revisa tu estado de cuenta en el menú.',
        ),
        GuideStep(
          target: _historyKey,
          icon: Icons.history,
          title: 'Tus visitas',
          body: 'Cada vez que entras queda registrado aquí.',
        ),
      ];

  Future<void> _loadCheckins() async {
    final token = UserSession.token;
    if (token == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    if (!_loading) setState(() => _loading = true);

    try {
      _checkins = await _checkinService.fetchMyCheckins(token);
    } catch (e) {
      debugPrint('Checkin: history failed: $e');
    }

    try {
      final profile = await _apiService.getMemberProfile(token);
      await UserSession.mergeProfile(profile);
    } catch (e) {
      debugPrint('Checkin: profile refresh failed: $e');
    }

    if (!mounted) return;
    setState(() => _loading = false);
    if (!_guideChecked) {
      _guideChecked = true;
      SectionGuide.showIfFirstTime(context, 'checkin', _guideSteps);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final memberId = UserSession.memberId;
    final memberName = UserSession.fullName;
    final membership = UserSession.membership;
    final membershipStatus = UserSession.membershipStatus;
    final hasCredential = memberId != null && memberId.isNotEmpty;
    final latest = _checkins.isNotEmpty ? _checkins.first : null;

    return AppScaffold(
      padding: EdgeInsets.zero,
      child: RefreshIndicator(
        onRefresh: _loadCheckins,
        child: ListView(
          scrollCacheExtent: const ScrollCacheExtent.pixels(3000),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenX,
            AppSpacing.md,
            AppSpacing.screenX,
            AppSpacing.navBarClearance,
          ),
          children: [
            Text('Mi credencial', style: AppTextStyles.displayMd),
            const SizedBox(height: AppSpacing.xs),
            Text(
              hasCredential
                  ? 'Muestra este código en recepción'
                  : 'No pudimos cargar tu credencial. Revisa tu conexión.',
              style: AppTextStyles.bodySm,
            ),
            const SizedBox(height: AppSpacing.xl),
            if (hasCredential)
              KeyedSubtree(
                key: _qrKey,
                child: QRCard(
                  qrData: memberId,
                  memberName: memberName,
                  memberId: memberId,
                ),
              )
            else
              EmptyState(
                icon: Icons.qr_code_2_outlined,
                title: 'Sin código de acceso',
                message: 'No se pudo generar tu credencial.',
                actionLabel: 'Reintentar',
                onAction: _loadCheckins,
              ),
            const SizedBox(height: AppSpacing.lg),
            MembershipStatusCard(
              key: _statusKey,
              membership: (membership ?? '').isEmpty
                  ? 'Membresía'
                  : 'Membresía $membership',
              status: membershipStatus ?? '—',
            ),
            if (latest != null) ...[
              const SizedBox(height: AppSpacing.sm),
              LatestCheckinCard(checkin: latest),
            ],
            const SizedBox(height: AppSpacing.xl),
            SectionHeader(key: _historyKey, title: 'Historial reciente'),
            if (_checkins.isEmpty)
              const CheckinEmptyState()
            else
              ..._checkins.map(
                (c) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: CheckinHistoryTile(checkin: c),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
