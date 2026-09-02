import SwiftUI

struct ProgressViewScreen: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    BrandHeader("İlerleme", subtitle: "Tamamlama ile hazır olma durumunu konu hareketlerinden hesaplıyoruz.")
                    VStack(spacing: 8) {
                        Text("%\(Int(store.overallProgress * 100))").font(.system(size: 54, weight: .bold, design: .rounded))
                        Text("Genel müfredat ilerlemesi").foregroundStyle(.secondary)
                        ProgressBar(value: store.overallProgress)
                    }
                    .padding(24)
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 20))

                    if let exam = store.selectedExam {
                        ForEach(exam.sessions.flatMap(\.subjects)) { subject in
                            NavigationLink { TopicListView(subject: subject) } label: {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(subject.name).bold()
                                        Spacer()
                                        Text("%\(Int(store.subjectProgress(subject) * 100))")
                                    }
                                    ProgressBar(value: store.subjectProgress(subject))
                                }
                                .padding()
                                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(.primary)
                        }
                    }

                    NavigationLink("Haftalık analizi görüntüle") { WeeklyReviewView() }
                        .buttonStyle(.borderedProminent)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
