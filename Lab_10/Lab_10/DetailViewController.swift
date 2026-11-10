import UIKit

class DetailViewController: UIViewController {

    var item: FavoriteItem?

    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var ratingStackView: UIStackView!
    @IBOutlet weak var descriptionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let item else { return }

        title = item.title
        itemImageView.image = UIImage(named: item.imageName)
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        descriptionLabel.text = item.description
        configureStars(rating: item.rating)
    }

    private func configureStars(rating: Int) {
        for (index, view) in ratingStackView.arrangedSubviews.enumerated() {
            guard let star = view as? UIImageView else { continue }
            star.image = UIImage(systemName: index < rating ? "star.fill" : "star")
        }
    }
}
