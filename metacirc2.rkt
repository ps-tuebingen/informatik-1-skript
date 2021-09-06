#lang racket

; a Val is a Racket Value
; an Env is a (list-of (list Symbol Val))
; a FunDef is a (list-of fundef)
; symbol (list-of const-or-fundef) -> const-def
(define (lookup x env)
  (match env
    [(list) (error "undefined variable: " x)]
    [(cons (list y v) rest) (if (symbol=? x y) v (lookup x rest))]))

; symbol (list-of fundef) -> fun-def
(define (lookup-fun f ctx)
  (match ctx
    [(list) (error "undefined function: " f)]
    [(cons (list 'define (cons g args) e) rest) (if (symbol=? f g) (first ctx) (lookup-fun f rest))]))


; (list-of exp) (list-of const-or-fundef) -> val
(define (eval-all es funs genv lenv)
  (match es
    [(cons e rest) (cons (eval e funs genv lenv) (eval-all rest funs genv lenv))]
    [(list) '()]))

; [X Y] (list-of X) (list-of Y) -> (list-of (list X Y))
(define (zip l1 l2)
  (match l1
    [(cons x xs) (cons (list x (first l2)) (zip xs (rest l2)))]
    [(list) '()]))

(define (lookup-substitution sigma x)
  (match sigma
    [(cons (list y v) rest) (if (symbol=? x y) v (lookup-substitution rest x))]
    [(list) 'not-found]))

(define (compose-substitutions sigma1 sigma2)
  (if (or (equal? sigma1 "no match") (equal? sigma2 "no match"))
      "no match"
      (match sigma1
        [(list) sigma2]
        [(cons (list x v) rest)
         (if (or (equal? (lookup-substitution sigma2 x) 'not-found) (equal? (lookup-substitution sigma2 x) v))
             (cons (list x v) (compose-substitutions rest sigma2))
             "no match")])))

(define (match-all ps es)
  (match (list ps es)
    [(list (list) (list)) (list)]
    [(list (cons p ps2) (cons e es2))
     (compose-substitutions
      (match-pattern p e)
      (match-all ps2 es2))]
    [else "no match"]))

(define (match-pattern p e) 
  (match p
    [(cons 'list ps) (if (list? e)
                         (match-all ps e)
                         "no match")]
    [(list 'cons p1 ps) (if (cons? e)
                         (match-all (list p1 ps) (list (first e) (rest e)))
                         "no match")]
    [other (if (symbol? p) (list (list p e))
               (if (equal? (if (and (list? p) (and (symbol? (first p)) (symbol=? (first p) 'quote))) (second p) p) e) (list) "no match"))]))

;(define (reflect e) (error "ran out of interpreter levels"))
(define (le) (error "ran out of interpreter levels"))
(define (ge) (error "ran out of interpreter levels"))
(define (fs) (error "ran out of interpreter levels"))

; exp (list-of const-or-fundef) -> exp
(define (eval e funs genv lenv)
  (match e
    [(list 'eval-above e) (eval e (fs) (ge) (le))]
    [(list 'le) lenv]
    [(list 'ge) genv]
    [(list 'fs) funs]
    [(list '+ x y) (+ (eval x funs genv lenv) (eval y funs genv lenv))]
    [(list '* x y) (* (eval x funs genv lenv) (eval y funs genv lenv))]
    [(list '= x y) (= (eval x funs genv lenv) (eval y funs genv lenv))]
    [(list 'and x y) (and (eval x funs genv lenv) (eval y funs genv lenv))]
    [(list 'or x y) (or (eval x funs genv lenv) (eval y funs genv lenv))]
    [(list 'cons x xs) (cons (eval x funs genv lenv) (eval xs funs genv lenv))]
    [(list 'current-input-port) (current-input-port)]
    [(list 'read p) (read (eval p funs genv lenv))]
    [(list 'read-line x) (read-line (eval x funs genv lenv))]
    [(list 'eof-object? x) (eof-object? (eval x funs genv lenv))]
    [(list 'peek-char x) (peek-char (eval x funs genv lenv))]
    [(list 'open-input-file x) (open-input-file (eval x funs genv lenv))]
    [(list 'error x) (error (eval x funs genv lenv))]
    [(list 'error x y) (error (eval x funs genv lenv) (eval y funs genv lenv))]
    [(list 'void) (void)]
    [(list 'char=? x y) (char=? (eval x funs genv lenv) (eval y funs genv lenv))]
    [(list 'symbol=? x y) (symbol=? (eval x funs genv lenv) (eval y funs genv lenv))]
    [(list 'equal? x y) (equal? (eval x funs genv lenv) (eval y funs genv lenv))]
    [(list 'symbol? x) (symbol? (eval x funs genv lenv))]
    [(list 'append x y) (append (eval x funs genv lenv) (eval y funs genv lenv))]
    [(list 'first x) (first (eval x funs genv lenv))]
    [(list 'second x) (second (eval x funs genv lenv))]
    [(list 'list? x) (list? (eval x funs genv lenv))]
    [(list 'cons? x) (cons? (eval x funs genv lenv))]
    [(list 'length x) (length (eval x funs genv lenv))]
    [(list 'rest x) (rest (eval x funs genv lenv))]
    [(list 'display x) (display (eval x funs genv lenv))]
    [(list 'file-stream-port? x) (file-stream-port? (eval x funs genv lenv))]
    [(list 'newline) (newline)]
    [(cons 'list xs) (eval-all xs funs genv lenv) ]
    [(list 'quote x) x]
    [(cons 'begin (cons x (list))) (eval x funs genv lenv)]
    [(cons 'begin (cons x xs)) (begin (eval x funs genv lenv) (eval (cons 'begin xs) funs genv lenv))]
    [(cons 'match (cons e1 clauses))
     (match (eval e1 funs genv lenv)
       [v (match clauses
            [(cons (list p e2) rest)
              (if (equal? (match-pattern p v) "no match")
                 (eval (cons 'match (cons (list 'quote v) rest)) funs genv lenv)
                 (eval e2 funs genv (append (match-pattern p v) lenv)))]
            [(list) (error "no match for: " v)])])]    
    [(list 'if e1 e2 e3) (if (eval e1 funs genv lenv) (eval e2 funs genv lenv) (eval e3 funs genv lenv))]
    [(cons f args) (match (lookup-fun f funs)
                     [(list 'define (cons _ params) body)
                      (begin
                        (if (= (length params) (length args))
                            (eval
                               body
                               funs
                               genv
                               (zip params (eval-all args funs genv lenv)))
                            (error "Wrong number of params for: " f params args)))])]
    [other (if (symbol? e) (lookup e (append lenv genv)) e)]));)

(define (skip-hash-lang port)
  (if (char=? (peek-char port) #\#)
      (begin (read-line port) port)
      port))

(define (start funs env port prompt)
  (match (if (file-stream-port? port) (read port) (begin (display prompt) (read port)))
    [(list 'define x e) (if (symbol? x)
                         (start funs (cons  (list x (eval e funs env (list))) env) port prompt)
                         (start (cons (list 'define x e) funs) env port prompt)
                         )
                         ]
    [(list 'open f) (start funs env (skip-hash-lang (open-input-file f)) prompt )]
    [(list 'quit) (void)]
    [e (if (eof-object? e)
           (start funs env (current-input-port) prompt)
           (start (begin (display prompt)  (display (eval e funs env (list))) (newline) funs) env port prompt))]))

(define (run prompt) (start (list) (list) (current-input-port) prompt))

; consider
; (define (halts p) ...)
; now consider
; (define (halts-strange) (if (halts halts-strange) (loop) #true))
; Now consider (halts halts-strange )
; If answer is yes, then it means 