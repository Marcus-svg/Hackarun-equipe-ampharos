# Ecossistema Inteligente Capim Dourado - Totem e PWA

Projeto desenvolvido para o Hackathon, com foco em otimizar a experiencia dos visitantes do Capim Dourado Shopping (Palmas - TO) atraves de um totem interativo de autoatendimento, coleta inteligente de feedback e gamificacao de engajamento com as lojas.

---

## 1. Documentacao Inicial do Projeto

### 1.1. Visao Geral e Problema
O Capim Dourado Shopping recebe grande fluxo de publico em busca de lazer e compras em um ambiente climatizado. No entanto, a coleta de feedback sobre a satisfacao com as lojas costuma ser fragmentada ou de baixa adesao. A solucao proposta simplifica essa interacao por meio de um Totem Interativo de Pesquisa Expressa (30 segundos), sem necessidade de cadastro complexo, transformando a opiniao do publico em metricas reais para a gestao e oferecendo recompensas instantaneas (gamificacao).

### 1.2. Solucao Proposta (Fluxo do Usuario nos Wireframes)
O fluxo do totem foi desenhado para ser intuitivo, rapido e inclusivo:
1. Tela Inicial (Chamada para Acao): Convite amigavel destacando a velocidade ("Rapido. Sem cadastro. 3 perguntas e 1 roleta de premios" - 30 segundos).
2. Passo 1 (Variedade de Lojas): Percepcao rapida baseada em frases de validacao ("As lojas tem o que procuro").
3. Passo 2 (Avaliacao Geral): Classificacao do conjunto de lojas visitadas (ex: Mas, Boas, Excelentes).
4. Passo 3 (O Que Mais Conta): Identificacao do principal valor para o cliente (Atendimento, Precos, Variedade ou Promocoes).
5. Gamificacao (Roleta de Premios): Apos concluir as respostas, o usuario gira a roleta da sorte para desbloquear premios e mimos instantaneos.
6. Tela de Recompensa e Retencao: Exibicao do cupom conquistado (ex: 10% de desconto em lojas aderentes) com opcao opcional de insercao de telefone para receber novidades e resgatar o beneficio.

### 1.3. Escopo do MVP
* Incluso: Interface do Totem em modo Kiosk, fluxo completo de avaliacao de 3 etapas, animacao e mecanica da roleta de premios, tela de cupom gerado, entrada opcional de telefone e painel administrativo simulado com as metricas coletadas.
* Fora de Escopo: Integracao fiscal direta com os sistemas ERP de centenas de lojas do shopping (focado na validacao visual do cupom no caixa).

---

## 2. Linguagem de Programacao Escolhida
* TypeScript / JavaScript (ES2023+): Produtividade maxima para prototipagem rapida, tipagem estatica e ecossistema unificado para front-end e servicos.
* SQL: Modelagem relacional para persistencia de respostas e metricas agregadas.

---

## 3. Arquitetura Proposta

O projeto adota uma Arquitetura Desacoplada (Jamstack / Serverless):
1. Camada de Apresentacao (Front-end): Aplicacao web otimizada para telas touchscreen (Modo Kiosk) com cache local e alta resiliencia.
2. Camada de API / Backend (BaaS): Gerenciamento de rotas e registro de interacoes de feedback de forma anonima ou com consentimento (LGPD).
3. Camada de Banco de Dados Realtime: Persistencia relacional para alimentar os indicadores do painel gerencial instantaneamente.

---

## 4. Plataforma e Tecnologias Adotadas

| Camada | Tecnologia / Plataforma | Justificativa Tecnica |
| :--- | :--- | :--- |
| Front-end | Next.js (React) + Tailwind CSS | Agilidade na criacao de layouts responsivos, estilizacao limpa com identidade visual propria e modo tela cheia (Kiosk). |
| Icones e Estetica | Lucide Icons / SVG | Elementos visuais leves e icones intuitivos para garantir acessibilidade visual. |
| Back-end e Banco | Supabase (PostgreSQL) | Banco relacional seguro, pronto para armazenar os registros da pesquisa e os cupons resgatados. |
| Hospedagem | Vercel | Deploy continuo, SSL nativo e alta performance global. |

---

## 5. Proposta e Estrutura Inicial das Telas (Baseada nos Wireframes)

1. Tela 01 - Boas-Vindas (Home): Badge da marca Capim Dourado, chamada principal e o selo circular "30 segundos • Rapido. Sem cadastro" com o botao principal "Comecar".
2. Tela 02 - Percepcao de Variedade: Validacao por frases diretas ("As lojas tem o que procuro") com botoes de resposta rapida ("Nao representa" / "Representa").
3. Tela 03 - Avaliacao Geral: Classificacao das lojas visitadas em categorias simples (Mas, Boas, Excelentes).
4. Tela 04 - Atributo de Valor: Escolha do fator mais importante na experiencia (Atendimento, Precos, Variedade ou Promocoes).
5. Tela 05 - Roleta de Premios (Gamificacao): Tela interativa com o componente de roleta dividida em segmentos (descontos de 5%, 10% e Mimos) e botao central de acao "Girar a roleta".
6. Tela 06 - Resgate do Premio: Exibicao do voucher conquistado (ex: 10% de desconto) com orientacoes e botao de encerramento.
7. Tela 07 - Captura Opcional (Fidelidade): Campo de entrada para numero de telefone para envio do desconto e novidades (com total transparencia e foco em LGPD).

---

## 6. Incorporacao da Pratica / Tecnologia Sorteada (LGPD e Experiencia Inclusiva)
* Privacidade by Design (LGPD): A pesquisa de satisfacao e totalmente anonima por padrao. O fornecimento do numero de telefone na ultima etapa e estritamente opcional, servindo apenas como chave de resgate do cupom mediante consentimento claro do usuario.
* Acessibilidade Touch: Botoes de grande formato e navegacao linear em no maximo 3 toques, garantindo inclusao digital para todos os perfis de frequentadores do shopping.
