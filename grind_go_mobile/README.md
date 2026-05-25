# Grind & Go Mobile

Flutter-клиент для онлайн-заказа кофе (НИУ ВШЭ, Grind & Go HSE).

## Запуск в Chrome (web)

### Вариант A — обычная команда

```powershell
cd grind_go_mobile
flutter pub get
flutter run -d chrome
```

### Вариант B — если `flutter` падает с ошибкой `engine.stamp`

```powershell
cd grind_go_mobile
.\run_chrome.ps1
```

Скрипт вызывает Flutter через Dart напрямую (обход бага прав доступа в `C:\Program Files\Flutter\`).

При первом запуске Flutter сам соберёт web-версию и откроет вкладку в Chrome.

Полезные команды во время работы приложения в терминале:

- `r` — hot reload (обновить UI после правок)
- `R` — hot restart
- `q` — выход

## Сборка для деплоя

```powershell
flutter build web
```

Результат будет в `build/web/` — статические файлы для хостинга.

## Другие платформы (опционально)

Если нужны Android/iOS/Windows, сгенерируйте недостающие платформы:

```powershell
flutter create . --org com.hse.grindgo --project-name grind_go_mobile
```

## Структура

```
lib/
├── main.dart
├── theme/       # Цвета и ThemeData
├── models/      # Модели данных
├── screens/     # Экраны приложения
├── widgets/     # Переиспользуемые виджеты
└── data/        # Mock-данные (до подключения API)

web/
├── index.html
├── manifest.json
└── icons/       # Иконки PWA
```
