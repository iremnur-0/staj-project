# Kişisel Finans Uygulaması – Flutter Mobil Uygulama

Merhaba! Ben İrem. Bu repo, Flutter kullanarak gerçekleştirdiğim staj projemin kaynak kodlarını içermektedir. Bu proje sayesinde hem Firebase entegrasyonu hem de kullanıcı arayüzü geliştirme konularında deneyim kazandım.

## Proje Özeti

Uygulama, kullanıcıların:
- Firebase Authentication ile giriş yapabilmesini,
- Gerçek zamanlı veri akışı sağlayan Firebase Database & Firestore bağlantılarını,
- Grafikler (fl_chart) üzerinden verileri görselleştirebilmesini,
- Firebase Storage üzerinden medya dosyalarını yönetmesini,
- Gelir ve Giderlerin kategorik olarak ayrılması
- Kullanıcıların kendilerine hedef belirleyelme ve takip edebilmesi 

## Kullanılan Teknolojiler ve Paketler

| Paket | Açıklama |
|-------|----------|
| `flutter` | Mobil uygulama çatısı |
| `video_player` | Uygulama içinde video oynatma |
| `firebase_core`, `firebase_auth`, `firebase_database`, `cloud_firestore`, `firebase_storage` | Firebase servisleriyle tam entegrasyon |
| `fl_chart` | Grafik ve veri görselleştirme |
| `intl` | Tarih/saat ve çoklu dil desteği |
| `provider` | State management (durum yönetimi) |
| `cupertino_icons` | iOS tarzı simgeler |

## Ekran Videosu

Projeme ait videoyu aşağıdaki linkten izleyebilirsiniz.

https://drive.google.com/file/d/1MvOhnQ07boMed_GrqsFnwoC4yjH7AJwj/view?usp=sharing

## Kurulum Talimatları

Projeyi çalıştırmak için aşağıdaki adımları takip edebilirsiniz:

1. Depoyu klonlayın:
   ```bash
   git clone https://github.com/kullaniciadi/my_new_project.git
   cd my_new_project
