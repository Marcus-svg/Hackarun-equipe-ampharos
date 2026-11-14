import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../design_system/components/cd_primary_button.dart';
import '../../design_system/theme/app_colors.dart';
import '../../design_system/theme/app_typography.dart';
import 'store_viewmodel.dart';

class StoreRedemptionView extends StatefulWidget {
  final StoreRedemptionViewModel viewModel;
  final String? initialCode;

  const StoreRedemptionView({
    super.key,
    required this.viewModel,
    this.initialCode,
  });

  @override
  State<StoreRedemptionView> createState() => _StoreRedemptionViewState();
}

class _StoreRedemptionViewState extends State<StoreRedemptionView> {
  late final TextEditingController _codeController;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.initialCode ?? '');
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final vm = widget.viewModel;
        return Container(
          width: 520,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('FONTE 1 • REGISTRO DE RESGATE NAS LOJAS',
                  style: AppTypography.labelGold),
              const SizedBox(height: 6),
              const Text('Validador da Loja Participante',
                  style: AppTypography.h2),
              const SizedBox(height: 8),
              const Text(
                'Conecta o interesse declarado no totem ao consumo real na loja sem exigir dados pessoais do visitante.',
                style: AppTypography.body,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: vm.selectedStore,
                decoration: InputDecoration(
                  labelText: 'Estabelecimento Participante',
                  filled: true,
                  fillColor: AppColors.cream,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: vm.stores.entries
                    .map((e) => DropdownMenuItem(
                          value: e.key,
                          child: Text('${e.key} (${e.value})',
                              style: const TextStyle(fontSize: 13)),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) vm.setStore(val);
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _codeController,
                decoration: InputDecoration(
                  labelText: 'Código Único do Cupom',
                  hintText: 'Ex: CD-3319',
                  filled: true,
                  fillColor: AppColors.lightCream,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              CdPrimaryButton(
                label: 'Registrar Resgate pelo Código',
                icon: Icons.verified_outlined,
                onPressed: () => vm.redeemCode(_codeController.text),
              ),
              if (vm.statusMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: vm.isSuccess
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vm.statusMessage!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: vm.isSuccess
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                      if (vm.isSuccess)
                        TextButton(
                          onPressed:
                              ServiceLocator.coordinator.navigateToDashboard,
                          child: const Text(
                              'Ver análise atualizada no Dashboard →'),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}