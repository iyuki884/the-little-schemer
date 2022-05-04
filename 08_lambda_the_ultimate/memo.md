# 究極の lambda

## rember-f

```scheme
(define rember-f
  (lambda (test? a l)
    (cond
      ((null? l) (quote ()))
      ((test? (car l) a) (cdr l))
      (else (cons (car l)
                  (rember-f test? a (cdr l)))))))
```

引数に関数を指定できる。

```scheme
(rember-f o= 2 '(1 2 3))   ; (1 3)
(rember-f eq? 'a '(a b c)) ; (b c)
```

## eq?-c

```scheme
(define eq?-c
  (lambda (a)
    (lambda (x)
      (eq? x a))))
```

引数`a`と等しいかどうかを判定する関数を返す。カリー化。

```scheme
((eq?-c 'hoge) 'hoge)  ; #t
((eq?-c 'hoge) 'fuga)  ; #f

;こんな感じで名前をつけて関数定義してもいい
(define eq?-salada (eq?-c 'salada))

(eq?-salada 'salada) ; #t
(eq?-salada 'meat)   ; #f
```

## rember-f をカリー化する

```scheme
(define rember-f
  (lambda (test?)
    (lambda (a l)
      (cond
        ((null? l) (quote ()))
        ((test? (car l) a) (cdr l))
        (else (cons (car l)
                    ((rember-f test?) a (cdr l))))))))
```

引数に比較関数`test?`を受け取り、それを使った`rember`関数を返す。

```scheme
((rember-f eq?) 'a '(a b c)) ; (b c)
```

## insertL-f

```scheme
(define insertL-f
  (lambda (test?)
    (lambda (new old l)
      (cond
        ((null? l) (quote ()))
        ((test? (car l) old)
         (cons new (cons old (cdr l))))
        (else (cons (car l)
                    ((insertL-f test?) new old
                                       (cdr l))))))))
```

`insertL`も同じように変形する。ところで`-f`ってどういう意味なんだろう。

```scheme
((insertL-f eq?) 'a 'b '(b c d)) ; (a b c d)
```

## insesrtR-f

```scheme
(define insertR-f
  (lambda (test?)
    (lambda (new old l)
      (cond
        ((null? l) (quote ()))
        ((test? (car l) old)
         (cons old (cons new (cdr l))))
        (else (cons (car l)
                    ((insertR-f test?) new old
                                       (cdr l))))))))
```

`insertR`も同様に。`insertL-f`との違いは少しだけ。

```scheme
((insertR-f eq?) 'b 'a '(a c d)) ; (a b c d)
```

## insert-g

```scheme
(define insert-g
  (lambda (seq)
    (lambda (new old l)
      (cond
        ((null? l) (quote ()))
        ((eq? (car l) old)
         (seq new old (cdr l)))
        (else (cons (car l)
                    ((insert-g seq) new old
                                    (cdr l))))))))
(define seqL
  (lambda (new old l)
    (cons new (cons old l))))

(define seqR
  (lambda (new old l)
    (cons old (cons new l))))
```

補助関数を導入して、`insertL`か`insertR`かを選べるようにした。比較方法は`eq?`限定。

```scheme
((insert-g seqL) 'a 'b '(b c d)) ; (a b c d)
((insert-g seqR) 'b 'a '(a c d)) ; (a b c d)
```

`insert-g`を使って`insertL`と`insertR`を定義してみる。

```scheme
(define insertL (insert-g seqL))
(define insertR (insert-g seqR))
```

`seqL`、`seqR`を別名で定義したが、名前をつけなくてもよい。`seqL`とかをほかで使わないなら、この方がすっきりしていいか。

```scheme
(define insertL
  (insert-g
   (lambda (new old l)
     (cons new (cons old l)))))

(define insertR
  (insert-g
   (lambda (new old l)
     (cons old (cons new l)))))
```

## subst

```scheme
(define seqS
  (lambda (new old l)
    (cons new l)))

(define subst (insert-g seqS))
```

`subst`も似てるから同じように`insert-g`を使って定義できるよねって話。

```scheme
(subst 'a 'b '(a b c d)) ; (a a c d)
```

## rember

```scheme
(define seqrem
  (lambda (new old l)
    l))

(define rember
  (lambda (a l)
    ((insert-g seqrem) #f a l)))
```

`rember`も同じ形で実装できるぞって話。

`rember`の定義を思い出してみよう。`new`は使わない(捨てられる)ので`#f`を渡しておくって感じか。

```scheme
(define rember
  (lambda (s l)
    (cond
      ((null? l) (quote ()))
      ((equal?? (car l) s) (cdr l))
      (else (cons (car l)
                  (rember s (cdr l)))))))
```

> 第9の戒律
> 
> 新しき関数においては共通のパターンを抽象化すべし。

## atom-to-function

