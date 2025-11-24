#lang scribble/manual
@(require scribble/eval)
@(require "marburg-utils.rkt")
@(require (for-label lang/htdp-beginner-abbr))
@(require (for-label (except-in 2htdp/image image?)))
@(require (for-label 2htdp/universe))
@(require (for-label xml))
@(require scriblib/footnote)

@title[#:version ""]{Quote und Unquote}

Listen spielen in funktionalen Sprachen eine wichtige Rolle, insbesondere
in der Familie von Sprachen, die von LISP abstammen (wie Racket und BSL).

Wenn man viel mit Listen arbeitet, ist es wichtig, eine effiziente Notation
dafür zu haben. Sie haben bereits die @racket[list] Funktion kennengelernt,
mit der man einfache Listen kompakt notieren kann.

Allerdings gibt es in BSL/ISL (und vielen anderen Sprachen) einen noch viel mächtigeren
Mechanismus, nämlich @racket[quote] und @racket[unquote]. Diesen Mechanismus
gibt es seit den 1950er Jahren in LISP, und noch heute eifern beispielsweise
Template-Sprachen wie Java Server Pages oder PHP diesem Vorbild nach.

Um mit @racket[quote] und @racket[unquote] zu arbeiten, ändern Sie bitte den
Sprachlevel auf "Anfänger mit Listenabkürzungen" beziehungsweise "Beginning
Student with List Abbreviations".


@section{Quote}
Das @racket[quote]-Konstrukt dient als kompakte Notation für große und verschachtelte Listen. 
Beispielsweise können wir mit der Notation @tt{(quote (1 2 3))} die Liste @racket[(cons 1 (cons 2 (cons 3 empty)))] erzeugen.
Dies ist noch nicht besonders eindrucksvoll, denn der Effekt ist der gleiche wie

@ex[(list 1 2 3)]

Zunächst mal gibt es eine Abkürzung für das Schlüsselwort @racket[quote],
nämlich das Hochkomma, '.

@ex['(1 2 3)]

@ex['("a" "b" "c")]

@ex['(5 "xx")]

Bis jetzt sieht @racket[quote] damit wie eine minimale Verbesserung der @racket[list]
Funktion aus. Dies ändert sich, wenn wir damit verschachtelte Listen, also Bäume, erzeugen.

@ex['(("a" 1) ("b" 2) ("c" 3))]

Wir können also mit @racket[quote] auch sehr einfach verschachtelte Listen erzeugen,
und zwar mit minimalem syntaktischen Aufwand.

Die Bedeutung von @racket[quote] ist über eine rekursive syntaktische Transformation definiert.

@itemlist[
  @item{        
    @racket[(quote (e-1 ... e-n))] wird transformiert zu @racket[(list (quote e-1) ... (quote e-n))].
    Die Transformation wird rekursiv auf die erzeugten Unterausdrücke @racket[(quote e-1)] usw. angewendet.}
  @item{Wenn @racket[l] ein Literal (eine Zahl, ein String, ein Wahrheitswert@note{Wenn Sie boolsche Literale
   quoten wollen, müssen Sie die Syntax @racket[#true] und @racket[#false] für die Wahrheitswerte verwenden;
   bei @racket[true] und @racket[false] erhalten Sie ein Symbol.}, oder ein Bild)
              ist, dann wird @racket[(quote l)] transformiert zu @racket[l].}
  @item{Wenn @racket[n] ein Name/Bezeichner ist, dann wird @racket[(quote n)] transformiert zum @italic{Symbol} @racket['n].}]

Ignorieren Sie eine Sekunde die dritte Regel und betrachten wir den Ausdruck @racket['(1 (2 3))].
Gemäß der ersten Regel wird dieser Ausdruck im ersten Schritt transformiert zu @racket[(list '1 '(2 3))].
Gemäß der zweiten Regel wird der Unterausdruck @racket['1] zu @racket[1] und gemäß der Anwendung der ersten
Regel wird aus dem Unterausdruck @racket['(2 3)] im nächsten Schritt @racket[(list '2 '3)]. Gemäß der zweiten
Regel wird dieser Ausdruck wiederum transformiert zu @racket[(list 2 3)]. Insgesamt erhalten wir also das Ergebnis @racket[(list 1 (list 2 3))].

Sie sehen, dass man mit @racket[quote] sehr effizient verschachtelte Listen (eine Form von Bäumen) erzeugen kann. Vielleicht fragen Sie sich,
wieso wir nicht gleich von Anfang an @racket[quote] verwendet haben. Der Grund dafür ist, dass diese bequemen Wege,
Listen zu erzeugen, verbergen, welche Struktur Listen haben. Insbesondere sollten Sie beim Entwurf von Programmen (und der Anwendung
des Entwurfsrezepts) stets vor Augen haben, dass Listen aus @racket[cons] und @racket[empty] zusammengesetzt sind.

@section{Symbole}
Symbole sind eine Art von Werten die Sie bisher noch nicht kennen. Symbole dienen zur Repräsentation symbolischer Daten.
Symbole sind verwandt mit Strings; statt durch Anführungszeichen vorne und hinten wie bei einem String, 
@racket["Dies ist ein String"], werden Symbole durch ein einfaches Hochkomma gekennzeichnet: @racket['dies-ist-ein-Symbol].
Symbole haben die gleiche Syntax wie Namen/Bezeichner, daher sind beispielsweise Leerzeichen nicht erlaubt.

Im Unterschied zu Strings sind Symbole nicht dazu gedacht, Texte zu repräsentieren. Man kann beispielsweise nicht (direkt) Symbole
konkatenieren. Es gibt nur eine wichtige Operation für Symbole, nämlich der Vergleich von Symbolen mittels @racket[symbol=?].

@ex[(symbol=? 'x 'x)]

@ex[(symbol=? 'x 'y)]

Symbole sind dafür gedacht, "symbolische Daten" zu repräsentieren. Das sind Daten, die "in der Realität" eine wichtige
Bedeutung haben, aber die wir im Programm nur mit einem Symbol darstellen wollen. Ein Beispiel dafür sind Farben:
@racket['red], @racket['green], @racket['blue]. Es macht keinen Sinn, die Namen von Farben als Text zu betrachten.
Wir wollen lediglich ein Symbol für jede Farbe und vergleichen können, ob eine Farbe beispielsweise @racket['red] ist (mit
Hilfe von @racket[symbol=?]).

@section{Quasiquote und Unquote}

Der @racket[quote]-Mechanismus birgt noch eine weitere Überraschung.
Betrachten Sie das folgende Programm:

@racketblock[
(define x 3)
(define y '(1 2 x 4))
]             

Welchen Wert hat @racket[y] nach Auswertung dieses Programms? Wenn Sie die Regeln oben anwenden, sehen Sie, dass nicht etwa @racket[(list 1 2 3 4)]
sondern @racket[(list 1 2 'x 4)] herauskommt. Aus dem Bezeichner @racket[x] wird also das @italic{Symbol} @racket['x].

Betrachten wir noch ein weiteres Beispiel:

@ex['(1 2 (+ 3 4))]

Wer das Ergebnis @racket[(list 1 2 7)] erwartet hat, wird enttäuscht. Die Anwendung der Transformationsregeln ergibt das Ergebnis:
@racket[(list 1 2 (list '+ 3 4))]. Aus dem Bezeichner @racket[+] wird das Symbol @racket['+]. Das Symbol @racket['+] 
hat keine direkte Beziehung zur Additionsfunktion, genau wie das Symbol @racket['x] in dem Beispiel oben keine direkte
Beziehung zum Konstantennamen @racket[x] hat.

Was ist aber, wenn Sie Teile der (verschachtelten) Liste doch berechnen wollen?

Betrachten wir als Beispiel die folgende Funktion:

@#reader scribble/comment-reader
(racketblock
; Number -> (List-of Number)
; given n, generates the list ((1 2) (m 4)) where m is n+1
(check-expect (some-list 2) (list (list 1 2) (list 3 4)))
(check-expect (some-list 11) (list (list 1 2) (list 12 4)))
(define (some-list n) ...)
)

Eine naive Implementation wäre:

@block[
(define (some-list n) '((1 2) ((+ n 1) 4)))]

Aber natürlich funktioniert diese Funktion nicht wie gewünscht:

@ex[(some-list 2)]

Für solche Fälle bietet sich @racket[quasiquote] an. Das @racket[quasiquote]-Konstrukt
verhält sich zunächst mal wie @racket[quote], außer dass es
statt mit einem geraden Hochkomma  mit einem schrägen Hochkomma
abgekürzt wird:

@ex[`(1 2 3)]
@ex[`(a ("b" 5) 77)]

Das besondere an @racket[quasiquote] ist, dass man damit innerhalb eines
gequoteten Bereichs zurückspringen kann in die Programmiersprache. Diese
Möglichkeit nennt sich "unquote" und wird durch das @racket[unquote]-Konstrukt
unterstützt. Auch @racket[unquote] hat eine Abkürzung, nämlich das Komma-Zeichen.

@ex[`(1 2 ,(+ 3 4))]

Mit Hilfe von @racket[quasiquote] können wir nun auch unser Beispiel von oben korrekt implementieren.

@block[
(define (some-list-v2 n) `((1 2) (,(+ n 1) 4)))]

@ex[(some-list-v2 2)]

Die Regeln zur Transformation von @racket[quasiquote] sind genau wie die von @racket[quote] mit
einem zusätzlichen Fall: Wenn @racket[quasiquote] auf ein @racket[unquote] trifft, neutralisieren
sich beide. Ein Ausdruck wie @racket[`,e] wird also transformiert zu @racket[e].

@section[#:tag "sexps"]{S-Expressions}
Betrachten Sie die @racket[person-has-ancestor]-Funktion aus @secref{programmieren-rekdt}. Eine ähnliche Funktion
lässt sich auch für viele andere baumartig organisierte Datentypen definieren, beispielsweise solche zur Repräsentation von
Ordnerhierarchien in Dateisystemen oder zur Repräsentation der Hierarchie innerhalb einer Firma. 

Natürlich könnten wir neben @racket[person-has-ancestor] nun auch noch @racket[directory-has-file] 
und @racket[manager-has-employee] implementieren, aber diese hätten eine sehr ähnliche Struktur wie @racket[person-has-ancestor].
Wir würden also gegen das DRY-Prinzip verstoßen.

Es gibt eine ganze Reihe von Funktionen, die sich auf vielen baumartigen Datentypen definieren ließen: Die Tiefe eines Baumes berechnen, 
nach Vorkommen eines Strings suchen, alle "Knoten" des Baums finden, die ein Prädikat erfüllen, und so weiter.

Um solche Funktionen generisch (also einmal für alle Datentypen) definieren zu können, brauchen wir die Möglichkeit,
über die genaue Struktur von Datentypen abstrahieren zu können. Dies funktioniert mit den "getypten" Datentypen, die 
wir bisher betrachtet haben, nicht.

Eine der großen Innovationen der Programmiersprache LISP war die Idee eines universellen Datenformats: Ein Format, mit
dem beliebige strukturierte Daten repräsentiert werden können, und zwar in solch einer Weise, dass das Format der Daten selbst
Teil der Daten ist und dementsprechend darüber abstrahiert werden kann. Diese Idee wird typischerweise alle paar Jahre
wieder einmal neu erfunden; zur Zeit sind beispielsweise XML und JSON beliebte universelle Datenformate.

Der Mechanismus, den es dazu in LISP seit Ende der 1950er Jahre gibt, heißt @italic{S-Expressions}. Was sind S-Expressions?
Hier ist eine Datendefinition, die dies genau beschreibt:

@#reader scribble/comment-reader
(racketblock
; An S-Expression is one of:
; - a Number
; - a String
; - a Symbol
; - a Boolean
; - an Image
; - empty
; - a (list-of S-Expression)
)

Beispiele für S-Expressions sind: @racket[(list 1 (list 'two 'three) "four")], @racket["Hi"].
Dies sind keine S-Expressions: @racket[(make-posn 1 2)], @racket[(list (make-student "a" "b" 1))].

S-Expressions können als universelles Datenformat verwendet werden, indem die Strukturierung der Daten zum Teil
der Daten gemacht wird. Statt @racket[(make-posn 1 2)] kann man auch die S-Expression @racket['(posn 1 2)] 
oder @racket['(posn (x 1) (y 2))]
verwenden; statt

@block[
(make-person "Heinz" (make-person "Horst" false false) (make-person "Hilde" false false))]

kann man auch die S-Expression

@block[
'(person "Heinz" (person "Horst" #false #false) (person "Hilde" #false #false))] 

oder

@block[
'(person "Heinz" (father (person "Horst" (father #false) (mother #false)) (mother (person "Hilde" (father #false) (mother #f)))))]

verwenden.

Der Vorteil der zweiten Variante ist, dass man beliebige strukturierte Daten auf diese Weise uniform ausdrücken kann
und die Struktur selber Teil der Daten ist. Damit wird es möglich, sehr generische Funktionen zu definieren, die auf
beliebigen strukturierten Daten funktionieren. Der Nachteil ist der, dass man Sicherheit und Typisierung verliert.
Es ist schwierig, zu sagen, dass eine Funktion beispielsweise nur S-Expressions als Eingabe verarbeiten kann, die
einen Stammbaum repräsentieren. 

Der Quote-Operator hat die Eigenschaft, dass er stets S-Expressions erzeugt. Sie können sogar beliebige Definitionen oder Ausdrücke 
in BSL nehmen, einen Quote-Operator drumherumschreiben, und Sie erhalten eine S-Expression, die dieses Programm repräsentiert.

@ex[(first '(define-struct student (firstname lastname matnr)))]

Diese Eigenschaft, die manchmal @italic{Homoikonizität} genannt wird, macht es besonders leicht, Programme als Daten zu
repräsentieren und Programme zu schreiben, die die Repräsentation eines Programms als Eingabe bekommen oder als Ausgabe produzieren.
In Scheme und (vollem) Racket gibt es sogar eine Funktion @racket[eval], die eine Repräsentation eines Ausdrucks als S-Expression
als Eingabe bekommt und die diesen Ausdruck dann interpretiert und das Ergebnis zurückliefert. Beispielsweise würde @racket[(eval '(+ 1 1))] 
Ergebnis @racket[2] liefern. Damit wird es möglich, Programme zur Laufzeit zu berechnen und dann direkt auszuführen - eine sehr mächtige aber
auch sehr gefährliche Möglichkeit.

@section{Anwendungsbeispiel: Dynamische Webseiten}
Da S-Expressions ein universelles Datenformat sind, ist es einfach, andere Datenformate darin zu kodieren, zum Beispiel HTML (die Sprache in 
der die meisten Webseiten definiert werden).

Zusammen mit Quasiquote und Unquote können S-Expressions dadurch leicht zur Erstellung von dynamischen Webseiten, bei denen die
festen Teile als Template definiert werden, genutzt werden. Beispielsweise könnte eine einfache Funktion zur Erzeugung
einer dynamischen Webseite wie folgt aussehen:

@#reader scribble/comment-reader
(block
; String String -> S-Expression
; produce a (representation of) a web page with given author and title
(define (my-first-web-page author title)
  `(html
     (head
       (title ,title)
       (meta ((http-equiv "content-type")
              (content "text-html"))))
     (body
       (h1 ,title)
       (p "I, " ,author ", made this page."))))
)

Die Funktion erzeugt die Repräsentation einer HTML-Seite, bei der die übergebenen Parameter an der gewünschten Stelle eingebaut werden.
S-Expressions und Quasi-/Unquote führen zu einer besseren Lesbarkeit im Vergleich zur Variante der Funktion, die die Datenstruktur mit @racket[cons]
und @racket[empty] oder @racket[list] zusammenbaut. Die erzeugte S-Expression ist zwar noch kein HTML, aber sie kann leicht zu HTML
umgewandelt werden. In Racket gibt es zu diesem Zweck beispielsweise die @racket[xexpr->string] und @racket[xexpr->xml] Funktion der @hyperlink["http://docs.racket-lang.org/xml/index.html"]{XML Bibliothek}.

@ex[(require xml)]

@ex[(xexpr->string (my-first-web-page "Klaus Ostermann" "Meine Homepage"))]

Der durch @racket[xexpr->string] erzeugte String ist gültiges HTML und könnte nun an einen Browser geschickt und dargestellt werden.
