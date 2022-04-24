# \*すごい\* 星がいっぱいだ

## rember*

```scheme
(define rember*
  (lambda (a l)
    (cond
      ((null? l) (quote ()))
      ((atom? (car l))
       (cond
         ((eq? (car l) a)
          (rember* a (cdr l)))
         (else (cons (car l)
                     (rember* a (cdr l))))))
      (else (cons (rember* a (car l))
                  (rember* a (cdr l)))))))
```

`l`内のアトム`a`を全て削除したリストを返す。

`rember`との違いは、入れ子のリスト内のアトムも削除対象にしているところ。

```scheme
(rember* 'a '(a b a c a d)) ; (b c d)
(rember* 'a '((a b) a b c)) ; ((b) b c)
(rember 'a '((a b) a b c))  ; ((a b) b c) <- rember
```

## insertR*

```scheme
(define insertR*
  (lambda (new old l)
    (cond
      ((null? l) (quote ()))
      ((atom? (car l))
       (cond
         ((eq? (car l) old)
          (cons old
                (cons new (insertR* new old (cdr l)))))
         (else (cons (car l) (insertR* new old (cdr l))))))
      (else (cons (insertR* new old (car l))
                  (insertR* new old (cdr l)))))))
```

`l`内のアトム`old`の右側に`new`を追加したリストを返す。入れ子内も対象。

```scheme
(insertR* 'b 'a '((a c) a c)) ; ((a b c) a b c)
```

> ### 第1の戒律
> 
> (最終版)
> 
> アトムのリスト`lat`を再帰せしときは、2つの質問、`(null? lat)`と`else`を行うべし。
> 数`n`を再帰せしときは、2つの質問、`(zero? n)`と`else`を行うべし。
> S式のリスト`l`を再帰せしときは、3つの質問、`(null? l)`、`(atom? (car l))`、`else`を行うべし。

> ### 第4の戒律
> 
> (最終版)
> 
> 再帰の時は少なくとも1つの引数を変えるべし。
> アトムのリスト`lat`を再帰せしときは、`(cdr lat)`を用いるべし。
> 数`n`を再帰せしときは、`(sub1)`を用いるべし。
> 式のリスト`l`を再帰せしときは、`(null? l)`も`(atom? (car l))`も真でないならば、`(car l)`と`(cdr l)`を用いるべし。
> 必ず最終条件に向かって変化すべし。
> 変化せし引数は、必ず最終条件でテストすべし。すなわち、`cdr`を用いるときは、最後に`null?`で、`sub1`を用いるときは、最後に`zero?`でテストすべし。

## occur*

```scheme
(define occur*
  (lambda (a l)
    (cond
      ((null? l) 0)
      ((atom? (car l))
       (cond
         ((eq? (car l) a)
          (add1 (occur* a (cdr l))))
         (else (occur* a (cdr l)))))
      (else (o+ (occur* a (car l))
                (occur* a (cdr l)))))))
```

`l`内に`a`がいくつ存在するかを返す。

```scheme
(occur* 'a '((a b) a b)) ; 2
```

## subst*

```scheme
(define subst*
  (lambda (new old l)
    (cond
      ((null? l) (quote ()))
      ((atom? (car l))
       (cond
         ((eq? (car l) old)
          (cons new (subst* new old (cdr l))))
         (else (cons (car l)
                     (subst* new old (cdr l))))))
      (else
       (cons (subst* new old (car l))
             (subst* new old (cdr l)))))))
```

`l`内の`old`をすべて`new`に置き換えたリストを返す。

```scheme
(subst* 'z 'a '((a b) a b)) ; ((z b) z b)
```

## insertL*

```scheme
(define insertL*
  (lambda (new old l)
    (cond
      ((null? l) (quote ()))
      ((atom? (car l))
       (cond
         ((eq? (car l) old)
          (cons new
                (cons old (insertL* new old (cdr l)))))
         (else (cons (car l) (insertL* new old (cdr l))))))
      (else (cons (insertL* new old (car l))
                  (insertL* new old (cdr l)))))))
```

`insertR*`の左側バージョン。

```scheme
(insertL* 'b 'a '((a c) a c)) ; ((b a c) b a c)
```

## member*

```scheme
(define member*
  (lambda (a l)
    (cond
      ((null? l) #f)
      ((atom? (car l))
       (or (eq? (car l) a)
           (member* a (cdr l))))
      (else (or (member* a (car l))
                (member* a (cdr l)))))))
```

