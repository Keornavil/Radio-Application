# Radio Application on MVP

Мобильное приложение на UIKit для прослушивания интернет‑радиостанций.  
Состоит из 2 экранов: список станций и экран `Now Playing` с данными о треке.  
При запуске проверяет сеть, загружает список станций из JSON и изображения станций.

## Технологии
Компонент: Используется
UI: UIKit
Архитектура: MVP
Сеть: Alamofire
Изображения: Kingfisher
Аудиоплеер: FRadioPlayer
Системный плеер: AVAudioSession + Now Playing Info Center + Remote Command Center
Целевая платформа: iOS 18+

## Основной функционал
Станции:
- загрузка списка станций из удаленного JSON
- отображение станций в `UITableView`
- параллельная загрузка изображений станций

Воспроизведение:
- запуск/пауза радио
- мини‑плеер на главном экране
- переход на экран `Now Playing`

Now Playing / локскрин:
- показ `artist`, `track`, `station`, `artwork` в Control Center и на экране блокировки
- обработка команд гарнитуры и системных кнопок `Play/Pause/Toggle`

Сеть:
- проверка доступности сети при запуске
- показ `Alert` при отсутствии интернета

## Структура проекта
- `Radio Application on MVP/StationsViewModule` — главный экран со списком станций
- `Radio Application on MVP/NowPlayingViewModule` — экран текущего трека
- `Radio Application on MVP/Model` — модели и загрузка данных станций
- `Radio Application on MVP/ServiceLayer` — плеер, делегаты, сеть, загрузка изображений
- `Radio Application on MVP/Routing` — роутер и сборка модулей
- `Radio Application on MVPTests` — юнит‑тесты
- `Images` — скриншоты для README

## Скриншоты
![Alert при отсутствии сети](../Images/Alert.png)
![Индикатор загрузки](../Images/ActivityIndicator.png)
![Список станций](../Images/StationList.png)
![Мини-плеер](../Images/PlayerView.png)
![Экран Now Playing](../Images/NowPlayingView.png)
![Now Playing на локскрине](../Images/PlayerLockScreen.jpg)

## Как запустить
1. Открой `Radio Application on MVP.xcodeproj` в Xcode.
2. Выбери симулятор или устройство с iOS 18+.
3. Нажми Run.

## Тесты
В Xcode: `Cmd+U`  
Через CLI (пример):  
`xcodebuild test -project "Radio Application on MVP.xcodeproj" -scheme "Radio Application on MVP" -destination "platform=iOS Simulator,OS=18.6,name=iPhone 15 Pro"`
