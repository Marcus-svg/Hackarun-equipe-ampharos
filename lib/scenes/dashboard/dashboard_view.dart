import 'package:flutter/material.dart';
import '../../data/models/coupon_feedback_model.dart';
import '../../design_system/components/cd_primary_button.dart';
import '../../design_system/theme/app_colors.dart';
import '../../design_system/theme/app_typography.dart';
import 'dashboard_viewmodel.dart';

class DashboardView extends StatefulWidget {
  final DashboardViewModel viewModel;
  const DashboardView({super.key, required this.viewModel});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final TextEditingController _emailController =
  TextEditingController(text: 'gestao@capimdourado.com.br');
  final TextEditingController _passwordController =
  TextEditingController(text: '••••••••');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final vm = widget.viewModel;

        if (!vm.isAuthenticated) {
          return _buildTela01Acesso(vm);
        }

        return Container(
          width: 1020,
          decoration: BoxDecoration(
            color: const Color(0xFFFCFBF9),
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 24)],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= 780;
                if (isDesktop) {
                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSidebarDesktop(vm),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: _buildActiveTabContent(vm),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderMobile(vm),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: _buildActiveTabContent(vm),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }

  // ==========================================================================
  // TELA 01 / ACESSO (LOGIN DESKTOP & MOBILE DO FIGMA)
  // ==========================================================================
  Widget _buildTela01Acesso(DashboardViewModel vm) {
    return Container(
      width: 920,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 24)],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 720;
          return Row(
            children: [
              if (isDesktop)
                Expanded(
                  flex: 5,
                  child: Container(
                    padding: const EdgeInsets.all(40),
                    decoration: const BoxDecoration(
                      color: AppColors.cream,
                      borderRadius:
                      BorderRadius.horizontal(left: Radius.circular(14)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('CAPIM DOURADO',
                            style: AppTypography.labelGold),
                        const Text(
                          'Experience Intelligence',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 36),
                        const Text(
                          'Interesses que viram\nexperiências.',
                          style: AppTypography.h1,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Conheça seu público. Planeje o próximo encontro.',
                          style: AppTypography.body,
                        ),
                        const SizedBox(height: 32),
                        _buildStepItem('01', 'Acesse o painel'),
                        const SizedBox(height: 12),
                        _buildStepItem('02', 'Explore públicos e interesses'),
                        const SizedBox(height: 12),
                        _buildStepItem('03', 'Oriente suas decisões'),
                        const SizedBox(height: 36),
                        const Text(
                          'Gastronomia • Música • Tecnologia • Moda • Esportes • Cultura • Entretenimento',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('01 / ACESSO', style: AppTypography.labelGold),
                      const SizedBox(height: 8),
                      const Text('Bem-vindo ao painel',
                          style: AppTypography.h2),
                      const SizedBox(height: 4),
                      const Text('Entre para conhecer seu público.',
                          style: AppTypography.body),
                      const SizedBox(height: 24),
                      const Text('E-mail',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'seunome@empresa.com.br',
                          filled: true,
                          fillColor: AppColors.lightCream,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Senha',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Digite sua senha',
                          filled: true,
                          fillColor: AppColors.lightCream,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text('Esqueci minha senha',
                              style: TextStyle(
                                  fontSize: 11, color: AppColors.gold)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      CdPrimaryButton(
                        label: 'Entrar no painel',
                        onPressed: vm.login,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Acesso exclusivo da administração.\nPrecisa de acesso? Fale com o administrador.',
                        style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            height: 1.4),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStepItem(String number, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(number,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gold)),
        ),
        const SizedBox(width: 10),
        Text(text,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }

  // ==========================================================================
  // NAVEGAÇÃO LATERAL (DESKTOP) E SUPERIOR (MOBILE)
  // ==========================================================================
  Widget _buildSidebarDesktop(DashboardViewModel vm) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CAPIM DOURADO',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Experience Intelligence',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              _buildSidebarItem(vm, AdminTab.visaoGeral, 'Visão geral'),
              _buildSidebarItem(vm, AdminTab.publicos, 'Públicos'),
              _buildSidebarItem(vm, AdminTab.interesses, 'Interesses'),
              _buildSidebarItem(vm, AdminTab.tendencias, 'Tendências'),
              _buildSidebarItem(vm, AdminTab.relatorios, 'Relatórios'),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(),
              const Text(
                'Gestão do shopping',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              TextButton.icon(
                onPressed: vm.logout,
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                icon: const Icon(Icons.logout, size: 15, color: AppColors.gold),
                label: const Text('Sair (Tela 01 Acesso)',
                    style: TextStyle(fontSize: 11, color: AppColors.gold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
      DashboardViewModel vm, AdminTab tab, String label) {
    final active = vm.currentTab == tab;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: () => vm.setTab(tab),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: active ? AppColors.cream : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderMobile(DashboardViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'CAPIM DOURADO',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: vm.logout,
                child: const Text('Sair',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildMobileTabChip(vm, AdminTab.visaoGeral, 'Visão geral'),
              _buildMobileTabChip(vm, AdminTab.publicos, 'Públicos'),
              _buildMobileTabChip(vm, AdminTab.interesses, 'Interesses'),
              _buildMobileTabChip(vm, AdminTab.tendencias, 'Tendências'),
              _buildMobileTabChip(vm, AdminTab.relatorios, 'Relatórios'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileTabChip(
      DashboardViewModel vm, AdminTab tab, String label) {
    final active = vm.currentTab == tab;
    return InkWell(
      onTap: () => vm.setTab(tab),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.cream : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildActiveTabContent(DashboardViewModel vm) {
    return switch (vm.currentTab) {
      AdminTab.visaoGeral => _buildTab02VisaoGeral(vm),
      AdminTab.publicos => _buildTab03Publicos(vm),
      AdminTab.interesses => _buildTab04Interesses(vm),
      AdminTab.tendencias => _buildTab05Tendencias(vm),
      AdminTab.relatorios => _buildTab06Relatorios(vm),
    };
  }

  Widget _buildTopFiltersBar({
    required String codeLabel,
    required String title,
    required String subtitle,
    List<String> filterTags = const [
      'Período: 01 a 30 set. 2026',
      'Público: todos'
    ],
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 16,
          runSpacing: 12,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(codeLabel, style: AppTypography.labelGold),
                const SizedBox(height: 4),
                Text(title, style: AppTypography.h1),
                const SizedBox(height: 4),
                Text(subtitle, style: AppTypography.body),
              ],
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: filterTags
                  .map((tag) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(tag,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w500)),
              ))
                  .toList(),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ==========================================================================
  // TELA 02 / VISÃO GERAL (FIGMA + INTEGRAÇÃO DO CUPOM)
  // ==========================================================================
  Widget _buildTab02VisaoGeral(DashboardViewModel vm) {
    final weeks = vm.weeklyParticipations;
    final maxWeek = weeks.reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTopFiltersBar(
          codeLabel: '02 / PAINEL ADMINISTRATIVO',
          title: 'Visão geral',
          subtitle: 'Conheça o que move seu público.',
        ),

        // 4 KPI Cards do Figma + 1 KPI do Ciclo de Cupom
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildFigmaKpiCard(
              'Consumidores',
              vm.totalConsumersFormatted,
              '+5,8% vs. agosto',
            ),
            _buildFigmaKpiCard(
              'Categorias',
              '7',
              'Experiências monitoradas',
            ),
            _buildFigmaKpiCard(
              'Maior interesse',
              '62%',
              'Gastronomia',
            ),
            _buildFigmaKpiCard(
              'Em crescimento',
              '+8 p.p.',
              'Tecnologia vs. agosto',
            ),
            _buildFigmaKpiCard(
              'Taxa de resgate (Cupons)',
              '${vm.redemptionRatePercent}% (${vm.totalRedeemed}/${vm.totalIssued})',
              'Interesse convertido em loja',
            ),
          ],
        ),
        const SizedBox(height: 24),

        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            // Card Esquerdo: Interesses por categoria
            Container(
              width: 440,
              padding: const EdgeInsets.all(24),
              decoration: _cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Interesses por categoria',
                      style:
                      TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Parcela dos consumidores por interesse',
                      style: AppTypography.body),
                  const SizedBox(height: 18),
                  ...vm.categoryMetrics.map((cat) {
                    final pct = vm.getCategoryPercentage(cat);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(cat.name,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500)),
                              Text('$pct%',
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          LinearProgressIndicator(
                            value: pct / 100,
                            backgroundColor: AppColors.lightCream,
                            color: AppColors.gold,
                            minHeight: 7,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Cada pessoa pode escolher mais de uma categoria.',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ),
                      TextButton(
                        onPressed: () => vm.setTab(AdminTab.interesses),
                        child: const Text('Explorar interesses →',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.gold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Coluna Direita: Participações por Semana + Em Destaque
            SizedBox(
              width: 390,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: _cardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Participações no período',
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text('Total por semana',
                            style: AppTypography.body),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 160,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: List.generate(4, (i) {
                              final val = weeks[i];
                              final barHeight = (val / maxWeek) * 110;
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text('$val',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 6),
                                  Container(
                                    width: 48,
                                    height: barHeight,
                                    decoration: BoxDecoration(
                                      color: i == 3
                                          ? AppColors.gold
                                          : const Color(0xFFC9C5BA),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text('S${i + 1}',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary)),
                                ],
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppColors.cream,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('EM DESTAQUE',
                            style: AppTypography.labelGold),
                        const SizedBox(height: 8),
                        const Text(
                          'Gastronomia lidera o interesse.\nTecnologia tem a maior alta do mês: 8 pontos percentuais.',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              height: 1.35),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => vm.setTab(AdminTab.tendencias),
                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                          child: const Text('Ver tendências →',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.gold)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================================================
  // TELA 03 / PÚBLICOS (FIGMA DESKTOP & MOBILE)
  // ==========================================================================
  Widget _buildTab03Publicos(DashboardViewModel vm) {
    const ageDistribution = [
      {'faixa': '18 a 24 anos', 'pct': 28},
      {'faixa': '25 a 34 anos', 'pct': 36},
      {'faixa': '35 a 44 anos', 'pct': 22},
      {'faixa': '45 anos ou mais', 'pct': 14},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTopFiltersBar(
          codeLabel: '03 / PAINEL ADMINISTRATIVO',
          title: 'Públicos',
          subtitle: 'Entenda perfis e preferências.',
          filterTags: const [
            '01 a 30 set. 2026',
            'Faixa etária: todas as idades',
            'Aplicar filtros'
          ],
        ),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            // Distribuição por idade
            Container(
              width: 460,
              padding: const EdgeInsets.all(24),
              decoration: _cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Distribuição por idade',
                      style:
                      TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${vm.totalConsumersFormatted} consumidores no período',
                      style: AppTypography.body),
                  const SizedBox(height: 20),
                  ...ageDistribution.map((item) {
                    final pct = item['pct'] as int;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(item['faixa'] as String,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500)),
                              Text('$pct%',
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          LinearProgressIndicator(
                            value: pct / 100,
                            backgroundColor: AppColors.lightCream,
                            color: pct == 36
                                ? AppColors.gold
                                : const Color(0xFFC9C5BA),
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Card Público em Foco
            Container(
              width: 370,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('PÚBLICO EM FOCO', style: AppTypography.labelGold),
                  const SizedBox(height: 10),
                  const Text('25 a 34 anos', style: AppTypography.h2),
                  const SizedBox(height: 4),
                  const Text('36% do público',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gold)),
                  const SizedBox(height: 12),
                  const Text(
                    '449 consumidores. Gastronomia é o principal interesse deste grupo.',
                    style: AppTypography.body,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => vm.setTab(AdminTab.interesses),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: const Text('Explorar interesses →',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.gold)),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Tabela Preferências por público
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Preferências por público',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...vm.audienceProfiles.map((profile) {
                final share =
                ((profile.baseConsumers / vm.totalConsumers) * 100).round();
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border:
                    Border(bottom: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    spacing: 16,
                    runSpacing: 6,
                    children: [
                      SizedBox(
                        width: 150,
                        child: Text(profile.ageGroup,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                      Text('${profile.baseConsumers} consumidores',
                          style: const TextStyle(fontSize: 13)),
                      Text('$share% do total',
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textSecondary)),
                      Text('Maior interesse: ${profile.topInterest}',
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 12),
              const Text(
                'Informações agregadas, sem identificação individual (Conformidade LGPD).',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // TELA 04 / INTERESSES (FIGMA DESKTOP & MOBILE)
  // ==========================================================================
  Widget _buildTab04Interesses(DashboardViewModel vm) {
    final detail = vm.selectedCategoryDetail;
    final pct = vm.getCategoryPercentage(detail);
    final diff = pct - detail.augustPercentage;
    final diffLabel = diff >= 0 ? '+$diff p.p.' : '$diff p.p.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTopFiltersBar(
          codeLabel: '04 / PAINEL ADMINISTRATIVO',
          title: 'Interesses',
          subtitle: 'Explore as categorias de experiência.',
        ),
        const Text('Selecione uma categoria',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: vm.categoryMetrics.map((cat) {
            final isSelected = cat.name == vm.selectedCategoryName;
            final catPct = vm.getCategoryPercentage(cat);
            return InkWell(
              onTap: () => vm.selectCategory(cat.name),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.cream : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? AppColors.gold : Colors.grey.shade300,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cat.name,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text('$catPct%',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            // Card Categoria Selecionada
            Container(
              width: 400,
              padding: const EdgeInsets.all(24),
              decoration: _cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('CATEGORIA SELECIONADA',
                      style: AppTypography.labelGold),
                  const SizedBox(height: 8),
                  Text(detail.name, style: AppTypography.h2),
                  const SizedBox(height: 4),
                  const Text('Indicadores consolidados do período.',
                      style: AppTypography.body),
                  const Divider(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMiniStat('$pct%', 'dos consumidores'),
                      _buildMiniStat('${detail.baseInterestedCount}',
                          'pessoas interessadas'),
                      _buildMiniStat(diffLabel, 'em relação a agosto'),
                    ],
                  ),
                ],
              ),
            ),

            // Card Interesse por faixa etária
            Container(
              width: 430,
              padding: const EdgeInsets.all(24),
              decoration: _cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Interesse por faixa etária',
                      style:
                      TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Percentual dentro de cada faixa',
                      style: AppTypography.body),
                  const SizedBox(height: 16),
                  ...detail.ageGroupAffinity.entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(entry.key,
                                style: const TextStyle(fontSize: 13)),
                            Text('${entry.value}%',
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(
                          value: entry.value / 100,
                          backgroundColor: AppColors.lightCream,
                          color: AppColors.gold,
                          minHeight: 7,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Card Oportunidade
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('OPORTUNIDADE', style: AppTypography.labelGold),
                  const SizedBox(height: 6),
                  Text(detail.opportunityTitle,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(detail.opportunityDescription,
                      style: AppTypography.body),
                ],
              ),
              TextButton(
                onPressed: () => vm.setTab(AdminTab.tendencias),
                child: const Text('Ver evolução da categoria →',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: AppColors.gold)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label,
            style:
            const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }

  // ==========================================================================
  // TELA 05 / TENDÊNCIAS (FIGMA DESKTOP & MOBILE)
  // ==========================================================================
  Widget _buildTab05Tendencias(DashboardViewModel vm) {
    const months = ['Jun', 'Jul', 'Ago', 'Set'];
    const techSeries = [24, 26, 27, 35];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTopFiltersBar(
          codeLabel: '05 / PAINEL ADMINISTRATIVO',
          title: 'Tendências',
          subtitle: 'Acompanhe o que ganha relevância.',
          filterTags: const [
            '01 a 30 set. 2026',
            'Categoria: tecnologia',
            'Comparar com: agosto de 2026'
          ],
        ),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            // Gráfico Tecnologia em alta (Jun a Set)
            Container(
              width: 460,
              padding: const EdgeInsets.all(24),
              decoration: _cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tecnologia em alta',
                      style:
                      TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Interesse por mês • Junho a setembro de 2026',
                      style: AppTypography.body),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 165,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(4, (i) {
                        final val = techSeries[i];
                        final h = (val / 35) * 115;
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('$val%',
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Container(
                              width: 52,
                              height: h,
                              decoration: BoxDecoration(
                                color: i == 3
                                    ? AppColors.gold
                                    : const Color(0xFFC9C5BA),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(months[i],
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary)),
                          ],
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),

            // Card Maior Crescimento
            Container(
              width: 370,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MAIOR CRESCIMENTO', style: AppTypography.labelGold),
                  SizedBox(height: 10),
                  Text('+8 p.p.', style: AppTypography.h1),
                  SizedBox(height: 4),
                  Text('Tecnologia',
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text(
                    'De 27% para 35% em um mês.\nConsidere experiências digitais e demonstrações de produtos.',
                    style: AppTypography.body,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Tabela Comparativo das categorias
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Comparativo das categorias',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Setembro em relação a agosto',
                  style: AppTypography.body),
              const SizedBox(height: 16),
              ...vm.categoryMetrics.map((cat) {
                final sep = vm.getCategoryPercentage(cat);
                final aug = cat.augustPercentage;
                final diff = sep - aug;
                final diffStr = diff >= 0 ? '+$diff p.p.' : '$diff p.p.';
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border:
                    Border(bottom: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(cat.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('Agosto: $aug%',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textSecondary)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('Setembro: $sep%',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                      Text(
                        diffStr,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: diff >= 0
                              ? AppColors.gold
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // TELA 06 / RELATÓRIOS (FIGMA DESKTOP & MOBILE)
  // ==========================================================================
  Widget _buildTab06Relatorios(DashboardViewModel vm) {
    const conteudos = [
      'Resumo dos indicadores',
      'Perfil dos públicos',
      'Interesses por categoria',
      'Tendências do período',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTopFiltersBar(
          codeLabel: '06 / PAINEL ADMINISTRATIVO',
          title: 'Relatórios',
          subtitle: 'Transforme dados em decisões.',
        ),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            // Card Configurar Relatório
            Container(
              width: 440,
              padding: const EdgeInsets.all(24),
              decoration: _cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Configurar relatório',
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Text('1. Conteúdo',
                      style:
                      TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ...conteudos.map((item) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.lightCream,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item, style: const TextStyle(fontSize: 13)),
                        const Text('Incluído',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.gold)),
                      ],
                    ),
                  )),
                  const SizedBox(height: 16),
                  const Text('2. Formato',
                      style:
                      TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFormatSelector(
                          vm,
                          format: 'PDF',
                          desc: 'Resumo visual',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildFormatSelector(
                          vm,
                          format: 'CSV',
                          desc: 'Dados em tabela',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  CdPrimaryButton(
                    label: 'Gerar relatório ${vm.selectedReportFormat}',
                    onPressed: vm.generateNewReport,
                  ),
                  if (vm.reportFeedbackMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      vm.reportFeedbackMessage!,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.success,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                  const SizedBox(height: 8),
                  const Text('O relatório respeita os filtros selecionados.',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ),

            // Coluna Direita: Prévia do Relatório + Últimos Relatórios
            SizedBox(
              width: 390,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: _cardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('PRÉVIA DO RELATÓRIO',
                            style: AppTypography.labelGold),
                        const SizedBox(height: 6),
                        const Text('Interesses e experiências',
                            style: AppTypography.h2),
                        const SizedBox(height: 4),
                        const Text('Capim Dourado • Setembro de 2026',
                            style: AppTypography.body),
                        const Divider(height: 24),
                        const Text('Consumidores',
                            style: TextStyle(
                                fontSize: 11, color: AppColors.textSecondary)),
                        Text(vm.totalConsumersFormatted,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        const Divider(height: 20),
                        const Text('Categoria líder',
                            style: TextStyle(
                                fontSize: 11, color: AppColors.textSecondary)),
                        const Text('Gastronomia • 62%',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const Divider(height: 20),
                        const Text('Maior crescimento',
                            style: TextStyle(
                                fontSize: 11, color: AppColors.textSecondary)),
                        const Text('Tecnologia • +8 p.p.',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const Divider(height: 20),
                        const Text('Principais leituras',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text(
                          'Gastronomia lidera. Tecnologia apresenta a maior evolução mensal.',
                          style: AppTypography.body,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: _cardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Últimos relatórios',
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        ...vm.generatedReports.map((rep) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(rep['titulo']!,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600)),
                                  Text(
                                      '${rep['data']} • ${rep['formato']}',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary)),
                                ],
                              ),
                              Text(rep['acao']!,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.gold)),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormatSelector(
      DashboardViewModel vm, {
        required String format,
        required String desc,
      }) {
    final selected = vm.selectedReportFormat == format;
    return InkWell(
      onTap: () => vm.setReportFormat(format),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.cream : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.gold : Colors.grey.shade300,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(format,
                style:
                const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(desc,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildFigmaKpiCard(String label, String value, String sub) {
    return Container(
      width: 172,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text(value,
              style:
              const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(sub,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade200),
    );
  }
}