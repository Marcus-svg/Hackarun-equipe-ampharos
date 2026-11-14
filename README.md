# Hackarun - Capim Dourado Experience Intelligence

![Status](https://img.shields.io/badge/Status-Em_Desenvolvimento_(MVP)-yellow)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B)
![Python](https://img.shields.io/badge/Python-3.12-3776AB)
![FastAPI](https://img.shields.io/badge/FastAPI-0.115-009688)
![SQLite](https://img.shields.io/badge/SQLite-local-003B57)

Este repositório contém a implementação real do Hackarun: um frontend em Flutter para o totem e dashboard e um backend em Python/FastAPI para coleta e inteligência regional. A documentação antiga do README descrevia uma stack em Next.js/Supabase e precisa ser alinhada ao código atual.

O objetivo da solução é transformar dados regionais em indicadores e recomendações com evidência, auxiliando o Capim Dourado Shopping a identificar oportunidades de eventos, experiências e categorias com maior relevância em Palmas e região.

---

## Como executar localmente

### Backend Python

```powershell
cd backend
copy .env.example .env
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

Os endpoints principais ficam em:
- `http://localhost:8000/health`
- `http://localhost:8000/api/dashboard/summary`
- `http://localhost:8000/api/integrations/status`
- `http://localhost:8000/api/trends/import`

### Frontend Flutter

O app Flutter depende do SDK do Flutter instalado localmente. Em um ambiente com Flutter configurado:

```powershell
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

Se o Flutter estiver em emulador Android, o backend deve ser acessado por IP do host (ex.: `http://10.0.2.2:8000` em emuladores Android) em vez de `localhost`.

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
