;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-abbr-reader.ss" "lang")((modname reduction) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require 2htdp/abstraction)

(define-struct plus (e1 e2))
(define-struct mult (e1 e2))

; exp -> number
(check-expect (eval (make-mult (make-plus 2 3) 4)) 20)
(define (eval e)
  (match e
    [(plus e1 e2) (+ (eval e1) (eval e2))]
    [(mult e1 e2) (* (eval e1) (eval e2))]
    [(? number?) e]))

; An exp is one of:
; - a number
; - (make-plus exp exp)
; - (make-mult exp exp)

(define (value? e) (number? e))

(define-struct ctxp1 (ctx e2))
(define-struct ctxp2 (e1 ctx))
(define-struct ctxm1 (ctx e2))
(define-struct ctxm2 (e1 ctx))
(define-struct hole ())
; A ctx is one of:
; - (make-ctxp1 ctx exp)
; - (make-ctxp2 exp ctx)
; - (make-ctxm1 ctx exp)
; - (make-ctxm2 exp ctx)

; exp -> (list ctx exp)
(define (decompose e)
  (match e
    [(plus e1 e2) (if (value? e1)
                       (if (value? e2)
                           (list (make-hole) e)
                           (match (decompose e2)
                             [(list ctx rdx) (list (make-ctxp2 e1 ctx) rdx)]))
                       (match (decompose e1)
                         [(list ctx rdx) (list (make-ctxp1 ctx e2) rdx)]))]
    [(mult e1 e2) (if (value? e1)
                       (if (value? e2)
                           (list (make-hole) e)
                           (match (decompose e2)
                             [(list ctx rdx) (list (make-ctxm2 e1 ctx) rdx)]))
                       (match (decompose e1)
                         [(list ctx rdx) (list (make-ctxm1 ctx e2) rdx)]))]
    [(? value?) (error "Cannot decompose a value")]))

; ctx exp -> exp
(define (plug ctx e)
  (match ctx
    [(hole) e]
    [(ctxp1 ctx1 e2) (make-plus (plug ctx1 e) e2)]
    [(ctxp2 e1 ctx2) (make-plus e1 (plug ctx2 e))]
    [(ctxm1 ctx1 e2) (make-mult (plug ctx1 e) e2)]
    [(ctxm2 e1 ctx2) (make-mult e1 (plug ctx2 e))]))

; exp -> exp
(define (reduce e)
  (match (decompose e)
    [(list ctx rdx) (plug
                     ctx
                     (match rdx
                      [(plus v1 v2) (+ v1 v2)]
                      [(mult v1 v2) (* v1 v2)]
                      [(? value?) (error "cannot reduce value" rdx)]))]))


(check-expect (reduction-sequence (make-mult (make-plus 3 4) (make-mult 2 3)))
              (list (make-mult (make-plus 3 4) (make-mult 2 3)) (make-mult 7 (make-mult 2 3)) (make-mult 7 6) 42))
; exp -> (list-of exp)
(define (reduction-sequence e)
  (if (value? e)
      (list e)
      (cons e (reduction-sequence (reduce e)))))

