import Foundation

class NoteManager {
    static let shared = NoteManager()

    private let fileName = "notes.json"
    private(set) var notes: [Note] = []

    private init() {
        loadNotes()
    }

    private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private var fileURL: URL {
        documentsDirectory.appendingPathComponent(fileName)
    }

    func createNote(title: String, content: String, tintColorHex: String = "#BB86FC") {
        let newNote = Note(title: title, content: content, tintColorHex: tintColorHex)
        notes.insert(newNote, at: 0)  // Add to top
        saveNotes()
    }

    func updateNote(_ note: Note) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            var updatedNote = note
            updatedNote.dateModified = Date()
            notes[index] = updatedNote
            saveNotes()
        }
    }

    func deleteNote(at index: Int) {
        notes.remove(at: index)
        saveNotes()
    }

    func deleteNote(with id: UUID) {
        notes.removeAll { $0.id == id }
        saveNotes()
    }

    func toggleFavorite(for note: Note) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index].isFavorite.toggle()
            saveNotes()
        }
    }

    private func saveNotes() {
        do {
            let data = try JSONEncoder().encode(notes)
            try data.write(to: fileURL)
        } catch {
            print("Failed to save notes: \(error)")
        }
    }

    private func loadNotes() {
        do {
            let data = try Data(contentsOf: fileURL)
            notes = try JSONDecoder().decode([Note].self, from: data)
            // Sort by date modified desc by default
            notes.sort { $0.dateModified > $1.dateModified }
        } catch {
            print("Failed to load notes (might be first run): \(error)")
        }
    }

    // Filtering helper
    func getNotes(filter: (Note) -> Bool) -> [Note] {
        return notes.filter(filter)
    }

    func searchNotes(query: String) -> [Note] {
        if query.isEmpty { return notes }
        return notes.filter {
            $0.title.localizedCaseInsensitiveContains(query)
                || $0.content.localizedCaseInsensitiveContains(query)
        }
    }
}
