# Planejamento Técnico Inicial — Ecossistema Inteligente Capim Dourado

## 1. Documentação Inicial do Projeto

### 1.1. Visão Geral e Problema
O Capim Dourado Shopping (Palmas - TO) recebe um fluxo intenso de visitantes em busca de lazer e compras. No entanto, a coleta de feedback sobre a satisfação com as lojas costuma ser fragmentada e de baixa adesão. A solução proposta resolve isso por meio de um **Totem Interativo de Pesquisa Expressa (30 segundos)**, transformando a opinião do público em métricas reais de satisfação para a gestão com o auxílio de gamificação.

### 1.2. Solução Proposta
Uma plataforma de autoatendimento touch em formato de totem que executa uma pesquisa rápida de 3 etapas (avaliação de variedade, percepção geral e atributos de valor) seguida de uma roleta de prêmios interativa, unindo engajamento e captação de métricas sem fricção para o usuário.

### 1.3. Escopo do MVP
* **Incluso:** Fluxo completo do totem em modo Kiosk (3 perguntas + roleta + cupom de desconto), captura opcional de telefone e painel de métricas simuladas.
* **Fora de Escopo:** Integração direta com sistemas de ERP e PDV das lojas individuais.

---

## 2. Linguagem de Programação Escolhida
* **TypeScript / JavaScript (ES2023+):** Escolhido pela alta produtividade, tipagem estática e ecossistema unificado para front-end.
* **SQL:** Utilizado para modelagem de banco de dados e persistência das métricas e feedbacks.

---

## 3. Arquitetura Proposta
1. **Camada de Apresentação (Front-end):** Interface em tela cheia otimizada para telas *touchscreen* (Modo Kiosk).
2. **Camada de Dados & API:** Backend assíncrono para registro seguro de interações de feedback.
3. **Banco de Dados Relacional:** Persistência para alimentar em tempo real o painel de métricas da gestão.

---

## 4. Plataforma e Tecnologias Adotadas

| Camada | Tecnologia / Plataforma | Justificativa Técnica |
| :--- | :--- | :--- |
| **Design e Wireframes** | **Figma** | Prototipagem de alta fidelidade e validação rápida do fluxo de telas de toque (UX). |
| **Front-end** | **Next.js (React) + Tailwind CSS** | Agilidade na criação de layouts responsivos e interfaces de totem. |
| **Back-end e Banco** | **Supabase (PostgreSQL)** | Banco de dados relacional seguro e estruturado para armazenamento rápido de métricas. |
| **Hospedagem** | **Vercel** | Deploy contínuo e alta disponibilidade. |

---

## 5. Proposta e Estrutura Inicial das Telas (Wireframes no Figma)
O fluxo desenhado e prototipado no Figma compreende as seguintes telas principais:
1. **Home / Boas-Vindas:** Chamada principal destacando a rapidez (*"30 segundos • Rápido. Sem cadastro"*) e botão "Começar".
2. **Avaliação de Variedade:** Validação rápida por frases (*"As lojas têm o que procuro"*).
3. **Avaliação Geral:** Classificação do conjunto de lojas visitadas (Más, Boas, Excelentes).
4. **Atributo de Valor:** Escolha do fator de maior destaque (Atendimento, Preços, Variedade, Promoções).
5. **Roleta de Prêmios:** Tela interativa de gamificação pós-pesquisa com giros para recompensas.
6. **Resgate e Fidelidade:** Exibição do cupom gerado e campo opcional para inserção de telefone (em conformidade com a LGPD).

🔗 **Acesse o protótipo completo no Figma:** [Wireframes Totem Capim Dourado](https://www.figma.com/design/NMQEEiZzv9lszXZZ3JiwXN/Wireframes-Totem-Capim-Dourado?node-id=0-1&t=5uVLa0GvSPKI9WZx-1)

---

## 6. Incorporação da Prática Sorteada: Testes, Métricas e Feedback
A tecnologia/prática sorteada foi **Testes e Métricas (Feedback)**, incorporada da seguinte forma na solução:
* **Métricas de Experiência (CSAT Express):** O totem opera como um gerador automatizado de indicadores de satisfação, coletando a percepção real do público em segundos.
* **Análise de Indicadores:** As respostas tabuladas alimentam um painel gerencial que mapeia falhas e acertos das operações do shopping com base em dados concretos.
* **Testes de Usabilidade:** Os wireframes criados no Figma foram pensados com base em leis de usabilidade *touch* (botões grandes e navegação linear), permitindo testar o fluxo com usuários reais antes do desenvolvimento final.
