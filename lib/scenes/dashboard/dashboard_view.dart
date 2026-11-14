import 'package:flutter/material.dart';
import '../../design_system/components/cd_kpi_card.dart';
import '../../design_system/theme/app_colors.dart';
import '../../design_system/theme/app_typography.dart';
import 'dashboard_viewmodel.dart';

class DashboardView extends StatelessWidget {
  final DashboardViewModel viewModel;
  const DashboardView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final vm = viewModel;
    final total = vm.totalIssued == 0 ? 1 : vm.totalIssued;

    return Container(
      width: 960,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('DASHBOARD ADMINISTRATIVO • APOIO À DECISÃO',
              style: AppTypography.labelGold),
          const SizedBox(height: 4),
          const Text('Capim Dourado Experience Intelligence',
              style: AppTypography.h2),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              CdKpiCard(
                sourceTitle: 'FONTE 1: CLIENTES CADASTRADOS',
                mainValue: '${vm.totalStoreClients} clientes',
                subtitle: 'Dados autorizados (LGPD)',
              ),
              CdKpiCard(
                sourceTitle: 'FONTE 2: TOTEM DE FEEDBACK',
                mainValue: '${vm.totalIssued} cupons emitidos',
                subtitle: 'Participação voluntária',
              ),
              CdKpiCard(
                sourceTitle: 'TAXA DE RESGATE DE CUPONS',
                mainValue:
                    '${vm.redemptionRatePercent}% (${vm.totalRedeemed}/${vm.totalIssued})',
                subtitle: 'Interesse convertido em visita',
              ),
              const CdKpiCard(
                sourceTitle: 'FONTE 3: GOOGLE PERFIL',
                mainValue: '4.6 ★ (88% Positivo)',
                subtitle: 'Avaliações e percepções',
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'INTERESSE DECLARADO (TOTEM) vs. RESGATE REAL NAS LOJAS POR CATEGORIA',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          ...vm.categories.map((cat) {
            final declared =
                vm.feedbacks.where((f) => f.interestCategory == cat).length;
            final redeemed = vm.feedbacks
                .where((f) => f.interestCategory == cat && f.isRedeemed)
                .length;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.lightCream,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$cat (Base Lojas: ${vm.storeClients[cat] ?? 0})',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Text(
                          'Interesse: $declared  |  Resgates Reais: $redeemed',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: declared / total,
                            color: AppColors.gold,
                            backgroundColor: Colors.grey.shade300,
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: redeemed / total,
                            color: AppColors.success,
                            backgroundColor: Colors.grey.shade300,
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              Container(
                width: 285,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('DESEMPENHO POR LOJA',
                        style: AppTypography.labelGold),
                    const SizedBox(height: 8),
                    ...vm.redemptionsByStore.entries.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  child: Text(e.key,
                                      style: const TextStyle(fontSize: 12))),
                              Text('${e.value} resgates',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
              Container(
                width: 295,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('FONTE 3 • PERCEPÇÃO GOOGLE',
                        style: AppTypography.labelGold),
                    const SizedBox(height: 8),
                    ...vm.googlePerceptions.map((g) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            '• ${g['tema']} (${g['sentimento']}): ${g['detalhe']}',
                            style: const TextStyle(fontSize: 11),
                          ),
                        )),
                  ],
                ),
              ),
              Container(
                width: 290,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('FONTE 4 • TENDÊNCIAS EXTERNAS',
                        style: AppTypography.labelGold),
                    const SizedBox(height: 8),
                    ...vm.publicTrends.map((t) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            '• ${t['categoria']} (${t['tendencia']}): ${t['oportunidade']}',
                            style: const TextStyle(fontSize: 11),
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}