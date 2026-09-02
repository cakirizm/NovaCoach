import Foundation

enum UserRole: String, Codable, CaseIterable, Identifiable {
    case student = "Öğrenci"
    var id: String { rawValue }
}

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

enum TopicState: String, Codable, CaseIterable, Identifiable {
    case notStarted = "Başlanmadı"
    case studying = "Çalışılıyor"
    case review = "Tekrar Gerekli"
    case mastered = "Oturdu"
    var id: String { rawValue }
}

enum TopicDifficulty: Int, Codable, CaseIterable, Identifiable {
    case easy = 1, normal = 2, hard = 3
    var id: Int { rawValue }
    var label: String { self == .easy ? "Kolay" : self == .normal ? "Normal" : "Zor" }
}

struct TopicProgress: Codable, Identifiable {
    let id: String
    var state: TopicState
    var difficulty: TopicDifficulty
    var lastStudiedAt: Date?
    var reviewCount: Int
    var nextReviewAt: Date?
}

enum StudyTaskKind: String, Codable {
    case study = "Konu"
    case review = "Tekrar"
}

struct StudyTask: Identifiable, Codable, Hashable {
    let id: UUID
    let examId: String
    let subjectId: String
    let topicId: String
    let title: String
    let subjectName: String
    let kind: StudyTaskKind
    let scheduledDate: Date
    var isDone: Bool
}

struct UserProfile: Codable {
    var name: String = ""
    var email: String = ""
    var role: UserRole = .student
    var selectedExamId: String?
    var targetLabel: String = ""
    var pace: String = "Dengeli"
    var coachStyle: String = "Dengeli"
    var examDate: Date?
    var weeklyBusy: Bool = false
}

struct AuthAccount: Codable {
    let email: String
    let displayName: String
    let salt: String
    let passwordHash: String
    let createdAt: Date
}

struct CoachAction: Codable, Identifiable {
    let id: UUID
    let createdAt: Date
    let input: String
    let summary: String
}

struct WeeklyInsight: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let systemImage: String
}
