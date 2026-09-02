import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var store: AppStore
    @State private var showExamPicker = false
    @State private var showSubscription = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Hesap") {
                    LabeledContent("Ad", value: store.profile.name)
                    LabeledContent("E-posta", value: store.profile.email)
                }

                Section("Hazırlık") {
                    Button { showExamPicker = true } label: {
                        LabeledContent("Sınav", value: store.selectedExam?.shortName ?? "Seçilmedi")
                    }
                    TextField("Hedef", text: $store.profile.targetLabel)
                    Picker("Tempo", selection: $store.profile.pace) {
                        Text("Hafif").tag("Hafif")
                        Text("Dengeli").tag("Dengeli")
                        Text("Yoğun").tag("Yoğun")
                    }
                    Picker("Koç tarzı", selection: $store.profile.coachStyle) {
                        Text("Destekleyici").tag("Destekleyici")
                        Text("Dengeli").tag("Dengeli")
                        Text("Disiplinli").tag("Disiplinli")
                    }
                    DatePicker("Sınav tarihi", selection: Binding(get: {
                        store.profile.examDate ?? Calendar.current.date(byAdding: .month, value: 6, to: Date())!
                    }, set: { store.profile.examDate = $0 }), displayedComponents: .date)
                }

                Section("Üyelik") {
                    Button("Premium planları gör") { showSubscription = true }
                }

                Section("Sistem") {
                    NavigationLink("Haftalık analiz") { WeeklyReviewView() }
                    Button("Planı yeniden oluştur") { store.generatePlan() }
                }

                Section {
                    Button("Çıkış Yap", role: .destructive) { store.logout() }
                }
            }
            .navigationTitle("Profil")
            .sheet(isPresented: $showExamPicker) { ExamPickerSheet() }
            .sheet(isPresented: $showSubscription) { SubscriptionView() }
        }
    }
}

struct ExamPickerSheet: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List(store.exams) { exam in
                Button {
                    store.selectExam(exam)
                    store.generatePlan()
                    dismiss()
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(exam.shortName).bold()
                            Text(exam.name).font(.caption)
                        }
                        Spacer()
                        if store.profile.selectedExamId == exam.id { Image(systemName: "checkmark.circle.fill") }
                    }
                }
            }
            .navigationTitle("Sınav Seç")
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Kapat") { dismiss() } } }
        }
    }
}

struct SubscriptionView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    BrandHeader("NovaCoach Premium", subtitle: "Dinamik yeniden planlama, gelişmiş koç analizi ve tekrar yönetimi.")
                    PlanOption(title: "Aylık", detail: "StoreKit ürünü bağlandığında aktif olacak")
                    PlanOption(title: "Yıllık", detail: "StoreKit ürünü bağlandığında aktif olacak")
                    Text("Bu ekranda sahte satın alma yapılmaz. App Store Connect ürün kimlikleri tanımlandıktan sonra StoreKit 2 bağlanacak.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }.padding()
            }
            .navigationTitle("Üyelik")
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Kapat") { dismiss() } } }
        }
    }
}

struct PlanOption: View {
    let title: String
    let detail: String
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.title3.bold())
            Text(detail).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 18))
    }
}
