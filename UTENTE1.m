%% Pulizia dell'ambiente di lavoro

% Elimino tutte le variabili presenti nel Workspace
% Chiudo tutte le figure eventualmente aperte
% Pulisco la Command Window
clear all
close all
clc;

%% Definizione degli elettrodomestici e delle cartelle

% Elenco dei nomi utilizzati all'interno della struttura MATLAB

Elettrodomestici = ["lavatrice", "lavastoviglie", "frigo", "asciugatrice", "hvac1", "hvac2", "aggregato"];

% Elenco delle cartelle reali associate ai diversi segnali

Cartelle = ["segnale lavatrice", "segnale lavastoviglie", ...
            "segnale frigo", "segnale asciugatrice", ...
            "segnale hvac 1", "segnale hvac 2", "segnale aggregato"];

%% Inizializzazione della struttura dati

% Creo una struttura vuota che conterrà

% una tabella per ogni elettrodomestico

dati = struct();

%% Lettura e organizzazione automatica dei file CSV

% Scorro tutti gli elettrodomestici presenti nell'elenco

for e = 1:length(Elettrodomestici)

    % Recupero il nome dell'elettrodomestico corrente

    nome = Elettrodomestici(e);

    % Recupero la cartella associata

    cartella = Cartelle(e);

    % Cerco tutti i file CSV presenti nella cartella corrente

    files = dir(fullfile(cartella, "*.csv"));

    % Inizializzo una tabella vuota che conterrà

    % progressivamente tutti i dati dell'elettrodomestico

    TT = table();

    % Scorro tutti i file CSV trovati nella cartella

    for i = 1:length(files)

        % Costruisco il percorso completo del file corrente

        percorsoFile = fullfile(cartella, files(i).name);

        % Leggo il contenuto del file CSV

        % specificando il punto e virgola come delimitatore

        T = readtable(percorsoFile, "Delimiter", ";");

        % Converto la colonna timestamp da testo

        % a variabile temporale di tipo datetime

        T.Timestamp = datetime( T.timestamp, ...
                                "InputFormat", ...
                                "yyyy-MM-dd'T'HH:mm:ss'Z'", ...
                                "TimeZone", ...
                                "UTC");

        % Estraggo la sola data dal timestamp completo

        T.Data = dateshift(T.Timestamp, "start", "day");

        % Estraggo il solo orario dal timestamp completo

        T.Ora = timeofday(T.Timestamp);

        % Mantengo solamente le colonne di interesse

        % e le dispongo nell'ordine desiderato

        T = T(:, ["Timestamp", "Data", "Ora", "P"]);

        % Accodo verticalmente i dati del file corrente

        % alla tabella totale dell'elettrodomestico

        TT = [TT; T];

    end

    % Salvo la tabella completa all'interno

    % del campo corrispondente della struttura dati

    dati.(nome) = TT;

end

%% Verifiche preliminari sulla struttura dati

% Visualizzo gli elettrodomestici caricati nella struct
disp(fieldnames(dati))

% Controllo le prime righe della tabella lavatrice
head(dati.lavatrice)

% Controllo le dimensioni delle tabelle
disp(height(dati.lavatrice))
disp(height(dati.asciugatrice))
disp(height(dati.lavastoviglie))
disp(height(dati.hvac1))
disp(height(dati.hvac2))
disp(height(dati.frigo))
disp(height(dati.aggregato))

% Controllo i nomi delle colonne
disp(dati.lavatrice.Properties.VariableNames)

% Controllo il tipo delle variabili
varfun(@class, dati.lavatrice)
varfun(@class, dati.asciugatrice)
varfun(@class, dati.lavastoviglie)
varfun(@class, dati.hvac1)
varfun(@class, dati.hvac2)
varfun(@class, dati.frigo)
varfun(@class, dati.aggregato)

% Controllo prima e ultima data disponibile
disp("Lavatrice:")
disp(min(dati.lavatrice.Timestamp))
disp(max(dati.lavatrice.Timestamp))
disp("Asciugatrice:")
disp(min(dati.asciugatrice.Timestamp))
disp(max(dati.asciugatrice.Timestamp))
disp("Lavastoviglie:")
disp(min(dati.lavastoviglie.Timestamp))
disp(max(dati.lavastoviglie.Timestamp))
disp("HVAC 1:")
disp(min(dati.hvac1.Timestamp))
disp(max(dati.hvac1.Timestamp))
disp("HVAC 2:")
disp(min(dati.hvac2.Timestamp))
disp(max(dati.hvac2.Timestamp))
disp("FRIGO:")
disp(min(dati.frigo.Timestamp))
disp(max(dati.frigo.Timestamp))
disp("Aggregato:")
disp(min(dati.aggregato.Timestamp))
disp(max(dati.aggregato.Timestamp))

%% Verifica del passo temporale e della frequenza di campionamento

% Estraggo i nomi dei segnali presenti nella struttura dati
nomiSegnali = fieldnames(dati);

% Scorro tutti i segnali disponibili
for i = 1:length(nomiSegnali)

    % Recupero il nome del segnale corrente
    nome = nomiSegnali{i};

    % Estraggo la tabella associata
    T = dati.(nome);

    % Ordino cronologicamente i campioni
    T = sortrows(T, "Timestamp");

    % Calcolo la distanza temporale
    % tra campioni consecutivi
    deltaT = seconds(diff(T.Timestamp));

    % Elimino eventuali differenze
    % nulle, negative o non valide
    deltaT = deltaT( isfinite(deltaT) & deltaT > 0);

    % Calcolo il passo temporale tipico
    % utilizzando la mediana,
    % meno influenzata dalla presenza di gap
    passoMediano = median(deltaT);

    % Calcolo la frequenza di campionamento equivalente
    frequenzaCampionamento = 1 / passoMediano;

    % Visualizzo i risultati
    fprintf("\n%s\n", upper(nome));

    fprintf( "Passo temporale mediano: %.3f s\n", ...
        passoMediano);

    fprintf( "Frequenza di campionamento equivalente: %.5f Hz\n", ...
        frequenzaCampionamento);

end

%% Analisi della regolarità temporale dei campioni

nomiSegnali = fieldnames(dati);

for i = 1:length(nomiSegnali)

    nome = nomiSegnali{i};

    T = sortrows(dati.(nome), "Timestamp");

    deltaT = seconds(diff(T.Timestamp));

    deltaT = deltaT(isfinite(deltaT) & deltaT > 0);

    fprintf("\n%s\n", upper(nome));

    fprintf("Minimo: %.2f s\n", min(deltaT));

    fprintf("25° percentile: %.2f s\n", prctile(deltaT,25));

    fprintf("Mediana: %.2f s\n", median(deltaT));

    fprintf("75° percentile: %.2f s\n", prctile(deltaT,75));

    fprintf("90° percentile: %.2f s\n", prctile(deltaT,90));

end

%% Caratterizzazione preliminare dei segnali di potenza

% Estraggo i nomi di tutti gli elettrodomestici
% presenti come campi nella struttura dati
Elettrodomestici = fieldnames(dati);

% Scorro tutti gli elettrodomestici presenti
for e = 1:length(Elettrodomestici)

    % Recupero il nome dell'elettrodomestico corrente
    nome = Elettrodomestici{e};

    % Estraggo dalla struttura dati
    % la tabella relativa al dispositivo corrente
    T = dati.(nome);

    % Ordino cronologicamente i campioni
    T = sortrows(T, "Timestamp");


    %% Calcolo delle statistiche preliminari

    % Numero totale di campioni
    campioni = height(T);

    % Prima data disponibile
    dataInizio = min(T.Timestamp);

    % Ultima data disponibile
    dataFine = max(T.Timestamp);

    % Numero di giorni distinti
    giorni = length(unique(T.Data));

    % Potenza minima
    Pmin = min(T.P);

    % Potenza media
    Pmedia = mean(T.P);

    % Deviazione standard della potenza
    Pstd = std(T.P);

    % Potenza massima
    Pmax = max(T.P);


    %% Calcolo della percentuale di campioni nulli

    % Numero di campioni con potenza nulla
    numeroCampioniNulli = sum(T.P == 0);

    % Percentuale di campioni nulli
    percentualeCampioniNulli = 100 * numeroCampioniNulli / campioni;


    %% Creazione della figura

    figure( "Name", ...
        "Caratterizzazione preliminare - " + nome, ...
        "NumberTitle", "off")

    % Creo quattro riquadri verticali:
    %
    % 1) statistiche
    % 2) andamento temporale
    % 3) distribuzione completa
    % 4) distribuzione senza valori nulli
    tiledlayout(4, 1)


    %% Riquadro 1 - Statistiche descrittive

    nexttile

    % Nascondo gli assi
    axis off

    % Creo il testo contenente
    % le principali statistiche del segnale
    testo = {

        "Elettrodomestico: " + nome

        "Numero campioni: " + string(campioni)

        "Giorni disponibili: " + string(giorni)

        "Data iniziale: " + string(dataInizio)

        "Data finale: " + string(dataFine)

        "Potenza minima: " + string(Pmin) + " W"

        "Potenza media: " + string(Pmedia) + " W"

        "Deviazione standard: " + string(Pstd) + " W"

        "Potenza massima: " + string(Pmax) + " W"

        "Campioni nulli: " + string(numeroCampioniNulli) + ...
            " (" + sprintf("%.2f", percentualeCampioniNulli) + "%)"

        };

    % Visualizzo le statistiche
    text( 0, 0.5, testo, "FontSize", 10)


    %% Riquadro 2 - Andamento temporale della potenza

    nexttile

    plot( T.Timestamp, T.P, "LineWidth", 1)

    grid on

    xlabel("Tempo")

    ylabel("Potenza attiva [W]")

    title( "Andamento della potenza - " + nome)


    %% Riquadro 3 - Distribuzione completa della potenza

    nexttile

    histogram(T.P)

    grid on

    xlabel("Potenza attiva [W]")

    ylabel("Numero di campioni")

    title( "Distribuzione della potenza - " + nome)


    %% Riquadro 4 - Distribuzione senza valori nulli

    % Estraggo solamente i campioni
    % caratterizzati da potenza maggiore di zero
    potenzaNonNulla = T.P(T.P > 0);

    nexttile

    % Verifico che esistano valori non nulli
    if ~isempty(potenzaNonNulla)

        histogram(potenzaNonNulla)

        grid on

        xlabel("Potenza attiva [W]")

        ylabel("Numero di campioni")

        title( "Distribuzione della potenza senza valori nulli - " + ...
            nome)

    else

        % Caso in cui tutti i campioni
        % abbiano potenza nulla
        axis off

        text(   0.5, 0.5, ...
                "Nessun campione con P > 0 W", ...
                "HorizontalAlignment", ...
                "center")

    end

    %% Zoom dell'andamento temporale della potenza

% Intervallo comune di due mesi
% scelto per osservare tutti i dispositivi
inizioZoom = datetime( ...
    2024, 7, 1, 0, 0, 0, ...
    "TimeZone", "UTC");

fineZoom = datetime( ...
    2024, 9, 1, 0, 0, 0, ...
    "TimeZone", "UTC");

% Individuo i campioni appartenenti
% all'intervallo temporale selezionato
righeZoom = ...
    T.Timestamp >= inizioZoom & ...
    T.Timestamp < fineZoom;

% Estraggo i dati del periodo scelto
Tzoom = T(righeZoom, :);

% Creo una figura larga e poco alta
figure( ...
    "Name", ...
    "Zoom andamento potenza - " + nome, ...
    "NumberTitle", ...
    "off", ...
    "Position", ...
    [100 300 1400 400])

% Rappresento l'andamento della potenza
plot( ...
    Tzoom.Timestamp, ...
    Tzoom.P, ...
    "LineWidth", ...
    1)

grid on

xlabel("Tempo")

ylabel("Potenza attiva [W]")

title( ...
    "Andamento della potenza - " + ...
    nome + ...
    " - luglio-agosto 2024")

end

%% Individuazione dei giorni comuni

% Inizializzo una struttura vuota che conterrà

% l'elenco dei giorni comuni e i dati filtrati

Comuni = struct();

% Estraggo i nomi di tutti gli elettrodomestici

% presenti nella struttura dati

Elettrodomestici = fieldnames(dati);

% Utilizzo i giorni del primo elettrodomestico

% come insieme iniziale di riferimento

giorniComuni = unique(dati.(Elettrodomestici{1}).Data);

% Scorro tutti gli elettrodomestici successivi al primo

for e = 2:length(Elettrodomestici)

    % Recupero il nome dell'elettrodomestico corrente

    nome = Elettrodomestici{e};

    % Estraggo l'elenco dei giorni distinti

    % presenti nel segnale corrente

    giorniCorrenti = unique(dati.(nome).Data);

    % Mantengo solamente i giorni presenti

    % sia nell'elenco precedente sia nel segnale corrente

    giorniComuni = intersect(giorniComuni, giorniCorrenti);

end

% Salvo l'elenco finale dei giorni comuni

% all'interno della struttura Comuni

Comuni.giorni = giorniComuni;

%% Creazione della struttura con i soli giorni comuni

% Inizializzo una struttura vuota che conterrà

% i dati filtrati di ciascun elettrodomestico

Comuni.dati = struct();

% Scorro tutti gli elettrodomestici

for e = 1:length(Elettrodomestici)

    % Recupero il nome dell'elettrodomestico corrente

    nome = Elettrodomestici{e};

    % Estraggo la tabella completa

    % dell'elettrodomestico corrente

    T = dati.(nome);

    % Individuo le righe la cui data

    % appartiene all'elenco dei giorni comuni

    righeComuni = ismember(T.Data, Comuni.giorni);

    % Salvo nella nuova struttura solamente

    % le righe appartenenti ai giorni comuni

    Comuni.dati.(nome) = T(righeComuni, :);

end

%% Campo di test della nuova struttura

% Visualizzo i campi principali

% presenti nella struttura Comuni

fieldnames(Comuni)

% Visualizzo gli elettrodomestici

% presenti nella sottostruttura Comuni.dati

fieldnames(Comuni.dati)

% Visualizzo il numero totale di giorni comuni

length(Comuni.giorni)

%% Soglie preliminari di attivazione [W]

% Inizializzo una struttura vuota

% che conterrà la soglia di ciascun elettrodomestico

Soglie = struct();

% Definisco la soglia preliminare della lavatrice

Soglie.lavatrice = 30;

% Definisco la soglia preliminare della lavastoviglie

Soglie.lavastoviglie = 30;

% Definisco la soglia preliminare dell'asciugatrice

Soglie.asciugatrice = 30;

% Definisco la soglia preliminare del primo climatizzatore

Soglie.hvac1 = 120;

% Definisco la soglia preliminare del secondo climatizzatore

Soglie.hvac2 = 120;

% Definisco la soglia preliminare del frigorifero;

% sopra tale valore il compressore viene considerato attivo

Soglie.frigo = 30;

%% Aggiunta della colonna Attivo

% Estraggo i nomi degli elettrodomestici

% per i quali è stata definita una soglia

ElettrodomesticiConSoglia = fieldnames(Soglie);

% Scorro tutti gli elettrodomestici dotati di soglia

for e = 1:length(ElettrodomesticiConSoglia)

    % Recupero il nome dell'elettrodomestico corrente

    nome = ElettrodomesticiConSoglia{e};

    % Recupero il valore della soglia

    % associata all'elettrodomestico corrente

    sogliaCorrente = Soglie.(nome);

    % Confronto ogni valore di potenza con la soglia

    % e salvo il risultato in una nuova colonna logica

    dati.(nome).Attivo = dati.(nome).P > sogliaCorrente;

end

%% Creazione dello stato definitivo

% Definisco la durata massima di una breve pausa
% che può essere ricongiunta allo stesso evento.
%
% I valori possono essere successivamente affinati
% osservando i segnali dei singoli dispositivi.

SogliaPausa.lavatrice = minutes(5);
SogliaPausa.lavastoviglie = minutes(5);
SogliaPausa.asciugatrice = minutes(5);
SogliaPausa.hvac1 = minutes(5);
SogliaPausa.hvac2 = minutes(5);
SogliaPausa.frigo = minutes(2);

% Estraggo i dispositivi analizzati
nomiDispositivi = fieldnames(Soglie);

% Scorro tutti i dispositivi
for e = 1:length(nomiDispositivi)

    % Recupero il nome corrente
    nome = nomiDispositivi{e};

    % Estraggo la tabella
    T = dati.(nome);

    % Ordino cronologicamente i campioni
    T = sortrows(T, "Timestamp");

    % Stato binario iniziale
    stato = logical(T.Attivo);

    % Inizialmente lo stato definitivo
    % coincide con quello binario
    statoDefinitivo = stato;

    % Calcolo le distanze temporali
    % tra campioni consecutivi
    if height(T) > 1

        deltaT = diff(T.Timestamp);

        % Intervallo di campionamento tipico
        passoTipico = median(deltaT);

        % Una distanza molto superiore al passo
        % viene considerata un vero buco nei dati
        sogliaGapDati = 3 * passoTipico;

    else

        deltaT = duration.empty(0,1);
        sogliaGapDati = seconds(0);

    end

    % Individuo gli intervalli inattivi
    variazione = diff([false; stato; false]);

    iniziPausa = find(variazione == -1);
    finiPausa = find(variazione == 1) - 1;

    % Scorro tutte le pause individuate
    for k = 1:length(iniziPausa)

        i1 = iniziPausa(k);
        i2 = finiPausa(k);

        % La pausa può essere ricongiunta solamente
        % se è compresa tra due tratti attivi
        if i1 > 1 && i2 < height(T)

            attivoPrima = stato(i1 - 1);
            attivoDopo = stato(i2 + 1);

            if attivoPrima && attivoDopo

                % Durata temporale reale della pausa
                durataPausa = ...
                    T.Timestamp(i2 + 1) - ...
                    T.Timestamp(i1 - 1);

                % Verifico che all'interno della pausa
                % non siano presenti veri buchi nei dati
                intervalloLocale = ...
                    diff(T.Timestamp(i1 - 1:i2 + 1));

                presenzaGap = ...
                    any(intervalloLocale > sogliaGapDati);

                % Ricongiungo solamente pause brevi
                % senza discontinuità temporali
                if durataPausa <= SogliaPausa.(nome) ...
                        && ~presenzaGap

                    statoDefinitivo(i1:i2) = true;

                end

            end

        end

    end

    % Salvo nuovamente la tabella ordinata
    dati.(nome) = T;

    % Aggiungo lo stato definitivo
    dati.(nome).StatoDefinitivo = ...
        statoDefinitivo;

end

%% Verifica grafica delle soglie sull'intero periodo

% Estraggo l'elenco degli elettrodomestici

% per i quali è stata definita una soglia

ElettrodomesticiConSoglia = fieldnames(Soglie);

% Scorro tutti gli elettrodomestici

for e = 1:length(ElettrodomesticiConSoglia)

    % Recupero il nome dell'elettrodomestico corrente

    nome = ElettrodomesticiConSoglia{e};

    % Estraggo la tabella contenente i dati

    % dell'elettrodomestico corrente

    T = dati.(nome);

    % Creo una nuova figura dedicata

    % all'elettrodomestico analizzato

    figure("Name", "Verifica soglia - " + nome)

    % Rappresento l'andamento della potenza attiva

    % sull'intero periodo di acquisizione

    plot(T.Timestamp, T.P, "LineWidth", 1)

    % Mantengo il grafico corrente per poter

    % sovrapporre la linea della soglia

    hold on

    % Inserisco una linea orizzontale corrispondente

    % alla soglia definita per l'elettrodomestico

    yline(Soglie.(nome), "--", "Soglia = " + string(Soglie.(nome)) + " W", "LineWidth", 2)

    % Attivo la griglia

    grid on

    % Etichetta dell'asse delle ascisse

    xlabel("Tempo")

    % Etichetta dell'asse delle ordinate

    ylabel("Potenza attiva [W]")

    % Titolo della figura

    title("Verifica della soglia - " + nome)

    % Termino la sovrapposizione degli elementi grafici

    hold off

end

%% Rappresentazione grafica dello stato binario

% Estraggo l'elenco degli elettrodomestici

% per i quali è stata definita una soglia

ElettrodomesticiConSoglia = fieldnames(Soglie);