`l`内に`a`が含まれているか判定する。

役割的に`member*?`のように`?`をつけるべきなのでは。

あと`((null? l) nil`は誤記だと思われるので`((null? l) #f`に変更。

```scheme
(member* 'a '((a b) b)) ; #t
(member? 'a '((a b) b)) ; #f <- member?は入れ子のリストを探索しない
```

## leftmost

```scheme
(define leftmost
  (lambda (l)
    (cond
      ((atom? (car l)) (car l))
       (else (leftmost (car l))))))
```

`l`内で最も左側にあるアトムを返す。

```scheme
(leftmost '(a b c d))     ; a
(leftmost '((a b) c d))   ; a
(leftmost '(((a) b) c d)) ; a
(leftmost '())            ; NG
(leftmost' (() a b))      ; NG
```

## eqlist?

```scheme
(define eqlist?
  (lambda (l1 l2)
    (cond
      ((and (null? l1) (null? l2)) #t) ; [1]
      (( or (null? l1) (null? l2)) #f) ; [2]
      ((and (atom? (car l1))
            (atom? (car l2)))
       (and (eqan? (car l1) (car l2))
            (eqlist? (cdr l1) (cdr l2)))) ; [3]
      ((or (atom? (car l1))
           (atom? (car l2))) #f) ; [4]
      (else
       (and (eqlist? (car l1) (car l2))
            (eqlist? (cdr l1) (cdr l2))))))) ; [5]
```

リスト同士を比較する。

1. 両方とも`null`なら一致している

2. どちらか片方が`null`なら不一致([1]をチェックしているので、この時点で両方`null`はない

3. `(car l)`が両方ともアトムならアトム同士を比較して残りを再帰する

4. `(car l)`のどちらかがアトムなら不一致

5. それ以外は再帰する

```scheme
(eqlist? '(1 2) '(1 2))   ; #t
(eqlist? '(1 2 3) '(1 2)) ; #f
(eqlist? '() '(1))        ; #f
(eqlist? 'a 'b)           ; NG
```

## equal?

```scheme
(define equal??
  (lambda (s1 s2)
    (cond
      ((and (atom? s1) (atom? s2))
       (eqan? s1 s2))
      ((or (atom? s1) (atom? s2)) #f)
      (else (eqlist? s1 s2)))))
```

組み込みで`equal?`があったので`equal??`として実装。

引数がアトムかリストかチェックして`eqan?`と`eqlist?`を使い分ける。

```scheme
(equal?? 'a 'a)           ; #t
(equal?? 'a 'b)           ; #f
(equal?? '(1 2) '(1 2))   ; #t
(equal?? '(1 2) '(1 2 3)) ; #f
```

`equal?`を使って`eqlist?`を書き換える。

```scheme
(define eqlist?
  (lambda (l1 l2)
    (cond
      ((and (null? l1) (null? l2)) #t)
      ((or (null? l1) (null? l2)) #f)
      (else
       (and (equal?? (car l1) (car l2))
            (eqlist? (cdr l1) (cdr l2)))))))
```

お互いを呼び合う形になって大丈夫かと思ってしまったが、引数が変わっているので大丈夫なのか。

> ### 第6の戒律
> 
> 関数が正しいときのみ簡単かせよ。

## rember

`rember`を一般化する。

```scheme
(define rember
  (lambda (s l)
    (cond
      ((null? l) (quote ()))
      ((atom? (car l))
       (cond
         ((equal?? (car l) s) (cdr l))
         (else (cons (car l)
                     (rember s (cdr l))))))
      (else (cond
              ((equal?? (car l) s) (cdr l))
              (else (cons (car l)
                          (rember s (cdr l)))))))))
```

S式のリスト`l`から任意のS式`s`を削除したリストを返すようにした。

これを簡単化する。

```scheme
(define rember
  (lambda (s l)
    (cond
      ((null? l) (quote ()))
      (else (cond
              ((equal?? (car l) s) (cdr l))
              (else (cons (car l)
                          (rember s (cdr l)))))))))
```

さらに簡単化する。

```scheme
(define rember
  (lambda (s l)
    (cond
      ((null? l) (quote ()))
      ((equal?? (car l) s) (cdr l))
      (else (cons (car l)
                  (rember s (cdr l)))))))
```
