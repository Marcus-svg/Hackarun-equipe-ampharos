import 'package:flutter/material.dart';
import '../../design_system/components/cd_primary_button.dart';
import '../../design_system/theme/app_colors.dart';
import '../../design_system/theme/app_typography.dart';
import 'totem_viewmodel.dart';

class TotemView extends StatefulWidget {
  final TotemViewModel viewModel;
  const TotemView({super.key, required this.viewModel});

  @override
  State<TotemView> createState() => _TotemViewState();
}

class _TotemViewState extends State<TotemView> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final vm = widget.viewModel;
        // Em telas estreitas (celular) o cartão de 430px estourava; agora ele
        // encolhe para caber na largura disponível e reduz o padding.
        final screenWidth = MediaQuery.sizeOf(context).width;
        final isCompact = screenWidth < 520;
        final cardWidth = screenWidth < 470 ? screenWidth - 40 : 430.0;
        return Container(
          width: cardWidth,
          constraints: const BoxConstraints(minHeight: 720),
          padding: EdgeInsets.all(isCompact ? 20 : 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 24)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: const [
                      Text('CAPIM DOURADO SHOPPING',
                          style: AppTypography.labelGold),
                      Text('Dados Seguros e Anônimos',
                          style: TextStyle(
                              fontSize: 10, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (vm.step == 0) _buildStep0Home(vm),
                  if (vm.step == 1) _buildStep1Interests(vm),
                  if (vm.step == 2) _buildStep2Events(vm),
                  if (vm.step == 3) _buildStep3Satisfaction(vm),
                  if (vm.step == 4) _buildStep4Coupon(vm),
                ],
              ),
              const SizedBox(height: 24),
              _buildFooter(vm),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStep0Home(TotemViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quais experiências\nvocê quer viver no\nCapim Dourado?',
          style: AppTypography.h1,
        ),
        const SizedBox(height: 12),
        const Text(
          'Responda a 3 perguntas rápidas e garanta o seu benefício exclusivo.',
          style: AppTypography.body,
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.gold, width: 1.2),
          ),
          child: Row(
            children: [
              const Icon(Icons.local_offer_outlined,
                  color: AppColors.gold, size: 36),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Até 10% de desconto',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    SizedBox(height: 4),
                    Text(
                      'Após responder, você ganha um cupom único para usar em lojas selecionadas do shopping.',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        InkWell(
          onTap: () => vm.toggleLgpd(!vm.lgpdAccepted),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.lightCream,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: vm.lgpdAccepted ? AppColors.gold : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  vm.lgpdAccepted
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  color: AppColors.gold,
                  size: 22,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Privacidade Garantida (Sem CPF ou Nome)',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Toque para aceitar: suas respostas são totalmente anônimas e usadas apenas para gerar seu cupom e melhorar o shopping.',
                        style: TextStyle(fontSize: 11, height: 1.35, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep1Interests(TotemViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('01 / 03   FAIXA ETÁRIA E INTERESSE PRINCIPAL',
            style: AppTypography.labelGold),
        const SizedBox(height: 16),
        const Text('Qual a sua faixa etária?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: vm.ageGroups.map((age) {
            return ChoiceChip(
              label: Text(age, style: const TextStyle(fontSize: 12)),
              selected: vm.selectedAgeGroup == age,
              selectedColor: AppColors.gold,
              backgroundColor: AppColors.lightCream,
              onSelected: (_) => vm.selectAgeGroup(age),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        const Text('Qual categoria mais desperta seu interesse?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: vm.categories.map((cat) {
            return InkWell(
              onTap: () => vm.selectCategoryAndAdvance(cat),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 175,
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(cat,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                    const Text('→'),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStep2Events(TotemViewModel vm) {
    const events = [
      'Festival Gastronômico & Música na Praça',
      'Arena Games, Tecnologia & Robótica',
      'Feira Cultural, Artesanato & Jalapão',
      'Ativações Esportivas & Bem-Estar',
      'Moda, Desfiles & Promoções Sazonais',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('02 / 03   PREFERÊNCIA DE ATRAÇÕES',
            style: AppTypography.labelGold),
        const SizedBox(height: 16),
        const Text('Que tipo de evento você gostaria de ver no shopping?',
            style: AppTypography.h2),
        const SizedBox(height: 16),
        ...events.map((ev) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: () => vm.selectEventFormatAndAdvance(ev),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(ev,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500)),
                  ),
                  const Text('→'),
                ],
              ),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildStep3Satisfaction(TotemViewModel vm) {
    const options = ['Ruim', 'Boas', 'Excelentes'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('03 / 03   PERCEPÇÃO GERAL', style: AppTypography.labelGold),
        const SizedBox(height: 16),
        const Text('Como avalia as lojas que visitou hoje?',
            style: AppTypography.h2),
        const SizedBox(height: 16),
        ...options.asMap().entries.map((entry) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () async {
              vm.selectSatisfaction(entry.value);
              await vm.completeDirectlyAndIssueCoupon();
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('0${entry.key + 1}   ${entry.value}',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                  const Text('→'),
                ],
              ),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildStep4Coupon(TotemViewModel vm) {
    final coupon = vm.generatedCoupon;
    if (coupon == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('CUPOM GERADO COM SUCESSO', style: AppTypography.labelGold),
        const SizedBox(height: 8),
        const Text('Aproveite até 10% de desconto nas lojas participantes:',
            style: AppTypography.h2),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.gold, width: 1.5),
          ),
          child: Column(
            children: [
              const Text('CÓDIGO PSEUDONIMIZADO',
                  style:
                  TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Text(
                coupon.code,
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const Divider(height: 24),
              Text('${coupon.discountBenefit} • ${coupon.interestCategory}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Faixa etária: ${coupon.ageGroup}',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(TotemViewModel vm) {
    if (vm.step == 0) {
      return CdPrimaryButton(
        label: vm.lgpdAccepted
            ? 'Aceitar e Começar →'
            : 'Aceite os termos para iniciar',
        onPressed: vm.lgpdAccepted ? vm.startSurvey : null,
      );
    }
    if (vm.step >= 1 && vm.step <= 3) {
      return TextButton(
        onPressed: vm.previousStep,
        child: const Text('← Voltar'),
      );
    }
    if (vm.step == 4) {
      return Column(
        children: [
          CdPrimaryButton(
            label: 'Validar este Cupom na Loja →',
            icon: Icons.storefront,
            onPressed: vm.goToStoreSimulation,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: vm.resetFlow,
            child: const Text('Novo Visitante no Totem'),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}