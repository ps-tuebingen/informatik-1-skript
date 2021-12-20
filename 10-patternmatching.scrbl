#lang scribble/manual
@(require scribble/eval)
@(require scribble/core)
@(require "marburg-utils.rkt")
@(require (for-label (except-in lang/htdp-beginner e)))
@(require (for-label (except-in 2htdp/image image?)))
@(require (for-label teachpack/2htdp/abstraction))
@require[scribble-math]

@;(require "math-utilities.rkt")

@(require scribble/bnf)

@;setup-math

@title[#:version "" #:tag "patternmatching"]{Pattern Matching}


Viele Funktionen konsumieren Daten, die einen Summentyp oder einen algebraischen Datentyp (also eine Mischung aus
Summen- und Produkttypen (@secref{adts})) mit einer Summe "ganz oben" haben.

Häufig (und gemäß unseres Entwurfsrezepts) sehen solche Funktionen so aus, dass zunächst einmal unterschieden
wird, welche Alternative gerade vorliegt, und dann wird (ggf. in Hilfsfunktionen) auf die Komponenten
des in der Alternative vorliegenden Produkttypen zugegriffen.

Beispielsweise haben Funktionen, die Listen verarbeiten, in der Regel diese Struktur:
@racketblock[
(define (f l)
  (cond [(cons? l) (... (first l) ... (f (rest l))...)]
        [(empty? l) ...]))]

Mit @italic{Pattern Matching} können solche Funktionen mit deutlich reduziertem Aufwand definiert werden.
Pattern Matching hat zwei Facetten: 1) Es definiert implizit eine Bedingung, analog zu den
Bedingungen in den @racket[cond] Klauseln oben. 2) Es definiert Namen, die statt der Projektionen
(@racket[(first l)] und @racket[(rest l)] im Beispiel) verwendet werden können.

Pattern Matching kann auf allen Arten von Summentypen verwendet werden. Insbesondere ist es nicht
auf rekursive Typen wie Listen oder Bäume beschränkt.

@section{Pattern Matching am Beispiel} 
Um Unterstützung für Pattern Matching zu bekommen, verwenden wir das Teachpack @racket[2htdp/abstraction].
Fügen Sie an Anfang ihres Programms daher diese Anweisung ein:

@racketblock[(require 2htdp/abstraction)]

Das folgende Beispiel zeigt, wie das @racket[match] Konstrukt verwendet werden kann.

@; I use a new instance of isl-eval+ here because for an unknown reason stdeval produces a horrible error message on the (f 42) example
@(define ex-evaluator (isl-eval+))

@racketblock+eval[#:eval ex-evaluator #:escape unsyntax
(define (f x)
    (match x
      [7 8]
      ["hey" "joe"]
      [(list 1 y 3) y]
      [(cons a (list 5 6)) (add1 a)]
      [(posn 5 5) 42]
      [(posn y y) y]
      [(posn y z) (+ y z)]
      [(cons (posn 1 z) y) z]
      [(? cons?) "nicht-leere Liste"]))]               

Hier sind einige Beispiele, die das Verhalten des @racket[match] Konstrukts illustrieren.

             
@interaction[#:eval ex-evaluator
(f 7)
(f "hey")
(f (list 1 2 3))
(f (list 4 5 6))
(f (make-posn 5 5))
(f (make-posn 6 6))
(f (make-posn 5 6))
(f (list (make-posn 1 6) 7))
(f (list 99 88))
(f 42)]


Jede Klausel in einem @racket[match] Ausdruck beginnt mit einem Pattern. Ein Pattern kann ein Literal sein, wie
in den ersten beiden Klauseln (@racket[7] und @racket["hey"]). In diesem Fall ist das Pattern lediglich eine
implizite Bedingung: Wenn der Wert, der gematcht wird (im Beispiel @racket[x]), gleich dem Literal ist, dann ist der
Wert des Gesamtausdrucks der der rechten Seite der Klausel (analog zu @racket[cond]). 

