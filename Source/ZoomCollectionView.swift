import Foundation
import UIKit

open class ZoomCollectionView: UIView, UIScrollViewDelegate, UICollectionViewDelegate {
    let collectionView: UICollectionView
    let scrollView: UIScrollView
    let dummyZoomView: UIView
    let layout: UICollectionViewLayout

    public init(frame: CGRect, layout: UICollectionViewLayout) {
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        scrollView = UIScrollView(frame: frame)
        scrollView.contentInset = .zero
        collectionView.contentInset = .zero
        dummyZoomView = UIView(frame: .zero)

        self.layout = layout

        super.init(frame: frame)

        // remove gesture recognizers from the collection
        // view and use the scroll views built-in instead.
        collectionView.gestureRecognizers?.forEach { collectionView.removeGestureRecognizer($0) }

        scrollView.delegate = self
        collectionView.delegate = self

        addSubview(collectionView)
        addSubview(scrollView)
        scrollView.addSubview(dummyZoomView)

        // bounce is currently not supported since the
        // animation does not call scrollViewDidZoom
        scrollView.bouncesZoom = false

        bringSubviewToFront(scrollView)
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        if let layout = self.layout as? ScalingLayoutProtocol {
            print("ZoomCollectionView layoutSubviews")
            let size = layout.contentSizeForScale(scrollView.zoomScale)
            scrollView.contentSize = size
            dummyZoomView.frame = CGRect(origin: .zero, size: size)
        }
    }

    func assignContent() {
        var offset = scrollView.contentOffset
        if scrollView.zoomScale < 1.0 {
            offset.x = (scrollView.contentSize.width - collectionView.bounds.width) / 2
        }
        collectionView.contentOffset = offset
        collectionView.hideLingeringCells()
    }

    open func viewForZooming(in _: UIScrollView) -> UIView? {
        return dummyZoomView
    }

    open func scrollViewDidScroll(_: UIScrollView) {
        assignContent()
    }

    open func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if let layout = self.layout as? ScalingLayoutProtocol, layout.getScale() != scrollView.zoomScale {
            layout.setScale(scrollView.zoomScale)
            self.layout.invalidateLayout()
            assignContent()
        }
    }

    open func collectionView(_: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt _: IndexPath) {
        // cells might have been hidden by hideLingeringCells() so we must un-hide them.
        cell.isHidden = false
    }

    public func scrollViewDidEndZooming(_: UIScrollView, with _: UIView?, atScale _: CGFloat) {}
}
