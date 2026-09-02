import Foundation

struct PlanningEngine {
    static func generate(exam: Exam, profile: UserProfile, progress: [String: TopicProgress], existing: [StudyTask]) -> [StudyTask] {
        let today = Calendar.current.startOfDay(for: Date())
        let all = exam.sessions.flatMap(\.subjects).flatMap { subject in subject.topics.map { (subject, $0) } }
        let dueReviews = all.filter { pair in
            guard let p = progress[pair.1.id] else { return false }
            return p.state == .review || (p.nextReviewAt.map { $0 <= Date() } ?? false)
        }
        let pending = all.filter { pair in
            let state = progress[pair.1.id]?.state ?? .notStarted
            return state == .notStarted || state == .studying
        }.sorted { lhs, rhs in lhs.1.priority > rhs.1.priority }

        let dailyCount = profile.pace == "Yoğun" ? 5 : profile.pace == "Hafif" ? 2 : 3
        var selected: [(Subject, Topic, StudyTaskKind)] = dueReviews.prefix(max(1, dailyCount / 2)).map { ($0.0, $0.1, .review) }
        let slots = max(0, dailyCount - selected.count)
        selected.append(contentsOf: pending.prefix(slots).map { ($0.0, $0.1, .study) })

        return selected.enumerated().map { idx, item in
            StudyTask(id: UUID(), examId: exam.id, subjectId: item.0.id, topicId: item.1.id, title: item.1.name, subjectName: item.0.name, kind: item.2, scheduledDate: Calendar.current.date(byAdding: .day, value: idx / dailyCount, to: today) ?? today, isDone: false)
        }
    }

    static func nextReviewDate(difficulty: TopicDifficulty, reviewCount: Int, from date: Date = Date()) -> Date {
        let base = difficulty == .hard ? [1, 3, 7, 14, 30] : difficulty == .easy ? [3, 10, 30, 60, 90] : [2, 7, 21, 45, 90]
        let day = base[min(reviewCount, base.count - 1)]
        return Calendar.current.date(byAdding: .day, value: day, to: date) ?? date
    }
}
