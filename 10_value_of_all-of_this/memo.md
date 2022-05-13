# このすべての値は何だ

## エントリ

同じ長さのリストのペアで、第1のリストが集合であるものをエントリ(entry)という。

```scheme
; エントリの例
((a b c) (hoge fuga moge))
((a b c) (hoge hoge hoge))  ; 第2のリストは重複してもよい
((a b) ((hoge fuga) (moge)) ; 第2のリストはアトムでなくてもよい
```

エントリを作る関数`new-entry`をつくる。

```scheme
(define new-entry build)
```

といっても`build`でよい。

```scheme
(build '(a b c) '(hoge fuga moge))
; ((a b c) (hoge fuga moge))
```

エントリの中から`name`に該当する`value`を取得する関数をつくる。

```scheme
(look-in-entry name entry) ; こんな風に使う関数が欲しい
```

`name`が`entry`に存在しない場合も考える。これまでそういう例外的なことは無視してきたけど、ここでは気にするんだな。

ここでの処置としては、見つからなかった時に呼び出す関数を引数で与えるらしい。

```scheme
(define lookup-in-entry
  (lambda (name entry entry-f)
    (lookup-in-entry-help name
                          (first entry)
                          (second entry)
                          entry-f)))
```

補助関数も定義する。

```scheme
(define lookup-in-entry-help
  (lambda (name names values entry-f)
    (cond
      ((null? names) (entry-f name))
      ((eq? (car names) name)
       (car values))
      (else (lookup-in-entry-help name
                                  (cdr names)
                                  (cdr values)
                                  entry-f)))))
```

`name`が一致すれば対応する`value`を返す。見つからなければ`entry-f`を適用する。

## テーブル

エントリのリストをテーブル(table)という。環境ともいうらしい。

```scheme
(((a b c) (hoge fuga moge)
 ((d e) (bow wow)))
```

新しいエントリをテーブルの先頭に追加する関数をつくる。

```scheme
(define extend-table cons)
```

つまり`cons`のこと。新しい関数でもデータ構造に注目して既存の関数の別名を定義するってのはポイントだよなあ。

テーブルから`name`に該当する`value`を探せるようにする。

```scheme
(define lookup-in-table
  (lambda (name table table-f)
    (cond
      ((null? table) (table-f name))
      (else (lookup-in-entry name
                             (car table)
                             (lambda (name)
                               (lookup-in-table name
                                                (cdr table)
                                                table-f)))))))
```

`(car table)`について`lookup-in-entry`を適用する。見つからなかった場合に適用する関数`entry-f`は`(cdr table)`を引数にした`lookup-in-table`を指定することで再帰させる。

ここまで、エントリとテーブルというものを見てきた。ここから`value`の話になる。
6章で作った`value`は数式表現の結果を返すものだったが、ここでは新しい`value`をつくるらしく、いくつか例が挙げられている。

```scheme
(value (car (quote (a b c)))          ; a
(value (quote (car (quote (a b c))))) ; (car (quote (a b c)))
(value (add1 6))                      ; 7
(value 6)                             ; 6
(value (quote nothing))               ; nothing
(value nothing)                       ; nothingは値を持っていません
```

みたいな感じ。数式表現に限らず式を評価する関数って感じかな。

続いてタイプ(type)という言葉が出てきた。式に対応するタイプがあるらしく、その対応を返す関数を定義する。

```scheme
(define atom-to-action
  (lambda (e)
    (cond
      ((number? e) *const)
      ((eq? e #t) *const)
      ((eq? e #f) *const)
      ((eq? e (quote cons)) *const)
      ((eq? e (quote car)) *const)
      ((eq? e (quote cdr)) *const)
      ((eq? e (quote null?)) *const)
      ((eq? e (quote eq?)) *const)
      ((eq? e (quote atom?)) *const)
      ((eq? e (quote zero?)) *const)
      ((eq? e (quote add1)) *const)
      ((eq? e (quote sub1)) *const)
      ((eq? e (quote number?)) *const)
      (else *identifier))))

(define list-to-action
  (lambda (e)
    (cond
      ((atom? (car e))
       (cond
         ((eq? (car e) (quote quote)) *quote)
         ((eq? (car e) (quote lambda)) *lambda)
         ((eq? (car e) (quote cond)) *cond)
         (else *application)))
      (else *application))))

(define expression-to-action
  (lambda (e)
    (cond
      ((atom? e) (atom-to-action e))
      (else (list-to-action e)))))
```

