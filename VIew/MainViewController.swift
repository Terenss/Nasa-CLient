//
//  ViewController.swift
//  Nasa-Client
//
//  Created by Dmitrii on 09.08.2021.
//

import UIKit
import PromiseKit
import NVActivityIndicatorView
import Kingfisher

class MainViewController: UIViewController {
    
    @IBOutlet var roverButton: UIButton!
    @IBOutlet var cameraButton: UIButton!
    @IBOutlet var calendarButton: UIButton!
    @IBOutlet var photoView: UIView!
    @IBOutlet var roverTextField: UITextField!
    @IBOutlet var cameraTextField: UITextField!
    @IBOutlet var calendarTextField: UITextField!
    @IBOutlet var quantityLabel: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var stackView: UIStackView!
    
    var detailImageViewController: DetailImageController?
    
    public var activityIndicator: NVActivityIndicatorView?
    public var spinner: NVActivityIndicatorView?
    public var requestPage = 1
    
    private var noResultFoundView = UIImageView(image: UIImage(named: "noResult"))
    
    public var datePicker = UIDatePicker()
    public var roverAndCameraPicker = UIPickerView()
    public var chosenDate = Date()
    public var chosenRover = Rovers.Curiosity
    public var chosenCamera = Cameras.fhaz
    
    fileprivate let refreshControl = UIRefreshControl()
    
    fileprivate var receivedPhotos = [Photo]()
    
    private var itemSize: CGSize = .zero
    
    enum Pickers {
        case rover
        case camera
        case date
    }
    
    var chosenPicker: Pickers?
    public let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())
    
    public var chosenRoverIndex: Int {
        switch chosenRover {
        case .Curiosity: return 0
        case .Opportunity: return 1
        case .Spirit: return 2
        }
    }
    
    private let footerIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.white)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        roverAndCameraPicker.delegate = self
        roverAndCameraPicker.dataSource = self
        registerNotifications()
        loadingViewsSetup()
        chosenDate = self.yesterday ?? Date()
        setupPickersAndUI()
        setupDatePicker()
        getData()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "PhotosCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CollectionViewCell")
        collectionView.register(CollectionViewFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "Footer")
                (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.footerReferenceSize = CGSize(width: collectionView.bounds.width, height: 50)
        
        refreshControlSetUp()
    }
    
    deinit {
        removeKeyboardNotifications()
    }
    
    @objc func refreshControlSetUp() {
        
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = refreshControl
        } else {
            collectionView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        refreshControl.tintColor = UIColor(red:0.25, green:0.72, blue:0.85, alpha:1.0)
        refreshControl.attributedTitle = NSAttributedString(string: "Reloading Data...")
    }
    
    
    
    @IBAction func chooseRover(_sender: Any) {
        chosenPicker = .rover
        self.cameraButton.isUserInteractionEnabled = true
        self.calendarButton.isUserInteractionEnabled = false
        self.cameraButton.isUserInteractionEnabled = false
        self.cameraTextField.isUserInteractionEnabled = false
        self.roverTextField.isUserInteractionEnabled = true
        self.calendarTextField.isUserInteractionEnabled = false
        self.roverTextField.becomeFirstResponder()
    }
    
    @IBAction func chooseCamera(_sender: Any) {
        chosenPicker = .camera
        self.cameraButton.isUserInteractionEnabled = true
        self.roverButton.isUserInteractionEnabled = false
        self.calendarButton.isUserInteractionEnabled = false
        self.cameraTextField.isUserInteractionEnabled = true
        self.roverTextField.isUserInteractionEnabled = false
        self.calendarTextField.isUserInteractionEnabled = false
        self.cameraTextField.becomeFirstResponder()
    }
    
    @IBAction func chooseDate(_sender: Any) {
        chosenPicker = .date
        self.calendarButton.isUserInteractionEnabled = true
        self.roverButton.isUserInteractionEnabled = false
        self.cameraButton.isUserInteractionEnabled = false
        self.cameraTextField.isUserInteractionEnabled = false
        self.roverTextField.isUserInteractionEnabled = false
        self.calendarTextField.isUserInteractionEnabled = true
        self.calendarTextField.becomeFirstResponder()
    }
}


extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.receivedPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as? PhotosCollectionViewCell {
            cell.setModelToUI(with: receivedPhotos[indexPath.item])
            
            cell.layer.borderWidth = 1.0
            cell.layer.borderColor = UIColor.gray.cgColor
            return cell
        }
        return UICollectionViewCell()
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.collectionView.deselectItem(at: indexPath, animated: true)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detailImageController = storyboard.instantiateViewController(withIdentifier: "DetailImageController") as? DetailImageController {
            detailImageController.photoModel = receivedPhotos[indexPath.item]
            self.navigationController?.pushViewController(detailImageController, animated: true)
        }
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item + 1 == (25 * self.requestPage) {
            footerIndicatorView.startAnimating()
            self.requestPage += 1
            getData()
        } else {
            footerIndicatorView.stopAnimating()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
            if kind == UICollectionView.elementKindSectionFooter {
                let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Footer", for: indexPath)
                footer.addSubview(footerIndicatorView)
                footerIndicatorView.frame = CGRect(x: 0, y: 0, width: collectionView.bounds.width, height: 50)
                return footer
            }
            return UICollectionReusableView()
        }
}
extension MainViewController {
    
    @objc func refreshData() {
        self.collectionView.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    
    @objc func getData() {
        
        firstly {
            Provider.getDataFrom(rover: chosenRover.rawValue, camera: chosenCamera.rawValue, date: chosenDate, page: requestPage)
        } .done {
            [weak self] (response) in
            guard let self = self else {return}
            if !response.photos.isEmpty {
                if self.requestPage == 1 {
                    self.receivedPhotos.removeAll()
                }
                response.photos.forEach({self.receivedPhotos.append($0)})
                self.noResultFoundView.isHidden = true
                self.collectionView.isHidden = false
                self.quantityLabel.text = "\(self.receivedPhotos.count) photos"
            } else {
                self.requestPage = 1
                self.quantityLabel.text = "no photos"
                self.receivedPhotos.removeAll()
                self.collectionView.isHidden = true
                self.noResultFoundView.isHidden = false
            }
            self.activityIndicator?.stopAnimating()
            self.collectionView.reloadData()
            }
            .catch { (error) in
            debugPrint(error.localizedDescription)
        }
    }
}

extension MainViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch chosenPicker {
        case .rover: return Rovers.allCases.count
        case .camera: return chosenRover.roverCameras.count
        default: return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch chosenPicker {
        case .rover: return Rovers.allCases[row].rawValue
        case .camera: return Rovers.allCases[chosenRoverIndex].roverCameras[row].fullName
        default: return ""
        }
    }
}

extension MainViewController {
    func setupPickersAndUI() {
        [roverButton, cameraButton, calendarButton].forEach({
            $0!.layer.cornerRadius = 7; $0!.layer.borderWidth = 2;
            $0!.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        })
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {
            //Fallback on earlier versions
        }
        datePicker.datePickerMode = .date
        calendarTextField.inputView = datePicker
        [roverTextField, cameraTextField].forEach({$0?.inputView = roverAndCameraPicker})
        [roverTextField, cameraTextField, calendarTextField].forEach({ $0?.isUserInteractionEnabled = false; $0?.inputAccessoryView = toolBar})
        roverTextField.text = chosenRover.rawValue
        cameraTextField.text = chosenCamera.rawValue
        let dateFomatter = DateFormatter()
        dateFomatter.dateFormat = "dd.MM.yy"
        calendarTextField.text = dateFomatter.string(from: chosenDate)
    }
    fileprivate func setupDatePicker() {
        let dateFomatter = DateFormatter()
        dateFomatter.dateFormat = "dd.MM.yy"
        switch chosenRoverIndex {
        case 0: datePicker.minimumDate = dateFomatter.date(from: "01.12.2011")
            datePicker.maximumDate = yesterday
        case 1: datePicker.minimumDate = dateFomatter.date(from: "25.01.2004")
            datePicker.maximumDate = dateFomatter.date(from: "09.06.2018")
        case 2: datePicker.minimumDate = dateFomatter.date(from: "05.01.2004")
            datePicker.maximumDate = dateFomatter.date(from: "01.03.2010")
        default: break
        }
    }
    
    fileprivate func loadingViewsSetup() {
        let nvRect = CGRect(x: self.view.frame.origin.x, y: self.view.frame.height / 2 - self.view.frame.height / 6, width: self.view.frame.width, height: self.view.frame.height / 3)
        self.activityIndicator = NVActivityIndicatorView(frame: nvRect, type: .ballDoubleBounce, color: .systemBlue, padding: nil)
        self.view.addSubview(activityIndicator ?? UIView())
    }
    