Interessant wird Pattern Matching dadurch, dass auch auf Listen und andere algebraische Datentypen "gematcht" werden kann.
In den Pattern dürfen Namen vorkommen (wie das @racket[y] in @racket[(list 1 y 3)] ; diese Variablen sind im Unterschied zu Strukturnamen oder Literalen keine 
Bedingungen, sondern sie dienen zur Bindung der Namen an den entsprechenden Teil der Struktur.

Allerdings können Namen zur Bedingung werden, wenn sie mehrfach im Pattern vorkommen. Im Beispiel oben ist dies der Fall
im Pattern @racket[(posn y y)]. Dieses Pattern matcht nur dann, wenn @racket[x] eine @racket[posn] ist und beide
Komponenten den gleichen Wert haben.

Falls mehrere Pattern gleichzeitig matchen, so "gewinnt" stets das erste Pattern, welches passt (analog dazu wie auch bei @racket[cond] stets
die erste Klausel, deren Kondition @racket[true] ergibt, "gewinnt"). Daher ergibt beispielsweise @racket[(f (make-posn 5 5))]
im Beispiel das Ergebnis @racket[42] und nicht etwa @racket[5] oder @racket[10].

Das vorletzte Pattern, @racket[(cons (posn 1 z) y)], illustriert, dass Patterns beliebig tief verschachtelt werden können.

Im letzten Pattern, @racket[(? list?)], sehen wir, dass auch Prädikatsfunktionen von Listen und Strukturen verwendet
werden können, um zu überprüfen, was für eine Art von Wert wir gerade haben. Diese Art von Pattern bietet sich an, wenn
man nur wissen möchte, ob der Wert, auf dem wir matchen, zum Beispiel eine Liste oder eine @racket[posn] ist.

Pattern Matching ist in vielen Fällen eine sinnvolle Alternative zum Einsatz von @racket[cond] Ausdrücken.
Beispielsweise können wir mittels Pattern Matching die Funktion

@racketblock[
(define (person-has-ancestor p a)
  (cond [(person? p)
         (or
          (string=? (person-name p) a)
          (person-has-ancestor (person-father p) a)
          (person-has-ancestor (person-mother p) a))]
        [else #false]))]

aus @secref{rekursivedatentypen} umschreiben zu:

@racketblock[
(define (person-has-ancestor p a)
  (match p 
    [(person name father mother)
         (or
          (string=? name a)
          (person-has-ancestor father a)
          (person-has-ancestor mother a))]
    [else #false]))]



@section{Pattern Matching allgemein}
Wir betrachten die Syntax, Bedeutung und Reduktion von Pattern Matching.

@subsection{Syntax von Pattern Matching}
Um die syntaktische Struktur der @racket[match] Ausdrücke zu definieren, erweitern wir die Grammatik für
Ausdrücke aus @secref{bsl-grammar} wie folgt:

@; The ? form actually allows arbitrary functions, but I'm restricting it to structure predicate functions to keep it first-order.
@BNF[
 (list @nonterm{e}
       @BNF-etc
       @BNF-seq[@litchar{(} @litchar{match} @nonterm{e} @kleeneplus[@BNF-group[@litchar{[}@nonterm{pattern} @nonterm{e} @litchar{]}]] @litchar{)}])
 (list @nonterm{pattern} 
             @nonterm{literal-constant}
             @nonterm{name}
             @BNF-seq[@litchar{(} @nonterm{name} @kleenestar[@nonterm{pattern}] @litchar{)}]
             @BNF-seq[@litchar{(} @litchar{?} @(make-element #f (list @nonterm{name} @litchar{?})) @litchar{)}])
  (list @nonterm{literal-constant}
         @nonterm{number}
         @nonterm{boolean}
         @nonterm{string})]


@subsection{Bedeutung von Pattern Matching}
Falls man einen Ausdruck der Form @racket[(match v [p-1 e-1] ... [p-n e-n])] hat, so kann 
man Pattern Matching verstehen als die Aufgabe, ein minimales @racket[i] zu finden, so dass
@racket[p-i] auf @racket[v] "matcht". Aber was bedeutet das genau?

Wir können Matching als eine Funktion definieren, die ein Pattern und einen Wert als Eingabe
erhält und entweder "no match" oder eine @italic{Substitution} zurückgibt.
Eine Substitution ist ein Mapping @${ \left[ x_1 := v_1, \ldots, x_n := v_n \right] } von Namen auf Werte.
Eine Substitution kann auf einen Ausdruck angewendet werden. Dies bedeutet, dass alle Namen in dem
Ausdruck, die in der Substitution auf einen Wert abgebildet werden, durch diesen Wert ersetzt werden.
Wenn @${e} ein Ausdruck ist und @${\sigma} eine Substitution, so schreiben wir @${e \sigma}
für die Anwendung von @${\sigma} auf @${e}. Beispielsweise für @${\sigma = \left[ x := 1, y := 2 \right] }
und @${e = \mathtt{(+\ x\ y\ z)}}, ist

@$${
  e \sigma = \mathtt{(+\ x\ y\ z)}\left[ x := 1, y := 2 \right] = \mathtt{(+\ 1\ 2\ z)}
}

Das Matching eines Werts auf ein Pattern ist nun wie folgt definiert:

@$${
\begin{aligned} 
\mathit{match}(v,v) & = \left[ \right] \\
\mathit{match}( \mathit{(name}\ p_1 \ldots p_n\mathtt{)}, \mathtt{<}\mathtt{make}\mathit{-name}\ v_1 \ldots v_n\mathtt{>}) & = \mathit{match}(p_1,v_1) \oplus \ldots \oplus \mathit{match}(p_n,v_n) \\
\mathit{match}( \mathtt{(}\mathtt{cons}\ p_1\ p_2\mathtt{)},\mathtt{<}\mathtt{cons}\ v_1\ v_2\mathtt{>}) & = \mathit{match}(p_1,v_1) \oplus \mathit{match}(p_2,v_2) \\
\mathit{match}(\mathtt{(}?\ \mathtt{name}?\mathtt{)}, <\mathtt{make}\mathit{-name} \ldots > \mathtt{)} & = \left[ \right] \\
\mathit{match}(x, v) & = \left[ x := v \right]  \\
\mathit{match}(\ldots, \ldots) & = \mathit{no\ match\ } \text{in allen anderen Fällen}  \\
\end{aligned}
}





Hierbei ist @${\oplus} ein Operator, der Substitutionen kombiniert. Das Ergebnis von @${\sigma_1 \oplus \sigma_2} ist
"no match", falls @${\sigma_1} oder  @${\sigma_2} "no match" sind oder  @${\sigma_1} und  @${\sigma_2} beide ein Mapping für den gleichen Namen definieren  aber
diese auf unterschiedliche Werte abgebildet werden.

@$${
\begin{aligned}            
    \left[ x_1 := v_1, \ldots, x_k := v_k \right] \oplus \left[ x_{k+1} := v_{k+1}, \ldots, x_n := v_n \right]  =
    \left[ x_1 := v_1, \ldots, x_n := v_n \right] \\ \ \ \text{ falls für alle } i,j \text{ gilt:} x_i = x_j \Rightarrow v_i = v_j.
\end{aligned}    
}

Beispiele:
@$${
\begin{aligned}
\mathit{match}(\mathtt{(posn\ x\ y)},\mathtt{<make-posn\ 3\ 4>}) = \left[ x := 3, y := 4 \right] \\
\end{aligned}
}
@$${
\begin{aligned}
\mathit{match}(\mathtt{(posn\ 3\ y)},\mathtt{<make-posn\ 3\ 4>}) = \left[y := 4 \right] \\
\end{aligned}
}
@$${
\begin{aligned}
\mathit{match}(\mathtt{x},\mathtt{<make-posn\ 3\ 4>}) = \left[x := \mathtt{<make-posn\ 3\ 4>} \right] \\
\end{aligned}
}

@$${
\begin{aligned}
 \mathit{match}(\mathtt{(cons\ (posn\ x\ 3)\ y)},\mathtt{<cons\ <make-posn\ 3\ 3>\ empty>}) = \left[x := \mathtt{3}, y := empty \right] \\
\end{aligned}
}

@$${
\begin{aligned}
 \mathit{match}(\mathtt{(cons\ (posn\ x\ x)\ y)},\mathtt{<cons\ <make-posn\ 3\ 4>\ empty>}) = \mathit{no\ match\ } \\
\end{aligned}
}

Beim Vergleich auf unterschiedliche Werte durch  @${\oplus} werden tatsächlich jedoch nicht die Werte direkt verglichen sondern 
die Funktion @racket[equal?] zum Vergleich verwendet. Im derzeitigen Sprachlevel ist dieser Unterschied nicht relevant, doch wenn 
wir später Funktionen als Werte betrachten, so kann dies zu überraschenden Ergebnissen führen, da eigentlich gleiche Funktionen 
bezüglich der @racket[equal?] Funktion nicht unbedingt gleich sind. Da das Vergleichen von Funktionen eine komplizierte Angelegenheit
ist, wird in vielen Sprachen mit Pattern Matching nur sogenanntes "lineares" Pattern Matching unterstützt. Dies bedeutet, dass Pattern Variablen nur einmal im Pattern vorkommen dürfen;
Patterns wie @racket[(posn x x)] wären dann nicht erlaubt.

@subsection{Reduktion von Pattern Matching}

Wir erweitern die Grammatik des Auswertungskontextes so, dass der Ausdruck, auf dem gematcht wird, zu einem Wert
reduziert werden kann. Alle anderen Unterausdrücke des @racket[match] Ausdrucks werden nicht ausgewertet.

@BNF[(list @nonterm{E} 
      @BNF-etc
      @BNF-seq[@litchar{(} @litchar{match} @nonterm{E} @kleeneplus[@BNF-group[@litchar{[}@nonterm{pattern} @nonterm{e} @litchar{]}]] @litchar{)}])]


In der Reduktionsrelation verwenden wir nun die @${\mathit{match}} Funktion von oben, um zu entscheiden,
ob ein Pattern matcht und um ggf. die durch das Pattern gebundenen Namen in dem dazugehörigen Ausdruck
durch die entsprechenden Werte zu ersetzen.

@elem[#:style inbox-style]{
@italic{(MATCH-YES): }
Falls in einem Ausdruck @racket[(match v [p-1 e-1] ... [p-n e-n])] gilt:
match(@racket[p-1],@racket[v]) = @${\sigma} und  @racket[e-1] @${\sigma} = @racket[e],
dann @racket[(match v [p-1 e-1] ... [p-n e-n])] @step @racket[e].}

@elem[#:style inbox-style]{
@italic{(MATCH-NO): }Falls hingegen match(@racket[p-1],@racket[v]) = "no match", so gilt:
@racket[(match v [p-1 e-1] ... [p-n e-n])] @step @racket[(match v [p-2 e-2] ... [p-n e-n])].}

Sind keine Patterns zum Matchen mehr übrig, so wird die Auswertung mit einem Laufzeitfehler abgebrochen,
wie oben an dem @racket[(f 42)] Beispiel illustriert. Dies wird in der Reduktionssemantik
dadurch modelliert, dass die Auswertung "steckenbleibt", also nicht mehr weiter reduziert werden
kann obwohl der Ausdruck noch kein Wert ist.

@subsection{Pattern Matching Fallstricke}

Es gibt einige Besonderheiten bgzl. des Verhaltens von Pattern Matching bei der Verwendung von
Literalen, die möglicherweise zu Verwirrungen führen können.

Hier einige Beispiele:

@interaction[#:eval ex-evaluator
(match true [false false] [else 42])
(match true [#false false] [else 42])
(match (list 1 2 3) [empty empty] [else 42])
(match (list 1 2 3) [(list) empty] [else 42])
]

Die ersten beiden Beispiele illustrieren, dass es wichtig ist, die boolschen Konstanten als @racket[#true]
und @racket[#false] zu schreiben, wenn sie in Pattern vorkommen. Wenn man stattdessen @racket[false]
oder @racket[true] schreibt, so werden diese als Namen interpretiert, die durch das Pattern Matching gebunden werden.

Die letzten beiden Beispiele zeigen, dass das gleiche Phänomen bei Listenliteralen auftritt. Schreiben Sie
@racket[(list)] und nicht @racket[empty] wenn Sie auf die leere Liste matchen wollen.
