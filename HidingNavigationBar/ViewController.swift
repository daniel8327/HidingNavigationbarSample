//
//  ViewController.swift
//  HidingNavigationBar
//
//  Created by moonkyoochoi on 2021/01/12.
//
import HidingNavigationBar
import UIKit

class ViewController: UIViewController {

    var hidingNavBarManager: HidingNavigationBarManager?
    
    let identifier = "ACell"
    var collectionView: UICollectionView!
    var toolbar: UIToolbar!
    var listItems: [Int] = [1]
    @IBOutlet var imgOrig: UIImageView!
    @IBOutlet var imgEdit: UIImageView!
    @IBOutlet var imgCrop: UIImageView!
    
    let margin: CGFloat = 10
    let cellItemCount: CGFloat = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
//        let picker = UIImagePickerController()
//        picker.sourceType = .photoLibrary
//        picker.allowsEditing = true
//        picker.delegate = self
//
//        self.present(picker, animated: true)
        addData2()

        let flowLayout = UICollectionViewFlowLayout()
        //let flowLayout = STCollectionViewFlowLayout() // https://github.com/AnanthaKrish/StretchyCollectionView
        flowLayout.scrollDirection = .vertical
//        flowLayout.minimumLineSpacing = 10
//        flowLayout.minimumInteritemSpacing = 5
        
        flowLayout.sectionInset = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin) // CollectionView 의 전체 마진
        flowLayout.minimumLineSpacing = margin // 셀 아이템간의 라인 마진
        flowLayout.minimumInteritemSpacing = margin // 셀 아이템간의 측면 마진
        
        flowLayout.itemSize.width = floor((UIScreen.main.bounds.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right - ((cellItemCount - 1) * flowLayout.minimumInteritemSpacing)) / cellItemCount)
        flowLayout.itemSize.height = flowLayout.itemSize.width
        
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: flowLayout)
        
        // 셀 등록
        collectionView.register(UINib(nibName: identifier, bundle: nil), forCellWithReuseIdentifier: identifier)
        
        // 헤더 등록
        collectionView.register(UINib(nibName: "HeaderCell", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderCell")
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        view.addSubview(collectionView)
        
        //initRefreshControl()

        let extensionView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
        extensionView.layer.borderColor = UIColor.lightGray.cgColor
        extensionView.layer.borderWidth = 1
        extensionView.backgroundColor = UIColor(white: 230/255, alpha: 1)
        let label = UILabel(frame: extensionView.frame)
        label.text = "Extension View"
        label.textAlignment = NSTextAlignment.center
        extensionView.addSubview(label)
        
        toolbar = UIToolbar(frame: CGRect(x: 0, y: view.bounds.size.height - 80, width: view.bounds.width, height: 80))
        toolbar.barTintColor = UIColor.red
        view.addSubview(toolbar)
        
        hidingNavBarManager = HidingNavigationBarManager(viewController: self, scrollView: collectionView)
        
        hidingNavBarManager?.addExtensionView(extensionView)
        hidingNavBarManager?.manageBottomBar(toolbar)
        
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let height = scrollView.frame.height
        let contentSizeHeight = scrollView.contentSize.height
        let offset = scrollView.contentOffset.y
        print("scrollViewDidScroll offset: \(offset) height: \(height) contentSizeHeight: \(contentSizeHeight)")
        let reachedBottom = (offset + 200 + height >= contentSizeHeight)
        if reachedBottom {
            print("scrollViewDidScroll reached to bottom")
            let current = listItems.count
            addData2()
            //tableView.scrollToRow(at: IndexPath(row: current, section: 0), at: .top, animated: true)
            
            collectionView.reloadData()
            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                self.tableView.setContentOffset(CGPoint(x: 0, y: -104), animated: true)
//            }
            
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewDidEndDecelerating")
    }
    
    func initRefreshControl() {
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(addData(refreshControl:)), for: .valueChanged)
        rc.attributedTitle = NSAttributedString(string: "새로고침")
        collectionView.refreshControl = rc
    }
    
    @objc func addData(refreshControl: UIRefreshControl){
        
        addData2()
        
        refreshControl.endRefreshing()
        collectionView.reloadData()
    }
    
    func addData2() {
        
        let startIdx = listItems.last! + 1
        
        if startIdx > 300 {
            return
        }
        let endIdx = startIdx + 20
        for idx in startIdx ..< endIdx {
            listItems.append(idx)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        hidingNavBarManager?.viewWillAppear(animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        hidingNavBarManager?.viewDidLayoutSubviews()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        hidingNavBarManager?.viewWillDisappear(animated)
    }
    
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        hidingNavBarManager?.shouldScrollToTop()
        return true
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // MARK: UICollectionViewDelegate
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? ACell else {
            fatalError()
        }
        
        cell.label.text = "row \(listItems[(indexPath as NSIndexPath).row])"
        
        cell.layer.cornerRadius = 10

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderCell", for: indexPath) as? HeaderCell else { fatalError() }
            
            headerView.button.setTitle("zzzzzzz", for: .normal)
            headerView.backgroundColor = .white
            
            return headerView
            
        } else {
            fatalError()
        }
    }
    
    /// MARK : 컬렉션 뷰 헤더 높이
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: 100)
    }
}


// MARK: 이미지 픽커 델리게이트 메소드
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true) {
            
            self.imgOrig.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            self.imgEdit.image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
            self.imgCrop.image = info[UIImagePickerController.InfoKey.cropRect] as? UIImage
        }
    }
}

