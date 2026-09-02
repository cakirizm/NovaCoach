import SwiftUI

struct PlanView: View {
    @EnvironmentObject var store: AppStore
    @State private var selectedSegment = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Picker("Plan", selection: $selectedSegment) {
                    Text("Bugün").tag(0)
                    Text("Dersler").tag(1)
                    Text("Tekrar").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                if selectedSegment == 0 { today }
                else if selectedSegment == 1 { curriculum }
                else { reviews }
            }
            .navigationTitle("Planım")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { store.generatePlan() } label: { Image(systemName: "arrow.clockwise") }
                }
            }
        }
    }

    private var today: some View {
        List {
            ForEach(store.todayTasks) { task in
                Button { store.toggleTask(task) } label: {
                    HStack {
                        Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                        VStack(alignment: .leading) {
                            Text(task.title)
                            Text(task.subjectName).font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(task.kind.rawValue).font(.caption)
                    }
                }.foregroundStyle(.primary)
            }
        }
    }

    private var curriculum: some View {
        List {
            if let exam = store.selectedExam {
                ForEach(exam.sessions) { session in
                    Section(session.name) {
                        ForEach(session.subjects) { subject in
                            NavigationLink { TopicListView(subject: subject) } label: {
                                VStack(alignment: .leading, spacing: 7) {
                                    HStack {
                                        Text(subject.name).font(.headline)
                                        Spacer()
                                        Text("%\(Int(store.subjectProgress(subject) * 100))")
                                    }
                                    ProgressBar(value: store.subjectProgress(subject))
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private var reviews: some View {
        List {
            let items = store.selectedExam?.sessions.flatMap(\.subjects).flatMap(\.topics).filter { topic in
                let p = store.progress[topic.id]
                return p?.state == .review || (p?.nextReviewAt.map { $0 <= Date() } ?? false)
            } ?? []

            if items.isEmpty {
                Text("Şu an tekrar kuyruğunda konu yok.").foregroundStyle(.secondary)
            }

            ForEach(items) { topic in
                NavigationLink(topic.name) { TopicDetailView(topic: topic) }
            }
        }
    }
}

struct TopicListView: View {
    @EnvironmentObject var store: AppStore
    let subject: Subject

    var body: some View {
        List(subject.topics) { topic in
            NavigationLink { TopicDetailView(topic: topic) } label: {
                HStack {
                    VStack(alignment: .leading) {
                        Text(topic.name)
                        Text("Öncelik \(topic.priority)").font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(store.progress[topic.id]?.state.rawValue ?? TopicState.notStarted.rawValue).font(.caption)
                }
            }
        }
        .navigationTitle(subject.name)
    }
}

struct TopicDetailView: View {
    @EnvironmentObject var store: AppStore
    let topic: Topic

    var body: some View {
        Form {
            Section("Konu") {
                LabeledContent("Ad", value: topic.name)
                LabeledContent("Öncelik", value: "\(topic.priority)")
            }

            Section("Durum") {
                ForEach(TopicState.allCases) { state in
                    Button { store.markTopic(topic.id, state: state) } label: {
                        HStack {
                            Text(state.rawValue)
                            Spacer()
                            if store.progress[topic.id]?.state == state { Image(systemName: "checkmark") }
                        }
                    }
                }
            }

            Section("Zorluk") {
                ForEach(TopicDifficulty.allCases) { difficulty in
                    Button {
                        store.markTopic(topic.id, state: store.progress[topic.id]?.state ?? .studying, difficulty: difficulty)
                    } label: {
                        HStack {
                            Text(difficulty.label)
                            Spacer()
                            if store.progress[topic.id]?.difficulty == difficulty { Image(systemName: "checkmark") }
                        }
                    }
                }
            }

            if let next = store.progress[topic.id]?.nextReviewAt {
                Section("Tekrar") {
                    LabeledContent("Sonraki tekrar", value: next.formatted(date: .abbreviated, time: .omitted))
                }
            }
        }
        .navigationTitle(topic.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
