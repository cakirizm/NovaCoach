import Foundation

@MainActor
final class AppStore: ObservableObject {
    @Published var isLoggedIn = false
    @Published var onboardingCompleted = false
    @Published var profile = UserProfile(name: "", email: "", selectedExamId: nil, targetLabel: "", pace: "Dengeli", coachStyle: "Dengeli")
    @Published var exams: [Exam] = ExamRepository.shared.loadExams()
    @Published var progress: [String: TopicProgress] = [:]
    @Published var todayTasks: [StudyTask] = []
    private let defaults = UserDefaults.standard

    init() { restore() }
    var selectedExam: Exam? { exams.first { $0.id == profile.selectedExamId } }
    var allSelectedTopics: [(subject: Subject, topic: Topic)] {
        guard let exam = selectedExam else { return [] }
        return exam.sessions.flatMap { $0.subjects.flatMap { subject in subject.topics.map { (subject, $0) } } }
    }
    var overallProgress: Double {
        let topics = allSelectedTopics; guard !topics.isEmpty else { return 0 }
        let score = topics.reduce(0.0) { partial, item in
            switch progress[item.topic.id]?.state ?? .notStarted {
            case .notStarted: return partial
            case .studying: return partial + 0.35
            case .review: return partial + 0.65
            case .mastered: return partial + 1
            }
        }
        return score / Double(topics.count)
    }
    func login(email: String, password: String) { guard !email.isEmpty, !password.isEmpty else { return }; profile.email=email; if profile.name.isEmpty { profile.name=email.components(separatedBy:"@").first?.capitalized ?? "Öğrenci" }; isLoggedIn=true; persist() }
    func logout() { isLoggedIn=false; persist() }
    func selectExam(_ exam: Exam) { profile.selectedExamId=exam.id; persist() }
    func completeOnboarding() { onboardingCompleted=true; generatePlan(); persist() }
    func markTopic(_ topicId: String, state: TopicState, difficulty: Int = 2) { progress[topicId]=TopicProgress(id:topicId,state:state,difficulty:difficulty,lastStudiedAt:Date(),reviewCount:progress[topicId]?.reviewCount ?? 0); generatePlan(); persist() }
    func toggleTask(_ task: StudyTask) { guard let i=todayTasks.firstIndex(where:{$0.id==task.id}) else{return}; todayTasks[i].isDone.toggle(); if todayTasks[i].isDone { markTopic(todayTasks[i].topicId,state:.studying) } else { persist() } }
    func generatePlan() {
        guard selectedExam != nil else { todayTasks=[]; return }
        let pending=allSelectedTopics.filter{(progress[$0.topic.id]?.state ?? .notStarted) != .mastered}.sorted{$0.topic.priority > $1.topic.priority}
        todayTasks=Array(pending.prefix(profile.pace == "Hafif" ? 3 : profile.pace == "Yoğun" ? 6 : 4)).map { item in
            StudyTask(id:UUID(),examId:profile.selectedExamId ?? "",subjectId:item.subject.id,topicId:item.topic.id,title:"\(item.subject.name) · \(item.topic.name)",type:(progress[item.topic.id]?.state == .review ? "Tekrar":"Konu"),isDone:false)
        }; persist()
    }
    func subjectProgress(_ subject: Subject) -> Double { guard !subject.topics.isEmpty else{return 0}; return subject.topics.reduce(0.0){p,t in switch progress[t.id]?.state ?? .notStarted {case .notStarted:return p; case .studying:return p+0.35; case .review:return p+0.65; case .mastered:return p+1}}/Double(subject.topics.count) }
    func coachMessage() -> String { guard selectedExam != nil else{return "Önce sınavını seç."}; let done=todayTasks.filter(\.isDone).count; if !todayTasks.isEmpty && done==todayTasks.count{return "Bugünkü plan tamam. Yeni planında ilerlemeni dengeleyeceğim."}; return "Bugün \(max(0,todayTasks.count-done)) görev kaldı. Önceliği yüksek öncelikli ve yarım kalan konulara verdim." }
    private func persist(){ if let d=try? JSONEncoder().encode(profile){defaults.set(d,forKey:"profile")}; if let d=try? JSONEncoder().encode(progress){defaults.set(d,forKey:"progress")}; if let d=try? JSONEncoder().encode(todayTasks){defaults.set(d,forKey:"tasks")}; defaults.set(isLoggedIn,forKey:"loggedIn"); defaults.set(onboardingCompleted,forKey:"onboarding") }
    private func restore(){ isLoggedIn=defaults.bool(forKey:"loggedIn"); onboardingCompleted=defaults.bool(forKey:"onboarding"); if let d=defaults.data(forKey:"profile"),let v=try? JSONDecoder().decode(UserProfile.self,from:d){profile=v}; if let d=defaults.data(forKey:"progress"),let v=try? JSONDecoder().decode([String:TopicProgress].self,from:d){progress=v}; if let d=defaults.data(forKey:"tasks"),let v=try? JSONDecoder().decode([StudyTask].self,from:d){todayTasks=v} }
}
