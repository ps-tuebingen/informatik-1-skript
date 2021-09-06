#lang scribble/manual
@(require scribble/eval)
@(require "marburg-utils.rkt")
@(require (for-label lang/htdp-intermediate-lambda))
@(require (for-label (except-in 2htdp/image image?)))
@(require (for-label 2htdp/abstraction))
@(require scribble/bnf)
   
@title[#:version ""]{Programmieren mit Higher-Order Funktionen}

In diesem Kapitel wollen wir uns einige Funktionen und Programmiertechniken
anschauen, die typisch für funktionale Programmierung mit Higher-Order Funktionen sind.

@section{Funktionskomposition und "Point-Free Style"}

Eine Standard Higher-Order Funktion ist die Funktionskomposition.

@#reader scribble/comment-reader
(racketblock
; [X Y Z] (Y -> Z) (X -> Y) -> (X -> Z)
(define (compose f g) (λ (x) (f (g x))))
)
Auf diese Art und Weise können bequem Funktionen hintereinandergeschaltet
werden, ohne immer umständlich einen Lambda-Ausdruck verwenden zu müssen.

Beispielsweise können wir schreiben:
@interaction[#:eval (isl-eval+)
(map (compose add1 sqrt) (list 9 4 16))]

statt:
@interaction[#:eval (isl-eval+)
(map (lambda (x) (add1 (sqrt x))) (list 9 4 16))]

Funktionen wie @racket[compose] ermöglichen einen Programmierstil auf einem abstrakteren Level, bei dem
vermieden wird, explizite Funktionsargumente zu verwenden wird, sondern stattdessen verschiedene
Higher-Order Funktionen wie  @racket[compose] verwendet werden (solche Higher-Order Funktionen werden
häufig auch @italic{Kombinatoren} genannt) um Funktionen miteinander zu verknüpfen.

Eine Funktion, die zu ihrem Argument zwei hinzuaddiert, könnten wir im "Point-Free Style" so definieren:

@#reader scribble/comment-reader
(racketblock
; Number -> Number
(define add2 (compose add1 add1))
)

Der konventionelle Programmierstil, in dem alle Argumente explizit benannt und verwendet werden, wird in diesem
Zusammenhang manchmal "Pointful Style" genannt.

@#reader scribble/comment-reader
(racketblock
; Number -> Number
(define (add2 x) (add1 (add1 x)))
)
Point-free style kann zu kürzeren und besser lesbaren Programmen führen. In manchen Situationen wird jedoch
die Lesbarkeit und Wartbarkeit jedoch auch erschwert, weshalb manchmal dieser Programmierstil auch
ironisch abwertend "pointless style" genannt wird.

@section{Currying und Typisomorphien von Funktionstypen}
Mittels Funktionen höherer Ordnung können Funktionen, die mehrere Argumente erwarten, in Funktionen transformiert werden,
die nur ein Argument bekommen und eine Funktion zurückliefert die die noch fehlenden Argumente erwartet. Diese
Transformation nennt man @italic{currying}, nach dem Logiker Haskell B. Curry. Die Transformation in die umgekehrte Richtung
nennt man @italic{uncurry}. Sie sind wie folgt definiert. @margin-note{Um Klammern zu vermeiden, wird der Funktionspfeil
 typischerweise als rechtsassoziativ interpretiert, also @racket[X -> Y -> Z] bedeutet @racket[X -> (Y -> Z)] und
 nicht @racket[(X -> Y) -> Z].}
}

@#reader scribble/comment-reader
(racketblock

; [X Y Z] (X Y -> Z) -> X -> Y -> Z
(define (curry f) (λ (x) (λ (y) (f x y))))

; [X Y Z] (X -> Y -> Z) -> X Y -> Z
(define (uncurry f) (λ (x y) ((f x) y)))
)

Beispielsweise können wir eine Funktion zur Addition von 5 zu ihrem Argument definieren als:

@#reader scribble/comment-reader
(racketblock
; Number -> Number
(define add5 ((curry +) 5))
)

