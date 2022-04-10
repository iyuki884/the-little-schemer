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
