# Scheme手習い

Ohmsha出版の『Scheme手習い The Little Schemer』を読む。

## 実行環境

- Windows 10 (64bit)

- [DrRacket](https://racket-lang.org/)(version 8.4, Language:R5RS)

## 動機

問いと答えが並ぶ構成がおもしろそうだったので購入。Lispは全く馴染みがない。

> この本の目的は、読者に再帰的に考えることを教えることにある。

定期的にHaskell学びたい欲が湧いてくるので、関数型プログラミングの基礎固めにもちょうどいいんじゃないかな。

## 準備

「はじめに」に記載されている通り、Schemeの一部の機能を使って進めていく構成らしい。

```scheme
car
cdr
cons
eq?
null?
zero?
number?
and
or
quote
lambda
define
cond
```

Schemeの仕様は色々あるらしいけど、上記実装がされていればどれでもよさそうなのでR5RSを採用する。(ちなみに本文では基本的にSchemeのコードが書かれているけど、注釈でCommon Lispのコードが載っている)

また、上記に加えて以下の3つの関数を定義して使う。ちなみに、この3つでは上記以外の関数を使って定義している。まあ、例外ってことなんだろう。

```scheme
atom?
add1
sub1
```

## 正誤表

細かい誤記っぽいのが散見されるのでメモ。

| ページ | 誤                            | 正                                   | 備考                                                    |
|:---:|:----------------------------:|:-----------------------------------:|:-----------------------------------------------------:|
| 23  | `((null? lat) nil)`          | `((null? lat) #f)`                  | `member?`の4行目                                         |
| 89  | `((null? l) nil)`            | `((null? l) #f)`                    | `member*`の4行目                                         |
| 116 | `((null? set1) t)`           | `((null? set1) #t)`                 | `subset?`の4行目                                         |
| 117 | `((null? set1) nil)`         | `((null? set1) #f)`                 | `intersect?`の4行目                                      |
| 137 | `((test? a (cat lat))`       | `((test? a (car lat))`              | `multirember-f`の6行目                                   |
| 146 | lad は ...                    | lat は ...                           | 一番上の質問左側の7行目                                          |
| 146 | `even-only*`を書いてください。        | `evens-only*`を書いてください。              | 4番目の質問左側の2行目<br/>以降は`evens-only*`になっているので誤記だろう        |
| 154 | `para`                       | `pora`                              | `align`の引数<br/>意味的に`pora`(Pair OR Atom)の方が適切な気がする     |
| 155 | `para`                       | `pora`                              | `length*`の引数<br/>同上                                   |
| 183 | `add1?`<br/>`sub1?`          | `add1`<br/>`sub1`                   | `atom-to-action`の条件式<br/>`?`は不要                       |
| 190 | `(lambda (x) ((atom? x)...)` | `(lambda (x) (cond ((atom? x) ...)` | `:atom?`の定義で`cond`がない<br/>`else`があるので`cond`なしだとエラーになる |
