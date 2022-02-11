#lang scribble/manual
@(require scribble/eval)
@(require scribble/core)
@(require "marburg-utils.rkt")
@(require (for-label (except-in lang/htdp-beginner e)))
@(require (for-label (except-in 2htdp/image image?)))
@(require (for-label teachpack/2htdp/abstraction))
@require [scribble-math]
@;(require "math-utilities.rkt")

@(require scribble/bnf)
@(require scriblib/footnote)


@;setup-math

@title[#:version "" #:tag "lang-support-adts"]{Sprachunterstützung für Algebraische Datentypen}

Wie wir in @secref{adts} und @secref{rekursivedatentypen} gesehen haben, sind algebraische Datentypen
essentiell zur Strukturierung von komplexen Daten. Ähnlich dazu wie Signaturen und Datendefinitionen
unterschiedlich gut durch Sprachmittel unterstützt werden können (@secref{lang-support}), gibt es
auch bei algebraischen Datentypen Unterschiede darin, wie gut diese von der Programmiersprache
unterstützt werden.

Wir werden uns vier verschiedene Arten anschauen, wie man algebraische Datentypen ausdrücken kann
und diese im Anschluss bewerten. 


Zu diesem Zweck betrachten wir folgende Datendefinitionen für arithmetische Ausdrücke:

Beispiel:
@#reader scribble/comment-reader
(block
; An Expression is one of:
; - (make-literal Number)
; - (make-addition Expression Expression)
; interp. abstract syntax of arithmetic expressions
)

Als "Interface" für den Datentyp wollen wir die folgende Menge
von Konstruktoren, Destruktoren und Prädikaten betrachten:

@#reader scribble/comment-reader
(block
; Number -> Expression
; constructs a literal exression
(define (make-literal value) ...)

; Expression -> Number
; returns the number of a literal
; throws an error if lit is not a literal
(define (literal-value lit) ...)

; [X] X -> Bool
; returns #true iff x is a literal
(define (literal? x) ...)

; Expression Expression -> Expression
; constructs an addition expression
(define (make-addition lhs rhs) ...)

; [X] X -> Bool
; returns #true iff x is an addition expression
(define (addition? x) ...)

; Expression -> Expression
; returns left hand side of an addition expression
; throws an error if e is not an addition expression
(define (addition-lhs e) ...)

; Expression -> Expression
; returns right hand side of an addition expression
; throws an error if e is not an addition expression
(define (addition-rhs e) ...)
)

Wir werden nun unterschiedliche Arten betrachten, wie wir diesen Datentyp repräsentieren können.

@section{ADTs mit Listen und S-Expressions}
Wie in @secref{sexps} diskutiert, können verschachtelte Listen mit Zahlen, Strings etc. -- also S-Expressions --
als universelle Datenstruktur verwendet werden. Hier ist eine Realisierung der Funktionen von
oben auf Basis von S-Expressions:

@(define eval1 (isl-eval))

@#reader scribble/comment-reader
(racketblock+eval #:eval eval1 #:escape unsyntax
(define (make-literal n)
  (list 'literal n))

(define (literal-value l)
  (if (literal? l)
      (second l)
      (error 'not-a-literal)))

(define (literal? l)
  (and
   (cons? l)
   (symbol? (first l))
   (symbol=? (first l) 'literal)))

(define (make-addition e1 e2)
  (list 'addition e1 e2))

(define (addition? e)
  (and
   (cons? e)
   (symbol? (first e))
   (symbol=? (first e) 'addition)))

(define (addition-lhs e)
  (if (addition? e)
      (second e)
      (error 'not-an-addition)))

(define (addition-rhs e)
  (if (addition? e)
      (third e)
      (error 'not-an-addition)))
)

Auf Basis dieses Interfaces können nun Funktionen definiert werden, wie zum Beispiel ein Interpreter für
die Ausdrücke:
@#reader scribble/comment-reader
(racketblock+eval #:eval eval1 #:escape unsyntax
(define (calc e)
  (cond [(addition? e) (+ (calc (addition-lhs e))
                          (calc (addition-rhs e)))]
        [(literal? e) (literal-value e)]))
)


@interaction[#:eval eval1 
             (make-addition
              (make-addition (make-literal 0) (make-literal 1))
              (make-literal 2))]

@interaction[#:eval eval1 
             (calc (make-addition
                    (make-addition (make-literal 0) (make-literal 1))
                    (make-literal 2)))]


Beachten Sie, dass der Code von @racket[calc] in keiner Weise von der Repräsentation
der Ausdrücke abhängt, sondern lediglich auf Basis des Interfaces definiert wurde.

@section{ADTs mit Strukturdefinitionen}

In dieser Variante verwenden wir Strukturdefinitionen, um das obige Interface zu implementieren.
Wir haben die Namen so gewählt, dass sie mit denen, die durch @racket[define-struct] gebunden werden,
übereinstimmen, deshalb können wir in zwei Zeilen das gesamte Interface implementieren:

@(define eval2 (isl-eval))

@#reader scribble/comment-reader
(racketblock+eval #:eval eval2 #:escape unsyntax
(define-struct literal (value))
(define-struct addition (lhs rhs))
)

Auch in dieser Variante können wir nun wieder Funktionen auf Basis des Interfaces implementieren.
Die @racket[calc] Funktion aus dem vorherigen Abschnitt funktioniert unverändert mit der
@racket[define-struct] Repräsentation von algebraischen Datentypen:
@#reader scribble/comment-reader
(racketblock
(define (calc e)
  (cond [(addition? e) (+ (calc (addition-lhs e))
                          (calc (addition-rhs e)))]
        [(literal? e) (literal-value e)]))
)

Allerdings haben wir durch @racket[define-struct] nun eine neue, komfortablere Möglichkeit, um algebraische
Datentypen zu verarbeiten, nämlich Pattern Matching (@secref{patternmatching}):

@#reader scribble/comment-reader
(racketblock+eval #:eval eval2 #:escape unsyntax
(define (calc e)
  (match e
    [(addition e1 e2) (+ (calc e1) (calc e2))]
    [(literal x) x]))
)

@interaction[#:eval eval2 
             (make-addition
              (make-addition (make-literal 0) (make-literal 1))
              (make-literal 2))]

@interaction[#:eval eval2 
             (calc (make-addition
                    (make-addition (make-literal 0) (make-literal 1))
                    (make-literal 2)))]

@section{ADTs mit @racket[define-type]}

@margin-note{Wechseln Sie zum Nutzen von @racket[define-type] auf die "Intermediate Student Language".}
Eine neue Möglichkeit, um algebraische Datentypen zu repräsentieren, bietet
das @racket[2htdp/abstraction] Teachpack mit dem @racket[define-type] Konstrukt.
Im Unterschied zu @racket[define-struct] bietet @racket[define-type] direkte Unterstützung
für Summentypen, daher kann der Summentyp @racket[Expression] mit seinen unterschiedlichen
Alternativen direkt definiert werden. Ein weiterer wichtiger Unterschied zu @racket[define-struct]
ist, dass zu jedem Feld einer Alternative eine Prädikatsfunktion angegeben wird, die definiert,
welche Werte für dieses Feld zulässig sind. Diese Prädikatsfunktionen sind eine
Form von dynamisch überprüften Contracts (siehe @secref{contracts}).

@(define eval3 (isl-eval))

@#reader scribble/comment-reader
(racketblock+eval #:eval eval3 #:escape unsyntax
(define-type Expression
  (literal (value number?))
  (addition (left Expression?) (right Expression?)))
)

Analog zu @racket[define-struct] (@secref{definestruct})
definiert @racket[define-type] für jede Alternative Konstruktor-, Selektor- und Prädikatsfunktionen,
so dass wir Werte dieses Typs auf die gleiche Weise definieren können:

@interaction[#:eval eval3 
             (make-addition
              (make-addition (make-literal 0) (make-literal 1))
              (make-literal 2))]

Allerdings wird bei Aufruf der Konstruktoren überprüft, ob die Felder die dazugehörige Prädikatsfunktion
erfüllen. Der folgende Aufruf, der bei der @racket[define-struct] Variante ausgeführt werden könnte,
schlägt nun zur Laufzeit fehl:

@interaction[#:eval eval3 
             (make-addition 0 1)]


Passend zu @racket[define-type] gibt es auch eine Erweiterung von @racket[match], nämlich @racket[type-case].
Mit Hilfe von @racket[type-case] kann die @racket[calc] Funktion nun wie folgt definiert werden:

@#reader scribble/comment-reader
(racketblock+eval #:eval eval3 #:escape unsyntax
(define (calc e)
  (type-case Expression e
    [literal (value) value]
    [addition (e1 e2) (+ (calc e1) (calc e2))]))
)

@interaction[#:eval eval3 
             (calc (make-addition
                    (make-addition (make-literal 0) (make-literal 1))
                    (make-literal 2)))]

Der wichtigste Unterschied zwischen @racket[match] und @racket[type-case] ist, dass der Typ @racket[Expression],
auf dem wir eine Fallunterscheidung machen möchten, explizit mit angegeben wird. Dies ermöglicht es
der DrRacket Umgebung, bereits @emph{vor} der Programmausführung zu überprüfen, ob alle Fälle abgedeckt wurden.
Beispielsweise wird die folgende Definition bereits vor der Ausführung mit einer entsprechenden Fehlermeldung
zurückgewiesen.

@interaction[#:eval eval3 
(define (calc2 e)
  (type-case Expression e
    [addition (e1 e2) (- (calc2 e1) (calc2 e2))]))]

Der Preis für diese Vollständigkeitsüberprüfung ist, dass @racket[type-case] nur ein sehr eingeschränktes
Pattern Matching erlaubt. Beispielsweise ist es nicht erlaubt, Literale, verschachtelte Pattern, oder
nicht-lineares Pattern Matching zu verwenden. Im Allgemeinen haben die Klauseln von @racket[type-case]
stets die Form @racket[((variant (name-1 ... name-n) body-expression))], wobei in @racket[body-expression]
die Namen @racket[name-1] bis @racket[name-n] verwendet werden können.

@section{Ausblick: ADTs mit Zahlen}

Ist es auch möglich, algebraische Datentypen zu repräsentieren, wenn man weder Listen/S-expressions
noch @racket[define-struct] oder @racket[define-type] zur Verfügung hat, sondern der einzige
eingebaute Datentyp (natürliche) Zahlen sind? Diese Frage ist von großer Bedeutung in der theoretischen
Informatik, denn dort möchte man häufig möglichst minimale und einfache Rechenmodelle definieren,
die dennoch prinzipiell mächtig genug wären, um beliebige Programme darin auszudrücken.
Es spielt hierbei in der Regel keine Rolle, ob diese Techniken praxistauglich oder effizient sind.
Wichtig ist nur, ob eine Kodierung prinzipiell möglich ist. Der Grund, wieso die Rechenmodelle
möglichst minimal sein sollen, ist der, dass dann leichter wichtige Eigenschaften dieser
Rechenmodelle analysiert und bewiesen werden können.

Beispielsweise ist es in vielen Rechenmodellen wichtig, ob es eine Art universelles Programm
gibt, das die Repräsentation eines Programms als Eingabe bekommt und dann dieses Programm
quasi simuliert. In der BSL wäre dies beispielsweise ein Programm, welches eine Repräsentation
eines BSL Programms als Eingabe bekommt und dann die Ausführung dieses Programms simuliert.
Ein solches Programm nennt man auch @emph{Selbstinterpreter}. In der theoretischen Informatik
kommen solche Konstruktionen häufig vor, beispielsweise bei der sogenannten Universellen
Turing-Maschine, im Normalformtheorem in der Theorie rekursiver Funktionen, beim sogenannten "Halteproblem",
und im Beweis der Unvollständigkeitstheoreme von Gödel. Als Anerkennung der Beiträge von
Kurt Gödel werden solche Repräsentationstechniken in der Berechenbarkeitstheorie auch
"Gödelisierung" genannt. All diese Rechenmodelle haben gemein, dass Zahlen quasi der einzige
eingebaute Datentyp sind.

Bevor wir algebraische Datentypen durch Zahlen repräsentieren, überlegen wir uns erstmal einen
Spezialfall: Wie können wir ein Paar von zwei Zahlen, beispielsweise 17 und 12, durch eine einzelne Zahl
repräsentieren? Eine Idee wäre, die Zahlen in Dezimalrepräsentation hintereinander zu schreiben: 1712.
Aber woher wissen wir dann, dass 17 und 12 gemeint waren und nicht etwa 1 und 712 oder 171 und 2?
Eine Lösung hierzu wäre, als Trennzeichen bestimmte Zahlenfolgen zu wählen, die in den Zahlen selbst
nicht vorkommen dürfen. Wir werden eine andere Technik wählen, die von Kurt Gödel vorgeschlagen wurde
und die auf der Eindeutigkeit der Primfaktorzerlegung beruht.

Die Eindeutigkeit der Primfaktorzerlegung sagt aus, dass jede Zahl eindeutig in ihre Primfaktoren
zerlegt werden kann. Wenn die Primzahlen durch @${p_1,p_2,\ldots} bezeichnet werden,
so bedeutet dies, dass es für jede natürliche Zahl @${n} eine Zahl @${k} sowie
Zahlen @${n_1,\ldots,n_k} gibt, so dass
@${n = p_1^{n_1} \cdot p_2^{n_2} \cdot \ldots  \cdot p_k^{n_k} }. Beispielsweise kann
die Zahl 18 zerlegt werden in @${18 = 2^1 \cdot 3^2}.

Aufgrund der Eindeutigkeit der Primfaktoren könnten wir beispielsweise Paare mit Hilfe der
ersten beidem Primzahlen, 2 und 3, repräsentieren. Beispielsweise könnten die Zahlen 17 und 12
von oben durch die Zahl @${2^{17} \cdot 3^{12} = 69657034752} repräsentiert werden. Um die beiden Zahlen
wieder zu extrahieren, berechnen wir, wie häufig sich die Zahl ohne Rest durch 2 bzw. 3 teilen lässt.

Diese Idee können wir durch folgendes Programm ausdrücken:
@(define eval4 (isl-eval))

@#reader scribble/comment-reader
(racketblock+eval #:eval eval4 
; Nat Nat -> Nat
; computes how often n can be divided by m
(define (how-often-dividable-by n m)
  (if (zero? (modulo n m))
      (add1 (how-often-dividable-by (/ n m) m))
      0))
)

@interaction[#:eval eval4 
(how-often-dividable-by 69657034752 2)
(how-often-dividable-by 69657034752 3)
]

Offensichtlich können durch Nutzen von mehr Primzahlen mit der gleichen Technik
beliebig lange Listen von (natürlichen) Zahlen durch eine einzelne Zahl repräsentiert werden.
Verschachtelte Listen, also quasi S-Expressions, können durch Verschachtelung der gleichen
Kodierungstechnik repräsentiert werden. Wollen wir beispielsweise ein Paar von zwei Paaren
repräsentieren und @${n_1} ist die Kodierung des ersten Paars und @${n_2}
die Kodierung des zweiten Paars, so kann das Paar der beiden Paare durch @${2^{n_1} \cdot 3^{n_2}}
repräsentiert werden.

Bleibt noch die Frage, wie wir Summentypen repräsentieren. Hierzu können wir einfach für jede Variante
 disjunkte Mengen von Primzahlen nehmen.

Auf Basis dieser Idee können wir nun das Interface für den Expression Datentyp implementieren:

@#reader scribble/comment-reader
(racketblock+eval #:eval eval4 
(define prime-1 2)
(define prime-2 3)
(define prime-3 5)

(define (make-literal value) (expt prime-1 value))
(define (literal-value l) (how-often-dividable-by l prime-1))

(define (make-addition e-1 e-2)
  (* (expt prime-2 e-1)
     (expt prime-3 e-2)))

(define (addition-lhs e)
  (how-often-dividable-by e prime-2))

(define (addition-rhs e)
  (how-often-dividable-by e prime-3))

(define (addition? e)
  (zero? (modulo e prime-2)))

(define (literal? e)
  (or (= e 1) (zero? (modulo e prime-1))))
)

Diese Kodierung ergibt sehr schnell sehr große Zahlen, daher ist sie nicht für praktische
Zwecke brauchbar, aber sie funktioniert wie gewünscht:
@interaction[#:eval eval4 
(define e-1 (make-addition (make-addition (make-literal 0) (make-literal 1)) (make-literal 2)))
e-1
(literal-value (addition-lhs (addition-lhs e-1)))
(literal-value (addition-rhs (addition-lhs e-1)))
(literal-value (addition-rhs e-1))
]

Auch Funktionen wie die @racket[calc] Funktionen funktionieren weiterhin auch auf Basis
dieser ADT Repräsentation:

@#reader scribble/comment-reader
(racketblock+eval #:eval eval4 #:escape unsyntax
(define (calc e)
  (cond [(addition? e) (+ (calc (addition-lhs e))
                          (calc (addition-rhs e)))]
        [(literal? e) (literal-value e)]))
)

@interaction[#:eval eval4 
(calc e-1)]


@section[#:tag "diskadts"]{Diskussion}

Die unterschiedlichen Möglichkeiten, algebraische Datentypen (ADTs) zu unterstützen, unterscheiden sich
in wichtigen Eigenschaften. Im folgenden bezeichnen wir die Variante ADTs mit Listen und S-Expressions als a),
ADTs mit Strukturdefinitionen als b), ADTs mit @racket[define-type] als c), und ADTs mit Zahlen als d).

@itemlist[
@item{Boilerplate: Gibt es in der Art, wie ADTs kodiert werden, Verstöße gegen das DRY-Prinzip?
 Solchen Code nennt man @italic{boilerplate code}. Bei a) und d) haben wir solchen boilerplate code,
 denn die Konstruktoren, Destruktoren und Prädikate müssen manuell auf eine mechanische Art und Weise implementiert werden.}
@item{Unterscheidbarkeit der Alternativen: Können die Alternativen bei Summentypen stets unterschieden werden?
 Bei b) und c) bekommen wir durch die Sprache eindeutige Prädikate geliefert, mit denen wir die Alternativen
 unterscheiden können. Bei a) und d) muss der Programmierer diszipliniert genug arbeiten um diese Eigenschaft
 sicherzustellen. }
@item{Erweiterbarkeit der Summen: Können Summen leicht um weitere Alternativen erweitert werden? Ein Beispiel wäre,
 dass der Typ für arithmetische Ausdrücke von oben noch durch eine Alternative zur Multiplikation von zwei
 arithmetischen Ausdrücken erweitert werden soll. Mit "erweitert" ist gemeint, dass hierzu keine Modifiktion von
 bestehendem Code erforderlich ist. Bei den Varianten a), b) und d) können wir leicht weitere Alternativen
 zu der jeweiligen Repräsentation des ADTs hinzufügen, beispielsweise in der Variante b) durch Definition einer
 weiteren Struktur. Allerdings werden bestehende Programme, die solche ADTs als Eingabe bekommen, in der Regel
 nicht korrekt auf diesen erweiterten ADTs arbeiten, denn sie berücksichtigen den hinzugekommenen Fall nicht.
 Es ist auch nicht ohne weiteres möglich, ohne Modifikation dieser Programme die Funktionalität für den
 hinzugekommenen Fall hinzuzufügen. @note{Dieses und ähnliche Erweiterungsprobleme werden
   unter dem Namen "Expression Problem" in vielen wissenschaftlichen Artikeln diskutiert.}
  Die Variante c) hingegen ist eine "geschlossene" Kodierung eines ADTs:
 Alle Alternativen werden an einer Stelle definiert, daher ist eine Erweiterung um weitere Alternativen
 ohne Modifikation von Code nicht ohne weiteres möglich. } 
@item{Erweiterbarkeit der Produkte: Können Produkte leicht um weitere Komponenten erweitert werden? Ein Beispiel wäre,
 dass die Alternative für Literale noch um eine weitere Zahl erweitert werden soll, welche aussagt, dass die
 Zahl nur eine Annäherung an die genaue Zahl ist und die zweite Zahl gibt an, wie präzise die Annäherung ist.
 In der Variante a) können wir Produkte leicht dadurch erweitern, dass wir die Listen länger machen. Auf eine
 ähnliche Weise können wir auch in der Variante d) die Produkte erweitern. In den Varianten b) und c) hingegen
 ist die Anzahl der Komponenten (die "Arität") der Konstruktoren in den Struktur- bzw. Typdefinitionen festgelegt
 und diese läßt sich nicht ohne Modifikation des bestehenden Codes erweitern.}
@item{Typsicherheit: Ist sichergestellt, dass die Datendefinition vom Programm eingehalten wird? Bei den Varianten
 a) und d) gibt es keinerlei Unterstützung für Typsicherheit; falls Daten konstruiert werden, die gegen die
 Datendefinition verstossen, so wird dies weder vor der Programmausführung noch während der Konstruktion sondern
 erst möglicherweise im weiteren Verlauf der Programmausführung festgestellt. Bei b) wird zumindest sichergestellt,
 dass den Konstruktoren die korrekte Anzahl von Parametern übergeben wird (Arität). Diese Prüfung findet, je
 nach Sprachvariante, schon vor der Programmausführung (BSL) bzw. während der Ausführung des Konstruktors (ISL) statt.
 Bei der Variante c) hingegen wird eine Variante von Contracts verwendet (siehe @secref{contracts}), um
 während der Konstruktion der Daten zu überprüfen, ob die Komponenten zur Datendefinition passen.} 
