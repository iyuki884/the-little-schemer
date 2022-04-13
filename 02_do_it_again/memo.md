# もう一度、もう一度、さらにもう一度、またもう一度、……

## lat?

```scheme
(define lat?
  (lambda (l)
    (cond
      ((null? l) #t)
      ((atom? (car l)) (lat? (cdr l)))
      (else #f))))
```

アトムのリストになっているものをラットという。

関数定義する場合の基本的な形式はこういう形。`lat?`で再帰している。

```schemer
(lat? '(1 2))     ; #t
(lat? '())        ; #t
(lat? '((1 2) 3)) ; #f
(lat? 1)          ; NG
```

`car`とかもそうだったけど、引数のデータ構造が不正だと`#f`ではなくエラーを返す。そこは使う側で気を付けようっていうポリシーか。

## member?

```scheme
(define member?
  (lambda (a lat)
    (cond
      ((null? lat) #f)
      (else (or (eq? (car lat) a)
                (member? a (cdr lat)))))))
```

引数を2つとる。
リスト`lat`の中にアトム`a`が存在するかチェックする。

 本だと`((null? lat) nil)`となっているが`nil` は誤記だろうな。

```scheme
(member? 1 '(1 2 3))    ; #t
(member? 4 '(1 2 3))    ; #f
(member? 'a '())        ; #f
(member? '(a) '((a) b)) ; #f <- eq? で比較するので期待した結果にならない
```

> ### 第1の戒律
> 
> (仮) いかなる関数を表現するときも最初の質問はすべて`null?`にすべし。
