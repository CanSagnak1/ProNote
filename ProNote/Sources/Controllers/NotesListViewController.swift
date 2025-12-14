import UIKit

nonisolated enum NotesListSection: Sendable, Hashable { case main }

@MainActor class NotesListViewController: UIViewController {

    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<NotesListSection, Note.ID>!
    private var notes: [Note] = []

    private let searchController = UISearchController(searchResultsController: nil)
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    private var searchBarIsEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }

    // Sort/Filter state
    private var showFavoritesOnly = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.background
        title = "Notes"

        setupNavBar()
        setupCollectionView()
        configureDataSource()

        loadData()

        // Notification for when data changes elsewhere (e.g., detail view)
        NotificationCenter.default.addObserver(
            self, selector: #selector(refreshData), name: NSNotification.Name("NotesUpdated"),
            object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()  // Ensure up to date
    }

    private func setupNavBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Notes"
        definesPresentationContext = true

        let addBtn = UIBarButtonItem(
            barButtonSystemItem: .compose, target: self, action: #selector(didTapAdd))
        navigationItem.rightBarButtonItem = addBtn

        let filterBtn = UIBarButtonItem(
            image: UIImage(systemName: "line.3.horizontal.decrease.circle"), style: .plain,
            target: self, action: #selector(didTapFilter))
        navigationItem.leftBarButtonItem = filterBtn
    }

    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = Theme.background
        collectionView.delegate = self
        collectionView.register(NoteCell.self, forCellWithReuseIdentifier: NoteCell.identifier)
        view.addSubview(collectionView)
    }

    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(120))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(120))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 10, leading: 16, bottom: 10, trailing: 16)

        return UICollectionViewCompositionalLayout(section: section)
    }

    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<NotesListSection, Note.ID>(
            collectionView: collectionView
        ) { (collectionView: UICollectionView, indexPath: IndexPath, id: Note.ID) -> UICollectionViewCell? in
            guard
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: NoteCell.identifier, for: indexPath) as? NoteCell
            else {
                return nil
            }
            if let note = NoteManager.shared.notes.first(where: { $0.id == id }) {
                cell.configure(with: note)
            }
            return cell
        }
    }

    @objc private func refreshData() {
        loadData()
    }

    private func loadData() {
        var allNotes = NoteManager.shared.notes

        if showFavoritesOnly {
            allNotes = allNotes.filter { $0.isFavorite }
        }

        if isFiltering {
            let query = searchController.searchBar.text ?? ""
            allNotes = NoteManager.shared.searchNotes(query: query)
            if showFavoritesOnly {
                allNotes = allNotes.filter { $0.isFavorite }
            }
        }

        self.notes = allNotes
        applySnapshot()
    }

    private func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<NotesListSection, Note.ID>()
        snapshot.appendSections([NotesListSection.main])
        snapshot.appendItems(notes.map { $0.id })
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }

    @objc private func didTapAdd() {
        let detailVC = NoteDetailViewController()  // Will implement next
        navigationController?.pushViewController(detailVC, animated: true)
    }

    @objc private func didTapFilter() {
        let ac = UIAlertController(title: "Filter", message: nil, preferredStyle: .actionSheet)
        ac.addAction(
            UIAlertAction(
                title: showFavoritesOnly ? "Show All Notes" : "Show Favorites Only",
                style: .default,
                handler: { _ in
                    self.showFavoritesOnly.toggle()
                    self.loadData()
                }))

        let sortTitle = "Sort by Date"  // Currently only default sort, but placeholder for more
        ac.addAction(
            UIAlertAction(
                title: sortTitle, style: .default,
                handler: { _ in
                    // Basic sort logic already in Manager, could expand here
                }))

        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
}

extension NotesListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let noteId = dataSource.itemIdentifier(for: indexPath),
            let note = NoteManager.shared.notes.first(where: { $0.id == noteId })
        else { return }

        let detailVC = NoteDetailViewController()
        detailVC.note = note
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension NotesListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        loadData()
    }
}

