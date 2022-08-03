# Stack
* **Architecture**: Clean Archirecture
* **State management**: Provider
* **DI**: get_it
* **Remote communications**: FirebaseSDK(firebase_core, cloud_firestore, firebase_auth, firebase_storage, cloud_functions), http, dio
* **Local storage**: sembast
* **Other**: image/video/file pickers, chewie(play video), qr_code_scanner, overlay_support, webview_flutter

# Description

* Приложения (**Chromatec Service** и **Chromatec Admin**) находятся в одном монорепозитории и используют общий код из директории **core**(общие сервисы, модели, виджеты и т.п.).
* Оба приложения делятся на фичи, каждая из которых включает в себя один или несколько экранов; Каждая фича имеет свой слой **domain** и **repository**
* **Сервисы**(Pickers, Snackbars, Connection check, Permissions и т.п.) вынесены в отдельную директорию
