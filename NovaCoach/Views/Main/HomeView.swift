import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    BrandHeader("Merhaba, \(store.profile.name)", subtitle: store.selectedExam?.name ?? "Sınav seçilmedi")

                    HStack(spacing: 12) {
                        MetricCard(title: "İlerleme", value: "%\(Int(store.overallProgress * 100))", icon: "chart.line.uptrend.xyaxis")
                        MetricCard(title: "Bugün", value: "\(store.todayTasks.filter(\.isDone).count)/\(store.todayTasks.count)", icon: "checkmark.circle")
                    }

                    GroupBox {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Koç notu", systemImage: "sparkles").font(.headline)
                            Text(store.coachMessage()).foregroundStyle(.secondary)
                            NavigationLink("Koça git") { CoachView() }
                        }.frame(maxWidth: .infinity, alignment: .leading)
                    }

                    HStack {
                        Text("Bugünün planı").font(.title2.bold())
                        Spacer()
                        Button("Yenile") { store.generatePlan() }
                    }

                    if store.todayTasks.isEmpty {
                        ContentUnavailableView("Bugün görev yok", systemImage: "calendar.badge.plus", description: Text("Planı yenileyerek devam edebilirsin."))
                    } else {
                        ForEach(store.todayTasks) { task in
                            Button { store.toggleTask(task) } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                                        .font(.title3)
                                        .foregroundStyle(task.isDone ? .green : .secondary)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(task.title).font(.headline).foregroundStyle(.primary)
                                        Text("\(task.subjectName) · \(task.kind.rawValue)").font(.caption).foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                }
                                .padding()
                                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 18))
                            }.buttonStyle(.plain)
                        }
                    }

                    NavigationLink { WeeklyReviewView() } label: {
                        Label("Haftalık koç analizini aç", systemImage: "chart.xyaxis.line")
                            .frame(maxWidth: .infinity)
                            .padding()
                    }.buttonStyle(.bordered)
                }.padding()
            }
            .navigationTitle("NovaCoach")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct WeeklyReviewView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        List(store.weeklyInsights()) { insight in
            Label {
                VStack(alignment: .leading) {
                    Text(insight.title).font(.headline)
                    Text(insight.detail).foregroundStyle(.secondary)
                }
            } icon: {
                Image(systemName: insight.systemImage)
            }
        }
        .navigationTitle("Haftalık Analiz")
    }
}
