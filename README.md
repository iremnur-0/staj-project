# 📱 Staj Projesi – Flutter Mobil Uygulama

Merhaba! Ben İrem. Bu repo, Flutter kullanarak gerçekleştirdiğim staj projemin kaynak kodlarını içermektedir. Bu proje sayesinde hem Firebase entegrasyonu hem de kullanıcı arayüzü geliştirme konularında deneyim kazandım.

## 🔍 Proje Özeti

Uygulama, kullanıcıların:
- Firebase Authentication ile giriş yapabilmesini,
- Gerçek zamanlı veri akışı sağlayan Firebase Database & Firestore bağlantılarını,
- Grafikler (fl_chart) üzerinden verileri görselleştirebilmesini,
- Firebase Storage üzerinden medya dosyalarını yönetmesini,
- Video oynatma (video_player) özelliklerini kullanabilmesini sağlar.

## 🚀 Kullanılan Teknolojiler ve Paketler

| Paket | Açıklama |
|-------|----------|
| `flutter` | Mobil uygulama çatısı |
| `video_player` | Uygulama içinde video oynatma |
| `firebase_core`, `firebase_auth`, `firebase_database`, `cloud_firestore`, `firebase_storage` | Firebase servisleriyle tam entegrasyon |
| `fl_chart` | Grafik ve veri görselleştirme |
| `intl` | Tarih/saat ve çoklu dil desteği |
| `provider` | State management (durum yönetimi) |
| `cupertino_icons` | iOS tarzı simgeler |

## 📸 Ekran Görüntüleri

> **Not**: Ekran görüntüleri `assets/images/` klasöründe yer alıyor. Örneğin:
> ![Uygulama Arka Plan](assets/images/background.jpg)

## 🛠️ Kurulum Talimatları

Projeyi çalıştırmak için aşağıdaki adımları takip edebilirsiniz:

1. Depoyu klonlayın:
   ```bash
   git clone https://github.com/kullaniciadi/my_new_project.git
   cd my_new_project
