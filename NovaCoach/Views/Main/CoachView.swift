import SwiftUI

struct CoachView: View {
    @EnvironmentObject var store: AppStore
    @State private var input = ""
    @State private var lastResponse = ""
    private let quickInputs = ["Bu hafta çok yoğunum", "Matematikte zorlanıyorum", "Geride kaldım, hızlanalım"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        BrandHeader("Dijital Koç", subtitle: "Sadece cevap vermez; söylediklerini plan motoruna uygular.")
                        CoachBubble(text: store.coachMessage(), isCoach: true)
                        ForEach(store.coachActions.prefix(8)) { action in
                            CoachBubble(text: action.input, isCoach: false)
                            CoachBubble(text: action.summary, isCoach: true)
                        }
                        if !lastResponse.isEmpty { CoachBubble(text: lastResponse, isCoach: true) }
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(quickInputs, id: \.self) { value in
                                    Button(value) { input = value; send() }.buttonStyle(.bordered)
                                }
                            }
                        }
                    }.padding()
                }
                HStack {
                    TextField("Koçuna yaz...", text: $input, axis: .vertical).textFieldStyle(.roundedBorder)
                    Button { send() } label: { Image(systemName: "arrow.up.circle.fill").font(.title) }
                        .disabled(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }.padding()
            }
            .navigationTitle("Koç")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func send() {
        let value = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { return }
        lastResponse = store.applyCoachInput(value)
        input = ""
    }
}

struct CoachBubble: View {
    let text: String
    let isCoach: Bool
    var body: some View {
        HStack {
            if !isCoach { Spacer() }
            Text(text)
                .padding(12)
                .background(isCoach ? Color(.secondarySystemBackground) : Color.accentColor.opacity(0.16), in: RoundedRectangle(cornerRadius: 16))
            if isCoach { Spacer() }
        }
    }
}
