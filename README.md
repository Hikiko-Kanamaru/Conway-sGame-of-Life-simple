# Conway-sGame-of-Life-simple
simple Game of Life swift
単純なライフゲームのコードです。
UIViewなどは、使わずに書いていきます。

マップデータは、多重配列[[Bool]]型を利用します。
機能は単純に、

1.マップを生成する

2.マップを表示する

3.1ターン進める

4.特定マスの値を変更する

以上の関数でできています。
制作した関数を使って
コマンドラインで遊ぶ機能が実装されています。

コマンドラインで遊ぶ際は、xcodeで実行するのが楽です。
コンパイルしてターミナルで実行しても構いません。ご自由にどうぞ

swiftのコマンドラインで動くライフゲームの作り方を解説します。
ライフゲームとは、セルを生命に見立てたシミュレーションゲームです。
ライフゲームがわからない方は、ライフゲームをスマホのアプリで探してみて下さい。プレイできるものが見つかるはずです。
詳しくは、[ウィキペディア「ライフゲーム」](https://ja.wikipedia.org/wiki/ライフゲーム)を、読んでください。
今回は、コマンドラインでゲーム画面が表示される、簡単で分かり易い物を作ります。
作りたくない方は、GitHubの[ここから](https://github.com/Hikiko-Kanamaru/Conway-sGame-of-Life-simple)落として下さい。
こんな感じです。生存は⬛️、死は⬜️、で表示しています。

```example.swift
|0|1|2|3|4|
⬜️⬜️⬜️⬜️⬜️:0
⬜️⬜️⬜️⬜️⬜️:1
⬜️⬛️⬛️⬜️⬛️:2
⬛️⬜️⬜️⬜️⬜️:3
⬜️⬛️⬜️⬜️⬜️:4
```



導入する動作は、以下の４つです
1.マップを生成
2.画面を表示
3.次の世代に進める
4.特定のマスを操作
5.コマンドラインで遊べる

##Conway's Game of Lifeのルール
ルールを確認しておきます。
自身のセルに、隣接し生存しているセルの数によって、「生」「死」が決まります

* 誕生　生存セル３つと隣接している　-> セルに生命が誕生
* 生存　生存セル２つと隣接しており、自身が生存している　->　次世代でも生存を継続
* 過疎　隣接する生存セルが、１以下　-> 次世代では死滅
* 過密　隣接する生存セルが、４以上　-> 次世代では死滅
 

##基礎的データ構造について　lifeData
今回は、説明を省くため、``多重配列``を使用します。
配列の中に配列が入っています。外側の配列をx軸。内側の配列をy軸として扱います
例えば、左上0行目の左から３列目の値を取り出すときは、``配列名[0][3]``　となります。
内部の型は、``真理値``です
trueが生存
falseが死です

```lifeData.swift
//ライフゲームの基礎データ[X軸[Y軸]] 要素０で初期化するなら初期値は不要
var lifeData:[[Bool]]
```

##マップを生成する mapCreate
マップを生成に、必要なものは、２つです。
1. マップの大きさを決める。　今回は、最大でも50*50マス程度にします
2. 初期値の基準 ランダムなのか、空白なのか、すべて生存で埋まっているのか。　

引数として受け取ります。今回の場合、初期値は、ランダムであった方が楽です。
そのためデフォルト値をクロージャー``{Bool.random()}``で、与えています。
これにより、呼び出しの際ランダム生成の場合、マップの大きさを入力するだけになっています。

```mapCreate.swift
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

lifeData = mapCreate(Xjiku: 10, Yjiku:10 )
print(lifeData)
```

>実行結果
[[true, false, true, true, true], [true, true, false, true, false], [true, false, true, true, false], [true, true, false, false, true], [false, false, false, false, false]]

見にくいですよね。これを見やすくしています。

##画面を表示 lifeView
コンソールに表示するには、標準出力``print``を使って並べて行きます。
前にも書きましたが、生存は⬛️、死は⬜️を使って表現します。
表番号がついていないと、指示しづらいので、表番号をつけます。
ただし、コンソールで行っているので、多少のズレは発生します。
最後に、現在の生存セル数を表示します。
これをしておかないと、変化があったのか分かりづらいですから必要です。

構造は、一行分のデータを表示したら改行し次の行に行きます。これの繰り返しです。
一行目は、列番号を書き込みます。lifeDataの外側の配列の個数(count)を基準にします
lifeDataを受け取り、１セルづつ生死を確認して行きます。端まできたら、行番号を振って改行します。
死んでいる状態の時でも、セルを設置するのが、四角く表示するコツです。

```lifeView.swift
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
```

実行結果

```lifeViewExample.swift
|0|1|2|3|4|
⬛️⬛️⬜️⬛️⬛️:0
⬜️⬛️⬛️⬛️⬜️:1
⬛️⬜️⬜️⬜️⬛️:2
⬛️⬛️⬜️⬜️⬛️:3
⬜️⬜️⬛️⬛️⬜️:4
```

これで見慣れたゲーム画面になってきました。
次から、世代を導入します。

##次の世代に進める　nextLife 
次の世代に進めるには、いくつかルールの違いがありますが、今回は、最も基礎ルールで行きます。
つまり、Conway's Game of Lifeのルールで示した４つのルールです。
* 誕生　生存セル３つと隣接している　-> セルに生命が誕生
* 生存　生存セル２つと隣接しており、自身が生存している　->　次世代でも生存を継続
* 過疎　隣接する生存セルが、１以下　-> 次世代では死滅
* 過密　隣接する生存セルが、４以上

そのため、端は死のセルであるとして扱われます。

今回は、楽をするために２つだけ変わった組み方をします。

次世代のlifeDataをすべて死んだ状態からにすることで、誕生と生存だけ調べるだけで済むようにします。

セル隣接数マップ``kamitudo``を導入します。[[Int]]型で、lifeDataよりひと回り大きい配列です。
隣接するセル数を記録します。

どのようにするか、まず三つの同じ大きさのmapを用意します。
1. 現在のlifeMap:引数として読み込んだもの
2. 未来のlifeMap:返値として利用するもの
3. セル隣接数マップ(kamitudo):周辺の生存セル数を表示するもの


セル隣接数マップ(kamitudo)大きさを左右前後に１マスづつ拡大します。
現在のlifeMapを縦横にひとマス``ずらして``対応させます。現在のlifeMapでは、[2][1]の位置に有ったものを、[3][2]の位置にあるとして扱うと言うことです。
そして、現在のlifeMapを読み込み、生存しているのであれば、セル隣接数マップの8方向セルに、数値を加算します。すべてのセルに対して行います。加算し終わったなら、kamitudoから隣接情報を読み込み、ルールに基づき、次世代セルに書き込みます。
　端のデータは、対応する次世代データを作る際に読み込まないので、現在は、対応する必要はありません。

これら方法を取ることでの利益は、計算が早くなることです。
過密度マップが存在しない場合、セル毎に毎回周辺を調査することになります。つまりセル一つにつき８方向から読み込まれます。
過密度マップがある場合、読み込みはセル一つにつき１度だけです。書き込みは、書き込みデータ量によるので、他の方法とほぼ変わりません。

過密度マップを拡大しておくことで、書き込みセルが存在するかを調べる必要がなくなります。各セルごとにnilチェックを入れなくて良くなります。
セルが存在しない場合、アクセスしてしまうとエラーが出ます。そのため、調査は必要ですが、拡大しておけば、マップ端にセルが確実に存在するので不要です。


```nextLife.swift
//1ターン進める　今回は、生存条件を変更不可能にする。
func nextLife(world w:[[Bool]]) -> [[Bool]] {

    //毎回読み込ませると時間がかかるので、定数として読み込ませる
    let xCount = w.count
    let yCount = w[0].count
    
    //周辺の密度を保存する。型がIntのため、mapCreateを使わない。端っこかどうかの計算をなくすために、一マスづつ前後に大きくしています。両側ぶんで２足します
    var kamitudo:[[Int]] = Array(repeating:{Array(repeating: 0, count: yCount + 2)}(), count: xCount + 2)
    
    //返値を保存する場所 生命は減っていく傾向にあるのでfalse指定{false}。
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
```

実行結果
今回は、変化を見るために二回実行しています。

```nextLifeExample.swift
現在の世界を表示します
|0|1|2|3|4|
⬜️⬜️⬛️⬜️⬛️:0
⬜️⬛️⬛️⬛️⬜️:1
⬛️⬛️⬛️⬜️⬛️:2
⬜️⬜️⬜️⬛️⬜️:3
⬜️⬜️⬛️⬜️⬜️:4
現在生き残りは 11です 約44%です 
一年進めました
現在の世界を表示します
|0|1|2|3|4|
⬜️⬛️⬛️⬜️⬜️:0
⬛️⬜️⬜️⬜️⬛️:1
⬛️⬜️⬜️⬜️⬛️:2
⬜️⬜️⬜️⬛️⬜️:3
⬜️⬜️⬜️⬜️⬜️:4
現在生き残りは 7です 約28%です
```

中央付近が、過密で死亡しています
最も下のマスは、過疎で死亡しています。左上は、生命が誕生しています。

##特定のマスを操作 kamiNoTe
修正地点を受け取り、値を変更して上書きしています。
変更する規則は、クロージャ(無名関数)で受け取ります。デフォルトで反転になっています。
特定の値にしたい場合
正にする　{_ in true}
偽にする　{_ in false}
で、変えることが可能です。 ``_ in`` は引数を受け取っても使わないと言う指定です。
デフォルトの{!$0}は、``!``は反転。``$0``は、第一引数の意味です。
クロージャは、返値が{}のなかに１つしか無い場合``returnは不要``です。
　
lifeDataを全面的に作り直すと、効率が良く無いので``inout``を指定して、``参照渡し``にしています。
参照渡しとは、データそのもの受け取ると言うことです。
対義語は、値渡し（あたいわたし）です。swiftの場合、ほぼ全ての場合で、値渡しです。
値渡しは、データがコピーされて渡されます。オリジナルに影響を与えないことが、利点です。
値渡しのデータは、変更しても、オリジナルに影響はありませんが、参照渡しの値は、オリジナル(参照元)が変更されます。データの消失に気をつけて下さい。

swiftで参照渡しを行う場合、仮引数の型に、``inout``属性を与え、呼び出す際には、実引数に``＆``をつけて、利用します。

```kamiNote.swift
//特定のマスを指示してデータを操作する関数 worldは現在の状態、pointは編集する場所(X軸,Y軸)、sayouは、セルに行う操作　デフォルトは、反転
func kamiNoTe(world w :inout [[Bool]],point p :(Int,Int),sayou s:(Bool)->Bool = {!$0}) {
    w[p.0][p.1] = s(w[p.0][p.1])
}


//一番下の行を反転させる
lifeView(world: lifeData)
print("一番下の行を反転させます")
//一番下の行を反転させる
for i in 0..<lifeData[0].count {
    //&をつけて、参照渡し。
    kamiNoTe(world: &lifeData, point: (i,lifeData.count - 1))
}
```

実行結果

```kamiNotTeExample.swift
現在の世界を表示します
|0|1|2|3|4|
⬜️⬜️⬛️⬜️⬛️:0
⬜️⬛️⬛️⬛️⬜️:1
⬛️⬛️⬛️⬜️⬛️:2
⬜️⬜️⬜️⬛️⬜️:3
⬜️⬜️⬛️⬜️⬜️:4
現在生き残りは、11です。約44%です。
一番下の行を反転させます
現在の世界を表示します
|0|1|2|3|4|
⬜️⬜️⬛️⬜️⬛️:0
⬜️⬛️⬛️⬛️⬜️:1
⬛️⬛️⬛️⬜️⬛️:2
⬜️⬜️⬜️⬛️⬜️:3
⬛️⬛️⬜️⬛️⬛️:4
現在生き残りは、14です。約56%です。
```

一番下の行が反転しています。
これで基本的機能の説明は終わりです。
これを使ってコマンドラインでのゲーム化に入ります。

##コマンドラインで遊べる gameMode
コマンドラインでは、標準入力(readLine)を使って操作します。
今回は``Xcode``上で実行するので右下の``コンソールエリア``に、入出力します。
ココに入力っとなっている場所です。
<img width="1219" alt="IMG_0385.JPG" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/72239/338dd826-fc6c-2ef5-72ee-5782a76df0c8.jpeg">

コンソールエリアに、文字列を入力することでゲームを操作します。
この際、入力を求める内容を忘れないようにします。何が起きているのか分からなくなりますからね。

**ゲームの流れを説明します。**
まず、数字の入力を求めます。
ゲームマップを大きさを決めます

ライフゲームの操作に入ります。
できる操作は、以下の５つです。
1. next:次の時代に進みます 
2. change:対象のマスを変更します 
3. changeAll:すべてを変更します　
4. view:現在の状態を表示します　即時実行されます　
5.  exit:終了します

以上の機能を実装します。

readLineについて、
コンソールに入力された文字列を、入手できる関数です。
使用するとコンソールが入力待機状態になります。そのため、文字入力を求める前に、何を求めるのか説明する必要があります。
　次に、文字列がどのようなものかからないため注意する必要があります。何も入力されていない``nil``であったりすると、プログラムが止まる原因になります。nil合体演算子 ??を使って安全に利用しています。
> オプショナル(nilの可能性のある値) ?? 代替値

で利用します。オプショナルとは、nilになる選択肢(オプション)がある値を示すものです。

readLineの使い方について、ユーザーの行動によって、動作が変わるため、有効な値と無効な値の反応を作る必要があります。今回は、無効な値の場合、再度やり直す構造にします。有効な値を受け取るまで、同じ動作を繰り返すようにします。repeat_while文を使用します。

>repeat {プログラム}while 条件

条件が、真の場合に繰り返します。今回は、入力が異常値だった場合、繰り返しています。
ただし、readLineを呼ぶなど、入力待機中になるコードの場合、実行中で止められなくなってしまう場合があるので、注意して利用して下さい。
swiftの場合、main.swiftの最後まで行けば動作を停止しますので、ループを抜けらようにしておきます。
終了した際には``Program ended with exit code: 0``とコンソールに表示されるので、見てみて下さい。



```gameMode.swift
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

```

実行結果
全ての操作を行ってみます。
[ここから](https://github.com/Hikiko-Kanamaru/Conway-sGame-of-Life-simple)コードを配布していますので、自分の環境で実行してみた下さい

```gameModeExample.swift
数字を入力してください1~50まで
3
3を受け取りました。マップを製造します
現在の世界を表示します
|0|1|2|
⬛️⬜️⬛️:0
⬜️⬜️⬛️:1
⬜️⬛️⬛️:2
現在生き残りは、5です。約55%です。
操作を英字で入力して下さい。
 next:次の時代に進みます 
 change:対象のマスを変更します 
 changeAll:すべてを変更します　
 view:現在の状態を表示します　即時実行されます　
 exit:終了します
next
どれくらい進めますか？1回以上
1
操作を英字で入力して下さい。
/*省略*/
view
現在の世界を表示します
|0|1|2|
⬜️⬛️⬜️:0
⬜️⬜️⬛️:1
⬜️⬛️⬛️:2
現在生き残りは、4です。約44%です。
操作を英字で入力して下さい。
/*省略*/
changeAll
世界を再構成します
操作を英字で入力して下さい。
/*省略*/
view
現在の世界を表示します
|0|1|2|
⬜️⬜️⬜️:0
⬜️⬛️⬜️:1
⬜️⬜️⬜️:2
操作を英字で入力して下さい。
/*省略*/
change
x軸を入力して下さい。最大値は2です
0
y軸を入力して下さい。最大値は2です
3
y軸を入力して下さい。最大値は2です
2
x:0 y:2を、反転させます
操作を英字で入力して下さい。
/*省略*/
view
現在の世界を表示します
|0|1|2|
⬜️⬜️⬜️:0
⬜️⬛️⬜️:1
⬛️⬜️⬜️:2
現在生き残りは、2です。約22%です。
操作を英字で入力して下さい。
/*省略*/
error
指示を理解できません
操作を英字で入力して下さい。
/*省略*/
exit
終了します
Program ended with exit code: 0
```

##終わりに
一通り動作しました。これでsimpleライフゲームの完成です。説明も終わります。
　コンソールで遊ぶ以上テキストベースにはなってしまいますが、今回作ったコードUIViewなどと組み合わせて使えば、リアルタイムで反応するlifeGameになります。リアルタイムに動いているようなゲームでも、根底にあるのは、データの変更です。アクションゲームもパズルゲームもその点では何も変わりません。
今回は非常簡単なデータ構造``[[Bool]]``でしたが、それなりにゲームになっていますよね？

