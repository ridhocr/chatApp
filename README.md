# 🗨️ chatApp MST

A cross-platform chat application built with Flutter, designed to run on
**mobile (Android/iOS), tablet, and desktop**.\
The app integrates with **OpenAI API (or compatible AI API)** to provide
intelligent bot responses and supports **image, file, and video
upload**.

------------------------------------------------------------------------

## 📌 Overview

Project ini dibuat sebagai bagian dari *Programmer Practice Test* dari
Mitra Solusi Telematika (MST).\
Tujuan utama aplikasi ini adalah membuat aplikasi chat sederhana namun
fungsional yang dapat berjalan di berbagai platform, dengan fitur
percakapan yang terintegrasi AI.

Mockup dasar dan requirement berasal dari dokumen resmi practice test:

-   Flutter app yang bisa dibuka melalui **handphone, tablet, dan
    desktop**
-   Menggunakan **OpenAI API atau alternatif**
-   Fitur chat dengan upload gambar, file, dan video

------------------------------------------------------------------------

## 🚀 Features

### 🧠 AI Chat Integration

-   Menggunakan **OpenAI API** untuk membalas pesan pengguna.
-   Mendukung *two-way conversation* dengan teks dan media.

### 📱💻 Multi-Platform Support

-   Responsive layout untuk:
    -   Mobile
    -   Tablet
    -   Desktop

### 📤 Upload & Send Media

-   **Image upload**
-   **File upload** (PDF, Docs, ZIP, dll.)
-   **Video upload**
-   Generate **video thumbnail** otomatis (saat ini masih bermasalah untuk upload video)

### 🗂️ Message Threading

-   Bubbles chat kiri--kanan
-   Timestamp menggunakan `intl`

### 🧩 Clean Architecture (Provider)

-   State Management: **Provider**
-   Service layer untuk API
-   Model & helper utilities

------------------------------------------------------------------------

## 🛠️ Tech Stack

### Frontend

-   Flutter SDK (stable)
-   Provider (state management)
-   Responsive UI menggunakan `LayoutBuilder`

### Backend / AI

-   **OpenAI API**

### Packages Used

``` yaml
provider: ^6.1.2
intl: ^0.20.1
dio: ^5.8.0
file_picker: ^10.3.6
image_picker: ^1.0.0
video_thumbnail: ^0.5.3
```

------------------------------------------------------------------------

## ▶️ How to Run

1.  Install dependency:

    ``` bash
    flutter pub get
    ```
2.  Jalankan aplikasi:

    ``` bash
    flutter run
    ```

3.  Untuk desktop:

    ``` bash
    flutter config --enable-windows-desktop
    flutter run -d windows
    ```

------------------------------------------------------------------------

## 📑 Requirements Completed

  Requirement                         Status
  ----------------------------------- --------
  Flutter app mobile/tablet/desktop   ✔️
  Chat interface sesuai mockup        ✔️
  Integrasi AI API                    ✔️
  Upload image/file/video             ✔️
  README lengkap                      ✔️

------------------------------------------------------------------------

## 💼 Author

Developed by **Ridhocr**\
Practice Test -- Mitra Solusi Telematika (MST)