% Scorro tutti gli elettrodomestici

for e = 1:length(ElettrodomesticiConSoglia)

    % Recupero il nome dell'elettrodomestico corrente

    nome = ElettrodomesticiConSoglia{e};

    % Estraggo la tabella contenente i dati

    % dell'elettrodomestico corrente

    T = dati.(nome);

    % Creo una nuova figura

    figure("Name", "Stato binario - " + nome)

    % Rappresento lo stato di funzionamento

    % utilizzando un grafico a gradini

    stairs(T.Timestamp, double(T.Attivo), "LineWidth", 1)

    % Attivo la griglia

    grid on

    % Etichetta dell'asse delle ascisse

    xlabel("Tempo")

    % Etichetta dell'asse delle ordinate

    ylabel("Stato")

    % Imposto i soli valori possibili dell'asse y

    yticks([0 1])

    % Assegno una descrizione ai due livelli

    yticklabels(["Inattivo", "Attivo"])

    % Limito l'intervallo dell'asse y

    ylim([-0.2 1.2])

    % Titolo della figura

    title("Stato di funzionamento - " + nome)

end

%% Estrazione degli eventi di funzionamento

% Inizializzo la struttura che conterrà
% le tabelle degli eventi
Eventi = struct();

% Considero gli elettrodomestici
% per cui è stata definita una soglia
ElettrodomesticiConSoglia = fieldnames(Soglie);

% Scorro tutti gli elettrodomestici
for e = 1:length(ElettrodomesticiConSoglia)

    % Recupero il nome dell'elettrodomestico corrente
    nome = ElettrodomesticiConSoglia{e};

    % Estraggo la relativa tabella
    T = dati.(nome);

    % Ordino i campioni cronologicamente
    T = sortrows(T, "Timestamp");

    % Converto la colonna Attivo
    % in un vettore logico
    stato = logical(T.StatoDefinitivo);


    % Determinazione del passo temporale tipico

    if height(T) > 1

        % Calcolo le distanze temporali
        % tra campioni consecutivi
        differenzeTempo = diff(T.Timestamp);

        % Passo di campionamento tipico
        intervalloCampionamento = ...
            median(differenzeTempo);

    else

        differenzeTempo = duration.empty(0,1);

        intervalloCampionamento = ...
            seconds(0);

    end


    % Individuazione delle discontinuità temporali

    % Considero una discontinuità quando
    % la distanza tra due campioni supera
    % tre volte il passo temporale tipico
    sogliaGap = ...
        3 * intervalloCampionamento;

    % Individuo i gap temporali
    gapTemporali = ...
        differenzeTempo > sogliaGap;


    % Individuazione degli inizi degli eventi

    % Un evento inizia quando:
    %
    % 1) lo stato passa da 0 a 1
    %
    % oppure
    %
    % 2) il campione è attivo ma il campione
    %    precedente appartiene a un blocco
    %    temporale separato da un gap

    nuovoEvento = false(height(T),1);

    % Il primo campione costituisce un nuovo evento
    % se risulta attivo
    nuovoEvento(1) = stato(1);

    if height(T) > 1

        nuovoEvento(2:end) = ...
            stato(2:end) & ...
            ( ...
                ~stato(1:end-1) | ...
                gapTemporali ...
            );

    end

    % Recupero gli indici di inizio
    indiciInizio = find(nuovoEvento);


    % Individuazione delle fini degli eventi

    % Un evento termina quando:
    %
    % 1) il campione corrente è attivo
    %    e quello successivo è inattivo
    %
    % oppure
    %
    % 2) tra il campione corrente e quello
    %    successivo è presente un gap temporale

    fineEvento = false(height(T),1);

    if height(T) > 1

        fineEvento(1:end-1) = ...
            stato(1:end-1) & ...
            ( ...
                ~stato(2:end) | ...
                gapTemporali ...
            );

    end

    % Se l'ultimo campione è attivo,
    % chiudo l'evento alla fine del segnale
    fineEvento(end) = stato(end);

    % Recupero gli indici di fine
    indiciFine = find(fineEvento);


    % Verifica di coerenza

    numeroEventi = length(indiciInizio);

    if length(indiciFine) ~= numeroEventi

        error( ...
            "Numero di inizi e fini non coerente per %s", ...
            nome);

    end


    % Costruzione dei timestamp degli eventi

    % Timestamp di inizio
    timestampInizio = ...
        T.Timestamp(indiciInizio);

    % Utilizzo come fine dell'evento
    % il timestamp dell'ultimo campione
    % effettivamente classificato come attivo
    timestampFine = ...
        T.Timestamp(indiciFine);


    % Calcolo delle caratteristiche temporali

    % Numero progressivo degli eventi
    numeroEvento = ...
        (1:numeroEventi)';

    % Data di inizio
    dataEvento = ...
        dateshift(timestampInizio, ...
                  "start", ...
                  "day");

    % Orario di inizio
    oraInizio = ...
        timeofday(timestampInizio);

    % Orario di fine
    oraFine = ...
        timeofday(timestampFine);

    % Durata dell'evento
    durataEvento = ...
        timestampFine - timestampInizio;


    % Creazione della tabella degli eventi

    tabellaEventi = table( ...
        numeroEvento, ...
        dataEvento, ...
        timestampInizio, ...
        timestampFine, ...
        oraInizio, ...
        oraFine, ...
        durataEvento);

    % Assegno i nomi alle colonne
    tabellaEventi.Properties.VariableNames = { ...
        'NumeroEvento', ...
        'Data', ...
        'TimestampInizio', ...
        'TimestampFine', ...
        'OraInizio', ...
        'OraFine', ...
        'Durata'};


    % Salvataggio

    Eventi.(nome) = ...
        tabellaEventi;


    % Riepilogo

    fprintf( ...
        '%s: %d eventi | gap rilevati: %d\n', ...
        nome, ...
        numeroEventi, ...
        sum(gapTemporali));

end

%% Test della struttura Eventi

% Visualizzo l'elenco degli elettrodomestici

% presenti nella struttura Eventi

disp("Elettrodomestici presenti:")

disp(fieldnames(Eventi))

% Visualizzo le prime righe della tabella

% relativa alla lavatrice

disp("Prime righe della tabella lavatrice:")

disp(head(Eventi.lavatrice))

% Visualizzo i nomi delle colonne

% presenti nella tabella della lavatrice

disp("Colonne presenti:")

disp(Eventi.lavatrice.Properties.VariableNames)

% Visualizzo il numero di eventi

% individuati per ogni elettrodomestico

disp("Numero eventi rilevati:")

% Estraggo i nomi degli elettrodomestici

% presenti nella struttura Eventi

nomiEventi = fieldnames(Eventi);

% Scorro tutti gli elettrodomestici

for e = 1:length(nomiEventi)

    % Recupero il nome dell'elettrodomestico corrente

    nome = nomiEventi{e};

    % Calcolo il numero totale di eventi

    numeroEventi = height(Eventi.(nome));

    % Conto il numero di eventuali

    % durate negative

    durateNegative = sum(Eventi.(nome).Durata < seconds(0));

    % Visualizzo il riepilogo dei risultati

    disp(   nome + ": " + ...
            string(numeroEventi) + ...
            " eventi, durate negative = " + ...
            string(durateNegative) ...
        )

end

%% Correzione della frammentazione degli eventi

% Conservo una copia degli eventi inizialmente estratti

EventiGrezzi = Eventi;

% Inizializzo la struttura che conterrà

% gli eventi raggruppati e filtrati

EventiDefinitivi = struct();

% Definisco la pausa massima ammessa
% tra due segmenti dello stesso evento/ciclo
% separatamente per ciascun dispositivo

PausaMassima.lavatrice = minutes(5);
PausaMassima.lavastoviglie = minutes(5);
PausaMassima.asciugatrice  = minutes(5);
PausaMassima.frigo         = minutes(1);
PausaMassima.hvac1         = minutes(1);
PausaMassima.hvac2         = minutes(1);

% Definisco la durata minima necessaria

% affinché un evento venga considerato valido

durataMinima = seconds(30);

% Estraggo i nomi degli elettrodomestici

% presenti nella struttura degli eventi

nomiEventi = fieldnames(EventiGrezzi);

% Scorro tutti gli elettrodomestici

for e = 1:length(nomiEventi)

    % Recupero il nome dell'elettrodomestico corrente

    nome = nomiEventi{e};

    % Recupero la pausa massima specifica
    % per il dispositivo corrente
    pausaMassimaCorrente = PausaMassima.(nome);

    % Estraggo anche i dati originali
    % per verificare la continuità temporale
    TDati = dati.(nome);

    % Ordino cronologicamente i campioni
    TDati = sortrows(TDati, "Timestamp");

    % Determino il passo di campionamento tipico
    if height(TDati) > 1

    differenzeDati = diff(TDati.Timestamp);

    passoTipicoDati = median(differenzeDati);

    % Considero gap una distanza superiore
    % a tre volte il passo temporale tipico
    sogliaGapDati = 3 * passoTipicoDati;

else

    sogliaGapDati = seconds(0);

end

    % Estraggo la tabella degli eventi grezzi

    TEventi = EventiGrezzi.(nome);

    % Ordino gli eventi cronologicamente

    % in base al loro timestamp di inizio

    TEventi = sortrows(TEventi, "TimestampInizio");

    % Gestisco il caso in cui non siano presenti eventi

    if isempty(TEventi)

        % Mantengo una tabella vuota nella struttura definitiva

        EventiDefinitivi.(nome) = TEventi;

        % Passo all'elettrodomestico successivo

        continue

    end

    % Inizializzo il primo evento raggruppato

    timestampInizioUniti = TEventi.TimestampInizio(1);

    % Inizializzo il relativo timestamp di fine

    timestampFineUniti = TEventi.TimestampFine(1);

    % Scorro gli eventi a partire dal secondo

    for k = 2:height(TEventi)

        % Calcolo la pausa tra l'inizio dell'evento corrente

        % e la fine dell'ultimo evento già raggruppato

        pausa = TEventi.TimestampInizio(k) - timestampFineUniti(end);

       % Verifico se la pausa è inferiore o uguale
% alla soglia specifica del dispositivo
if pausa <= pausaMassimaCorrente

    % Estraggo i campioni originali compresi
    % tra la fine dell'evento precedente
    % e l'inizio dell'evento corrente
    righePausa = ...
        TDati.Timestamp >= timestampFineUniti(end) & ...
        TDati.Timestamp <= TEventi.TimestampInizio(k);

    timestampPausa = ...
        TDati.Timestamp(righePausa);

    % Inizialmente assumo che
    % l'intervallo sia continuo
    datiContinui = true;

    % Se non sono disponibili almeno due campioni,
    % non posso dimostrare la continuità
    if length(timestampPausa) < 2

        datiContinui = false;

    else

        % Calcolo le distanze tra i campioni
        % presenti nell'intervallo
        deltaPausa = diff(timestampPausa);

        % Se compare un intervallo troppo grande
        % considero presente un gap nei dati
        if any(deltaPausa > sogliaGapDati)

            datiContinui = false;

        end

    end

    % Ricongiungo i due segmenti
    % solamente se la pausa è breve
    % e i dati risultano temporalmente continui
    if datiContinui

        if TEventi.TimestampFine(k) > timestampFineUniti(end)

            timestampFineUniti(end) = ...
                TEventi.TimestampFine(k);

        end

    else

        % Pausa breve ma presenza di gap:
        % mantengo due eventi distinti
        timestampInizioUniti(end + 1, 1) = ...
            TEventi.TimestampInizio(k);

        timestampFineUniti(end + 1, 1) = ...
            TEventi.TimestampFine(k);

    end

else

    % Pausa superiore alla soglia:
    % creo un nuovo evento indipendente
    timestampInizioUniti(end + 1, 1) = ...
        TEventi.TimestampInizio(k);

    timestampFineUniti(end + 1, 1) = ...
        TEventi.TimestampFine(k);

end

    end

    % Calcolo la durata degli eventi dopo il raggruppamento

    durataEventiUniti = timestampFineUniti - timestampInizioUniti;

    % Individuo gli eventi con durata superiore a 30 secondi

    eventiValidi = durataEventiUniti > durataMinima;

    % Elimino le possibili false attivazioni

    timestampInizioDefinitivi = timestampInizioUniti(eventiValidi);

    timestampFineDefinitivi = timestampFineUniti(eventiValidi);

    durataDefinitiva = durataEventiUniti(eventiValidi);

    % Calcolo il numero totale degli eventi definitivi

    numeroEventiDefinitivi = length(timestampInizioDefinitivi);

    % Creo il numero progressivo degli eventi

    numeroEvento = (1:numeroEventiDefinitivi)';

    % Estraggo la data di inizio di ogni evento

    dataEvento = dateshift( timestampInizioDefinitivi, "start", "day");

    % Estraggo il solo orario di inizio

    oraInizio = timeofday(timestampInizioDefinitivi);

    % Estraggo il solo orario di fine

    oraFine = timeofday(timestampFineDefinitivi);

    % Creo la tabella definitiva degli eventi

    tabellaEventiDefinitivi = table(    numeroEvento, dataEvento, timestampInizioDefinitivi, ...
                                        timestampFineDefinitivi, oraInizio, oraFine, durataDefinitiva);

    % Assegno i nomi definitivi alle colonne

    tabellaEventiDefinitivi.Properties.VariableNames = {    'NumeroEvento', ...
                                                            'Data', ...
                                                            'TimestampInizio', ...
                                                            'TimestampFine', ...
                                                            'OraInizio', ...
                                                            'OraFine', ...
                                                            'Durata'
                                                        };

    % Salvo la tabella nella struttura definitiva

    EventiDefinitivi.(nome) = tabellaEventiDefinitivi;

end

%% Confronto tra eventi grezzi ed eventi definitivi

% Estraggo i nomi degli elettrodomestici

nomiEventi = fieldnames(EventiGrezzi);

% Scorro tutti gli elettrodomestici

for e = 1:length(nomiEventi)

    % Recupero il nome dell'elettrodomestico corrente

    nome = nomiEventi{e};

    % Numero di eventi prima della correzione

    eventiGrezzi = height(EventiGrezzi.(nome));

    % Numero di eventi dopo la correzione

    eventiDefinitivi = height(EventiDefinitivi.(nome));

    % Calcolo il numero di eventi eliminati

    eventiEliminati = eventiGrezzi - eventiDefinitivi;

    % Visualizzo i risultati

    disp(   nome + " --> Grezzi: " + string(eventiGrezzi) + ...
            " | Definitivi: " + string(eventiDefinitivi) + ...
            " | Eliminati: " + string(eventiEliminati) ...
        )

end

%% Figura rappresentativa dell'affinamento - lavatrice

% Estraggo i dati originali della lavatrice
T = dati.lavatrice;

% Ordino cronologicamente i campioni
T = sortrows(T, "Timestamp");

% Estraggo gli eventi prima e dopo l'affinamento
eventiGrezziLavatrice = EventiGrezzi.lavatrice;
eventiDefinitiviLavatrice = EventiDefinitivi.lavatrice;


%% Ricostruzione dello stato a partire dagli eventi grezzi

statoGrezzo = false(height(T), 1);

for k = 1:height(eventiGrezziLavatrice)

    campioniEvento = ...
        T.Timestamp >= eventiGrezziLavatrice.TimestampInizio(k) & ...
        T.Timestamp <= eventiGrezziLavatrice.TimestampFine(k);

    statoGrezzo(campioniEvento) = true;

end


%% Ricostruzione dello stato a partire dagli eventi definitivi

statoDefinitivoGrafico = false(height(T), 1);

for k = 1:height(eventiDefinitiviLavatrice)

    campioniEvento = ...
        T.Timestamp >= eventiDefinitiviLavatrice.TimestampInizio(k) & ...
        T.Timestamp <= eventiDefinitiviLavatrice.TimestampFine(k);

    statoDefinitivoGrafico(campioniEvento) = true;

end


%% Individuazione delle zone modificate dall'affinamento

differenze = ...
    statoGrezzo ~= statoDefinitivoGrafico;

idxDifferenze = find(differenze);

if isempty(idxDifferenze)

    warning( ...
        'Non sono presenti differenze tra eventi grezzi e definitivi.')

else

    % Seleziono una zona nella quale
    % l'affinamento ha prodotto una modifica
    idxCentro = ...
        idxDifferenze(round(length(idxDifferenze) / 2));

    tempoCentro = ...
        T.Timestamp(idxCentro);

    % Visualizzo 30 minuti prima e dopo
    tempoInizio = ...
        tempoCentro - minutes(30);

    tempoFine = ...
        tempoCentro + minutes(30);

    idxZoom = ...
        T.Timestamp >= tempoInizio & ...
        T.Timestamp <= tempoFine;


    %% Creazione della figura

    figure( ...
        'Name', ...
        'Affinamento eventi - lavatrice', ...
        'NumberTitle', ...
        'off', ...
        'Position', ...
        [100 100 1200 700])

    tiledlayout( ...
        2, 1, ...
        'TileSpacing', 'compact', ...
        'Padding', 'compact');


    %% Prima dell'affinamento

    nexttile

    yyaxis left

    plot( ...
        T.Timestamp(idxZoom), ...
        T.P(idxZoom), ...
        'LineWidth', 1)

    ylabel('Potenza attiva [W]')

    yline( ...
        Soglie.lavatrice, ...
        '--', ...
        'Soglia = 30 W', ...
        'LineWidth', 1)

    yyaxis right

    stairs( ...
        T.Timestamp(idxZoom), ...
        double(statoGrezzo(idxZoom)), ...
        'LineWidth', 1.5)

    ylim([-0.1 1.1])
    yticks([0 1])
    yticklabels({'Inattivo','Attivo'})

    ylabel('Stato')
    xlabel('Tempo')

    grid on

    title('Prima dell''affinamento')


    %% Dopo l'affinamento

    nexttile

    yyaxis left

    plot( ...
        T.Timestamp(idxZoom), ...
        T.P(idxZoom), ...
        'LineWidth', 1)

    ylabel('Potenza attiva [W]')

    yline( ...
        Soglie.lavatrice, ...
        '--', ...
        'Soglia = 30 W', ...
        'LineWidth', 1)

    yyaxis right

    stairs( ...
        T.Timestamp(idxZoom), ...
        double(statoDefinitivoGrafico(idxZoom)), ...
        'LineWidth', 1.5)

    ylim([-0.1 1.1])
    yticks([0 1])
    yticklabels({'Inattivo','Attivo'})

    ylabel('Stato')
    xlabel('Tempo')

    grid on

    title('Dopo l''affinamento')


    %% Titolo generale

    sgtitle( ...
        'Esempio di affinamento degli eventi - lavatrice')

end

%% Rappresentazione dello stato di funzionamento definitivo

% Estraggo i nomi di tutti gli elettrodomestici

% presenti nella struttura EventiDefinitivi

nomiEventi = fieldnames(EventiDefinitivi);

% Scorro tutti gli elettrodomestici presenti

for e = 1:length(nomiEventi)

    % Recupero il nome dell'elettrodomestico

    % associato all'iterazione corrente

    nome = nomiEventi{e};

    % Estraggo dalla struttura dati la tabella completa

    % relativa all'elettrodomestico corrente

    T = dati.(nome);

    % Creo un vettore logico inizialmente composto

    % interamente da valori false, cioè stato inattivo

    % Il numero di elementi coincide con il numero di righe di T

    statoDefinitivo = false(height(T), 1);

    % Estraggo dalla struttura EventiDefinitivi

    % la tabella degli eventi dell'elettrodomestico corrente

    Eventi = EventiDefinitivi.(nome);

    % Scorro tutti gli eventi definitivi rilevati

    % per l'elettrodomestico corrente

    for k = 1:height(Eventi)

        % Individuo tutti i campioni della tabella T

        % il cui timestamp è compreso tra l'inizio

        % e la fine dell'evento corrente

        campioniEvento = T.Timestamp >= Eventi.TimestampInizio(k) & T.Timestamp <= Eventi.TimestampFine(k);

        % Imposto a true, cioè a stato attivo,

        % tutti i campioni appartenenti all'evento corrente

        statoDefinitivo(campioniEvento) = true;

    end

    % Creo una nuova finestra grafica

    % dedicata all'elettrodomestico corrente

    figure("Name", "Stato definitivo - " + nome)

    % Rappresento lo stato definitivo nel tempo

    % mediante un grafico a gradini

    % Converto i valori logici false/true nei valori numerici 0/1

    stairs(T.Timestamp, double(statoDefinitivo), "LineWidth", 1)

    % Attivo la griglia del grafico

    grid on

    % Inserisco l'etichetta dell'asse orizzontale

    xlabel("Tempo")

    % Inserisco l'etichetta dell'asse verticale

    ylabel("Stato")

    % Imposto sull'asse verticale solamente

    % i due valori possibili dello stato

    yticks([0 1])

    % Sostituisco le etichette numeriche 0 e 1

    % con le descrizioni Inattivo e Attivo

    yticklabels(["Inattivo", "Attivo"])

    % Imposto i limiti dell'asse verticale

    % lasciando un piccolo margine sopra e sotto i due livelli

    ylim([-0.2 1.2])

    % Inserisco il titolo della figura

    % indicando l'elettrodomestico rappresentato

    title("Stato di funzionamento definitivo - " + nome)

