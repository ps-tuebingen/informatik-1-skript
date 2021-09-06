#lang scribble/manual
@(require scribble/eval)
@(require scribble/core)
@(require "marburg-utils.rkt")
@(require (for-label lang/htdp-intermediate-lambda))
@(require (for-label (except-in 2htdp/image image?)))
@(require (for-label 2htdp/universe))
@(require scribble/bnf)
@(require scribble/decode
          scribble/html-properties
          scribble/latex-properties)
@(require scriblib/footnote)
   
@(define inbox-style
    (make-style "inbox"
                (list (make-css-addition "inbox.css")
                      (make-tex-addition "inbox.tex"))))

@title[#:version ""]{Bedeutung von ISL+}

In diesem Kapitel werden wir die im Vergleich zur letzten formalen Sprachdefinition aus @secref{bsl-semantics}
neu hinzugekommen Sprachfeatures präzise definieren. Unsere Methodik bleibt die gleiche. Wir definieren
zunächst die Semantik einer Kern-Sprache, die alle wesentlichen Sprachmerkmale enthält. Dann definieren wir
eine Auswertungsregel für Programme und Definitionen sowie eine Reduktionsrelation @step, mit der Programme
Schritt für Schritt ausgewertet werden können.

@section{Syntax von Core-ISL+}

@(define open (litchar "("))
@(define close (litchar ")"))
@(define lb (litchar "["))
@(define rb (litchar "]"))

@(define (mv s)
       (make-element #f  (list (make-element 'italic s))))


Die beiden neu hinzugekommenen Sprachfeatures in ISL sind 1) lokale Definitionen und 2) die Möglichkeit, 
Funktionen als Werte zu betrachten. Um die Definitionen möglichst einfach zu halten, werden wir
zunächst mal Sprachfeatures entfernen, die wir bereits in @secref{bsl-semantics} präzise definiert haben
und die durch die Hinzunahme der neuen Features nicht beeinflusst werden: Strukturdefinitionen (@racket[define-struct]),
konditionale Ausdrücke (@racket[cond]) und logische Operatoren (@racket[and]).

Desweiteren ergeben sich durch die uniforme Behandlung von Funktionen und Werten noch weitere Vereinfachungsmöglichkeiten.
Es ist nicht nötig, Konstantendefinitionen und Funktionsdefinitionen zu unterstützen, denn jede Funktionsdefinition
@racket[(define (f x) e)] kann durch eine Konstantendefinition @racket[(define f (lambda (x) e))] ausgedrückt werden.
Insgesamt ergibt sich damit folgende Syntax für die Kernsprache:

@BNF[(list @nonterm{definition} 
         @BNF-seq[open @litchar{define} @nonterm{name} @nonterm{e} close])
         
     (list @nonterm{e}
         @BNF-seq[open @nonterm{e} @kleeneplus[@nonterm{e}] close]
         @BNF-seq[open @litchar{local} lb @kleeneplus[@nonterm{definition}] rb @nonterm{e} close]
         @nonterm{name}
         @nonterm{v}
         )
     (list @nonterm{v}
         @BNF-seq[open @litchar{lambda} open @kleeneplus[@nonterm{name}] close @nonterm{e} close]
         @nonterm{number}
         @nonterm{boolean}
         @nonterm{string}
         @nonterm{image}
         @nonterm{+}
         @nonterm{*}
         @nonterm{...})]          ]

     
