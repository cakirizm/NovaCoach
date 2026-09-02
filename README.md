# NovaCoach — iOS Faz 2

NovaCoach, soru çözdürmek yerine öğrencinin çalışma sürecini yöneten SwiftUI tabanlı dijital sınav koçudur.

## Faz 2 kapsamı
- Gerçek çalışan kayıt / giriş / çıkış / şifre yenileme akışı
- Hesap bilgilerini iOS Keychain'de SHA-256 + salt ile saklama
- Kullanıcı bazlı ilerleme ve plan kalıcılığı
- YKS, KPSS Lisans, KPSS Ön Lisans, KPSS Ortaöğretim master data başlangıcı
- Sınav > oturum > ders > konu navigasyonu
- Konu durumu + zorluk seçimi
- Dinamik plan motoru
- Zorluğa göre tekrar tarihleri
- Günlük görev tamamlama ve ilerlemeye gerçek yansıma
- Dijital koçun kullanıcı girdisine göre plan temposunu değiştirmesi
- Haftalık analiz
- Profil, sınav değiştirme, hedef, tempo, koç stili ve sınav tarihi
- Premium ekranı (sahte satın alma yok; StoreKit ürünleri bağlanmayı bekliyor)
- Codemagic iOS simulator QA gate + archive workflow

## Önemli
Bu fazdaki hesap sistemi gerçek ve cihaz üzerinde çalışır; kullanıcı kayıt olur, çıkış yapar ve aynı bilgilerle tekrar giriş yapabilir. Henüz cloud backend olmadığı için hesap/ilerleme farklı cihazlar arasında senkronize olmaz. Backend bağlandığında CredentialStore ve persistence katmanı cloud servise taşınacaktır.

## Build
Codemagic `xcodegen generate` ile `NovaCoach.xcodeproj` üretir. Bundle ID: `com.novacoach.app`.

## Veri yaklaşımı
Master konu taksonomisi ürün verisidir ve sürümlenir. Sınav/başvuru/sonuç tarihleri admin tarafından yönetilecek ayrı güncel veri katmanına taşınacaktır. Yayın öncesi her sınav yılı için kapsam audit'i yapılmalıdır.
