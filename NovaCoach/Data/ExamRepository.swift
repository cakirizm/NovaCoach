import Foundation

final class ExamRepository {
    static let shared = ExamRepository()
    private init() {}

    func loadExams() -> [Exam] {
        guard let url = Bundle.main.url(forResource: "exams", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let exams = try? JSONDecoder().decode([Exam].self, from: data) else {
            return []
        }
        return exams
    }
}
