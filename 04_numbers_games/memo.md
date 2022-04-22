# 数遊び

原則として負数は扱わない。`add`などは負数でも正常に動作するが、比較演算子などは負数を考慮していない。`o<`などに負数を渡すと無限ループとなりメモリオーバーが発生する。

## add1, sub1

```scheme
(define add1
  (lambda (n)
    (+ n 1)))

(define sub1
  (lambda (n)
    (- n 1)))
```

それぞれ引数を1つ取り、1を加算・減算した値を返す。

書籍内では負数は扱わないと書いてあるが、実際には注釈にあるよう負数も計算できる。

```scheme
(add1 0)  ; 1
(add1 -2) ; -1
(sub1 1)  ; 0
(sub1 0)  ; -1
```

`add1`と`sub1`を使って加算・減算をする関数を定義していく。

## 加算(o+)

```scheme
(define o+
  (lambda (n m)
    (cond
      ((zero? m) n)
      (else (add1 (o+ n (sub1 m)))))))
```

引数`m`が0になるまで1ずつ減らしていきながら再帰する。`n`に`m`の数だけ1を加算していく。

```scheme
(o+ 2 3) ; 5 <- 2 + 1 + 1 + 1
```

## 減算(o-)

```scheme
(define o-
  (lambda (n m)
    (cond
      ((zero? m) n)
      (else (sub1 (o- n (sub1 m)))))))
```

加算と考え方は同じ。

```scheme
(o- 5 4) ; 1 <- 5 - 1 - 1 - 1 - 1
```

## タップ

数のリストのことをタップ(タプル)という。

数限定なんだな。Haskellのタプルとは違う定義なのか。