```scheme
(define atom-to-function
  (lambda (x)
    (cond
      ((eq? x (quote +)) o+)
      ((eq? x (quote ×)) o*)
      (else ^))))
```

関数を返す。これを使って`value`を短くする。

## value

```scheme
(define value
  (lambda (nexp)
    (cond
      ((atom? nexp) nexp)
      (else
       ((atom-to-function
         (operator nexp))
        (value (1st-sub-exp nexp))
        (value (2nd-sub-exp nexp)))))))
```

共通部分がまとまってすっきりした。

```scheme
(value '(2 + 3)) ; 5
(value '(2 × 3)) ; 6
(value '(2 ↑ 3)) ; 8
```

## multirember-f

```scheme
(define multirember-f
  (lambda (test?)
    (lambda (a lat)
      (cond
        ((null? lat) (quote ()))
        ((test? a (car lat))
         ((multirember-f test?) a
                                (cdr lat)))
        (else (cons (car lat)
                    ((multirember-f test?) a
                                           (cdr lat))))))))
```

`mulrirember`の比較関数を引数で指定できるようにした。

誤:`(test? a (cat lat))`
正:`(test? a (car lat))`

```scheme
((multirember-f eq?) 'a '(a b a c)) ; (b c)
```

`multirember-eq?`を定義する場合はこうする。

```scheme
(define multirember-eq?
  (multirember-f eq?))
```

常に`tuna`と比較するような`eq?`を作ってみる。

```scheme
(define eq?-tuna
  (eq?-c (quote tuna)))
```

`eq?-tuna`を渡せる`multiremberT`を作る。

```scheme
(define multiremberT
  (lambda (test? lat)
    (cond
      ((null? lat) (quote ()))
      ((test? (car lat))
       (multiremberT test? (cdr lat)))
      (else (cons (car lat)
                  (multirembert test?
                                (cdr lat)))))))
```

```scheme
(multiremberT eq?-tuna '(tuna hoge tuna fuga)) ; (hoge fuga)
```

### multirember&co

```scheme
(define multirember&co
  (lambda (a lat col)
    (cond
      ((null? lat)
       (col (quote ()) (quote ())))
      ((eq? (car lat) a)
       (multirember&co a (cdr lat)
                       (lambda (newlat seen)
                         (col newlat
                              (cons (car lat) seen)))))
      (else
       (multirember&co a (cdr lat)
                       (lambda (newlat seen)
                         (col (cons (car lat) newlat) seen)))))))
```

なんか複雑なのが出てきた。

`col`に`a-friend`を指定する。

```scheme
(define a-friend
  (lambda (x y)
    (null? y)))
```

引数を2つとって、第2引数が`null`かどうかを判定するだけの関数。第1引数は無視。なんのための関数かわからないが、とりあえずこれを`col`として考えてみる。

`multirember&co`は引数を3つ取る。やりたいこととしては`lat`の中身を`newlat`と`seen`に振り分けているようだ。用語として`collector(収集子)`、`continuation(継続)`というのが出てくる。これを理解する必要がありそう。
この関数自体は、振り分けは行っているけど実際のところそれをどうこうする関数ではない。まあ練習用関数って感じか。関数の効用としては`a`が`lat`内にあれば`#t`を返すだけ。

よくわからないのは、関数内で定義している`col`に渡している`newlat`と`seen`について。これは最初に呼び出すときは`()`で、以降は同じ名前なら値が保持されているってことなんだろうか。ちがうか。

あ、なんかわかったかもしれない。

```scheme
; こんな感じで呼び出すとする
(multirember&co 'hoge '(hoge) a-friend)
; 2つ目の条件でマッチするので再帰する
(multirember&co 'hoge '() (lambda (newlat seen)
    (col newlat (cons (car lat) seen))) ; (car lat)はhoge
; 第3引数に渡している関数を new-friend と呼ぶことにすると
(multirember&co 'hoge '() new-friend)
; 次は1つ目の条件にマッチする
(col quote() quote())
; つまりこう
(new-friend quote() quote())

; そうるすと実際どうなるか
(a-friend newlat (cons (car lat) seen)) ; ここで(car lat)はhoge
(a-friend '() (cons (car 'hoge '())
(a-friend '() '(hoge))
```

こんな感じでマッチする条件によって`col`の定義を変えるのか。なんか6割ぐらい理解できたような気分。ちゃんと説明しようとすると混乱する。

`col`を以下のような関数にすると意味のある関数になる。

```scheme
(define last-friend
  (lambda (x y)
    (length x)))
```

```scheme
(multirember&co 'hoge '(hoge fuga moge) last-friend) ; 2
```

`seen`に集めた要素の数を返す関数になった。

> 第10の戒律
> 
> 同時に2つ以上の値を集める際には関数を作るべし。

## multiinsertLR

