# ……もう一度、もう一度、もう一度、……

## looking, keep-looking

```scheme
(define keep-looking
  (lambda (a sorn lat)
    (cond
      ((number? sorn)
       (keep-looking a (pick sorn lat) lat))
      (else (eq? sorn a)))))


(define looking
  (lambda (a lat)
    (keep-looking a (pick 1 lat) lat)))
```

アトムのリストを捜査して、数値だったらその場所のアトムを取り出す。数値以外のアトムが見つかったら検索対象のアトム`a`と一致するか判定する。`sorn`は`Symbol Or Number`(記号が数)を表している。

```scheme
(looking 'caviar '(6 2 4 caviar 5 7 3) ; #t
(looking 'caviar '(6 2 4 hoge 5 7 3)   ; #f
```

ポイントは再帰してるのに同じ`lat`を使っているけど大丈夫なのってこと。第4の戒律に反するんじゃないか。いや、「少なくとも1つの引数を変えるべし」なので違反はしてないのか。本ではこういう再帰を「不自然な」再帰と呼んでいる。

引数の与え方によっては無限ループを起こせてしまう。

```scheme
(looking '(2 3 1)) ; 無限ループ
```

このように必ずしも値を返すとは限らない関数を**部分関数**と呼ぶ。対してこれまで見てきた関数は**全関数**という。

部分関数についてもっと短い例。

```scheme
(define eternity
  (lambda (x)
    (eternity x)))
```

ひたすら自分自身を呼ぶだけ。これも部分関数。

## shift

```scheme
(define shift
  (lambda (pair)
    (build (first (first pair))
           (build (second (first pair))
                  (second pair)))))
```

引数は`pair`となっているけど、第1引数がペアであるペアを指している。第1引数のペアの第2要素を2番目の要素にずらして新しいペアにする感じ。

```scheme
(shift '((a b) c))             ; (a (b c))
(shift '((a b) (c d)))         ; (a (b (c d)))
(shift '(((a b) (c d)) (e f))) ; ((a b) ((c d) (e f)))
```

## align

```scheme
(define align
  (lambda (pora)
    (cond
      ((atom? pora) pora)
      ((a-pair? (first pora))
       (align (shift pora)))
      (else (build (first pora)
                   (align (second pora)))))))
```

