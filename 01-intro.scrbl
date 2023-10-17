#lang scribble/manual
@(require scribble/eval)
@(require "marburg-utils.rkt")
@(require (for-label lang/htdp-beginner))
@(require (for-label (except-in 2htdp/image image?)))
@(require scriblib/footnote)
@(require "questionnaire.rkt")


@title[#:version ""]{Programmieren mit Ausdrücken}

@margin-note{Dieser Teil des Skripts basiert auf [HTDP/2e] Kapitel 1}

@section{Programmieren mit arithmetischen Ausdrücken}

Jeder von Ihnen weiß, wie man Zahlen addiert, Kaffee kocht, oder einen Schrank eines schwedischen Möbelhauses zusammenbaut.
Die Abfolge von Schritten, die sie hierzu durchführen, nennt man @italic{Algorithmus}, und Sie wissen
wie man einen solchen Algorithmus ausführt.
In diesem Kurs werden wir die Rollen umdrehen: Sie werden den Algorithmus programmieren, und der Computer
wird ihn ausführen.  Eine formale Sprache, in der solche Algorithmen formuliert werden können, heißt
@italic{Programmiersprache}. Die Programmiersprache, die wir zunächst verwenden werden, heißt
@italic{BSL}. BSL steht für "Beginning Student Language". Zum Editieren und Ausführen der BSL Programme
verwenden wir @italic{DrRacket}. DrRacket kann man unter der URL @url{http://racket-lang.org/} herunterladen.
Bitte stellen Sie als Sprache "How To Design Programs - Anfänger" ein. Folgen Sie diesem Text am besten,
indem Sie DrRacket parallel starten und immer mitprogrammieren.

Viele einfache Algorithmen sind in einer Programmiersprache bereits vorgegeben, z.B. solche
zur Arithmetik mit Zahlen. Wir können "Aufgaben" stellen, indem wir DrRacket eine Frage stellen,
auf die uns DrRacket dann im Ausgabefenster die Antwort gibt. So können wir zum Beispiel die Frage

@racketblock[(+ 1 1)]

im @italic{Definitionsbereich} (dem oberen Teil der DrRacket Oberfläche) stellen --- als Antwort erhalten wir im @italic{Interaktionsbereich} (dem Bereich unterhalb
des Definitionsbereichs) bei Auswertung dieses Programms ("Start" Knopf) @ev[(+ 1 1)].
Im Definitionsbereich
 schreiben und editieren Sie ihre Programme. Sobald Sie hier etwas ändern, taucht der "Speichern" Knopf
 auf, mit dem Sie die Definitionen in einer Datei abspeichern können. Im Interaktionsbereich wird das Ergebnis einer Programmausführung angezeigt;
 außerdem können hier Ausdrücke eingegeben werden, die sofort ausgewertet werden aber nicht in der Datei mit abgespeichert werden.

 Die Art von Programmen bzw. Fragen wie @racket[(+ 1 1)] nennen wir @italic{Ausdrücke}. In Zukunft werden wir solche Frage/Antwort Interaktionen so darstellen, dass wir vor die Frage das > Zeichen setzen und in der nächsten Zeile die Antwort auf die Frage:
@todo{Screenshot zur Beschreibung der DrRacket Oberfläche?}

@ex[(+ 1 1)]

Operationen wie @racket[+] nennen wir im Folgenden @italic{Funktionen}. Die Operanden wie @racket[1] nennen wir @italic{Argumente}.
Hier einige weitere Beispiele für Ausdrücke mit anderen Funktionen:

@ex[(+ 2 2)
(* 3 3)
(- 4 2)
(/ 6 2)
(sqr 3)
(expt 2 3)
(sin 0)]

Die Argumente dieser Funktionen sind jeweils Zahlen, und das Ergebnis ist auch wieder eine Zahl. Wir können auch direkt eine Zahl als Ausdruck verwenden. Zum Beispiel:

@ex[5]

DrRacket zeigt als Ergebnis wieder genau dieselbe Zahl an. Eine Zahl, die direkt in einem Ausdruck verwendet wird, heißt auch Zahlen@italic{literal}.

Für manche Ausdrücke kann der Computer das mathematisch korrekte Ergebnis nicht berechnen.
Stattdessen erhalten wir eine Annäherung an das mathematisch korrekte Ergebnis. Zum Beispiel:

@ex[(sqrt 2)]
@ex[(cos pi)]

Das @racket[i] im letzten Ergebnis steht für "inexact", also ungenau. In BSL kann man an diesem @racket[i] sehen, ob eine
Zahl ein exaktes Ergebnis oder nur ein angenähertes Ergebnis ist.


 Programme beinhalten Ausdrücke. Alle Programme, die wir bisher gesehen haben, @italic{sind} Ausdrücke.
 Jeder von Ihnen kennt Ausdrücke aus der Mathematik. Zu diesem Zeitpunkt ist ein Ausdruck in unserer
 Programmiersprache entweder eine Zahl, oder etwas, das mit einer linken Klammer "(" startet und mit
 einer rechten Klammer ")" endet.
 Wir bezeichnen Zahlen als @italic{atomare Ausdrücke} und Ausdrücke, die mit einer Klammer starten, als @italic{zusammengesetzte Ausdrücke}.
 Später werden andere Arten von Ausdrücken hinzukommen.


@margin-note{Programieren Sie einen Ausdruck, der die Summe der Zahlen 3, 5, 19, und 32 berechnet.}

 Wie kann man mehr als zwei Zahlen addieren? Hierzu gibt es zwei Möglichkeiten:

 Durch Schachtelung:

@ex[(+ 2 (+ 3 4))]

oder durch Addition mit mehr als zwei Argumenten:

@ex[(+ 2 3 4)]

Immer wenn Sie in BSL eine Funktion wie @racket[+] oder @racket[sqrt] benutzen möchten,
schreiben Sie eine öffnende Klammer, gefolgt vom Namen der Funktion, dann einem Leerzeichen
(oder Zeilenumbruch) und dann die Argumente der Funktion, also in unserem Fall die Zahlen, auf die die
Funktion angewandt werden soll.

@margin-note{Programmieren Sie einen Ausdruck, der den Durchschnitt der Zahlen 3, 5, 19 und 32 berechnet.}

Am Beispiel der Schachtelung haben Sie gesehen, dass auch zusammengesetzte Ausdrücke als Argumente zugelassen sind.
Diese Schachtelung kann beliebig tief sein:

@ex[(+ (* 5 5) (+ (* 3 (/ 12 4)) 4))]

Das Ergebnis für einen solchen geschachtelten Ausdruck wird so berechnet, wie sie es auch auf einem Blatt Papier
machen würden: Wenn ein Argument ein zusammengesetzter Ausdruck ist, so wird zunächst das Ergebnis für diesen Ausdruck berechnet.
Dieser Unterausdruck ist möglicherweise selber wieder geschachtelt; in diesem Fall wird diese
Berechnungsvorschrift auch auf diese Unterausdrücke wieder angewendet (@italic{rekursive} Anwendung).
Falls mehrere Argumente zusammengesetzte Ausdrücke sind, so werden diese in einer nicht festgelegten Reihenfolge ausgewertet.
Die Reihenfolge ist nicht festgelegt, weil das Ergebnis nicht von der Reihenfolge abhängt --- mehr dazu später.

Zusammengefasst ist Programmieren zu diesem Zeitpunkt das Schreiben von arithmetischen Ausdrücken.
Ein Programm auszuführen bedeutet, den Wert der darin enthaltenen Ausdrücke zu berechnen.
Ein Drücken auf "Start" bewirkt die Ausführung des Programms im Definitionsbereich; die Ergebnisse
der Ausführung werden im Interaktionsbereich angezeigt.

Noch ein praktischer Hinweis: Wenn Sie dieses Dokument mit einem Webbrowser lesen, sollten alle Funktionen, die
in den Beispielausdrücken vorkommen, einen Hyperlink zu ihrer Dokumentation enthalten. Beispielsweise
sollte der Additionsoperator im Ausdruck @racket[(+ 5 7)] einen solchen Hyperlink enthalten. Unter diesen
Links finden Sie auch eine Übersicht über die weiteren Operationen, die sie verwenden können.

@pdf-note{Im HTML-Skript ist an dieser Stelle und nach ein paar anderen Kapiteln ein interaktives Quiz.
  Im PDF haben wir die Quizzes ans Ende gepackt, damit man frei entscheiden kann, ob man sie mitdrucken will,
  und verweisen darauf mit einer Notiz am Rande, wie hier: @secref{quiz-intro}}

@questionnaire[#:key "intro" #:language "de"
  @question[
    @q{Was ist die aktuelle Version von DrRacket?}

    @distractor{5.2}

    @solution{8.10}
    @explanation{Stand April 2022, zu sehen u.a. auf der Downloadseite @url{https://download.racket-lang.org/}}

    @distractor{9.0}
  ]
  @question[
    @q{Wofür steht BSL?}
    @distractor{Bovine Sign Language}
    @solution{Beginning Student Language}
    @distractor{Bayrische Schnaps-Lieferanten}
  ]
  @question[
    @q{Welche der folgenden Optionen sind gültige BSL-Programme?}

    @solution{@racketblock[(+ 40 2)]}
    @distractor{@racketblock[40 + 2]}
    @distractor{@racketblock[add(40, 2)]}
    @solution{@racketblock[42]}

  ]
  @question[
    @q{Wie nennen wir im Folgenden Operationen wie @racket[+] oder @racket[/]?}

    @distractor{Prozeduren}
    @distractor{Methoden}
    @distractor{Funktoren}
    @solution{Funktionen}
  ]
  @question[
    @q{Und wie nennen wir die Zahlen, auf die wir die Funktionen anwenden?}

    @distractor{Operanden}
    @solution{Argumente}
    @distractor{Passoren}
  ]
  @question[
    @q{Wieviele @italic{zusammengesetzte} Ausdrücke sind in folgendem Programm enthalten?
    @racketblock[(+ (* 5 5) (+ (* 3 (/ 12 4)) 4))]
    }

    @solution{5}
    @explanation{@racket[(* 5 5)], @racket[(/ 12 4)], @racket[(* 3 (/ 12 4))], @racket[(+ (* 3 (/ 12 4)) 4)] und @racket[(+ (* 5 5) (+ (* 3 (/ 12 4)) 4))].}

    @distractor{11}
    @explanation{Die 6 Zahlen sind @italic{atomare} Ausdrücke.}

    @distractor{2}
  ]
]

@section[#:tag "arithmeticnm"]{Arithmetik mit nicht-numerischen Werten}

Wenn wir nur Programme schreiben könnten, die Zahlen verarbeiten, wäre Programmieren genau so
langweilig wie Mathematik ;-) Zum Glück gibt es viele andere Arten von Werten, mit denen
wir ganz analog zu Zahlen rechnen können, zum Beispiel Text, Wahrheitswerte, Bilder usw.

Zu jedem dieser sogenannten @italic{Datentypen} gibt es @italic{Konstruktoren}, mit denen man Werte dieser
 Datentypen konstruieren kann, sowie @italic{Funktionen}, die auf Werte dieses Datentyps angewendet
 werden können und die weitere Werte des Datentyps konstruieren. Konstruktoren für numerische
 Werte sind zum Beispiel @racket[42] oder @racket[5.3] (also die Zahlen@italic{literale}; Funktionen sind zum Beispiel
 @racket[+] oder @racket[*].

Die Konstruktoren für Text (im folgenden auch @italic{String} genannt) erkennt man an Anführungszeichen. So ist zum Beispiel

@racket["Konzepte der Programmiersprachen"]

ein Stringliteral. Eine Funktion auf diesem Datentyp ist @racket[string-append], zum Beispiel

@ex[(string-append "Konzepte der " "Programmiersprachen")]

Es gibt weitere Funktionen auf Strings: Um Teile aus einem String zu extrahieren, um die Reihenfolge
der Buchstaben umzukehren, um in Groß- oder Kleinbuchstaben zu konvertieren usw. Zusammen bilden diese
Funktionen die @italic{Arithmetik der Strings}.


Die Namen aller dieser Funktionen muss man sich nicht merken; bei Bedarf können die zur Verfügung stehenden
Funktionen für Zahlen, Strings und andere Datentypen in der DrRacket Hilfe nachgeschlagen werden
unter: Hilfe -> How to Design Programs Languages -> Beginning Student -> Pre-defined Functions

@margin-note{Programmieren Sie einen Ausdruck, der den String @racket["Der Durchschnitt ist ..."] erzeugt. Statt der drei Punkte soll der Durchschnitt der Zahlen 3, 5, 19 und 32 stehen. Verwenden Sie den Ausdruck, der diesen Durchschnitt berechnet, als Unterausdruck.}

Bisher haben wir nur Funktionen kennengelernt, bei denen alle Argumente und auch das Ergebnis zum
selben Datentyp gehören müssen. Zum Beispiel arbeitet die Funktion @racket[+] nur mit Zahlen, und die
Funktion @racket[string-append] arbeitet nur mit Strings. Es gibt aber auch Funktionen, die Werte
eines Datentyps als Argument erwarten, aber Werte eines anderen Datentypes als Ergebnis liefern,
zum Beispiel die Funktion @racket[string-length]:

@ex[(+ (string-length "Programmiersprachen") 5)]

Das Ergebnis von @racket[(string-length "Programmiersprachen")] ist die Zahl
@ev[(string-length "Programmiersprachen")], die ganz normal als Argument für die Funktion @racket[+]
verwendet werden kann. Sie können also Funktionen, die zu unterschiedlichen Datentypen gehören, in
einem Ausdruck zusammen verwenden. Dabei müssen Sie allerdings darauf achten, daß jede Funktion Argumente
des richtigen Datentyps bekommt. Es gibt sogar Funktionen, die Argumente unterschiedlicher Datentypen
erwarten, zum Beispiel

@ex[(replicate 3 "hi")]

Schließlich gibt es auch Funktionen, die Datentypen ineinander umwandeln, zum Beispiel

@ex[(number->string 42)
    (string->number "42")]

Dieses Beispiel illustriert, dass @racket[42] und @racket["42"], trotz ihres ähnlichen Aussehens,
zwei sehr unterschiedliche Ausdrücke sind. Um diese zu vergleichen, nehmen wir noch zwei weitere Ausdrücke hinzu,
nämlich @racket[(+ 21 21)] und @racket["(+ 21 21)"].

@tabular[#:sep @hspace[3]
 (list (list @bold{Zahlen}       @bold{Strings})
       (list @racket[42]         @racket["42"])
       (list @racket[(+ 21 21)]  @racket["(+ 21 21)"]))]

Der erste Ausdruck, @racket[42], ist ein Zahl;
die Auswertung einer Zahl ergibt die Zahl selber.
@note{Wenn wir ganz präzise sein wollten, könnten wir noch unterscheiden zwischen dem Zahlenliteral @racket[42]
und dem mathematischen Objekt 42; ersteres ist nur eine Notation (Syntax) für letzteres. Wir werden
jedoch die Bedeutung von Programmen rein syntaktisch definieren, daher ist diese Unterscheidung für uns nicht relevant.}
Der dritte Ausdruck, @racket[(+ 21 21)], ist ein Ausdruck, der bei Auswertung ebenfalls den Wert 42 ergibt.
Jedes Vorkommen des Ausdrucks @racket[42] kann in einem Programm durch den Ausdruck
@racket[(+ 21 21)] ersetzt werden (und umgekehrt), ohne die Bedeutung des Programms zu verändern.

Der zweite Ausdruck, @racket["42"], ist hingegen ein String, also eine Sequenz von Zeichen, die zufällig, wenn
man sie in Dezimalnotation interpretiert, dem Wert 42 entspricht. Dementsprechend ist es auch sinnlos,
zu @racket["42"] etwas hinzuaddieren zu wollen:

@interaction[#:eval (bsl-eval)
 (+ "42" 1)]

@margin-note{Es gibt Programmiersprachen, die automatische Konvertierungen zwischen Zahlen und Strings, die Zahlen
             repräsentieren, unterstützen. Dies ändert nichts daran, dass Zahlen und Strings, die als Zahlen gelesen werden können,
             sehr unterschiedliche Dinge sind.}

Der letzte Ausdruck, @racket["(+ 21 21)"], ist auch eine Sequenz von Zeichen, aber sie ist nicht äquivalent zu
@racket["42"]. Das eine kann also nicht durch das andere ersetzt werden ohne die Bedeutung des Programms zu verändern, wie dieses Beispiel illustriert:

@ex[(string-length "42")]

@ex[(string-length "(+ 21 21)")]

Nun zurück zu unserer Vorstellung der wichtigsten Datentypen.
Ein weiterer wichtiger Datentyp sind Wahrheitswerte (Boolsche Werte). Die einzigen
Konstruktoren hierfür sind die Literale @racket[#true] und @racket[#false]. Funktionen auf boolschen
Werten sind zum Beispiel die aussagenlogischen Funktionen:

@ex[
(and #true #true)
(and #true #false)
(or #true #false)
(or #false #false)
(not #false)]
@margin-note{Kennen Sie den? Frage an die schwangere Informatikerin: Wird es ein Junge oder ein Mädchen? Antwort: Ja!}
Boolsche Werte werden auch häufig von Vergleichsfunktionen zurückgegeben:

@ex[(> 10 9)
(< -1 0)
(= 42 9)
(string=? "hello" "world")
]

Natürlich können Ausdrücke weiterhin beliebig verschachtelt werden, z.B. so:

@margin-note{Beachten Sie in diesem Beispiel wie die Einrückung des Textes
hilft, zu verstehen, welcher Teilausdruck Argument welcher Funktion ist. Probieren
Sie in DrRacket aus, wie die Funktionen "Einrücken" bzw. "Alles einrücken"
im Menü "Racket" die Einrückung ihres Programms verändern.}
@ex[(and (or (= (string-length "hello world") (string->number "11"))
             (string=? "hello world" "good morning"))
         (>= (+ (string-length "hello world") 60) 80))]


Die Auswertung der boolschen Funktionen @racket[and] und @racket[or] funktioniert
etwas anders als die "normaler" Funktionen. Während bei "normalen" Funktionen alle
Argumente ausgewertet werden bevor die Funktion angewendet wird, wird bei
@racket[and] und @racket[or] nur soweit ausgewertet, wie unbedingt nötig. Wir werden
die genaue Semantik und die Gründe dafür später besprechen; an dieser Stelle
geben wir nur einige Beispiele an, die den Unterschied illustrieren.

Kein "Division durch 0" Fehler:
@ex[(and #false (/ 1 0))]
@ex[(or #true (/ 1 0))]

Keine Fehler, dass @racket[42] kein boolscher Wert ist.
@ex[(and #false 42)]
@ex[(or #true 42)]


Der letzte Datentyp den wir heute einführen werden, sind Bilder. In BSL sind
Bilder "ganz normale" Werte, mit dazugehöriger Arithmetik, also Funktionen darauf.
Existierende Bilder können per Copy&Paste oder über das Menü "Einfügen -> Bild" direkt in
das Programm eingefügt werden. Wenn Sie dieses Dokument im Browser betrachten, können Sie
das Bild dieser Rakete @ev[rocket] mit Copy&Paste in ihr Programm einfügen. Genau wie die Auswertung
einer Zahl die Zahl selber ergibt, ergibt die Auswertung des Bilds das Bild selber.

@racket[>] @ev[rocket]

@ev[rocket]

@margin-note{Achten Sie darauf, das Teachpack "image.ss" zu verwenden, das zu HtDP/2e gehört. Es steht im DrRacket-Teachpack-Dialog in der mittleren Spalte.
Alternativ können Sie am Anfang ihrer Datei die Anweisung @racket{(require 2htdp/image)} hinzufügen.}

Wie auf anderen Datentypen sind auch auf Bildern eine Reihe von Funktionen verfügbar.
Diese Funktionen müssen allerdings erst durch das Aktivieren eines "Teachpacks" zu BSL
hinzugefügt werden. Aktivieren Sie in DrRacket das HtDP/2e Teachpack "image.ss", um selber
mit den folgenden Beispielen zu experimentieren.

Beispielsweise kann die Fläche des Bildes durch diesen Ausdruck berechnet werden:

@racket[>] @racket[(* (image-width (unsyntax @ev[rocket]))  (image-height (unsyntax @ev[rocket])))]

@ev[
  (* (image-width rocket)
   (image-height rocket))]

Statt existierende Bilder in das Programm einzufügen kann man auch neue Bilder konstruieren:

@ex[(circle 10 "solid" "red")
    (rectangle 30 20 "solid" "blue")]

@margin-note{@para{Programmieren Sie einen Ausdruck, der mehrere Kreise um denselben Mittelpunkt zeichnet.}
             @para{}
             @para{Programmieren Sie einen Ausdruck, der einen Kreis zeichnet, der durch eine schräge Linie geschnitten
                   wird. Markieren Sie die Schnittpunkte durch kleine Kreise.}}

Die Arithmetik der Bilder umfasst nicht nur Funktionen um Bilder zu konstruieren, sondern auch
um Bilder in verschiedener Weise zu kombinieren:

@ex[(overlay (circle 5 "solid" "red")
             (rectangle 20 20 "solid" "blue"))]


Benutzen Sie die Dokumentation von BSL (z.B. über die Links in der Browser-Version dieses Dokuments) wenn
Sie wissen wollen welche weiteren Funktionen auf Bildern es gibt und welche Parameter diese erwarten.
Zwei wichtige Funktionen die Sie noch kennen sollten sind @racket[empty-scene] und @racket[place-image]. Die erste
erzeugt eine Szene, ein spezielles Rechteck in dem Bilder plaziert werden können.
Die zweite Funktionen setzt ein Bild in eine Szene:

@ex[
(place-image (circle 5 "solid" "green") ; ergibt
             50 80
             (empty-scene 100 100))]

@pdf-note{Quiz: @secref{quiz-types}}

@questionnaire[#:key "types" #:language "de"
  @question[
    @q{Wie nennen wir verschiedene Arten von Werten in der Informatik?}

    @distractor{Kategorien}
    @distractor{Objekte}
    @solution{Datentypen}
  ]
  @question[
    @q{Wie fügt man in BSL zwei Strings zusammen?}

    @solution{@racket[(string-append "zusammen" "setzen")]}
    @distractor{@racket[(+ "zusammen" "setzen")]}
    @distractor{@tt{"zusammen" . "setzen"}}
    @distractor{@racket["zusammen" || "setzen"]}

  ]

  @question[#:type "multiplechoice"
    @q{Wie kann man in BSL eine Zahl in einen String umwandeln, um sie z.B. an einen anderen String anzuhängen?}

    @distractor{@racket[string-append] wandelt seine Argumente automatisch um}
    @solution{Mit @racket[number->string]}
    @distractor{Mit der @racket[print]-Funktion}
  ]

  @question[
    @q{Welchen Datentyp hat das Ergebnis des Ausdrucks @racket[(string=? "Apfel" "Birne")]?}

    @distractor{String}
    @distractor{Zahl}
    @solution{Boolscher Wert (Wahrheitswert)}
  ]
  @question[
    @q{Was ergibt die Auswertung des folgenden Ausdrucks? @racketblock[(or (= 2 (string->number "2")) (> 1 "1"))]}

    @solution{@racket[#true]}
    @distractor{@racket[#false]}
    @distractor{einen Fehler}
    @explanation{Da das erste Argument von @racket[or] bereits wahr ist, wird das zweite Argument nicht ausgewertet und der Fehler tritt nicht auf.}
  ]
  @question[
    @q{Wie kann man mit DrRacket ein Bild in ein BSL-Programm hinzufügen?}

    @solution{Mit Copy&Paste}
    @solution{Über das Menü "Einfügen -> Bild"}
    @distractor{Mithilfe von @racket[load-image]}
  ]
  @question[
    @q{Was ist das Ergebnis des folgenden Ausdrucks?
    @racketblock[(place-image (overlay (circle 50 "solid" "white")
               (circle 55 "solid" "blue")
               (circle 60 "solid" "purple")
               (circle 65 "solid" "red")
               (circle 70 "solid" "orange")
               (circle 75 "solid" "yellow")
               (circle 80 "solid" "green"))
               50 90
               (empty-scene 90 90))]}

    @solution{
      @interaction-eval-show[
      (require 2htdp/image)
      (place-image (overlay (circle 50 "solid" "white")
                 (circle 55 "solid" "blue")
                 (circle 60 "solid" "purple")
                 (circle 65 "solid" "red")
                 (circle 70 "solid" "orange")
                 (circle 75 "solid" "yellow")
                 (circle 80 "solid" "green"))
                 50 90
                 (empty-scene 90 90))]
    }
    @distractor{
      @interaction-eval-show[
      (require 2htdp/image)
      (place-image
                 (circle 80 "solid" "green")
                 50 90
                 (empty-scene 90 90))]
    }
  ]
]


@section{Auftreten und Umgang mit Fehlern}

 Bei der Erstellung und Ausführung von Programmen können unterschiedliche Arten von Fehlern auftreten.
 Außerdem treten Fehler zu unterschiedlichen Zeitpunkten auf.
 Es ist wichtig, die Klassen und Ursachen dieser Fehler zu kennen.

 Programmiersprachen unterscheiden sich darin, zu welchem Zeitpunkt Fehler
 gefunden werden. Die wichtigsten Zeitpunkte, die wir unterscheiden möchten, sind folgende:
 1) @italic{Vor} der Programmausführung (manchmal auch "statische Fehler" genannt), oder 2) @italic{Während}
 der Programmausführung ("dynamische Fehler" oder "Laufzeitfehler"). Im Allgemeinen
 gilt: Je früher desto besser! - allerdings muss diese zusätzliche Sicherheit häufig mit anderen
 Restriktionen erkauft werden, zum Beispiel der, dass einige korrekte Programme nicht
 mehr ausgeführt werden können.

 Eine wichtige Art von Fehlern sind @italic{Syntaxfehler}. Ein Beispiel für ein Programm
 mit einem Syntaxfehler sind die Ausdrücke (+ 2 3(  oder (+ 2 3 oder (+ 2 (+ 3 4).

 Syntaxfehler werden vor der Programmausführung von DrRacket geprüft und gefunden;
 diese Prüfung kann auch mit der Schaltfläche "Syntaxprüfung" veranlasst werden.

 Ein Syntaxfehler tritt auf, wenn ein BSL Programm nicht zur BSL Grammatik passt.
 Später werden wir diese Grammatik genau definieren; informell ist eine Grammatik
 eine Menge von Vorschriften über die Struktur korrekter Programme.

 Die Grammatik von dem Teil von BSL, den sie bereits kennen, ist sehr einfach:
@itemize[
 @item{Ein BSL Programm ist eine Sequenz von Ausdrücken.}
 @item{Ein Ausdruck ist ein Zahlenliteral (wie @racket[123]), ein Bildliteral, @racket[#true] oder @racket[#false], ein Stringliteral (wie @racket["asdf"]), oder ein Funktionsaufruf.}
 @item{Ein Funktionsaufruf hat die Form @racket[(f e1 e2 ...)] wobei @racket[f] ein Name ist und
        @racket[e1],@racket[e2],... Ausdrücke sind.}
 ]

Bei dem Namen @racket[f] im letzten Teil ist es für die Beurteilung der syntaktischen Korrektheit
nicht relevant, ob @racket[f] der Name einer existierenden Funktion ist. Ebenso ist es nicht relevant,
ob die korrekte Anzahl von Argumenten übergeben wurde. Dies sind auch Fehler, aber keine Syntaxfehler.
In Programmiersprachen ist syntaktische Korrektheit eine sogenannte @italic{kontextfreie} Eigenschaft.
Dies bedeutet, dass syntaktische Korrektheit immer "lokal", ohne Berücksichtigung des Kontextes, entschieden
werden kann. Wir werden dies später in der Form sogenannter kontextfreien Grammatiken noch präzisieren.


In BSL werden Syntaxfehler immer @italic{vor} der Programmausführung erkannt.
 Auch einige andere Fehler, wie das Aufrufen einer Funktion, die nicht definiert ist, werden vor der
 Programmausführung erkannt, beispielsweise ein Aufruf @racket[(foo "asdf")]. Dies ist jedoch kein
 Syntaxfehler (es ist leider etwas verwirrend dass diese Fehler dennoch durch Drücken des Knopfs "Check Syntax"
 gefunden werden).

Die folgenden Programme sind alle syntaktisch korrekt, allerdings lassen sich nicht alle diese Programme auswerten:

@interaction[#:eval (bsl-eval)
 (number->string "asdf")
 (string-length "asdf" "fdsa")
 (/ 1 0)
 (string->number "asdf")]


 Nicht jedes syntaktisch korrekte Programm hat in BSL eine Bedeutung. @italic{Bedeutung} heißt in diesem
 Fall dass das Programm korrekt ausgeführt werden kann und einen Wert zurückliefert.
 Die Menge der BSL Programme, die eine Bedeutung haben, ist nur eine @italic{Teilmenge} der syntaktisch
 korrekten BSL Programme.

  Die Ausführung des Programms @racket[(number->string "asdf")] ergibt einen Laufzeitfehler, also ein Fehler der auftritt während
das Programm läuft (im Unterschied zu Syntaxfehlern, die @italic{vor} der Programmausführung erkannt werden).
Wenn in BSL ein Laufzeitfehler auftritt, wird die Programmausführung abgebrochen und eine
 Fehlermeldung ausgegeben.

 Dieser Fehler ist ein Beispiel für einen @italic{Typfehler}: Die Funktion erwartet, dass ein Argument
 einen bestimmten Typ hat, diesem Fall 'Zahl', aber tatsächlich hat das Argument einen anderen
 Typ, in diesem Fall 'String'.

 Ein anderer Fehler, der auftreten kann, ist der, dass die Anzahl der angegebenen Argumente nicht
 zu der Funktion passt (ein @italic{Aritätsfehler}). Im Programm @racket[ (string-length "asdf" "fdsa")] tritt dieser Fehler auf.

 Manchmal stimmt zwar der Datentyp des Arguments, aber trotzdem 'passt' das Argument
 in irgendeiner Weise nicht. Im Beispiel @racket[(/ 1 0)] ist es so, dass die Divisionsfunktion als Argumente
 Zahlen erwartet. Das zweite Argument ist eine Zahl, trotzdem resultiert die Ausführung in einer
 Fehlermeldung, denn die Division durch Null ist nicht definiert.

 Typfehler, Aritätsfehler und viele andere Arten von Fehlern werden erst zur Laufzeit erkannt. Eigentlich wäre
 es viel besser, auch diese Fehler schon vor der Programmausführung zu entdecken.
 @margin-note{Recherchieren Sie, was das Theorem von Rice aussagt.}
 Zwar gibt es Programmiersprachen,
 die mehr Fehlerarten bereits vor der Programmausführung erkennen (insbesondere solche mit sogenanntem
 "statischen Typsystem"), aber es gibt einige fundamentale Grenzen der Berechenbarkeit, die dafür sorgen,
 dass es in jeder ausreichend mächtigen ("Turing-vollständigen") Sprache immer auch Fehler gibt, die erst
 zur Laufzeit gefunden werden.

 Nicht alle Laufzeitfehler führen zu einem Abbruch der Programmausführung.
 Beispielsweise ergibt die Ausführung des Programms @racket[(string->number "asdf")]
 den Wert @racket[#false].
 Dieser Wert signalisiert, dass der übergebene String keine Zahl repräsentiert.
 In diesem Fall tritt also @italic{kein} Laufzeitfehler auf, sondern die Ausführung wird fortgesetzt.
 Der Aufrufer von @racket[(string->number "asdf")] hat dadurch die Möglichkeit, abzufragen, ob die
 Umwandlung erfolgreich war oder nicht, und je nachdem das Programm anders fortzusetzen.
 Das Programm ist also aus BSL-Sicht wohldefiniert. Die Funktion @racket[string->number] hätte alternativ
 aber auch so definiert werden können, dass sie in dieser Situation einen Laufzeitfehler auslöst.

@pdf-note{Quiz: @secref{quiz-errors}}

@questionnaire[#:language "de" #:key "errors"
  @question[
    @q{Welche der folgenden Programme enthalten @italic{Syntaxfehler}?}

    @solution{@tt{(+ 2 (- 44 4)}}
    @distractor{@tt{(string->number 42)}}
    @explanation{Der Datentyp von Argumenten ist nicht Teil der Syntax}
    @distractor{@tt{(string-length "40" "2")}}
    @solution{@tt{-(44, 2)}}
  ]
  @question[
    @q{Wann werden Syntaxfehler erkannt?}

    @solution{Vor der Ausführung des Programms}
    @distractor{Während der Ausführung des Programms}
    @distractor{Nach der Ausführung des Programms}
  ]
  @question[
    @q{Was für einen Fehler enthält das folgende Programm?
    @racketblock[(string->number "40" "2")]}

    @distractor{Typfehler}
    @solution{Aritätsfehler}
    @explanation{Die @italic{Arität} einer Funktion beschreibt, wie viele Argumente sie benötigt.}
    @distractor{Syntaxfehler}
  ]
  @question[
    @q{Gibt es eine Turing-vollständige Programmiersprache, in der keine Laufzeitfehler auftreten können?}

    @distractor{Ja, Haskell}
    @distractor{Ja, alle Sprachen mit statischem Typsystem}
    @solution{Nein, da stoßen wir an fundamentale Grenzen der Berechenbarkeit}
  ]
]


@section{Kommentare}

Ein Programm kann neben dem eigentlichen Programmtext auch Kommentare enthalten.
Kommentare haben keinen Einfluss auf die Bedeutung eines Programms und dienen nur
der besseren Lesbarkeit eines Programms. Insbesondere wenn Programme größer werden
können Kommentare helfen das Programm schneller zu verstehen.
Kommentare werden durch ein Semikolon eingeleitet; alles was in einer Zeile nach einem Semikolon steht ist ein Kommentar.

@#reader scribble/comment-reader
(racketblock
  ;; Berechnet die Goldene Zahl
  (/ (+ 1 (sqrt 5)) 2))

Es kann auch manchmal hilfreich sein, ganze Programme "auszukommentieren".
Programme, welche in Kommentaren enthalten sind werden von DrRacket
ignoriert und nicht ausgewertet.

@#reader scribble/comment-reader
(racketblock
  ;; (/ (+ 1 (sqrt 5)) 2)
  ;; (+ 42
  )

Im obigen Beispiel würde kein Ergebnis ausgegeben werden, da die
Berechnungen in einem Kommentar stehen. Fehlerhafte Teile eines Programms
(wie jenes in der zweiten Kommentarzeile), können auskommentiert werden, um den Rest des
Programms in DrRacket ausführen zu können.

Wir werden später mehr dazu sagen, wo, wie und wie ausführlich Programme kommentiert werden sollten.


@section[#:tag "semanticsofexpressions"]{Bedeutung von BSL Ausdrücken}


 Fassen wir nochmal den jetzigen Stand zusammen: Programmieren ist das Aufschreiben arithmetischer Ausdrücke,
 wobei die Arithmetik Zahlen, Strings, Boolsche Werte und Bilder umfasst. Programme sind syntaktisch
 korrekt wenn Sie gemäß der Regeln aus dem vorherigen Abschnitt konstruiert wurden. Nur syntaktisch
 korrekte Programme (aber nicht alle) haben in BSL eine Bedeutung. Die Bedeutung eines Ausdrucks in BSL
 ist ein Wert, und dieser Wert wird durch folgende Auswertungsvorschriften ermittelt:

@itemize[
 @item{Zahlen, Strings, Bilder und Wahrheitswerte sind Werte. Wir benutzen im Rest dieser Vorschrift Varianten des Buchstaben @v als Platzhalter für  Ausdrücke die Werte sind und Varianten des Buchstaben @e für beliebige Ausdrücke (Merkhilfe: Wert = @italic{v}alue, Ausdruck = @italic{e}xpression).}
 @item{Ist der Ausdruck bereits ein Wert so ist seine Bedeutung dieser Wert.}
 @item{ Hat der Ausdruck die Form @racket[(f (unsyntax @e1) ... (unsyntax @eN))], wobei @racket[f] ein Funktionsname (der nicht @racket[and] oder @racket[or] ist) und @e1,...,@eN  Ausdrücke sind, so wird dieser Ausdruck
                                  wie folgt ausgewertet:
   @itemize[
       @item{Falls @e1,...,@eN  bereits Werte @v1,...,@vN sind und
                   @racket[f] auf  den  Werten @v1,...,@vN definiert ist, so ist der Wert des Ausdrucks die Anwendung von @racket[f] auf @v1,...,@vN }
       @item{Falls @e1,...,@eN bereits Werte @v1,...,@vN sind aber
                   @racket[f] ist @italic{nicht} auf den  Werten @v1,...,@vN definiert, dann wird die Auswertung mit einer passenden Fehlermeldung abgebrochen.}
       @item{Falls mindestens eines der Argumente noch kein Wert ist, so werden durch Anwendung der gleichen Auswertungsvorschriften
             die Werte aller Argumente bestimmt, so dass dann die vorherige Auswertungsregel anwendbar ist.}

          ]}
   @item{Hat der Ausdruck die Form @racket[(and (unsyntax @e1) ... (unsyntax @eN))], so wird wie folgt ausgewertet:
      @itemize[
         @item{Falls eines der @eI den Wert @racket[#false] hat und alle Argumente links davon den Wert @racket[#true], so ist der Wert des gesamten Ausdrucks @racket[#false].}
         @item{Falls alle @eI den Wert @racket[#true] haben, so ist der Wert des gesamten Ausdrucks @racket[#true].}
         @item{Falls eines der @eI ein Wert ist der weder @racket[#false] noch @racket[#true] ist und alle Argumente
           links davon den Wert @racket[#true], dann wird die Auswertung mit einer Fehlermeldung abgebrochen.}
         @item{Falls @eI das am weitesten links stehende Argument ist, welches noch kein Wert ist, so wird durch Anwendung
               der gleichen Auswertungsvorschriten der Wert dieses Arguments bestimmt und dann mit den gleichen Vorschriften die Auswertung fortgesetzt.}]}
  @item{Hat der Ausdruck die Form @racket[(or (unsyntax @e1) ... (unsyntax @eN))], so wird analog zur Auswertung von @racket[and] verfahren. }

]

Diese Vorschriften können wir als Anleitung zur schrittweisen @italic{Reduktion} von Programmen auffassen. Wir schreiben @e @step @(prime e) um zu
sagen, dass @e in einem Schritt zu @(prime e) reduziert werden kann. Werte können nicht reduziert werden. Die Reduktion ist wie folgt definiert:

@margin-note{Experimentieren Sie in DrRacket mit dem "Stepper" Knopf: Geben Sie einen komplexen
Ausdruck in den Definitionsbereich ein, drücken Sie auf "Stepper" und dann auf die "Schritt nach rechts"
Taste und beobachten Sie was passiert.}
   @itemize[
       @item{Falls der Ausdruck die Form @racket[(f (unsyntax @v1) ... (unsyntax @vN))] hat (und @racket[f] nicht @racket[and] oder @racket[or] ist) und
                   die Anwendung von @racket[f] auf @v1,...,@vN den Wert @racket[v] ergibt, dann
                   @racket[(f (unsyntax @v1) ... (unsyntax @vN))]  @step @racket[v].}
       @item{ @racket[(and #false ...)] @step @racket[#false] und  @racket[(and #true ... #true)] @step @racket[#true]. Analog @racket[or].}
       @item{Falls ein Audruck @e1 einen Unterausdruck @e2 in einer @italic{Auswertungsposition} enthält, der reduziert werden kann, also @e2 @step @(prime @e2), dann
       gilt @e1 @step @(prime @e1), wobei @(prime @e1) aus @e1 entsteht indem @e2 durch @(prime @e2) ersetzt wird.}]

Die letzte Regel nennen wir die @italic{Kongruenzregel}. In dem Teil der Sprache, den Sie bereits kennengelernt haben,
sind @italic{alle} Positionen von Unterausdrücken Auswertungspositionen - außer bei den boolschen Funktionen @racket[and] und @racket[or];
bei diesen ist nur der am weitesten links stehende Unterausdruck, der noch kein Wert ist, in Auswertungsposition.
Für Funktionsaufrufe (ungleich @racket[and] und @racket[or]) gilt in diesem Fall folgender Spezialfall der Kongruenzregel: Falls @eI @step @(prime @eI),
dann @racket[(f (unsyntax @e1) ... (unsyntax @eN))] @step @racket[(f (unsyntax @e1) ... (unsyntax @eI-1) (unsyntax @(prime @eI)) (unsyntax @eI+1) ...)].

Wir benutzen folgende Konventionen:

@itemize[
         @item{@e1 @step @e2 @step @e3 ist eine Kurzschreibweise für @e1 @step @e2 und @e2 @step @e3}
         @item{Wenn wir schreiben @e @multistep @(prime @e) so bedeutet dies dass es ein n ≥ 0 und @e1, ...,@eN gibt so dass
                                  @e @step @e1 @step ... @step  @eN @step @(prime @e) gilt. Insbesondere gilt @e @multistep @e .
           Man sagt, @multistep ist der reflexive und transitive Abschluss von @step .}]



Beispiele:

@itemize[
@item{@racket[(+ 1 1)] @step @racket[2].}

@item{@racket[(+ (* 2 3) (* 4 5))] @step @racket[(+ 6 (* 4 5))] @step @racket[(+ 6 20)] @step @racket[26].}

@item{@racket[(+ (* 2 3) (* 4 5))] @step @racket[(+ (* 2 3) 20)] @step @racket[(+ 6 20)] @step @racket[26].}

@item{@racket[(+ (* 2 (+ 1 2)) (* 4 5))] @step @racket[(+ (* 2 3) (* 4 5))].}

@item{@racket[(or #true (and #true #true))] @step @racket[#true], aber nicht @racket[(or #true (and #true #true))] @step @racket[(or #true #true)].}

@item{@racket[(+ (* 2 3) (* 4 5))] @multistep @racket[26] aber nicht @racket[(+ (* 2 3) (* 4 5))] @step @racket[26].}

@item{@racket[(+ 1 1)] @multistep @racket[(+ 1 1)] aber nicht @racket[(+ 1 1)] @step @racket[(+ 1 1)].}

@item{@racket[(overlay (circle 5 "solid" "red")  (rectangle 20 20 "solid" "blue"))] @step @racket[(overlay (unsyntax @ev[(circle 5 "solid" "red")])  (rectangle 20 20 "solid" "blue"))]
       @step @racket[(overlay (unsyntax @ev[(circle 5 "solid" "red")])  (unsyntax @ev[(rectangle 20 20 "solid" "blue")]))]
       @step @ev[(overlay (circle 5 "solid" "red")  (rectangle 20 20 "solid" "blue"))].}

]

Im Allgemeinen kann ein Ausdruck mehrere reduzierbare Unterausdrücke haben, also die Kongruenzregeln an mehreren Stellen gleichzeitig einsetzbar sein.
In den Beispielen oben haben wir zum Beispiel @racket[(+ (* 2 3) (* 4 5))] @step @racket[(+ (* 2 3) 20)] aber auch
@racket[(+ (* 2 3) (* 4 5))] @step @racket[(+ 6 (* 4 5))]. Es ist jedoch nicht schwer zu sehen, dass immer wenn
wir die Situation @e1 @step @e2 und @e1 @step @e3 haben, dann gibt es ein @e4 so dass gilt @e2 @multistep @e4 und @e3 @multistep @e4 .
Diese Eigenschaft nennt man @italic{Konfluenz}. Reduktionen die auseinanderlaufen können also immer wieder zusammengeführt werden;
der Wert den man am Ende erhält ist auf jeden Fall eindeutig.


Auf Basis dieser Reduktionsregeln können wir nun  definieren, unter welchen Umständen zwei Programme äquivalent sind:
Zwei Ausdrücke @e1 und @e2 sind äquivalent, geschrieben @e1 @equiv @e2 , falls es einen Ausdruck @e gibt
so dass @e1 @multistep @e und @e2 @multistep @e .

Beispiele:

@itemize[
@item{@racket[(+ 1 1)] @equiv @racket[2].}

@item{@racket[(+ (* 2 3) 20)]  @equiv @racket[(+ 6 (* 4 5))] @equiv @racket[26].}

@item{ @racket[(overlay (unsyntax @ev[(circle 5 "solid" "red")])  (rectangle 20 20 "solid" "blue"))]
       @equiv @racket[(overlay (circle 5 "solid" "red") (unsyntax @ev[(rectangle 20 20 "solid" "blue")]))].}

]

Die Rechtfertigung für diese Definition liegt in folgender wichtiger Eigenschaft begründet: Wir können innerhalb eines großen Programms Teilausdrücke beliebig durch äquivalente Teilausdrücke ersetzen, ohne die Bedeutung des Gesamtprogramms zu verändern. Etwas formaler können wir das so ausdrücken:

Sei @e1 ein Unterausdruck eines größeren Ausdrucks @e2 und @e1 @equiv @e3 . Ferner sei @(prime @e2) eine Kopie von @e2 in dem Vorkommen von @e1 durch @e3 ersetzt wurden. Dann gilt: @e2 @equiv @(prime @e2).

Diese Eigenschaft folgt direkt aus der Kongruenzregel und der Definition von @equiv . Dieser Äquivalenzbegriff ist identisch mit dem, den Sie aus der Schulmathematik kennen, wenn Sie Gleichungen umformen, zum Beispiel wenn wir a + a - b umformen zu 2a - b weil wir wissen dass a + a = 2a.

Die Benutzung von @equiv um zu zeigen dass Programme die gleiche Bedeutung haben nennt man auch @italic{equational reasoning}.