> **タプル**または**チュープル**（[英](https://ja.wikipedia.org/wiki/%E8%8B%B1%E8%AA%9E "英語"): tuple）とは、複数の構成要素からなる組を総称する一般概念。
> 
> [数学](https://ja.wikipedia.org/wiki/%E6%95%B0%E5%AD%A6 "数学")や[計算機科学](https://ja.wikipedia.org/wiki/%E8%A8%88%E7%AE%97%E6%A9%9F%E7%A7%91%E5%AD%A6 "計算機科学")などでは通常、順序付けられた対象の並びを表すために用いられる。個別的には、n 個でできた組を英語で「n-tuple」と書き、日本語に訳す場合は通常「n **組**」としている。
> 
> [タプル - Wikipedia](https://ja.wikipedia.org/wiki/%E3%82%BF%E3%83%97%E3%83%AB)

```scheme
(1 2 3)   ; tup
()        ; tup
(1 a 2)   ; not tup
(1 (2 3)) ; not tup
```

> ### 第1の戒律
> 
> (改訂版)
> 
> アトムのリスト`lat`を再帰する時には、2つの質問をすべし。すなわち、`(null? lat)`と`else`なり。
> 数`n`を再帰するときには、2つの質問をすべし。すなわち、`(zero? n)`と`else`なり。

## addtup

```scheme
(define addtup
  (lambda (tup)
    (cond
      ((null? tup) 0)
      (else (o+ (car tup) (addtup (cdr tup)))))))
```

タップのすべての数を合計した値を返す。

```scheme
(addtup '(1 2 3)) ; 6
(addtup '())      ; 0
```

> ### 第4の戒律
> 
> (改訂版)
> 
> 再帰の間は少なくとも1つの引数を常に変化させるべし。
> 引数は終わりに向けて変化させることを要す。変化する引数は最終条件にてテストすべし。すなわち、`cdr`を用いる時は、`null?`で最終テストし、`sub1`を用いる時は、`zero?`で最終テストせよ。

## 乗算(o*)

```scheme
(define o*
  (lambda (n m)
    (cond
      ((zero? m) 0)
      (else (o+ n (0* n (sub1 m)))))))
```

`o+`と`sub1`を使って乗算を定義。`×`を入力するのは面倒なので`o*`とした。
引数`m`が`0`なら`0`を返す。
そうでなければ`n`を`m`回加算する。

```scheme
(o* 2 3) ; 6 <- 2 + 2 + 2 + 0
(o* 2 0) ; 0 <- 0
(o* 0 3) ; 0 <- 0 + 0 + 0 + 0
```

> ### 第5の戒律
> 
> `+`で値を作らんとせすときは、行を終えるときに常に値として`0`を用うべし。なんとなれば、`0`を加うるは加算の値を変えぬからなり。
> `×`で値を作らんとせすときは、行を終える時に常に値として`1`を用うべし。なんとなれば、`1`を掛けるは乗算の値を変えぬからなり。
> `cons`で値を作らんとせしときは、行を終えるときに常に値として`()`を考えるべし。

## tup+

```scheme
(define tup+
  (lambda (tup1 tup2)
    (cond
      ((and (null? tup1) (null? tup2))
       (quote ()))
      (else
       (cons (o+ (car tup1) ((car tup2))
             (tup+ (cdr tup1) (cdr tup2)))))))
```

2つのタップの各要素を加算したタップを返す。

この定義だと各タップの長さが異なるとエラーになるので、長さが異なるタップにも適用できるようにする。

```scheme
(define tup+
  (lambda (tup1 tup2)
    (cond
      ((null? tup1) tup2)
      ((null? tup2) tup1)
      (else
       (cons (o+ (car tup1) (car tup2))
             (tup+ (cdr tup1) (cdr tup2)))))))
```

```scheme
(tup+ '(1 2) '(1 2))   ; (2 4)
(tup+ '(1 2 3) '(1 2)) ;(2 4 3)
(tup+ '(1 2) '())      ; (1 2)
```

## 以上、以下(o>、o<)

```scheme
(define o>
  (lambda (n m)
    (cond
      ((zero? n) #f)
      ((zero? m) #t)
      (else (o> (sub1 n) (sub1 m))))))

(define o<
  (lambda (n m)
    (cond
      ((zero? m) #f)
      ((zero? n) #t)
      (else (o< (sub1 n) (sub1 m))))))
```

引数`n`、`m`を1ずつ減算して、どちらが先に0になったかで判断する。
半角の大なり小なり記号は使えなかったので`+`や`-`と同じように`o`を追加して実装。

```scheme
(o> 1 2) ; #f
(o> 2 1) ; #t
(o> 1 1) ; #f
(o< 1 2) ; #t
(o< 2 1) ; #f
(o< 1 1) ; #f
```

## 等号(o=)

```scheme
(define o=
  (lambda (n m)
    (cond
      ((o> n m) #f)
      ((o< n m) #f)
      (else #t))))
```

`o>`か`o<`を満たすなら`#f`。
これも`o=`として実装。

```scheme
(o= 1 1) ; #t
(o= 1 2) ; #f
(o= 2 1) ; #f
```

## 階乗(^)

```scheme
(define ^
  (lambda (n m)
    (cond
      ((zero? m) 1)
      (else (o* n (^ n (sub1 m)))))))
```

`n`の`m`乗を求める。

```scheme
(^ 2 3) ; 8
(^ 2 0) ; 1
(^ 0 2) ; 0
```

## 除算(o/)

```scheme
(define o/
  (lambda (n m)
    (cond
      ((o< n m) 0)
      (else (add1 (o/ (o- n m) m))))))
```

`o/`として定義。

除算の結果を整数値で返す。
-> `n`から`m`を減算できた回数を返す。

```scheme
(o/ 10 2) ; 5
(o/ 10 3) ; 3
(o/ 3 10) ; 0
(o/ 10 0) ; 無限ループのためNG
```

## length

```scheme
(define length2
  (lambda (lat)
    (cond
      ((null? lat) 0)
      (else (add1 (length2 (cdr lat)))))))
```

組み込みで`length`があったので`length2`として実装。

```scheme
(length2 '(1 2))     ; 2
(length2 '())        ; 0
(length2 '((a b) c)) ; 2
```

## pick

```scheme
(define pick
  (lambda (n lat)
    (cond
      ((zero? (sub1 n)) (car lat))
      (else (pick (sub1 n) (cdr lat))))))
```

リスト`lat`の`n`番目の要素を返す。

`n`番目の要素がリストの先頭になるまで`cdr`をかけていく。なるほど。

```scheme
(pick 2 '(a b c d))    ; b
(pick 2 '((a b) (c d)) ; (c d)
```

## rempick

```scheme
(define rempick
  (lambda (n lat)
    (cond
      ((zero? (sub1 n)) (cdr lat))
      (else (cons (car lat)
                  (rempick (sub1 n)
                           (cdr lat)))))))
```

リスト`lat`から`n`番目の要素を除いたリストを返す。

```scheme
(rempick 2 '(a b c d))     ; (a c d)
(rempick 1 '((a b) (c d))) ; ((c d))
```

## no-nums

```scheme
(define no-nums
  (lambda (lat)
    (cond
      ((null? lat) (quote ()))
      (else (cond
              ((number? (car lat))
               (no-nums (cdr lat)))
              (else (cons (car lat)
                          (no-nums (cdr lat)))))))))
```

リスト`lat`から数値でない要素だけを取り出したリストを返す。

```scheme
(no-nums '(1 a 2 b)) ; (a b)
(no-nums '(a b c d)) ; (a b c d)
(no-nums '(1 2 3 4)) ; ()
```

## all-nums

```scheme
(define all-nums
  (lambda (lat)
    (cond
      ((null? lat) (quote ()))
      (else
       (cond
         ((number? (car lat))
          (cons (car lat) (all-nums (cdr lat))))
         (else (all-nums (cdr lat))))))))
```

リスト`lat`から数値だけを取り出したリスト(タップ)を返す。

```scheme
(all-nums '(a 1 b 2))
```

## eqan?

```scheme
(define eqan?
  (lambda (a1 a2)
    (cond
      ((and (number? a1) (number? a2))
       (o= a1 a2))
      ((or (number? a1) (number? a2)) #f)
      (else (eq? a1 a2)))))
```

アトム同士を比較するための関数。`eq?`は数でないアトムを比較する用なので、数値の場合は`o=`で比較する。(実際には`eq?`で数値も比較できるが)

この関数を利用すれば、数値かどうかを意識せずにアトム同士の比較ができる。

```scheme
(eqan? 2 2)           ; #t
(eqan? 1 'a)          ; #f
(eqan? 'hoge 'hoge)   ; #t
(eqan? '(a b) '(a b)) ; #f <- リストは対象外
```

## occur

```scheme
(define occur
  (lambda (a lat)
    (cond
      ((null? lat) 0)
      (else
       (cond
         ((eq? (car lat) a)
          (add1 (occur a (cdr lat))))
         (else (occur a (cdr lat))))))))
```

`lat`の中にアトム`a`がいくつ含まれるか数える。

せっかく`eqan?`を定義したので`eq?`の代わりに使うべきなのではと思うが`eq?`で定義してある。まあ、実際には`eq?`で数値も比較できるので問題にはならないが……

```scheme
(occur 'a '(a b a c a d))   ; 3
(occur 2 '(1 2 3 2 1))      ; 2
(occur 'a '(a (a b) (c d))) ; 1
```

## one?

```scheme
(define one?
  (lambda (n)
    (cond
      ((zero? n) #f)
      (else (zero? (sub1 n))))))
```

引数が`1`かどうか判定する。
以下のようにも定義できる。

```scheme
(define one?
  (lambda (n)
    (cond
      (else (o= n 1)))))
```

条件式が`else`のみになった。この場合、`cond`をなくして簡略化できる。

```scheme
(define one?
  (lambda (n)
    (o= n 1)))
```

```scheme
(one? 1) ; #t
(one? 2) ; #f
```

## rempick(再掲)

```scheme
(define rempick
  (lambda (n lat)
    (cond
      ((zero? (sub1 n)) (cdr lat))
      (else (cons (car lat)
                  (rempick (sub1 n)
                           (cdr lat)))))))
```

`one?`を使うと以下のように定義できる。

```scheme
(define rempick
  (lambda (n lat)
    (cond
      ((one? n) (cdr lat))
      (else (cons (car lat)
                  (rempick (sub1 n)
                           (cdr lat)))))))
```
