#!/bin/bash
# Baixa e configura o Flutter SDK no ambiente de build do Vercel
git clone https://github.com/flutter/flutter.git -b stable --depth 1 _flutter
export PATH="$PATH:$(pwd)/_flutter/bin"
flutter doctor
flutter pub get
flutter build web --release