本では引数が`para`になっているが、あとから出てくる`weight*`とかを見ると`pora`の方が適切っぽい。おそらく`Pair OR Atom`の略。[こちらのブログ](https://kb84tkhr.hatenablog.com/entry/2016/05/13/111431)でも言及あり。

で、これが何をする関数なのか。`shift`も使っている。とりあえず動作を見てみる。

```scheme
(align '(((a b) (c d)) (e f))) ; (a (b (c (d (e f)))))
```

なんとなく右側に寄っていくイメージ。これも再帰しているけど部分関数なのか全関数なのかっていうのがポイントっぽい。

`shift`を実施して先頭がアトムになるようにする。そうなったら残りの部分で`align`を実施するっていうのを繰り返していく感じか。全関数っぽい雰囲気はある。

とりあえず進んでみる。

## length*

```scheme
(define length*
  (lambda (pora)
    (cond
      ((atom? pora) 1)
      (else
       (o+ (length* (first pora))
                    (length* (second pora)))))))
```

これも引数を`para`から`pora`に変えた。

`align`の引数中のアトムを数えるために導入。単純に数えるだけ。

```scheme
(length* '(((a b) (c d)) (e f))) ; 6
```

知りたいことは`align`が部分関数なのか全関数なのかということ。`length*`を導入してみたけど、これじゃ判断つかないよねって話かな。進んでみる。

## weight*

```scheme
(define weight*
  (lambda (pora)
    (cond
      ((atom? pora) 1)
      (else
       (o+ (o* (weight* (first pora)) 2)
           (weight* (second pora)))))))
```

単に数を数えるだけじゃ不十分なので、重みを付けるって感じだろうか。話の展開として第1要素に重みをつけたいらしいが、どう計算しているのか。

```scheme
(weight* '((a b) c))     ; 7
(weight* '(a (b c)))     ; 5
(weight* '((a b) (c d))) ; 9
(weight* '(a b))         ; 3
```

先頭にペアがあるとその分大きく評価される。

`align`の定義を思い出してみる。問題は、`shift pora`を引数に再帰しているけど`shift`した結果リストの長さは変わってないからまずいんじゃないのって話だった。再帰する場合には終了条件に向かうようにしなければならない。つまり引数を簡単にしていく必要がある。多分、「引数が簡単になっているかどうか」を評価するために`length*`と`weight*`の話を出したんだろうな。

で、`length*`はいくら`shift`しても変わらないから意味ないよねと。`weight*`は先頭要素がアトムに変われば小さくなるから、この基準で言えば`shift`した結果のリストは簡単になっている、みたいな話かなあ。これで結論が「`align`は部分関数」になっている。

`align`の最初の質問は引数がアトムかどうかだから、`weight*`が小さくなるってことは最終条件に近づいているって論法だろうか。多分、きちんと証明もできるんだろうが詳しくは書かれていないので、とりあえずそういうものと理解しておこう。『定理証明見習い』を読んだら理解が進むだろうか。

## shuffle

```scheme
(define shuffle
  (lambda (pora)
    (cond
      ((atom? pora) pora)
      ((a-pair? (first pora))
       (shuffle (revpair pora)))
      (else (build (first pora)
                   (shuffle (second pora)))))))
```

引数の第1要素がペアだったら(引数の第1要素と第2要素を)入れ替える関数。

```scheme
(shuffle '((a b) c))     ; (c (a b))
(shuffle '(a (b c)))     ; (a (b c))
(shuffle '(a ((b c) d))) ; (a (d (b c)))
(shuffle '((a b) (c d))  ; 無限ループ
```

入れ替えた結果第1引数がペアになると無限ループになってしまう。なのでこれは部分関数。

## C

```scheme
(define C
  (lambda (n)
    (cond
      ((one? n) 1)
      (else
       (cond
         ((even? n) (C (o/ n 2)))
       (else (C (add1 (o* 3 n)))))))))
```

コラッツ予想というやつ。奇数なら3倍して1を足す。偶数なら2で割る。これを繰り返すと必ず1に到達するというやつ。未解決問題で全関数かどうかはわからないよねって話。

## A

```scheme
(define A
  (lambda (n m)
    (cond
      ((zero? n) (add1 m))
      ((zero? m) (A (sub1 n) 1))
      (else (A (sub1 n)
               (A n (sub1 m)))))))
```

アッカーマン関数というやつ。引数を大きくすると計算量がめちゃんこ増えていく。全関数だが現実的に計算が完了できるかは別問題。

## will-stop?

さて、無限ループする関数もいくつか出てきたけど、それを判定できる関数があったら便利だから作ってみよう。と言われてもできるんだろうか。

いきなりは難しそうなので引数に空リスト`()`を与えた時に絞って考えてみる。
`will-stop?`は対象の関数に`()`を渡した時に値を返すなら`#t`、返さないなら`#f`となる関数とする。つまり全関数と言える。

例えば`length`は値を返すので`#t`となるはず。`eternity`は`#f`だ。でも、値を返さない関数だから評価できないんじゃないだろうか。

```scheme
; こんな風に使える関数があったら便利
(will-stop? length)   ; #t
(will-stop? eternity) ; #f
```

もう1つ別の例。以下のような関数を考える。

```scheme
(define last-try
  (lambda (x)
    (and (will-stop? last-try)
         (eternity x))))
```

ややこしいのが出てきた。

```scheme
; (last-try '()) が値を返さないと仮定する
(will-stop? last-try) ; #fを返す
; つまり
(and (will-stop? last-try) (eternity x)) ; この評価は常に#f
; ということは
(last-try '()) ; これは#fで停止することになる
; 値を返さないはずなのに停止してしまう。おかしい。

; 逆に値を返すと仮定してみる
(will-stop? last-try) ; #tを返す
(and (will-stop? last-try) (eternity x)) ; この評価は常に#t
(last-try '()) ; eternityが無限ループなので値が返ってこないはず
; こっちも矛盾してしまった
```

ということで、`will-stop?`なる関数があるという前提が間違っているという結論。
チューリングとゲーデルの名前が出てくるので、不完全性定理に関連した話なんだろうか。

## 再帰的定義とは

「再帰的定義とは」という質問から`define`を使わずに`length`を定義する話へと展開していく。なんだか複雑そうだが順番に読んでいこう。

とりあえず`length`を再掲。

```scheme
(define length
  (lambda (lat)
    (cond
      ((null? lat) 0)
      (else (add1 (length (cdr lat)))))))
```

`define`を使わないと再帰で`length`を指定できない。ということでいったん次のような関数が登場する。

```scheme
(lambda (l)
  (cond
    ((null? l) 0)
    (else (add1 (eternity (cdr l))))))
```

変な感じだが、名前のついてない関数か。空リストを与えると0を返す。ほかは応答なしになる。つまり空リストの長さを求めることだけができる関数。`length0`と呼ぶことにする。

```scheme
((lambda (l)
  (cond
    ((null? l) 0)
    (else (add1 (eternity (cdr l)))))) '()) ; 0
```

次に、1以下の要素からなるリストの長さを求めることができる`length<=1`を考える。`length0`の`eternity`の部分を`length0`に置き換えてやればよい。

```scheme
(lambda (l)
  (cond
    ((null? l) 0)
    (else (add1
           ((lambda (l)
              (cond
                ((null? l) 0)
                (else (add1
                       (eternity (cdr l))))))
            (cdr l))))))
```

```scheme
((lambda (l)
  (cond
    ((null? l) 0)
    (else (add1
           ((lambda (l)
              (cond
                ((null? l) 0)
                (else (add1
                       (eternity (cdr l))))))
            (cdr l)))))) '())
; 0

((lambda (l)
  (cond
    ((null? l) 0)
    (else (add1
           ((lambda (l)
              (cond
                ((null? l) 0)
                (else (add1
                       (eternity (cdr l))))))
            (cdr l)))))) '(a))
; 1
```

ふむ。とりあえずこうやって繋げていけば`length`に近づいていくことはできる。ただし無限に書くことはできないので限界がある。同じパターンの繰り返しなので、ここをうまいことやる方法があるんだろうな。

`define`で名前をつけることができないので代わりに`(lambda (length) ...)`で名前をつける。

```scheme
((lambda (length)
  (lambda (l)
    (cond
      ((null? l) 0)
      (else (add1 (length (cdr l)))))))
 eternity)
```

ん～？これはどういう形だろうか。
ああ、`(lambda (length) ... `に`eternity`を渡しているのか。つまり`length0`と同じになると。

```scheme
(((lambda (length)
  (lambda (l)
    (cond
      ((null? l) 0)
      (else (add1 (length (cdr l)))))))
 eternity) '())
; 0
```

同じように動作する。これを使って`length<=1`を書いてみる。

```scheme
((lambda (f)
  (lambda (l)
    (cond
      ((null? l) 0)
      (else (add1 (f (cdr l)))))))
 ((lambda (g)
   (lambda (l)
     (cond
       ((null? l) 0)
       (else (add1 (g (cdr l)))))))
 eternity))
```

たしかに`length<=1`になった。でもやっぱり繰り返しが増えていくのは変わらない。次はどうするのか。

> `length`を引数として取り、`length`に似た関数を返す関数に名前を付けましょう。

はて。どういうことでしょうか。

```scheme
((lambda (mk-length)
   (mk-length eternity))
 (lambda (length)
   (lambda (l)
     (cond
       ((null? l) 0)
       (else (add1 (length (cdr l))))))))
```

ほむ。たしかに展開してみると`length0`になる。`length<=1`を作るにはどうするか。

```scheme
((lambda (mk-length)
   (mk-length
    (mk-length eternity)))
 (lambda (length)
   (lambda (l)
     (cond
       ((null? l) 0)
       (else (add1 (length (cdr l))))))))
```

`mk-length`の部分を重ねていけばいいのか。これまでのに比べたらすっきりした。ロジックの部分は重複がなくなっている。

> 再帰とはどんなものですか。
> 
> 任意の関数への`mk-length`の適用が無限に連鎖しているようなものです。

なるほど。

> 実際に無限の連鎖が必要ですか。
> 
> もちろん、そんなことはありません。`length`を使うときはいつも有限回しか必要としませんが、何回必要かはわかりません。

遅延評価みたいな話につながるんだろうか。
十分な回数`mk-length`を重ねれば`length`と同じ関数として使えるけど、十分な回数っていうのはわからないよね。いつかは`eternity`が呼ばれてしまう。じゃあ、どうするか。

```scheme
((lambda (mk-length)
   (mk-length mk-length))
 (lambda (length)
   (lambda (l)
     (cond
       ((null? l) 0)
       (else (add1
              (length (cdr l))))))))
```

これは`length0`らしい。`eternity`がなくなった。

```scheme
(((lambda (mk-length)
   (mk-length mk-length))
 (lambda (length)
   (lambda (l)
     (cond
       ((null? l) 0)
       (else (add1
              (length (cdr l))))))))) '())
; 0
```

たしかに`length0`として動く。`'(a)`を渡すとエラーになってしまった。

`length`を`mk-length`に名前変更してもいいらしい。

```scheme
((lambda (mk-length)
   (mk-length mk-length))
 (lambda (mk-length)
   (lambda (l)
     (cond
       ((null? l) 0)
       (else (add1
              (mk-length (cdr l)
```

まあ、問題なさそう。読みやすいんだろうか。

それはいいとして、これが`'(a)`を渡した時にうまくいかないのはなぜなのか。なんかいい感じに再帰しそうな気がしない？

`mk-length (cdr l)`が呼ばれるので`(mk-length '())`となるはず。ああ、`mk-length`の引数がリストになるからダメなのか。なるほど。

では、`length<=1`にするにはどうすればいいんでしょうか。

```scheme
((lambda (mk-length)
   (mk-length mk-length))
 (lambda (mk-length)
   (lambda (l)
     (cond
       ((null? l) 0)
       (else (add1
              ((mk-length eternity) (cdr l))))))))
```

`eternity`が再登場。これで`length<=1`になった。

```scheme
(((lambda (mk-length)
   (mk-length mk-length))
 (lambda (mk-length)
   (lambda (l)
     (cond
       ((null? l) 0)
       (else (add1
              ((mk-length eternity) (cdr l)))))))) '())
; 0

(((lambda (mk-length)
   (mk-length mk-length))
 (lambda (mk-length)
   (lambda (l)
     (cond
       ((null? l) 0)
       (else (add1
              ((mk-length eternity) (cdr l)))))))) '(a))
; 1
```

ここで`eternity`を`mk-length`に置き換えてやる。

```scheme
((lambda (mk-length)
   (mk-length mk-length))
 (lambda (mk-length)
   (lambda (l)
     (cond
       ((null? l) 0)
       (else (add1
              ((mk-length mk-length) (cdr l))))))))
```

`length`ができた！！？

```scheme
(((lambda (mk-length)
   (mk-length mk-length))
 (lambda (mk-length)
   (lambda (l)
     (cond
       ((null? l) 0)
       (else (add1
              ((mk-length mk-length) (cdr l))))))))) '(a b c))
; 3
```

うまくいってる感じ。でもまだ終わらない。

> 1つ問題が残っています。これはもはや`length`のような関数を含んでいません。

どういうことでしょうか。元の`length`を思い出してみると`(mk-length mk-length)`の部分が`length`に相当しているって話かな。なので、ここを`length`と名付けよう。

```scheme
((lambda (mk-length)
   (mk-length mk-length))
 (lambda (mk-length)
   ((lambda (length)
      (lambda (l)
        (cond
          ((null? l) 0)
          (else (add1 (length (cdr l)))))))
    (mk-length mk-length))))
```

ということで変形してみた。うまくいきそうな気がするが、実際これは無限ループになってしまう。なぜ。

どうやら関数を評価する時に`mk-length`が無限に展開されてしまうようだ。元の形だと`else`に到達したときだけ評価されたたから問題なかったのか。

とりあえず本の展開を追いかけてみる。この関数を評価していく。

```scheme
((lambda (mk-length)
   (mk-length mk-length)) ; (1)
 (lambda (mk-length)      ; (2)
   ((lambda (length)
      (lambda (l)
        (cond
          ((null? l) 0)
          (else (add1 (length (cdr l)))))))
    (mk-length mk-length))))
```

(2)の`lambda`部分が引数になっているので(1)の`mk-length`に(2)を展開する。

```scheme
((lambda (mk-length)
   ((lambda (length)
      (lambda (l)
        (cond
          ((null? l) 0)
          (else (add1 (length (cdr l)))))))
    (mk-length mk-length))) ; (1)
 (lambda (mk-length)        ; (2)
   ((lambda (length)
      (lambda (l)
        (cond
          ((null? l) 0)
          (else (add1 (length (cdr l)))))))
    (mk-length mk-length))))
```

先ほどと同じく(1)の`mk-length`に(2)を当てはめていく。

```scheme
((lambda (length)
   (lambda (l)
     (cond
       ((null? l) 0)
       (else (add1 (length (cdr l)))))))
 ((lambda (mk-length)
    ((lambda (length)
       (lambda (l)
         (cond
           ((null? l) 0)
           (else (add1 (length (cdr l)))))))
     (mk-length mk-length))) ; (1)
  (lambda (mk-length)        ; (2)
    ((lambda (length)
       (lambda (l)
         (cond
           ((null? l) 0)
           (else (add1 (length (cdr l)))))))
     (mk-len
```

結局`mk-length`が延々と展開されていってしまうので評価が終わらない。

それじゃあ、次はどうするのか。

```scheme
((lambda (mk-length)
   (mk-length mk-length))
 (lambda (mk-length)
   (lambda (l)
     (cond
       ((null? l) 0)
       (else
        (add1
         ((lambda (x)
            ((mk-length mk-length) x))
          (cdr l))))))))
```

これは`(mk-length mk-length)`に名前をつける前と同じように動く。先ほどと同じように名前をつけてくくりだしてみる。

```scheme
((lambda (mk-length)
   (mk-length mk-length))
 (lambda (mk-length)
   ((lambda (length)
      (lambda (l)
        (cond
          ((null? l) 0)
          (else
           (add1 (length (cdr l)))))))
    (lambda (x)
      ((mk-length mk-length) x)))))
```

これだとうまく動作する。どうして。これについても展開してみる。

```scheme
((lambda (mk-length)
   ((lambda (length)
      (lambda (l)
        (cond
          ((null? l) 0)
          (else
           (add1 (length (cdr l)))))))
    (lambda (x)
      ((mk-length mk-length) x))))
 (lambda (mk-length)
   ((lambda (length)
      (lambda (l)
        (cond
          ((null? l) 0)
          (else
           (add1 (length (cdr l)))))))
    (lambda (x)
      ((mk-length mk-length) x)))))
```

こんな感じだろうか。で、さらに展開する。

```scheme
 ((lambda (length)
   (lambda (l)
     (cond
       ((null? l) 0)
       (else
        (add1 (length (cdr l)))))))
 (lambda (x)
   (((lambda (mk-length)
       ((lambda (length)
          (lambda (l)
            (cond
              ((null? l) 0)
              (else
               (add1 (length (cdr l)))))))
        (lambda (x)
          ((mk-length mk-length) x))))
     (lambda (mk-length)
       ((lambda (length)
          (lambda (l)
            (cond
              ((null? l) 0)
              (else
               (add1 (length (cdr l)))))))
        (lambda (x)
          ((mk-length mk-length) x))))) x)))
```

頭が混乱してくるが、多分合ってるだろう。引数にリストを与えればちゃんと評価してくれた。

で、これがさっきと何が違うのか。さっきまで無限に展開していた箇所がラムダ式になったので`else`のときしか評価されないってことかな。

```scheme
((lambda (le)
   ((lambda (mk-length)
      (mk-length mk-length))
    (lambda (mk-length)
      (le (lambda (x)
            ((mk-length mk-length) x))))))
 (lambda (length)
   (lambda (l)
     (cond
       ((null? l) 0)
       (else (add1 (length (cdr l))))))))
```

> これが正しい関数ですか？

さて、次はどういうことだろうか。なんかさっきの関数を変形した形っぽい。後半部分は`length`関数の定義だな。前半はなんだろうか。

> `length`を生成している関数を`length`のように見える関数から分離してみましょう。

```scheme
(lambda (le)
  ((lambda (mk-length)
     (mk-length mk-length))
   (lambda (mk-length)
     (le (lambda (x)
           ((mk-length mk-length) x))))))
```

前半部分ですね。これが「`length`を生成している関数」と。

で、これのことを**Yコンビネータ**と呼ぶらしい。

```scheme
(define Y
  (lambda (le)
    ((lambda (f) (f f))
     (lambda (f)
       (le (lambda (x) ((f f) x)))))))
```

さて、9章のゴールまで来てしまったが、まだ理解は浅い気がする。

とりあえずさっきの`length`を`Y`を使って試してみる。

```scheme
((Y (lambda (length)
   (lambda (l)
     (cond
       ((null? l) 0)
       (else (add1 (length (cdr l)))))))) '(a b))
; 2
```

ちゃんと動く。多分`length`以外もいけるってことなんだろうな。

```scheme
((Y (lambda (lat)
        (lambda (l)
          (cond
            ((null? l) #t)
            ((atom? (car l)) (lat? (cdr l)))
            (else #f))))) '(a b c))
; #t

((Y (lambda (lat)
        (lambda (l)
          (cond
            ((null? l) #t)
            ((atom? (car l)) (lat? (cdr l)))
            (else #f))))) '(a (b c)))
; #f
```

できてるっぽい。

引数が複数ある場合はカリー化すればよさそう。やはり[こちらのブログ](https://kb84tkhr.hatenablog.com/entry/2016/06/01/220205)が参考になる。ありがたし。

十分な理解ではないけど、大ボリュームは9章を終えることができた。`define`を使わずに再帰関数を作るっておもしろいな。もう何回か読み返したりしながら理解を深めるとして、ひとまず次へ進もう。

しかし、10章はさらに難解そうだ。
