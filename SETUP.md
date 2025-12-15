# Инструкция по настройке iOS проекта

## Быстрый старт

### Вариант 1: Открыть существующий проект

1. Откройте Xcode
2. File → Open → выберите `NotaSpace.xcodeproj`
3. Если Xcode показывает ошибки о недостающих файлах:
   - File → Add Files to "NotaSpace"
   - Выберите папку `NotaSpace/Sources`
   - Убедитесь, что выбрана опция "Create groups" (не "Create folder references")
   - Нажмите "Add"

### Вариант 2: Создать новый проект и скопировать файлы

Если проект не открывается корректно:

1. Создайте новый проект в Xcode:
   - File → New → Project
   - Выберите "iOS" → "App"
   - Product Name: `NotaSpace`
   - Interface: `SwiftUI`
   - Language: `Swift`
   - Minimum Deployment: `iOS 15.0`

2. Удалите автоматически созданные файлы:
   - `ContentView.swift` (мы создали свой)
   - `NotaSpaceApp.swift` (мы создали свой)

3. Скопируйте файлы из `NotaSpace/Sources` в новый проект:
   - Перетащите папки `Models`, `ViewModels`, `Views`, `Network`, `Services` в проект
   - Убедитесь, что файлы добавлены в target "NotaSpace"

4. Скопируйте `Info.plist`:
   - Замените автоматически созданный `Info.plist` нашим из `NotaSpace/Resources/Info.plist`

5. Настройте Bundle Identifier:
   - Выберите target "NotaSpace"
   - В разделе "Signing & Capabilities" настройте ваш Team
   - Bundle Identifier: `ru.notaspace.app` (или свой)

## Настройка проекта

### 1. Bundle Identifier и Signing

1. Выберите проект в навигаторе
2. Выберите target "NotaSpace"
3. Перейдите на вкладку "Signing & Capabilities"
4. Выберите ваш Team
5. Убедитесь, что Bundle Identifier: `ru.notaspace.app`

### 2. API Endpoint

По умолчанию используется:
- **Debug**: `http://localhost:85/api`
- **Release**: `https://notaspace.ru/api`

Для изменения откройте `Sources/Network/APIClient.swift` и измените `baseURL`.

### 3. App Transport Security

Для работы с localhost в Debug режиме уже настроен App Transport Security в `Info.plist`.

Если нужно добавить другие домены, откройте `Info.plist` и добавьте их в секцию `NSAppTransportSecurity` → `NSExceptionDomains`.

## Запуск приложения

1. Выберите симулятор или подключенное устройство
2. Нажмите ⌘R или кнопку "Run"
3. Приложение должно запуститься и показать экран входа

## Проверка работы

1. Убедитесь, что веб-сервер запущен и доступен по адресу `http://localhost:85`
2. Попробуйте войти с существующими учетными данными
3. Проверьте, что токен сохраняется и используется для последующих запросов

## Известные проблемы

- Если проект не компилируется, убедитесь, что все файлы добавлены в target
- Если возникают ошибки импорта, проверьте, что структура папок правильная
- Для работы с localhost на реальном устройстве используйте IP-адрес компьютера вместо `localhost`

## Следующие шаги

После успешного запуска можно приступать к:
1. Интеграции с API endpoints для страниц
2. Реализации работы с задачами
3. Добавлению WebSocket для real-time обновлений

