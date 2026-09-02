import Foundation

struct Exam: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let shortName: String
    let sessions: [ExamSession]
}

struct ExamSession: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let subjects: [Subject]
}

struct Subject: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let topics: [Topic]
}

struct Topic: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let priority: Int
}

enum TopicState: String, Codable, CaseIterable {
    case notStarted = "Başlanmadı"
    case studying = "Çalışılıyor"
    case review = "Tekrar Gerekli"
    case mastered = "Oturdu"
}

struct TopicProgress: Codable, Identifiable {
    let id: String
    var state: TopicState
    var difficulty: Int
    var lastStudiedAt: Date?
    var reviewCount: Int
}

struct StudyTask: Identifiable, Codable {
    let id: UUID
    let examId: String
    let subjectId: String
    let topicId: String
    let title: String
    let type: String
    var isDone: Bool
}

struct UserProfile: Codable {
    var name: String
    var email: String
    var selectedExamId: String?
    var targetLabel: String
    var pace: String
    var coachStyle: String
}
