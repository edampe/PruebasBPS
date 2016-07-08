//
//  ViewController.swift
//  PruebasIOSBPS
//
//  Created by Desarrollo 4 on 7/07/16.
//  Copyright © 2016 BPS. All rights reserved.

import UIKit
import Alamofire

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate {
    
    @IBOutlet weak var _TblSearchResults: UITableView!
    let _Cell = "cellReporte"
    var _SearchController: UISearchController!
    var _MessageFrame = UIView()
    var _ActivityIndicator = UIActivityIndicatorView()
    var _StrLabel = UILabel()
    var _Llenar = true
    var _DatosBusqueda =  Array<DatosBusqueda>()
    var _HistorialBusqueda =  Array<String>()
    
    private var _HistorialURL: NSURL = {
        let _FileManager = NSFileManager.defaultManager()
        let _DocumentDirectoryURLs = _FileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask) as [NSURL]
        let _DocumentDirectoryURL = _DocumentDirectoryURLs.first
        return _DocumentDirectoryURL!.URLByAppendingPathComponent("historial.items")
    }()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadHistorial()
        self._TblSearchResults.registerNib(UINib(nibName: "TVCResultBusqueda", bundle: nil), forCellReuseIdentifier: _Cell)
        
        _TblSearchResults.delegate = self
        _TblSearchResults.dataSource = self
        
        configureSearchController()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: UITableView Delegate and Datasource functions
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var _Count = 0
        if !_Llenar {
            _Count = _DatosBusqueda.count
            
        }else{
            _Count = _HistorialBusqueda.count
        }
        
        return _Count
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
      let cell = tableView.dequeueReusableCellWithIdentifier(self._Cell, forIndexPath: indexPath) as! TVCResultBusqueda
        if _Llenar {
            self._Llenar = false
            
            buscarDatosInternet(_HistorialBusqueda[indexPath.row])
            
            cell.textLabel?.text = _HistorialBusqueda[indexPath.row]
            cell._LabelTitulo?.text = nil
            cell._LabelPrecio?.text = nil
            cell._LabelUbicacion?.text = nil
            cell._ImgProducto?.image = nil
            
        }

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(self._Cell, forIndexPath: indexPath) as! TVCResultBusqueda
        
        if !_Llenar {
            cell._LabelTitulo?.text = _DatosBusqueda[indexPath.row]._Tiulo
            cell._LabelPrecio?.text = _DatosBusqueda[indexPath.row]._Precio
            cell._LabelUbicacion?.text = _DatosBusqueda[indexPath.row]._Ubicacion
            if _DatosBusqueda[indexPath.row]._ImgLocal != nil{
                cell._ImgProducto?.image = UIImage(data: _DatosBusqueda[indexPath.row]._ImgLocal!)
                
            }else {
                cell._ImgProducto?.image = UIImage(named: "Imagen-no-disponible")
            }
            cell.textLabel?.text = nil
        }else{
            cell.textLabel?.text = _HistorialBusqueda[indexPath.row]
            cell._LabelTitulo?.text = nil
            cell._LabelPrecio?.text = nil
            cell._LabelUbicacion?.text = nil
            cell._ImgProducto?.image = nil

        }
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100.0
    }
    
    
    // MARK: Custom functions
    func progressBarDisplayer(msg:String, _ indicator:Bool ) {
        _StrLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 200, height: 50))
        _StrLabel.text = msg
        _StrLabel.textColor = UIColor.whiteColor()
        _MessageFrame = UIView(frame: CGRect(x: view.frame.midX - 90, y: view.frame.midY - 25 , width: 180, height: 50))
        _MessageFrame.layer.cornerRadius = 15
        _MessageFrame.backgroundColor = UIColor(white: 0, alpha: 0.7)
        if indicator {
            _ActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
            _ActivityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            _ActivityIndicator.startAnimating()
            _MessageFrame.addSubview(_ActivityIndicator)
        }
        _MessageFrame.addSubview(_StrLabel)
        view.addSubview(_MessageFrame)
    }
    
    
    func configureSearchController() {
        // Initialize and perform a minimum configuration to the search controller.
        _SearchController = UISearchController(searchResultsController: nil)
        _SearchController.searchResultsUpdater = self
        _SearchController.dimsBackgroundDuringPresentation = false
        _SearchController.searchBar.placeholder = "Search here..."
        _SearchController.searchBar.delegate = self
        _SearchController.searchBar.sizeToFit()
        _SearchController.searchBar.frame.size.width = self.view.frame.size.width
        
        // Place the search bar view to the tableview headerview.
        _TblSearchResults.tableHeaderView = _SearchController.searchBar
    }
    
    func saveHistorial(){
        let _ItemsHistorial = _HistorialBusqueda as NSArray
        if _ItemsHistorial.writeToURL(self._HistorialURL, atomically: true){
            print("Guardo")
        }else{
            print("yucas")
        }
    }
    
    func loadHistorial(){
        if let _ItemsBusqueda = NSArray(contentsOfURL: self._HistorialURL) as? [String]{
            self._HistorialBusqueda = _ItemsBusqueda
        }
    }
    
    // MARK: UISearchBarDelegate functions
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        _TblSearchResults.reloadData()
    }
    
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self._Llenar = true

        _TblSearchResults.reloadData()
    }
    
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self._Llenar = false
        var _BusquedaRepedita = false
        
        for _Str in _HistorialBusqueda{
            if _Str == searchBar.text!{
                _BusquedaRepedita = true
            }
        }
        if !_BusquedaRepedita{
            _HistorialBusqueda.append(searchBar.text!)
        }
        saveHistorial()
        buscarDatosInternet(searchBar.text!)
        

        
    }
    
    func buscarDatosInternet (_StrBusqueda: String) {
        
        _DatosBusqueda = Array<DatosBusqueda>()
        
        progressBarDisplayer("Buscando producto", true)
        
        let _UrlBase = "http://www.liverpool.com.mx/tienda?s="
        
        let _Url = _UrlBase + _StrBusqueda + "&format=json"
        Alamofire.request(.GET, _Url) .validate() .responseJSON
            { response in
                switch(response.result)
                {
                case .Success:
                    
                    if let JSON = (response.result.value) as? NSDictionary
                    {
                        let _ArrayDatosBuqueda = ((((JSON.valueForKey("contents") as? Array<NSDictionary>)![0]
                            .valueForKey("mainContent") as? Array<NSDictionary>)![2]
                            .valueForKey("contents") as? Array<NSDictionary>)![0]
                            .valueForKey("records") as? Array<NSDictionary>)
                        
                        if _ArrayDatosBuqueda?.count > 0 {
                            
                            
                            for _Datos in _ArrayDatosBuqueda!{
                                
                                
                                let atributosProducto = ((_Datos.valueForKey("records") as? Array<NSDictionary>)![0]
                                    .valueForKey("attributes") as? NSDictionary)
                                
                                
                                let _Producto: DatosBusqueda = DatosBusqueda()
                                
                                _Producto._Tiulo = (atributosProducto!.valueForKey("product.displayName") as? Array<String>)![0]
                                _Producto._Precio = (atributosProducto!.valueForKey("sku.sale_Price") as? Array<String>)![0]
                                _Producto._Ubicacion = (atributosProducto!.valueForKey("ancestorCategories.displayName") as? Array<String>)![0]
                                if let _ImgProducto = (atributosProducto!.valueForKey("product.smallImage") as? Array<String>) {
                                    if let _Image = NSData(contentsOfURL: NSURL(string: _ImgProducto[0])!){
                                        _Producto._ImgLocal = _Image
                                    }
                                    
                                }else if let _ImgProducto = (atributosProducto!.valueForKey("sku.largeImage") as? Array<String>) {
                                    if let _Image = NSData(contentsOfURL: NSURL(string: _ImgProducto[0])!){
                                        _Producto._ImgLocal = _Image
                                    }
                                }else if let _ImgProducto = (atributosProducto!.valueForKey("sku.smallImage") as? Array<String>) {
                                    if let _Image = NSData(contentsOfURL: NSURL(string: _ImgProducto[0])!){
                                        _Producto._ImgLocal = _Image
                                    }
                                }else if let _ImgProducto = (atributosProducto!.valueForKey("product.largeImage") as? Array<String>) {
                                    if let _Image = NSData(contentsOfURL: NSURL(string: _ImgProducto[0])!){
                                        _Producto._ImgLocal = _Image
                                    }
                                }else if let _ImgProducto = (atributosProducto!.valueForKey("cdlImageLink") as? Array<String>){
                                    if let _Image = NSData(contentsOfURL: NSURL(string: _ImgProducto[0])!){
                                        _Producto._ImgLocal = _Image
                                    }
                                }
                                self._DatosBusqueda.append(_Producto)
                            }
                        }
                    }
                    self._TblSearchResults.reloadData()
                    self._SearchController.searchBar.resignFirstResponder()
                    
                case .Failure(let error):
                    print(error.localizedDescription)
                    
                }
                self._MessageFrame.removeFromSuperview()
                
        }
        
    }
    
    
    // MARK: UISearchResultsUpdating delegate function
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        // Reload the tableview.
        _TblSearchResults.reloadData()
    }
    
    
    // MARK: CustomSearchControllerDelegate functions
    
    func didStartSearching() {
        _TblSearchResults.reloadData()
    }
    
    
    func didTapOnSearchButton() {
        _TblSearchResults.reloadData()
        
    }
    
    
    func didTapOnCancelButton() {
              _TblSearchResults.reloadData()
    }
    
    
    func didChangeSearchText(searchText: String) {
        // Filter the data array and get only those countries that match the search text.
        
        _TblSearchResults.reloadData()
    }
    
    
    class DatosBusqueda {
        var _Tiulo : String?
        var _Precio : String?
        var _Ubicacion : String?
        var _ImgLocal: NSData?
        
        
    }
    
}

