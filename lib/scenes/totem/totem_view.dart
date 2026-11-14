import 'dart:math';
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

class _TotemViewState extends State<TotemView>
    with SingleTickerProviderStateMixin {
  late AnimationController _wheelController;
  late Animation<double> _wheelAnimation;
  bool _spinning = false;

  @override
  void initState() {
    super.initState();
    _wheelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _wheelAnimation = CurvedAnimation(
      parent: _wheelController,
      curve: Curves.decelerate,
    );
  }

  @override
  void dispose() {
    _wheelController.dispose();
    super.dispose();
  }

  Future<void> _spinWheel() async {
    if (_spinning) return;
    setState(() => _spinning = true);
    await _wheelController.forward(from: 0);
    await widget.viewModel.completeWheelAndIssueCoupon();
    if (mounted) {
      setState(() => _spinning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final vm = widget.viewModel;
        return Container(
          width: 430,
          constraints: const BoxConstraints(minHeight: 720),
          padding: const EdgeInsets.all(32),
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
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('CAPIM DOURADO SHOPPING',
                          style: AppTypography.labelGold),
                      Text('LGPD Pseudonimizado',
                          style: TextStyle(
                              fontSize: 10, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (vm.step == 0) _buildStep0Home(vm),
                  if (vm.step == 1) _buildStep1Interests(vm),
                  if (vm.step == 2) _buildStep2Events(vm),
                  if (vm.step == 3) _buildStep3Satisfaction(vm),
                  if (vm.step == 4) _buildStep4Wheel(),
                  if (vm.step == 5) _buildStep5Coupon(vm),
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
          'Responda voluntariamente a 3 perguntas rápidas e receba um cupom exclusivo para usar nas lojas participantes.',
          style: AppTypography.body,
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.gold, width: 5),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('30', style: TextStyle(fontSize: 30)),
                  Text('SEGUNDOS',
                      style: TextStyle(
                          fontSize: 8, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(width: 20),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rápido e Sem CPF.',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  SizedBox(height: 6),
                  Text('3 perguntas de interesse\n+ 1 Cupom de código único',
                      style: AppTypography.body),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        InkWell(
          onTap: () => vm.toggleLgpd(!vm.lgpdAccepted),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cream,
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
                  child: Text(
                    'Consentimento Explícito (LGPD): Aceito informar minha faixa etária e interesses de forma anônima para geração do cupom e análise agregada do shopping.',
                    style: TextStyle(fontSize: 11, height: 1.35),
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
    const options = ['Más', 'Boas', 'Excelentes'];
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
                onTap: () => vm.selectSatisfactionAndAdvance(entry.value),
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

  Widget _buildStep4Wheel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Gire a roleta para emitir seu Cupom Único!',
            style: AppTypography.h2),
        const SizedBox(height: 24),
        Center(
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              AnimatedBuilder(
                animation: _wheelAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _wheelAnimation.value * 10 * pi,
                    child: child,
                  );
                },
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.cream,
                    border: Border.all(color: AppColors.gold, width: 6),
                  ),
                  child: const Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                          top: 18,
                          child: Text('10% OFF',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      Positioned(
                          bottom: 18,
                          child: Text('10% OFF',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      Positioned(
                          left: 16,
                          child: Text('Mimo',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      Positioned(
                          right: 16,
                          child: Text('5% OFF',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
              ),
              const Icon(Icons.arrow_drop_down, size: 36),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep5Coupon(TotemViewModel vm) {
    final coupon = vm.generatedCoupon;
    if (coupon == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('CUPOM EMITIDO COM SUCESSO', style: AppTypography.labelGold),
        const SizedBox(height: 8),
        const Text('Utilize este código em uma loja participante:',
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
            : 'Aceite o termo LGPD para iniciar',
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
      return CdPrimaryButton(
        label: 'Girar a Roleta e Gerar Cupom',
        isLoading: _spinning,
        onPressed: _spinWheel,
      );
    }
    if (vm.step == 5) {
      return Column(
        children: [
          CdPrimaryButton(
            label: 'Validar este Cupom na Loja (Passo 3 e 4) →',
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