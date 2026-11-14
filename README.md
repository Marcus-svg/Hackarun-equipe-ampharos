# Hackarun - Capim Dourado Experience Intelligence

![Status](https://img.shields.io/badge/Status-Em_Desenvolvimento_(MVP)-yellow)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B)
![Python](https://img.shields.io/badge/Python-3.12-3776AB)
![FastAPI](https://img.shields.io/badge/FastAPI-0.115-009688)
![SQLite](https://img.shields.io/badge/SQLite-local-003B57)
[![Vídeo de Demonstração](https://img.shields.io/badge/YouTube-Assistir_Demonstração-FF0000?style=flat&logo=youtube&logoColor=white)](https://youtu.be/0nyy2pfhUfs)

Este repositório contém a implementação real do Hackarun: um frontend em Flutter para o totem e dashboard e um backend em Python/FastAPI para coleta e inteligência regional.

O objetivo da solução é transformar dados regionais em indicadores e recomendações com evidência, auxiliando o Capim Dourado Shopping a identificar oportunidades de eventos, experiências e categorias com maior relevância em Palmas e região.

---

## Demonstração em Vídeo
👉 **[Clique aqui para assistir à apresentação e demonstração do sistema no YouTube](https://youtu.be/0nyy2pfhUfs)**

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