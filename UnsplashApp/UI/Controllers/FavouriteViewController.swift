import UIKit

final class FavouriteViewController: UIViewController {

    var resultsTab: [ResultSearchPhotos] = []

    lazy var tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.rowHeight = 100
        table.dataSource = self
        table.delegate = self
        table.register(FavouriteCell.self, forCellReuseIdentifier: FavouriteCell.identifier)

        return table
    }()

    private let placeholderImage: UILabel = {
        let label = UILabel()
        label.text = "You didn't add photos to favorites"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 20)

        return label
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resultsTab = HelperData.shared.fetchedData
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "backgroundColor")
        setup()
    }

    private func setup() {
        view.addSubview(tableView)
        tableView.addSubview(placeholderImage)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        placeholderImage.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            placeholderImage.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            placeholderImage.centerYAnchor.constraint(equalTo: tableView.centerYAnchor)
        ])
    }
}

extension FavouriteViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        placeholderImage.isHidden = resultsTab.count != 0
        return resultsTab.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FavouriteCell.identifier,
                                                       for: indexPath) as? FavouriteCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        let selectedIndex = resultsTab[indexPath.row]
        cell.nameAuthor.text = "Author name - \(selectedIndex.user.username)"

        if let imageURL = URL(string: selectedIndex.urls.small) {
            DispatchQueue.global().async {
                if let imageData = try? Data(contentsOf: imageURL) {
                    DispatchQueue.main.async {
                        cell.imageMini.image = UIImage(data: imageData)
                    }
                }
            }
        }
        return cell
    }
}

extension FavouriteViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = DetailViewController()
        let indexCurrent = resultsTab[indexPath.row]
        detailVC.resultsDetail = resultsTab
        detailVC.configure(imageURL: indexCurrent.urls.small,
                           authorName: indexCurrent.user.username,
                           date: indexCurrent.created_at,
                           location: indexCurrent.user.location,
                           totalLikes: indexCurrent.user.total_likes,
                           id: indexCurrent.id)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