end

%% 10.1 Analisi della correlazione tra orari e attivazioni

% Estraggo i nomi degli elettrodomestici

% presenti nella struttura EventiDefinitivi

nomiEventi = fieldnames(EventiDefinitivi);

% Inizializzo una struttura che conterrà

% i risultati dell'analisi oraria

ProfilazioneOraria = struct();

% Scorro tutti gli elettrodomestici

for e = 1:length(nomiEventi)

    % Recupero il nome dell'elettrodomestico corrente

    nome = nomiEventi{e};

    % Estraggo la tabella degli eventi definitivi

    % relativa all'elettrodomestico corrente

    TEventi = EventiDefinitivi.(nome);

    % Estraggo l'ora di inizio di ciascun evento

    % come valore intero compreso tra 0 e 23

    oraAttivazione = hour(TEventi.TimestampInizio);

    % Definisco i limiti delle 24 fasce orarie

    % da 00:00-01:00 fino a 23:00-24:00

    intervalliOrari = 0:24;

    % Conteggio il numero di eventi che iniziano

    % all'interno di ciascuna fascia oraria

    numeroAttivazioni = histcounts( oraAttivazione, intervalliOrari);

    % Creo il vettore delle ore

    % da 0 a 23

    ore = (0:23)';

    % Converto il conteggio in vettore colonna

    numeroAttivazioni = numeroAttivazioni';

    % Creo una tabella contenente

    % ora e numero di attivazioni corrispondenti

    tabellaProfilazione = table( ore, numeroAttivazioni);

    % Assegno i nomi alle colonne della tabella

    tabellaProfilazione.Properties.VariableNames = {'Ora', ...

        'NumeroAttivazioni'};

    % Salvo la tabella all'interno della struttura

    % ProfilazioneOraria

    ProfilazioneOraria.(nome) = tabellaProfilazione;

    % Creo una nuova figura per

    % l'elettrodomestico corrente

    figure("Name", "Profilazione oraria - " + nome)

    % Disegno le barre centrate a metà di ogni fascia oraria

    bar(0.5:1:23.5, numeroAttivazioni, 1)

    % Attivo la griglia

    grid on

    % Imposto i limiti dell'asse x da 0 a 24 ore

    xlim([0 24])

    % Imposto le tacche dell'asse x in corrispondenza

    % dell'inizio di ogni fascia oraria

    xticks(0:24)

    % Creo le etichette nel formato HH:00

    etichetteOrarie = compose("%02d:00", 0:24);

    % Assegno le etichette all'asse x

    xticklabels(etichetteOrarie)

    % Ruoto leggermente le etichette per migliorarne la leggibilità

    xtickangle(45)

    % Inserisco l'etichetta dell'asse orizzontale

    xlabel("Fascia oraria")

    % Inserisco l'etichetta dell'asse verticale

    ylabel("Numero di attivazioni")

    % Inserisco il titolo del grafico

    title("Distribuzione oraria delle attivazioni - " + nome)

end

%% Ricostruzione dello stato definitivo nei giorni comuni

% Inizializzo la struttura che conterrà
% lo stato definitivo di ogni elettrodomestico
StatoDefinitivo = struct();

% Estraggo i nomi degli elettrodomestici
% presenti nella struttura EventiDefinitivi
nomiElettrodomestici = fieldnames(EventiDefinitivi);

% Scorro tutti gli elettrodomestici
for e = 1:length(nomiElettrodomestici)

    % Recupero il nome dell'elettrodomestico corrente
    nome = nomiElettrodomestici{e};

    % Estraggo i dati relativi ai soli giorni comuni
    TComune = Comuni.dati.(nome);

    % Estraggo gli eventi definitivi
    % dell'elettrodomestico corrente
    TEventi = EventiDefinitivi.(nome);

    % Inizializzo il vettore dello stato definitivo
    % ponendo inizialmente tutti i campioni a stato inattivo
    stato = false(height(TComune), 1);

    % Scorro tutti gli eventi definitivi
    for k = 1:height(TEventi)

        % Individuo i campioni dei giorni comuni
        % compresi tra l'inizio e la fine dell'evento corrente
        campioniEvento = ...
            TComune.Timestamp >= TEventi.TimestampInizio(k) & ...
            TComune.Timestamp <= TEventi.TimestampFine(k);

        % Imposto a true, cioè attivo,
        % tutti i campioni appartenenti all'evento
        stato(campioniEvento) = true;

    end

    % Creo una nuova tabella con le informazioni necessarie
    tabellaStato = table( ...
        TComune.Timestamp, ...
        TComune.Data, ...
        TComune.Ora, ...
        stato);

    % Assegno i nomi alle colonne
    tabellaStato.Properties.VariableNames = { ...
        'Timestamp', ...
        'Data', ...
        'Ora', ...
        'Stato'};

    % Salvo la tabella nella struttura StatoDefinitivo
    StatoDefinitivo.(nome) = tabellaStato;

end

%% 10.2 Analisi degli elettrodomestici utilizzati contemporaneamente

% Estraggo i nomi degli elettrodomestici

% presenti nella struttura EventiDefinitivi

nomiElettrodomestici = fieldnames(EventiDefinitivi);

% Calcolo il numero totale di elettrodomestici analizzati

numeroElettrodomestici = length(nomiElettrodomestici);

%% Determinazione dell'intervallo temporale comune

% Inizializzo un vettore che conterrà

% l'intervallo di campionamento tipico di ogni sensore

intervalliCampionamento = ...
repmat(seconds(0), numeroElettrodomestici, 1);

% Scorro tutti gli elettrodomestici

for e = 1:numeroElettrodomestici

    % Recupero il nome dell'elettrodomestico corrente

    nome = nomiElettrodomestici{e};

    % Estraggo i timestamp relativi ai giorni comuni

    timestamp = unique(StatoDefinitivo.(nome).Timestamp);

    % Calcolo le distanze temporali tra campioni consecutivi

    differenzeTemporali = diff(timestamp);

    % Elimino eventuali differenze nulle

    differenzeTemporali = ...
    differenzeTemporali(differenzeTemporali > seconds(0));

    % Calcolo l'intervallo di campionamento tipico

    intervalliCampionamento(e) = median(differenzeTemporali);

end

% Utilizzo come passo comune il più grande

% tra gli intervalli di campionamento dei sensori

passoTemporale = max(intervalliCampionamento);

% Visualizzo il passo temporale adottato

disp("Passo temporale comune:")

disp(passoTemporale)

%% Creazione della base temporale sui giorni comuni

% Inizializzo un vettore datetime vuoto

tempoComune = NaT(0, 1, "TimeZone", "UTC");

% Scorro tutti i giorni comuni

for g = 1:length(Comuni.giorni)

    % Individuo l'inizio del giorno corrente

    inizioGiorno = Comuni.giorni(g);

    % Individuo l'ultimo istante del giorno

    % compatibile con il passo temporale scelto

    fineGiorno = inizioGiorno + days(1) - passoTemporale;

    % Creo la griglia temporale relativa al giorno corrente

    grigliaGiornaliera = (inizioGiorno:passoTemporale:fineGiorno)';

    % Aggiungo la griglia giornaliera al vettore complessivo

    tempoComune = [tempoComune; grigliaGiornaliera];

end

%% Ricostruzione dello stato dei dispositivi sulla stessa griglia

% Creo una matrice logica inizialmente nulla

%

% righe   = istanti della griglia temporale

% colonne = elettrodomestici

matriceStati = false(length(tempoComune), numeroElettrodomestici);

% Scorro tutti gli elettrodomestici

for e = 1:numeroElettrodomestici

    % Recupero il nome dell'elettrodomestico corrente

    nome = nomiElettrodomestici{e};

    % Estraggo la relativa tabella degli eventi definitivi

    TEventi = EventiDefinitivi.(nome);

    % Scorro tutti gli eventi definitivi

    for k = 1:height(TEventi)

        % Individuo gli istanti della griglia comune

        % compresi tra inizio e fine dell'evento

        campioniAttivi =    tempoComune >= TEventi.TimestampInizio(k) & ...
                            tempoComune <= TEventi.TimestampFine(k);

        % Imposto a 1 lo stato dell'elettrodomestico

        % durante l'intervallo dell'evento

        matriceStati(campioniAttivi, e) = true;

    end

end

%% Creazione della tabella di contemporaneità

% Creo la tabella iniziale contenente il timestamp comune

Contemporaneita = table(tempoComune);

% Assegno il nome Timestamp alla prima colonna

Contemporaneita.Properties.VariableNames = {'Timestamp'};

% Aggiungo una colonna di stato

% per ogni elettrodomestico

for e = 1:numeroElettrodomestici

    % Recupero il nome corrente

    nome = nomiElettrodomestici{e};

    % Inserisco la relativa colonna binaria

    Contemporaneita.(nome) = matriceStati(:, e);

end

% Calcolo quanti elettrodomestici risultano

% attivi contemporaneamente in ogni istante

Contemporaneita.NumeroAttivi = sum(matriceStati, 2);

%% Individuazione delle combinazioni attive

% Assegno a ogni combinazione binaria

% un codice numerico univoco

pesiBinari = 2.^(0:numeroElettrodomestici - 1);

codiceCombinazione = matriceStati * pesiBinari';

% Creo l'elenco delle descrizioni possibili

descrizioniCombinazioni = strings(2^numeroElettrodomestici, 1);

% Scorro tutti i possibili codici

for codice = 0:(2^numeroElettrodomestici - 1)

    % Individuo gli elettrodomestici attivi

    % nella combinazione corrente

    dispositiviAttivi = logical(bitget(codice, 1:numeroElettrodomestici));

    % Verifico se non è attivo alcun dispositivo

    if ~any(dispositiviAttivi)

        % Assegno la descrizione "Nessuno"

        descrizioniCombinazioni(codice + 1) = "Nessuno";

    else

        % Estraggo i nomi dei dispositivi attivi

        nomiAttivi = string(nomiElettrodomestici(dispositiviAttivi));

        % Creo una descrizione unica della combinazione

        descrizioniCombinazioni(codice + 1) = strjoin(nomiAttivi, " + ");

    end

end

% Aggiungo alla tabella la descrizione

% della combinazione attiva in ogni istante

Contemporaneita.Combinazione = descrizioniCombinazioni(codiceCombinazione + 1);

%% Riepilogo del numero di dispositivi contemporaneamente attivi

% Individuo i diversi numeri di elettrodomestici attivi

[valoriNumeroAttivi, ~, indiceNumero] = unique(Contemporaneita.NumeroAttivi);

% Conto quanti campioni appartengono a ogni categoria

conteggioCampioni = accumarray(indiceNumero, 1);

% Calcolo la durata totale di ogni categoria

durataTotale = conteggioCampioni .* passoTemporale;

% Calcolo la percentuale rispetto al tempo complessivo

percentualeTempo = 100 * conteggioCampioni / height(Contemporaneita);

% Creo la tabella riassuntiva

RiepilogoNumeroAttivi = table(  valoriNumeroAttivi, conteggioCampioni, ...
                                durataTotale, percentualeTempo  );

% Assegno i nomi alle colonne

RiepilogoNumeroAttivi.Properties.VariableNames = { ...

    'NumeroElettrodomesticiAttivi', 'NumeroCampioni', 'DurataTotale', 'PercentualeTempo'};

%% Riepilogo delle combinazioni contemporanee

% Mantengo solamente gli istanti in cui

% risultano attivi almeno due elettrodomestici

righeContemporanee = ...
    Contemporaneita.NumeroAttivi >= 2;

% Estraggo le combinazioni contemporanee

combinazioniContemporanee = ...
    Contemporaneita.Combinazione(righeContemporanee);

% Individuo le combinazioni differenti

[combinazioniUniche, ~, indiceCombinazione] = ...
    unique(combinazioniContemporanee);

% Conto quante volte compare ogni combinazione

conteggioCombinazioni = accumarray(indiceCombinazione, 1);

% Calcolo la durata complessiva di ogni combinazione

durataCombinazioni = conteggioCombinazioni .* passoTemporale;

% Creo la tabella riepilogativa

RiepilogoCombinazioni = table(  combinazioniUniche, ...
                                conteggioCombinazioni, ...
                                durataCombinazioni          );

% Assegno i nomi alle colonne

RiepilogoCombinazioni.Properties.VariableNames = { ...

    'Combinazione', 'NumeroCampioni', 'DurataTotale'};

% Ordino le combinazioni dalla più frequente alla meno frequente

RiepilogoCombinazioni = sortrows(   RiepilogoCombinazioni, ...
                                    "DurataTotale", "descend"   );

%% Stampa dei risultati della contemporaneità - Utente 1

fprintf('\n===== CONTEMPORANEITA - UTENTE 1 =====\n');

fprintf('\nPasso temporale comune:\n');
disp(passoTemporale)

fprintf('\n--- NUMERO DI DISPOSITIVI ATTIVI ---\n');
disp(RiepilogoNumeroAttivi)

fprintf('\n--- COMBINAZIONI CON ALMENO 2 DISPOSITIVI ATTIVI ---\n');
disp(RiepilogoCombinazioni)

fprintf('=====================================\n');

%% GRAFICO CONTEMPORANEITA' - UTENTE 1

numeroAttivi = 0:6;

percentualeTempo = [ ...
    83.058, ...
    12.109, ...
    3.7148, ...
    0.95223, ...
    0.14475, ...
    0.01861, ...
    0.0020678];

fig = figure;
bar(numeroAttivi, percentualeTempo);

xlabel('Numero di dispositivi contemporaneamente attivi');
ylabel('Percentuale di tempo [%]');

xticks(0:6);
ylim([0 90]);
grid on;

for i = 1:length(numeroAttivi)
    text(numeroAttivi(i), percentualeTempo(i), ...
        sprintf('%.3g%%', percentualeTempo(i)), ...
        'HorizontalAlignment','center', ...
        'VerticalAlignment','bottom', ...
        'FontSize',9);
end

exportgraphics(fig, ...
    'contemporaneita_utente1.png', ...
    'Resolution',300);

%% Analisi delle pause tra eventi consecutivi
% utile per la ricostruzione delle sessioni operative

dispositiviSessione = {'lavatrice', 'asciugatrice'};

for d = 1:length(dispositiviSessione)

    nomeDisp = dispositiviSessione{d};

    % Estraggo gli eventi definitivi
    E = EventiDefinitivi.(nomeDisp);

    % Ordino cronologicamente
    E = sortrows(E, "TimestampInizio");

    % Calcolo la pausa tra la fine di un evento
    % e l'inizio dell'evento successivo
    pauseEventi = ...
        E.TimestampInizio(2:end) - ...
        E.TimestampFine(1:end-1);

    % Mantengo solamente pause positive
    pauseSecondi = seconds(pauseEventi);
    pauseSecondi = ...
        pauseSecondi(isfinite(pauseSecondi) & pauseSecondi >= 0);

    fprintf('\n%s\n', upper(nomeDisp));
    fprintf('Numero pause analizzate: %d\n', length(pauseSecondi));
    fprintf('Mediana: %.2f min\n', median(pauseSecondi)/60);
    fprintf('75° percentile: %.2f min\n', prctile(pauseSecondi,75)/60);
    fprintf('90° percentile: %.2f min\n', prctile(pauseSecondi,90)/60);
    fprintf('95° percentile: %.2f min\n', prctile(pauseSecondi,95)/60);

    fprintf('Pause <= 5 min: %.2f%%\n', ...
        100*mean(pauseSecondi <= 5*60));

    fprintf('Pause <= 10 min: %.2f%%\n', ...
        100*mean(pauseSecondi <= 10*60));

    fprintf('Pause <= 20 min: %.2f%%\n', ...
        100*mean(pauseSecondi <= 20*60));

    fprintf('Pause <= 30 min: %.2f%%\n', ...
        100*mean(pauseSecondi <= 30*60));

    % Istogramma delle pause fino a 60 minuti
    figure

    pauseMinuti = pauseSecondi / 60;
    pauseMinutiGrafico = pauseMinuti(pauseMinuti <= 60);

    histogram(pauseMinutiGrafico, ...
        'BinWidth', 1)

    grid on
    xlabel('Pausa tra eventi consecutivi [min]')
    ylabel('Numero di occorrenze')

    title( ...
        'Distribuzione delle pause tra eventi - ' + ...
        string(nomeDisp))

end

%% Ricostruzione preliminare delle sessioni operative
%
% Eventi consecutivi sufficientemente vicini vengono considerati
% appartenenti alla stessa sessione di utilizzo.
%
% In questa prima verifica viene utilizzata una soglia di 10 minuti.

pausaMassimaSessione = minutes(10);

dispositiviSessione = {'lavatrice', 'asciugatrice'};

SessioniOperative = struct();

for d = 1:length(dispositiviSessione)

    nomeDisp = dispositiviSessione{d};

    % Estraggo gli eventi definitivi
    E = EventiDefinitivi.(nomeDisp);

    % Ordino cronologicamente gli eventi
    E = sortrows(E, "TimestampInizio");

    % Inizializzo le sessioni
    numeroSessione = 1;

    inizioSessione = E.TimestampInizio(1);
    fineSessione   = E.TimestampFine(1);

    numeroEventiSessione = 1;

    inizioSessioni = NaT(0,1, ...
        "TimeZone", E.TimestampInizio.TimeZone);

    fineSessioni = NaT(0,1, ...
        "TimeZone", E.TimestampFine.TimeZone);

    eventiPerSessione = [];

    for k = 2:height(E)

        % Calcolo la pausa rispetto alla fine
        % dell'ultimo evento già appartenente alla sessione
        pausa = E.TimestampInizio(k) - fineSessione;

        if pausa >= seconds(0) && ...
                pausa <= pausaMassimaSessione

            % L'evento appartiene alla stessa sessione
            fineSessione = max( ...
                fineSessione, ...
                E.TimestampFine(k));

            numeroEventiSessione = ...
                numeroEventiSessione + 1;

        else

            % Salvo la sessione appena conclusa
            inizioSessioni(end+1,1) = ...
                inizioSessione;

            fineSessioni(end+1,1) = ...
                fineSessione;

            eventiPerSessione(end+1,1) = ...
                numeroEventiSessione;

            % Inizio una nuova sessione
            numeroSessione = ...
                numeroSessione + 1;

            inizioSessione = ...
                E.TimestampInizio(k);

            fineSessione = ...
                E.TimestampFine(k);

            numeroEventiSessione = 1;

        end

    end

    % Salvo l'ultima sessione
    inizioSessioni(end+1,1) = ...
        inizioSessione;

    fineSessioni(end+1,1) = ...
        fineSessione;

    eventiPerSessione(end+1,1) = ...
        numeroEventiSessione;

    % Creo la tabella
    numeroSessioneVettore = ...
        (1:length(inizioSessioni))';

    durataSessione = ...
        fineSessioni - inizioSessioni;

    SessioniOperative.(nomeDisp) = table( ...
        numeroSessioneVettore, ...
        inizioSessioni, ...
        fineSessioni, ...
        durataSessione, ...
        eventiPerSessione, ...
        'VariableNames', { ...
        'NumeroSessione', ...
        'TimestampInizio', ...
        'TimestampFine', ...
        'Durata', ...
        'NumeroEventi'});

    fprintf('\n%s\n', upper(nomeDisp));
    fprintf('Eventi originali: %d\n', height(E));
    fprintf('Sessioni ottenute: %d\n', ...
        height(SessioniOperative.(nomeDisp)));

    fprintf('Riduzione: %.2f%%\n', ...
        100 * ...
        (1 - height(SessioniOperative.(nomeDisp)) / height(E)));

