import UIKit

final class FavouriteCell: UITableViewCell {
    
    static let identifier = String(describing: FavouriteCell.self)
    
    let imageMini: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleToFill
        imageView.layer.cornerRadius = 12
        
        return imageView
    }()
    
    let nameAuthor: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: .heavy)
        label.numberOfLines = 0
        label.textAlignment = .left
        
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageMini.image = nil
        nameAuthor.text = nil
    }
    
    private func setup() {
        imageMini.translatesAutoresizingMaskIntoConstraints = false
        nameAuthor.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageMini)
        contentView.addSubview(nameAuthor)

        NSLayoutConstraint.activate([
            imageMini.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            imageMini.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            imageMini.widthAnchor.constraint(equalTo: contentView.heightAnchor),
            imageMini.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            nameAuthor.leftAnchor.constraint(equalTo: imageMini.rightAnchor, constant: 10),
            nameAuthor.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -50),
            nameAuthor.topAnchor.constraint(equalTo: contentView.topAnchor),
            nameAuthor.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
}
