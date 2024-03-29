#lang scribble/manual
@(require scribble/eval)
@(require "marburg-utils.rkt")
@(require (for-label lang/htdp-beginner))
@(require (for-label (except-in 2htdp/image image?)))
@(require (for-label 2htdp/universe))
   
@title[#:version "" #:tag "produkttypen"]{Datendefinition durch Zerlegung: Produkttypen}

@margin-note{Dieser Teil des Skripts basiert auf [HTDP/2e] Kapitel 5}

Nehmen Sie an, Sie möchten mit dem "universe" Teachpack ein Programm schreiben, welches
einen Ball simuliert, der zwischen vier Wänden hin und her prallt. Nehmen wir der Einfachheit
halber an, der Ball bewegt sich konstant mit zwei Pixeln pro Zeiteinheit.

Wenn Sie sich an das Entwurfsrezept halten, ist ihre erste Aufgabe, eine Datenrepräsentation
für all die Dinge, die sich ändern, zu definieren. Für unseren Ball mit konstanter Geschwindigkeit
sind dies zwei Eigenschaften: Die aktuelle Position sowie die Richtung, in die sich der Ball bewegt.

@margin-note{Wäre es sinnvoll, Varianten des "universe" Teachpacks zu haben, in denen der WorldState
             zum Beispiel durch zwei Werte repräsentiert wird?}
Der WorldState im "universe" Teachpack ist allerdings nur ein einzelner Wert. Die Werte, die
wir bisher kennen, sind allerdings stets einzelne Zahlen, Bilder, Strings oder Wahrheitswerte
--- daran ändern auch Summentypen nichts. Wir müssen also irgendwie mehrere Werte so zusammenstellen
können, dass sie wie ein einzelner Wert behandelt werden können. 

Es wäre zwar denkbar, zum Beispiel zwei Zahlen in einen String reinzukodieren und bei Bedarf wieder
zu dekodieren (in der theoretischen Informatik sind solche Techniken als @italic{Gödelisierung} bekannt),
aber für die praktische Programmierung sind diese Techniken ungeeignet.

Jede höhere Programmiersprache hat Mechanismen, um mehrere Daten zu einem Datum zusammenzupacken und
bei Bedarf wieder in seine Bestandteile zu zerlegen. In BSL gibt es zu diesem Zweck
@italic{Strukturen} (@italic{structs}). Man nennt Strukturdefinitionen auch oft @italic{Produkte}, weil 
Sie dem Kreuzprodukt von Mengen in der Mathematik entsprechen. Aus dieser Analogie ergibt sich übrigens auch
der Name 'Summentyp' aus dem letzten Kapitel, denn die Vereinigung von Mengen wird auch als die Summe der
Mengen bezeichnet. In manchen Sprachen werden Strukturen auch @italic{Records} genannt.


@section{Die @racket[posn] Struktur}

Eine Position in einem Bild wird durch zwei Zahlen eindeutig identifiziert: Die
Distanz vom linken Rand und die Distanz vom oberen Rand. Die erste Zahl nennt man die x-Koordinate
und die zweite die y-Koordinate.

In BSL werden solche Positionen mit Hilfe der @racket[posn] Struktur repräsentiert. 
Eine @racket[posn] (Aussprache: Position) ist also @italic{ein} Wert, der @italic{zwei} Werte enthält.

@margin-note{Im Deutschen wäre es eigentlich korrekt, von einem @italic{Exemplar} einer Struktur zu sprechen.
Es hat sich jedoch eingebürgert, analog zum Wort @italic{instance} im Englischen von einer Instanz zu reden, deshalb
werden auch wir diese sprachlich fragwürdige Terminologie verwenden.}
Wir können eine @italic{Instanz} der @racket[posn] Struktur mit der Funktion @racket[make-posn] erzeugen.
Die Signatur dieser Funktion ist @italic{Number Number -> Posn}.

Beispiel: Diese drei Ausdrücke erzeugen jeweils eine Instanz der @racket[posn] Struktur.

@racketblock[
(make-posn 3 4)
(make-posn 8 6)
(make-posn 5 12)]

Eine @racket[posn] hat den gleichen Status wie Zahlen oder Strings in dem Sinne, dass
Funktionen Instanzen von Strukturen konsumieren oder produzieren können.

Betrachten Sie nun eine Funktion, die die Distanz einer Position von der oberen linken Bildecke
berechnet. Hier ist die Signatur, Aufgabenbeschreibung und der Header einer solchen Funktion:

@#reader scribble/comment-reader
(racketblock
; Posn -> Number
; computes the distance of a-posn to the origin
(define (distance-to-0 a-posn) 0)
)

Was neu ist an dieser Funktion ist, dass sie nur einen Parameter, @racket[a-posn], hat, in dem aber 
beide Koordinaten übergeben werden. Hier sind einige Tests die verdeutlichen, was @racket[distance-to-0]
berechnen soll. Die Distanz kann natürlich über die bekannte Pythagaros Formel berechnet werden.

@racketblock[
(check-expect (distance-to-0 (make-posn 0 5)) 5)
(check-expect (distance-to-0 (make-posn 7 0)) 7)
(check-expect (distance-to-0 (make-posn 3 4)) 5)
(check-expect (distance-to-0 (make-posn 8 6)) 10)]

Wie sieht nun der Funktionsbody von @racket[distance-to-0] aus? Offensichtlich müssen wir zu diesem
Zweck die x- und y-Koordinate aus dem Parameter @racket[a-posn] extrahieren. Hierzu gibt es zwei
Funktionen @racket[posn-x] und @racket[posn-y]. Die erste Funktion extrahiert die x-Koordinate, die zweite
die y-Koordinate. Hier zwei Beispiele die diese Funktionen illustrieren:

@ex[(posn-x (make-posn 3 4))
(posn-y (make-posn 3 4))]

Damit wissen wir nun genug, um @racket[distance-to-0] zu implementieren. Als Zwischenschritt
definieren wir ein Template für @racket[distance-to-0], in welchem die Ausdrücke zur Extraktion
der x- und y-Koordinate vorgezeichnet sind.

@racketblock[
(define (distance-to-0 a-posn)
  (... (posn-x a-posn) ...
   ... (posn-y a-posn) ...))]


Auf Basis dieses Templates ist es nun leicht, die Funktionsdefinition zu vervollständigen:

@racketblock[
(define (distance-to-0 a-posn)
  (sqrt
    (+ (sqr (posn-x a-posn))
       (sqr (posn-y a-posn)))))]

@section[#:tag "definestruct"]{Strukturdefinitionen}

Strukturen wie @racket[posn] werden normalerweise nicht fest in eine Programmiersprache eingebaut.
Stattdessen wird von der Sprache nur ein Mechanismus zur Verfügung gestellt, um eigene Strukturen
zu definieren. Die Menge der verfügbaren Strukturen kann also von jedem Programmierer beliebig erweitert
werden.

Eine Struktur wird durch eine spezielle Strukturdefinition erzeugt. Hier ist die Definition der @racket[posn]
Struktur in BSL:

@racketblock[(define-struct posn (x y))]

Im Allgemeinen hat eine Strukturdefinition diese Form:

@racketblock[(define-struct StructureName (FieldName ... FieldName))]

Das Schlüsselwort @racket[define-struct] bedeutet, dass hier eine Struktur definiert wird. Danach kommt
der Name der Struktur. Danach folgen, eingeschlossen in Klammern, die Namen der @italic{Felder} der Struktur.

Im Gegensatz zu einer normale Funktionsdefinition definiert man durch eine Strukturdefinition gleich einen
ganzen Satz an Funktionen, und zwar wie folgt:

@itemize[
       @item{Einen @italic{Konstruktor} --- eine Funktion, die soviele Parameter hat wie die Struktur Felder hat
             und eine Instanz der Struktur zurückliefert. Im Falle von @racket[posn] heißt diese Funktion @racket[make-posn];
             im allgemeinen Fall heißt sie @racket[make-StructureName], wobei @racket[StructureName] der Name der Struktur ist.}

       @item{Pro Feld der Struktur einen @italic{Selektor} --- eine Funktion, die den Wert eines Feldes aus
             einer Instanz der Struktur ausliest. Im Falle von @racket[posn] heißen diese Funktionen @racket[posn-x] 
             und @racket[posn-y]; im Allgemeinen heißen Sie @racket[StructureName-FieldName], wobei @racket[StructureName]
             der Name der Struktur und @racket[FieldName] der Name des Feldes ist.}
       @item{Ein @italic{Strukturprädikat} --- eine boolsche Funktion, die berechnet, ob ein Wert eine Instanz
                 dieser Struktur ist. Im Falle von @racket[posn] heißt dieses Prädikat @racket[posn?]; 
                 im Allgemeinen heißt es @racket[StructureName?], wobei @racket[StructureName] der Name der Struktur ist.}]

Der Rest des Programms kann diese Funktionen benutzen als wären sie primitive Funktionen.    

@section{Verschachtelte Strukturen}
Ein sich mit konstanter Geschwindigkeit bewegender Ball im zweidimensionalen Raum 
kann durch zwei Eigenschaften beschrieben werden: Seinen Ort und die Geschwindigkeit und Richtung in die er sich bewegt. 
Wir wissen bereits wie man den Ort eines Objekts im zweidimensionalen Raum beschreibt: Mit Hilfe der @racket[posn] Struktur.
Es gibt verschiedene Möglichkeiten, die Geschwindigkeit und Richtung eines Objekts zu repräsentieren. Eine dieser
Möglichkeiten ist die, einen Bewegungsvektor anzugeben, zum Beispiel in Form einer Strukturdefinition wie dieser:

@block[(define-struct vel (delta-x delta-y))]

@margin-note{Der Grad der Veränderung von Einheiten wird in der Informatik (und anderswo) häufig als @italic{Delta} bezeichnet, daher der Name
             der Felder.}
Der Name @racket[vel] steht für @italic{velocity}; @racket[delta-x] und @racket[delta-y] beschreiben, wieviele Punkte auf der x-
und y-Achse sich das Objekt pro Zeiteinheit bewegt.

Auf Basis dieser Definitionen können wir beispielsweise berechnen, wie sich der Ort eines Objekts ändert:
@#reader scribble/comment-reader
(racketblock
; Posn Vel -> Posn
; computes position of loc moving it by v
(check-expect (move (make-posn 5 6) (make-vel 1 2)) (make-posn 6 8))
(define (move loc v)
  (make-posn
   (+ (posn-x loc) (vel-delta-x v))
   (+ (posn-y loc) (vel-delta-y v))))
)   

Wie können wir nun einen sich bewegenden Ball repräsentieren? Wir haben gesehen, dass dieser durch seinen Ort und seinen
Bewegungsvektor beschrieben wird. Eine Möglichkeit der Repräsentation wäre diese:
@racketblock[(define-struct ball (x y delta-x delta-y))]

Hier ist ein Beispiel für einen Ball in dieser Repräsentation:

@racketblock[(define SOME-BALL (make-ball 5 6 1 2))]

Allerdings geht in dieser Repräsentation die Zusammengehörigkeit der Felder verloren: Die ersten zwei Felder repräsentieren
den Ort, die anderen zwei Felder die Bewegung. Eine praktische Konsequenz ist, dass es auch umständlich ist, Funktionen
aufzurufen, die etwas mit Geschwindigkeiten und/oder Bewegungen machen aber nichts über Bälle wissen, wie zum Beispiel @racket[move]
oben, denn wir müssen die Daten erst immer manuell in die richtigen Strukturen verpacken. Um @racket[SOME-BALL] 
mit Hilfe von @racket[move] zu bewegen, müssten wir Ausdrucke wie diesen schreiben:

@racketblock[
(move (make-posn (ball-x SOME-BALL) (ball-y SOME-BALL)) 
      (make-vel (ball-delta-x SOME-BALL) (ball-delta-y SOME-BALL)))]

Eine bessere Repräsentation @italic{verschachtelt} Strukturen ineinander:

@racketblock[(define-struct ball (position velocity))]

Diese Definition ist so noch nicht verschachtelt --- dies werden wir in Kürze durch Datendefinitionen
für Strukturen deutlich machen. Die Schachtelung können wir sehen, wenn wir Instanzen dieser Struktur
erzeugen. Der Beispielball @racket[SOME-BALL] wird konstruiert, indem die Konstruktoren ineinander verschachtelt werden:

@racketblock[(define SOME-BALL (make-ball (make-posn 5 6) (make-vel 1 2)))]

In dieser Repräsentation bleibt die logische Gruppierung der Daten intakt. Auch der Aufruf von @racket[move] gestaltet sich nun einfacher:

@racketblock[
(move (ball-position SOME-BALL) (ball-velocity SOME-BALL))]

Im Allgemeinen kann man durch Verschachtelung von Strukturen also Daten hierarchisch in Form eines Baums repräsentieren.

@section{Datendefinitionen für Strukturen}

Der Zweck einer Datendefinition für Strukturen ist, zu beschreiben, welche Art von Daten jedes Feld
enthalten darf. Für einige Strukturen ist die dazugehörige Datendefinition recht offensichtlich:

@#reader scribble/comment-reader
(racketblock
(define-struct posn (x y))
; A Posn is a structure: (make-posn Number Number)
; interp. the number of pixels from left and from top
)

Hier sind zwei plausible Datendefinitionen für @racket[vel] und @racket[ball]:

@#reader scribble/comment-reader
(racketblock
(define-struct vel (delta-x delta-y))
; A Vel is a structure: (make-vel Number Number)
; interp. the velocity vector of a moving object

(define-struct ball (position velocity))
; A Ball is a structure: (make-ball Posn Vel)
; interp. the position and velocity of a ball
)

Eine Struktur hat jedoch nicht notwendigerweise genau eine zugehörige Datendefinition. Beispielsweise können
wir Bälle nicht nur im zweidimensionalen, sondern auch im ein- oder drei-dimensionalen Raum betrachten.
Im eindimensionalen Raum können Position und Velocity jeweils durch eine Zahl repräsentiert werden.
Daher können wir definieren:

@#reader scribble/comment-reader
(racketblock
; A Ball1d is a structure: (make-ball Number Number)
; interp. the position and velocity of a 1D ball
)
 
Strukturen können also "wiederverwendet" werden. Sollte man dies stets tun wenn möglich?

Prinzipiell bräuchten wir nur eine einzige Struktur mit zwei Feldern und könnten damit alle Produkttypen mit zwei Komponenten kodieren.
Beispielsweise könnten wir uns auch @racket[vel] und @racket[ball] sparen und stattdessen nur @racket[posn] verwenden:

@#reader scribble/comment-reader
(racketblock
; A Vel is a structure: (make-posn Number Number)
; interp. the velocity vector of a moving object

; A Ball is a structure: (make-posn Posn Vel)
; interp. the position and velocity of a ball
)

Wir können sogar prinzipiell @italic{alle} Produkttypen, auch solche mit mehr als zwei Feldern, mit Hilfe von @racket[posn] ausdrücken,
indem wir @racket[posn] verschachteln.

Beipiel:

@#reader scribble/comment-reader
(racketblock
; A 3DPosn is a structure: (make-posn Number (make-posn Number Number))
; interp. the x/y/z coordinates of a point in 3D space
)

Die Sprache LISP basierte auf diesem Prinzip: Es gab in ihr nur eine universelle Datenstruktur, die sogenannte @italic{cons-Zelle}, 
die verwendet wurde, um alle Arten von Produkten zu repräsentieren. Die cons-Zelle entspricht folgender Strukturdefinition in BSL:

@margin-note{Die Namen @racket[cons], @racket[car] und @racket[cdr] haben eine Historie, die für uns aber nicht relevant ist.
             @racket[car] ist einfach der Name für die erste Komponente und @racket[cdr] der für die zweite Komponente des Paars.}
@racketblock[(define-struct cons-cell (car cdr))]

Ist diese Wiederverwendung von Strukturdefinitionen eine gute Idee? Der Preis, den man dafür bezahlt, ist, dass man die unterschiedlichen
Daten nicht mehr unterscheiden kann, weil es pro Strukturdefinition nur ein Prädikat gibt. Unsere Empfehlung ist daher, Strukturdefinitionen
nur dann in mehreren Datendefinitionen zu verwenden, wenn die unterschiedlichen Daten ein gemeinsames semantisches Konzept haben. Im
Beispiel oben gibt es für @racket[Ball] und @racket[Ball1d] das gemeinsame Konzept des Balls im n-dimensionalen Raum. Es gibt jedoch kein
sinnvolles gemeinsames Konzept für @racket[Ball] und @racket[Posn]; daher ist es nicht sinnvoll, eine gemeinsame Strukturdefinition zu verwenden.

Ein anderes sinnvolles Kriterium, um über Wiederverwendung zu entscheiden, ist die Frage, ob es wichtig ist, dass man mit einem Prädikat die
unterschiedlichen Daten unterscheiden kann --- falls ja, so sollte man jeweils eigene Strukturen verwenden.

@section[#:tag "ballinbewegung"]{Fallstudie: Ein Ball in Bewegung}

Probieren Sie aus, was das folgende Programm macht. Verstehen Sie, wie Strukturen und Datendefinitionen verwendet wurden, um das Programm zu
strukturieren!

@#reader scribble/comment-reader
(racketblock
(define WIDTH 200)
(define HEIGHT 200)
(define BALL-IMG (circle 10 "solid" "red"))
(define BALL-RADIUS (/ (image-width BALL-IMG) 2))

(define-struct vel (delta-x delta-y))
; A Vel is a structure: (make-vel Number Number)
; interp. the velocity vector of a moving object

(define-struct ball (position velocity))
; A Ball is a structure: (make-ball Posn Vel)
; interp. the position and velocity of a object 

; Posn Vel -> Posn
; computes position of loc moving it by v
(check-expect (move (make-posn 5 6) (make-vel 1 2)) (make-posn 6 8))
(define (move loc v)
  (make-posn
   (+ (posn-x loc) (vel-delta-x v))
   (+ (posn-y loc) (vel-delta-y v))))

; Ball -> Ball
; computes movement of ball in one clock tick
(check-expect (move-ball (make-ball (make-posn 20 30) 
                                    (make-vel 5 10))) 
              (make-ball (make-posn 25 40) 
                         (make-vel 5 10)))
(define (move-ball ball)
  (make-ball (move (ball-position ball)
                   (ball-velocity ball))
             (ball-velocity ball)))

; A Collision is one of:
; - "top"
; - "down"
; - "left"
; - "right"
; - "none"
; interp. the location where a ball collides with a wall

; Posn -> Collision
; detects with which of the walls (if any) the ball collides
(check-expect (collision (make-posn 0 12))  "left")
(check-expect (collision (make-posn 15 HEIGHT)) "down")
(check-expect (collision (make-posn WIDTH 12))  "right")
(check-expect (collision (make-posn 15 0)) "top")
(check-expect (collision (make-posn 55 55)) "none")
(define (collision posn)
  (cond 
    [(<= (posn-x posn) BALL-RADIUS) "left"]
    [(<= (posn-y posn) BALL-RADIUS)  "top"]
    [(>= (posn-x posn) (- WIDTH BALL-RADIUS)) "right"]
    [(>= (posn-y posn) (- HEIGHT BALL-RADIUS)) "down"]
    [else "none"]))
  
; Vel Collision -> Vel  
; computes the velocity of an object after a collision
(check-expect (bounce (make-vel 3 4) "left") 
              (make-vel -3 4))
(check-expect (bounce (make-vel 3 4) "top") 
              (make-vel 3 -4))
(check-expect (bounce (make-vel 3 4) "none") 
              (make-vel 3 4))
(define (bounce vel collision)
  (cond [(or (string=? collision "left")
             (string=? collision "right"))
         (make-vel (- (vel-delta-x vel))
                   (vel-delta-y vel))]
        [(or (string=? collision "down")
             (string=? collision "top"))
         (make-vel (vel-delta-x vel) 
                   (- (vel-delta-y vel)))]
        [else vel]))
        
; WorldState is a Ball

; WorldState -> Image
; renders ball at its position
(check-expect (image? (render INITIAL-BALL)) #true)
(define (render ball)
  (place-image BALL-IMG 
               (posn-x (ball-position ball))
               (posn-y (ball-position ball))
               (empty-scene WIDTH HEIGHT)))


; WorldState -> WorldState
; moves ball to its next location
(check-expect (tick (make-ball (make-posn 20 12) (make-vel 1 2)))
              (make-ball (make-posn 21 14) (make-vel 1 2)))
(define (tick ball)
  (move-ball (make-ball (ball-position ball)
                        (bounce (ball-velocity ball)
                                (collision (ball-position ball))))))

(define INITIAL-BALL (make-ball (make-posn 20 12)
                                (make-vel 1 2)))

(define (main ws) 
  (big-bang ws (on-tick tick 0.01) (to-draw render)))

; start with: (main INITIAL-BALL)
)

Probieren Sie aus, was passiert, wenn der Ball genau in eine Ecke des Spielfeldes fliegt.
Wie kann man dieses Problem lösen? Reflektieren Sie in Anbetracht dieses Problems darüber,
wieso es wichtig ist, immer die Extremfälle (im Englischen: @italic{@bold{Corner} Cases}) zu testen ;-)


@section[#:tag "tagging-maybe"]{Tagged Unions und Maybe}
Wie bereits im Abschnitt @secref{disjoint} bemerkt wurde, ist es für Summentypen wichtig, dass die
einzelnen Alternativen unterscheidbar sind. Nehmen wir zum Beispiel den Datentyp @racket[MaybeNumber]
aus Abschnitt @secref{sums}:

@#reader scribble/comment-reader
(racketblock
; A MaybeNumber is one of:
; – a Number
; – #false
; interp. a number if successful, else false.
)

Das Konzept, dass eine Berechnung fehlschlägt, bzw. dass eine Eingabe optional ist, ist sehr
häufig anzutreffen. Hier stellt der obige Summentyp eine gute Lösung dar.

@margin-note{Zur Erinnerung: Wir können den Summentyp aber nur so definieren, da der Wert @racket[#false]
nicht in @racket[Number] enthalten ist und keine Zahl aus @racket[Number] in der ein-elementigen Menge { @racket[#false] }
enthalten ist. Die beiden Mengen sind disjunkt.}

Nun würden wir gerne die gleiche Idee auch für optionale Wahrheitswerte verwenden und definieren daher:

@#reader scribble/comment-reader
(racketblock
; A BadMaybeBoolean is one of:
; – a Boolean
; – #false
; interp. a boolean if successful, else false.
)

Die beiden Varianten sind offensichtlich nicht disjunkt: Die Vereinigung von { @racket[#true], @racket[#false] }
und { @racket[#false] } hätte wieder nur zwei Elemente.

Um das zu verhindern, können wir mit einem @italic{tag} markieren, zu welcher Alternative ein Wert gehört.
Hierzu definieren wir zunächst die Strukturen

@#reader scribble/comment-reader
(racketblock
(define-struct some (value))
(define-struct none ())
)

Die erste Struktur nutzen wir, um zu markieren, dass es sich bei der Variante um einen vorhandenen Wert handelt --
die zweite Struktur nutzen wir, um zu markieren, dass kein Wert vorhanden ist:

@#reader scribble/comment-reader
(racketblock
; A MaybeBoolean is one of:
; – a structure: (make-some Boolean)
; – (make-none)
; interp. a boolean if successful, else none.
)

Der Summentyp @racket[MaybeBoolean] hat nun drei Elemente { @racket[(make-none)], @racket[(make-some #true)], @racket[(make-some #false)] }.
Die beiden Alternativen sind nun eindeutig zu unterscheiden. Insbesondere können wir jetzt eine Funktion, die ein @racket[MaybeBoolean] erwartet,
einfach nach dem Entwurfsrezept (in der Version für Summentypen) implementieren.

@margin-note{Würden wir @racket[MaybeNumber] nun auch auf diese Weise definieren und danach die Summe aus @racket[MaybeBoolean]
und @racket[MaybeNumber] bilden, hätten wir wieder das ursprüngliche Problem: Es ist nicht unterscheidbar, ob
@racket[(make-none)] "kein Wahrheitswert" oder "keine Zahl" ist. Haben Sie eine Idee, wie sich das Problem lösen lässt?}


@section[#:tag "entwurfsrezept-structs"]{Erweiterung des Entwurfsrezepts}

Die vorhergehenden Beispiele haben gezeigt, dass viele Probleme es erfordern, parallel
mit Funktionen passende Datenstrukturen zu entwickeln. Dies bedeutet, dass sich
die Schritte des Entwurfsrezepts aus Abschnitt @secref{entwurfsrezept} wie folgt ändern:

@itemize[#:style 'ordered
       @item{Wenn in einer Problembeschreibung Information auftauchen, die zusammengehören
             oder ein Ganzes beschreiben, benötigt man Strukturen. Die Struktur korrespondiert
             zu dem "Ganzen" und hat für jede "relevante" Eigenschaft ein Feld.
             
             Eine Datendefinition für ein Feld muss einen Namen für die Menge der Instanzen
             der Struktur angeben, die durch diese Datendefinition beschrieben werden.
             Sie muss beschreiben, welche Daten für welches Feld erlaubt sind. Hierzu sollten
             nur Namen von eingebauten Datentypen oder von Ihnen bereits definierten Daten
             verwendet werden.
             
             Geben Sie in der Datendefinition Beispiele für Instanzen der Struktur, die der 
             Datendefinition entsprechen, an.}
       @item{Nichts ändert sich im zweiten Schritt.}
       @item{Verwenden Sie im dritten Schritt die Beispiele aus dem ersten Schritt, um Tests
             zu entwerfen. Wenn eines der Felder einer Struktur, die Eingabeparameter ist, einen
             Summentypen hat, so sollten Testfälle für alle Alternativen vorliegen. Bei Intervallen
             sollten die Endpunkte der Intervalle getestet werden.}
       @item{Eine Funktion die Instanzen von Strukturen als Eingabe erhält wird in vielen 
             Fällen die Felder der Strukturinstanz lesen. Um Sie an diese Möglichkeit zu erinnern,
             sollte das Template für solche Funktionen die Selektorausdrücke (zum Beispiel 
             @racket[(posn-x param)] falls @racket[param] ein Parameter vom Typ @racket[Posn] ist)
             zum Auslesen der Felder enthalten.
             
             Falls der Wert eines Feldes selber Instanz einer Struktur ist, sollten Sie jedoch
             @italic{nicht} Selektorausdrücke für die Felder dieser verschachtelten Strukturinstanz
             ins Template aufnehmen. Meistens ist es besser, die Funktionalität, die diese 
             Unterstruktur betrifft, in eine neue Hilfsfunktion auszulagern.}
       @item{Benutzen Sie die Selektorausdrücke aus dem Template um die Funktion zu implementieren.
             Beachten Sie, dass Sie möglicherweise nicht die Werte aller Felder benötigen.}
       @item{Testen Sie, sobald Sie den Funktionsheader geschrieben haben. Überprüfen Sie, dass
             zu diesem Zeitpunkt alle Tests fehlschlagen (bis auf die bei denen zufällig der eingesetzte
             Dummy-Wert richtig ist). Dieser Schritt ist wichtig, denn er bewahrt Sie vor Fehlern in
             den Tests und stellt sicher, dass ihre Tests auch wirklich eine nicht-triviale Eigenschaft testen.
             
             Testen Sie so lange, bis alle Ausdrücke im Programm während des Testens mindestens einmal
             ausgeführt wurden. Die Codefärbung in DrRacket nach dem Testen unterstützt Sie dabei.}]

 
@section{Formale Signaturen für Produkttypen}

Auch für Produkttypen gibt es (leider etwas rudimentären) Support für formale Signaturen. Zu jeder
Struktur @racket[mystruct] gibt es eine Signatur @racket[MystructOf], die genau so viele
Signaturen als Parameter erwartet wie @racket[mystruct] Felder hat.

Beispiel:
@#reader scribble/comment-reader
(racketblock
(define-struct pair [fst snd])

(: add-pair ((PairOf Number Number) -> Number))
(define (add-pair p)
  (+ (pair-fst p) (pair-snd p)))
)

Mit Hilfe von @racket[signature] können wir auch formale Datendefinitionen für Produkttypen erstellen.

Beispiel:
@#reader scribble/comment-reader
(racketblock
(define Position (signature (PairOf Number Number)))
; interp. x/y coordinates of a Position on the screen, from top left.

(: ORIGIN Position)
(define ORIGIN (make-pair 0 0))
)

Leider ist es derzeit nicht möglich, der Konstruktorfunktion selber eine formale Signatur zu geben.
