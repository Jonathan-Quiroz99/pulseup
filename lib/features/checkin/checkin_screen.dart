import 'package:flutter/material.dart';

import '../auth/user_session.dart';

import 'widgets/last_checkin_tile.dart';
import 'widgets/membership_status_card.dart';
import 'widgets/qr_card.dart';

class CheckinScreen extends StatelessWidget {
  const CheckinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TEMPORAL
    // luego esto vendrá del backend
    final memberId =
        UserSession.memberId ?? "MEM001";

    final memberName =
        UserSession.displayName ??
        "Usuario";

    return Scaffold(
      backgroundColor:
          const Color(0xFF0F172A),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFF0F172A),

        elevation: 0,

        title: const Text(
          "Mi Check-In",
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [
              const SizedBox(height: 12),

              Text(
                memberName,

                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "Muestra este código al entrar",

                style: const TextStyle(
                  color: Colors.white60,
                ),
              ),

              const SizedBox(height: 28),

              QRCard(
                qrData: memberId,
              ),

              const SizedBox(height: 24),

              const MembershipStatusCard(
                membership:
                    "Membresía Premium",

                status: "Activa",
              ),

              const SizedBox(height: 16),

              const LastCheckinTile(
                date: "20 Mayo 2026",
                time: "7:42 PM",
              ),


              SizedBox(
                width: double.infinity,

                child: ElevatedButton.icon(
                  onPressed: () {},

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(
                      0xFF00FF88,
                    ),

                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                  ),

                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.black,
                  ),

                  label: const Text(
                    "Actualizar QR",

                    style: TextStyle(
                      color: Colors.black,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}