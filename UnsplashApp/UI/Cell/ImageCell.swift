import UIKit

final class ImageCell: UICollectionViewCell {

    static let identifier = String(describing: ImageCell.self)

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill

        return imageView
    }()

    private var imageURLString: String?

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
        layer.masksToBounds = true
        layer.cornerRadius = 16
    }

    func configure(with imageURLString: String) {
        self.imageURLString = imageURLString

        DispatchQueue.global().async {
            if let imageURL = URL(string: imageURLString),
               let imageData = try? Data(contentsOf: imageURL),
               let image = UIImage(data: imageData) {
                DispatchQueue.main.async {
                    if self.imageURLString == imageURLString {
                        self.imageView.image = image
                    }
                }
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
}
