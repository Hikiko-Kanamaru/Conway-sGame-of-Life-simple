//
//  main.swift
//  Conway'sGame of Life simple
//
//  Created by リノ on 2019/12/21.
//  Copyright © 2019 hikiko. All rights reserved.
//

import Foundation

//ライフゲームの基礎データ[X軸[Y軸]] 要素０で初期化するなら初期値は不要
var lifeDate:[[Bool]] = [[]]

//マップを生成してくれる 引数　X軸,Y軸,値生成方法(デフォルはランダム)省略可
func mapCreate(Xjiku x:Int,Yjiku y:Int,seisei s:()->Bool = {Bool.random()} ) -> [[Bool]] {
    var map = [[Bool]]()
    for _ in 0..<x {
        var yjiku = [Bool]()
        for _ in 0..<y {
            //値生成部分
            yjiku.append(s())
        }
        map.append(yjiku)
    }
    return map
}

lifeDate = mapCreate(Xjiku: 10, Yjiku: 5)
print(lifeDate)

//ブロック状に表示してくれる。
func <#name#>(<#parameters#>) -> <#return type#> {
    <#function body#>
}
