import UIKit

class ViewController: UIViewController, UICollectionViewDataSource {
    static let cellId = "CellId"

    var zoomView: ZoomCollectionView?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if zoomView == nil {
            let itemWidth = (self.view.frame.width - 20.0) / 5.0

            let layout = ScalingGridLayout(
                itemSize: CGSize(width: itemWidth, height: itemWidth),
                columns: 5,
                itemSpacing: 5.0,
                scale: 1.0
            )

            var size = self.view.frame.size
            size.height = 500
            zoomView = ZoomCollectionView(
                frame: CGRect(origin: CGPoint(x: 0, y: 60), size: size),
                layout: layout
            )
            zoomView!.collectionView.dataSource = self
            zoomView!.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: ViewController.cellId)
            zoomView!.collectionView.backgroundColor = .white

            zoomView!.scrollView.minimumZoomScale = 0.5
            zoomView!.scrollView.zoomScale = 1.0
            zoomView!.scrollView.maximumZoomScale = 6.0

            view.addSubview(zoomView!)

            let tap = UITapGestureRecognizer(target: self, action: #selector(scrollViewWasTapped(sender:)))
            zoomView!.addGestureRecognizer(tap)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return 40
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ViewController.cellId, for: indexPath)
        cell.backgroundColor = indexPath.row % 2 == 0 ? .orange : .blue

        return cell
    }

    @objc func scrollViewWasTapped(sender: UITapGestureRecognizer) {
        let point = sender.location(in: zoomView!.collectionView)
        let path = zoomView!.collectionView.indexPathForItem(at: point)
        print(path ?? IndexPath(row: 0, section: 0))
    }
}