Man kann statt einem nachträglichen Aufruf von @racket[curry] auch direkt in einer Funktionsdefinition
currying betreiben. Die @racket[foldr] Funktion kann beispielsweise so umformuliert werden, dass die
Liste auf der gefaltet werden soll noch nicht direkt als Argument mitgegeben wird sondern stattdessen
eine Funktion zurückgegeben wird die auf die Liste wartet.

@#reader scribble/comment-reader
(racketblock
; [X Y] (X Y -> Y) Y -> (list-of X) -> Y
(define (foldr op z)
  (λ (l)
    (cond
      [(empty? l) z]
      [else
       (op (first l)
           ((foldr op z) (rest l)))])))
)
Der Vorteil dieses "curried" folds ist, dass nun viele Funktionen im point-free style kurz und prägnant
definiert werden können, zum Beispiel:

@#reader scribble/comment-reader
(racketblock
; (list-of Number) -> Number
(check-expect (sum-list (list 2 3 4)) 9)
(define sum-list (foldr + 0))

; (list-of Number) -> Number
(check-expect (product-list (list 2 3 4)) 24)
(define product-list (foldr * 1))
)

Die Funktionen @racket[curry] und @racket[uncurry] bilden zusammen die Bijektion eines Typisomorphismus zwischen
@racket[X Y -> Z] und @racket[X -> Y -> Z]. In @secref{refactoring-adt} haben wir gesehen, dass sich Typisomorphien
ähnlich wie Gleichheiten arithmetischer Ausdrücke verhalten wenn wir @racket[*] als Konstruktor für Produkttypen
@margin-note{In der Kategorientheorie werden Funktionstypen verallgemeinert zu sogenannten @italic{exponential objects}.}
und @racket[+] als Konstruktor für (disjunkte) Summentypen verwenden. Diese Analogie können wir auf Funktionstypen
erweitern indem wir Funktionen @racket[X -> Y] als Exponential @racket[Y]@superscript{@racket[X]} interpretieren.


Für das Rechnen mit Exponenten kennen wir die gewohnten Gleichungen

@racket[X]@superscript{@racket[Y*Z]} = @racket[X]@superscript{Y@superscript{Z}}

und 

@racket[X]@superscript{@racket[Y+Z]} = @racket[X]@superscript{Y} * @racket[X]@superscript{Z}

Die erste Gleichung beschreibt exakt die durch @racket[curry] und @racket[uncurry] ausgedrückte Typisomorphie.

Die zweite Gleichung gibt an, dass die Typen @racket[Y+Z -> X] und @racket[(Y -> X) * (Z->X)] isomorph sind. Dies
ist nicht schwer zu sehen. Wenn ich eine Funktion von  @racket[Y+Z] nach @racket[X] habe, so kann ich sie offensichtlich
als Funktion von @racket[Y] nach @racket[X] wie auch von @racket[Z] nach @racket[X] verwenden, denn sie kann ja mit
beiden Typen von Argumenten umgehen. Umgekehrt kann ich (bei disjunkten Summen) eine Paar von Funktionen
@racket[(Y -> X) * (Z->X)] umbauen zu einer Funktion vom Typ @racket[Y+Z -> X], indem ich in der zu erstellenden
Funktion prüfe, ob die Eingabe zum linken oder zum rechten Fall gehört und je nachdem die richtige Funktion aus dem Paar aufrufe.

Auch weitere typische Identitäten aus der Algebra können für Typisomorphien verwendet werden. Erinnern Sie sich daran, dass
der Typ @racket[1] die Äuivalenzklasse aller Typen mit nur einem Wert ist, der Typ @racket[2] die Äquivalenzklasse aller Typen mit zwei Werten
(wie Boolean) ist. Dann gilt

@racket[X]@superscript{@racket[1]} = @racket[X]

sowie 

@racket[X]@superscript{@racket[2]} = @racket[X * X]

Die erste Isomorphie sagt aus, dass Funktionen von @racket[1] nach @racket[X] isomorph zu @racket[X] sind. Da es nur ein mögliches
Argument gibt, muss das Resultat jedes Funktionsaufrufs das immer gleiche Element aus @racket[X] sein.

