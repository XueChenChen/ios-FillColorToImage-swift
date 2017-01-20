//
//  ImageData.swift
//  colorfill
//
//  Created by qi on 05/12/2016.
//  Copyright © 2016 Qi. All rights reserved.
//

import UIKit

class ImageData {
    private let width:Int
    private let height:Int
    private let data:UnsafeMutablePointer<UInt32>
    
    private let whiteValue:UInt32=0xFFFFFFFF
    
    init(width:Int,height:Int, data:UnsafeMutablePointer<UInt32>) {
        self.width=width
        self.height=height
        self.data=data
    }
    
    func fillColor(x:Int,y:Int, color:UIColor){
        
//        for i in 0..<2000 {
//            self.data.advanced(by:i).pointee = 0xFF0000FF
//        }
        
        var stack=[(Int,Int)]()
        
        if needFill(x: x, y: y) {
            stack.append((x,y))
        }
        
        while stack.count>0 {
            let p=stack.popLast()!
            setColorAt(x: p.0, y: p.1, colorValue: self.translateValue(color:color))
            let ptList=[(p.0-1,p.1),
                    (p.0+1,p.1),
                    (p.0,p.1-1),
                    (p.0,p.1+1)]
            
            for pt in ptList {
                if needFill(x: pt.0, y: pt.1)
                    && self.getColorAt(x: pt.0, y: pt.1) != self.translateValue(color: color) {
                    stack.append(pt)
                }
                else {
                    continue
                }
            }
        }
    }
    
    
    func needFill(x:Int,y:Int)->Bool{
        
        if x<=0 || x>=self.width || y<=0 || y>=self.height {
            return false
        }
        
        let colorValue=getColorAt(x:x, y:y)
//        if colorValue==self.whiteValue{
        if isNearWhite(color:colorValue){
            return true
        }
        else {
            return false
        }
        
        
    }
    
    private func getColorAt(x:Int,y:Int)->UInt32 {
        return self.data.advanced(by: x+y*self.width).pointee
    }
    
    private func setColorAt(x:Int,y:Int,colorValue:UInt32){
        self.data.advanced(by: x+y*self.width).pointee=colorValue
    }
    
    private func translateValue(color:UIColor)->UInt32{
        var ret:UInt32=0
        
        for c in (color.cgColor.components?.reversed())! {
            ret = ret << 8
            ret += UInt32(c)*255
        }
        
        return ret
    }
    
    
    func isNearWhite(color:UInt32)->Bool{
//        if color==0xFFFFFFFF {
//            return true
//        }
//        else {
//            return false
//        }
        
        let delta=UInt32(0.3*0xFF)
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

    
    
}
