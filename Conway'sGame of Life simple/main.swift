//
//  main.swift
//  Conway'sGame of Life simple
//
//  Created by リノ on 2019/12/21.
//  Copyright © 2019 hikiko. All rights reserved.
//

import Foundation

//ライフゲームの基礎データ[X軸[Y軸]] 要素０で初期化するなら初期値は不要　リスクのある使い方なので注意。
var lifeData:[[Bool]]

//マップを生成してくれる 引数　X軸,Y軸,値生成方法(デフォルはランダム)省略可
func mapCreate(Xjiku x:Int,Yjiku y:Int,seisei s:()->Bool = {Bool.random()} ) -> [[Bool]] {
    //上書きしてしまうので、初期値を入れたほうが安全
    var map = [[Bool]]()
    for _ in 0..<x {
        //一度に列を入れるために一度変数に入れる。
        var yjiku = [Bool]()
        for _ in 0..<y {
            //値生成部分
            yjiku.append(s())
        }
        map.append(yjiku)
    }
    return map
}


lifeData = mapCreate(Xjiku: 5, Yjiku:5 )
print(lifeData)

//ブロック状に表示してくれる。
func lifeView(world w:[[Bool]]) {
    print("現在の世界を表示します")
    //今回は生存は、黒、絶滅は白の記号で表示していく
    let life = "⬛️"
    let death = "⬜️"
    //生存者集を計算数変数
    var ikinokori = 0
    print("|", separator: "", terminator: "")
    for y in 0..<w[0].count{
        //列番号の表示 きれいに表示されるのは,10*10くらいまで
        print("\(y%10)|", separator: "", terminator: "")
    }
    print("")
    //ループを回して、マップを読み込む
    for y in 0..<w[0].count {
        for x in 0..<w.count{
            //値を把握して、どちらを表示するか決める
            if w[x][y] == true {
                ikinokori += 1
                print(life, separator: "", terminator: "")
            }else{
                print(death, separator: "", terminator: "")
            }
        }
        //改行コード　端まできたら改行する
        //行番号の表示
        print(":\(y)", separator: "", terminator: "\n")
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
    
    //返値を保存する場所 生命は減っていく傾向にあるのでfalse指定{false}。
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


lifeView(world: lifeData)
lifeData = nextLife(world: lifeData)
print("一年進めました")
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

//クロージャの操作を変える場合　{_ in true}　{_ in false}　を試しに使って下さい


//lifeData = [[false, false, true, false, false], [false, true, true, false, false], [true, true, true, false, true], [false, true, false, true, false], [true, false, true, false, false]]

lifeView(world: lifeData)
print("一番下の行を反転させます")
//一番下の行を反転させる
for i in 0..<lifeData[0].count {
    //&をつけて、参照渡し。
    kamiNoTe(world: &lifeData, point: (i,lifeData.count - 1),sayou: {!$0})
}



lifeView(world: lifeData)




print("ここから、ゲームモード")
//世界の大きさ
var ookisa:Int = 0
//ゲームモードのマップ
var gameMap:[[Bool]]

repeat {
    print("数字を入力してください1~50まで")
    //readLineで入力を受け付ける
    let readOokisa = readLine() ?? "0"
    ookisa = Int(readOokisa) ?? 0
}while ookisa == 0 || ookisa > 50

print("\(ookisa)を受け取りました。マップを製造します")
gameMap = mapCreate(Xjiku: ookisa, Yjiku: ookisa)
lifeView(world: gameMap)

//操作するループ　next change changeAll view exti
//文字入力用文字列
var readString = ""
repeat{
    print("操作を英字で入力して下さい。\n next:次の時代に進みます \n change:対象のマスを変更します \n changeAll:すべてを変更します　\n view:現在の状態を表示します　即時実行されます　\n exit:終了します")
    readString = readLine() ?? ""
    //switch文で条件分岐
    switch readString {
    case "next":
        var readKaisuu = ""
        var nextkaisuu = 0
        repeat {
            print("どれくらい進めますか？1回以上")
            readKaisuu = readLine() ?? "0"
            nextkaisuu = Int(readKaisuu) ?? 0
        }while nextkaisuu == 0
        for _ in 0..<nextkaisuu{
            gameMap = nextLife(world: gameMap)
        }
    case "change":
        //x軸
        let xMax = gameMap.count
        var xjiku:Int = xMax
        repeat {
            print("x軸を入力して下さい。最大値は\(xMax - 1)です")
            let readX = readLine() ?? ""
            xjiku = Int(readX) ?? xjiku
        }while xjiku >= xMax
        //y軸
        let yMax = gameMap[0].count
        var yjiku:Int = yMax
        repeat {
            print("y軸を入力して下さい。最大値は\(yMax - 1)です")
            let ready = readLine() ?? ""
            yjiku = Int(ready) ?? yjiku
        }while yjiku >= yMax
        //操作部
        print("x:\(xjiku) y:\(yjiku)を、反転させます")
        kamiNoTe(world: &gameMap, point: (xjiku,yjiku))
    case "changeAll":
        print("世界を再構成します")
        //新たにマップを作って上書きする。
        gameMap = mapCreate(Xjiku: ookisa, Yjiku: ookisa)
    case "view":
        lifeView(world: gameMap)
    case "exit":
        print("終了します")
    default:
        print("指示を理解できません")
    }
    //exitが入力されない限り繰り返す
}while readString != "exit"



