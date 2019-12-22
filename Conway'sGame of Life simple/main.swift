//
//  main.swift
//  Conway'sGame of Life simple
//
//  Created by リノ on 2019/12/21.
//  Copyright © 2019 hikiko. All rights reserved.
//

import Foundation

//ライフゲームの基礎データ[X軸[Y軸]] 要素０で初期化するなら初期値は不要
var lifeData:[[Bool]]

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

lifeData = mapCreate(Xjiku: 10, Yjiku:10 )
//print(lifeData)

//ブロック状に表示してくれる。
func lifeView(world w:[[Bool]]) {
    print("現在の世界を表示します")
    let life = "⬛️"
    let death = "⬜️"
    var ikinokori = 0
    for x in 0..<w.count{
        for y in 0..<w[x].count {
            if w[x][y] == true {
                ikinokori += 1
                print(life, separator: "", terminator: "")
            }else{
                print(death, separator: "", terminator: "")
            }
        }
        //改行コードの代わり
        print("")
    }
    print("現在生き残りは、\(ikinokori)です。約\(ikinokori*100/(w.count * w[0].count))%です。")
}


lifeView(world: lifeData)

//1ターン進める　今回は、生存条件を変更不可能にする。
func nextLife(world w:[[Bool]]) -> [[Bool]] {

    //毎回読み込ませると時間がかかるので、定数として読み込ませる
    let xCount = w.count
    let yCount = w[0].count
    
    //周辺の密度を保存する。型がIntのため、mapCreateを使わない。端っこかどうかの計算をなくすために、一マスづつ前後に大きくしています。両側ぶんで２足します
    var kamitudo:[[Int]] = Array(repeating:{Array(repeating: 0, count: yCount + 2)}(), count: xCount + 2)
    
    
    //返値を保存する場所 生命は減っていく傾向にあるのでfalse始まり。
    //    var nextWorld = Array(repeating: {Array(repeating: false, count: yCount)}(), count: xCount)
    var nextWorld  = mapCreate(Xjiku: xCount, Yjiku: yCount, seisei: {false})
    
    //引数worldを読み込み過密状況を調査する
    for x in 0..<xCount {
        for y in 0..<yCount{
            //マスに生命が存在したら、周辺の過密度を上昇させる
            if w[x][y] == true{
                //過密度を書き込むループ 9方向に加算する
                //　ハードコード(直接書き込む事)したほうが早いが、読みづらいのでforループを使う
                for i in 0...2 {
                    for t in 0...2{
                        kamitudo[x+i][y+t] += 1
                    }
                }
                //自分は隣接する個数に含まれないので、１減らす
                kamitudo[x+1][y+1] -= 1
            }
        }
    }
    
    // kamitudo(過密度)に基づき生存判定をしていく
    for x in 1...xCount{
        for y in 1...yCount {
            switch kamitudo[x][y] {
                //３なら誕生
            case 3 :
                nextWorld[x-1][y-1] = true
                //２なら、マスに生命がいれば生存させる
            case 2 :
                if w [x-1][y-1] == true {
                    nextWorld[x-1][y-1] = true
                }
                //それ以外は、基礎値でfalseのまま
            default:
                //xcodeのエラー抑止　*defaultに何も設定しないとエラーが出ます。
                {}()
            }
        }
    }
    
    return nextWorld
}



lifeData = nextLife(world: lifeData)
lifeView(world: lifeData)
/*
for _ in 0..<100{
    lifeData = nextLife(world: lifeData)
}
lifeView(world: lifeData)
*/

//特定のマスを指示してデータを操作する関数 worldは現在の状態、pointは編集する場所(X軸,Y軸)、sayouは、セルに行う操作　デフォルトは、反転
func kamiNoTe(world w :inout [[Bool]],point p :(Int,Int),sayou s:(Bool)->Bool = {!$0}) {
    w[p.0][p.1] = s(w[p.0][p.1])
}


//一番下の行を反転させる
for i in 0..<lifeData[0].count {
    kamiNoTe(world: &lifeData, point: (lifeData.count - 1,i))
}


lifeView(world: lifeData)