end

%% Controllo delle sessioni operative ottenute

dispositiviSessione = {'lavatrice', 'asciugatrice'};

for d = 1:length(dispositiviSessione)

    nomeDisp = dispositiviSessione{d};

    S = SessioniOperative.(nomeDisp);

    durataMin = minutes(S.Durata);

    fprintf('\n%s - CONTROLLO SESSIONI\n', upper(nomeDisp));

    fprintf('Durata mediana: %.2f min\n', ...
        median(durataMin));

    fprintf('75° percentile durata: %.2f min\n', ...
        prctile(durataMin,75));

    fprintf('90° percentile durata: %.2f min\n', ...
        prctile(durataMin,90));

    fprintf('Durata massima: %.2f min\n', ...
        max(durataMin));

    fprintf('Numero mediano di eventi per sessione: %.2f\n', ...
        median(S.NumeroEventi));

    fprintf('90° percentile eventi per sessione: %.2f\n', ...
        prctile(S.NumeroEventi,90));

    fprintf('Massimo eventi in una sessione: %d\n', ...
        max(S.NumeroEventi));

end

%% Analisi sequenziale lavatrice-asciugatrice basata sulle sessioni operative

% Definisco la distanza temporale massima
% entro la quale considero plausibile
% l'associazione lavatrice-asciugatrice
distanzaMassima = hours(24);

% Estraggo le sessioni operative ricostruite
sessioniLavatrice = SessioniOperative.lavatrice;
sessioniAsciugatrice = SessioniOperative.asciugatrice;

% Aggiungo la data associata all'inizio della sessione
sessioniLavatrice.Data = ...
    dateshift(sessioniLavatrice.TimestampInizio, 'start', 'day');

sessioniAsciugatrice.Data = ...
    dateshift(sessioniAsciugatrice.TimestampInizio, 'start', 'day');

% Mantengo solamente le sessioni della lavatrice
% appartenenti ai giorni comuni
righeComuniLavatrice = ...
    ismember(sessioniLavatrice.Data, Comuni.giorni);

sessioniLavatrice = ...
    sessioniLavatrice(righeComuniLavatrice, :);

% Mantengo solamente le sessioni dell'asciugatrice
% appartenenti ai giorni comuni
righeComuniAsciugatrice = ...
    ismember(sessioniAsciugatrice.Data, Comuni.giorni);

sessioniAsciugatrice = ...
    sessioniAsciugatrice(righeComuniAsciugatrice, :);

% Ordino cronologicamente le sessioni
sessioniLavatrice = ...
    sortrows(sessioniLavatrice, "TimestampInizio");

sessioniAsciugatrice = ...
    sortrows(sessioniAsciugatrice, "TimestampInizio");

% Creo un vettore logico per evitare che
% una stessa sessione di lavatrice venga riutilizzata
lavatriceAssociata = ...
    false(height(sessioniLavatrice), 1);

% Inizializzo i vettori dei risultati
sessioneLavatriceAssociata = [];

sessioneAsciugatriceAssociata = [];

fineLavatriceAssociata = ...
    NaT(0, 1, ...
    "TimeZone", ...
    sessioniLavatrice.TimestampFine.TimeZone);

inizioAsciugatriceAssociata = ...
    NaT(0, 1, ...
    "TimeZone", ...
    sessioniAsciugatrice.TimestampInizio.TimeZone);

distanzaTemporale = ...
    duration.empty(0, 1);

categoriaSequenza = ...
    strings(0, 1);

% Scorro tutte le sessioni dell'asciugatrice
for k = 1:height(sessioniAsciugatrice)

    % Recupero l'inizio della sessione corrente
    inizioAsciugatrice = ...
        sessioniAsciugatrice.TimestampInizio(k);

    % Calcolo la distanza rispetto alla fine
    % di tutte le sessioni della lavatrice
    distanze = ...
        inizioAsciugatrice - ...
        sessioniLavatrice.TimestampFine;

    % Individuo le sessioni di lavatrice:
    % - terminate prima dell'asciugatrice
    % - distanti non più di 24 ore
    % - non ancora associate
    candidate = ...
        distanze >= seconds(0) & ...
        distanze <= distanzaMassima & ...
        ~lavatriceAssociata;

    indiciCandidate = find(candidate);

    % Se non esistono sessioni compatibili,
    % passo alla successiva sessione di asciugatrice
    if isempty(indiciCandidate)
        continue
    end

    % Scelgo la sessione di lavatrice terminata
    % più recentemente prima dell'asciugatrice
    [~, posizioneMinima] = ...
        min(distanze(indiciCandidate));

    indiceLavatrice = ...
        indiciCandidate(posizioneMinima);

    % Evito di riutilizzare la stessa sessione
    lavatriceAssociata(indiceLavatrice) = true;

    % Recupero la distanza temporale
    distanzaCorrente = ...
        distanze(indiceLavatrice);

    % Salvo i numeri delle sessioni associate
    sessioneLavatriceAssociata(end + 1, 1) = ...
        sessioniLavatrice.NumeroSessione(indiceLavatrice);

    sessioneAsciugatriceAssociata(end + 1, 1) = ...
        sessioniAsciugatrice.NumeroSessione(k);

    % Salvo i timestamp
    fineLavatriceAssociata(end + 1, 1) = ...
        sessioniLavatrice.TimestampFine(indiceLavatrice);

    inizioAsciugatriceAssociata(end + 1, 1) = ...
        inizioAsciugatrice;

    % Salvo la distanza
    distanzaTemporale(end + 1, 1) = ...
        distanzaCorrente;

    % Classifico la sequenza
    if distanzaCorrente <= hours(2)

        categoriaSequenza(end + 1, 1) = ...
            "Ravvicinata";

    elseif distanzaCorrente <= hours(8)

        categoriaSequenza(end + 1, 1) = ...
            "Differita";

    else

        categoriaSequenza(end + 1, 1) = ...
            "Molto differita";

    end

end


%% Creazione della tabella delle sequenze

numeroSequenza = ...
    (1:length(distanzaTemporale))';

dataSequenza = ...
    dateshift(fineLavatriceAssociata, ...
    'start', 'day');

SequenzeLavatriceAsciugatrice = table( ...
    numeroSequenza, ...
    sessioneLavatriceAssociata, ...
    fineLavatriceAssociata, ...
    sessioneAsciugatriceAssociata, ...
    inizioAsciugatriceAssociata, ...
    distanzaTemporale, ...
    categoriaSequenza, ...
    dataSequenza);

SequenzeLavatriceAsciugatrice.Properties.VariableNames = { ...
    'NumeroSequenza', ...
    'SessioneLavatrice', ...
    'FineLavatrice', ...
    'SessioneAsciugatrice', ...
    'InizioAsciugatrice', ...
    'DistanzaTemporale', ...
    'Categoria', ...
    'Data'};


%% Riepilogo dei risultati

numeroTotaleSequenze = ...
    height(SequenzeLavatriceAsciugatrice);

fprintf( ...
    '\nSequenze lavatrice -> asciugatrice individuate: %d\n', ...
    numeroTotaleSequenze);

categorie = [ ...
    "Ravvicinata", ...
    "Differita", ...
    "Molto differita"];

for c = 1:length(categorie)

    idxCategoria = ...
        SequenzeLavatriceAsciugatrice.Categoria == categorie(c);

    numeroCategoria = ...
        sum(idxCategoria);

    percentualeCategoria = ...
        100 * numeroCategoria / numeroTotaleSequenze;

    fprintf( ...
        '%s: %d (%.2f%%)\n', ...
        categorie(c), ...
        numeroCategoria, ...
        percentualeCategoria);

end

% Calcolo gli indicatori temporali complessivi
fprintf('\nIndicatori temporali complessivi\n');

fprintf( ...
    'Distanza media: %s\n', ...
    char(mean(distanzaTemporale)));

fprintf( ...
    'Distanza mediana: %s\n', ...
    char(median(distanzaTemporale)));

fprintf( ...
    'Distanza minima: %s\n', ...
    char(min(distanzaTemporale)));

fprintf( ...
    'Distanza massima: %s\n', ...
    char(max(distanzaTemporale)));


%% Creazione della tabella delle sequenze

% Calcolo il numero totale di sequenze individuate

numeroSequenze = length(sessioneLavatriceAssociata);

% Creo il numero progressivo delle sequenze

numeroSequenza = (1:numeroSequenze)';

% Estraggo la data di conclusione della lavatrice

dataSequenza = dateshift(fineLavatriceAssociata, "start", "day");

% Creo la tabella contenente tutte

% le associazioni temporali individuate

SequenzeLavatriceAsciugatrice = table(  numeroSequenza, ...
                                        sessioneLavatriceAssociata, ...
                                        fineLavatriceAssociata, ...
                                        sessioneAsciugatriceAssociata, ...
                                        inizioAsciugatriceAssociata, ...
                                        distanzaTemporale, ...
                                        categoriaSequenza, ...
                                        dataSequenza      );

% Assegno i nomi alle colonne

SequenzeLavatriceAsciugatrice.Properties.VariableNames = {  'NumeroSequenza', ...
                                                            'EventoLavatrice', ...
                                                            'FineLavatrice', ...
                                                            'EventoAsciugatrice', ...
                                                            'InizioAsciugatrice', ...
                                                            'DistanzaTemporale', ...
                                                            'Categoria', ...
                                                            'Data'     };

%% Riepilogo delle sequenze individuate

% Calcolo il numero di sequenze appartenenti
% a ciascuna categoria temporale

RiepilogoCategorieSequenza = groupcounts( SequenzeLavatriceAsciugatrice, ...
                                          "Categoria"                        );

%% Visualizzazione grafica della tabella delle sequenze

% Calcolo il numero totale di sequenze individuate

numeroTotaleSequenze = height(SequenzeLavatriceAsciugatrice);

% Converto ogni colonna nel formato compatibile con uitable

% Converto i numeri progressivi in celle numeriche

colonnaNumeroSequenza = num2cell(SequenzeLavatriceAsciugatrice.NumeroSequenza);

% Converto i numeri degli eventi della lavatrice in celle numeriche

colonnaEventoLavatrice = num2cell(SequenzeLavatriceAsciugatrice.EventoLavatrice);

% Converto i timestamp finali della lavatrice

% in celle contenenti vettori di caratteri

colonnaFineLavatrice = cellstr( string(SequenzeLavatriceAsciugatrice.FineLavatrice, ...
                                "dd/MM/yyyy HH:mm:ss"));

% Converto i numeri degli eventi dell'asciugatrice

% in celle numeriche

colonnaEventoAsciugatrice = num2cell(SequenzeLavatriceAsciugatrice.EventoAsciugatrice);

% Converto i timestamp iniziali dell'asciugatrice

% in celle contenenti vettori di caratteri

colonnaInizioAsciugatrice = cellstr( ...
    string(SequenzeLavatriceAsciugatrice.InizioAsciugatrice, "dd/MM/yyyy HH:mm:ss"));

% Converto le distanze temporali nel formato ore:minuti:secondi

distanzeFormattate = string(    SequenzeLavatriceAsciugatrice.DistanzaTemporale, ...
                                "hh:mm:ss"  );

% Converto le distanze in celle di caratteri

colonnaDistanzaTemporale = cellstr(distanzeFormattate);

% Converto le categorie in celle di caratteri

colonnaCategoria = cellstr(string(SequenzeLavatriceAsciugatrice.Categoria));

% Converto le date in celle di caratteri

colonnaData = cellstr(string(SequenzeLavatriceAsciugatrice.Data, "dd/MM/yyyy"));

% Unisco tutte le colonne in un'unica cell array

% compatibile con la tabella grafica

datiTabellaGrafica = [  colonnaNumeroSequenza, ...
                        colonnaEventoLavatrice, ... 
                        colonnaFineLavatrice, ...
                        colonnaEventoAsciugatrice, ...
                        colonnaInizioAsciugatrice, ...
                        colonnaDistanzaTemporale, ...
                        colonnaCategoria, ...
                        colonnaData                    ];

%% Creazione della finestra grafica

% Creo una nuova finestra

figuraSequenze = figure(    "Name", "Sequenze lavatrice - asciugatrice", ...
                            "NumberTitle", "off", "Position", [100 100 1250 650]    );

% Inserisco il titolo e il numero totale di sequenze

annotation( figuraSequenze, "textbox", [0.02 0.92 0.96 0.06], "String", ...
            "Sequenze lavatrice → asciugatrice individuate: " + ...
            string(numeroTotaleSequenze), "HorizontalAlignment", "center", ...
            "FontSize", 14, "FontWeight", "bold", "EdgeColor", "none"   );

% Creo la tabella grafica

tabellaGrafica = uitable(   figuraSequenze, "Data", datiTabellaGrafica, ...
                            "ColumnName", { 'NumeroSequenza', ...
                                            'EventoLavatrice', ...
                                            'FineLavatrice', ...
                                            'EventoAsciugatrice', ...
                                            'InizioAsciugatrice', ...
                                            'DistanzaTemporale', ...
                                            'Categoria', ...
                                            'Data'}, ...
                            "RowName", [], "Units", "normalized", ...
                            "Position", [0.02 0.05 0.96 0.85]);

% Imposto la larghezza delle colonne

tabellaGrafica.ColumnWidth = {  100, ...
                                110, ...
                                170, ...
                                130, ...
                                170, ...
                                130, ...
                                120, ...
                                100         };

%% Analisi della potenza non monitorata

% Definisco gli elettrodomestici dotati
% di un sensore individuale di potenza
nomiMonitorati = { ...
    'lavatrice', ...
    'lavastoviglie', ...
    'frigo', ...
    'asciugatrice', ...
    'hvac1', ...
    'hvac2'};

% Calcolo il numero degli elettrodomestici monitorati
numeroMonitorati = length(nomiMonitorati);

% Definisco la distanza temporale massima accettata
% tra un campione dell'aggregato e il campione più vicino
% del singolo elettrodomestico
tolleranzaMassima = minutes(5);


%% Definizione del segnale temporale di riferimento

% Estraggo il segnale aggregato relativo ai giorni comuni
TAggregato = Comuni.dati.aggregato;

% Ordino cronologicamente i campioni aggregati
TAggregato = sortrows(TAggregato, 'Timestamp');

% Elimino eventuali timestamp duplicati
[~, indiciUnici] = unique( ...
    TAggregato.Timestamp, ...
    'stable');

TAggregato = TAggregato(indiciUnici, :);

% Utilizzo i timestamp dell'aggregato
% come base temporale di riferimento
timestampRiferimento = TAggregato.Timestamp;

% Estraggo la potenza aggregata
potenzaAggregata = TAggregato.P;

% Calcolo il numero dei campioni di riferimento
numeroCampioni = height(TAggregato);


%% Ricerca del campione più vicino per ogni elettrodomestico

% Inizializzo una matrice con valori non disponibili
%
% righe   = timestamp dell'aggregato
% colonne = elettrodomestici monitorati
potenzeAllineate = ...
    NaN(numeroCampioni, numeroMonitorati);

% Utilizzo il primo timestamp dell'aggregato
% come origine temporale per i calcoli
origineTemporale = timestampRiferimento(1);

% Converto i timestamp dell'aggregato
% in secondi rispetto all'origine temporale
tempoRiferimentoSecondi = ...
    seconds(timestampRiferimento - origineTemporale);

% Scorro tutti gli elettrodomestici monitorati
for e = 1:numeroMonitorati

    % Recupero il nome dell'elettrodomestico corrente
    nome = nomiMonitorati{e};

    % Estraggo i dati relativi ai giorni comuni
    T = Comuni.dati.(nome);

    % Ordino cronologicamente i campioni
    T = sortrows(T, 'Timestamp');

    % Elimino eventuali timestamp duplicati
    [~, indiciUnici] = unique( ...
        T.Timestamp, ...
        'stable');

    T = T(indiciUnici, :);

    % Converto i timestamp del segnale corrente
    % in secondi rispetto alla stessa origine
    tempoSegnaleSecondi = ...
        seconds(T.Timestamp - origineTemporale);

    % Creo il vettore degli indici dei campioni
    indiciSegnale = (1:height(T))';

    % Per ogni timestamp dell'aggregato individuo
    % l'indice del campione temporalmente più vicino
    indiceVicino = interp1( ...
        tempoSegnaleSecondi, ...
        indiciSegnale, ...
        tempoRiferimentoSecondi, ...
        'nearest', ...
        NaN);

    % Individuo i timestamp per cui
    % è stato trovato un campione vicino
    righeConIndice = ~isnan(indiceVicino);

    % Converto gli indici validi in numeri interi
    indiceVicinoValido = ...
        round(indiceVicino(righeConIndice));

    % Calcolo la distanza temporale tra
    % il campione dell'aggregato e quello individuato
    distanzaTemporale = abs( ...
        timestampRiferimento(righeConIndice) - ...
        T.Timestamp(indiceVicinoValido));

    % Mantengo solamente gli abbinamenti
    % che rispettano la tolleranza stabilita
    associazioneValida = ...
        distanzaTemporale <= tolleranzaMassima;

    % Recupero le posizioni originali
    % dei timestamp di riferimento
    posizioniRiferimento = find(righeConIndice);

    % Mantengo soltanto le posizioni valide
    posizioniValide = ...
        posizioniRiferimento(associazioneValida);

    % Mantengo gli indici validi del segnale corrente
    indiciValidiSegnale = ...
        indiceVicinoValido(associazioneValida);

    % Inserisco nella matrice la potenza
    % del campione più vicino
    potenzeAllineate(posizioniValide, e) = ...
        T.P(indiciValidiSegnale);

end


%% Selezione dei timestamp completamente confrontabili

% Individuo i timestamp per i quali sono disponibili
% contemporaneamente aggregato e tutti gli elettrodomestici
righeValide = ...
    ~isnan(potenzaAggregata) & ...
    all(~isnan(potenzeAllineate), 2);

% Mantengo soltanto i timestamp validi
timestampValidi = ...
    timestampRiferimento(righeValide);

% Mantengo la potenza aggregata valida
potenzaAggregataValida = ...
    potenzaAggregata(righeValide);

% Mantengo le potenze individuali valide
potenzeMonitorateValide = ...
    potenzeAllineate(righeValide, :);


%% Calcolo della potenza non monitorata

% Sommo le potenze dei sei elettrodomestici
potenzaMonitorata = ...
    sum(potenzeMonitorateValide, 2);

% Calcolo il residuo grezzo
potenzaResidua = ...
    potenzaAggregataValida - potenzaMonitorata;

% Impongo a zero i residui negativi per ottenere
% una stima fisicamente ammissibile della potenza
% attribuibile ai carichi non monitorati
potenzaNonMonitorata = ...
    max(potenzaResidua, 0);

% Calcolo la parte della potenza aggregata
% effettivamente spiegata dai sensori individuali
potenzaSpiegata = ...
    min(potenzaMonitorata, potenzaAggregataValida);


%% Creazione della tabella dei risultati

% Creo la tabella contenente i risultati
PotenzaNonMonitorata = table( ...
    timestampValidi, ...
    potenzaAggregataValida, ...
    potenzaMonitorata, ...
    potenzaSpiegata, ...
    potenzaResidua, ...
    potenzaNonMonitorata);

% Assegno i nomi alle colonne
PotenzaNonMonitorata.Properties.VariableNames = { ...
    'Timestamp', ...
    'PotenzaAggregata', ...
    'PotenzaMonitorata', ...
    'PotenzaSpiegata', ...
    'PotenzaResidua', ...
    'PotenzaNonMonitorata'};


%% Calcolo delle statistiche principali

% Calcolo la potenza aggregata media
potenzaAggregataMedia = ...
    mean(potenzaAggregataValida);

% Calcolo la potenza monitorata media
potenzaMonitorataMedia = ...
    mean(potenzaMonitorata);