Die zweite Isomorphie sagt aus, dass der Typ @racket[Bool -> X] isomorph zu @racket[X*X] ist. Dies ist nicht schwer zu sehen. Da @racket[#true]
und @racket[#false] die einzigen möglichen Argumente der Funktion sind, gibt es genau zwei Werte aus @racket[X] die die Funktion liefern kann.
Umgekehrt kann aus einem Paar aus @racket[X*X] leicht eine Funktion vom Typ @racket[Bool -> X] gemacht werden: Wenn das Argument @racket[#true]
ist, nimm die erste Komponente des Paars, bei @racket[#false] das zweite.

@section{Map, filter, flatmap}
Weitere typische Higher-Order Funktionen für den Umgang mit Listen sind @racket[map], @racket[filter] und @racket[flatmap].
Sie sind wie folgt definiert:

@#reader scribble/comment-reader
(racketblock

; [X Y] (X -> Y) (list-of X) -> (list-of Y)
(define (map f xs)
  (cond [(empty? xs) empty]
        [(cons? xs)
         (cons (f (first xs))
               (map f (rest xs)))]))

; [X] (X -> Boolean) (list-of X) -> (list-of X)
(define (filter f xs)
  (cond [(empty? xs) empty]
        [(cons? xs) (if (f (first xs))
                        (cons (first xs) (filter1 f (rest xs)))
                        (filter f (rest xs)))]))

; [X Y] (X -> (list-of Y)) (list-of X) -> (list-of Y)
(define (flatmap f xs)
  (foldr
    append
    empty
    (map f xs)))
)
Die ersten beiden Funktionen sind nahezu selbsterklärend. Die @racket[map] Funktion wendet eine Funktion auf
jedes Listenelement an und fügt die Ergebnisse wieder zu einer Liste zusammen.
@interaction[#:eval (isl-eval+)
(map add1 (list 1 2 3))]

Die @racket[filter] Funktion gibt alle Elemente einer Liste zurück, für die eine boolsche Funktion
@racket[#true] ergibt.

@interaction[#:eval (isl-eval+)
(filter even? (list 1 2 3 4))]

Die @racket[map] Funktion in der Racket Bibliothek kann sogar noch auf eine mächtigere Art und Weise benutzt
werden. Mann kann mehrere Listen übergeben die dann synchron durchgegangen werden. Die Funktion, die übergeben
wird muss soviele Argumente bekommen wie man Listen übergeben hat und wird dann jeweils auf die n-ten Elemente der Listen
angewendet. Hier ein Beispiel dazu:
@interaction[#:eval (isl-eval+)
(map cons (list 1 2 3) (list (list 4 5) (list 6 7) (list 8 9)))]

Die @racket[flatmap] Funktion ist vielleicht etwas schwerer zu verstehen.
@margin-note{In anderen Sprachen heisst diese Funktion manchmal @italic{concatMap} oder @italic{selectMany}. Es gibt
eine mächtige Verallgemeinerung der @racket[flatmap] Funktion durch sogenannte @italic{Monaden}.}
Sie wendet wie @racket[map] eine Funktion auf alle Listenargumente an, aber die Funktion gibt jeweils eine
Liste zurück und @racket[flatmap] konkateniert all diese Ergebnislisten. Beispielsweise ergibt der
Aufruf @racket[(flatmap (lambda (x) (list x x)) (list 1 2 3))] das Ergebnis @racket[(list 1 1 2 2 3 3)].
Diese Funktionalität ist beispielsweise nützlich, um so etwas wie "List Comprehensions" auszudrücken.
List Comprehensions ermöglichen es, Listen in einer ähnlichen Weise zu definieren wie Mengen in der
Mengenlehre. In der Mathematik könnten wir beispielsweise die Menge der pythagoreischen Tripel (also natürlichen Zahlen
a,b,c für die gilt: a^2 + b^2 = c^2) zwischen
1 und n wie folgt definieren:

{ (x,y,z) | x in {1..n}, y in {x..n}, z in {x..n}, x*x+y*y = z*z}

In der Sprache Racket (nicht BSL/ISL) kann beispielsweise eine Liste der pythagoreischen Tripel wie folgt berechnet werden:

@#reader scribble/comment-reader
(racketblock
(define (pyth n)
  (for*/list ((x (range 1 n 1))
              (y (range x n 1))
              (z (range x n 1))
              #:when (= (+ (* x x) (* y y)) (* z z)))
               (list x y z)))
)

Mit Hilfe von @racket[flatmap] können wir solche List-Comprehensions wie folgt ausdrücken:
@#reader scribble/comment-reader
(racketblock
; Nat -> (list-of (list-of Nat))
(check-expect (pyth 15) (list (list 3 4 5) (list 5 12 13) (list 6 8 10)))
(define (pyth n)
  (flatmap (λ (x)
     (flatmap (λ (y)
        (flatmap (λ (z)
           (if (= (+ (* x x) (* y y)) (* z z))
               (list (list x y z))
               empty))
         (range y n 1)))
      (range x n 1)))
   (range 1 n 1)))
)
Man sieht dass die @racket[for*/list] Syntax besser lesbar ist, aber man sieht, dass wir prinzipiell das
gleiche mit @racket[flatmap] ausdrücken können.

@section{Konstruktion von Listen mit unfold}
Die @racket[foldr] Funktion von oben abstrahiert das Pattern der strukturellen Rekursion auf Listen, also des
Zerlegens (Dekonstruktion) von Listen. Es gibt auch eine "duale" Funktion zur Konstruktion von Listen. Es wird
also keine Liste als Eingabe genommen und zerlegt sondern es geht in der @racket[unfold] Funktion um
die Konstruktion von Listen. Man kann sie wie folgt definieren:

@#reader scribble/comment-reader
(racketblock
; [X Y] (Y -> Bool) (Y -> Y) (Y -> X) Y -> (list-of X)
; (stop (next ... (next seed))) must yield #true after a finite number of iterations
(define (unfold stop next emit seed)
  (if (stop seed)
      empty
      (cons (emit seed)
            (unfold stop next emit (next seed)))))

; Number -> (list-of Number)
(check-expect (one-to-n 5) (list 1 2 3 4 5))
(define (one-to-n n) (unfold (λ (m) (> m n)) add1 identity 1))
)
Wir sehen, dass die @racket[unfold] Funktion rekursiv ist, aber nicht strukturell rekursiv in einer Eingabe, deshalb
ist nicht offensichtlich, dass diese Funktion terminiert. Der aktuelle Zustand von @racket[unfold], @racket[seed],
wird in jedem Iterationsschritt durch die Funktion @racket[next] in einen neuen Zustand überführt und dann von
@racket[stop] abgefragt. Die Funktion terminiert nur dann, wenn @racket[stop] irgendwann @racket[#true] zurückgibt.
Mittels der Funktion @racket[emit] wird aus dem aktuellen Zustand jeweils ein Listenelement erzeugt.

Ein Beispiel für die Verwendung von @racket[unfold] sehen wir in der @racket[one-to-n] Funktion. Die
@racket[unfold] Funktion ist in einem präzisen mathematischen Sinn das "Gegenteil" ("Dual") von @racket[foldr], aber
das ist nicht Bestandteil dieser Lehrveranstaltung.


@section{Fold und unfold zusammen, Deforestation}
Häufig tritt der Fall auf, dass eine Berechnung in zwei Teile zerlegt werden kann, wobei der erste Teil der Berechnung
sein Ergebnis in einer Datenstruktur wie einer Liste zurückgibt und der zweite Teil der Berechnung diese Datenstruktur
wieder zerlegt. Häufig können solche Berechnungen als Hintereinanderausführung eines unfolds und eines folds definiert
werden. Beispielsweise können wir die Fakultät einer Zahl n berechnen, indem wir zunächst eine Liste mit den Zahlen
1 bis n erzeugen und diese Zahlen dann alle miteinander multiplizieren.

@#reader scribble/comment-reader
(racketblock
; Nat -> Nat
(check-expect (factorial 5) 120)
(define factorial (compose product-list one-to-n))
)

Allerdings ist es in einem gewissen Sinne eine Verschwendung, erst eine Liste zu konstruieren um sie dann sofort wieder
auseinanderzunehmen. Techniken, um die Erzeugung solcher temporären Zwischenergebnisse zu verhindern, nennt man
oft @italic{Deforestation}. Für folds und unfolds gibt es eine sehr allgemeine Technik, die Zwischenergebnisse zu überspringen
und direkt das Resultat zu erzeugen. Wenn wir uns anschauen, was mit den von @racket[unfold] erzeugten Listenelementen
durch @racket[foldr] gemacht wird, so sehen wir, dass wir die Argumente von @racket[foldr] auch sofort auf die
von @racket[unfold] erzeugten Ergebnisse anwenden können, und zwar so:

@#reader scribble/comment-reader
(racketblock

; [X Y Z] (Y -> Bool) (Y -> Y) (Y -> X) Y (X Z -> Z) Z -> Z
(define (unfold-and-fold stop next emit seed op z)
  (if (stop seed)
      z
      (op (emit seed) 
          (unfold-and-fold stop next emit (next seed) op z))))
  
(define (factorial n) 
  (unfold-and-fold (λ (m) (> m n)) add1 identity 1 * 1))
)


@section{Verallgemeinerung von fold und unfold auf beliebige algebraische Datentypen}

Die Funktionen @racket[foldr] und @racket[unfold] können nicht nur für Listen sondern sogar
für beliebige algebraische Datentypen definiert werden. Auch die Idee der Komposition von 
@racket[unfold] und @racket[foldr] sowie der Optimierung durch Deforestation funktioniert für beliebige algebraische
Datentypen. Die Verallgemeinerungen diese Konzepte haben beeindruckende Namen:
Die @racket[foldr] Funktion ist ein @italic{Catamorphismus}, 
die @racket[unfold] Funktion ist ein @italic{Anamorphismus} und die Komposition
von @racket[unfold] gefolgt von @racket[foldr] Funktion ist ein @italic{Hylomorphismus}.

Wir wollen anhand eines algebraischen Datentyps für Binärbäume die Verallgemeinerung dieser
Konzepte illustrieren.

@#reader scribble/comment-reader
(racketblock

(define-struct branch (left right))
; A (tree-of X) is one of:
; - (make-branch (tree-of X) (tree-of X))
; - X

(define a-tree (make-branch (make-branch 3 5) (make-branch 7 8)))
)

Die @racket[fold] Funktion für Bäume abstrahiert wie bei Listen das Prinzip der strukturellen Rekursion.
Wir verwenden Currying in der Definition von @racket[fold-tree] 
um die Funktionen @racket[sum-tree] und @racket[sum-tree] im "point-free style" definieren zu können.

@#reader scribble/comment-reader
(racketblock

; [X Y] (X X -> X) (Y -> X) -> (tree-of Y) -> X
(define (fold-tree b l)
  (λ (t)
    (match t
      [(branch left right) 
       (b ((fold-tree b l) left) 
          ((fold-tree b l) right))]
      [x (l x)])))

; (tree-of Number) -> Number
(check-expect (sum-tree a-tree) 23)
(define sum-tree (fold-tree + identity))

; tree-to-list as fold of the tree
; [X] (tree-of X) -> (list-of X)
(check-expect (tree-to-list a-tree) (list 3 5 7 8))
(define tree-to-list (fold-tree append list))
)
Die @racket[unfold] Funktion für Bäume funktioniert analog wie die für Listen, mit dem
Unterschied dass für beide Unterbäume ein rekursiver Aufruf nötig ist und es separate
Funktionen @racket[nextl] und @racket[nextr] für den Zustandsupdate für den linken und
rechten Teilbaum gibt.

@#reader scribble/comment-reader
(racketblock
; [X Y] (Y -> Bool) (Y -> Y) (Y -> Y) (Y -> X) Y -> (tree-of X)
(define (unfold-tree stop nextl nextr emit seed)
  (if (stop seed)
      (emit seed)
      (make-branch (unfold-tree stop nextl nextr emit (nextl seed))
                   (unfold-tree stop nextl nextr emit (nextr seed)))))
)
Ein etwas künstliches aber dafür sehr einfaches Beispiel für die Benutzung von @racket[unfold-tree]
ist die Erzeugung eines Baums der die Rekursionsstruktur der Fibonacci-Funktion repräsentiert.
Die Fibonacci-Funktion selber kann dann als Hylomorphismus definiert werden, nämlich als Komposition
von @racket[sum-tree] und @racket[fib-tree].

@#reader scribble/comment-reader
(racketblock
; Nat -> (tree-of Nat)
(check-expect (fib-tree 3) (make-branch (make-branch 1 1) 1))
(define (fib-tree n) 
  (unfold-tree 
    (λ (m) (<= m 1)) 
    sub1 
    (compose sub1 sub1) 
    (λ (_) 1) n))

; Nat -> Nat
(check-expect (fibonacci 6) 13)
(check-expect (fibonacci 7) 21)
(define fibonacci (compose sum-tree fib-tree))
)

Auch für Hylomorphismen auf Bäumen kann "Deforestation" betrieben werden, also die Konstruktion des Bäumes
der direkt wieder zerlegt wird kann vermieden werden indem @racket[unfold] und @racket[fold] gleichzeitig
und synchron das Endergebnis berechnen.

@#reader scribble/comment-reader
(racketblock
; the argument f of type Y -> Z is the composition of the 
; two functions Y->X (from the unfold) and X->Z (from the fold)
; [X Y Z] (Y -> Bool) (Y -> Y) (Y -> Y) (Y -> Z) Y (Z Z -> Z)  -> Z
(define (unfold-and-fold-tree stop ls rs f seed b)
  (if (stop seed)
      (f seed)
      (b (unfold-and-fold-tree stop ls rs f (ls seed) b)
         (unfold-and-fold-tree stop ls rs f (rs seed) b))))

; Nat -> Nat
(check-expect (fibonacci2 6) 13)
(check-expect (fibonacci2 7) 21)
(define (fibonacci2 n) 
  (unfold-and-fold-tree 
    (λ (m) (<= m 1)) 
    sub1 
    (compose sub1 sub1) 
    (λ (_) 1) n +))
)

Es ist nicht schwer zu sehen (durch "equational reasoning"), dass @racket[fibonacci2] äquivalent zu der
klassischen Definition der Fibonacci Funktion ist, also:
@#reader scribble/comment-reader
(racketblock
(define (fibonacci seed)
    (if (<= seed 1)
        1
        (+ (fibonacci (sub1 seed))
           (fibonacci (sub1 (sub1 seed))))))
)

Am Rande wollen wir erwähnen dass es eine weitere Optimierung der Fibonacci-Funktion gibt, die allerdings nichts
mit Deforestation zu tun hat sondern verhindert, dass der Algorithmus Fibonacci-Zahlen mehrfach berechnet und
sogar eine exponentielle Laufzeit hat. Ein viel schnellerer Algorithmus um Fibonacci-Zahlen zu berechnen ist
dieser:

@#reader scribble/comment-reader
(racketblock
(define (fib n)
  (local [(define (f m a b)
    (if (= m 0)
       b
       (f (sub1 m) b (+ a b))))]
  (f n 0 1)))
)
Dieser Algorithmus verwendet eine Technik, die sich "Akkumulator" nennt, auf die wir später noch zu sprechen kommen.

Erwähnen möchten wir an dieser Stelle jedoch, dass sich der oben stehende Algorithmus auch so umformulieren läßt,
dass wir mit Hilfe von @racket[unfold] effizient eine Liste der ersten @racket[n] Fibonacci-Zahlen berechnen.
Der Zustand in dem unten stehenden @racket[unfold] ist ein Tripel (kodiert als Liste der Länge 3, wobei die 
ersten beiden Listenelemente jeweils die beiden vorhergehenden Fibonacci-Zahlen repräsentieren und die
das dritte Listenelement zählt wieviele Listenelemente noch erzeugt werden müssen.)

@#reader scribble/comment-reader
(racketblock
(check-expect (fib2 10) (list 1 1 2 3 5 8 13 21 34 55))
(define (fib2 n) 
   (unfold 
     (lambda (m) (= (third m) n)) 
     (lambda (p) (list (second p) (+ (first p) (second p)) (add1 (third p)))) 
     second 
     (list 0 1 0)))
)                         
