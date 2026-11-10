import UIKit

class ListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private let items = FavoriteData.items

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail",
           let detailVC = segue.destination as? DetailViewController,
           let indexPath = tableView.indexPathForSelectedRow {
            detailVC.item = items[indexPath.row]
        }
    }
}

// MARK: - UITableViewDataSource
extension ListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "FavoriteCell",
            for: indexPath
        ) as? FavoriteCell else {
            return UITableViewCell()
        }

        let item = items[indexPath.row]
        cell.titleLabel.text = item.title
        cell.thumbImageView.image = UIImage(named: item.imageName)
        return cell
    }
}
