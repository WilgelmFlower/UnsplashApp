import UIKit

final class ViewController: UIViewController {

    var fetchedData = [ResultSearchPhotos]()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.itemSize = CGSize(width: self.view.frame.size.width/2.2, height: self.view.frame.size.width/2.2)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.identifier)
        collectionView.showsVerticalScrollIndicator = false

        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        fetchData()
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

    private func fetchData() {
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
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        fetchedData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let imageURL = fetchedData[indexPath.item].urls.regular
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.identifier,
                                                            for: indexPath) as? ImageCell else { return UICollectionViewCell() }
        cell.configure(with: imageURL)

        return cell
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVC = DetailViewController()
        if indexPath.item < fetchedData.count {
            let selectedCell = fetchedData[indexPath.item]
            detailVC.configure(imageURL: selectedCell.urls.regular,
                               authorName: selectedCell.user.username,
                               date: selectedCell.created_at,
                               location: selectedCell.user.location,
                               totalLikes: selectedCell.user.total_likes,
                               id: selectedCell.id)
            detailVC.resultsDetail = fetchedData
        }
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else {
            collectionView.reloadData()
            return
        }

        if searchText.isEmpty {
            collectionView.reloadData()
            return
        }

        fetchedData = []
        APIManager.shared.fetchPhotos(withQuery: searchText) { [weak self] (result: Result<PhotoModelSearch, Error>) in
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
        fetchData()
    }
}
