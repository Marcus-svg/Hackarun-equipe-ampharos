# 🌟 Ecossistema Inteligente Capim Dourado — Totem & PWA

Projeto desenvolvido para o Hackathon, com foco em otimizar a experiência dos visitantes do **Capim Dourado Shopping (Palmas - TO)** através de um totem interativo de autoatendimento, coleta inteligente de feedback e gamificação de engajamento com as lojas.

---

## 📋 1. Documentação Inicial do Projeto

### 1.1. Visão Geral e Problema
O Capim Dourado Shopping recebe grande fluxo de público em busca de lazer e compras em um ambiente climatizado[span_0](start_span)[span_0](end_span)[span_1](start_span)[span_1](end_span). No entanto, a coleta de feedback sobre a satisfação com as lojas costuma ser fragmentada ou de baixa adesão. A solução proposta simplifica essa interação por meio de um **Totem Interativo de Pesquisa Expressa (30 segundos)**, sem necessidade de cadastro complexo[span_2](start_span)[span_2](end_span), transformando a opinião do público em métricas reais para a gestão e oferecendo recompensas instantâneas (gamificação).

### 1.2. Solução Proposta (Fluxo do Usuário nos Wireframes)
O fluxo do totem foi desenhado para ser intuitivo, rápido e inclusivo:
1. **Tela Inicial (Chamada para Ação):** Convite amigável destacando a velocidade (*"Rápido. Sem cadastro. 3 perguntas e 1 roleta de prêmios"* - 30 segundos)[span_3](start_span)[span_3](end_span).
2. **Passo 1 (Variedade de Lojas):** Percepção rápida baseada em frases de validação (*"As lojas têm o que procuro"*)[span_4](start_span)[span_4](end_span).
3. **Passo 2 (Avaliação Geral):** Classificação do conjunto de lojas visitadas (ex: Más, Boas, Excelentes)[span_5](start_span)[span_5](end_span).
4. **Passo 3 (O Que Mais Conta):** Identificação do principal valor para o cliente (*Atendimento, Preços, Variedade ou Promoções*)[span_6](start_span)[span_6](end_span).
5. **Gamificação (Roleta de Prêmios):** Após concluir as respostas, o usuário gira a roleta da sorte para desbloquear prêmios e mimos instantâneos[span_7](start_span)[span_7](end_span).
6. **Tela de Recompensa & Retenção:** Exibição do cupom conquistado (ex: *10% de desconto em lojas aderentes*)[span_8](start_span)[span_8](end_span) com opção opcional de inserção de telefone para receber novidades e resgatar o benefício[span_9](start_span)[span_9](end_span).

### 1.3. Escopo do MVP
* **Incluso:** Interface do Totem em modo *Kiosk*, fluxo completo de avaliação de 3 etapas, animação/mecânica da roleta de prêmios, tela de cupom gerado, entrada opcional de telefone e painel administrativo simulado com as métricas coletadas.
* **Fora de Escopo:** Integração fiscal direta com os sistemas ERP de centenas de lojas do shopping (focado na validação visual do cupom no caixa).

---

## 🛠️ 2. Linguagem de Programação Escolhida
* **TypeScript / JavaScript (ES2023+):** Produtividade máxima para prototipagem rápida, tipagem estática e ecossistema unificado para front-end e serviços.
* **SQL:** Modelagem relacional para persistência de respostas e métricas agregadas.

---

## 🏗️ 3. Arquitetura Proposta

O projeto adota uma **Arquitetura Desacoplada (Jamstack / Serverless)**:
1. **Camada de Apresentação (Front-end):** Aplicação web otimizada para telas *touchscreen* (Modo Kiosk) com cache local e alta resiliência.
2. **Camada de API / Backend (BaaS):** Gerenciamento de rotas e registro de interações de feedback de forma anônima ou com consentimento (LGPD).
3. **Camada de Banco de Dados Realtime:** Persistência relacional para alimentar os indicadores do painel gerencial instantaneamente.

---

## 🚀 4. Plataforma e Tecnologias Adotadas

| Camada | Tecnologia / Plataforma | Justificativa Técnica |
| :--- | :--- | :--- |
| **Front-end** | **Next.js (React) + Tailwind CSS** | Agilidade na criação de layouts responsivos, estilização limpa com identidade visual própria e modo tela cheia (*Kiosk*). |
| **Ícones e Estética** | **Lucide Icons / SVG** | Elementos visuais leves e ícones intuitivos para garantir acessibilidade visual. |
| **Back-end & Banco de Dados** | **Supabase (PostgreSQL)** | Banco relacional seguro, pronto para armazenar os registros da pesquisa e os cupons resgatados. |
| **Hospedagem** | **Vercel** | Deploy contínuo, SSL nativo e alta performance global. |

---

## 📱 5. Proposta e Estrutura Inicial das Telas (Baseada nos Wireframes)

1. **Tela 01 - Boas-Vindas (Home):** Badge da marca Capim Dourado, chamada principal e o selo circular *"30 segundos • Rápido. Sem cadastro"* com o botão principal **"Começar"**[span_10](start_span)[span_10](end_span).
2. **Tela 02 - Percepção de Variedade:** Validação por frases diretas (*"As lojas têm o que procuro"*) com botões de resposta rápida (*"Não representa"* / *"Representa"*)[span_11](start_span)[span_11](end_span).
3. **Tela 03 - Avaliação Geral:** Classificação das lojas visitadas em categorias simples (*Más, Boas, Excelentes*)[span_12](start_span)[span_12](end_span).
4. **Tela 04 - Atributo de Valor:** Escolha do fator mais importante na experiência (*Atendimento, Preços, Variedade ou Promoções*)[span_13](start_span)[span_13](end_span).
5. **Tela 05 - Roleta de Prêmios (Gamificação):** Tela interativa com o componente de roleta dividida em segmentos (descontos de 5%, 10% e Mimos) e botão central de ação **"Girar a roleta"**[span_14](start_span)[span_14](end_span).
6. **Tela 06 - Resgate do Prêmio:** Exibição do voucher conquistado (ex: *10% de desconto*) com orientações e botão de encerramento[span_15](start_span)[span_15](end_span).
7. **Tela 07 - Captura Opcional (Fidelidade):** Campo de entrada para número de telefone `(DD) XXXXX-XXXX` para envio do desconto e novidades (com total transparência e foco em LGPD)[span_16](start_span)[span_16](end_span).

---

## 🔒 6. Incorporação da Prática / Tecnologia Sorteada (LGPD & Experiência Inclusiva)
* **Privacidade by Design (LGPD):** A pesquisa de satisfação é totalmente anônima por padrão[span_17](start_span)[span_17](end_span). O fornecimento do número de telefone na última etapa é estritamente opcional[span_18](start_span)[span_18](end_span), servindo apenas como chave de resgate do cupom mediante consentimento claro do usuário.
* **Acessibilidade Touch:** Botões de grande formato e navegação linear em no máximo 3 toques, garantindo inclusão digital para todos os perfis de frequentadores do shopping.

---

### 👥 Equipe do Projeto
Desenvolvido para o Hackathon do Capim Dourado Shopping.
