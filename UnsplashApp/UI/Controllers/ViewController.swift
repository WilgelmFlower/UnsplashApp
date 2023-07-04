import UIKit

final class ViewController: UIViewController {

    var fetchedData = [ResultSearchPhotos]()
    private var searchDebounceTimer: Timer?
    private var currentPage = 1
    private var isLoadingData = false

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: self.view.frame.size.width/2.2, height: self.view.frame.size.width/2.2)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.identifier)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.allowsMultipleSelection = false
        collectionView.keyboardDismissMode = .onDrag

        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "backgroundColor")
        collectionView.dataSource = self
        collectionView.delegate = self
        fetchData(isFirstPage: true)
        setup()
        setupSearchController()
    }

    private func setupSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
    }

    private func setup() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func fetchData(isFirstPage: Bool) {
        if isFirstPage {
            APIManager.shared.fetchPhotos { [weak self] (result: Result<[ResultSearchPhotos], Error>) in
                guard let self = self else { return }
                switch result {
                case .success(let photoData):
                    DispatchQueue.main.async {
                        self.fetchedData.append(contentsOf: photoData)
                        self.collectionView.reloadData()
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        } else {
            guard !isLoadingData else { return }
            isLoadingData = true
            currentPage += 1
            APIManager.shared.fetchPhotos(page: currentPage) { [weak self] (result: Result<[ResultSearchPhotos], Error>) in
                guard let self = self else { return }
                self.isLoadingData = false
                switch result {
                case .success(let photoData):
                    DispatchQueue.main.async {
                        self.fetchedData.append(contentsOf: photoData)
                        self.collectionView.reloadData()
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        fetchedData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let imageURL = fetchedData[indexPath.item].urls.small
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.identifier,
                                                            for: indexPath) as? ImageCell else { return UICollectionViewCell() }
        cell.configure(with: imageURL)
        if indexPath.item == fetchedData.count - 2 && !isLoadingData {
            fetchData(isFirstPage: false)
        }
        return cell
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVC = DetailViewController()
        if indexPath.item < fetchedData.count {
            let selectedCell = fetchedData[indexPath.item]
            detailVC.configure(imageURL: selectedCell.urls.small,
                               authorName: selectedCell.user.username,
                               date: selectedCell.created_at,
                               location: selectedCell.user.location,
                               totalLikes: selectedCell.user.total_likes,
                               id: selectedCell.id)
            detailVC.resultsDetail = fetchedData
        }
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            fetchData(isFirstPage: true)
        }
        searchDebounceTimer?.invalidate()

        if !searchText.isEmpty {
            searchDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { [weak self] (_) in
                self?.performSearch(withQuery: searchText)
            })
        }
    }

    private func performSearch(withQuery query: String) {
        fetchedData = []

        if query.isEmpty {
            collectionView.reloadData()
            return
        }

        APIManager.shared.fetchPhotos(withQuery: query) { [weak self] (result: Result<PhotoModelSearch, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let photoData):
                DispatchQueue.main.async {
                    self.fetchedData.append(contentsOf: photoData.results)
                    self.collectionView.reloadData()
                }
            case .failure(let error):
                print(String(describing: error))
            }
        }
    }


    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        fetchedData.removeAll()
        fetchData(isFirstPage: true)
    }
}