% Calcolo la potenza non monitorata media
potenzaNonMonitorataMedia = ...
    mean(potenzaNonMonitorata);

% Calcolo la potenza non monitorata massima
potenzaNonMonitorataMassima = ...
    max(potenzaNonMonitorata);

% Calcolo il numero dei residui negativi
numeroResiduiNegativi = ...
    sum(potenzaResidua < 0);

% Calcolo la percentuale dei residui negativi
percentualeResiduiNegativi = ...
    100 * numeroResiduiNegativi / ...
    length(potenzaResidua);

% Calcolo la percentuale dei timestamp dell'aggregato
% per cui è stato possibile allineare tutti i segnali
percentualeCampioniUtilizzati = ...
    100 * sum(righeValide) / numeroCampioni;


%% Calcolo delle energie giorno per giorno

% Estraggo la data di ciascun timestamp valido
dateValide = ...
    dateshift(timestampValidi, 'start', 'day');

% Individuo i giorni effettivamente utilizzati
giorniValidi = unique(dateValide);

% Inizializzo le energie complessive
energiaAggregata_Wh = 0;
energiaSpiegata_Wh = 0;
energiaNonMonitorata_Wh = 0;

% Scorro tutti i giorni validi
for g = 1:length(giorniValidi)

    % Seleziono i campioni del giorno corrente
    righeGiorno = ...
        dateValide == giorniValidi(g);

    % Estraggo i timestamp giornalieri
    tempoGiorno = ...
        timestampValidi(righeGiorno);

    % Verifico che siano presenti almeno due campioni
    if length(tempoGiorno) < 2

        continue

    end

    % Converto il tempo in ore rispetto
    % al primo campione della giornata
    tempoOre = ...
        hours(tempoGiorno - tempoGiorno(1));

    % Integro la potenza aggregata
    % per ottenere l'energia giornaliera
    energiaAggregata_Wh = ...
        energiaAggregata_Wh + ...
        trapz(tempoOre, ...
              potenzaAggregataValida(righeGiorno));

    % Integro la potenza spiegata
    energiaSpiegata_Wh = ...
        energiaSpiegata_Wh + ...
        trapz(tempoOre, ...
              potenzaSpiegata(righeGiorno));

    % Integro la potenza non monitorata
    energiaNonMonitorata_Wh = ...
        energiaNonMonitorata_Wh + ...
        trapz(tempoOre, ...
              potenzaNonMonitorata(righeGiorno));

end

% Calcolo la copertura energetica del monitoraggio
coperturaMonitoraggio = ...
    100 * energiaSpiegata_Wh / energiaAggregata_Wh;

% Calcolo la percentuale di energia non monitorata
percentualeEnergiaNonMonitorata = ...
    100 * energiaNonMonitorata_Wh / ...
    energiaAggregata_Wh;


%% Riepilogo numerico della potenza non monitorata

fprintf('\n===== POTENZA NON MONITORATA - UTENTE 1 =====\n');

fprintf('Campioni aggregato disponibili: %d\n', ...
    numeroCampioni);

fprintf('Campioni completamente confrontabili: %d\n', ...
    sum(righeValide));

fprintf('Campioni utilizzati: %.2f%%\n', ...
    percentualeCampioniUtilizzati);

fprintf('\n--- POTENZE ---\n');

fprintf('Potenza aggregata media: %.2f W\n', ...
    potenzaAggregataMedia);

fprintf('Potenza monitorata media: %.2f W\n', ...
    potenzaMonitorataMedia);

fprintf('Potenza non monitorata media: %.2f W\n', ...
    potenzaNonMonitorataMedia);

fprintf('Potenza non monitorata massima: %.2f W\n', ...
    potenzaNonMonitorataMassima);

fprintf('\n--- RESIDUI ---\n');

fprintf('Residui negativi: %d (%.2f%%)\n', ...
    numeroResiduiNegativi, ...
    percentualeResiduiNegativi);

fprintf('\n--- ENERGIE ---\n');

fprintf('Energia aggregata: %.2f kWh\n', ...
    energiaAggregata_Wh / 1000);

fprintf('Energia spiegata: %.2f kWh\n', ...
    energiaSpiegata_Wh / 1000);

fprintf('Energia non monitorata: %.2f kWh\n', ...
    energiaNonMonitorata_Wh / 1000);

fprintf('\nCopertura energetica del monitoraggio: %.2f%%\n', ...
    coperturaMonitoraggio);

fprintf('Energia non monitorata: %.2f%%\n', ...
    percentualeEnergiaNonMonitorata);

fprintf('=============================================\n');

%% Rappresentazione della potenza non monitorata

% Estraggo i timestamp della tabella dei risultati

tempoPlot = PotenzaNonMonitorata.Timestamp;

% Estraggo i valori della potenza non monitorata

potenzaPlot = PotenzaNonMonitorata.PotenzaNonMonitorata;

% Calcolo la distanza temporale tra campioni consecutivi

saltiTemporali = diff(tempoPlot);

% Individuo i punti in cui il salto temporale

% tra due campioni consecutivi supera un'ora

indiciSalto = find(saltiTemporali > hours(1));

% Inserisco valori mancanti in corrispondenza dei salti temporali,

% in modo da evitare che MATLAB colleghi periodi non consecutivi

