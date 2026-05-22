import 'package:flutter/material.dart';

import '../auth/user_session.dart';

import 'models/checkin_record.dart';

import 'services/checkin_service.dart';

import 'widgets/qr_card.dart';
import 'widgets/membership_status_card.dart';
import 'widgets/latest_checkin_card.dart';
import 'widgets/checkin_history_tile.dart';
import 'widgets/checkin_empty_state.dart';

class CheckinScreen extends StatefulWidget {
  const CheckinScreen({super.key});

  @override
  State<CheckinScreen> createState() =>
      _CheckinScreenState();
}

class _CheckinScreenState
    extends State<CheckinScreen> {
  bool loading = false;

  List<CheckinRecord> checkins = [];

  @override
  void initState() {
    super.initState();

    loadCheckins();
  }

  Future<void> loadCheckins() async {
    try {
      setState(() {
        loading = true;
      });

      final token = UserSession.token;

      if (token == null) return;

      final data =
          await CheckinService()
              .fetchMyCheckins(token);

      if (!mounted) return;

      setState(() {
        checkins = data;
      });
    } catch (e) {
      print(e);
    }

    if (!mounted) return;

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final memberId =
        UserSession.memberId ??
            "MEM001";

    final memberName =
        UserSession.fullName;

    final membership =
        UserSession.membership ??
            "Premium";

    final membershipStatus =
        UserSession.membershipStatus ??
            "Activa";

    final latestCheckin =
        checkins.isNotEmpty
            ? checkins.first
            : null;

    return Scaffold(
      backgroundColor:
          const Color(0xFF0F172A),

      body: loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : SafeArea(
              child:
                  SingleChildScrollView(
                padding:
                    const EdgeInsets.all(
                  20,
                ),

                child: Column(
                  children: [
                    const SizedBox(
                      height: 12,
                    ),

                    Align(
                      alignment:
                          Alignment.centerLeft,

                      child: Text(
                        "Mi Check-In",

                        style:
                            const TextStyle(
                          color:
                              Colors.white,

                          fontSize: 38,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 40,
                    ),

                    Text(
                      memberName,

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    const Text(
                      "Muestra este código al entrar",

                      style: TextStyle(
                        color:
                            Colors.white54,

                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(
                      height: 30,
                    ),

                    QRCard(
                      qrData:
                          "PULSEUP:$memberId",
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    MembershipStatusCard(
                      membership:
                          "Membresía $membership",

                      status:
                          membershipStatus,
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    if (latestCheckin !=
                        null)
                      LatestCheckinCard(
                        checkin:
                            latestCheckin,
                      ),

                    const SizedBox(
                      height: 30,
                    ),

                    Align(
                      alignment:
                          Alignment.centerLeft,

                      child: Text(
                        "Historial reciente",

                        style:
                            const TextStyle(
                          color:
                              Colors.white,

                          fontSize: 22,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    if (checkins.isEmpty)
                      const CheckinEmptyState(),

                    ...checkins.map(
                      (checkin) {
                        return CheckinHistoryTile(
                          checkin: checkin,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}