# Настройка TestFlight для NotaSpace

## Требования

1. **Apple Developer Program** аккаунт ($99/год)
   - Регистрация: https://developer.apple.com/programs/
   - Нужен для публикации в TestFlight и App Store

2. **App Store Connect** доступ
   - После регистрации в Developer Program получите доступ к App Store Connect

## Шаг 1: Создание приложения в App Store Connect

1. Откройте https://appstoreconnect.apple.com
2. Войдите с Apple ID (из Developer Program)
3. Перейдите в **"Мои приложения"** → **"+"** → **"Новое приложение"**
4. Заполните информацию:
   - **Платформы**: iOS
   - **Название**: NotaSpace
   - **Основной язык**: Русский
   - **Bundle ID**: `ru.notaspace.app` (должен совпадать с проектом)
   - **SKU**: `notaspace-ios` (уникальный идентификатор)
5. Нажмите **"Создать"**

## Шаг 2: Настройка проекта в Xcode

### 2.1. Bundle Identifier

1. Откройте проект в Xcode
2. Выберите проект "NotaSpace" → target "NotaSpace"
3. Вкладка **"General"**
4. **Bundle Identifier**: `ru.notaspace.app` (должен совпадать с App Store Connect)

### 2.2. Signing & Capabilities

1. Вкладка **"Signing & Capabilities"**
2. Включите **"Automatically manage signing"**
3. Выберите ваш **Team** (из Apple Developer Program)
4. Xcode автоматически создаст Provisioning Profile

### 2.3. Версия приложения

1. Вкладка **"General"**
2. **Version**: `1.0` (версия для пользователей)
3. **Build**: `1` (номер сборки, увеличивается с каждой загрузкой)

## Шаг 3: Настройка для Production API

Перед созданием архива убедитесь, что используется Production API:

1. Откройте `NotaSpace/Sources/Network/APIClient.swift`
2. Убедитесь, что для Release используется Production URL:
   ```swift
   #if DEBUG
   self.baseURL = "http://localhost:85/api"
   #else
   self.baseURL = "https://notaspace.ru/api"  // Production
   #endif
   ```

## Шаг 4: Создание Archive (архива)

### 4.1. Выбор устройства

1. В Xcode выберите **"Any iOS Device"** (не симулятор!)
2. Или выберите **"Generic iOS Device"**

### 4.2. Создание архива

1. Меню **Product** → **Archive**
2. Дождитесь завершения компиляции
3. Откроется окно **Organizer** с архивом

### 4.3. Загрузка в App Store Connect

1. В окне **Organizer** выберите ваш архив
2. Нажмите **"Distribute App"**
3. Выберите **"App Store Connect"**
4. Нажмите **"Next"**
5. Выберите **"Upload"**
6. Нажмите **"Next"**
7. Оставьте все опции по умолчанию
8. Нажмите **"Upload"**
9. Дождитесь завершения загрузки (может занять несколько минут)

## Шаг 5: Настройка TestFlight в App Store Connect

### 5.1. Обработка билда

1. Откройте https://appstoreconnect.apple.com
2. Перейдите в ваше приложение **NotaSpace**
3. Вкладка **"TestFlight"**
4. Дождитесь обработки билда (обычно 10-30 минут)
5. Статус изменится на **"Готово к тестированию"**

### 5.2. Настройка информации для тестировщиков

1. В разделе **"TestFlight"** → **"Информация для тестировщиков"**
2. Заполните:
   - **Что нового в этой версии**: описание изменений
   - **Описание**: инструкции для тестировщиков
   - **Ключевые слова**: для поиска

### 5.3. Добавление тестировщиков

#### Внутреннее тестирование (Internal Testing)
- До 100 тестировщиков из вашей команды
- Доступ сразу после обработки билда
- Добавьте членов команды в **"Пользователи и доступ"**

#### Внешнее тестирование (External Testing)
- До 10,000 тестировщиков
- Требуется проверка Apple (1-2 дня)
- Добавьте тестировщиков:
  1. **"Внешнее тестирование"** → **"+"**
  2. Выберите билд
  3. Добавьте email адреса тестировщиков
  4. Отправьте приглашения

## Шаг 6: Установка через TestFlight

### Для тестировщиков:

1. Установите приложение **TestFlight** из App Store (если еще не установлено)
2. Откройте email с приглашением от Apple
3. Нажмите на ссылку в письме
4. Или откройте TestFlight и войдите с Apple ID
5. Нажмите **"Установить"** рядом с NotaSpace
6. Приложение установится на устройство

## Автоматизация через Fastlane (опционально)

Для автоматизации процесса можно использовать Fastlane:

```ruby
# Fastfile
lane :beta do
  increment_build_number
  build_app(scheme: "NotaSpace")
  upload_to_testflight
end
```

Запуск:
```bash
fastlane beta
```

## Обновление версии

При каждом обновлении:

1. Увеличьте **Build** номер в Xcode (General → Build)
2. Обновите **Version** если нужно (например, 1.0 → 1.1)
3. Создайте новый Archive
4. Загрузите в App Store Connect
5. Тестировщики получат уведомление об обновлении

## Важные моменты

### Сертификаты и профили
- Xcode автоматически управляет сертификатами при включенном "Automatically manage signing"
- Если возникают проблемы - проверьте в Keychain Access

### Время обработки
- Первая загрузка: 30-60 минут
- Последующие обновления: 10-30 минут
- Внешнее тестирование: +1-2 дня на проверку Apple

### Ограничения
- Внутреннее тестирование: до 100 человек
- Внешнее тестирование: до 10,000 человек
- Срок действия билда: 90 дней (после этого нужно обновить)

### Отладка
- Если билд не появляется - проверьте email от Apple (могут быть проблемы)
- Проверьте статус в App Store Connect → Activity
- Логи можно посмотреть в Xcode → Window → Organizer

## Полезные ссылки

- App Store Connect: https://appstoreconnect.apple.com
- Apple Developer: https://developer.apple.com
- Документация TestFlight: https://developer.apple.com/testflight/
- Руководство по распространению: https://developer.apple.com/distribute/

## Troubleshooting

### Ошибка "No accounts with App Store Connect access"
- Убедитесь, что вы вошли в Xcode с правильным Apple ID
- Xcode → Settings → Accounts → добавьте Apple ID

### Ошибка "Invalid Bundle"
- Проверьте Bundle Identifier
- Убедитесь, что он совпадает с App Store Connect

### Билд не появляется в TestFlight
- Подождите 30-60 минут
- Проверьте email от Apple (могут быть проблемы с билдом)
- Проверьте статус в App Store Connect → Activity

