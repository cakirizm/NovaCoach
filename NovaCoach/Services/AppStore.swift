import Foundation
import SwiftUI

@MainActor
final class AppStore: ObservableObject {
    @Published var isLoggedIn = false
    @Published var onboardingCompleted = false
    @Published var profile = UserProfile()
    @Published var exams: [Exam] = []
    @Published var progress: [String: TopicProgress] = [:]
    @Published var tasks: [StudyTask] = []
    @Published var coachActions: [CoachAction] = []
    @Published var authError: String?

    private let defaults = UserDefaults.standard
    private let credentials = CredentialStore.shared

    init() {
        exams = ExamRepository.shared.loadExams()
        restoreSession()
    }

    var selectedExam: Exam? { exams.first { $0.id == profile.selectedExamId } }
    var todayTasks: [StudyTask] {
        let cal = Calendar.current
        return tasks.filter { cal.isDateInToday($0.scheduledDate) || (!$0.isDone && $0.scheduledDate < Date()) }
    }

    var overallProgress: Double {
        guard let exam = selectedExam else { return 0 }
        let topics = exam.sessions.flatMap(\.subjects).flatMap(\.topics)
        guard !topics.isEmpty else { return 0 }
        let points = topics.reduce(0.0) { partial, topic in
            switch progress[topic.id]?.state ?? .notStarted {
            case .notStarted: return partial
            case .studying: return partial + 0.25
            case .review: return partial + 0.65
            case .mastered: return partial + 1
            }
        }
        return points / Double(topics.count)
    }

    func register(name: String, email: String, password: String) {
        do {
            let account = try credentials.register(name: name, email: email, password: password)
            profile.name = account.displayName
            profile.email = account.email
            isLoggedIn = true
            onboardingCompleted = false
            authError = nil
            persist()
        } catch { authError = error.localizedDescription }
    }

    func login(email: String, password: String) {
        do {
            let account = try credentials.login(email: email, password: password)
            loadUserData(email: account.email)
            profile.name = account.displayName
            profile.email = account.email
            isLoggedIn = true
            authError = nil
            persist()
        } catch { authError = error.localizedDescription }
    }

    func resetPassword(email: String, newPassword: String) {
        do { try credentials.resetPassword(email: email, newPassword: newPassword); authError = nil }
        catch { authError = error.localizedDescription }
    }

    func logout() {
        persist()
        isLoggedIn = false
        defaults.removeObject(forKey: "nova.currentUser")
    }

    func selectExam(_ exam: Exam) { profile.selectedExamId = exam.id; persist() }

    func completeOnboarding() {
        onboardingCompleted = true
        seedProgressIfNeeded()
        generatePlan()
        persist()
    }

    func generatePlan() {
        guard let exam = selectedExam else { return }
        tasks = PlanningEngine.generate(exam: exam, profile: profile, progress: progress, existing: tasks)
        persist()
    }