```scheme
(define multiinsertLR
  (lambda (new oldL oldR lat)
    (cond
      ((null? lat) (quote ()))
      ((eq? (car lat) oldL)
       (cons new
             (cons oldL
                   (multiinsertLR new oldL oldR
                                  (cdr lat)))))
      ((eq? (car lat) oldR)
       (cons oldR
             (cons new
                   (multiinsertLR new oldL oldR
                                  (cdr lat)))))
      (else (cons (car lat)
                  (multiinsertLR new oldL oldR
                                 (cdr lat)))))))
```

`multiinsertL`と`multiinsertR`の合体みたいな感じ。
`oldL`と`oldR`は異なっている前提。

```scheme
(multiinsertLR 'a 'hoge 'fuga '(hoge fuga fuga hoge)) ; (a hoge fuga a fuga a a hoge)
```

## multiinsertLR

```scheme
(define multiinsertLR&co
  (lambda (new oldL oldR lat col)
    (cond
      ((null? lat)
       (col (quote ()) 0 0))
      ((eq? (car lat) oldL)
       (multiinsertLR&co new oldL oldR
                         (cdr lat)
                         (lambda (newlat L R)
                           (col (cons new
                                      (cons oldL newlat))
                                (add1 L) R))))
      ((eq? (car lat) oldR)
       (multiinsertLR&co new oldL oldR
                         (cdr lat)
                         (lambda (newlat L R)
                           (col (cons oldR (cons new newlat))
                                L (add1 R)))))
      (else
       (multiinsertLR&co new oldL oldR
                         (cdr lat)
                         (lambda (newlat L R)
                           (col (cons (car lat) newlat)
                                L R)))))))
```

もうひとつ収集子関数の練習。

`multiinsertLR`をしながら左右それぞれに挿入した回数を数える。

以下のような収集子関数を実装して試してみる。

```scheme
(define LR-counts
  (lambda (lat L R)
    (cons L (cons R lat))))
```

```scheme
(multiinsertLR&co 'new 'hoge 'fuga '(hoge fuga moge hoge fuga fuga) LR-counts)
; (2 3 new hoge fuga new moge new hoge fuga new fuga new)
```

期待した結果っぽい。収集子関数について雰囲気は掴めた気がするが、自分でこういう関数を実装するのは難しそうだ。

## evens-only*

```scheme
(define evens-only*
  (lambda (l)
    (cond
      ((null? l) (quote ()))
      ((atom? (car l))
       (cond
         ((even? (car l))
          (cons (car l)
                (evens-only* (cdr l))))
         (else (evens-only* (cdr l)))))
      (else (cons (evens-only* (car l))
                  (evens-only* (cdr l)))))))
```

入れ子のリストから奇数を削除したリストを返す。

```scheme
(evens-only* '(1 2 (3 4) ((5 6) 7) 8 9)) ; (2 (4) ((6)) 8)
```

## evens-only*&co

```scheme
(define evens-only*&co
  (lambda (l col)
    (cond
      ((null? l) (col (quote ()) 1 0))
      ((atom? (car l))
              (cond
                ((even? (car l))
                 (evens-only*&co (cdr l)
                                 (lambda (newl p s)
                                   (col (cons (car l) newl)
                                        (o* (car l) p) s))))
              (else (evens-only*&co (cdr l)
                                    (lambda (newl p s)
                                      (col newl p
                                           (o+ (car l) s)))))))
      (else (evens-only*&co (car l)
                            (lambda (al ap as)
                              (evens-only*&co (cdr l)
                                              (lambda (dl dp ds)
                                                (col (cons al dl)
                                                     (o* ap dp)
                                                     (o+ as ds))))))))))
```

`evens-only*`をしながら、出てきた偶数の積と奇数の和を計算する関数。めっちゃ混乱する。最後の`else`句はどうなってるんだ。

対象がアトムでない場合の処理なので`(car l)`はリスト。`col`の中でさらに再帰する。`(car l)`と`(cdr l)`それぞれ処理する必要があるからだろうけど、具体的な処理のイメージがしづらい。

`the-last-friend`という収集子関数を定義して試してみる。

```scheme
(define the-last-friend
  (lambda (newl product sum)
    (cons sum
          (cons product
                newl))))

(evens-only*&co '(1 2 (3 4) ((5 6) 7) 8) the-last-friend)
; (16 384 2 (4) ((6)) 8)
; 1 + 3 + 5 + 7 = 16
; 2 * 4 * 6 * 8 = 384
```

正しく動作してるっぽい。

処理順的には、`(car l)`に対しての処理が終わったら続いて`(cdr l)`の処理をしていく感じか。やっぱり、なんとか読解はできても自力で書ける気がしない。慣れなのか？

`evens-only*`が先にあるから、構造的にはそれを下敷きにすればいいと考えれば、ある程度機械的に書き換えできそうな気もする。
