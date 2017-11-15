**Gas Simulation**

**Vorrausetzungen**

1. Implmentieren der Funktionen
    1. Bachelor_simulate
    2. Bachelor_validateCombined
    3. Bachelor_validateAttributeBool
    4. Bachelor_getBetriebsmittelValidate
    5. Bachelor_getBetriebsmittel
2. Installieren des Plug-Ins
    1. Kopieren des Plug-Ins in den entsprechenden Ordner (z.B.: "Z:\Users\mancuso\.qgis2\python\plugins")
    2. Bearbeiten der .py Datei um die Datenbankverbindung herzustellen
3. Aufbereiten der Daten
    Falls noch nicht vorhanden, müssen die Münchener Daten importiert werden. Ein entsprechendes Skript liegt anbei.
    Lohnenswert ist es sich einen Bereich zu bestimmen, in dem man zwei Absperrarmaturen schließt, sodass ein geschlossener Bereich entsteht. 

    Empfehlenswert sind hier die nodes:

    1. 437082429
    2. 11865607

**Handhabung**

- Starte QGIS
- Füge den node Layer und den edge_data Layer hinzu
- Selektieren auf dem node Layer einen Startpunkt und starte das Plug-In anhand des Icons
- Gib einen Namen für den neuen temporären Layer ein und fülle entsprechend die anderen Felder
- Selektiere den edge_data Layer und drücke auf OK. Alle betroffenen edges werden automatisch selektiert. Je nach Anzahl der Elemente, kann dies Zeit in Anspruch nehmen.


**Elemente**

- 100     4s
- 4400    3,5 Minuten
- 14000   10 Minuten
