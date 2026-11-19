# KomByd iOS (Komunikacja Bydgoszcz)

Natywna aplikacja na iOS (iPhone) dla komunikacji miejskiej w Bydgoszczy (ZDMiKP).
Aplikacja została przygotowana na podstawie analizy parametrów i protokołów z oryginalnej aplikacji KomByd na Androida.

## 🚀 Jak skompilować plik .IPA przez GitHub Actions:

1. **Создайте новый репозиторий на GitHub:**
   * Зайдите на [github.com](https://github.com) и создайте **Public** или **Private** репозиторий (например, `KomByd-iOS`).
2. **Загрузите все файлы из этой папки в репозиторий:**
   * Убедитесь, что папка `.github/workflows/build.yml` также загружена.
3. **Запустите автоматическую сборку:**
   * Как только файлы будут отправлены в репозиторий, перейдите во вкладку **Actions** в вашем репозитории на GitHub.
   * Вы увидите запущенный воркфлоу **"Build KomByd iOS IPA"**.
   * GitHub запустит виртуальную машину с macOS и Xcode, скомпилирует приложение и упакует его в файл `KomByd.ipa`.
4. **Скачайте готовый .IPA:**
   * Когда сборка завершится зеленой галочкой, откройте её и внизу в разделе **Artifacts** нажмите на **KomByd-iOS-IPA**.
   * Скачается архив с готовым файлом `KomByd.ipa`.
5. **Установите на iPhone:**
   * Установите полученный `.ipa` через бесплатную утилиту **Sideloadly**, **AltStore**, **Scarlet** или **TrollStore**.

---

## 📱 Funkcje aplikacji (Features):
* **Przystanki i wyszukiwarka:** Baza ponad 1200 przystanków ZDMiKP Bydgoszcz.
* **Odjazdy na żywo (live GPS):** Rzeczywisty czas odjazdu z minutami i pozycjonowaniem pojazdów.
* **Ulubione:** Dodawanie najczęściej używanych przystanków do szybkiego dostępu (gwiazdka).
* **Linie:** Rozpiska wszystkich linii tramwajowych, autobusowych dziennych i nocnych wraz z przystankami.
* **Komunikaty:** Najświeższe ogłoszenia i zmiany tras z ZDMiKP.
