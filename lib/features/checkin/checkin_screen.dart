import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../services/api_service.dart';
import '../../widgets/ui/app_scaffold.dart';
import '../../widgets/ui/empty_state.dart';
import '../../widgets/ui/section_header.dart';

import '../auth/user_session.dart';

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

  @override
  void initState() {
    super.initState();
    _loadCheckins();
  }

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
              QRCard(
                qrData: memberId,
                memberName: memberName,
                memberId: memberId,
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
            const SectionHeader(title: 'Historial reciente'),
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
