(define atom?
  (lambda (x)
    (and (not (pair? x)) (not (null? x)))))

(define lat?
  (lambda (l)
    (cond
      ((null? l) #t)
      ((atom? (car l)) (lat? (cdr l)))
      (else #f))))

(define member?
  (lambda (a lat)
    (cond
      ((null? lat) #f)
      (else (or (eq? (car lat) a)
                (member? a (cdr lat)))))))


(define firsts
  (lambda (l)
    (cond
      ((null? l) (quote ()))
      (else (cons (car (car l))
                 (firsts (cdr l)))))))

(define subst2
  (lambda (new o1 o2 lat)
    (cond
      ((null? lat) (quote ()))
      (else (cond
              ((or (eq? (car lat) o1) (eq? (car lat) o2))
               (cons new (cdr lat)))
            (else (cons (car lat)
                        (subst2 new o1 o2 (cdr lat)))))))))

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

(define add1
  (lambda (n)
    (+ n 1)))

(define sub1
  (lambda (n)
    (- n 1)))

(define o+
  (lambda (n m)
    (cond
      ((zero? m) n)
      (else (add1 (o+ n (sub1 m)))))))

(define o-
  (lambda (n m)
    (cond
      ((zero? m) n)
      (else (sub1 (o- n (sub1 m)))))))

(define addtup
  (lambda (tup)
    (cond
      ((null? tup) 0)
      (else (o+ (car tup) (addtup (cdr tup)))))))

(define o*
  (lambda (n m)
    (cond
      ((zero? m) 0)
      (else (o+ n (o* n (sub1 m)))))))

(define tup+
  (lambda (tup1 tup2)
    (cond
      ((null? tup1) tup2)
      ((null? tup2) tup1)
      (else
       (cons (o+ (car tup1) (car tup2))
             (tup+ (cdr tup1) (cdr tup2)))))))

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

(define o=
  (lambda (n m)
    (cond
      ((o> n m) #f)
      ((o< n m) #f)
      (else #t))))

(define ^
  (lambda (n m)
    (cond
      ((zero? m) 1)
      (else (o* n (^ n (sub1 m)))))))

(define o/
  (lambda (n m)
    (cond
      ((o< n m) 0)
      (else (add1 (o/ (o- n m) m))))))

(define length2
  (lambda (lat)
    (cond
      ((null? lat) 0)
      (else (add1 (length2 (cdr lat)))))))

(define pick
  (lambda (n lat)
    (cond
      ((zero? (sub1 n)) (car lat))
      (else (pick (sub1 n) (cdr lat))))))

#|
(define rempick
  (lambda (n lat)
    (cond
      ((zero? (sub1 n)) (cdr lat))
      (else (cons (car lat)
                  (rempick (sub1 n)
                           (cdr lat)))))))
|#

(define no-nums
  (lambda (lat)
    (cond
      ((null? lat) (quote ()))
      (else (cond
              ((number? (car lat))
               (no-nums (cdr lat)))
              (else (cons (car lat)
                          (no-nums (cdr lat)))))))))

(define all-nums
  (lambda (lat)
    (cond
      ((null? lat) (quote ()))
      (else
       (cond
         ((number? (car lat))
          (cons (car lat) (all-nums (cdr lat))))
         (else (all-nums (cdr lat))))))))

(define eqan?
  (lambda (a1 a2)
    (cond
      ((and (number? a1) (number? a2))
       (o= a1 a2))
      ((or (number? a1) (number? a2)) #f)
      (else (eq? a1 a2)))))

(define occur
  (lambda (a lat)
    (cond
      ((null? lat) 0)
      (else
       (cond
         ((eq? (car lat) a)
          (add1 (occur a (cdr lat))))
         (else (occur a (cdr lat))))))))

(define one?
  (lambda (n)
    (o= n 1)))

(define rempick
  (lambda (n lat)
    (cond
      ((one? n) (cdr lat))
      (else (cons (car lat)
                  (rempick (sub1 n)
                           (cdr lat)))))))

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

(define member*
  (lambda (a l)
    (cond
      ((null? l) #f)
      ((atom? (car l))
       (or (eq? (car l) a)
           (member* a (cdr l))))
      (else (or (member* a (car l))
                (member* a (cdr l)))))))

(define leftmost
  (lambda (l)
    (cond
      ((atom? (car l)) (car l))
       (else (leftmost (car l))))))

(define equal??
  (lambda (s1 s2)
    (cond
      ((and (atom? s1) (atom? s2))
       (eqan? s1 s2))
      ((or (atom? s1) (atom? s2)) #f)
      (else (eqlist? s1 s2)))))

(define eqlist?
  (lambda (l1 l2)
    (cond
      ((and (null? l1) (null? l2)) #t)
      ((or (null? l1) (null? l2)) #f)
      (else
       (and (equal?? (car l1) (car l2))
            (eqlist? (cdr l1) (cdr l2)))))))

(define numbered?
  (lambda (aexp)
    (cond
      ((atom? aexp) (number? aexp))
      (else
       (and (numbered? (car aexp))
            (numbered?
             (car (cdr (cdr aexp)))))))))

(define 1st-sub-exp
  (lambda (aexp)
    (car aexp)))

(define 2nd-sub-exp
  (lambda (aexp)
    (car (cdr (cdr aexp)))))

(define operator
  (lambda (aexp)
    (car (cdr aexp))))

(define sero?
  (lambda (n)
    (null? n)))

(define edd1
  (lambda (n)
    (cons (quote ()) n)))

(define zub1
  (lambda (n)
    (cdr n)))

(define oo+
  (lambda (n m)
    (cond
      ((sero? m) n)
      (else (edd1 (oo+ n (zub1 m)))))))

(define lat??
  (lambda (l)
    (cond
      ((null? l) #t)
      ((null? (car l))
       (and (null? (car l)) (lat?? (cdr l))))
      (else #f))))

(define set?
  (lambda (lat)
    (cond
      ((null? lat) #t)
      ((member? (car lat) (cdr lat)) #f)
      (else (set? (cdr lat))))))

(define makeset
  (lambda (lat)
    (cond
      ((null? lat) (quote ()))
      (else (cons (car lat)
                  (makeset
                   (multirember (car lat)
                                (cdr lat))))))))

(define subset?
  (lambda (set1 set2)
    (cond
      ((null? set1) #t)
      (else
       (and (member? (car set1) set2)
            (subset? (cdr set1) set2))))))

(define eqset?
  (lambda (set1 set2)
    (and (subset? set1 set2)
         (subset? set2 set1))))

(define intersect?
  (lambda (set1 set2)
    (cond
      ((null? set1) #f)
      (else (or (member? (car set1) set2)
                (intersect?
                 (cdr set1) set2))))))

(define intersect
  (lambda (set1 set2)
    (cond
      ((null? set1) (quote ()))
      ((member? (car set1) set2)
       (cons (car set1)
             (intersect (cdr set1) set2)))
      (else (intersect (cdr set1) set2)))))

(define union
  (lambda (set1 set2)
    (cond
      ((null? set1) set2)
      ((member? (car set1) set2)
       (union (cdr set1) set2))
      (else (cons (car set1)
                  (union (cdr set1) set2))))))

(define difference
  (lambda (set1 set2)
    (cond
      ((null? set1) (quote ()))
      ((member? (car set1) set2)
                (difference (cdr set1) set2))
      (else (cons (car set1)
                  (difference (cdr set1) set2))))))

(define intersectall
  (lambda (l-set)
    (cond
      ((null? (cdr l-set)) (car l-set))
      (else (intersect (car l-set)
                       (intersectall (cdr l-set)))))))

(define a-pair?
  (lambda (x)
    (cond
      ((atom? x) #f)
      ((null? x) #f)
      ((null? (cdr x)) #f)
      ((null? (cdr (cdr x))) #t)
      (else #f))))

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

(define third
  (lambda (l)
    (car (cdr (cdr l)))))

(define fun?
  (lambda (rel)
    (set? (firsts rel))))

(define revpair
  (lambda (pair)
    (build (second pair) (first pair))))

(define revrel
  (lambda (rel)
    (cond
      ((null? rel) (quote ()))
      (else (cons (revpair (car rel))
                  (revrel (cdr rel)))))))

(define fullfun?
  (lambda (fun)
    (set? (seconds fun))))

(define seconds
  (lambda (l)
    (cond
      ((null? l) (quote ()))
      (else (cons (car (cdr (car l)))
                 (seconds (cdr l)))))))

(define eq?-c
  (lambda (a)
    (lambda (x)
      (eq? x a))))

(define eq?-salada (eq?-c 'salada))

(define rember-f
  (lambda (test?)
    (lambda (a l)
      (cond
        ((null? l) (quote ()))
        ((test? (car l) a) (cdr l))
        (else (cons (car l)
                    ((rember-f test?) a (cdr l))))))))

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

(define insertL
  (insert-g
   (lambda (new old l)
     (cons new (cons old l)))))

(define insertR
  (insert-g
   (lambda (new old l)
     (cons old (cons new l)))))

(define seqS
  (lambda (new old l)
    (cons new l)))

(define subst (insert-g seqS))

(define seqrem
  (lambda (new old l)
    l))

(define rember
  (lambda (a l)
    ((insert-g seqrem) #f a l)))

(define atom-to-function
  (lambda (x)
    (cond
      ((eq? x (quote +)) o+)
      ((eq? x (quote ×)) o*)
      (else ^))))

(define value
  (lambda (nexp)
    (cond
      ((atom? nexp) nexp)
      (else
       ((atom-to-function
         (operator nexp))
        (value (1st-sub-exp nexp))
        (value (2nd-sub-exp nexp)))))))

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

(define multirember-eq?
  (multirember-f eq?))

(define eq?-tuna
  (eq?-c (quote tuna)))

(define multiremberT
  (lambda (test? lat)
    (cond
      ((null? lat) (quote ()))
      ((test? (car lat))
       (multiremberT test? (cdr lat)))
      (else (cons (car lat)
                  (multirembert test?
                                (cdr lat)))))))

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

(define a-friend
  (lambda (x y)
    (null? y)))

(define last-friend
  (lambda (x y)
    (length x)))

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

(define LR-counts
  (lambda (lat L R)
    (cons L (cons R lat))))

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

(define the-last-friend
  (lambda (newl product sum)
    (cons sum
          (cons product
                newl))))

(define keep-looking
  (lambda (a sorn lat)
    (cond
      ((number? sorn)
       (keep-looking a (pick sorn lat) lat))
      (else (eq? sorn a)))))


(define looking
  (lambda (a lat)
    (keep-looking a (pick 1 lat) lat)))

(define eternity
  (lambda (x)
    (eternity x)))

(define shift
  (lambda (pair)
    (build (first (first pair))
           (build (second (first pair))
                  (second pair)))))

(define align
  (lambda (pora)
    (cond
      ((atom? pora) pora)
      ((a-pair? (first pora))
       (align (shift pora)))
      (else (build (first pora)
                   (align (second pora)))))))

(define length*
  (lambda (pora)
    (cond
      ((atom? pora) 1)
      (else
       (o+ (length* (first pora))
                    (length* (second pora)))))))

(define weight*
  (lambda (pora)
    (cond
      ((atom? pora) 1)
      (else
       (o+ (o* (weight* (first pora)) 2)
           (weight* (second pora)))))))

(define shuffle
  (lambda (pora)
    (cond
      ((atom? pora) pora)
      ((a-pair? (first pora))
       (shuffle (revpair pora)))
      (else (build (first pora)
                   (shuffle (second pora)))))))

(define C
  (lambda (n)
    (cond
      ((one? n) 1)
      (else
       (cond
         ((even? n) (C (o/ n 2)))
       (else (C (add1 (o* 3 n)))))))))

(define A
  (lambda (n m)
    (cond
      ((zero? n) (add1 m))
      ((zero? m) (A (sub1 n) 1))
      (else (A (sub1 n)
               (A n (sub1 m)))))))
