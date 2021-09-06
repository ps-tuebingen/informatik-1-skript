;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname metacirc) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp")) #f)))
(require 2htdp/abstraction)

; symbol (list-of const-or-fundef) -> const-def
(define (lookup-const c ctx)
  (match ctx
    ['() (error "undefined constant")]
    [(cons `(define ,x ,e) rest) (if (symbol=? c x) e (lookup-const c rest))]))

; symbol (list-of const-or-fundef) -> fun-def
(define (lookup-fun f ctx)
  (match ctx
    ['() (error "undefined function")]
    [(cons (list 'define (cons g args) e) rest) (if (symbol=? f g) (first ctx) (lookup-fun f rest))]
    [(cons constdef rest) (lookup-fun f rest)]))

; (list-of exp) (list-of (list symbol exp)) -> (list-of exp)
(define (subst-list es sigma)
  (match es
    [(cons e rest) (cons (subst e sigma) (subst-list rest sigma))]
    ['() empty]))

(define-struct subst-failure ())

; symbol (list-of (list symbol exp)) -> exp or subst-failure
(define (lookup-subst x sigma)
  (match sigma
    [(cons (list y e) rest) (if (symbol=? x y) e (lookup-subst x rest))]
    ['() (make-subst-failure)]))

; exp (list-of (list symbol exp)) -> exp
(define (subst e sigma)
  (match e
    [(cons f args) (cons f (subst-list args sigma))]
    [(? symbol?) (match (lookup-subst e sigma) [(? subst-failure?) e] [res res])]
    [(? number?) e]))

; (list-of exp) (list-of const-or-fundef) -> val
(define (eval-all es ctx)
  (match es
    [(cons e rest) (cons (eval e ctx) (eval-all rest ctx))]
    ['() empty]))

; [X Y] (list-of X) (list-of Y) -> (list-of (list X Y))
(define (zip l1 l2)
  (match l1
    [(cons x xs) (cons (list x (first l2)) (zip xs (rest l2)))]
    ['() empty]))

; exp (list-of const-or-fundef) -> val
(define (eval e ctx)
  (match e
    [`(+ ,x ,y) (+ (eval x ctx) (eval y ctx))]
    [`(* ,x ,y) (* (eval x ctx) (eval y ctx))]
    [(? symbol?) (lookup-const e ctx)]
    [(cons f args) (match (lookup-fun f ctx)
                     [(list 'define (cons _ params) body)
                      (eval
                       (subst body (zip params (eval-all args ctx)))
                       ctx)])]
    [(? number?) e]))

(define testctx '((define x 7) (define (plus2 y) (+ y 2))))

(check-expect (eval '(* (plus2 x) 3) testctx) 27)