    func toggleTask(_ task: StudyTask) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index].isDone.toggle()
        if tasks[index].isDone {
            let current = progress[task.topicId] ?? TopicProgress(id: task.topicId, state: .notStarted, difficulty: .normal, lastStudiedAt: nil, reviewCount: 0, nextReviewAt: nil)
            let reviewCount = current.reviewCount + (task.kind == .review ? 1 : 0)
            let next = PlanningEngine.nextReviewDate(difficulty: current.difficulty, reviewCount: reviewCount)
            progress[task.topicId] = TopicProgress(id: task.topicId, state: task.kind == .review && reviewCount >= 2 ? .mastered : .review, difficulty: current.difficulty, lastStudiedAt: Date(), reviewCount: reviewCount, nextReviewAt: next)
        }
        persist()
    }

    func markTopic(_ topicId: String, state: TopicState, difficulty: TopicDifficulty? = nil) {
        var item = progress[topicId] ?? TopicProgress(id: topicId, state: .notStarted, difficulty: .normal, lastStudiedAt: nil, reviewCount: 0, nextReviewAt: nil)
        item.state = state
        if let difficulty { item.difficulty = difficulty }
        if state != .notStarted { item.lastStudiedAt = Date() }
        if state == .review { item.nextReviewAt = PlanningEngine.nextReviewDate(difficulty: item.difficulty, reviewCount: item.reviewCount) }
        progress[topicId] = item
        persist()
    }

    func subjectProgress(_ subject: Subject) -> Double {
        guard !subject.topics.isEmpty else { return 0 }
        return subject.topics.reduce(0.0) { result, topic in
            switch progress[topic.id]?.state ?? .notStarted {
            case .notStarted: return result
            case .studying: return result + 0.25
            case .review: return result + 0.65
            case .mastered: return result + 1
            }
        } / Double(subject.topics.count)
    }

    func applyCoachInput(_ input: String) -> String {
        let normalized = input.lowercased()
        var summary = "Planın mevcut tempona göre yeniden dengelendi."
        if normalized.contains("yoğun") || normalized.contains("vaktim yok") || normalized.contains("meşgul") {
            profile.pace = "Hafif"
            profile.weeklyBusy = true
            summary = "Bu haftayı hafiflettim; tekrarları koruyup yeni konu sayısını azalttım."
        } else if normalized.contains("zor") || normalized.contains("matematik") {
            profile.pace = profile.pace == "Yoğun" ? "Dengeli" : profile.pace
            summary = "Zorlandığın konular için tekrar ağırlığını artırdım ve sırayı yumuşattım."
        } else if normalized.contains("hız") || normalized.contains("geride") {
            profile.pace = "Yoğun"
            summary = "Yetişme riskini azaltmak için tempoyu yükselttim."
        }
        coachActions.insert(CoachAction(id: UUID(), createdAt: Date(), input: input, summary: summary), at: 0)
        generatePlan()
        persist()
        return summary
    }

    func coachMessage() -> String {
        if todayTasks.isEmpty { return "Bugün için planın boş. Planı yenileyerek yeni görevleri çıkarabilirsin." }
        let done = todayTasks.filter(\.isDone).count
        if done == todayTasks.count { return "Bugünkü plan tamamlandı. Bir sonraki adım tekrar takvimini korumak." }
        if overallProgress < 0.15 { return "Temel aşamadasın. Önceliğimiz düzen kurmak ve yüksek öncelikli konuları sırayla bitirmek." }
        return "Bugün \(todayTasks.count - done) görevin kaldı. Plan, mevcut ilerleme ve tekrar tarihlerine göre otomatik dengeleniyor."
    }

    func weeklyInsights() -> [WeeklyInsight] {
        let done = tasks.filter(\.isDone).count
        let due = progress.values.filter { $0.nextReviewAt.map { $0 <= Date() } ?? false }.count
        var values = [WeeklyInsight(title: "Plan uyumu", detail: "\(done)/\(max(tasks.count, 1)) görev tamamlandı.", systemImage: "checkmark.circle")]
        values.append(WeeklyInsight(title: "Tekrar kuyruğu", detail: "\(due) konu tekrar bekliyor.", systemImage: "arrow.clockwise"))
        if let date = profile.examDate {
            let days = max(0, Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0)
            values.append(WeeklyInsight(title: "Sınava kalan", detail: "\(days) gün", systemImage: "calendar"))
        }
        return values
    }

    private func seedProgressIfNeeded() {
        guard let exam = selectedExam else { return }
        exam.sessions.flatMap(\.subjects).flatMap(\.topics).forEach { topic in
            if progress[topic.id] == nil {
                progress[topic.id] = TopicProgress(id: topic.id, state: .notStarted, difficulty: .normal, lastStudiedAt: nil, reviewCount: 0, nextReviewAt: nil)
            }
        }
    }

    private func storageKey(_ suffix: String) -> String { "nova.\(profile.email.lowercased()).\(suffix)" }

    private func persist() {
        guard !profile.email.isEmpty else { return }
        defaults.set(profile.email.lowercased(), forKey: "nova.currentUser")
        defaults.set(onboardingCompleted, forKey: storageKey("onboarding"))
        if let data = try? JSONEncoder().encode(profile) { defaults.set(data, forKey: storageKey("profile")) }
        if let data = try? JSONEncoder().encode(progress) { defaults.set(data, forKey: storageKey("progress")) }
        if let data = try? JSONEncoder().encode(tasks) { defaults.set(data, forKey: storageKey("tasks")) }
        if let data = try? JSONEncoder().encode(coachActions) { defaults.set(data, forKey: storageKey("coachActions")) }
    }

    private func restoreSession() {
        guard let email = defaults.string(forKey: "nova.currentUser") else { return }
        loadUserData(email: email)
        isLoggedIn = !profile.email.isEmpty
    }

    private func loadUserData(email: String) {
        let key: (String) -> String = { "nova.\(email.lowercased()).\($0)" }
        if let data = defaults.data(forKey: key("profile")), let value = try? JSONDecoder().decode(UserProfile.self, from: data) { profile = value }
        else { profile.email = email.lowercased() }
        onboardingCompleted = defaults.bool(forKey: key("onboarding"))
        if let data = defaults.data(forKey: key("progress")), let value = try? JSONDecoder().decode([String: TopicProgress].self, from: data) { progress = value }
        if let data = defaults.data(forKey: key("tasks")), let value = try? JSONDecoder().decode([StudyTask].self, from: data) { tasks = value }
        if let data = defaults.data(forKey: key("coachActions")), let value = try? JSONDecoder().decode([CoachAction].self, from: data) { coachActions = value }
    }
}