    fileprivate var toolBar: UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(ignoreChangesCancelButton))
        let saveButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveChosenDataAndRequestToServerButton))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([cancelButton, space, saveButton], animated: false)
        return toolbar
    }
    
    @objc private func ignoreChangesCancelButton() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        [cameraButton,roverButton, calendarButton].forEach({$0?.isUserInteractionEnabled = true})
        [roverTextField, cameraTextField, calendarTextField].forEach({$0?.isUserInteractionEnabled = false})
        self.view.endEditing(true)
        switch chosenPicker {
        case .rover:
            self.chosenRover = Rovers.allCases[roverAndCameraPicker.selectedRow(inComponent: 0)]
            self.roverTextField.text = Rovers.allCases[roverAndCameraPicker.selectedRow(inComponent: 0)].rawValue
            self.roverAndCameraPicker.selectRow(self.chosenRoverIndex, inComponent: 0, animated: false)
            self.chosenCamera = Cameras.fhaz
            self.cameraTextField.text = chosenCamera.rawValue
            
            switch chosenRover{
            case .Curiosity: self.chosenDate = self.yesterday ?? Date()
            case .Opportunity: self.chosenDate = dateFormatter.date(from: "26.01.2004") ?? Date()
            case .Spirit: self.chosenDate = dateFormatter.date(from: "05.01.2004") ?? Date()
            }
            self.calendarTextField.text = dateFormatter.string(from: chosenDate)
        case .camera:
            self.chosenCamera = chosenRover.roverCameras[roverAndCameraPicker.selectedRow(inComponent: 0)]
            self.cameraTextField.text = chosenRover.roverCameras[roverAndCameraPicker.selectedRow(inComponent: 0)].rawValue
            self.roverAndCameraPicker.selectRow(roverAndCameraPicker.selectedRow(inComponent: 0), inComponent: 0, animated: false)
        case .date:
            calendarTextField.text = dateFormatter.string(from: datePicker.date)
            self.chosenDate = datePicker.date
        default: break
        }
        
    }
    
    @objc public func saveChosenDataAndRequestToServerButton () {
        self.activityIndicator?.startAnimating()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        [cameraButton,roverButton, calendarButton].forEach({$0?.isUserInteractionEnabled = true})
        [roverTextField, cameraTextField, calendarTextField].forEach({$0?.isUserInteractionEnabled = false})
        switch chosenPicker {
        case .rover:
            self.chosenRover = Rovers.allCases[roverAndCameraPicker.selectedRow(inComponent: 0)]
            self.roverTextField.text = Rovers.allCases[roverAndCameraPicker.selectedRow(inComponent: 0)].rawValue
            self.roverAndCameraPicker.selectRow(self.chosenRoverIndex, inComponent: 0, animated: false)
            self.chosenCamera = Cameras.fhaz
            self.cameraTextField.text = chosenCamera.rawValue
            
            switch chosenRover{
            case .Curiosity: self.chosenDate = self.yesterday ?? Date()
            case .Opportunity: self.chosenDate = dateFormatter.date(from: "26.01.2004") ?? Date()
            case .Spirit: self.chosenDate = dateFormatter.date(from: "05.01.2004") ?? Date()
            }
            self.calendarTextField.text = dateFormatter.string(from: chosenDate)
        case .camera:
            self.chosenCamera = chosenRover.roverCameras[roverAndCameraPicker.selectedRow(inComponent: 0)]
            self.cameraTextField.text = chosenRover.roverCameras[roverAndCameraPicker.selectedRow(inComponent: 0)].rawValue
            self.roverAndCameraPicker.selectRow(roverAndCameraPicker.selectedRow(inComponent: 0), inComponent: 0, animated: false)
        case .date:
            calendarTextField.text = dateFormatter.string(from: datePicker.date)
            self.chosenDate = datePicker.date
        default: break
        }
        self.requestPage = 1
        self.setupDatePicker()
        self.getData()
    }
}
extension MainViewController {
    private func registerNotifications () {
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc private func keyboardWillShow (_ notification: Notification) {
        let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        let keyboardHeight = keyboardFrame.cgRectValue.height
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        print(keyboardHeight)
    }
    @objc private func keyboardWillHide(_ notification: Notification) {
        collectionView.contentInset = .zero
    }
    
    private func removeKeyboardNotifications () {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
}