`*const`とかは関数。これから定義していく。先に`value`を定義しておく。

```scheme
(define meaning
  (lambda (e table)
    ((expression-to-action e) e table)))

(define value
  (lambda (e)
    (meaning e (quote ()))))
```

`value`に対して式を渡すと、その式に対応するアクションを返してくれる。ここでつくる`value`はSchemeの`eval`と同じものらしい。

> アクションは言葉よりも雄弁なり

突然、戒律じゃない言葉が大文字で差し込まれた。アクションというのが重要らしい。

まずは`*const` から見ていく。

```scheme
(define *const
  (lambda (e table)
    (cond
      ((number? e) e)
      ((eq? e #t) #t)
      ((eq? e #f) #f)
      (else (build (quote primitive) e)))))
```

とりあえず動かしてみよう。

```scheme
(value 1)     ; 1
(value #t)    ; #t
(value 'cons) ; (primitive cons)
(value 'eq?)  ; (primitive eq?)
```

ふむ。まあ、実装した通りの挙動であることを確認。続いて`*quote`。

```scheme
(define text-of second)

(define *quote
  (lambda (e table)
    (text-of e)))
```

補助関数も一緒に定義。

```scheme
(value '(quote a)) ; a
```

ここまでは引数の`table`が使われていない。次は`*identifier`。

```scheme
(define initial-table
  (lambda (name)
    (car (quote ()))))

(define *identifier
  (lambda (e table)
    (lookup-in-table e table initial-table)))
```

`initial-table`を定義したけど、これはエラーになるな。呼ばれない前提の定義なんだろうか。

関連する関数が多くて混乱してきたのでいったん全体像を把握する。

![](C:\Users\iyuki\AppData\Roaming\marktext\images\2022-05-10-08-02-11-Untitled%20Diagram%20(1).png)

これで全体を見通せるようになった。補助関数は省略してある。

おおまかに見れば`value`に式を渡して評価させる形。`meaning`の引数`table`がどこで効いてくるのかと思ったが、`*cond`と`*application`から`meaning`に再帰するルートがあるから、ここで影響してくるのか。

次は`*lambda`。

```scheme
(define *lambda
  (lambda (e table)
    (build (quote non-primitive)
           (cons table (cdr e)))))
```

```scheme
(value '(lambda (x) (eq? 'hoge)))
; (non-primitive (() (x) (eq? 'hoge)))
```

`(non-primitive {table} {引数} {本体})`という形に評価される。

次は`*cond`。

```scheme
(define else?
  (lambda (x)
    (cond
      ((atom? x) (eq? x (quote else)))
      (else #f))))

(define question-of first)

(define answer-of second)

(define evcon
  (lambda (lines table)
    (cond
      ((else? (question-of (car lines)))
       (meaning (answer-of (car lines)) table))
      ((meaning (question-of (car lines)) table)
       (meaning (answer-of (car lines)) table))
      (else (evcon (cdr lines) table)))))

(define cond-lines-of cdr)

(define *cond
  (lambda (e table)
    (evcon (cond-lines-of e) table)))
```

`evcon`の実装について、本では`cond`がなかったけどエラーになってしまった。`else`句を書くには`cond`が必要？

```scheme
(value '(cond (#t 'hoge)))
; hoge
```

シンプルな例で動作確認するとこんな感じか。とりあえず全体を把握するために次。