@section[#:tag "isl-env"]{Werte und Umgebungen}
Auch in ISL findet die Auswertung von Programmen immer in einer Umgebung statt. Da es in der Kernsprache
keine Struktur- und Funktionsdefinitionen mehr gibt, ist eine Umgebung nun nur noch eine Sequenz von Konstantendefinitionen.

@BNF[(list @nonterm{env}
         @kleenestar[@nonterm{env-element}])
      (list @nonterm{env-element}
         @BNF-seq[open @litchar{define} @nonterm{name} @nonterm{v} close])]
         

@section[#:tag "isl-prog"]{Bedeutung von Programmen}

Die @italic{(PROG)} Regel aus @secref{semanticsbsl} bleibt für ISL nahezu unverändert erhalten (ohne die
Teile für die Auswertung von Struktur- und Funktionsdefinitionen):
                                                      
@elem[#:style inbox-style]{
@italic{(PROG): }Ein Programm wird von links nach rechts ausgeführt und startet mit der leeren Umgebung. 
Ist das nächste Programmelement
ein Ausdruck, so wird dieser gemäß der unten stehenden Regeln in der aktuellen Umgebung zu einem Wert ausgewert. Ist das nächste Programmelement 
eine Konstantendefinition @racket[(define x e)], so wird, sofern @racket[e] nicht bereits ein Wert ist, in der aktuellen Umgebung zunächst @racket[e] zu einem Wert @racket[v] ausgewertet und dann
@racket[(define x v)] zur aktuellen Umgebung hinzugefügt (indem es an das Ende der Umgebung angehängt wird).}

Allerdings gibt es einen wichtigen Unterschied, nämlich den, dass sich durch die unten stehende @italic{(LOCAL)} Regel der Rest des noch auszuwertenden Programms
während der Auswertung ändern kann.


@section[#:tag "isl-cong"]{Auswertungspositionen und die Kongruenzregel}

Der Auswertungskontext legt fest, dass Funktionsaufrufe von links nach rechts ausgewertet werden,
wobei im Unterschied zu BSL nun auch die aufzurufende Funktion ein Ausdruck ist, der ausgewertet
werden muss.
@BNF[(list @nonterm{E} 
      @litchar{[]}
      @BNF-seq[open @kleenestar[@nonterm{v}] @nonterm{E} @kleenestar[@nonterm{e}]  close]
)]

Die Standard Kongruenzregel gilt auch in ISL.

@elem[#:style inbox-style]{
@italic{(KONG): }Falls @mv{e-1} @step @mv{e-2}, dann @mv{E[e-1]} @step @mv{E[e-2]}.
}      

@section[#:tag "isl-expr"]{Bedeutung von Ausdrücken}


@subsection[#:tag "isl-func"]{Bedeutung von Funktionsaufrufen}
Die Auswertung von Funktionsaufrufen ändert sich dadurch, dass sich die Funktion, die aufgerufen wird,
sich im Allgemeinen erst während der Funktionsauswertung ergibt.

@elem[#:style inbox-style]{
@italic{(APP): }
 @BNF-seq[open open @litchar{lambda} open @mv{name-1} "..." @mv{name-n} close @mv{e} close @mv{v-1} "..." @mv{v-n} close] 
 @step 
 @mv{e}[@mv{name-1} := @mv{v-1} ... @mv{name-n} := @mv{v-n}]}

Die Ersetzung der formalen Argumente durch die tatsächlichen Argumente in dieser Regel ist komplexer als es zunächst den
Anschein hat. Insbesondere darf ein Name wie @mv{name-1} nicht durch @mv{v-1} ersetzt werden, wenn @mv{name-1} in einem 
Kontext vorkommt, in dem es eine lexikalisch nähere andere Bindung (durch @racket[lambda] oder @racket[local]) von @mv{name-1} gibt.
Beispiel: @racket[((lambda (x) (+ x 1)) x)][x := 7] = @racket[((lambda (x) (+ x 1)) 7)] und nicht @racket[((lambda (x) (+ 7 1)) 7)].
Wir werden hierauf in unserer Diskussion zu Scope in @secref{isl-scoping} zurückkommen.

@elem[#:style inbox-style]{
@italic{(PRIM): }Falls @mv{v} eine primitive Funktion @mv{f} ist und @italic{f(v-1,...,v-n)=w}, @linebreak[]
dann @BNF-seq[open @mv{v} @mv{v-1} "..." @mv{v-n} close] @step @mv{w}. 
}

Auch primitive Funktionen können das Resultat von Berechnungen sein; beispielsweise hängt im Ausdruck
@racket[((if cond + *) 3 4)] die Funktion, die verwendet wird, vom Wahrheitswert des Ausdrucks @racket[cond] ab.

@subsection[#:tag "isl-local"]{Bedeutung von lokalen Definitionen}
Die komplexeste Regel ist die zur Bedeutung von lokalen Definitionen. Sie verwendet einen wie oben definierten
Auswertungskontext @mv{E} um aus lokalen Definitionen globale Definitionen zu machen. Um Namenskollisionen zu
vermeiden, werden lokale Definitionen ggf. umbenannt. Abhängigkeiten von lokalen Definitionen vom lokalen Kontext
(zum Beispiel einem Funktionsargument) wurden ggf. durch vorhergehende Substitutionen beseitigt.

@elem[#:style inbox-style]{
@italic{(LOCAL): } @mv{E}[@BNF-seq[open @litchar{local} lb   open @litchar{define} @mv{name-1} @mv{e-1} close 
                                                    "..."
                                                    open @litchar{define} @mv{name-n} @mv{e-n} close
                                                    rb @mv{e} close]]
                               @step 
  @BNF-seq[open @litchar{define} @mv{name-1'} @mv{e-1'} close "..."  open @litchar{define} @mv{name-n'} @mv{e-n'} close] @mv{E}[@mv{e'}]
  wobei @mv{name-1'},...,@mv{name-n'} "frische" Namen sind die sonst nirgendwo im Programm vorkommen und
  @mv{e'},@mv{e-1'},...,@mv{e-n'} Kopien von @mv{e}, @mv{e-1},...,@mv{e-n'} sind, in denen alle Vorkommen von 
  @mv{name-1},...,@mv{name-n} durch @mv{name-1'},...,@mv{name-n'} ersetzt werden. }                                                               

Die grammatikalisch nicht ganz korrekte Notation @BNF-seq[open @litchar{define} @mv{name-1'} @mv{e-1'} close "..."  open @litchar{define} @mv{name-n'} @mv{e-n'} close] @mv{E}[@mv{e'}]
soll hierbei bedeuten, dass @mv{E}[@BNF-seq[open @litchar{local} "..." @mv{e} close]] ersetzt wird durch  
@mv{E}[@mv{e}] und gleichzeitig die Definitionen @BNF-seq[open @litchar{define} @mv{name-1'} @mv{e-1'} close "..."  open @litchar{define} @mv{name-n'} @mv{e-n'} close]
als nächste mittels @italic{(PROG)} auszuwertende Definition in das Programm aufgenommen werden.

Beispiel:

@racketblock[
(define f (lambda (x)
            (+ 2 
               (local 
                 [(define y (+ x 1))]
                 (* y 2)))))
(f 2)]

Dann 

@racketblock[(f 2)] 

@step 

@racketblock[
(+ 2
   (local
     [(define y (+ 2 1))]
     (* y 2)))]

@step 

@racketblock[
(define y_0 (+ 2 1))
(+ 2 (* y_0 2))
]

In diesem zweiten Schritt wurde die @italic{(LOCAL)} verwendet, um aus der lokalen Definition eine globale Definition
zu machen. Die Abhängkeit vom lokalen Kontext (nämlich dem Funktionsargument @racket[x]) wurde zuvor im ersten Schritt durch 
eine Verwendung der @italic{(APP)} Regel beseitigt. Die Auswertung setzt sich nun durch Verwendung der @italic{(PROG)} 
fort, also wir werten durch @racket[(+ 2 1)] @step @racket[3] die Konstantendefinition aus, fügen 
@racket[(define y_0 3)] zur Umgebung hinzu, und werten nun in dieser Umgebung @racket[(+ 2 (* y_0 2))] zum Ergebnis @racket[8] aus. 

@subsection[#:tag "isl-const"]{Bedeutung von Konstanten}
Die Definition von Konstanten ist gegenüber BSL unverändert. 

@elem[#:style inbox-style]{@italic{(CONST): } @mv{name} @step @mv{v}, falls @BNF-seq[open @litchar{define} @mv{name} @mv{v} close]
die letzte Definition von @mv{name} in @mv{env} ist.}

@section[#:tag "isl-scoping"]{Scope}
Wir wollen unter der Berücksichtigung der lokalen Definitionen nochmal die Diskussion über Scope aus @secref{scope-local} aufgreifen und 
diskutieren, wie die formale Definition lexikalisches Scoping garantiert. Lexikalisches Scoping ist in zwei der Regeln oben sichtbar:
@italic{(APP)} und @italic{(LOCAL)}.

In @italic{(LOCAL)} findet eine Umbenennung statt: Der Name von lokalen Konstanten wird umbenannt und alle Verwendungen des Namens 
in den Unterausdrücken des @racket[local] Ausdrucks werden ebenfalls umbenannt. Dadurch, dass diese Umbenennung genau in den Unterausdrücken
vollzogen wird, wird lexikalisches Scoping sichergestellt. Dadurch, dass ein "frischer" Name verwendet wird, kann keine Benutzung des Namens
ausserhalb dieser Unterausdrücke an die umbenannte Definition gebunden werden.

Das gleiche Verhalten findet sich in @italic{(APP)}: Dadurch, dass die formalen Parameter nur im Body der Funktion durch die aktuellen 
Argumente ersetzt werden, wird lexikalisches Scoping sichergestellt. Gleichzeitig wird hierdurch definiert, wie Closures repräsentiert werden,
nämlich als Funktionsdefinitionen, in denen die "weiter aussen" gebundenen Namen bereits durch Werte ersetzt wurden.

Beispiel: Der Ausdruck @racket[(f 3)] in diesem Programm 

@racketblock[
(define (f x)
  (lambda (y) (+ x y)))
(f 3)]

wird reduziert zu @racket[(lambda (y) (+ 3 y))]; der Wert für @racket[x] wird also im Closure mit gespeichert.

Ein wichtiger Aspekt von lexikalischem Scoping ist @italic{Shadowing}. Shadowing ist eine Strategie, mit der Situation umzugehen, dass gleichzeitig
mehrere Definitionen eines Namens im Scope sind.

Beispiel:
@racketblock[
(define x 1)
(define (f x)
  (+ x (local [(define x 2)] (+ x 1))))]

In diesem Beispiel gibt es drei @italic{bindende} Vorkommen von @racket[x] und zwei @italic{gebundene} Vorkommen von @racket[x].
Das linke Vorkommen von @racket[x] in der letzten Zeile des Beispiels ist im lexikalischen Scope von zwei der drei Definitionen;
das rechte Vorkommen von @racket[x] ist sogar im lexikalischen Scope aller drei Definitionen.

Shadowing besagt, dass in solchen Situationen stets die lexikalisch "nächste" Definition "gewinnt". Mit "nächste" ist die Definition gemeint,
die man als erstes antrifft, wenn man in der grammatikalischen Struktur des Programmtextes von dem Namen nach außen geht.
Die weiter innen stehenden Definitionen überdecken also die weiter außen stehenden Definitionen: Sie werfen einen Schatten ("shadow"), in dem
die aussen stehende Definition nicht sichtbar ist. Daher wird in dem Beispiel oben beispielsweise
der Ausdruck @racket[(f 3)] zu @racket[6] ausgewertet.

Shadowing rechtfertigt sich aus einer Modularitätsüberlegung: Die Bedeutung eines Ausdrucks sollte möglichst lokal ablesbar sein. Insbesondere
sollte ein Ausdruck, der keine ungebundenen Namen enthält (ein sogenannter "geschlossener" Term), überall die gleiche Bedeutung haben, egal wo man
ihn einsetzt. Beispielsweise sollte der Ausdruck @racket[(lambda (x) x)] immer die Identitätsfunktion sein und nicht beispielsweise die konstante @racket[3] 
Funktion nur weil weiter außen irgendwo @racket[(define x 3)] steht. Dieses erwünschte Verhalten kann nur durch lexikalisches Scoping mit Shadowing 
garantiert werden.

Programmiersprachen, die es erlauben, lokal Namen zu definieren und lexikalisches Scoping mit Shadowing verwenden, nennt man auch Programmiersprachen mit @italic{Blockstruktur}.
Blockstruktur war eine der großen Innovationen in der Programmiersprache ALGOL 60. Die meisten modernen Programmiersprachen heute haben Blockstruktur.