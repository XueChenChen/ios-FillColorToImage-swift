//
//  ViewController.swift
//  colorfill
//
//  Created by 齐 on 2016/12/4.
//  Copyright © 2016年 Qi. All rights reserved.
//

import UIKit
import CoreImage
import CoreGraphics

class ViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate {
    
    @IBOutlet weak var colorsCollectionView: UICollectionView!
    @IBOutlet weak var imageView: UIImageView!
    
    private let colorList=ColorList()
    private var selectedColor:UIColor?
    private var orgImg:UIImage?
    var imgStack=[UIImage?]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.orgImg=self.imageView.image
        print(self.imageView.image?.cgImage?.bitsPerPixel ?? Int())
        let tap=UITapGestureRecognizer(target: self, action: #selector(ViewController.onTap(rec:)))
        self.imageView.isUserInteractionEnabled=true
        self.imageView.addGestureRecognizer(tap)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return self.colorList.colors.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cellId="ColorCell"
        let color=self.colorList.colors[indexPath.row]
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ColorCell
        cell.color=color
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let color=self.colorList.colors[indexPath.row]
        self.selectedColor=color
        //        if let newImg=self.addColorToImg(self.imageView.image,fillColor: self.selectedColor) {
        //            self.imgStack.append(self.imageView.image)
        //            self.imageView.image=newImg
        //        }
        //        else{
        //            print("some ting error")
        //        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let color=self.colorList.colors[indexPath.row]
        if self.selectedColor==color{
            self.selectedColor=nil
        }
    }
    
    func onTap(rec:UITapGestureRecognizer){
        print(rec)
        let touchPosition = rec.location(in: imageView)
        print(touchPosition)
        let positionInImage=self.transPosition(imageViewSize:imageView.bounds.size, imageSize:(self.imageView.image?.size)!, positionInImageView:touchPosition)
        print(positionInImage)
        
        if let newImg=self.imageView.image?.fillColorToPosition(position:positionInImage, color:self.selectedColor){
            self.imgStack.append(imageView.image)
            self.imageView.image=newImg
        }
        
    }
    
    
    
    
    func isNearWhite(color:UInt32)->Bool{
        let delta=UInt32(0.6*0xFF)
        var c=color
        var falseCount=0
        for _ in 0..<3 {
            c=c>>4
            if 0xFF-(c&0xFF)>delta {
                falseCount+=1
                if falseCount>1 {
                    return false
                }
            }
        }
        return true
    }
    
    
    func transPosition(imageViewSize:CGSize, imageSize:CGSize, positionInImageView:CGPoint)->CGPoint {
        
        var imgPosition=CGPoint(x: 0, y: 0)
        
        var positionInImage=positionInImageView
        
        var imageScaledSize=imageViewSize
        
        if imageSize.width/imageSize.height>imageViewSize.width/imageSize.height {
            let imageScaledHeight=imageSize.height*imageViewSize.width/imageSize.width
            imgPosition.y=(imageViewSize.height-imageScaledHeight)/2.0
            positionInImage.y -= imgPosition.y
            imageScaledSize.height=imageScaledHeight
            
        }else {
            let imageScaledWidth=imageSize.width*imageViewSize.height/imageSize.height
            imgPosition.x=(imageViewSize.width-imageScaledWidth)/2.0
            positionInImage.x -= imgPosition.x
            imageScaledSize.width=imageScaledWidth
        }
        
        //        positionInImage.y=imageScaledSize.height-positionInImage.y
        
        positionInImage.x *= imageSize.width/imageScaledSize.width
        positionInImage.y *= imageSize.width/imageScaledSize.width
        return positionInImage
    }
    
    
}


extension UIImage{
    
    func fillColorToPosition(position:CGPoint, color:UIColor?)->UIImage?{
        if let color=color {
            guard let imgRef=self.cgImage?.copy() else {
                return nil
            }
            
            let pixelData=UnsafeMutablePointer<UInt32>.allocate(capacity: imgRef.width*imgRef.height)
            let colorSpace=CGColorSpaceCreateDeviceRGB()
            guard let context=CGContext(data: pixelData,
                                        width: imgRef.width,
                                        height: imgRef.height,
                                        bitsPerComponent: imgRef.bitsPerPixel/4,
                                        bytesPerRow: imgRef.bytesPerRow,
                                        space: colorSpace,
                                        bitmapInfo: imgRef.bitmapInfo.rawValue)
                else {
                    return nil
            }
            
            context.draw(imgRef, in: CGRect(x:0,y:0,width:imgRef.width,height:imgRef.height))
            
            let imageData=ImageData(width: imgRef.width, height: imgRef.height, data: pixelData)
            imageData.fillColor(x: Int(position.x), y: Int(position.y), color: color)
            
            guard let newCGImg=context.makeImage() else {
                return nil
            }
            
            let newImg=UIImage(cgImage: newCGImg)
            
            return newImg
        }
        else {
            return nil
        }
    }

}



class ColorList{
    let colors:[UIColor]
    
    init(){
        colors=[UIColor.red,UIColor.blue,UIColor.green,UIColor.brown, UIColor.cyan]
    }
}