@item{Vollständigkeit von Fallunterscheidungen: Wird sichergestellt, dass Fallunterscheidungen bei
 Summentypen alle Möglichkeiten berücksichtigen? Die einzige Variante, die die Vollständigkeit vor der Programmausführung
 überprüfen kann, ist c). Dies ist ein wichtiger Vorteil, der daraus resultiert, dass ADTs in dieser
 Variante "geschlossen" sind.} 
@item{Zeit- und Platzeffizienz: Ist die Kodierung von ADTs effizient bezüglich des Platzbedarfs zur Repräsentation
 der Daten im Speicher sowie bezüglich des Zeitbedarfs zur Konstruktion und Destruktion (Analyse) von ADTs?
 Effizienz ist kein wichtiges Thema in dieser Lehrveranstaltung, aber die Variante d) fällt aus diesen
 Grund für praktische Anwendungen aus.} 
@item{Datentyp-generische Programme: Ist es möglich, Programme zu schreiben, die mit jedem algebraischen Datentyp
 funktionieren, wie beispielsweise eine Funktion, die zu einem Wert, der einen beliebigen algebraischen Datentyp hat,
 die Tiefe des Baums berechnet? Bei universellen Datenformaten wie S-Expressions ist dies leicht, während es nicht
 offensichtlich ist, wie man dies bei mittels @racket[define-struct] oder @racket[define-type] definierten ADTs
 hinbekommen könnte. Datentyp-generische Programmierung, insbesondere für statisch getypte Sprachen, ist ein sehr
 aktiver Zweig in der Programmiersprachenforschung.}
                                                                                               
]

