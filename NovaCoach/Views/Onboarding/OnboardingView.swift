import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var store: AppStore
    @State private var step = 0
    @State private var target = ""
    @State private var pace = "Dengeli"
    @State private var coachStyle = "Dengeli"

    var body: some View {
        NavigationStack {
            VStack(spacing: 22) {
                ProgressView(value: Double(step + 1), total: 4).padding(.horizontal)
                if step == 0 { welcome }
                else if step == 1 { examStep }
                else if step == 2 { targetStep }
                else { coachStep }
                Spacer()
                Button(step == 3 ? "Planımı Oluştur" : "Devam") {
                    if step < 3 { step += 1 }
                    else {
                        store.profile.targetLabel = target
                        store.profile.pace = pace
                        store.profile.coachStyle = coachStyle
                        store.completeOnboarding()
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(step == 1 && store.profile.selectedExamId == nil)
                .padding()
            }.padding(.top)
        }
    }

    private var welcome: some View {
        VStack(spacing: 16) {
            Image(systemName: "brain.head.profile").font(.system(size: 74)).foregroundStyle(.tint)
            Text("Kendi sınav koçunu kur").font(.largeTitle.bold()).multilineTextAlignment(.center)
            Text("Soru bankası değil. Müfredatı, planı, tekrarları ve ilerlemeyi yöneten bir sistem.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }

    private var examStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                BrandHeader("Hangi sınava hazırlanıyorsun?", subtitle: "YKS ve KPSS aileleriyle başlıyoruz.")
                ForEach(store.exams) { exam in
                    Button { store.selectExam(exam) } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(exam.shortName).font(.headline)
                                Text(exam.name).font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            if store.profile.selectedExamId == exam.id { Image(systemName: "checkmark.circle.fill").foregroundStyle(.tint) }
                        }
                        .padding()
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    }.buttonStyle(.plain)
                }
            }.padding(.horizontal)
        }
    }

    private var targetStep: some View {
        VStack(alignment: .leading, spacing: 18) {
            BrandHeader("Hedefini tanımla", subtitle: "Dakika değil, hedef ve tempo bazlı planlayacağız.")
            TextField("Örn. KPSS 85+ / YKS Sayısal 50K", text: $target).textFieldStyle(.roundedBorder)
            Picker("Tempo", selection: $pace) {
                Text("Hafif").tag("Hafif")
                Text("Dengeli").tag("Dengeli")
                Text("Yoğun").tag("Yoğun")
            }.pickerStyle(.segmented)
        }.padding(.horizontal)
    }

    private var coachStep: some View {
        VStack(alignment: .leading, spacing: 18) {
            BrandHeader("Koçunun tarzı", subtitle: "Algoritma aynı; iletişim dili değişir.")
            Picker("Koç", selection: $coachStyle) {
                Text("Destekleyici").tag("Destekleyici")
                Text("Dengeli").tag("Dengeli")
                Text("Disiplinli").tag("Disiplinli")
            }.pickerStyle(.segmented)
            Text("Koç planı gerektiğinde yeniden kuracak; yalnızca mesaj vermeyecek.").foregroundStyle(.secondary)
        }.padding(.horizontal)
    }
}
