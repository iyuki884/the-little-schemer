# 友達と親類

## set

```scheme
(define set?
  (lambda (lat)
    (cond
      ((null? lat) #t)
      ((member? (car lat) (cdr lat)) #f)
      (else (set? (cdr lat))))))
```

アトムのリスト`lat`が集合がどうかを判定する。

リスト内の各アトムがユニークであるものを集合という。

```scheme
(set? '(a b c))           ; #t
(set? '(a b a))           ; #f
(set? '())                ; #f
(set? '((a b) c d (a b))) ; #t <- アトムのリストでないので正しく判定できない
```

## makeset

```scheme
(define makeset
  (lambda (lat)
    (cond
      ((null? lat) (quote ()))
      ((member? (car lat) (cdr lat))
       (makeset (cdr lat)))
      (else (cons (car lat)
                  (makeset (cdr lat)))))))
```

アトムのリスト`lat`から重複する要素を取り除いて集合を返す。
先に出現するアトムから取り除かれていく。

```scheme
(makeset '(a b c b a)) ; (c b a)
```

`multirember`を使って書いてみる。

```scheme
(define makeset
  (lambda (lat)
    (cond
      ((null? lat) (quote ()))
      (else (cons (car lat)
                  (makeset
                   (multirember (car lat)
                                (cdr lat))))))))
```

```scheme
(makeset '(a b c b a)) ; (a b c)
```

条件式が減った。出力結果の順番は違う。
後者の方が直感的な結果な気がする。

## subset?

```scheme
(define subset?
  (lambda (set1 set2)
    (cond
      ((null? set1) #t)
      (else
       (and (member? (car set1) set2)
            (subset? (cdr set1) set2))))))
```

`set1`が`set2`の部分集合かどうか判定する。

誤:`((null? set1) t)`
正:`((null? set1) #t)`

```scheme
(subset? '(a b) '(a b c d)) ; #t
(subset? '(a b) '(b c a d)) ; #t
(subset? '(a b) '(a c d e)) ; #f
```

## eqset?

```scheme
(define eqset?
  (lambda (set1 set2)
    (and (subset? set1 set2)
         (subset? set2 set1))))
```

`set1`と`set2`が同じ集合か判定する。お互いがお互いの部分集合なら一致している。

```scheme
(subset? '(a b c) '(a b c)) ; #t
(subset? '(a b c) '(a c b)) ; #t
(subset? '(a b c) '(a b))   ; #t
```

## intersect?

```scheme
(define intersect?
  (lambda (set1 set2)
    (cond
      ((null? set1) #f)
      (else (or (member? (car set1) set2)
                (intersect?
                 (cdr set1) set2))))))
```

共通する要素があるか判定する。

誤:`((null? set1) nil)`
正:`((null? set1) #f)`
この誤記多いな。

```scheme
(intersect? '(1 2) '(2 4 6)) ; #t
(intersect? '(1 2) '(3 6 9)) ; #f
```

## intersect

```scheme
(define intersect
  (lambda (set1 set2)
    (cond
      ((null? set1) (quote ()))
      ((member? (car set1) set2)
       (cons (car set1)
             (intersect (cdr set1) set2)))
      (else (intersect (cdr set1) set2)))))
```

共通する要素を抽出した集合を返す。

```scheme
(intersect '(a b c d) '(b c d e)) ; (b c d)
(intersect '(a b c) '(d e f))     ; ()
```

## union

```scheme
(define union
  (lambda (set1 set2)
    (cond
      ((null? set1) set2)
      ((member? (car set1) set2)
       (union (cdr set1) set2))
      (else (cons (car set1)
                  (union (cdr set1) set2))))))
```

各要素を合わせた集合を返す。

```scheme
(union '() '(a b c))  ; (a b c)
(union '(a) '(a b c)) ; (a b c)
(union '(a) '(b c))   ; (a b c)
```

## difference

```scheme
(define difference
  (lambda (set1 set2)
    (cond
      ((null? set1) (quote ()))
      ((member? (car set1) set2)
                (difference (cdr set1) set2))
      (else (cons (car set1)
                  (difference (cdr set1) set2))))))
```

`set1`には含まれているが`set2`には含まれていない要素を返す。

```scheme
(difference '(1 2 3 4) '(2 4)) ; (1 3)
(difference '(1 2) '(1 2 3 4)) ; ()
```

## intersectall

```scheme
(define intersectall
  (lambda (l-set)
    (cond
      ((null? (cdr l-set)) (car l-set))
      (else (intersect (car l-set)
                       (intersectall (cdr l-set)))))))
```

