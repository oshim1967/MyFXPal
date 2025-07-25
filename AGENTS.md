#!/bin/bash
# Начальная настройка среды для Jules
# Jules run all these command for setting up the environment.


# Устанавливаем режим трассировки для отладки
set -x

# Проверяем наличие curl и wget (должны быть предустановлены или установиться с зависимостями apt)
echo "--- Проверка наличия curl и wget ---"
command -v curl >/dev/null 2>&1 || { echo >&2 "Ошибка: curl не установлен. Не могу скачать Flutter SDK."; exit 1; }
command -v wget >/dev/null 2>&1 || { echo >&2 "Ошибка: wget не установлен. Не могу скачать Flutter SDK."; exit 1; }
echo "curl и wget доступны."


# Обновляем список пакетов и устанавливаем Git
echo "--- Обновление системы и установка Git ---"
sudo apt update -y || { echo "Ошибка: apt update не выполнен."; exit 1; }
sudo apt install git -y || { echo "Ошибка: git не установлен."; exit 1; }
echo "Git установлен."

# ПРЯМОЙ URL ДЛЯ СКАЧИВАНИЯ FLUTTER SDK
# Это для версии 3.22.2 stable (на основе информации о последней стабильной версии на момент знания)
# Если вы запускаете это сильно позже, возможно, вам придется обновить этот URL,
# найдя его на https://flutter.dev/docs/get-started/install/linux
FLUTTER_SDK_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.22.2-stable.tar.xz"
# Если 3.22.2 не подходит (например, если она устарела), вот URL для 3.22.3 (если она вышла):
# FLUTTER_SDK_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.22.3-stable.tar.xz"


# Скачиваем Flutter SDK
if [ ! -d "$HOME/flutter" ]; then
    echo "--- Скачивание Flutter SDK из прямого URL ---"
    echo "URL: $FLUTTER_SDK_URL"
    wget -O /tmp/flutter_linux.tar.xz "$FLUTTER_SDK_URL" || { echo "Ошибка: Flutter SDK не скачан с $FLUTTER_SDK_URL. Проверьте URL или сетевые ограничения."; exit 1; }
    mkdir -p "$HOME/flutter" || { echo "Ошибка: Не удалось создать папку Flutter."; exit 1; }
    tar -xf /tmp/flutter_linux.tar.xz -C "$HOME" || { echo "Ошибка: Не удалось распаковать Flutter SDK."; exit 1; }
    rm /tmp/flutter_linux.tar.xz
    echo "Flutter SDK скачан и распакован."
else
    echo "Папка Flutter SDK уже существует в $HOME/flutter. Пропускаем скачивание."
fi

# Добавляем Flutter в PATH
echo "--- Добавление Flutter в PATH ---"
# Эти строки добавляют в файл, но не сразу в текущую сессию
# Проверяем, существует ли уже запись в .bashrc или .zshrc
if ! grep -q 'export PATH="$PATH:$HOME/flutter/bin"' "$HOME/.bashrc" && [ -f "$HOME/.bashrc" ]; then
    echo 'export PATH="$PATH:$HOME/flutter/bin"' >> "$HOME/.bashrc"
    echo "Добавлено в ~/.bashrc"
fi
if ! grep -q 'export PATH="$PATH:$HOME/flutter/bin"' "$HOME/.zshrc" && [ -f "$HOME/.zshrc" ]; then
    echo 'export PATH="$PATH:$HOME/flutter/bin"' >> "$HOME/.zshrc"
    echo "Добавлено в ~/.zshrc"
fi

# **Критически важно:** Обновляем PATH для текущей сессии
export PATH="$PATH:$HOME/flutter/bin"
echo "PATH обновлен для текущей сессии. Текущий PATH: $PATH"
which flutter || echo "Предупреждение: Команда 'flutter' не найдена в текущем PATH после обновления. Это может быть проблемой."


# Устанавливаем OpenJDK 17
echo "--- Установка OpenJDK 17 ---"
sudo apt install openjdk-17-jdk -y || { echo "Ошибка: OpenJDK 17 не установлен."; exit 1; }
echo "OpenJDK 17 установлен."

# Устанавливаем необходимые зависимости для компиляции
echo "--- Установка зависимостей для компиляции ---"
sudo apt install -y clang cmake ninja-build pkg-config libgtk-3-dev libstdc++-12-dev || { echo "Ошибка: Зависимости для компиляции не установлены."; exit 1; }
echo "Зависимости для компиляции установлены."

# Запускаем flutter doctor и принимаем лицензии Android
echo "--- Запуск flutter doctor и принятие лицензий Android ---"
echo "Попытка автоматически принять лицензии Android. Это может потребовать интерактивного ввода 'y'."
# Используем yes | для автоматического ввода 'y'. Если это не сработает в Jules, возможно, потребуется ручной шаг.
yes | flutter doctor --android-licenses || { echo "Ошибка: Не удалось принять лицензии Android. Возможно, требуется ручной ввод или проблема с доступом."; }

# Запускаем flutter doctor для финальной проверки
echo "--- Финальная проверка с flutter doctor ---"
flutter doctor || { echo "Ошибка: flutter doctor завершился с ошибкой. Проверьте вывод выше."; exit 1; }

echo "--- Установка завершена! ---"
echo "Пожалуйста, перезапустите терминал или выполните 'source ~/.bashrc' (или ~/.zshrc) для полной активации PATH."
echo "Проверьте вывод 'flutter doctor' выше на наличие красных крестиков (X) и при необходимости устраните проблемы вручную."