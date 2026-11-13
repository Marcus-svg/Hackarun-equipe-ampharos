# Ecossistema Inteligente Capim Dourado (Totem & Analytics)

![Status](https://img.shields.io/badge/Status-Em_Desenvolvimento_(MVP)-yellow)
![Next.js](https://img.shields.io/badge/Next.js-14-black)
![TypeScript](https://img.shields.io/badge/TypeScript-5.0-blue)
![TailwindCSS](https://img.shields.io/badge/Tailwind_CSS-3.4-38B2AC)
![Supabase](https://img.shields.io/badge/Supabase-PostgreSQL-3ECF8E)
![Figma](https://img.shields.io/badge/Figma-Prototipo-F24E1E)

Solucao B2B2C de autoatendimento interativo (Modo Kiosk) e inteligencia de dados em tempo real, desenvolvida durante o Hackathon para o **Capim Dourado Shopping (Palmas - TO)**. O sistema transforma a coleta de feedback em uma experiencia gamificada de 30 segundos, gerando metricas acionaveis para a gestao e conversao de vendas para os lojistas.

---

## Sumario Executivo e Problema de Negocio

Centros comerciais enfrentam baixa adesao em pesquisas de satisfacao tradicionais e dificuldade em atribuir o impacto da experiencia do visitante ao desempenho das lojas. 

Nossa solucao substitui formularios longos por um **Micro-Funil Gamificado de 30 segundos** operado em totens touch. O visitante avalia a experiencia em tres toques, gira uma roleta de recompensas instantaneas e resgata descontos no comercio local, enquanto a administracao recebe telemetria em tempo real sobre percepcao de variedade, atendimento e retencao.

---

## 1. Proposta e Estrutura de Interface (UI/UX no Figma)

O design foi concebido seguindo principios de ergonomia para totens (*Fitts's Law*, alto contraste e zero necessidade de digitacao na etapa obrigatoria).

* **Link Oficial do Prototipo:** [Acessar Wireframes Totem Capim Dourado no Figma](https://www.figma.com/design/NMQEEiZzv9lszXZZ3JiwXN/Wireframes-Totem-Capim-Dourado?node-id=0-1&t=5uVLa0GvSPKI9WZx-1)

### Fluxo de Telas Mapeado:
1. **00_Idle / Attract Screen:** Tela inicial com selo de velocidade (*"30 segundos • Rapido. Sem cadastro"*) e CTA de alto destaque (`Comecar`).
2. **01_Percepcao de Mix (Variedade):** Validacao binaria rapida sobre o mix de lojas (*"As lojas tem o que procuro: Representa / Nao representa"*).
3. **02_CSAT Geral (Avaliacao):** Classificacao direta do conjunto de lojas visitadas (`01 Mas`, `02 Boas`, `03 Excelentes`).
4. **03_Driver de Valor:** Identificacao do fator decisivo de compra (`Atendimento`, `Precos`, `Variedade`, `Promocoes`).
5. **04_Motor de Gamificacao (Roleta):** Interacao ludica pos-pesquisa sorteando beneficios (`5%`, `10%`, `Mimo`).
6. **05_Conversao e Voucher:** Exibicao clara do premio desbloqueado com instrucoes de uso nas lojas aderentes.
7. **06_Retencao Opt-in (LGPD):** Captura opcional de WhatsApp/Telefone `(DD) XXXXX-XXXX` para envio digital do cupom e ofertas futuras.

---

## 2. Arquitetura do Sistema

O projeto adota uma **Arquitetura Serverless Orientada a Eventos**, separando a interface de operacao continua (Totem) do motor analitico (Dashboard).

```text
+-----------------------------------------------------------------------+
|                        CAMADA DE APRESENTACAO                         |
|  [ Totem Web App (Modo Kiosk) ]        [ Dashboard Gestao (Admin) ]   |
|  Next.js + Tailwind + LocalCache       Next.js + Recharts (Realtime)  |
+----------------+-------------------------------------+----------------+
                 | POST /feedback                      | WebSockets
                 v (JSON Anonimizado)                  v (Live Metrics)
+-----------------------------------------------------------------------+
|                      CAMADA DE SERVICOS E DADOS                       |
|                     Supabase (BaaS / PostgreSQL)                      |
|  - Autenticacao Anonima e Row Level Security (RLS)                    |
|  - Armazenamento de Respostas, Giros de Roleta e Leads (Hash/LGPD)    |
+-----------------------------------------------------------------------+
