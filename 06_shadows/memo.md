# 影法師

## 算術式

以下のようなものが算術式。

```
1
3
1 + 3
3 ^ y + 5
```

算術式がどうかを判定する関数を定義する。

## numberd?

```scheme
(define numbered?
  (lambda (aexp)
    (cond
      ((atom? aexp) (number? aexp))
      ((eq? (car (cdr aexp)) (quote +))
       (and (numbered? (car aexp))
            (numbered? (car (cdr (cdr aexp))))))
      ((eq? (car (cdr aexp)) (quote ×))
       (and (numbered? (car aexp))
            (numbered?
             (car (cdr (cdr aexp))))))
      ((eq? ((car (cdr aexp) (quote ↑))
            (and (numbered? (car aexp))
                 (numbered?
                  (car (cdr (cdr aexp)))))))))))
```

`(算術式 演算子 算術式)`というリストなら`#t`を返す。

引数`aexp`が算術式である前提の実装。
`else`句がないので想定していない演算子があるとエラーになる。
この前提なら以下のように簡単化できる。

```scheme
(define numbered?
  (lambda (aexp)
    (cond
      ((atom? aexp) (number? aexp))
      (else
       (and (numbered? (car aexp))
            (numbered?
             (car (cdr (cdr aexp)))))))))
```

## value

```scheme
(define value
  (lambda (nexp)
    (cond
      ((atom? nexp) nexp)
      ((eq? (car (cdr nexp)) (quote +))
       (o+ (value (car nexp))
           (value (car (cdr (cdr nexp))))))
       ((eq? (car (cdr nexp)) (quote ×))
        (o* (value (car nexp))
            (value (car (cdr (cdr nexp))))))
       (else
        (^ (value (car nexp))
           (value (car (cdr (cdr nexp)))))))))
```

算術式を計算した結果を返す。

> 第7の戒律
> 
> 性質を同じくするすべての構成部分について再帰すべし。
> すなわち、
> 
> - リストのすべての部分リストについて。
> 
> - 算術式のすべての部分式について。

`value`は算術式を中置記法としていたが、ポーランド記法にした場合も実装してみる。
そのために、算術式から各要素(演算子、1番目の要素、2番目の要素)を抽出する補助関数を定義する。以下、ポーランド記法で考える。

## 1st-sub-exp

```scheme
(define 1st-sub-exp
  (lambda (aexp)
    (car (cdr aexp))))
```

## 2nd-sub-exp

```scheme
(define 2nd-sub-exp
  (lambda (aexp)
    (car (cdr (cdr aexp)))))
```

## operator

```scheme
(define operator
  (lambda (aexp)
    (car aexp)))
```

これらを使って`value`を書き換える。

## value

```scheme
(define value
  (lambda (nexp)
    (cond
      ((atom? nexp) nexp)
      ((eq? (operator nexp) (quote +))
       (o+ (value (1st-sub-exp nexp))
           (value (2nd-sub-exp nexp))))
       ((eq? (operator nexp) (quote ×))
        (o* (value (1st-sub-exp nexp))
            (value (2nd-sub-exp nexp))))
       (else
        (^ (value (1st-sub-exp nexp))
           (value (2nd-sub-exp nexp)))))))
```

また、これを中置記法に戻す場合は、補助関数を変更すればよい。

## 1st-sub-exp

```scheme
(define 1st-sub-exp
  (lambda (aexp)
    (car aexp)))
```

## operator

```scheme
(define operator
  (lambda (aexp)
    (car (cdr aexp))))
```

> 第8の戒律
> 
> 表現から抽象化するに際し、補助関数を使用すべし。

## 数の表現について

数の別の表現を考えてみる。

```
0 -> ()
1 -> (())
2 -> (() ())
```

数をこのように表現するものとしたときの、`zero?`、`add1`、`sub1`を考える。

```scheme
(define sero?
  (lambda (n)
    (null? n)))

(define edd1
  (lambda (n)
    (cons (quote ()) n)))

(define zub1
  (lambda (n)
    (cdr n)))
```

これらを使って`o+`を書いてみる。

```scheme
(define oo+
  (lambda (n m)
    (cond
      ((sero? m) n)
      (else (edd1 (oo+ n (zub1 m)))))))
```

ほとんど`o+`と同じになる。

最後の`lat?`についての話題は、どういう意図なのかいまいちしっくりきていない。

> 数のリストのはずなのに変ですね。
> 
> 影法師に注意しなければなりません。

この表現における`lat?`を定義するとしたらこんな感じか？

```scheme
(define lat??
  (lambda (l)
    (cond
      ((null? l) #t)
      ((null? (car l))
       (and (null? (car l)) (lat?? (cdr l))))
      (else #f))))
```

これは第1の戒律を満たしてるのかなあ……