集合のリスト`l-set`について、全集合に共通する要素の集合を返す。

```scheme
(intersectall '((a b c d) (b c d) (c d e))) ; (c d)
```

## a-pair?

```scheme
(define a-pair?
  (lambda (x)
    (cond
      ((atom? x) #f)
      ((null? x) #f)
      ((null? (cdr x)) #f)
      ((null? (cdr (cdr x))) #t)
      (else #f))))
```

ペアかどうか判定する。ここでいうペアは2つのアトムだけからなるリストのこと。

```scheme
(a-pair? 1)        ; #f
(a-pair? '())      ; #f
(a-pair? '(1))     ; #f
(a-pair? '(1 2))   ; #t
(a-pair? '(1 2 3)) ; #f
```

## ペアの補助関数

```scheme
(define first
  (lambda (p)
    (car p)))

(define second
  (lambda (p)
    (car (cdr p))))

(define build
  (lambda (a1 a2)
    (cons a1
          (cons a2 (quote ())))))
```

ペアの要素を取り出す、ペアをつくるための補助関数。

```scheme
(first '(1 2))  ; 1
(second '(1 2)) ; 2
(build 1 2)     ; (1 2)
```

## third

```scheme
(define third
  (lambda (l)
    (car (cdr (cdr l)))))
```

リストの3番目を取り出す。

```scheme
(third '(1 2 3)) ; 3
```

## レル(rel)

ペアの集合のこと。集合なので各要素がユニークでなければならない。

```scheme
((a b) (c d) (e f)) ; <- レル
((a b) (a c) (a d)) ; <- レル
((a b) (c d) (a b)) ; <- (a b)が重複してるのでレルでない
((a b c) (d e f))   ; <- ペアのリストでないのでレルでない
```

レルは関係(`relation`)のことらしいが、なぜ関係なのか。

> なんでペアの集合が関係なのか  
> たとえば1、2、3という数の中で大小の関係を定義するとすれば  
> `((1 2) (1 3) (2 3))`という集合を定義して  
> この集合にfirst = a、second = bとなる要素があるときa < bとする  
> と決めてやれば大小の関係を定義したことになります
> 
> [Scheme手習い(9) 集合と関数 - kb84tkhrのブログ](https://kb84tkhr.hatenablog.com/entry/2016/04/06/205642)

ということらしい。集合の定義が関係の定義になるっていうことかな。数学に強そうな人で参考になる。

## fun?

```scheme
(define fun?
  (lambda (rel)
    (set? (firsts rel))))
```

`rel`の各ペアの第1要素が重複していないことを判定する。

`fun`は`function`のこと。第1要素を`x`、第2要素を`y`と考えればペアの集合は`y=f(x)`という関数とみなすことができる。`fun?`を満たすということは`x`を与えれば`y`が定まることになる。なるほど。

```scheme
(fun? '((1 2) (2 3))) ; #t
(fun? '((1 2) (1 3))) ; #f
```

## revrel

```scheme
(define revrel
  (lambda (rel)
    (cond
      ((null? rel) (quote ()))
      (else (cons (build
                   (second (car rel))
                   (first (car rel)))
                   (revrel (cdr rel)))))))
```

`rel`の各ペアの要素を入れ替えたレルを返す。

```scheme
(revrel '((1 2) (2 3))) ; ((2 1) (3 2))
```

ペアの要素を交換する補助関数を定義して読みやすくする。

```scheme
(define revpair
  (lambda (pair)
    (build (second pair) (first pair))))


(define revrel
  (lambda (rel)
    (cond
      ((null? rel) (quote ()))
      (else (cons (revpair (car rel))
                  (revrel (cdr rel)))))))
```

## fullfun?

```scheme
(define fullfun?
  (lambda (fun)
    (set? (seconds fun))))

(define seconds
  (lambda (l)
    (cond
      ((null? l) (quote ()))
      (else (cons (car (cdr (car l)))
                 (seconds (cdr l)))))))
```

`fun?`では1要素目がユニークであることを判定した。`fullfun?`は2要素目もユニークであることを判定する。

`fullfun`とは一対一対応(全単射)であることを意味している。全単射であることを判定する関数なんだから1要素目もチェックすべきなのでは、と思ったが引数が`fun`であることから`fun?`を満たしている前提なんだろう。そういえばこれまでもそういう感じだった。

```scheme
(fullfun? '((1 2) (2 3) (3 4))) ; #t
(fullfun? '((1 2) (2 2)))       ; #f
```