for k = flip(indiciSalto')

    % Inserisco un timestamp mancante dopo il campione precedente al salto

    tempoPlot = [ ...

        tempoPlot(1:k); ...

        NaT(1, 1, 'TimeZone', tempoPlot.TimeZone); ...

        tempoPlot(k + 1:end)];

    % Inserisco un valore NaN nella potenza,

    % così il grafico interrompe la linea

    potenzaPlot = [ ...

        potenzaPlot(1:k); ...

        NaN; ...

        potenzaPlot(k + 1:end)];

end

% Creo una nuova figura dedicata

% all'analisi della potenza non monitorata

figure( 'Name', 'Analisi della potenza non monitorata', ...
        'NumberTitle', 'off')

% Divido la figura in tre riquadri disposti verticalmente

tiledlayout(2, 1)

%% Andamento temporale

% Seleziono il primo riquadro

nexttile

% Rappresento l'andamento della potenza non monitorata,

% interrompendo la linea nei periodi privi di dati

plot( tempoPlot, potenzaPlot, 'LineWidth', 1)

% Attivo la griglia

grid on

% Inserisco l'etichetta dell'asse orizzontale

xlabel('Tempo')

% Inserisco l'etichetta dell'asse verticale

ylabel('Potenza [W]')

% Inserisco il titolo

title('Andamento della potenza non monitorata')

%% Distribuzione dei valori

% Seleziono il secondo riquadro

nexttile

% Calcolo il percentile 99,5 della potenza non monitorata,

% per escludere dalla sola rappresentazione gli estremi più elevati

limiteIstogramma = prctile( PotenzaNonMonitorata.PotenzaNonMonitorata, 99.5);

% Mantengo i valori inferiori o uguali al percentile scelto

valoriIstogramma =  PotenzaNonMonitorata.PotenzaNonMonitorata( ...
                    PotenzaNonMonitorata.PotenzaNonMonitorata <= limiteIstogramma);

% Creo l'istogramma della distribuzione

histogram(valoriIstogramma)

% Attivo la griglia

grid on

% Inserisco l'etichetta dell'asse orizzontale

xlabel('Potenza non monitorata [W]')

% Inserisco l'etichetta dell'asse verticale

ylabel('Numero di campioni')

% Inserisco il titolo

title('Distribuzione della potenza non monitorata')

%% Indicatori generali del profilo di consumo

% Inizializzo la struttura che conterrà
% le caratteristiche di ogni singolo evento
CaratteristicheEventi = struct();

% Estraggo i nomi degli elettrodomestici
% presenti nella struttura EventiDefinitivi
nomiElettrodomestici = fieldnames(EventiDefinitivi);

% Calcolo il numero totale degli elettrodomestici
numeroElettrodomestici = length(nomiElettrodomestici);


%% Inizializzazione dei risultati

% Creo il vettore contenente
% il nome di ogni elettrodomestico
nomeRiepilogo = strings(numeroElettrodomestici, 1);

% Inizializzo il numero totale di eventi
numeroEventiRiepilogo = zeros(numeroElettrodomestici, 1);

% Inizializzo le durate medie
durataMediaRiepilogo = duration( ...
    zeros(numeroElettrodomestici, 1), ...
    zeros(numeroElettrodomestici, 1), ...
    zeros(numeroElettrodomestici, 1));

% Inizializzo le durate minime
durataMinimaRiepilogo = durataMediaRiepilogo;

% Inizializzo le durate massime
durataMassimaRiepilogo = durataMediaRiepilogo;

% Inizializzo le potenze medie
potenzaMediaRiepilogo = ...
    NaN(numeroElettrodomestici, 1);

% Inizializzo le potenze massime
potenzaMassimaRiepilogo = ...
    NaN(numeroElettrodomestici, 1);

% Inizializzo le energie medie
energiaMediaRiepilogo = ...
    NaN(numeroElettrodomestici, 1);

% Inizializzo le energie minime
energiaMinimaRiepilogo = ...
    NaN(numeroElettrodomestici, 1);

% Inizializzo le energie massime
energiaMassimaRiepilogo = ...
    NaN(numeroElettrodomestici, 1);

% Inizializzo le energie totali
energiaTotaleRiepilogo = ...
    NaN(numeroElettrodomestici, 1);


%% Calcolo delle caratteristiche dei singoli eventi

% Scorro tutti gli elettrodomestici
for e = 1:numeroElettrodomestici

    % Recupero il nome dell'elettrodomestico corrente
    nome = nomiElettrodomestici{e};

    % Salvo il nome per la rappresentazione finale
    nomeRiepilogo(e) = string(nome);

    % Estraggo gli eventi definitivi
    % dell'elettrodomestico corrente
    TEventi = EventiDefinitivi.(nome);

    % Estraggo i campioni originali di potenza
    TDati = dati.(nome);

    % Ordino cronologicamente i campioni
    TDati = sortrows(TDati, 'Timestamp');

    % Calcolo il numero totale degli eventi
    numeroEventi = height(TEventi);

    % Salvo il numero degli eventi
    numeroEventiRiepilogo(e) = numeroEventi;

    % Inizializzo la potenza media
    % di ciascun evento
    potenzaMediaEvento = ...
        NaN(numeroEventi, 1);

    % Inizializzo la potenza massima
    % di ciascun evento
    potenzaMassimaEvento = ...
        NaN(numeroEventi, 1);

    % Inizializzo l'energia
    % associata a ciascun evento
    energiaEvento_Wh = ...
        NaN(numeroEventi, 1);

    % Inizializzo il numero di campioni
    % utilizzati per ciascun evento
    numeroCampioniEvento = ...
        zeros(numeroEventi, 1);

    % Scorro tutti gli eventi definitivi
    for k = 1:numeroEventi

        % Recupero l'istante iniziale dell'evento
        timestampInizio = ...
            TEventi.TimestampInizio(k);

        % Recupero l'istante finale dell'evento
        timestampFine = ...
            TEventi.TimestampFine(k);

        % Individuo i campioni compresi
        % nell'intervallo dell'evento
        righeEvento = ...
            TDati.Timestamp >= timestampInizio & ...
            TDati.Timestamp <= timestampFine;

        % Estraggo i campioni appartenenti all'evento
        TEvento = TDati(righeEvento, :);

        % Salvo il numero di campioni disponibili
        numeroCampioniEvento(k) = ...
            height(TEvento);

        % Se non sono presenti campioni
        % passo all'evento successivo
        if isempty(TEvento)

            continue

        end

        % Calcolo la potenza media dell'evento
        potenzaMediaEvento(k) = ...
            mean(TEvento.P);

        % Calcolo la potenza massima dell'evento
        potenzaMassimaEvento(k) = ...
            max(TEvento.P);

        % Se sono presenti almeno due campioni
        % calcolo l'energia mediante integrazione
        if height(TEvento) >= 2

            % Converto il tempo in ore rispetto
            % al primo campione dell'evento
            tempoEventoOre = hours( ...
                TEvento.Timestamp - ...
                TEvento.Timestamp(1));

            % Integro la potenza nel tempo
            % ottenendo l'energia in Wh
            energiaEvento_Wh(k) = trapz( ...
                tempoEventoOre, ...
                TEvento.P);

        else

            % Se è presente un solo campione,
            % utilizzo la durata complessiva dell'evento
            durataEventoOre = ...
                hours(TEventi.Durata(k));

            % Stimo l'energia come potenza per durata
            energiaEvento_Wh(k) = ...
                TEvento.P(1) * durataEventoOre;

        end

    end


    %% Salvataggio delle caratteristiche dei singoli eventi

    % Creo una copia della tabella degli eventi definitivi
    tabellaCaratteristiche = TEventi;

    % Aggiungo il numero di campioni utilizzati
    tabellaCaratteristiche.NumeroCampioni = ...
        numeroCampioniEvento;

    % Aggiungo la potenza media
    tabellaCaratteristiche.PotenzaMedia_W = ...
        potenzaMediaEvento;

    % Aggiungo la potenza massima
    tabellaCaratteristiche.PotenzaMassima_W = ...
        potenzaMassimaEvento;

    % Aggiungo l'energia dell'evento
    tabellaCaratteristiche.Energia_Wh = ...
        energiaEvento_Wh;

    % Salvo le caratteristiche nella struttura
    % che verrà utilizzata nelle analisi successive
    CaratteristicheEventi.(nome) = ...
        tabellaCaratteristiche;


    %% Calcolo degli indicatori generali

    % Se non sono presenti eventi
    % passo all'elettrodomestico successivo
    if numeroEventi == 0

        continue

    end

    % Calcolo la durata media
    durataMediaRiepilogo(e) = ...
        mean(TEventi.Durata);

    % Calcolo la durata minima
    durataMinimaRiepilogo(e) = ...
        min(TEventi.Durata);

    % Calcolo la durata massima
    durataMassimaRiepilogo(e) = ...
        max(TEventi.Durata);

    % Calcolo la potenza media
    potenzaMediaRiepilogo(e) = ...
        mean(potenzaMediaEvento, 'omitnan');

    % Calcolo la potenza massima
    potenzaMassimaRiepilogo(e) = ...
        max(potenzaMassimaEvento, [], 'omitnan');

    % Calcolo l'energia media per evento
    energiaMediaRiepilogo(e) = ...
        mean(energiaEvento_Wh, 'omitnan');

    % Calcolo l'energia minima per evento
    energiaMinimaRiepilogo(e) = ...
        min(energiaEvento_Wh, [], 'omitnan');

    % Calcolo l'energia massima per evento
    energiaMassimaRiepilogo(e) = ...
        max(energiaEvento_Wh, [], 'omitnan');

    % Calcolo l'energia totale
    energiaTotaleRiepilogo(e) = ...
        sum(energiaEvento_Wh, 'omitnan');

end


%% Preparazione dei dati per la rappresentazione

% Converto i nomi degli elettrodomestici
% in un formato compatibile con uitable
colonnaElettrodomestico = ...
    cellstr(nomeRiepilogo);

% Converto il numero degli eventi
% in celle numeriche
colonnaNumeroEventi = ...
    num2cell(numeroEventiRiepilogo);

% Converto le durate medie
% nel formato ore:minuti:secondi
colonnaDurataMedia = cellstr( ...
    string(durataMediaRiepilogo, ...
           'hh:mm:ss'));

% Converto le durate minime
colonnaDurataMinima = cellstr( ...
    string(durataMinimaRiepilogo, ...
           'hh:mm:ss'));

% Converto le durate massime
colonnaDurataMassima = cellstr( ...
    string(durataMassimaRiepilogo, ...
           'hh:mm:ss'));

% Converto le potenze medie
% in celle numeriche
colonnaPotenzaMedia = ...
    num2cell(potenzaMediaRiepilogo);

% Converto le potenze massime
colonnaPotenzaMassima = ...
    num2cell(potenzaMassimaRiepilogo);

% Converto le energie medie
colonnaEnergiaMedia = ...
    num2cell(energiaMediaRiepilogo);

% Converto le energie minime
colonnaEnergiaMinima = ...
    num2cell(energiaMinimaRiepilogo);

% Converto le energie massime
colonnaEnergiaMassima = ...
    num2cell(energiaMassimaRiepilogo);

% Converto le energie totali
colonnaEnergiaTotale = ...
    num2cell(energiaTotaleRiepilogo);

% Riunisco tutte le informazioni
% in una cell array compatibile con uitable
datiTabellaGrafica = [ ...
    colonnaElettrodomestico, ...
    colonnaNumeroEventi, ...
    colonnaDurataMedia, ...
    colonnaDurataMinima, ...
    colonnaDurataMassima, ...
    colonnaPotenzaMedia, ...
    colonnaPotenzaMassima, ...
    colonnaEnergiaMedia, ...
    colonnaEnergiaMinima, ...
    colonnaEnergiaMassima, ...
    colonnaEnergiaTotale];


%% Rappresentazione degli indicatori generali

% Creo una nuova finestra
figuraProfili = figure( ...
    'Name', ...
    'Indicatori generali del profilo di consumo', ...
    'NumberTitle', ...
    'off', ...
    'Position', ...
    [50 150 1450 450]);

% Inserisco il titolo della finestra
annotation( ...
    figuraProfili, ...
    'textbox', ...
    [0.02 0.90 0.96 0.08], ...
    'String', ...
    'Indicatori generali del profilo di consumo', ...
    'HorizontalAlignment', ...
    'center', ...
    'FontSize', ...
    14, ...
    'FontWeight', ...
    'bold', ...
    'EdgeColor', ...
    'none');

% Creo la tabella grafica contenente
% una riga per ogni elettrodomestico
tabellaGraficaProfili = uitable( ...
    figuraProfili, ...
    'Data', ...
    datiTabellaGrafica, ...
    'ColumnName', { ...
        'Elettrodomestico', ...
        'N. eventi', ...
        'Durata media', ...
        'Durata min', ...
        'Durata max', ...
        'P media [W]', ...
        'P max [W]', ...
        'E media [Wh]', ...
        'E minima [Wh]', ...
        'E massima [Wh]', ...
        'E totale [Wh]'}, ...
    'RowName', ...
    [], ...
    'Units', ...
    'normalized', ...
    'Position', ...
    [0.02 0.08 0.96 0.80]);

% Imposto la larghezza delle colonne
tabellaGraficaProfili.ColumnWidth = { ...
    110, ...
    90, ...
    100, ...
    100, ...
    100, ...
    120, ...
    130, ...
    120, ...
    120, ...
    130, ...
    120};

%% Controllo coerenza eventi prima dell'analisi delle durate

disp("CONTROLLO PRIMA DELLA DISTRIBUZIONE DELLE DURATE")

disp("EventiDefinitivi lavatrice:")

disp(height(EventiDefinitivi.lavatrice))

disp("CaratteristicheEventi lavatrice:")

disp(height(CaratteristicheEventi.lavatrice))

%% Analisi della distribuzione delle durate

% Estraggo i nomi degli elettrodomestici

% presenti nella struttura CaratteristicheEventi

nomiElettrodomestici = fieldnames(CaratteristicheEventi);

% Scorro tutti gli elettrodomestici

for e = 1:length(nomiElettrodomestici)

    % Recupero il nome dell'elettrodomestico corrente

    nome = nomiElettrodomestici{e};

    % Estraggo la tabella contenente

    % le caratteristiche degli eventi

    T = CaratteristicheEventi.(nome);

    % Converto la durata degli eventi

    % da duration a minuti

    durataMinuti = minutes(T.Durata);

    % Elimino eventuali valori non validi

    durataMinuti = durataMinuti(~isnan(durataMinuti));

    % Se non sono presenti durate valide

    % passo all'elettrodomestico successivo

    if isempty(durataMinuti)

        continue

    end

    % Calcolo la durata media degli eventi

    durataMedia = mean(durataMinuti);

    % Calcolo la durata mediana

    durataMediana = median(durataMinuti);

    % Calcolo la deviazione standard,

    % utile per valutare la dispersione delle durate

    deviazioneStandard = std(durataMinuti);

    % Calcolo il primo quartile

    primoQuartile = prctile(durataMinuti, 25);

    % Calcolo il terzo quartile

    terzoQuartile = prctile(durataMinuti, 75);

    %% Creazione della figura

    % Creo una nuova finestra grafica

    % dedicata all'elettrodomestico corrente

    figure( 'Name', 'Distribuzione durate - ' + string(nome), 'NumberTitle', 'off')

    % Divido la figura in due riquadri

    tiledlayout(2, 1)

    %% Riquadro delle statistiche

    % Seleziono il primo riquadro

    nexttile

    % Nascondo gli assi

    % perché verranno visualizzati solo dati testuali

    axis off

    % Creo il testo contenente

    % le statistiche principali

    testoStatistiche = {

        ['Elettrodomestico: ', char(nome)]

        ['Numero eventi: ', num2str(length(durataMinuti))]

        ['Durata media: ', num2str(durataMedia, '%.2f'), ' min']

        ['Durata mediana: ', num2str(durataMediana, '%.2f'), ' min']

        ['Deviazione standard: ', num2str(deviazioneStandard, '%.2f'), ' min']

        ['Primo quartile: ', num2str(primoQuartile, '%.2f'), ' min']

        ['Terzo quartile: ', num2str(terzoQuartile, '%.2f'), ' min']

        };

    % Visualizzo le statistiche

    % nella parte superiore della figura

    text( 0, 0.5, testoStatistiche, 'FontSize', 11)

    %% Istogramma delle durate

    % Seleziono il secondo riquadro

    nexttile

    % Rappresento la distribuzione

    % delle durate mediante un istogramma

    histogram(durataMinuti)

    % Attivo la griglia

    grid on

    % Inserisco l'etichetta dell'asse orizzontale

    xlabel('Durata evento [min]')

    % Inserisco l'etichetta dell'asse verticale

    ylabel('Numero di eventi')

    % Inserisco il titolo del grafico

    title( 'Distribuzione delle durate - ' + string(nome))

end

%% Identificazione automatica delle modalità operative

% Definisco gli elettrodomestici per i quali
% viene effettuata l'identificazione di modalità o regimi operativi
elettrodomesticiProgramma = { ...
    'lavatrice', ...
    'lavastoviglie', ...
    'asciugatrice', ...
    'hvac1', ...
    'hvac2'};

% Inizializzo la struttura che conterrà
% i risultati dell'analisi
ModalitaOperative = struct();

% Definisco il numero massimo di modalità
% che l'algoritmo può individuare
numeroMassimoModalita = 5;

% Definisco il valore minimo di silhouette
% richiesto per accettare la presenza di più gruppi
sogliaSilhouette = 0.25;

% Fisso il generatore di numeri casuali
% per rendere riproducibile il clustering
rng(1);

%% Analisi dei singoli elettrodomestici


% Scorro gli elettrodomestici a programma
for e = 1:length(elettrodomesticiProgramma)

    % Recupero il nome dell'elettrodomestico corrente
    nome = elettrodomesticiProgramma{e};

    % Estraggo la tabella contenente
    % le caratteristiche dei singoli eventi
    T = CaratteristicheEventi.(nome);

    % Converto la durata degli eventi in minuti
    durataMinuti = minutes(T.Durata);

    % Estraggo la potenza media degli eventi
    potenzaMedia = T.PotenzaMedia_W;

    % Estraggo l'energia associata agli eventi
    energiaEvento = T.Energia_Wh;

    % Creo la matrice delle caratteristiche
    %
    % colonna 1 = durata
    % colonna 2 = potenza media
    % colonna 3 = energia
    caratteristiche = [ ...
        durataMinuti, ...
        potenzaMedia, ...
        energiaEvento];

    % Individuo gli eventi con tutte
    % le caratteristiche disponibili e fisicamente valide
    eventiValidi = ...
        all(isfinite(caratteristiche), 2) & ...
        durataMinuti > 0 & ...
        potenzaMedia >= 0 & ...
        energiaEvento >= 0;

    % Estraggo solamente le caratteristiche valide
    X = caratteristiche(eventiValidi, :);

    % Calcolo il numero di eventi validi
    numeroEventiValidi = size(X, 1);

    % Verifico che siano presenti eventi sufficienti
    % per eseguire l'analisi
    if numeroEventiValidi < 3

        warning( ...
            'Eventi insufficienti per analizzare %s.', ...
            nome)

        continue

    end


    %% Normalizzazione delle caratteristiche

    % Calcolo la mediana di ciascuna caratteristica
    centro = median(X, 1);

    % Calcolo il primo quartile
    primoQuartile = prctile(X, 25, 1);

    % Calcolo il terzo quartile
    terzoQuartile = prctile(X, 75, 1);

    % Calcolo l'intervallo interquartile
    scala = terzoQuartile - primoQuartile;

    % Individuo le caratteristiche con
    % intervallo interquartile nullo
    scalaNulla = scala == 0;

    % Per tali caratteristiche utilizzo
    % la deviazione standard come scala alternativa
    scala(scalaNulla) = std(X(:, scalaNulla), 0, 1);

    % Evito divisioni per zero nel caso
    % di caratteristiche completamente costanti
    scala(scala == 0) = 1;

    % Normalizzo le caratteristiche
    % rendendole confrontabili tra loro
    Xnormalizzata = ...
        (X - centro) ./ scala;
    
    %% Verifica diagnostica della lavastoviglie con k = 3

if strcmp(nome, 'lavastoviglie')

    % Forzo temporaneamente tre gruppi
    gruppoTest3 = kmeans( ...
        Xnormalizzata, ...
        3, ...
        'Replicates', ...
        50, ...
        'MaxIter', ...
        1000, ...
        'Display', ...
        'off');

    % Calcolo la silhouette della soluzione a tre gruppi
    silhouetteTest3 = silhouette( ...
        Xnormalizzata, ...
        gruppoTest3);

    fprintf('\nLAVASTOVIGLIE - CONTROLLO k = 3\n');
    fprintf( ...
        'Silhouette media: %.4f\n', ...
        mean(silhouetteTest3));

    % Numero di eventi per ciascun gruppo
    for g = 1:3

        fprintf( ...
            'Gruppo %d: %d eventi (%.2f%%)\n', ...
            g, ...
            sum(gruppoTest3 == g), ...
            100 * sum(gruppoTest3 == g) / length(gruppoTest3));

    end

    % Rappresentazione durata-energia
    figure
    hold on

    for g = 1:3

        idx = gruppoTest3 == g;

        scatter( ...
            X(idx,1), ...
            X(idx,3), ...
            36, ...
            'filled', ...
            'DisplayName', ...
            ['Gruppo ', num2str(g)])

    end

    set(gca, ...
        'XScale', 'log', ...
        'YScale', 'log')

    grid on

    xlabel('Durata [min]')
    ylabel('Energia [Wh]')

    title( ...
        'Lavastoviglie - verifica della soluzione con 3 gruppi')

    legend( ...
        'show', ...
        'Location', ...
        'best')

    hold off

end

    %% Scelta automatica del numero di modalità

    % Il numero massimo di gruppi non può superare
    % il numero di eventi disponibili meno uno
    massimoK = min( ...
        numeroMassimoModalita, ...
        numeroEventiValidi - 1);

    % Definisco i valori di k da provare
    valoriK = 2:massimoK;

    % Inizializzo il vettore dei valori di silhouette
    silhouetteMedia = ...
        NaN(length(valoriK), 1);

    % Scorro i diversi numeri di modalità
    for indiceK = 1:length(valoriK)

        % Recupero il numero di gruppi corrente
        k = valoriK(indiceK);

        % Applico il k-means alle caratteristiche normalizzate
        gruppiTemporanei = kmeans( ...
            Xnormalizzata, ...
            k, ...
            'Replicates', ...
            20, ...
            'MaxIter', ...
            1000, ...
            'Display', ...
            'off');

        % Calcolo il valore di silhouette
        % di ciascun evento
        valoriSilhouette = silhouette( ...
            Xnormalizzata, ...
            gruppiTemporanei);

        % Calcolo la silhouette media
        % associata al numero di gruppi corrente
        silhouetteMedia(indiceK) = ...
            mean(valoriSilhouette);

    end
   
    % Visualizzo i valori di silhouette ottenuti
    fprintf('\n%s\n', upper(nome));

    for indiceK = 1:length(valoriK)

     fprintf( ...
         'k = %d --> silhouette media = %.4f\n', ...
           valoriK(indiceK), ...
         silhouetteMedia(indiceK));
    
    end

    % Individuo il numero di gruppi
    % con il valore medio di silhouette più elevato
    [silhouetteMigliore, indiceMigliore] = ...
        max(silhouetteMedia);

    % Recupero il corrispondente numero di modalità
    numeroModalita = valoriK(indiceMigliore);


    %% Verifica della qualità del raggruppamento

    % Se la silhouette migliore è inferiore alla soglia,
    % considero presente una sola modalità prevalente
    if silhouetteMigliore < sogliaSilhouette

        % Assegno tutti gli eventi allo stesso gruppo
        gruppo = ones(numeroEventiValidi, 1);

        % Imposto a uno il numero delle modalità
        numeroModalita = 1;

    else

        % Applico definitivamente il k-means
        % con il numero di modalità selezionato
        gruppo = kmeans( ...
            Xnormalizzata, ...
            numeroModalita, ...
            'Replicates', ...
            50, ...
            'MaxIter', ...
            1000, ...
            'Display', ...
            'off');

    end


    %% Ordinamento delle modalità

    % Inizializzo la durata mediana di ciascun gruppo
    durataMedianaGruppo = ...
        zeros(numeroModalita, 1);

    % Calcolo la durata mediana
    % degli eventi appartenenti a ogni gruppo
    for m = 1:numeroModalita

        durataMedianaGruppo(m) = ...
            median(X(gruppo == m, 1));

    end

    % Ordino i gruppi dalla durata minore
    % alla durata maggiore
    [~, ordineGruppi] = ...
        sort(durataMedianaGruppo);

    % Inizializzo le etichette ordinate
    gruppoOrdinato = ...
        zeros(size(gruppo));

    % Riassegno i numeri dei gruppi
    % secondo l'ordine crescente delle durate
    for nuovaEtichetta = 1:numeroModalita

        vecchiaEtichetta = ...
            ordineGruppi(nuovaEtichetta);

        gruppoOrdinato( ...
            gruppo == vecchiaEtichetta) = ...
            nuovaEtichetta;

    end

    % Sostituisco le etichette originali
    % con quelle ordinate
    gruppo = gruppoOrdinato;


    %% Assegnazione delle modalità agli eventi

    % Inizializzo la modalità di tutti gli eventi
    % con la descrizione Non valida
    modalitaEvento = ...
        repmat("Non valida", height(T), 1);

    % Creo la descrizione delle modalità
    modalitaValide = ...
        "Modalità " + string(gruppo);

    % Assegno la modalità solamente
    % agli eventi utilizzati nel clustering
    modalitaEvento(eventiValidi) = ...
        modalitaValide;

    % Creo una copia della tabella
    % delle caratteristiche degli eventi
    tabellaEventiModalita = T;

    % Aggiungo la modalità operativa stimata
    tabellaEventiModalita.ModalitaStimata = ...
        modalitaEvento;


    %% Creazione del riepilogo delle modalità

    % Inizializzo i vettori del riepilogo
    nomeModalita = ...
        strings(numeroModalita, 1);

    numeroEventiModalita = ...
        zeros(numeroModalita, 1);

    percentualeEventi = ...
        zeros(numeroModalita, 1);

    durataMediana = ...
        zeros(numeroModalita, 1);

    potenzaMediaModalita = ...
        zeros(numeroModalita, 1);

    energiaMediaModalita = ...
        zeros(numeroModalita, 1);

    % Scorro tutte le modalità individuate
    for m = 1:numeroModalita

        % Individuo gli eventi appartenenti
        % alla modalità corrente
        righeModalita = gruppo == m;

        % Creo il nome della modalità
        nomeModalita(m) = ...
            "Modalità " + string(m);

        % Calcolo il numero di eventi
        numeroEventiModalita(m) = ...
            sum(righeModalita);

        % Calcolo la percentuale degli eventi
        percentualeEventi(m) = ...
            100 * numeroEventiModalita(m) / ...
            numeroEventiValidi;

        % Calcolo la durata mediana
        durataMediana(m) = ...
            median(X(righeModalita, 1));

        % Calcolo la potenza media
        potenzaMediaModalita(m) = ...
            mean(X(righeModalita, 2));

        % Calcolo l'energia media
        energiaMediaModalita(m) = ...
            mean(X(righeModalita, 3));

    end

    % Creo la tabella riassuntiva
    riepilogoModalita = table( ...
        nomeModalita, ...
        numeroEventiModalita, ...
        percentualeEventi, ...
        durataMediana, ...
        potenzaMediaModalita, ...
        energiaMediaModalita);

    % Assegno i nomi alle colonne
    riepilogoModalita.Properties.VariableNames = { ...
        'Modalita', ...
        'NumeroEventi', ...
        'PercentualeEventi', ...
        'DurataMediana_min', ...
        'PotenzaMedia_W', ...
        'EnergiaMedia_Wh'};


    %% Salvataggio dei risultati

    % Salvo gli eventi con la modalità stimata
    ModalitaOperative.(nome).Eventi = ...
        tabellaEventiModalita;

    % Salvo il riepilogo delle modalità
    ModalitaOperative.(nome).Riepilogo = ...
        riepilogoModalita;

    % Salvo il numero di modalità individuate
    ModalitaOperative.(nome).NumeroModalita = ...
        numeroModalita;

    % Salvo il valore migliore di silhouette
    ModalitaOperative.(nome).SilhouetteMedia = ...
        silhouetteMigliore;

% Controllo dei valori minimi di durata, potenza ed energia

disp(['Valori minimi per ', char(nome), ':'])

disp(min(X, [], 1))

    %% Rappresentazione grafica delle modalità operative

% Creo una nuova finestra grafica
figure( ...
    'Name', ...
    'Modalità operative - ' + string(nome), ...
    'NumberTitle', ...
    'off')

% Mantengo il grafico attivo per rappresentare
% separatamente le diverse modalità
hold on

% Rappresento un gruppo alla volta
for g = 1:numeroModalita

    % Individuo gli eventi appartenenti
    % alla modalità corrente
    idxGruppo = gruppo == g;

    % Rappresento gli eventi nel piano
    % durata-energia
    scatter( ...
        X(idxGruppo, 1), ...
        X(idxGruppo, 3), ...
        36, ...
        'filled', ...
        'DisplayName', ...
        ['Modalità ', num2str(g)])

end

% Imposto entrambi gli assi
% in scala logaritmica
set(gca, ...
    'XScale', 'log', ...
    'YScale', 'log')

% Attivo la griglia
grid on

% Inserisco le etichette degli assi
xlabel('Durata [min]')
ylabel('Energia [Wh]')

% Inserisco il titolo
title( ...
    'Modalità operative stimate - ' + ...
    string(nome) + ...
    ' - gruppi: ' + ...
    string(numeroModalita))

% Inserisco la legenda
legend( ...
    'show', ...
    'Location', ...
    'best')

% Termino la sovrapposizione dei grafici
hold off

end

%% Riepilogo completo modalità operative - Utente 1

fprintf('\n===== MODALITA OPERATIVE - UTENTE 1 =====\n');

nomiModalita = fieldnames(ModalitaOperative);

for e = 1:length(nomiModalita)

    nome = nomiModalita{e};

    fprintf('\n--- %s ---\n', upper(nome));

    fprintf('Numero modalità individuate: %d\n', ...
        ModalitaOperative.(nome).NumeroModalita);

    fprintf('Silhouette media migliore: %.4f\n', ...
        ModalitaOperative.(nome).SilhouetteMedia);

    disp(ModalitaOperative.(nome).Riepilogo)

end

fprintf('=========================================\n');


%% Profilazione finale dei singoli elettrodomestici

% Estraggo i nomi degli elettrodomestici
% presenti nella struttura ModalitaOperative
nomiElettrodomestici = fieldnames(ModalitaOperative);

% Inizializzo una cell array che conterrà
% una riga di risultati per ogni elettrodomestico
datiProfiliFinali = cell(length(nomiElettrodomestici), 9);

% Inizializzo i nomi delle sezioni
titoliProfili = cell(length(nomiElettrodomestici), 1);

% Scorro tutti gli elettrodomestici analizzati
for e = 1:length(nomiElettrodomestici)

    % Recupero il nome dell'elettrodomestico corrente
    nome = nomiElettrodomestici{e};

    % Estraggo il riepilogo delle modalità operative
    Riepilogo = ModalitaOperative.(nome).Riepilogo;

    % Calcolo il numero totale delle modalità
    numeroModalita = height(Riepilogo);

    % Se non sono presenti modalità
    % passo all'elettrodomestico successivo
    if numeroModalita == 0

        continue

    end

    % Individuo la modalità più utilizzata
    [percentualeMassima, indicePrevalente] = ...
        max(Riepilogo.PercentualeEventi);

    % Recupero il nome della modalità prevalente
    modalitaPrevalente = ...
        Riepilogo.Modalita(indicePrevalente);

    % Recupero il numero di eventi
    % appartenenti alla modalità prevalente
    numeroEventiPrevalente = ...
        Riepilogo.NumeroEventi(indicePrevalente);

    % Recupero la durata mediana
    % della modalità prevalente
    durataTipica = ...
        Riepilogo.DurataMediana_min(indicePrevalente);

    % Recupero la potenza media
    % della modalità prevalente
    potenzaMediaTipica = ...
        Riepilogo.PotenzaMedia_W(indicePrevalente);

    % Recupero l'energia media
    % della modalità prevalente
    energiaMediaTipica = ...
        Riepilogo.EnergiaMedia_Wh(indicePrevalente);


 %% Interpretazione automatica del profilo

% Verifico se il dispositivo corrente è un sistema HVAC
isHVAC = strcmp(nome, 'hvac1') || strcmp(nome, 'hvac2');

% Inizializzo il commento conclusivo
commentoProfilo = '';

% Caso con una sola modalità / regime
if numeroModalita == 1

    if isHVAC

        commentoProfilo = ...
            ['È stato individuato un solo regime operativo ', ...
             'prevalente. Il funzionamento risulta fortemente ripetitivo.'];

    else

        commentoProfilo = ...
            ['È stata individuata una sola modalità operativa ', ...
             'prevalente. Il comportamento risulta fortemente ripetitivo.'];

    end

% Caso con modalità / regime quasi esclusivo
elseif percentualeMassima >= 80

    if isHVAC

        commentoProfilo = ...
            ['Il funzionamento risulta prevalentemente concentrato ', ...
             'in un regime operativo.'];

    else

        commentoProfilo = ...
            ['L''utente utilizza quasi esclusivamente una sola ', ...
             'modalità operativa.'];

    end

% Caso con modalità / regime prevalente
elseif percentualeMassima >= 60

    if isHVAC

        commentoProfilo = ...
            ['È presente un regime operativo prevalente, ma vengono ', ...
             'osservati anche regimi alternativi.'];

    else

        commentoProfilo = ...
            ['È presente una modalità prevalente, ma vengono ', ...
             'utilizzate anche modalità alternative.'];

    end

% Caso senza netta prevalenza
elseif percentualeMassima >= 40

    if isHVAC

        commentoProfilo = ...
            ['Il funzionamento è distribuito tra più regimi operativi ', ...
             'senza una netta prevalenza.'];

    else

        commentoProfilo = ...
            ['L''utilizzo è distribuito tra più modalità operative ', ...
             'senza una netta prevalenza.'];

    end

% Caso molto variabile
else

    if isHVAC

        commentoProfilo = ...
            ['Il funzionamento risulta distribuito tra diversi ', ...
             'regimi operativi.'];

    else

        commentoProfilo = ...
            ['L''utilizzo risulta distribuito tra diverse ', ...
             'modalità operative.'];

    end

end

    %% Salvataggio dei risultati per la tabella grafica

    % Salvo il titolo della sezione
    titoliProfili{e} = ...
        ['Profilazione finale - ' upper(nome)];

    % Salvo i risultati in formato compatibile con uitable
    datiProfiliFinali(e, :) = { ...
        char(nome), ...
        numeroModalita, ...
        char(modalitaPrevalente), ...
        numeroEventiPrevalente, ...
        percentualeMassima, ...
        durataTipica, ...
        potenzaMediaTipica, ...
        energiaMediaTipica, ...
        char(commentoProfilo)};

end


%% Creazione di un'unica finestra finale

% Creo una sola figura contenente
% le tre profilazioni finali
figuraProfiliFinali = figure( ...
    'Name', ...
    'Profilazione finale degli elettrodomestici', ...
    'NumberTitle', ...
    'off', ...
    'Position', ...
    [50 80 1500 780]);

% Inserisco il titolo generale
annotation( ...
    figuraProfiliFinali, ...
    'textbox', ...
    [0.02 0.94 0.96 0.05], ...
    'String', ...
    'Profilazione finale degli elettrodomestici a programma', ...
    'HorizontalAlignment', ...
    'center', ...
    'FontSize', ...
    15, ...
    'FontWeight', ...
    'bold', ...
    'EdgeColor', ...
    'none');

% Definisco la posizione verticale
% delle tabella in funzione del numero di dispositivi
numeroProfili = length(nomiElettrodomestici);

% Definisco l'altezza di ogni tabella
altezzaTabella = 0.14;

% Calcolo le posizioni verticali
posizioniVerticali = linspace( 0.78, 0.06, numeroProfili);

% Scorro le tre analisi finali
for e = 1:length(nomiElettrodomestici)

    % Inserisco il titolo della singola sezione
    annotation( ...
        figuraProfiliFinali, ...
        'textbox', ...
        [0.02 posizioniVerticali(e) + 0.21 0.96 0.04], ...
        'String', ...
        titoliProfili{e}, ...
        'HorizontalAlignment', ...
        'center', ...
        'FontSize', ...
        12, ...
        'FontWeight', ...
        'bold', ...
        'EdgeColor', ...
        'none');

    % Creo la tabella relativa
    % all'elettrodomestico corrente
    tabellaProfilo = uitable( ...
        figuraProfiliFinali, ...
        'Data', ...
        datiProfiliFinali(e, :), ...
        'ColumnName', { ...
            'Elettrodomestico', ...
            'Numero modalità', ...
            'Mod. prevalente', ...
            'Eventi mod. prevalente', ...
            '% prevalente [%]', ...
            'Durata tipica [min]', ...
            'P media [W]', ...
            'E media [Wh]', ...
            'Profilo' }, ...
        'RowName', ...
        [], ...
        'Units', ...
        'normalized', ...
        'Position', ...
        [0.02 posizioniVerticali(e) 0.96 altezzaTabella]);

    % Imposto la larghezza delle colonne
    tabellaProfilo.ColumnWidth = { ...
        120, ...
        100, ...
        130, ...
        150, ...
        160, ...
        120, ...
        120, ...
        120, ...
        480};

end

%{

%% Analisi diagnostica del disallineamento temporale
% Ricerca di attivazioni isolate del frigorifero
%
% Obiettivo:
% individuare eventi del frigorifero durante i quali non risultano
% attivi altri dispositivi monitorati, così da confrontare direttamente
% il segnale individuale del frigorifero con il segnale aggregato.

%% Parametri dell'analisi

% Fascia oraria inizialmente considerata
oraInizioNotte = 0;
oraFineNotte   = 6;

% Finestra temporale utilizzata per verificare
% l'isolamento dell'evento
margineIsolamento = minutes(10);

% Dispositivi che non devono risultare attivi
% in prossimità dell'evento del frigorifero
altriDispositivi = { ...
    'lavatrice', ...
    'lavastoviglie', ...
    'asciugatrice', ...
    'hvac1', ...
    'hvac2'};

%% Estrazione degli eventi del frigorifero

eventiFrigo = EventiDefinitivi.frigo;

% Mantengo inizialmente gli eventi che iniziano
% nella fascia oraria notturna selezionata
oraEvento = hour(eventiFrigo.TimestampInizio);

eventiNotturni = ...
    oraEvento >= oraInizioNotte & ...
    oraEvento < oraFineNotte;

candidatiFrigo = eventiFrigo(eventiNotturni, :);

fprintf('\n===== RICERCA EVENTI ISOLATI FRIGORIFERO =====\n');
fprintf('Eventi notturni iniziali: %d\n', ...
    height(candidatiFrigo));

%% Verifica dell'isolamento dagli altri dispositivi

eventoIsolato = true(height(candidatiFrigo), 1);

for k = 1:height(candidatiFrigo)

    % Creo una finestra leggermente più ampia
    % rispetto all'evento del frigorifero
    inizioFinestra = ...
        candidatiFrigo.TimestampInizio(k) - margineIsolamento;

    fineFinestra = ...
        candidatiFrigo.TimestampFine(k) + margineIsolamento;

    % Controllo tutti gli altri dispositivi
    for d = 1:length(altriDispositivi)

        nome = altriDispositivi{d};

        E = EventiDefinitivi.(nome);

        % Verifico se esiste almeno un evento
        % che si sovrappone alla finestra considerata
        sovrapposizione = ...
            E.TimestampInizio <= fineFinestra & ...
            E.TimestampFine >= inizioFinestra;

        if any(sovrapposizione)

            eventoIsolato(k) = false;
            break

        end

    end

end

%% Mantengo solamente gli eventi isolati

EventiFrigoIsolati = ...
    candidatiFrigo(eventoIsolato, :);

fprintf('Eventi isolati trovati: %d\n', ...
    height(EventiFrigoIsolati));

fprintf('=============================================\n');

%% Visualizzo i primi eventi candidati

numeroDaMostrare = ...
    min(10, height(EventiFrigoIsolati));

if numeroDaMostrare > 0

    disp(EventiFrigoIsolati( ...
        1:numeroDaMostrare, ...
        {'NumeroEvento', ...
         'TimestampInizio', ...
         'TimestampFine', ...
         'Durata'}))

else

    warning('Nessun evento isolato trovato.')

end

%% Visualizzazione dei candidati
% Confronto diretto tra frigorifero e segnale aggregato

numeroGrafici = min(5, height(EventiFrigoIsolati));

% Finestra visualizzata prima e dopo l'evento
margineGrafico = minutes(10);

for k = 1:numeroGrafici

    % Recupero l'evento
    tInizio = EventiFrigoIsolati.TimestampInizio(k);
    tFine   = EventiFrigoIsolati.TimestampFine(k);

    % Definisco la finestra temporale
    t1 = tInizio - margineGrafico;
    t2 = tFine   + margineGrafico;

    %% Dati frigorifero

    TF = dati.frigo;

    righeFrigo = ...
        TF.Timestamp >= t1 & ...
        TF.Timestamp <= t2;

    TFzoom = TF(righeFrigo, :);

    %% Dati aggregato

    TA = dati.aggregato;

    righeAggregato = ...
        TA.Timestamp >= t1 & ...
        TA.Timestamp <= t2;

    TAz = TA(righeAggregato, :);

    %% Creazione del grafico

    figure( ...
        'Name', ...
        ['Disallineamento frigorifero - evento ', num2str(k)], ...
        'NumberTitle', ...
        'off', ...
        'Position', ...
        [100 200 1400 600])

    tiledlayout(2,1, ...
        'TileSpacing','compact', ...
        'Padding','compact')

    %% Aggregato

    nexttile

    plot( ...
        TAz.Timestamp, ...
        TAz.P, ...
        '-o', ...
        'LineWidth',1, ...
        'MarkerSize',3)

    grid on

    ylabel('Potenza aggregata [W]')

    title('Segnale aggregato')

    xline(tInizio, '--', 'Inizio evento frigo');

    %% Frigorifero

    nexttile

    plot( ...
        TFzoom.Timestamp, ...
        TFzoom.P, ...
        '-o', ...
        'LineWidth',1.2, ...
        'MarkerSize',5)

    grid on

    ylabel('Potenza frigorifero [W]')
    xlabel('Tempo')

    title('Segnale individuale del frigorifero')

    xline(tInizio, '--', 'Inizio evento rilevato');

    sgtitle( ...
        ['Confronto temporale aggregato-frigorifero - ', ...
         char(string(tInizio, ...
         'dd/MM/yyyy HH:mm:ss'))])

end

%% ============================================================
%  ANALISI DEL FRONTE DI ACCENSIONE - FRIGORIFERO
% =============================================================

fprintf('\n===== ANALISI FRONTI FRIGORIFERO =====\n');

% Numero di eventi isolati
nEventi = height(EventiFrigoIsolati);

% Risultati
DeltaP_frigo = NaN(nEventi,1);
Pprima_frigo = NaN(nEventi,1);
Pdopo_frigo  = NaN(nEventi,1);
Tfronte_frigo = NaT(nEventi,1,'TimeZone',dati.frigo.Timestamp.TimeZone);

for i = 1:nEventi

    % Istante di inizio dell'evento rilevato
    tEvento = EventiFrigoIsolati.TimestampInizio(i);

    % Finestra temporale attorno all'inizio dell'evento
    % 3 minuti prima e 3 minuti dopo
    idx = dati.frigo.Timestamp >= tEvento - minutes(3) & ...
          dati.frigo.Timestamp <= tEvento + minutes(3);

    t = dati.frigo.Timestamp(idx);
    P = dati.frigo.P(idx);

    if numel(t) < 2
        continue
    end

    % Campioni prima dell'inizio evento
    idxPrima = t < tEvento;

    % Campioni dall'inizio evento in poi
    idxDopo = t >= tEvento;

    if ~any(idxPrima) || ~any(idxDopo)
        continue
    end

    % Ultimo campione disponibile prima dell'evento
    indPrima = find(idxPrima,1,'last');

    % Primo campione disponibile dall'inizio dell'evento
    indDopo = find(idxDopo,1,'first');

    Pprima_frigo(i) = P(indPrima);
    Pdopo_frigo(i)  = P(indDopo);

    % Istante del primo campione associato al fronte di accensione
    Tfronte_frigo(i) = t(indDopo);

    % Variazione osservata all'accensione
    DeltaP_frigo(i) = Pdopo_frigo(i) - Pprima_frigo(i);

end

% Aggiunta dei risultati alla tabella
EventiFrigoIsolati.Pprima = Pprima_frigo;
EventiFrigoIsolati.Pdopo  = Pdopo_frigo;
EventiFrigoIsolati.DeltaP = DeltaP_frigo;
EventiFrigoIsolati.TfronteFrigo = Tfronte_frigo;

% Visualizzazione dei primi eventi
disp(EventiFrigoIsolati(1:min(20,height(EventiFrigoIsolati)), ...
    {'NumeroEvento','TimestampInizio','Pprima','Pdopo','DeltaP'}));

fprintf('======================================\n');

%% ============================================================
%  SELEZIONE DEI FRONTI DI ACCENSIONE NETTI - FRIGORIFERO
% =============================================================

sogliaFrigo = 30;   % [W]

fronteNetto = ...
    ~isnan(EventiFrigoIsolati.Pprima) & ...
    ~isnan(EventiFrigoIsolati.Pdopo) & ...
    EventiFrigoIsolati.Pprima < sogliaFrigo & ...
    EventiFrigoIsolati.Pdopo >= sogliaFrigo;

EventiFrigoFronti = EventiFrigoIsolati(fronteNetto,:);

fprintf('\n===== FRONTI NETTI FRIGORIFERO =====\n');
fprintf('Eventi isolati totali: %d\n', height(EventiFrigoIsolati));
fprintf('Fronti netti individuati: %d\n', height(EventiFrigoFronti));

disp(EventiFrigoFronti(1:min(20,height(EventiFrigoFronti)), ...
    {'NumeroEvento','TimestampInizio','Pprima','Pdopo','DeltaP'}));

fprintf('=====================================\n');

%% ============================================================
%  CONFRONTO FRONTI FRIGORIFERO - AGGREGATO
% =============================================================

numeroGraficiFronti = min(10, height(EventiFrigoFronti));

% Finestra molto più stretta rispetto ai grafici precedenti
margineFronte = seconds(120);

for k = 1:numeroGraficiFronti

    tFrigo = EventiFrigoFronti.TfronteFrigo(k);

    % Finestra temporale comune
    t1 = tFrigo - margineFronte;
    t2 = tFrigo + margineFronte;

    %% Segnale frigorifero
    TF = dati.frigo;

    idxF = TF.Timestamp >= t1 & TF.Timestamp <= t2;
    TFz = TF(idxF,:);

    %% Segnale aggregato
    TA = dati.aggregato;

    idxA = TA.Timestamp >= t1 & TA.Timestamp <= t2;
    TAz = TA(idxA,:);

    %% Grafico
    figure( ...
        'Name',['Fronte frigorifero ',num2str(k)], ...
        'NumberTitle','off', ...
        'Position',[100 200 1400 600])

    tiledlayout(2,1, ...
        'TileSpacing','compact', ...
        'Padding','compact')

    % Aggregato
    nexttile

    plot(TAz.Timestamp,TAz.P,'-o', ...
        'LineWidth',1, ...
        'MarkerSize',3)

    grid on
    ylabel('Potenza aggregata [W]')
    title('Segnale aggregato')

    xline(tFrigo,'--','Fronte rilevato dal frigorifero');

    % Frigorifero
    nexttile

    plot(TFz.Timestamp,TFz.P,'-o', ...
        'LineWidth',1.2, ...
        'MarkerSize',5)

    grid on
    ylabel('Potenza frigorifero [W]')
    xlabel('Tempo')
    title('Segnale individuale del frigorifero')

    yline(30,'--','Soglia 30 W');
    xline(tFrigo,'--','Fronte rilevato');

    sgtitle( ...
        ['Confronto del fronte aggregato-frigorifero - evento ', ...
         num2str(EventiFrigoFronti.NumeroEvento(k))])

end

%% ============================================================
%  ANALISI DELLA STABILITA' DELL'AGGREGATO
%  PRIMA DEI FRONTI DEL FRIGORIFERO
% =============================================================

fprintf('\n===== STABILITA'' AGGREGATO PRIMA DEL FRONTE =====\n');

nFronti = height(EventiFrigoFronti);

% Finestra precedente al fronte del frigorifero
finestraPre = minutes(2);

% Variabili per memorizzare i risultati
PmediaPre = NaN(nFronti,1);
PstdPre   = NaN(nFronti,1);
PrangePre = NaN(nFronti,1);
Ncampioni = NaN(nFronti,1);

TA = dati.aggregato;

for i = 1:nFronti

    % Istante del fronte rilevato dal frigorifero
    tFrigo = EventiFrigoFronti.TfronteFrigo(i);

    % Seleziono i campioni dell'aggregato nei 2 minuti
    % precedenti il fronte del frigorifero
    idx = ...
        TA.Timestamp >= tFrigo - finestraPre & ...
        TA.Timestamp <  tFrigo;

    P = TA.P(idx);

    % Elimino eventuali valori non validi
    P = P(~isnan(P));

    Ncampioni(i) = numel(P);

    if numel(P) < 2
        continue
    end

    % Caratterizzazione del livello dell'aggregato
    PmediaPre(i) = mean(P);
    PstdPre(i)   = std(P);

    % Escursione complessiva nella finestra
    PrangePre(i) = max(P) - min(P);

end

%% Aggiungo i risultati alla tabella

EventiFrigoFronti.PmediaAggPre = PmediaPre;
EventiFrigoFronti.StdAggPre    = PstdPre;
EventiFrigoFronti.RangeAggPre  = PrangePre;
EventiFrigoFronti.NcampioniAgg = Ncampioni;

%% Statistiche

validi = ~isnan(PrangePre);

fprintf('Fronti analizzabili: %d su %d\n', ...
    sum(validi), nFronti);

fprintf('\nEscursione aggregato nei 2 minuti precedenti:\n');

fprintf('Mediana: %.1f W\n', ...
    median(PrangePre(validi)));

fprintf('25° percentile: %.1f W\n', ...
    prctile(PrangePre(validi),25));

fprintf('75° percentile: %.1f W\n', ...
    prctile(PrangePre(validi),75));

fprintf('90° percentile: %.1f W\n', ...
    prctile(PrangePre(validi),90));

fprintf('\nDeviazione standard aggregato:\n');

fprintf('Mediana: %.1f W\n', ...
    median(PstdPre(validi)));

fprintf('75° percentile: %.1f W\n', ...
    prctile(PstdPre(validi),75));

fprintf('===============================================\n');

%% Visualizzazione distribuzione dell'escursione

figure( ...
    'Name','Stabilita aggregato prima dei fronti frigo', ...
    'NumberTitle','off')

histogram(PrangePre(validi),30)

grid on

xlabel('Escursione dell''aggregato nei 2 min precedenti [W]')
ylabel('Numero di eventi')

title(['Stabilità del segnale aggregato prima ', ...
       'dell''accensione del frigorifero'])

%% Visualizzazione degli eventi più stabili

TabellaStabilita = EventiFrigoFronti(validi,:);

TabellaStabilita = sortrows( ...
    TabellaStabilita, ...
    'RangeAggPre', ...
    'ascend');

fprintf('\n===== EVENTI CON AGGREGATO PIU'' STABILE =====\n');

disp(TabellaStabilita( ...
    1:min(20,height(TabellaStabilita)), ...
    {'NumeroEvento', ...
     'TfronteFrigo', ...
     'Pprima', ...
     'Pdopo', ...
     'DeltaP', ...
     'PmediaAggPre', ...
     'StdAggPre', ...
     'RangeAggPre', ...
     'NcampioniAgg'}));

%% ============================================================
%  GRAFICI DEGLI EVENTI CON AGGREGATO PIU' STABILE
% =============================================================

% Richiedo almeno 4 campioni dell'aggregato nei 2 minuti precedenti
eventiBuoni = ...
    TabellaStabilita.NcampioniAgg >= 4;

EventiStabili = TabellaStabilita(eventiBuoni,:);

% Ordino nuovamente per escursione crescente
EventiStabili = sortrows( ...
    EventiStabili, ...
    'RangeAggPre', ...
    'ascend');

% Visualizzo i primi 6 casi
numeroGrafici = min(6,height(EventiStabili));

% Finestra: 2 minuti prima e 2 minuti dopo
margine = minutes(2);

for k = 1:numeroGrafici

    tFrigo = EventiStabili.TfronteFrigo(k);

    t1 = tFrigo - margine;
    t2 = tFrigo + margine;

    %% Aggregato

    TA = dati.aggregato;

    idxA = ...
        TA.Timestamp >= t1 & ...
        TA.Timestamp <= t2;

    TAz = TA(idxA,:);

    %% Frigorifero

    TF = dati.frigo;

    idxF = ...
        TF.Timestamp >= t1 & ...
        TF.Timestamp <= t2;

    TFz = TF(idxF,:);

    %% Grafico

    figure( ...
        'Name', ...
        ['Evento stabile ', ...
         num2str(EventiStabili.NumeroEvento(k))], ...
        'NumberTitle','off', ...
        'Position',[100 200 1400 650])

    tiledlayout(2,1, ...
        'TileSpacing','compact', ...
        'Padding','compact')

    % ---------------------------------------------------------
    % AGGREGATO
    % ---------------------------------------------------------

    nexttile

    plot( ...
        TAz.Timestamp, ...
        TAz.P, ...
        '-o', ...
        'LineWidth',1.2, ...
        'MarkerSize',4)

    grid on

    ylabel('Potenza aggregata [W]')
    title('Segnale aggregato')

    xlim([t1 t2])

    % ---------------------------------------------------------
    % FRIGORIFERO
    % ---------------------------------------------------------

    nexttile

    plot( ...
        TFz.Timestamp, ...
        TFz.P, ...
        '-o', ...
        'LineWidth',1.2, ...
        'MarkerSize',5)

    grid on

    ylabel('Potenza frigorifero [W]')
    xlabel('Tempo')

    title('Segnale individuale del frigorifero')

    yline(30,'--','Soglia 30 W');

    xline( ...
        tFrigo, ...
        '--', ...
        'Fronte frigorifero');

    xlim([t1 t2])

    sgtitle( ...
        ['Evento ', ...
         num2str(EventiStabili.NumeroEvento(k)), ...
         ' - aggregato stabile prima dell''attivazione'])

end

%% Mostro quali eventi sono stati rappresentati

fprintf('\n===== EVENTI STABILI VISUALIZZATI =====\n');

disp(EventiStabili( ...
    1:numeroGrafici, ...
    {'NumeroEvento', ...
     'TfronteFrigo', ...
     'DeltaP', ...
     'RangeAggPre', ...
     'StdAggPre', ...
     'NcampioniAgg'}));
%}

%% ============================================================
%  RICERCA FRONTI NETTI DEI DISPOSITIVI MONITORATI
% =============================================================
%
% Obiettivo:
% individuare, per ciascun dispositivo, le transizioni di accensione
% caratterizzate da una variazione di potenza sufficientemente evidente.
% Questi fronti verranno successivamente confrontati con il segnale
% aggregato per studiare il disallineamento temporale.

fprintf('\n===== RICERCA FRONTI DEI DISPOSITIVI =====\n');

dispositiviFronti = { ...
    'lavatrice', ...
    'lavastoviglie', ...
    'asciugatrice', ...
    'hvac1', ...
    'hvac2'};

% Soglie di attivazione già utilizzate nell'analisi
soglieFronti = [30 30 30 120 120];

% Struttura nella quale salvo i risultati
AnalisiFronti = struct();

for d = 1:length(dispositiviFronti)

    nome = dispositiviFronti{d};
    soglia = soglieFronti(d);

    T = dati.(nome);

    % Ordino temporalmente i dati per sicurezza
    T = sortrows(T,'Timestamp');

    t = T.Timestamp;
    P = T.P;

    % ---------------------------------------------------------
    % Individuazione delle transizioni sotto-soglia -> sopra-soglia
    % ---------------------------------------------------------

    sottoPrima = P(1:end-1) < soglia;
    sopraDopo  = P(2:end) >= soglia;

    fronte = sottoPrima & sopraDopo;

    ind = find(fronte);

    % Istanti prima e dopo il fronte
    tPrima = t(ind);
    tDopo  = t(ind+1);

    Pprima = P(ind);
    Pdopo  = P(ind+1);

    DeltaP = Pdopo - Pprima;

    % Intervallo temporale nel quale è avvenuta realmente
    % la transizione
    DeltaT = seconds(tDopo - tPrima);

    % ---------------------------------------------------------
    % Creazione tabella
    % ---------------------------------------------------------

    Fronti = table( ...
        tPrima, ...
        tDopo, ...
        Pprima, ...
        Pdopo, ...
        DeltaP, ...
        DeltaT, ...
        'VariableNames',{ ...
        'TimestampPrima', ...
        'TimestampDopo', ...
        'Pprima', ...
        'Pdopo', ...
        'DeltaP', ...
        'DeltaT_s'});

    AnalisiFronti.(nome) = Fronti;

    % ---------------------------------------------------------
    % Statistiche
    % ---------------------------------------------------------

    fprintf('\n%s\n', upper(nome));
    fprintf('Fronti individuati: %d\n', height(Fronti));

    if ~isempty(Fronti)

        fprintf('DeltaP mediano: %.1f W\n', ...
            median(Fronti.DeltaP,'omitnan'));

        fprintf('DeltaP 75° percentile: %.1f W\n', ...
            prctile(Fronti.DeltaP,75));

        fprintf('DeltaP 90° percentile: %.1f W\n', ...
            prctile(Fronti.DeltaP,90));

        fprintf('DeltaP massimo: %.1f W\n', ...
            max(Fronti.DeltaP));

        fprintf('Intervallo temporale mediano del fronte: %.1f s\n', ...
            median(Fronti.DeltaT_s,'omitnan'));

    end

end

fprintf('\n===========================================\n');

%% ============================================================
%  ANALISI DISALLINEAMENTO - LAVASTOVIGLIE
% =============================================================
%
% Selezione di fronti di accensione caratterizzati da una
% variazione di potenza elevata, in modo da renderne più semplice
% l'identificazione anche nel segnale aggregato.

fprintf('\n===== ANALISI FRONTI LAVASTOVIGLIE =====\n');

FrontiLV = AnalisiFronti.lavastoviglie;

% Seleziono fronti con variazione di potenza sufficientemente elevata
sogliaDeltaP = 1000; % [W]

candidatiLV = FrontiLV(FrontiLV.DeltaP >= sogliaDeltaP,:);

fprintf('Fronti totali: %d\n',height(FrontiLV));
fprintf('Fronti con DeltaP >= %.0f W: %d\n', ...
    sogliaDeltaP,height(candidatiLV));

fprintf('\nStatistiche dei fronti selezionati:\n');

fprintf('DeltaP mediano: %.1f W\n', ...
    median(candidatiLV.DeltaP,'omitnan'));

fprintf('Intervallo temporale mediano: %.1f s\n', ...
    median(candidatiLV.DeltaT_s,'omitnan'));

fprintf('Intervallo temporale 75° percentile: %.1f s\n', ...
    prctile(candidatiLV.DeltaT_s,75));

fprintf('Intervallo temporale 90° percentile: %.1f s\n', ...
    prctile(candidatiLV.DeltaT_s,90));

disp(candidatiLV(1:min(20,height(candidatiLV)),:));

fprintf('=========================================\n');

%% ============================================================
%  CONFRONTO TEMPORALE LAVASTOVIGLIE - AGGREGATO
% =============================================================

% Mantengo fronti ben definiti e con intervallo tra i due
% campioni non eccessivamente ampio
frontiGrafico = candidatiLV(candidatiLV.DeltaT_s <= 300,:);

fprintf('\n===== FRONTI UTILIZZABILI PER IL CONFRONTO =====\n');
fprintf('Fronti disponibili: %d\n',height(frontiGrafico));

% Numero iniziale di esempi da visualizzare
numeroGrafici = min(10,height(frontiGrafico));

% Margine prima e dopo i due campioni della lavastoviglie
margine = seconds(120);

for k = 1:numeroGrafici

    tPrima = frontiGrafico.TimestampPrima(k);
    tDopo  = frontiGrafico.TimestampDopo(k);

    t1 = tPrima - margine;
    t2 = tDopo  + margine;

    %% Lavastoviglie

    TL = dati.lavastoviglie;

    idxL = TL.Timestamp >= t1 & ...
           TL.Timestamp <= t2;

    TLz = TL(idxL,:);

    %% Aggregato

    TA = dati.aggregato;

    idxA = TA.Timestamp >= t1 & ...
           TA.Timestamp <= t2;

    TAz = TA(idxA,:);

 %{   
    %% Grafico

    figure( ...
        'Name',['Lavastoviglie - fronte ',num2str(k)], ...
        'NumberTitle','off', ...
        'Position',[100 150 1400 700])

    tiledlayout(2,1, ...
        'TileSpacing','compact', ...
        'Padding','compact')

    % ---------------------------------------------------------
    % Segnale aggregato
    % ---------------------------------------------------------

    nexttile

    plot(TAz.Timestamp,TAz.P, ...
        '-', ...
        'LineWidth',1.1)

    grid on

    ylabel('Potenza aggregata [W]')
    title('Segnale aggregato')

    xline(tPrima,'--','Ultimo campione basso');
    xline(tDopo,'--','Primo campione alto');

    % ---------------------------------------------------------
    % Segnale lavastoviglie
    % ---------------------------------------------------------

    nexttile

    plot(TLz.Timestamp,TLz.P, ...
        '-o', ...
        'LineWidth',1.2, ...
        'MarkerSize',5)

    grid on

    ylabel('Potenza lavastoviglie [W]')
    xlabel('Tempo')

    title('Segnale individuale della lavastoviglie')

    yline(30,'--','Soglia 30 W');

    xline(tPrima,'--','Ultimo campione basso');
    xline(tDopo,'--','Primo campione alto');

    sgtitle(sprintf( ...
        'Fronte lavastoviglie: \\DeltaP = %.0f W, \\Deltat = %.0f s', ...
        frontiGrafico.DeltaP(k), ...
        frontiGrafico.DeltaT_s(k)));
 %}

end



%% ============================================================
%  RICERCA FRONTI LAVASTOVIGLIE OSSERVABILI NELL'AGGREGATO
% =============================================================

TA = dati.aggregato;

n = height(frontiGrafico);

NcampioniAgg = zeros(n,1);
DeltaAggMax  = NaN(n,1);
TsaltoAgg    = NaT(n,1);
TsaltoAgg.TimeZone = TA.Timestamp.TimeZone;

for i = 1:n

    tPrima = frontiGrafico.TimestampPrima(i);
    tDopo  = frontiGrafico.TimestampDopo(i);

    % Campioni aggregati compresi nell'intervallo di incertezza
    idx = TA.Timestamp >= tPrima & ...
          TA.Timestamp <= tDopo;

    tA = TA.Timestamp(idx);
    pA = TA.P(idx);

    NcampioniAgg(i) = length(pA);

    % Per calcolare una variazione servono almeno 2 campioni
    if length(pA) >= 2

        % Variazioni tra campioni aggregati consecutivi
        dP = diff(pA);

        % Massimo incremento positivo
        [DeltaAggMax(i),indMax] = max(dP);

        % Timestamp del campione successivo al salto
        TsaltoAgg(i) = tA(indMax+1);

    end
end

frontiGrafico.NcampioniAgg = NcampioniAgg;
frontiGrafico.DeltaAggMax  = DeltaAggMax;
frontiGrafico.TsaltoAgg    = TsaltoAgg;

% Compatibilità tra salto dell'aggregato e salto della lavastoviglie
frontiGrafico.ErroreDeltaP = abs( ...
    frontiGrafico.DeltaAggMax - frontiGrafico.DeltaP);

% Tengo soltanto casi con almeno 2 campioni aggregati
% nell'intervallo
frontiConAgg = frontiGrafico( ...
    frontiGrafico.NcampioniAgg >= 2,:);

% Ordino in base alla compatibilità delle variazioni di potenza
frontiConAgg = sortrows(frontiConAgg,'ErroreDeltaP','ascend');

fprintf('\n===== FRONTI CON RISCONTRO NELL''AGGREGATO =====\n');

fprintf('Fronti analizzati: %d\n',height(frontiGrafico));
fprintf('Fronti con almeno 2 campioni aggregati: %d\n', ...
    height(frontiConAgg));

disp(frontiConAgg(1:min(20,height(frontiConAgg)), ...
    {'TimestampPrima','TimestampDopo', ...
     'DeltaP','DeltaT_s','NcampioniAgg', ...
     'DeltaAggMax','ErroreDeltaP','TsaltoAgg'}));

%% ============================================================
%  RICERCA DEI CASI CON MAGGIORE DISALLINEAMENTO
% =============================================================

% Seleziono casi con:
% - almeno 5 campioni aggregati
% - buona corrispondenza tra il salto della lavastoviglie
%   e quello osservato nell'aggregato
% - intervallo della lavastoviglie non superiore a 120 s

candidatiRitardo = frontiConAgg( ...
    frontiConAgg.NcampioniAgg >= 5 & ...
    frontiConAgg.ErroreDeltaP <= 100 & ...
    frontiConAgg.DeltaT_s <= 120, :);

% Calcolo il disallineamento osservato
candidatiRitardo.Ritardo_s = seconds( ...
    candidatiRitardo.TimestampDopo - ...
    candidatiRitardo.TsaltoAgg);

% Tengo solo i casi in cui il salto aggregato precede
% il primo campione alto della lavastoviglie
candidatiRitardo = candidatiRitardo( ...
    candidatiRitardo.Ritardo_s >= 0, :);

% Ordino dal disallineamento maggiore al minore
candidatiRitardo = sortrows( ...
    candidatiRitardo, ...
    'Ritardo_s', ...
    'descend');

fprintf('\n===== CASI CON MAGGIORE DISALLINEAMENTO =====\n');
fprintf('Numero di casi disponibili: %d\n\n', ...
    height(candidatiRitardo));

disp(candidatiRitardo(1:min(20,height(candidatiRitardo)), ...
    {'TimestampPrima', ...
     'TimestampDopo', ...
     'DeltaP', ...
     'DeltaT_s', ...
     'NcampioniAgg', ...
     'DeltaAggMax', ...
     'ErroreDeltaP', ...
     'TsaltoAgg', ...
     'Ritardo_s'}));

%% ============================================================
%  DUE ESEMPI DI DISALLINEAMENTO TEMPORALE
%  AGGREGATO - LAVASTOVIGLIE
% =============================================================

TA = dati.aggregato;
TL = dati.lavastoviglie;

% -------------------------------------------------------------
% Selezione manuale dei due casi individuati dall'analisi
% -------------------------------------------------------------

dateScelte = [ ...
    datetime(2024,12,20,21,15,47); ...
    datetime(2025,7,23,21,35,27)];

% Adeguamento del fuso orario
dateScelte.TimeZone = TL.Timestamp.TimeZone;

indiciScelti = zeros(2,1);

for k = 1:2

    % Cerco nella tabella il fronte avente questo TimestampDopo
    idx = find(candidatiRitardo.TimestampDopo == dateScelte(k), ...
        1,'first');

    if isempty(idx)
        error('Caso %d non trovato nella tabella.',k);
    end

    indiciScelti(k) = idx;

end

casiScelti = candidatiRitardo(indiciScelti,:);


%% ============================================================
%  GRAFICI FINALI PER LA TESI
%  CONFRONTO AGGREGATO - LAVASTOVIGLIE
% =============================================================

for k = 1:2

    tPrima  = casiScelti.TimestampPrima(k);
    tDopo   = casiScelti.TimestampDopo(k);
    tSaltoA = casiScelti.TsaltoAgg(k);

    % Margine temporale
    margine = seconds(20);

    t1 = tPrima - margine;
    t2 = tDopo  + margine;


    % ---------------------------------------------------------
    % Segnale aggregato
    % ---------------------------------------------------------

    idxA = TA.Timestamp >= t1 & TA.Timestamp <= t2;

    tA = TA.Timestamp(idxA);
    pA = TA.P(idxA);


    % ---------------------------------------------------------
    % Segnale lavastoviglie
    % ---------------------------------------------------------

    idxL = TL.Timestamp >= t1 & TL.Timestamp <= t2;

    tL = TL.Timestamp(idxL);
    pL = TL.P(idxL);


    % ---------------------------------------------------------
    % Creazione figura
    % ---------------------------------------------------------

    fig = figure( ...
        'Color','w', ...
        'Units','centimeters', ...
        'Position',[2 2 18 11], ...
        'Name',sprintf('Disallineamento - caso %d',k), ...
        'NumberTitle','off');

    tiledlayout(2,1, ...
        'TileSpacing','compact', ...
        'Padding','compact');


    % =========================================================
% 1. SEGNALE AGGREGATO
% =========================================================

ax1 = nexttile;

plot(tA,pA,'-o', ...
    'LineWidth',1.2, ...
    'MarkerSize',4);

hold on

hSalto = xline(tSaltoA,'--', ...
    'LineWidth',1.2);

hCampione = xline(tDopo,':', ...
    'LineWidth',1.4);

grid on
box on

ylabel('Potenza aggregata [W]');

xlim([t1 t2]);

legend([hSalto hCampione], ...
    {'Salto aggregato','Primo campione alto lavastoviglie'}, ...
    'Location','best', ...
    'FontSize',9);

set(gca, ...
    'FontSize',10, ...
    'LineWidth',0.8);


   % =========================================================
% 2. SEGNALE LAVASTOVIGLIE
% =========================================================

ax2 = nexttile;

plot(tL,pL,'-o', ...
    'LineWidth',1.2, ...
    'MarkerSize',4);

hold on

yline(30,'--', ...
    'LineWidth',1);

xline(tSaltoA,'--', ...
    'LineWidth',1.2);

xline(tDopo,':', ...
    'LineWidth',1.4);

grid on
box on

ylabel('Potenza lavastoviglie [W]');
xlabel('Tempo');

xlim([t1 t2]);

set(gca, ...
    'FontSize',10, ...
    'LineWidth',0.8);


    % ---------------------------------------------------------
    % Stesso asse temporale
    % ---------------------------------------------------------

    linkaxes([ax1 ax2],'x');


    % ---------------------------------------------------------
    % Titolo unico e semplice
    % ---------------------------------------------------------

    sgtitle(sprintf( ...
        'Confronto temporale aggregato-lavastoviglie - disallineamento = %.0f s', ...
        casiScelti.Ritardo_s(k)), ...
        'FontWeight','normal', ...
        'FontSize',11);


    % ---------------------------------------------------------
    % Esportazione
    % ---------------------------------------------------------

    nomeFile = sprintf('disallineamento_caso%d.png',k);

    exportgraphics(fig,nomeFile, ...
        'Resolution',300);

end
%% ============================================================
% RIEPILOGO NUMERICO
% =============================================================

fprintf('\n===== DUE CASI SELEZIONATI =====\n');

disp(casiScelti(:, ...
    {'TimestampPrima', ...
     'TimestampDopo', ...
     'DeltaP', ...
     'DeltaAggMax', ...
     'ErroreDeltaP', ...
     'TsaltoAgg', ...
     'Ritardo_s', ...
     'NcampioniAgg'}));

fprintf('===============================\n');

%% ============================================================
%  QUANTIFICAZIONE DELL'ALLINEAMENTO TEMPORALE
%  NEI SOLI GIORNI COMUNI
% =============================================================

nomiDispositivi = { ...
    'lavatrice', ...
    'lavastoviglie', ...
    'asciugatrice', ...
    'frigo', ...
    'hvac1', ...
    'hvac2'};

tolleranza = 300;   % 5 minuti [s]

nDisp = numel(nomiDispositivi);

Ncampioni = zeros(nDisp,1);
Nallineati = zeros(nDisp,1);
NnonAllineati = zeros(nDisp,1);

for d = 1:nDisp

    nome = nomiDispositivi{d};

    fprintf('\nAnalisi dispositivo: %s\n',nome);

    deltaTtot = [];

    % Analizzo separatamente ciascuno dei 195 giorni comuni
    for g = 1:numel(Comuni.giorni)

        giorno = Comuni.giorni(g);

        TA = Comuni.dati.aggregato;
        TD = Comuni.dati.(nome);

        idxA = TA.Data == giorno;
        idxD = TD.Data == giorno;

        tAgg  = TA.Timestamp(idxA);
        tDisp = TD.Timestamp(idxD);

        % Il giorno viene utilizzato solo se entrambi i segnali
        % contengono campioni
        if isempty(tAgg) || isempty(tDisp)
            continue
        end

        % Origine comune all'interno del giorno
        origine = min([tAgg(1); tDisp(1)]);

        xAgg  = seconds(tAgg  - origine);
        xDisp = seconds(tDisp - origine);

        % Campione del dispositivo temporalmente più vicino
if numel(xDisp) >= 2

    xDispVicino = interp1( ...
        xDisp, ...
        xDisp, ...
        xAgg, ...
        'nearest', ...
        'extrap');

elseif numel(xDisp) == 1

    % Se nel giorno è presente un solo campione del dispositivo,
    % utilizzo direttamente quel timestamp come riferimento
    xDispVicino = repmat(xDisp, size(xAgg));

else

    continue

end

deltaT = abs(xAgg - xDispVicino);

        deltaTtot = [deltaTtot; deltaT(:)];

    end

    % Conteggi finali
    Ncampioni(d) = numel(deltaTtot);

    Nallineati(d) = sum(deltaTtot <= tolleranza);

    NnonAllineati(d) = sum(deltaTtot > tolleranza);

end

% Percentuali
PercAllineati = 100*Nallineati./Ncampioni;
PercNonAllineati = 100*NnonAllineati./Ncampioni;

%% ============================================================
%  TABELLA FINALE
% =============================================================

TabellaAllineamento = table( ...
    string(nomiDispositivi(:)), ...
    Ncampioni, ...
    Nallineati, ...
    NnonAllineati, ...
    PercAllineati, ...
    PercNonAllineati, ...
    'VariableNames',{ ...
        'Elettrodomestico', ...
        'CampioniConsiderati', ...
        'CampioniAllineati', ...
        'CampioniNonAllineati', ...
        'Allineati_percento', ...
        'NonAllineati_percento'});

fprintf('\n');
fprintf('============================================================\n');
fprintf(' ALLINEAMENTO TEMPORALE - 195 GIORNI COMUNI\n');
fprintf(' TOLLERANZA = 5 MINUTI\n');
fprintf('============================================================\n\n');

format long g
disp(TabellaAllineamento);
format short