# 偉大なる Cons

## rember

```scheme
(define rember
  (lambda (a lat)
    (cond
      ((null? lat) (quote ()))
      ((eq? (car lat) a) (cdr lat))
      (else (cons (car lat)
                  (rember a (cdr lat)))))))
```

ラットを先頭からチェックして、最初に見つかったアトムを取り除いた新しいラットを返す。

```scheme
(rember 3 '(2 3 4))   ; (2 4)
(rember 3 '(2 4))     ; (2 4)
(rember 1 '(1 2 1 2)) ; (2 1 2)
```

> ### 第2の戒律
> 
> リストを作るには`cons`を用いるべし。

## firsts

```scheme
(define firsts
  (lambda (l)
    (cond
      ((null? l) (quote ()))
      (else (cons (car (car l))
                 (firsts (cdr l)))))))
```

リストのリストを引数に取り、各内部リストの最初のS式をリストにして返す。

```scheme
(firsts '((1 2) (3 4) (5 6))) ; (1 3 5)
(firsts '())                  ; ()
(firsts '((a b c)))           ; (a)
(firsts '(a b c))             ; NG
(firsts '((1 2) ()))          ; NG
```

> ### 第3の戒律
> 
> リストを作らんとせしときは、最初の要素になるものを記述し、しかる後にそれを自然なる再帰に`cons`すべし。

## insertR

```scheme
(define insertR
  (lambda (new old lat)
    (cond
      ((null? lat) (quote ()))
      (else (cond
              ((eq? (car lat) old)
               (cons old (cons new (cdr lat))))
              (else (cons (car lat)
                          (insertR new old (cdr lat)))))))))
```

`lat`内で最初に出てきた`old`の右に`new`を追加したリストを返す。

```scheme
(insertR 'c 'b '(a b d)) ; (a b c d)
(insertR 'a 'b '(e f g)) ; (e f g)
(insertR '0 '1 '(1 1 1)) ; (1 0 1 1)
```

### insertL

```scheme
(define insertL
  (lambda (new old lat)
    (cond
      ((null? lat) (quote ()))
      (else (cond
              ((eq? (car lat) old)
               (cons new (cons old (cdr lat))))
              (else (cons (car lat)
                          (insertL new old (cdr lat)))))))))
```

`insertR`の左側に追加するバージョン。

```scheme
(insertL 'a 'b '(b d e)) ; (a b c d)
```

### subst

```scheme
(define subst
  (lambda (new old lat)
    (cond
      ((null? lat) (quote ()))
      (else (cond
              ((eq? (car lat) old)
               (cons new (cdr lat)))
              (else (cons (car lat)
                          (subst new old (cdr lat)))))))))
```

`lat`内で最初に出てきた`old`を`new`で置き換えたリストを返す。

```scheme
(subst 'love 'like '(i like scheme.)) ; (i love scheme.)
```

### subst2

```scheme
(define subst2
  (lambda (new o1 o2 lat)
    (cond
      ((null? lat) (quote ()))
      (else (cond
              ((eq? (car lat) o1)
               (cons new (cdr lat)))
              ((eq? (car lat) o2)
               (cons new (cdr lat)))
            (else (cons (car lat)
                        (subst2 new o1 o2 (cdr lat)))))))))
```

`lat`内で最初に出てくる`o1`か`o2`を`new`で置き換えたリストを返す。

以下のように簡略化できる。

```scheme
(define subst2
  (lambda (new o1 o2 lat)
    (cond
      ((null? lat) (quote ()))
      (else (cond
              ((or (eq? (car lat) o1) (eq? (car lat) o2))
               (cons new (cdr lat)))
            (else (cons (car lat)
                        (subst2 new o1 o2 (cdr lat)))))))))
```

```scheme
(subst2 '1 'a 'b '(a b c)) ; (1 b c)
```

### multirember

```scheme
(define multirember
  (lambda (a lat)
    (cond
      ((null? lat) (quote ()))
       (else
        (cond
          ((eq? (car lat) a)
           (multirember a (cdr lat)))
          (else (cons (car lat)
                      (multirember a (cdr lat)))))))))
```

`lat`内の`a`を削除したリストを返す。

```scheme
(multirember 'a '(a 1 2 a 3 4))  ; (1 2 3 4)
(multirember 'hoge '(hoge hoge)) ; ()
(multirember 'hoge '())          ; ()
```

### multiinsertR

```scheme
(define multiinsertR
  (lambda (new old lat)
    (cond
      ((null? lat) (quote ()))
      (else
       (cond
         ((eq? (car lat) old)
          (cons (car lat)
                (cons new
                      (multiinsertR new old (cdr lat)))))
         (else (cons (car lat)
                     (multiinsertR new old (cdr lat)))))))))
```

`lat`内にあるすべての`old`の右側に`new`を追加したリストを返す。

```scheme
(multiinsertR '2 '1 '(1 3 1 3)) ; (1 2 3 1 2 3)
```

### multiinsertL

```scheme
(define multiinsertL
  (lambda (new old lat)
    (cond
      ((null? lat) (quote ()))
      (else
       (cond
         ((eq? (car lat) old)
          (cons new
                (cons old
                      (multiinsertL new old (cdr lat)))))
         (else (cons (car lat)
                     (multiinsertL new old (cdr lat)))))))))
```

`multiinsertR`の左側バージョン。

```scheme
(multiinsertL '1 '2 '(2 3 2 3)) ; (1 2 3 1 2 3)
```

### multisubst

```scheme
(define multisubst
  (lambda (new old lat)
    (cond
    ((null? lat) (quote ()))
    (else (cond
            ((eq? (car lat) old)
             (cons new
                   (multisubst new old (cdr lat))))
            (else (cons (car lat)
                         (multisubst new old (cdr lat)))))))))
```

`lat`内のすべての`old`を`new`に置き換えたリストを返す。

```scheme
(multisubst '1 'a '(a 2 3 a 2 3)) ; (1 2 3 1 2 3)
```
