import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

import '../auth/user_session.dart';

import 'models/checkin_record.dart';

import 'services/checkin_service.dart';

import 'widgets/checkin_empty_state.dart';
import 'widgets/checkin_history_tile.dart';
import 'widgets/latest_checkin_card.dart';
import 'widgets/membership_status_card.dart';
import 'widgets/qr_card.dart';

class CheckinScreen
    extends StatefulWidget {

  const CheckinScreen({
    super.key,
  });

  @override
  State<CheckinScreen>
      createState() =>
          _CheckinScreenState();
}

class _CheckinScreenState
    extends State<CheckinScreen> {

  final CheckinService
      _checkinService =
          CheckinService();

  bool _loading = false;

  List<CheckinRecord>
      _checkins = [];

  @override
  void initState() {

    super.initState();

    _loadCheckins();
  }

  Future<void>
      _loadCheckins() async {

    try {

      setState(() {
        _loading = true;
      });

      final token =
          UserSession.token;

      if (token == null) return;

      final data =
          await _checkinService
              .fetchMyCheckins(
        token,
      );

      if (!mounted) return;

      setState(() {
        _checkins = data;
      });

    } catch (e) {

      debugPrint(
        'Checkin Error: $e',
      );

    } finally {

      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    final theme =
        Theme.of(context);

    final textTheme =
        theme.textTheme;

    final memberId =
        UserSession.memberId ??
            'MEM001';

    final memberName =
        UserSession.fullName;

    final membership =
        UserSession.membership ??
            'Premium';

    final membershipStatus =
        UserSession
                .membershipStatus ??
            'Activa';

    final latestCheckin =
        _checkins.isNotEmpty
            ? _checkins.first
            : null;

    if (_loading) {

      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }

    return SafeArea(

      child: SingleChildScrollView(

        padding: const EdgeInsets.all(
          AppSpacing.lg,
        ),

        child: Column(

          children: [

            const SizedBox(
              height: AppSpacing.xs,
            ),

            Align(

              alignment:
                  Alignment.centerLeft,

              child: Text(
                'Mi Check-In',
                style:
                    textTheme.headlineMedium,
              ),
            ),

            const SizedBox(
              height: AppSpacing.xl,
            ),

            Text(
              memberName,
              style:
                  textTheme.headlineSmall,
            ),

            const SizedBox(
              height: AppSpacing.xs,
            ),

            Text(
              'Muestra este código al entrar',
              style:
                  textTheme.bodyLarge,
            ),

            const SizedBox(
              height: AppSpacing.xl,
            ),

            QRCard(
              qrData: memberId,
            ),

            const SizedBox(
              height: AppSpacing.lg,
            ),

            MembershipStatusCard(
              membership:
                  'Membresía $membership',

              status:
                  membershipStatus,
            ),

            const SizedBox(
              height: AppSpacing.md,
            ),

            if (latestCheckin != null)
              LatestCheckinCard(
                checkin:
                    latestCheckin,
              ),

            const SizedBox(
              height: AppSpacing.xl,
            ),

            Align(

              alignment:
                  Alignment.centerLeft,

              child: Text(
                'Historial reciente',
                style:
                    textTheme.titleLarge,
              ),
            ),

            const SizedBox(
              height: AppSpacing.md,
            ),

            if (_checkins.isEmpty)
              const CheckinEmptyState(),

            ..._checkins.map(

              (checkin) {

                return Padding(

                  padding:
                      const EdgeInsets.only(
                    bottom:
                        AppSpacing.sm,
                  ),

                  child:
                      CheckinHistoryTile(
                    checkin: checkin,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}