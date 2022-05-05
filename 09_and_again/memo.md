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
