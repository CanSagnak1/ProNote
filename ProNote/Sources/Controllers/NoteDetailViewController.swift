import UIKit

class NoteDetailViewController: UIViewController {

    var note: Note?

    private let titleTextField: UITextField = {
        let tf = UITextField()
        tf.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        tf.textColor = Theme.textPrimary
        tf.placeholder = "Title"
        tf.tintColor = Theme.accent
        return tf
    }()

    private let bodyTextView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        tv.textColor = Theme.textPrimary
        tv.backgroundColor = .clear
        tv.tintColor = Theme.accent
        return tv
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = Theme.textSecondary
        label.textAlignment = .center
        return label
    }()

    // Tools
    private var isFavorite: Bool = false
    private var selectedColorHex: String = "#BB86FC"

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.background
        setupUI()
        setupNavBar()
        configureWithNote()

        // Keyboard observers
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveNote()
    }

    private func setupUI() {
        view.addSubview(titleTextField)
        view.addSubview(dateLabel)
        view.addSubview(bodyTextView)

        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyTextView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            dateLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            bodyTextView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
            bodyTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),  // slightly less padding for text view standard look
            bodyTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            bodyTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func setupNavBar() {
        navigationController?.navigationBar.tintColor = Theme.accent

        let trashBtn = UIBarButtonItem(
            barButtonSystemItem: .trash, target: self, action: #selector(didTapDelete))
        let favBtn = UIBarButtonItem(
            image: UIImage(systemName: isFavorite ? "star.fill" : "star"), style: .plain,
            target: self, action: #selector(didTapFavorite))
        let colorBtn = UIBarButtonItem(
            image: UIImage(systemName: "paintpalette"), style: .plain, target: self,
            action: #selector(didTapColor))

        navigationItem.rightBarButtonItems = [trashBtn, favBtn, colorBtn]
    }

    private func configureWithNote() {
        if let note = note {
            titleTextField.text = note.title
            bodyTextView.text = note.content
            isFavorite = note.isFavorite
            selectedColorHex = note.tintColorHex

            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            dateLabel.text = "Edited: " + formatter.string(from: note.dateModified)
        } else {
            // New Note
            dateLabel.text = "New Note"
            titleTextField.becomeFirstResponder()
        }
        updateFavoriteIcon()
    }

    private func updateFavoriteIcon() {
        if let buttons = navigationItem.rightBarButtonItems, buttons.count >= 2 {
            buttons[1].image = UIImage(systemName: isFavorite ? "star.fill" : "star")
            buttons[1].tintColor = isFavorite ? .systemYellow : Theme.accent
        }
    }

    private func saveNote() {
        guard let title = titleTextField.text, !title.isEmpty else { return }
        let content = bodyTextView.text ?? ""

        if var note = note {
            // Update
            note.title = title
            note.content = content
            note.isFavorite = isFavorite
            note.tintColorHex = selectedColorHex
            NoteManager.shared.updateNote(note)
        } else {
            // Create
            NoteManager.shared.createNote(
                title: title, content: content, tintColorHex: selectedColorHex)
            // After creation, we might want to reload this VC as an edit, but for now simple "save on exit" is fine
        }

        NotificationCenter.default.post(name: NSNotification.Name("NotesUpdated"), object: nil)
    }

    @objc private func didTapDelete() {
        if let note = note {
            let ac = UIAlertController(
                title: "Delete Note?", message: "This cannot be undone.", preferredStyle: .alert)
            ac.addAction(
                UIAlertAction(
                    title: "Delete", style: .destructive,
                    handler: { _ in
                        NoteManager.shared.deleteNote(with: note.id)
                        NotificationCenter.default.post(
                            name: NSNotification.Name("NotesUpdated"), object: nil)
                        self.navigationController?.popViewController(animated: true)
                    }))
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(ac, animated: true)
        } else {
            // Just close if it wasn't saved yet
            navigationController?.popViewController(animated: true)
        }
    }

    @objc private func didTapFavorite() {
        isFavorite.toggle()
        updateFavoriteIcon()

        // Find the favorite button view to animate
        if let buttons = navigationItem.rightBarButtonItems, buttons.count >= 2 {
            // It's a bit tricky to get the actual view of a UIBarButtonItem directly API-wise without custom view,
            // but for now we can just animate the main view or provide feedback elsewhere.
            // A better approach for programmatic UI would be to use a custom UIButton as the customView of the UIBarButtonItem.
            // Let's rely on haptic feedback instead for now as it's cleaner for standard items.
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
    }

    @objc private func didTapColor() {
        let ac = UIAlertController(
            title: "Choose Color", message: nil, preferredStyle: .actionSheet)

        let colors: [(name: String, hex: String)] = [
            ("Purple", "#BB86FC"),
            ("Teal", "#03DAC6"),
            ("Red", "#CF6679"),
            ("Orange", "#F39C12"),
            ("Blue", "#3498DB"),
        ]

        for color in colors {
            ac.addAction(
                UIAlertAction(
                    title: color.name, style: .default,
                    handler: { _ in
                        self.selectedColorHex = color.hex
                    }))
        }

        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }

    // MARK: - Keyboard Handling
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else { return }

        let bottomInset = keyboardFrame.height
        bodyTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
        bodyTextView.scrollIndicatorInsets = bodyTextView.contentInset
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        bodyTextView.contentInset = .zero
        bodyTextView.scrollIndicatorInsets = .zero
    }
}
