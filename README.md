# NovaCoach — Faz 1

Bu paket Codemagic/Xcode için hazırlanmış SwiftUI iOS uygulamasının ilk çalışan fazıdır.

## Faz 1 tamamlananlar
- Çalışan giriş ve kayıt akışı (şimdilik local persistence)
- Tam tıklanabilir onboarding
- YKS ve KPSS Lisans master exam verisi
- Sınav > oturum > ders > konu ağacı
- Hedef, tempo ve koç tarzı seçimi
- Otomatik ilk plan üretimi
- Ana sayfa görevleri ve tamamlanma aksiyonu
- Konu durumları: Başlanmadı / Çalışılıyor / Tekrar Gerekli / Oturdu
- Ders ve genel ilerleme hesapları
- Koç mesajı ve planı yeniden oluşturma
- Profil ve abonelik taslağı
- UserDefaults ile local kalıcılık
- Codemagic için project.yml ve codemagic.yaml

## Mimari
UI: SwiftUI
State: AppStore (ObservableObject)
Master Data: bundled versioned JSON
Persistence Faz 1: UserDefaults JSON
Faz 2 backend abstraction: AuthRepository / UserProgressRepository / ExamCalendarRepository
Abonelik: StoreKit 2 (Faz 2)
Admin: web panel + exam calendar endpoint (Faz 2)

## Veri ayrımı
1. Master data (bizim yönettiğimiz): sınav, oturum, ders, konu, alt konu, öncelik.
2. Güncel data (admin): sınav tarihi, başvuru/sonuç tarihi, duyuru.
3. Kullanıcı data: ilerleme, konu durumu, koç davranışı, plan geçmişi.

## Codemagic
Repository'ye bu klasörü yükle. `codemagic.yaml` XcodeGen kurup `.xcodeproj` üretir.
Signing için Codemagic App Store Connect integration + bundle id `com.novacoach.app` eşleştirilmelidir.

## Not
`exams.json` Faz 1 kapsamıdır. YKS/KPSS konu listeleri ürün master datasının başlangıcıdır; yayın öncesi resmi kılavuz/MEB kapsamıyla sürüm bazlı audit edilmelidir. ÖSYM soru içerikleri uygulamaya dahil edilmez.
