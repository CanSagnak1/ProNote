import UIKit

class NoteCell: UICollectionViewCell {
    static let identifier = "NoteCell"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = Theme.textPrimary
        label.numberOfLines = 1
        return label
    }()

    private let previewLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = Theme.textSecondary
        label.numberOfLines = 3
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = Theme.textSecondary.withAlphaComponent(0.6)
        label.textAlignment = .right
        return label
    }()

    private let favoriteIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "star.fill")
        iv.tintColor = .systemYellow
        iv.isHidden = true
        return iv
    }()

    // Gradient or background view
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Theme.surface
        view.layer.cornerRadius = Theme.cornerRadius
        view.layer.masksToBounds = true
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(titleLabel)
        containerView.addSubview(previewLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(favoriteIcon)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        previewLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        favoriteIcon.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: favoriteIcon.leadingAnchor, constant: -8),

            favoriteIcon.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            favoriteIcon.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor, constant: -16),
            favoriteIcon.widthAnchor.constraint(equalToConstant: 16),
            favoriteIcon.heightAnchor.constraint(equalToConstant: 16),

            previewLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            previewLabel.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor, constant: 16),
            previewLabel.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor, constant: -16),

            dateLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            dateLabel.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor, constant: -16),
            dateLabel.topAnchor.constraint(
                greaterThanOrEqualTo: previewLabel.bottomAnchor, constant: 12),
        ])
    }

    func configure(with note: Note) {
        titleLabel.text = note.title
        previewLabel.text = note.content

        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        dateLabel.text = formatter.string(from: note.dateModified)

        favoriteIcon.isHidden = !note.isFavorite

        // Add a subtle border or glow based on tint color
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = note.tintColor.withAlphaComponent(0.3).cgColor
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        previewLabel.text = nil
        favoriteIcon.isHidden = true
    }
}