@section{Ausblick: ADTs mit Dictionaries}

Eine wichtige Datenstruktur, die es in fast allen Programmiersprachen gibt, sind @emph{dictionaries}, manchmal
auch bezeichnet als @emph{associative array}, @emph{map}, oder @emph{hash table}. Dictionaries repräsentieren
partielle Funktionen mit einer endlichen Definitionsmenge (den sog. @emph{keys}); jedem key wird also maximal ein Wert
zugeordnet. Eine gängige Notation für Dictionaries ist JSON, die JavaScript Object Notation. Eine Person mit
Namen und Vornamen könnte in JSON beispielsweise so aufgeschrieben werden:

@verbatim{
{ name: 'Ostermann', vorname: 'Klaus'}
}
In diesem Fall sind @tt{name} und @tt{vorname} die Keys und @tt{'Ostermann'} und @tt{'Klaus'} die jeweils
zugeordneten Werte. Dictionaries sind wie Listen, bei denen die Elemente nicht durch ihre Position in der Liste
sondern durch einen Key adressiert werden. Da Dictionaries genau wie Listen verschachtelt werden können, können
Dictionaries ähnlich wie S-Expressions als universelle Datenstruktur verwendet werden.

Beispielsweise könnten die arithmetischen Ausdrücke von oben auch durch Dictionaries repräsentiert werden:

@verbatim{
{ kind: 'add', lhs: { kind: 'lit', val: 7}, rhs: { kind: 'lit', val: 12}};
}

Dictionaries spielen in einer Reihe von Programmiersprachen eine zentrale Rolle und werden als universelle
Datenstruktur im Sinne von S-Expressions verwendet, beispielsweise in JavaScript, AWK, Lua, Python, Perl und Ruby.
Unter dem Schlagwort "NoSQL" gibt es auch eine Reihe von Datenbanktechnologien, in denen Dictionaries eine
zentrale Rolle spielen.

Ein Interpreter für arithmetische Ausdrücke, die als Dictionaries repräsentiert werden, kann beispielsweise
in JavaScript wie folgt aussehen:

@verbatim{
  var calc = function (e) {
    switch (e.kind) {
      case 'lit': return e.val;
      case 'add': return calc(e.lhs)+calc(e.rhs);
    }
  }
  calc({ kind: 'add', lhs: { kind: 'lit', val: 7}, rhs: { kind: 'lit', val: 12}});
}

Bezüglich der Diskussion in @secref{diskadts} verhalten sich dictionary-repräsentierte ADTs ähnlich wie
S-Expressions.
@note{Einige Sprachen, wie beispielsweise Python, verwenden statt der Dot-Notation
 die Notation @tt{e['lhs']}.}
Ein wichtiger Vorteil gegenüber S-Expressions ist, dass der Zugriff auf die Komponenten
keinen "boilerplate" Code erfordert sondern mit Hilfe der "Dot-Notation" (wie @tt{e.lhs}) effizient
ausgedrückt werden kann.