```scheme
(define evlis
  (lambda (args table)
    (cond
      ((null? args) (quote ()))
      (else
       (cons (meaning (car args) table)
             (evlis (cdr args) table))))))

(define primitive?
  (lambda (l)
    (eq? (first l) (quote primitive))))

(define non-primitive?
  (lambda (l)
    (eq? (first l) (quote non-primitive))))

(define :atom?
  (lambda (x)
    (cond
      ((atom? x) #t)
      ((null? x) #f)
      ((eq? (car x) (quote primitive)) #t)
      ((eq? (car x) (quote non-primitive)) #f)
      (else #f))))

(define apply-primitive
  (lambda (name vals)
    (cond
      ((eq? name (quote cons)) (cons (first vals) (second vals)))
      ((eq? name (quote car)) (car (first vals)))
      ((eq? name (quote cdr)) (cdr (first vals)))
      ((eq? name (quote null?)) (null? (first vals)))
      ((eq? name (quote eq?)) (eq? (first vals) (second vals)))
      ((eq? name (quote atom?)) (:atom? (first vals)))
      ((eq? name (quote zero?)) (zero? (first vals)))
      ((eq? name (quote add1)) (add1 (first vals)))
      ((eq? name (quote sub1)) (sub1 (first vals)))
      ((eq? name (quote number?)) (number? (first vals))))))

(define table-of first)

(define formals-of second)

(define body-of third)

(define apply-closure
  (lambda (closure vals)
    (meaning (body-of closure)
             (extend-table
              (new-entry
               (formals-of closure) vals)
              (table-of closure)))))

(define apply^
  (lambda (fun vals)
    (cond
      ((primitive? fun)
       (apply-primitive (second fun) vals))
      ((non-primitive? fun) (apply-closure (second fun) vals)))))

(define function-of car)

(define arguments-of cdr)

(define *application
  (lambda (e table)
    (apply^
     (meaning (function-of e) table)
     (evlis (arguments-of e) table))))
```

これで最後。関数適用。`apply`は組み込み関数と重複するので`apply^`で定義。

ちゃんと動作するか確認。

```scheme
(value '((lambda (n) (add1 n)) 1))
; 2
```

動いた。これの処理を追いかけよう。

まず、引数が`'((lambda (n) (add1 n)) 1)`なので`*application`が適用される。

```scheme
(apply^ (meaning '(lambda (n) (add1 n)) '()) (evlis '(1) '()))
```

```scheme
(meaning '(lambda (n) (add1 n)) '())
(*lambda '(lambda (n) (add1 n)) '())
; (non-primitive (() (n) (add1 n)))
```

```scheme
(evlis '(1) '())
(cons (meaning '(1) '()) (evlis '() '()))
(cons (meaning 1 '()) (evlis '() '()))
(cons 1 '())
; (1)
```

```scheme
(apply^ '(non-primitive (() (n) (add1 n))) '(1))
(apply-closure '(() (n) (add1 n)) '(1))
(meaning '(add1 n) (extend-table (new-entry '(n) '(1)) '()))
(meaning '(add1 n) (extend-table '((n) (1)) '()))
(meaning '(add1 n) '(((n) (1)))) ; tableに情報が保持された状態になった
(apply^ (meaning 'add1 '(((n) (1)))) (evlis '(n) '(((n) (1))))) ; *application適用
```

```scheme
(meaning 'add1 '(((n) (1)))) ; ここではtableは無視されるのか
; (primitive add1)
```

```scheme
(evlis '(n) '(((n) (1))))
(cons (meaning 'n '(((n) (1)))) (evlis '() '(((n) (1)))))
(cons (*identifier 'n '(((n) (1)))) '())
(cons 1 '()) ; look-up-in-table適用
; (1)
```

```scheme
(apply^ (meaning 'add1 '(((n) (1)))) (evlis '(n) '(((n) (1)))))
(apply^ '(primitive add1) '(1))
(apply-primitive 'add1 '(1))
(add1 1)
; 1
```

いくつか省略しながら追いかけてみた。一部パターンしかできてないけど、一応追いかけることはできるな。

9章と10章に関してはまだ理解が浅い気がするが、いったんここまでにして、また何度か読み返すことにしよう。



> これで終わりですか。

> はい。疲れました。



疲れましたね。おもしろかった！
