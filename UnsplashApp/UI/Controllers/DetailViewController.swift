import UIKit

final class DetailViewController: UIViewController {

    private var isLiked = false
    private var id: String?
    var resultsDetail = [ResultSearchPhotos]()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 16

        return imageView
    }()

    private let nameAuthor: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 18, weight: .heavy)

        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 16, weight: .regular)

        return label
    }()

    private let locationLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0

        return label
    }()

    private let totalLikesLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 16, weight: .regular)

        return label
    }()

    private lazy var likeButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blue.withAlphaComponent(0.6)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)

        return button
    }()

    @objc func likeButtonTapped() {
        isLiked.toggle()
        UserDefaults.standard.set(isLiked, forKey: "isLiked\(id ?? "")")
        updateLikeButtonTitle()

        let selectedModel = resultsDetail.first { $0.id == id }
        if let selectedModel = selectedModel {
            if isLiked {
                HelperData.shared.fetchedData.append(selectedModel)
                showAlert(isLiked: true)
            } else {
                HelperData.shared.fetchedData.removeAll(where: { $0.id == id })
                showAlert(isLiked: false)
            }
        }
    }

    private func showAlert(isLiked: Bool = false) {
        if isLiked {
            let alertController = UIAlertController(title: "Liked", message: "The photo has been added to your favorites.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: "Unliked", message: "The photo has been deleted from your favorites.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Detail card about photo"
        view.backgroundColor = .systemBackground
        setup()
        loadLikedStatus()
    }

    private func loadLikedStatus() {
        isLiked = UserDefaults.standard.bool(forKey: "isLiked\(id ?? "")")
        updateLikeButtonTitle()
    }

    private func updateLikeButtonTitle() {
        if isLiked {
            likeButton.backgroundColor = .red
            likeButton.setTitle("Delete from favourites", for: .normal)
        } else {
            likeButton.backgroundColor = .blue.withAlphaComponent(0.6)
            likeButton.setTitle("Add to favourites", for: .normal)
        }
    }

    private func setup() {
        view.addSubview(imageView)
        view.addSubview(nameAuthor)
        view.addSubview(dateLabel)
        view.addSubview(locationLabel)
        view.addSubview(totalLikesLabel)
        view.addSubview(likeButton)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        nameAuthor.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        totalLikesLabel.translatesAutoresizingMaskIntoConstraints = false
        likeButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3),

            nameAuthor.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            nameAuthor.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            nameAuthor.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),

            dateLabel.topAnchor.constraint(equalTo: nameAuthor.bottomAnchor, constant: 10),
            dateLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),

            locationLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 10),
            locationLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            locationLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),

            totalLikesLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 10),
            totalLikesLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            totalLikesLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),

            likeButton.topAnchor.constraint(equalTo: totalLikesLabel.bottomAnchor, constant: 20),
            likeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 40),
            likeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -40),
        ])
    }

    func configure(imageURL: String, authorName: String, date: String, location: String?, totalLikes: Int, id: String) {
        guard let imageURL = URL(string: imageURL) else { return }
        self.id = id

        let task = URLSession.shared.dataTask(with: imageURL) { [weak self] data, _, error in
            guard let data = data, error == nil else { return }

            DispatchQueue.main.async {
                let image = UIImage(data: data)
                self?.imageView.image = image
                self?.nameAuthor.text = "Author name - \(authorName)"
                self?.convertDataString(date: date)
                self?.locationLabel.text = "Location - \(location ?? "Location not found")"
                self?.totalLikesLabel.text = "Total likes - \(totalLikes)"
            }
        }
        task.resume()
    }

    private func convertDataString(date: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let inputDate = dateFormatter.date(from: date) {
            dateFormatter.dateFormat = "dd MMMM yyyy"
            let formattedDate = dateFormatter.string(from: inputDate)
            dateLabel.text = "Created at - \(formattedDate)"
        }
    }

}
