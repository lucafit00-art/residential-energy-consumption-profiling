%% UTENTE 2 - PROFILAZIONE DEI CONSUMI
%
% Dispositivi disponibili:
%
% - asciugatrice
% - macchina da caffe
% - microonde
% - segnale aggregato
%
% In questa prima fase vengono eseguite:
%
% 1) importazione e organizzazione dei dati
% 2) verifica preliminare della struttura
% 3) analisi della risoluzione temporale
% 4) caratterizzazione preliminare dei segnali
% 5) individuazione dei giorni comuni
%
% Le soglie di attivazione verranno definite
% successivamente sulla base dei risultati ottenuti.


%% Pulizia dell'ambiente di lavoro

% Elimino tutte le variabili presenti nel Workspace
clear all

% Chiudo tutte le figure eventualmente aperte
close all

% Pulisco la Command Window
clc;


%% Definizione degli elettrodomestici e delle cartelle

% Elenco dei nomi utilizzati all'interno
% della struttura MATLAB

Elettrodomestici = [ ...
    "asciugatrice", ...
    "macchinacaffe", ...
    "microonde", ...
    "aggregato"];


% Elenco delle cartelle reali associate
% ai diversi segnali

Cartelle = [ ...
    "segnale asciugatrice 2", ...
    "segnale macchinacaffè 2", ...
    "segnale microonde 2", ...
    "segnale aggregato 2"];


%% Inizializzazione della struttura dati

% Creo una struttura vuota che conterrà
% una tabella per ogni dispositivo

dati = struct();


%% Lettura e organizzazione automatica dei file CSV

% Scorro tutti i dispositivi presenti nell'elenco

for e = 1:length(Elettrodomestici)

    % Recupero il nome del dispositivo corrente
    nome = Elettrodomestici(e);

    % Recupero la cartella associata
    cartella = Cartelle(e);

    % Cerco tutti i file CSV presenti
    % nella cartella corrente
    files = dir(fullfile(cartella, "*.csv"));

    % Verifico che siano presenti file CSV
    if isempty(files)

        error( ...
            "Nessun file CSV trovato nella cartella: %s", ...
            cartella);

    end

    % Inizializzo una tabella vuota che conterrà
    % progressivamente tutti i dati del dispositivo
    TT = table();

    % Scorro tutti i file CSV trovati
    for i = 1:length(files)

        % Costruisco il percorso completo
        % del file corrente
        percorsoFile = ...
            fullfile(cartella, files(i).name);

        % Leggo il contenuto del file CSV
        % utilizzando il punto e virgola
        % come delimitatore
        T = readtable( ...
            percorsoFile, ...
            "Delimiter", ";");


        %% Conversione del timestamp

        % Converto la colonna timestamp da testo
        % a variabile temporale datetime

        T.Timestamp = datetime( ...
            T.timestamp, ...
            "InputFormat", ...
            "yyyy-MM-dd'T'HH:mm:ss'Z'", ...
            "TimeZone", ...
            "UTC");


        %% Estrazione delle informazioni temporali

        % Estraggo la sola data
        T.Data = ...
            dateshift( ...
                T.Timestamp, ...
                "start", ...
                "day");

        % Estraggo il solo orario
        T.Ora = ...
            timeofday(T.Timestamp);


        %% Selezione delle colonne di interesse

        % Mantengo solamente:
        %
        % Timestamp
        % Data
        % Ora
        % Potenza attiva P

        T = T(:, [ ...
            "Timestamp", ...
            "Data", ...
            "Ora", ...
            "P"]);


        %% Accodamento dei dati

        % Aggiungo verticalmente i dati
        % del file corrente alla tabella
        % complessiva del dispositivo

        TT = [TT; T];

    end


    %% Ordinamento cronologico

    % Ordino tutti i campioni del dispositivo
    % in base al timestamp

    TT = sortrows(TT, "Timestamp");


    %% Salvataggio

    % Salvo la tabella completa
    % nella struttura dati

    dati.(nome) = TT;

end


%% Verifica dei dispositivi caricati

disp(" ")
disp("==============================================")
disp("DISPOSITIVI CARICATI")
disp("==============================================")

disp(fieldnames(dati))


%% Verifica delle prime righe

disp(" ")
disp("Prime righe - ASCIUGATRICE")

disp(head(dati.asciugatrice))


disp(" ")
disp("Prime righe - MACCHINA DA CAFFE")

disp(head(dati.macchinacaffe))


disp(" ")
disp("Prime righe - MICROONDE")

disp(head(dati.microonde))


disp(" ")
disp("Prime righe - AGGREGATO")

disp(head(dati.aggregato))


%% Verifica del numero di campioni

disp(" ")
disp("==============================================")
disp("NUMERO DI CAMPIONI")
disp("==============================================")

fprintf( ...
    "Asciugatrice: %d campioni\n", ...
    height(dati.asciugatrice));

fprintf( ...
    "Macchina da caffe: %d campioni\n", ...
    height(dati.macchinacaffe));

fprintf( ...
    "Microonde: %d campioni\n", ...
    height(dati.microonde));

fprintf( ...
    "Aggregato: %d campioni\n", ...
    height(dati.aggregato));


%% Verifica dei nomi delle colonne

disp(" ")
disp("==============================================")
disp("COLONNE PRESENTI")
disp("==============================================")

disp(dati.asciugatrice.Properties.VariableNames)


%% Verifica del tipo delle variabili

disp(" ")
disp("==============================================")
disp("TIPO DELLE VARIABILI")
disp("==============================================")

disp("ASCIUGATRICE")
varfun(@class, dati.asciugatrice)

disp("MACCHINA DA CAFFE")
varfun(@class, dati.macchinacaffe)

disp("MICROONDE")
varfun(@class, dati.microonde)

disp("AGGREGATO")
varfun(@class, dati.aggregato)


%% Controllo del periodo temporale disponibile

disp(" ")
disp("==============================================")
disp("PERIODO TEMPORALE DISPONIBILE")
disp("==============================================")


disp("ASCIUGATRICE")

disp("Prima acquisizione:")
disp(min(dati.asciugatrice.Timestamp))

disp("Ultima acquisizione:")
disp(max(dati.asciugatrice.Timestamp))


disp("MACCHINA DA CAFFE")

disp("Prima acquisizione:")
disp(min(dati.macchinacaffe.Timestamp))

disp("Ultima acquisizione:")
disp(max(dati.macchinacaffe.Timestamp))


disp("MICROONDE")

disp("Prima acquisizione:")
disp(min(dati.microonde.Timestamp))

disp("Ultima acquisizione:")
disp(max(dati.microonde.Timestamp))


disp("AGGREGATO")

disp("Prima acquisizione:")
disp(min(dati.aggregato.Timestamp))

disp("Ultima acquisizione:")
disp(max(dati.aggregato.Timestamp))


%% Verifica del passo temporale
% e della frequenza di campionamento equivalente

disp(" ")
disp("==============================================")
disp("RISOLUZIONE TEMPORALE DEI SEGNALI")
disp("==============================================")


% Estraggo i nomi dei segnali
nomiSegnali = fieldnames(dati);


% Scorro tutti i segnali
for i = 1:length(nomiSegnali)

    % Recupero il nome corrente
    nome = nomiSegnali{i};

    % Estraggo la tabella
    T = dati.(nome);

    % Ordino cronologicamente
    T = sortrows(T, "Timestamp");

    % Calcolo la distanza temporale
    % tra campioni consecutivi
    deltaT = ...
        seconds(diff(T.Timestamp));

    % Mantengo solamente differenze
    % finite e positive
    deltaT = ...
        deltaT( ...
            isfinite(deltaT) & ...
            deltaT > 0);

    % Verifico che siano presenti
    % intervalli temporali validi
    if isempty(deltaT)

        fprintf( ...
            "\n%s\n", ...
            upper(nome));

        fprintf( ...
            "Impossibile determinare il passo temporale.\n");

        continue

    end

    % Calcolo il passo temporale mediano
    passoMediano = ...
        median(deltaT);

    % Calcolo la frequenza equivalente
    frequenzaCampionamento = ...
        1 / passoMediano;


    %% Visualizzazione

    fprintf( ...
        "\n%s\n", ...
        upper(nome));

    fprintf( ...
        "Passo temporale mediano: %.3f s\n", ...
        passoMediano);

    fprintf( ...
        "Frequenza di campionamento equivalente: %.5f Hz\n", ...
        frequenzaCampionamento);

end


%% Analisi della regolarità temporale dei campioni

disp(" ")
disp("==============================================")
disp("REGOLARITA TEMPORALE")
disp("==============================================")


nomiSegnali = fieldnames(dati);


for i = 1:length(nomiSegnali)

    % Recupero il nome del segnale
    nome = nomiSegnali{i};

    % Estraggo e ordino la tabella
    T = sortrows( ...
        dati.(nome), ...
        "Timestamp");

    % Calcolo gli intervalli temporali
    deltaT = ...
        seconds(diff(T.Timestamp));

    % Mantengo solo intervalli validi
    deltaT = ...
        deltaT( ...
            isfinite(deltaT) & ...
            deltaT > 0);


    fprintf( ...
        "\n%s\n", ...
        upper(nome));


    if isempty(deltaT)

        fprintf( ...
            "Nessun intervallo temporale valido.\n");

        continue

    end


    fprintf( ...
        "Minimo: %.2f s\n", ...
        min(deltaT));

    fprintf( ...
        "25° percentile: %.2f s\n", ...
        prctile(deltaT, 25));

    fprintf( ...
        "Mediana: %.2f s\n", ...
        median(deltaT));

    fprintf( ...
        "75° percentile: %.2f s\n", ...
        prctile(deltaT, 75));

    fprintf( ...
        "90° percentile: %.2f s\n", ...
        prctile(deltaT, 90));

end


%% Caratterizzazione preliminare dei segnali di potenza

disp(" ")
disp("==============================================")
disp("CARATTERIZZAZIONE PRELIMINARE")
disp("==============================================")


% Estraggo i nomi dei segnali
nomiDispositivi = fieldnames(dati);


% Scorro tutti i segnali
for e = 1:length(nomiDispositivi)

    % Recupero il nome corrente
    nome = nomiDispositivi{e};

    % Estraggo la tabella
    T = dati.(nome);

    % Ordino cronologicamente
    T = sortrows(T, "Timestamp");


    %% Statistiche preliminari

    % Numero totale di campioni
    campioni = ...
        height(T);

    % Prima data disponibile
    dataInizio = ...
        min(T.Timestamp);

    % Ultima data disponibile
    dataFine = ...
        max(T.Timestamp);

    % Numero di giorni distinti
    giorni = ...
        length(unique(T.Data));

    % Potenza minima
    Pmin = ...
        min(T.P);

    % Potenza media
    Pmedia = ...
        mean(T.P);

    % Deviazione standard
    Pstd = ...
        std(T.P);

    % Potenza massima
    Pmax = ...
        max(T.P);


    %% Campioni nulli

    numeroCampioniNulli = ...
        sum(T.P == 0);

    percentualeCampioniNulli = ...
        100 * numeroCampioniNulli / ...
        campioni;


    %% Visualizzazione nella Command Window

    fprintf( ...
        "\n%s\n", ...
        upper(nome));

    fprintf( ...
        "Numero campioni: %d\n", ...
        campioni);

    fprintf( ...
        "Giorni disponibili: %d\n", ...
        giorni);

    fprintf( ...
        "Data iniziale: %s\n", ...
        char(dataInizio));

    fprintf( ...
        "Data finale: %s\n", ...
        char(dataFine));

    fprintf( ...
        "Potenza minima: %.3f W\n", ...
        Pmin);

    fprintf( ...
        "Potenza media: %.3f W\n", ...
        Pmedia);

    fprintf( ...
        "Deviazione standard: %.3f W\n", ...
        Pstd);

    fprintf( ...
        "Potenza massima: %.3f W\n", ...
        Pmax);

    fprintf( ...
        "Campioni nulli: %d (%.2f%%)\n", ...
        numeroCampioniNulli, ...
        percentualeCampioniNulli);


    %% Creazione della figura

    figure( ...
        "Name", ...
        "Caratterizzazione preliminare - " + ...
        string(nome), ...
        "NumberTitle", ...
        "off", ...
        "Position", ...
        [100 50 1200 850])


    tiledlayout( ...
        4, ...
        1, ...
        "TileSpacing", ...
        "compact", ...
        "Padding", ...
        "compact");


    %% Riquadro 1 - Statistiche

    nexttile

    axis off


    testo = {

        "Dispositivo: " + string(nome)

        "Numero campioni: " + string(campioni)

        "Giorni disponibili: " + string(giorni)

        "Data iniziale: " + string(dataInizio)

        "Data finale: " + string(dataFine)

        "Potenza minima: " + ...
            string(Pmin) + " W"

        "Potenza media: " + ...
            string(Pmedia) + " W"

        "Deviazione standard: " + ...
            string(Pstd) + " W"

        "Potenza massima: " + ...
            string(Pmax) + " W"

        "Campioni nulli: " + ...
            string(numeroCampioniNulli) + ...
            " (" + ...
            sprintf( ...
                "%.2f", ...
                percentualeCampioniNulli) + ...
            "%)"

        };


    text( ...
        0, ...
        0.5, ...
        testo, ...
        "FontSize", ...
        10)


    %% Riquadro 2 - Andamento temporale

    nexttile

    plot( ...
        T.Timestamp, ...
        T.P, ...
        "LineWidth", ...
        1)

    grid on

    xlabel("Tempo")

    ylabel("Potenza attiva [W]")

    title( ...
        "Andamento della potenza - " + ...
        string(nome))


    %% Riquadro 3 - Distribuzione completa

    nexttile

    histogram(T.P)

    grid on

    xlabel("Potenza attiva [W]")

    ylabel("Numero di campioni")

    title( ...
        "Distribuzione della potenza - " + ...
        string(nome))


    %% Riquadro 4 - Distribuzione senza valori nulli

    potenzaNonNulla = ...
        T.P(T.P > 0);


    nexttile


    if ~isempty(potenzaNonNulla)

        histogram(potenzaNonNulla)

        grid on

        xlabel("Potenza attiva [W]")

        ylabel("Numero di campioni")

        title( ...
            "Distribuzione della potenza senza valori nulli - " + ...
            string(nome))

    else

        axis off

        text( ...
            0.5, ...
            0.5, ...
            "Nessun campione con P > 0 W", ...
            "HorizontalAlignment", ...
            "center")

    end

end


%% Individuazione dei giorni comuni

disp(" ")
disp("==============================================")
disp("INDIVIDUAZIONE DEI GIORNI COMUNI")
disp("==============================================")


% Inizializzo la struttura
Comuni = struct();


% Estraggo i nomi di tutti i segnali
nomiSegnali = fieldnames(dati);


% Utilizzo i giorni del primo segnale
% come riferimento iniziale
giorniComuni = ...
    unique( ...
        dati.(nomiSegnali{1}).Data);


% Scorro tutti i segnali successivi
for e = 2:length(nomiSegnali)

    % Recupero il nome
    nome = nomiSegnali{e};

    % Estraggo i giorni disponibili
    giorniCorrenti = ...
        unique( ...
            dati.(nome).Data);

    % Mantengo solamente i giorni
    % presenti in entrambi gli insiemi
    giorniComuni = ...
        intersect( ...
            giorniComuni, ...
            giorniCorrenti);

end


% Salvo i giorni comuni
Comuni.giorni = ...
    giorniComuni;


%% Creazione della struttura contenente
% solamente i giorni comuni

Comuni.dati = struct();


for e = 1:length(nomiSegnali)

    % Recupero il nome corrente
    nome = nomiSegnali{e};

    % Estraggo la tabella completa
    T = dati.(nome);

    % Individuo le righe appartenenti
    % ai giorni comuni
    righeComuni = ...
        ismember( ...
            T.Data, ...
            Comuni.giorni);

    % Salvo solamente tali righe
    Comuni.dati.(nome) = ...
        T(righeComuni, :);

end


%% Verifica finale dei giorni comuni

disp(" ")
disp("==============================================")
disp("RISULTATI GIORNI COMUNI")
disp("==============================================")


fprintf( ...
    "Numero totale di giorni comuni: %d\n", ...
    length(Comuni.giorni));


if ~isempty(Comuni.giorni)

    fprintf( ...
        "Primo giorno comune: %s\n", ...
        char(min(Comuni.giorni)));

    fprintf( ...
        "Ultimo giorno comune: %s\n", ...
        char(max(Comuni.giorni)));

else

    warning( ...
        "Non sono stati individuati giorni comuni tra tutti i segnali.");

end


%% Numero di campioni presenti nei giorni comuni

disp(" ")
disp("Campioni disponibili nei giorni comuni:")


for e = 1:length(nomiSegnali)

    nome = nomiSegnali{e};

    fprintf( ...
        "%s: %d campioni\n", ...
        upper(nome), ...
        height(Comuni.dati.(nome)));

end


%% Fine della prima fase

disp(" ")
disp("==============================================")
disp("FINE FASE 1 - UTENTE 2")
disp("==============================================")

disp(" ")

disp( ...
    "Prima di procedere con soglie, stato di funzionamento ed eventi,")

disp( ...
    "analizzare i risultati e i grafici ottenuti.")

disp(" ")

%% ============================================================
%% FASE 2 - INDIVIDUAZIONE DELLO STATO DI FUNZIONAMENTO
%% ============================================================

%% Soglie preliminari di attivazione [W]

% Le soglie vengono definite sulla base
% delle distribuzioni preliminari della potenza.
%
% Asciugatrice:
% separazione tra zona di bassa potenza
% e fasi operative principali
%
% Macchina da caffe:
% esclusione dei valori prossimi allo zero
% mantenendo anche le fasi operative a potenza intermedia
%
% Microonde:
% netta separazione tra stato inattivo
% e funzionamento ad alta potenza

Soglie = struct();

Soglie.asciugatrice = 30;

Soglie.macchinacaffe = 30;

Soglie.microonde = 300;


%% Visualizzazione delle soglie adottate

disp(" ")
disp("==============================================")
disp("SOGLIE PRELIMINARI DI ATTIVAZIONE")
disp("==============================================")

fprintf( ...
    "Asciugatrice: %.1f W\n", ...
    Soglie.asciugatrice);

fprintf( ...
    "Macchina da caffe: %.1f W\n", ...
    Soglie.macchinacaffe);

fprintf( ...
    "Microonde: %.1f W\n", ...
    Soglie.microonde);


%% Aggiunta della colonna Attivo

% Estraggo i dispositivi
% per cui è stata definita una soglia

ElettrodomesticiConSoglia = ...
    fieldnames(Soglie);


% Scorro tutti i dispositivi

for e = 1:length(ElettrodomesticiConSoglia)

    % Recupero il nome corrente
    nome = ...
        ElettrodomesticiConSoglia{e};

    % Recupero la soglia
    sogliaCorrente = ...
        Soglie.(nome);

    % Ordino cronologicamente i dati
    dati.(nome) = ...
        sortrows( ...
            dati.(nome), ...
            "Timestamp");

    % Classifico ogni campione
    % come attivo o inattivo

    dati.(nome).Attivo = ...
        dati.(nome).P > ...
        sogliaCorrente;

end


%% Percentuale preliminare di campioni classificati come attivi

disp(" ")
disp("==============================================")
disp("CAMPIONI CLASSIFICATI COME ATTIVI")
disp("==============================================")

for e = 1:length(ElettrodomesticiConSoglia)

    nome = ...
        ElettrodomesticiConSoglia{e};

    numeroCampioni = ...
        height(dati.(nome));

    numeroAttivi = ...
        sum(dati.(nome).Attivo);

    percentualeAttivi = ...
        100 * numeroAttivi / numeroCampioni;

    fprintf( ...
        "%s: %d campioni attivi su %d (%.2f%%)\n", ...
        upper(nome), ...
        numeroAttivi, ...
        numeroCampioni, ...
        percentualeAttivi);

end


%% Verifica grafica delle soglie

for e = 1:length(ElettrodomesticiConSoglia)

    nome = ...
        ElettrodomesticiConSoglia{e};

    T = ...
        dati.(nome);

    figure( ...
        "Name", ...
        "Verifica soglia - " + string(nome), ...
        "NumberTitle", ...
        "off")

    plot( ...
        T.Timestamp, ...
        T.P, ...
        "LineWidth", ...
        1)

    hold on

    yline( ...
        Soglie.(nome), ...
        "--", ...
        "Soglia = " + ...
        string(Soglie.(nome)) + ...
        " W", ...
        "LineWidth", ...
        2)

    grid on

    xlabel("Tempo")

    ylabel("Potenza attiva [W]")

    title( ...
        "Verifica della soglia - " + ...
        string(nome))

    hold off

end


%% Zoom diagnostico dell'asciugatrice

T = dati.asciugatrice;

T = sortrows(T, "Timestamp");

% Individuo il primo campione superiore alla soglia
idxAttivo = find( ...
    T.P > Soglie.asciugatrice, ...
    1, ...
    'first');

if ~isempty(idxAttivo)

    tempoCentro = ...
        T.Timestamp(idxAttivo);

    % Finestra di 3 ore attorno all'attivazione
    tempoInizio = ...
        tempoCentro - hours(1);

    tempoFine = ...
        tempoCentro + hours(2);

    idxZoom = ...
        T.Timestamp >= tempoInizio & ...
        T.Timestamp <= tempoFine;

    figure( ...
        'Name', ...
        'Zoom diagnostico asciugatrice', ...
        'NumberTitle', ...
        'off', ...
        'Position', ...
        [100 250 1400 450])

    plot( ...
        T.Timestamp(idxZoom), ...
        T.P(idxZoom), ...
        'LineWidth', ...
        1.2)

    hold on

    yline( ...
        Soglie.asciugatrice, ...
        '--', ...
        'Soglia = ' + string(Soglie.asciugatrice) + ' W', ...
        'LineWidth', ...
        1.5)

    grid on

    xlabel('Tempo')

    ylabel('Potenza attiva [W]')

    title( ...
        'Zoom di un intervallo di funzionamento - asciugatrice')

    hold off

end


%% Rappresentazione dello stato preliminare

for e = 1:length(ElettrodomesticiConSoglia)

    nome = ...
        ElettrodomesticiConSoglia{e};

    T = ...
        dati.(nome);

    figure( ...
        "Name", ...
        "Stato preliminare - " + string(nome), ...
        "NumberTitle", ...
        "off")

    stairs( ...
        T.Timestamp, ...
        double(T.Attivo), ...
        "LineWidth", ...
        1)

    grid on

    xlabel("Tempo")

    ylabel("Stato")

    yticks([0 1])

    yticklabels( ...
        ["Inattivo", "Attivo"])

    ylim([-0.2 1.2])

    title( ...
        "Stato preliminare - " + ...
        string(nome))

end


%% ============================================================
%% AFFINAMENTO DELLO STATO DI FUNZIONAMENTO
%% ============================================================

% Una breve discesa sotto soglia può interrompere
% artificialmente un singolo utilizzo.
%
% La durata massima della pausa ricongiungibile
% viene definita separatamente per ciascun dispositivo.
%
% Per l'asciugatrice viene mantenuta una tolleranza maggiore,
% compatibile con possibili variazioni interne del ciclo.
%
% Per macchina da caffe e microonde viene utilizzato
% un intervallo molto più breve, poiché i loro utilizzi
% hanno generalmente durata ridotta.

SogliaPausa = struct();

SogliaPausa.asciugatrice = ...
    minutes(5);

SogliaPausa.macchinacaffe = ...
    minutes(1);

SogliaPausa.microonde = ...
    minutes(1);


% Estraggo i dispositivi analizzati

nomiDispositivi = ...
    fieldnames(Soglie);


%% Creazione dello stato definitivo

for e = 1:length(nomiDispositivi)

    % Recupero il dispositivo corrente
    nome = ...
        nomiDispositivi{e};

    % Estraggo i dati
    T = ...
        dati.(nome);

    % Ordino cronologicamente
    T = ...
        sortrows( ...
            T, ...
            "Timestamp");

    % Stato preliminare
    stato = ...
        logical(T.Attivo);

    % Inizialmente lo stato definitivo
    % coincide con quello preliminare
    statoDefinitivo = ...
        stato;


    %% Valutazione della continuita temporale

    if height(T) > 1

        deltaT = ...
            diff(T.Timestamp);

        % Utilizzo la mediana
        % come passo temporale tipico
        passoTipico = ...
            median(deltaT);

        % Una distanza superiore a tre volte
        % il passo tipico viene considerata
        % una discontinuita nei dati
        sogliaGapDati = ...
            3 * passoTipico;

    else

        deltaT = ...
            duration.empty(0,1);

        sogliaGapDati = ...
            seconds(0);

    end


    %% Individuazione delle pause inattive

% Creo il vettore logico degli stati inattivi
statoInattivo = ~stato;

% Individuo inizio e fine di ciascun intervallo inattivo
variazionePausa = ...
    diff([false; statoInattivo; false]);

iniziPausa = ...
    find(variazionePausa == 1);

finiPausa = ...
    find(variazionePausa == -1) - 1;


%% Analisi delle singole pause

for k = 1:length(iniziPausa)

    i1 = iniziPausa(k);
    i2 = finiPausa(k);

    % La pausa viene considerata solamente se
    % è effettivamente compresa tra due tratti attivi
    if i1 > 1 && i2 < height(T)

        attivoPrima = stato(i1 - 1);
        attivoDopo  = stato(i2 + 1);

        if attivoPrima && attivoDopo

            % Durata effettiva della pausa.
            %
            % Considero la distanza tra l'ultimo
            % campione attivo precedente e il primo
            % campione attivo successivo.
            durataPausa = ...
                T.Timestamp(i2 + 1) - ...
                T.Timestamp(i1 - 1);

            % Controllo della continuità temporale
            % nell'intervallo considerato
            intervalloLocale = ...
                diff( ...
                    T.Timestamp(i1 - 1:i2 + 1));

            presenzaGap = ...
                any( ...
                    intervalloLocale > sogliaGapDati);

            % Ricongiungo la pausa solamente se
            % è breve e non contiene veri gap
            if durataPausa <= SogliaPausa.(nome) && ...
                    ~presenzaGap

                statoDefinitivo(i1:i2) = true;

            end

        end

    end

end

    %% Analisi delle singole pause

    for k = 1:length(iniziPausa)

        i1 = ...
            iniziPausa(k);

        i2 = ...
            finiPausa(k);

        % Considero solamente pause
        % comprese tra due intervalli attivi
        if i1 > 1 && ...
                i2 < height(T)

            attivoPrima = ...
                stato(i1 - 1);

            attivoDopo = ...
                stato(i2 + 1);

            if attivoPrima && attivoDopo

                % Durata reale dell'intervallo
                % compreso tra i due tratti attivi
                durataPausa = ...
                    T.Timestamp(i2 + 1) - ...
                    T.Timestamp(i1 - 1);

                % Analizzo la continuita
                % dei campioni nella zona
                intervalloLocale = ...
                    diff( ...
                        T.Timestamp( ...
                        i1 - 1:i2 + 1));

                presenzaGap = ...
                    any( ...
                        intervalloLocale > ...
                        sogliaGapDati);


                % Ricongiungo la pausa
                % solamente se:
                %
                % - sufficientemente breve
                % - senza veri gap nei dati

                if durataPausa <= ...
                        SogliaPausa.(nome) && ...
                        ~presenzaGap

                    statoDefinitivo( ...
                        i1:i2) = true;

                end

            end

        end

    end


    %% Salvataggio

    T.StatoDefinitivo = ...
        statoDefinitivo;

    dati.(nome) = T;

end


%% ============================================================
%% ESTRAZIONE DEGLI EVENTI DI FUNZIONAMENTO
%% ============================================================

Eventi = struct();


for e = 1:length(nomiDispositivi)

    nome = ...
        nomiDispositivi{e};

    T = ...
        dati.(nome);

    T = ...
        sortrows( ...
            T, ...
            "Timestamp");

    stato = ...
        logical( ...
            T.StatoDefinitivo);


    %% Passo temporale tipico

    if height(T) > 1

        differenzeTempo = ...
            diff(T.Timestamp);

        intervalloCampionamento = ...
            median( ...
                differenzeTempo);

    else

        differenzeTempo = ...
            duration.empty(0,1);

        intervalloCampionamento = ...
            seconds(0);

    end


    %% Identificazione dei gap temporali

    sogliaGap = ...
        3 * intervalloCampionamento;

    gapTemporali = ...
        differenzeTempo > ...
        sogliaGap;


    %% Individuazione dell'inizio degli eventi

    nuovoEvento = ...
        false(height(T),1);

    if height(T) > 0

        nuovoEvento(1) = ...
            stato(1);

    end

    if height(T) > 1

        nuovoEvento(2:end) = ...
            stato(2:end) & ...
            ( ...
            ~stato(1:end-1) | ...
            gapTemporali ...
            );

    end

    indiciInizio = ...
        find(nuovoEvento);


    %% Individuazione della fine degli eventi

    fineEvento = ...
        false(height(T),1);

    if height(T) > 1

        fineEvento(1:end-1) = ...
            stato(1:end-1) & ...
            ( ...
            ~stato(2:end) | ...
            gapTemporali ...
            );

    end

    if height(T) > 0

        fineEvento(end) = ...
            stato(end);

    end

    indiciFine = ...
        find(fineEvento);


    %% Verifica di coerenza

    numeroEventi = ...
        length(indiciInizio);

    if length(indiciFine) ~= ...
            numeroEventi

        error( ...
            "Numero di inizi e fini non coerente per %s", ...
            nome);

    end


    %% Costruzione degli eventi

    timestampInizio = ...
        T.Timestamp(indiciInizio);

    % La fine coincide con il timestamp
    % dell'ultimo campione effettivamente attivo
    timestampFine = ...
        T.Timestamp(indiciFine);

    numeroEvento = ...
        (1:numeroEventi)';

    dataEvento = ...
        dateshift( ...
            timestampInizio, ...
            "start", ...
            "day");

    oraInizio = ...
        timeofday( ...
            timestampInizio);

    oraFine = ...
        timeofday( ...
            timestampFine);

    durataEvento = ...
        timestampFine - ...
        timestampInizio;


    %% Creazione della tabella

    tabellaEventi = table( ...
        numeroEvento, ...
        dataEvento, ...
        timestampInizio, ...
        timestampFine, ...
        oraInizio, ...
        oraFine, ...
        durataEvento);

    tabellaEventi.Properties.VariableNames = { ...
        'NumeroEvento', ...
        'Data', ...
        'TimestampInizio', ...
        'TimestampFine', ...
        'OraInizio', ...
        'OraFine', ...
        'Durata'};


    Eventi.(nome) = ...
        tabellaEventi;


    %% Riepilogo

    fprintf( ...
        '\n%s: %d eventi grezzi | gap rilevati: %d\n', ...
        upper(nome), ...
        numeroEventi, ...
        sum(gapTemporali));

end


%% ============================================================
%% ULTERIORE AFFINAMENTO DEGLI EVENTI
%% ============================================================

% Mantengo una copia degli eventi appena estratti

EventiGrezzi = ...
    Eventi;


% Inizializzo gli eventi definitivi

EventiDefinitivi = ...
    struct();


%% Pausa massima tra segmenti dello stesso utilizzo

PausaMassima = ...
    struct();

PausaMassima.asciugatrice = ...
    minutes(5);

PausaMassima.macchinacaffe = ...
    minutes(1);

PausaMassima.microonde = ...
    minutes(1);


%% Durata minima degli eventi validi

% La durata minima viene definita
% separatamente per dispositivo.
%
% Asciugatrice:
% 30 secondi, coerente con il precedente utente.
%
% Macchina da caffe e microonde:
% 10 secondi, per non eliminare utilizzi
% reali caratterizzati da durata molto breve.

DurataMinima = ...
    struct();

DurataMinima.asciugatrice = ...
    seconds(30);

DurataMinima.macchinacaffe = ...
    seconds(10);

DurataMinima.microonde = ...
    seconds(10);


%% Elaborazione degli eventi

nomiEventi = ...
    fieldnames(EventiGrezzi);


for e = 1:length(nomiEventi)

    nome = ...
        nomiEventi{e};

    pausaMassimaCorrente = ...
        PausaMassima.(nome);

    durataMinimaCorrente = ...
        DurataMinima.(nome);


    %% Dati originali

    TDati = ...
        dati.(nome);

    TDati = ...
        sortrows( ...
            TDati, ...
            "Timestamp");


    %% Passo temporale del dispositivo

    if height(TDati) > 1

        differenzeDati = ...
            diff(TDati.Timestamp);

        passoTipicoDati = ...
            median( ...
                differenzeDati);

        sogliaGapDati = ...
            3 * passoTipicoDati;

    else

        sogliaGapDati = ...
            seconds(0);

    end


    %% Eventi grezzi

    TEventi = ...
        EventiGrezzi.(nome);

    TEventi = ...
        sortrows( ...
            TEventi, ...
            "TimestampInizio");


    %% Caso senza eventi

    if isempty(TEventi)

        EventiDefinitivi.(nome) = ...
            TEventi;

        continue

    end


    %% Inizializzazione

    timestampInizioUniti = ...
        TEventi.TimestampInizio(1);

    timestampFineUniti = ...
        TEventi.TimestampFine(1);


    %% Raggruppamento degli eventi

    for k = 2:height(TEventi)

        pausa = ...
            TEventi.TimestampInizio(k) - ...
            timestampFineUniti(end);


        if pausa >= seconds(0) && ...
                pausa <= pausaMassimaCorrente


            %% Verifica della continuita dei dati

            righePausa = ...
                TDati.Timestamp >= ...
                timestampFineUniti(end) & ...
                TDati.Timestamp <= ...
                TEventi.TimestampInizio(k);

            timestampPausa = ...
                TDati.Timestamp( ...
                    righePausa);

            datiContinui = ...
                true;


            if length(timestampPausa) < 2

                datiContinui = ...
                    false;

            else

                deltaPausa = ...
                    diff(timestampPausa);

                if any( ...
                        deltaPausa > ...
                        sogliaGapDati)

                    datiContinui = ...
                        false;

                end

            end


            %% Ricongiungimento

            if datiContinui

                if TEventi.TimestampFine(k) > ...
                        timestampFineUniti(end)

                    timestampFineUniti(end) = ...
                        TEventi.TimestampFine(k);

                end

            else

                timestampInizioUniti(end+1,1) = ...
                    TEventi.TimestampInizio(k);

                timestampFineUniti(end+1,1) = ...
                    TEventi.TimestampFine(k);

            end


        else

            %% Nuovo evento indipendente

            timestampInizioUniti(end+1,1) = ...
                TEventi.TimestampInizio(k);

            timestampFineUniti(end+1,1) = ...
                TEventi.TimestampFine(k);

        end

    end


    %% Durata degli eventi raggruppati

    durataEventiUniti = ...
        timestampFineUniti - ...
        timestampInizioUniti;


    %% Selezione degli eventi validi

    eventiValidi = ...
        durataEventiUniti >= ...
        durataMinimaCorrente;


    timestampInizioDefinitivi = ...
        timestampInizioUniti( ...
            eventiValidi);

    timestampFineDefinitivi = ...
        timestampFineUniti( ...
            eventiValidi);

    durataDefinitiva = ...
        durataEventiUniti( ...
            eventiValidi);


    %% Costruzione della tabella definitiva

    numeroEventiDefinitivi = ...
        length( ...
            timestampInizioDefinitivi);

    numeroEvento = ...
        (1:numeroEventiDefinitivi)';

    dataEvento = ...
        dateshift( ...
            timestampInizioDefinitivi, ...
            "start", ...
            "day");

    oraInizio = ...
        timeofday( ...
            timestampInizioDefinitivi);

    oraFine = ...
        timeofday( ...
            timestampFineDefinitivi);


    tabellaEventiDefinitivi = ...
        table( ...
        numeroEvento, ...
        dataEvento, ...
        timestampInizioDefinitivi, ...
        timestampFineDefinitivi, ...
        oraInizio, ...
        oraFine, ...
        durataDefinitiva);


    tabellaEventiDefinitivi.Properties.VariableNames = { ...
        'NumeroEvento', ...
        'Data', ...
        'TimestampInizio', ...
        'TimestampFine', ...
        'OraInizio', ...
        'OraFine', ...
        'Durata'};


    EventiDefinitivi.(nome) = ...
        tabellaEventiDefinitivi;

end


%% ============================================================
%% CONFRONTO EVENTI GREZZI / DEFINITIVI
%% ============================================================

disp(" ")
disp("==============================================")
disp("CONFRONTO EVENTI GREZZI / DEFINITIVI")
disp("==============================================")


for e = 1:length(nomiEventi)

    nome = ...
        nomiEventi{e};

    numeroGrezzi = ...
        height( ...
            EventiGrezzi.(nome));

    numeroDefinitivi = ...
        height( ...
            EventiDefinitivi.(nome));

    riduzione = ...
        numeroGrezzi - ...
        numeroDefinitivi;

    if numeroGrezzi > 0

        percentualeRiduzione = ...
            100 * riduzione / ...
            numeroGrezzi;

    else

        percentualeRiduzione = ...
            0;

    end


    fprintf( ...
        "%s --> Grezzi: %d | Definitivi: %d | Riduzione: %d (%.2f%%)\n", ...
        upper(nome), ...
        numeroGrezzi, ...
        numeroDefinitivi, ...
        riduzione, ...
        percentualeRiduzione);

end


%% ============================================================
%% STATISTICHE PRELIMINARI DELLE DURATE
%% ============================================================

disp(" ")
disp("==============================================")
disp("DURATA DEGLI EVENTI DEFINITIVI")
disp("==============================================")


for e = 1:length(nomiEventi)

    nome = ...
        nomiEventi{e};

    TEventi = ...
        EventiDefinitivi.(nome);


    if isempty(TEventi)

        fprintf( ...
            "\n%s: nessun evento definitivo.\n", ...
            upper(nome));

        continue

    end


    durataMinuti = ...
        minutes( ...
            TEventi.Durata);


    fprintf( ...
        "\n%s\n", ...
        upper(nome));

    fprintf( ...
        "Numero eventi: %d\n", ...
        height(TEventi));

    fprintf( ...
        "Durata minima: %.2f min\n", ...
        min(durataMinuti));

    fprintf( ...
        "25° percentile: %.2f min\n", ...
        prctile(durataMinuti,25));

    fprintf( ...
        "Durata mediana: %.2f min\n", ...
        median(durataMinuti));

    fprintf( ...
        "75° percentile: %.2f min\n", ...
        prctile(durataMinuti,75));

    fprintf( ...
        "90° percentile: %.2f min\n", ...
        prctile(durataMinuti,90));

    fprintf( ...
        "Durata massima: %.2f min\n", ...
        max(durataMinuti));


    %% Istogramma

    figure( ...
        "Name", ...
        "Distribuzione durate - " + string(nome), ...
        "NumberTitle", ...
        "off")

    histogram( ...
        durataMinuti)

    grid on

    xlabel( ...
        "Durata evento [min]")

    ylabel( ...
        "Numero di eventi")

    title( ...
        "Distribuzione delle durate - " + ...
        string(nome))

end


%% ============================================================
%% FINE FASE 2
%% ============================================================

disp(" ")
disp("==============================================")
disp("FINE FASE 2 - UTENTE 2")
disp("==============================================")

%% ============================================================
%% FASE 3 - DISTRIBUZIONE TEMPORALE DELLE ATTIVAZIONI
%% ============================================================

% L'analisi viene effettuata a partire dagli eventi definitivi.
%
% Ogni evento viene assegnato alla fascia oraria
% corrispondente al proprio istante di inizio.
%
% In questo modo viene analizzato il numero di utilizzi
% che iniziano in ciascuna ora della giornata,
% indipendentemente dalla loro durata.


%% Inizializzazione

DistribuzioneOraria = struct();

nomiDispositivi = ...
    fieldnames(EventiDefinitivi);


%% Analisi dei singoli dispositivi

for e = 1:length(nomiDispositivi)

    nome = ...
        nomiDispositivi{e};

    TEventi = ...
        EventiDefinitivi.(nome);


    %% Caso senza eventi

    if isempty(TEventi)

        DistribuzioneOraria.(nome) = ...
            zeros(24,1);

        continue

    end


    %% Estrazione dell'ora di inizio

    oraEvento = ...
        hour( ...
            TEventi.TimestampInizio);


    %% Conteggio degli eventi per ora

    conteggiOrari = ...
        histcounts( ...
            oraEvento, ...
            0:24);


    conteggiOrari = ...
        conteggiOrari(:);


    %% Salvataggio

    DistribuzioneOraria.(nome) = ...
        conteggiOrari;


    %% Individuazione della fascia più frequente

    [numeroMassimo, indiceMassimo] = ...
        max(conteggiOrari);

    oraMassima = ...
        indiceMassimo - 1;

    percentualeMassima = ...
        100 * numeroMassimo / ...
        height(TEventi);


    %% Visualizzazione dei risultati

    fprintf( ...
        "\n%s\n", ...
        upper(nome));

    fprintf( ...
        "Numero totale di eventi: %d\n", ...
        height(TEventi));

    fprintf( ...
        "Fascia oraria con più attivazioni: %02d:00-%02d:00\n", ...
        oraMassima, ...
        mod(oraMassima + 1,24));

    fprintf( ...
        "Eventi nella fascia: %d (%.2f%%)\n", ...
        numeroMassimo, ...
        percentualeMassima);


    %% Grafico

    figure( ...
        "Name", ...
        "Distribuzione oraria - " + string(nome), ...
        "NumberTitle", ...
        "off")

    bar( ...
        0:23, ...
        conteggiOrari)

    grid on

    xlabel( ...
        "Ora del giorno")

    ylabel( ...
        "Numero di attivazioni")

    title( ...
        "Distribuzione oraria delle attivazioni - " + ...
        string(nome))

    xticks(0:23)

    xlim([-0.5 23.5])

end


%% ============================================================
%% DISTRIBUZIONE ORARIA NORMALIZZATA
%% ============================================================

% La distribuzione percentuale permette di confrontare
% dispositivi caratterizzati da un numero differente
% di eventi complessivi.


for e = 1:length(nomiDispositivi)

    nome = ...
        nomiDispositivi{e};

    conteggi = ...
        DistribuzioneOraria.(nome);

    totale = ...
        sum(conteggi);


    if totale > 0

        percentuali = ...
            100 * conteggi / totale;

    else

        percentuali = ...
            zeros(24,1);

    end


    figure( ...
        "Name", ...
        "Distribuzione oraria percentuale - " + string(nome), ...
        "NumberTitle", ...
        "off")

    bar( ...
        0:23, ...
        percentuali)

    grid on

    xlabel( ...
        "Ora del giorno")

    ylabel( ...
        "Percentuale di attivazioni [%]")

    title( ...
        "Distribuzione percentuale delle attivazioni - " + ...
        string(nome))

    xticks(0:23)

    xlim([-0.5 23.5])

end


%% ============================================================
%% FINE FASE 3
%% ============================================================

disp(" ")
disp("==============================================")
disp("FINE FASE 3 - UTENTE 2")
disp("==============================================")

%% ============================================================
%% FASE 4 - ANALISI DELLA CONTEMPORANEITA
%% ============================================================

% L'analisi viene effettuata esclusivamente
% sui giorni comuni a tutti i segnali.
%
% Lo stato di ciascun dispositivo viene ricostruito
% a partire dagli eventi definitivi.
%
% In questo modo è possibile valutare:
%
% - il numero di dispositivi contemporaneamente attivi
% - le combinazioni di utilizzo simultaneo


%% Dispositivi considerati

dispositiviContemporaneita = { ...
    'asciugatrice', ...
    'macchinacaffe', ...
    'microonde'};


numeroDispositivi = ...
    length(dispositiviContemporaneita);


%% ============================================================
%% COSTRUZIONE DEL RIFERIMENTO TEMPORALE COMUNE
%% ============================================================

% Utilizzo come riferimento temporale
% i timestamp del segnale aggregato
% appartenenti ai giorni comuni.

TAggregato = ...
    Comuni.dati.aggregato;

TAggregato = ...
    sortrows( ...
        TAggregato, ...
        "Timestamp");


tempoComune = ...
    TAggregato.Timestamp;


%% Inizializzazione della matrice degli stati

% Ogni colonna rappresenta un dispositivo.
% Ogni riga rappresenta un istante temporale
% del riferimento comune.

StatiContemporanei = ...
    false( ...
        length(tempoComune), ...
        numeroDispositivi);


%% ============================================================
%% RICOSTRUZIONE DELLO STATO DEI DISPOSITIVI
%% ============================================================

for d = 1:numeroDispositivi

    nome = ...
        dispositiviContemporaneita{d};

    TEventi = ...
        EventiDefinitivi.(nome);


    % Considero solamente gli eventi
    % appartenenti ai giorni comuni

    eventiComuni = ...
        ismember( ...
            TEventi.Data, ...
            Comuni.giorni);

    TEventi = ...
        TEventi( ...
            eventiComuni, :);


    %% Ricostruzione dello stato

    for k = 1:height(TEventi)

        dentroEvento = ...
            tempoComune >= ...
            TEventi.TimestampInizio(k) & ...
            tempoComune <= ...
            TEventi.TimestampFine(k);

        StatiContemporanei( ...
            dentroEvento, d) = true;

    end

end


%% ============================================================
%% NUMERO DI DISPOSITIVI CONTEMPORANEAMENTE ATTIVI
%% ============================================================

numeroAttivi = ...
    sum( ...
        StatiContemporanei, ...
        2);


%% Riepilogo

disp(" ")
disp("==============================================")
disp("CONTEMPORANEITA DEI DISPOSITIVI")
disp("==============================================")


for n = 0:numeroDispositivi

    numeroCampioni = ...
        sum( ...
            numeroAttivi == n);

    percentuale = ...
        100 * numeroCampioni / ...
        length(numeroAttivi);

    fprintf( ...
        "%d dispositivi attivi: %d campioni (%.3f%%)\n", ...
        n, ...
        numeroCampioni, ...
        percentuale);

end


%% ============================================================
%% DISTRIBUZIONE DEL NUMERO DI DISPOSITIVI ATTIVI
%% ============================================================

conteggioAttivi = ...
    zeros( ...
        numeroDispositivi + 1, ...
        1);


for n = 0:numeroDispositivi

    conteggioAttivi(n + 1) = ...
        sum( ...
            numeroAttivi == n);

end


figure( ...
    "Name", ...
    "Contemporaneita dei dispositivi", ...
    "NumberTitle", ...
    "off")

bar( ...
    0:numeroDispositivi, ...
    conteggioAttivi)

grid on

xlabel( ...
    "Numero di dispositivi contemporaneamente attivi")

ylabel( ...
    "Numero di campioni")

title( ...
    "Distribuzione della contemporaneita")

xticks( ...
    0:numeroDispositivi)


%% ============================================================
%% ANALISI DELLE COMBINAZIONI
%% ============================================================

% Con tre dispositivi sono possibili
% 2^3 = 8 configurazioni differenti.

numeroConfigurazioni = ...
    2^numeroDispositivi;


conteggioConfigurazioni = ...
    zeros( ...
        numeroConfigurazioni, ...
        1);


etichetteConfigurazioni = ...
    strings( ...
        numeroConfigurazioni, ...
        1);


for c = 0:(numeroConfigurazioni - 1)

    configurazione = ...
        logical( ...
            bitget( ...
                c, ...
                1:numeroDispositivi));


    righeConfigurazione = ...
        all( ...
            StatiContemporanei == ...
            configurazione, ...
            2);


    conteggioConfigurazioni(c + 1) = ...
        sum( ...
            righeConfigurazione);


    %% Creazione dell'etichetta

    dispositiviAttivi = ...
        dispositiviContemporaneita( ...
            configurazione);


    if isempty(dispositiviAttivi)

        etichetta = ...
            "Nessun dispositivo";

    else

        etichetta = ...
            strjoin( ...
                string(dispositiviAttivi), ...
                " + ");

    end


    etichetteConfigurazioni(c + 1) = ...
        etichetta;

end


%% ============================================================
%% TABELLA DELLE CONFIGURAZIONI
%% ============================================================

percentualeConfigurazioni = ...
    100 * ...
    conteggioConfigurazioni / ...
    length(tempoComune);


TabellaContemporaneita = ...
    table( ...
        etichetteConfigurazioni, ...
        conteggioConfigurazioni, ...
        percentualeConfigurazioni);


TabellaContemporaneita.Properties.VariableNames = { ...
    'Configurazione', ...
    'NumeroCampioni', ...
    'Percentuale'};


% Ordino dalla configurazione
% più frequente alla meno frequente

TabellaContemporaneita = ...
    sortrows( ...
        TabellaContemporaneita, ...
        "NumeroCampioni", ...
        "descend");


disp(" ")
disp("==============================================")
disp("CONFIGURAZIONI DI UTILIZZO")
disp("==============================================")

disp( ...
    TabellaContemporaneita)


%% ============================================================
%% FINE ANALISI DELLA CONTEMPORANEITA
%% ============================================================

disp(" ")
disp("==============================================")
disp("FINE ANALISI CONTEMPORANEITA - UTENTE 2")
disp("==============================================")

%% ============================================================
%% FASE 5 - ANALISI DELLA POTENZA NON MONITORATA
%% ============================================================

% L'analisi viene effettuata sui giorni comuni
% a tutti i segnali disponibili.
%
% Il segnale aggregato viene utilizzato
% come riferimento temporale.
%
% Per ciascun timestamp dell'aggregato viene individuato
% il campione temporalmente più vicino dei dispositivi
% monitorati individualmente.
%
% Viene mantenuta una tolleranza temporale massima
% di 5 minuti, coerente con quanto utilizzato
% nell'analisi dell'Utente 1.


%% Dispositivi monitorati individualmente

nomiMonitorati = { ...
    'asciugatrice', ...
    'macchinacaffe', ...
    'microonde'};


numeroMonitorati = ...
    length(nomiMonitorati);


%% Tolleranza temporale massima

tolleranzaMassima = ...
    minutes(5);


%% ============================================================
%% DEFINIZIONE DEL SEGNALE TEMPORALE DI RIFERIMENTO
%% ============================================================

% Estraggo il segnale aggregato
% limitatamente ai giorni comuni

TAggregato = ...
    Comuni.dati.aggregato;


% Ordino cronologicamente

TAggregato = ...
    sortrows( ...
        TAggregato, ...
        'Timestamp');


% Elimino eventuali timestamp duplicati

[~, indiciUnici] = ...
    unique( ...
        TAggregato.Timestamp, ...
        'stable');


TAggregato = ...
    TAggregato( ...
        indiciUnici, :);


% Utilizzo i timestamp dell'aggregato
% come riferimento temporale

timestampRiferimento = ...
    TAggregato.Timestamp;


% Estraggo la potenza aggregata

potenzaAggregata = ...
    TAggregato.P;


% Numero totale di campioni di riferimento

numeroCampioni = ...
    height(TAggregato);


%% ============================================================
%% RICERCA DEL CAMPIONE PIU VICINO
%% ============================================================

% Inizializzo la matrice delle potenze allineate
%
% righe   = timestamp dell'aggregato
% colonne = dispositivi monitorati

potenzeAllineate = ...
    NaN( ...
        numeroCampioni, ...
        numeroMonitorati);


% Definisco una origine temporale comune

origineTemporale = ...
    timestampRiferimento(1);


% Converto il tempo dell'aggregato
% in secondi rispetto all'origine

tempoRiferimentoSecondi = ...
    seconds( ...
        timestampRiferimento - ...
        origineTemporale);


%% Elaborazione dei singoli dispositivi

for e = 1:numeroMonitorati

    nome = ...
        nomiMonitorati{e};


    % Estraggo i dati
    % relativi ai giorni comuni

    T = ...
        Comuni.dati.(nome);


    % Ordino cronologicamente

    T = ...
        sortrows( ...
            T, ...
            'Timestamp');


    % Elimino eventuali timestamp duplicati

    [~, indiciUnici] = ...
        unique( ...
            T.Timestamp, ...
            'stable');


    T = ...
        T( ...
            indiciUnici, :);


    % Converto i timestamp del dispositivo
    % in secondi rispetto alla stessa origine

    tempoSegnaleSecondi = ...
        seconds( ...
            T.Timestamp - ...
            origineTemporale);


    % Creo il vettore degli indici

    indiciSegnale = ...
        (1:height(T))';


    % Per ogni timestamp dell'aggregato
    % individuo il campione temporalmente più vicino

    indiceVicino = ...
        interp1( ...
            tempoSegnaleSecondi, ...
            indiciSegnale, ...
            tempoRiferimentoSecondi, ...
            'nearest', ...
            NaN);


    %% Verifica delle associazioni

    righeConIndice = ...
        ~isnan( ...
            indiceVicino);


    indiceVicinoValido = ...
        round( ...
            indiceVicino( ...
                righeConIndice));


    % Calcolo la distanza temporale
    % tra campione aggregato e campione associato

    distanzaTemporale = ...
        abs( ...
            timestampRiferimento( ...
                righeConIndice) - ...
            T.Timestamp( ...
                indiceVicinoValido));


    % Mantengo solamente gli abbinamenti
    % entro la tolleranza definita

    associazioneValida = ...
        distanzaTemporale <= ...
        tolleranzaMassima;


    % Recupero le posizioni originali

    posizioniRiferimento = ...
        find( ...
            righeConIndice);


    posizioniValide = ...
        posizioniRiferimento( ...
            associazioneValida);


    indiciValidiSegnale = ...
        indiceVicinoValido( ...
            associazioneValida);


    % Salvo le potenze allineate

    potenzeAllineate( ...
        posizioniValide, e) = ...
        T.P( ...
            indiciValidiSegnale);

end


%% ============================================================
%% SELEZIONE DEI TIMESTAMP COMPLETAMENTE CONFRONTABILI
%% ============================================================

% Mantengo solamente gli istanti
% in cui risultano disponibili:
%
% - potenza aggregata
% - asciugatrice
% - macchina da caffe
% - microonde

righeValide = ...
    ~isnan( ...
        potenzaAggregata) & ...
    all( ...
        ~isnan( ...
            potenzeAllineate), ...
        2);


timestampValidi = ...
    timestampRiferimento( ...
        righeValide);


potenzaAggregataValida = ...
    potenzaAggregata( ...
        righeValide);


potenzeMonitorateValide = ...
    potenzeAllineate( ...
        righeValide, :);


%% ============================================================
%% CALCOLO DELLA POTENZA NON MONITORATA
%% ============================================================

% Sommo le potenze dei tre dispositivi
% monitorati individualmente

potenzaMonitorata = ...
    sum( ...
        potenzeMonitorateValide, ...
        2);


% Residuo grezzo

potenzaResidua = ...
    potenzaAggregataValida - ...
    potenzaMonitorata;


% Impongo a zero i residui negativi
% per ottenere una stima fisicamente ammissibile

potenzaNonMonitorata = ...
    max( ...
        potenzaResidua, ...
        0);


% Parte della potenza aggregata
% effettivamente spiegata
% dai sensori individuali

potenzaSpiegata = ...
    min( ...
        potenzaMonitorata, ...
        potenzaAggregataValida);


%% ============================================================
%% CREAZIONE DELLA TABELLA DEI RISULTATI
%% ============================================================

PotenzaNonMonitorata = ...
    table( ...
        timestampValidi, ...
        potenzaAggregataValida, ...
        potenzaMonitorata, ...
        potenzaSpiegata, ...
        potenzaResidua, ...
        potenzaNonMonitorata);


PotenzaNonMonitorata.Properties.VariableNames = { ...
    'Timestamp', ...
    'PotenzaAggregata', ...
    'PotenzaMonitorata', ...
    'PotenzaSpiegata', ...
    'PotenzaResidua', ...
    'PotenzaNonMonitorata'};


%% ============================================================
%% STATISTICHE PRINCIPALI
%% ============================================================

potenzaAggregataMedia = ...
    mean( ...
        potenzaAggregataValida);


potenzaMonitorataMedia = ...
    mean( ...
        potenzaMonitorata);


potenzaNonMonitorataMedia = ...
    mean( ...
        potenzaNonMonitorata);


potenzaNonMonitorataMassima = ...
    max( ...
        potenzaNonMonitorata);


numeroResiduiNegativi = ...
    sum( ...
        potenzaResidua < 0);


percentualeResiduiNegativi = ...
    100 * ...
    numeroResiduiNegativi / ...
    length(potenzaResidua);


percentualeCampioniUtilizzati = ...
    100 * ...
    sum(righeValide) / ...
    numeroCampioni;


%% Visualizzazione delle statistiche

disp(" ")
disp("==============================================")
disp("POTENZA NON MONITORATA")
disp("==============================================")


fprintf( ...
    "Campioni aggregati disponibili: %d\n", ...
    numeroCampioni);


fprintf( ...
    "Campioni completamente confrontabili: %d\n", ...
    length(timestampValidi));


fprintf( ...
    "Percentuale campioni utilizzati: %.2f%%\n", ...
    percentualeCampioniUtilizzati);


fprintf( ...
    "Potenza aggregata media: %.2f W\n", ...
    potenzaAggregataMedia);


fprintf( ...
    "Potenza monitorata media: %.2f W\n", ...
    potenzaMonitorataMedia);


fprintf( ...
    "Potenza non monitorata media: %.2f W\n", ...
    potenzaNonMonitorataMedia);


fprintf( ...
    "Potenza non monitorata massima: %.2f W\n", ...
    potenzaNonMonitorataMassima);


fprintf( ...
    "Residui negativi: %d (%.2f%%)\n", ...
    numeroResiduiNegativi, ...
    percentualeResiduiNegativi);


%% ============================================================
%% CALCOLO DELLE ENERGIE GIORNO PER GIORNO
%% ============================================================

% Estraggo la data
% di ciascun timestamp valido

dateValide = ...
    dateshift( ...
        timestampValidi, ...
        'start', ...
        'day');


% Individuo i giorni effettivamente utilizzati

giorniValidi = ...
    unique( ...
        dateValide);


% Inizializzo le energie complessive

energiaAggregata_Wh = 0;

energiaSpiegata_Wh = 0;

energiaNonMonitorata_Wh = 0;


%% Integrazione giornaliera

for g = 1:length(giorniValidi)

    righeGiorno = ...
        dateValide == ...
        giorniValidi(g);


    tempoGiorno = ...
        timestampValidi( ...
            righeGiorno);


    % Per effettuare l'integrazione
    % servono almeno due campioni

    if length(tempoGiorno) < 2

        continue

    end


    % Converto il tempo in ore
    % rispetto al primo campione del giorno

    tempoOre = ...
        hours( ...
            tempoGiorno - ...
            tempoGiorno(1));


    %% Energia aggregata

    energiaAggregata_Wh = ...
        energiaAggregata_Wh + ...
        trapz( ...
            tempoOre, ...
            potenzaAggregataValida( ...
                righeGiorno));


    %% Energia spiegata

    energiaSpiegata_Wh = ...
        energiaSpiegata_Wh + ...
        trapz( ...
            tempoOre, ...
            potenzaSpiegata( ...
                righeGiorno));


    %% Energia non monitorata

    energiaNonMonitorata_Wh = ...
        energiaNonMonitorata_Wh + ...
        trapz( ...
            tempoOre, ...
            potenzaNonMonitorata( ...
                righeGiorno));

end


%% ============================================================
%% INDICATORI ENERGETICI
%% ============================================================

coperturaMonitoraggio = ...
    100 * ...
    energiaSpiegata_Wh / ...
    energiaAggregata_Wh;


percentualeEnergiaNonMonitorata = ...
    100 * ...
    energiaNonMonitorata_Wh / ...
    energiaAggregata_Wh;


fprintf( ...
    "\nEnergia aggregata: %.2f kWh\n", ...
    energiaAggregata_Wh / 1000);


fprintf( ...
    "Energia spiegata: %.2f kWh\n", ...
    energiaSpiegata_Wh / 1000);


fprintf( ...
    "Energia non monitorata: %.2f kWh\n", ...
    energiaNonMonitorata_Wh / 1000);


fprintf( ...
    "Copertura energetica del monitoraggio: %.2f%%\n", ...
    coperturaMonitoraggio);


fprintf( ...
    "Energia non monitorata: %.2f%%\n", ...
    percentualeEnergiaNonMonitorata);


%% ============================================================
%% RAPPRESENTAZIONE DELLA POTENZA NON MONITORATA
%% ============================================================

tempoPlot = ...
    PotenzaNonMonitorata.Timestamp;


potenzaPlot = ...
    PotenzaNonMonitorata.PotenzaNonMonitorata;


%% Individuazione dei salti temporali

saltiTemporali = ...
    diff( ...
        tempoPlot);


indiciSalto = ...
    find( ...
        saltiTemporali > ...
        hours(1));


% Inserisco NaT e NaN
% per evitare collegamenti grafici
% tra periodi non consecutivi

for k = flip( ...
        indiciSalto')

    tempoPlot = [ ...
        tempoPlot(1:k); ...
        NaT( ...
            1, ...
            1, ...
            'TimeZone', ...
            tempoPlot.TimeZone); ...
        tempoPlot(k + 1:end)];


    potenzaPlot = [ ...
        potenzaPlot(1:k); ...
        NaN; ...
        potenzaPlot(k + 1:end)];

end


%% Creazione della figura

figure( ...
    'Name', ...
    'Analisi della potenza non monitorata - Utente 2', ...
    'NumberTitle', ...
    'off')


tiledlayout( ...
    2, ...
    1)


%% Andamento temporale

nexttile


plot( ...
    tempoPlot, ...
    potenzaPlot, ...
    'LineWidth', ...
    1)


grid on


xlabel( ...
    'Tempo')


ylabel( ...
    'Potenza [W]')


title( ...
    'Andamento della potenza non monitorata')


%% Distribuzione

nexttile


limiteIstogramma = ...
    prctile( ...
        PotenzaNonMonitorata.PotenzaNonMonitorata, ...
        99.5);


valoriIstogramma = ...
    PotenzaNonMonitorata.PotenzaNonMonitorata( ...
        PotenzaNonMonitorata.PotenzaNonMonitorata <= ...
        limiteIstogramma);


histogram( ...
    valoriIstogramma)


grid on


xlabel( ...
    'Potenza non monitorata [W]')


ylabel( ...
    'Numero di campioni')


title( ...
    'Distribuzione della potenza non monitorata')


%% ============================================================
%% FINE FASE 5
%% ============================================================

disp(" ")
disp("==============================================")
disp("FINE FASE 5 - UTENTE 2")
disp("==============================================")

%% ============================================================
%% FASE 6 - CARATTERIZZAZIONE DEGLI EVENTI
%% ============================================================

% Per ciascun evento definitivo vengono calcolate:
%
% - durata
% - potenza media
% - potenza massima
% - energia
% - numero di campioni disponibili
%
% La procedura è mantenuta coerente
% con quella utilizzata per l'Utente 1.


%% Inizializzazione

CaratteristicheEventi = struct();

nomiDispositivi = ...
    fieldnames(EventiDefinitivi);

numeroDispositivi = ...
    length(nomiDispositivi);


%% Inizializzazione del riepilogo generale

nomeRiepilogo = ...
    strings(numeroDispositivi, 1);

numeroEventiRiepilogo = ...
    zeros(numeroDispositivi, 1);

durataMediaRiepilogo = ...
    duration( ...
        zeros(numeroDispositivi,1), ...
        zeros(numeroDispositivi,1), ...
        zeros(numeroDispositivi,1));

durataMinimaRiepilogo = ...
    durataMediaRiepilogo;

durataMassimaRiepilogo = ...
    durataMediaRiepilogo;

potenzaMediaRiepilogo = ...
    NaN(numeroDispositivi, 1);

potenzaMassimaRiepilogo = ...
    NaN(numeroDispositivi, 1);

energiaMediaRiepilogo = ...
    NaN(numeroDispositivi, 1);

energiaMinimaRiepilogo = ...
    NaN(numeroDispositivi, 1);

energiaMassimaRiepilogo = ...
    NaN(numeroDispositivi, 1);

energiaTotaleRiepilogo = ...
    NaN(numeroDispositivi, 1);


%% ============================================================
%% CALCOLO DELLE CARATTERISTICHE DEGLI EVENTI
%% ============================================================

for e = 1:numeroDispositivi

    nome = ...
        nomiDispositivi{e};

    nomeRiepilogo(e) = ...
        string(nome);


    %% Eventi definitivi

    TEventi = ...
        EventiDefinitivi.(nome);


    %% Dati originali

    TDati = ...
        dati.(nome);

    TDati = ...
        sortrows( ...
            TDati, ...
            'Timestamp');


    %% Numero totale di eventi

    numeroEventi = ...
        height(TEventi);

    numeroEventiRiepilogo(e) = ...
        numeroEventi;


    %% Inizializzazione delle caratteristiche

    potenzaMediaEvento = ...
        NaN(numeroEventi, 1);

    potenzaMassimaEvento = ...
        NaN(numeroEventi, 1);

    energiaEvento_Wh = ...
        NaN(numeroEventi, 1);

    numeroCampioniEvento = ...
        zeros(numeroEventi, 1);


    %% Analisi dei singoli eventi

    for k = 1:numeroEventi

        timestampInizio = ...
            TEventi.TimestampInizio(k);

        timestampFine = ...
            TEventi.TimestampFine(k);


        % Individuo tutti i campioni
        % appartenenti all'intervallo dell'evento

        righeEvento = ...
            TDati.Timestamp >= timestampInizio & ...
            TDati.Timestamp <= timestampFine;


        TEvento = ...
            TDati(righeEvento, :);


        numeroCampioniEvento(k) = ...
            height(TEvento);


        % Se non sono presenti campioni
        % passo all'evento successivo

        if isempty(TEvento)

            continue

        end


        %% Potenza media

        potenzaMediaEvento(k) = ...
            mean( ...
                TEvento.P);


        %% Potenza massima

        potenzaMassimaEvento(k) = ...
            max( ...
                TEvento.P);


        %% Energia

        if height(TEvento) >= 2

            % Converto il tempo in ore
            % rispetto al primo campione dell'evento

            tempoEventoOre = ...
                hours( ...
                    TEvento.Timestamp - ...
                    TEvento.Timestamp(1));


            % Integrazione trapezoidale

            energiaEvento_Wh(k) = ...
                trapz( ...
                    tempoEventoOre, ...
                    TEvento.P);

        else

            % Caso con un solo campione

            durataEventoOre = ...
                hours( ...
                    TEventi.Durata(k));


            energiaEvento_Wh(k) = ...
                TEvento.P(1) * ...
                durataEventoOre;

        end

    end


    %% ========================================================
    %% SALVATAGGIO DELLE CARATTERISTICHE
    %% ========================================================

    tabellaCaratteristiche = ...
        TEventi;


    tabellaCaratteristiche.NumeroCampioni = ...
        numeroCampioniEvento;


    tabellaCaratteristiche.PotenzaMedia_W = ...
        potenzaMediaEvento;


    tabellaCaratteristiche.PotenzaMassima_W = ...
        potenzaMassimaEvento;


    tabellaCaratteristiche.Energia_Wh = ...
        energiaEvento_Wh;


    CaratteristicheEventi.(nome) = ...
        tabellaCaratteristiche;


    %% ========================================================
    %% INDICATORI GENERALI
    %% ========================================================

    if numeroEventi == 0

        continue

    end


    durataMediaRiepilogo(e) = ...
        mean(TEventi.Durata);

    durataMinimaRiepilogo(e) = ...
        min(TEventi.Durata);

    durataMassimaRiepilogo(e) = ...
        max(TEventi.Durata);


    potenzaMediaRiepilogo(e) = ...
        mean( ...
            potenzaMediaEvento, ...
            'omitnan');


    potenzaMassimaRiepilogo(e) = ...
        max( ...
            potenzaMassimaEvento, ...
            [], ...
            'omitnan');


    energiaMediaRiepilogo(e) = ...
        mean( ...
            energiaEvento_Wh, ...
            'omitnan');


    energiaMinimaRiepilogo(e) = ...
        min( ...
            energiaEvento_Wh, ...
            [], ...
            'omitnan');


    energiaMassimaRiepilogo(e) = ...
        max( ...
            energiaEvento_Wh, ...
            [], ...
            'omitnan');


    energiaTotaleRiepilogo(e) = ...
        sum( ...
            energiaEvento_Wh, ...
            'omitnan');

end


%% ============================================================
%% TABELLA RIASSUNTIVA
%% ============================================================

RiepilogoEventi = table( ...
    nomeRiepilogo, ...
    numeroEventiRiepilogo, ...
    durataMediaRiepilogo, ...
    durataMinimaRiepilogo, ...
    durataMassimaRiepilogo, ...
    potenzaMediaRiepilogo, ...
    potenzaMassimaRiepilogo, ...
    energiaMediaRiepilogo, ...
    energiaMinimaRiepilogo, ...
    energiaMassimaRiepilogo, ...
    energiaTotaleRiepilogo);


RiepilogoEventi.Properties.VariableNames = { ...
    'Dispositivo', ...
    'NumeroEventi', ...
    'DurataMedia', ...
    'DurataMinima', ...
    'DurataMassima', ...
    'PotenzaMedia_W', ...
    'PotenzaMassima_W', ...
    'EnergiaMedia_Wh', ...
    'EnergiaMinima_Wh', ...
    'EnergiaMassima_Wh', ...
    'EnergiaTotale_Wh'};


disp(" ")
disp("==============================================")
disp("CARATTERIZZAZIONE DEGLI EVENTI")
disp("==============================================")

disp(RiepilogoEventi)


%% ============================================================
%% FASE 7 - IDENTIFICAZIONE AUTOMATICA DELLE MODALITA OPERATIVE
%% ============================================================

% Il clustering viene applicato utilizzando:
%
% 1) durata dell'evento
% 2) potenza media
% 3) energia
%
% La metodologia è la stessa utilizzata
% per l'Utente 1.


%% Dispositivi analizzati

dispositiviModalita = { ...
    'asciugatrice', ...
    'macchinacaffe', ...
    'microonde'};


%% Inizializzazione

ModalitaOperative = struct();


% Numero massimo di gruppi

numeroMassimoModalita = 5;


% Soglia minima di silhouette
% per accettare più modalità

sogliaSilhouette = 0.25;


% Riproducibilità

rng(1);


%% ============================================================
%% ANALISI DEI SINGOLI DISPOSITIVI
%% ============================================================

for e = 1:length(dispositiviModalita)

    nome = ...
        dispositiviModalita{e};


    %% Estrazione delle caratteristiche

    T = ...
        CaratteristicheEventi.(nome);


    durataMinuti = ...
        minutes(T.Durata);


    potenzaMedia = ...
        T.PotenzaMedia_W;


    energiaEvento = ...
        T.Energia_Wh;


    %% Matrice delle caratteristiche

    caratteristiche = [ ...
        durataMinuti, ...
        potenzaMedia, ...
        energiaEvento];


    %% Individuazione degli eventi validi

    eventiValidi = ...
        all( ...
            isfinite(caratteristiche), ...
            2) & ...
        durataMinuti > 0 & ...
        potenzaMedia >= 0 & ...
        energiaEvento >= 0;


    X = ...
        caratteristiche( ...
            eventiValidi, :);


    numeroEventiValidi = ...
        size(X, 1);


    %% Controllo del numero di eventi

    if numeroEventiValidi < 3

        warning( ...
            'Eventi insufficienti per analizzare %s.', ...
            nome)

        continue

    end


    %% ========================================================
    %% NORMALIZZAZIONE ROBUSTA
    %% ========================================================

    centro = ...
        median(X, 1);


    primoQuartile = ...
        prctile( ...
            X, ...
            25, ...
            1);


    terzoQuartile = ...
        prctile( ...
            X, ...
            75, ...
            1);


    scala = ...
        terzoQuartile - ...
        primoQuartile;


    %% Gestione delle caratteristiche costanti

    scalaNulla = ...
        scala == 0;


    scala(scalaNulla) = ...
        std( ...
            X(:,scalaNulla), ...
            0, ...
            1);


    scala(scala == 0) = 1;


    %% Normalizzazione

    Xnormalizzata = ...
        (X - centro) ./ ...
        scala;


    %% ========================================================
    %% SCELTA AUTOMATICA DEL NUMERO DI MODALITA
    %% ========================================================

    massimoK = ...
        min( ...
            numeroMassimoModalita, ...
            numeroEventiValidi - 1);


    valoriK = ...
        2:massimoK;


    silhouetteMedia = ...
        NaN( ...
            length(valoriK), ...
            1);


    %% Test dei differenti valori di k

    for indiceK = 1:length(valoriK)

        k = ...
            valoriK(indiceK);


        gruppiTemporanei = ...
            kmeans( ...
                Xnormalizzata, ...
                k, ...
                'Replicates', ...
                20, ...
                'MaxIter', ...
                1000, ...
                'Display', ...
                'off');


        valoriSilhouette = ...
            silhouette( ...
                Xnormalizzata, ...
                gruppiTemporanei);


        silhouetteMedia(indiceK) = ...
            mean( ...
                valoriSilhouette);

    end


    %% Visualizzazione dei risultati

    fprintf( ...
        '\n%s\n', ...
        upper(nome));


    fprintf( ...
        'Eventi validi per il clustering: %d\n', ...
        numeroEventiValidi);


    for indiceK = 1:length(valoriK)

        fprintf( ...
            'k = %d --> silhouette media = %.4f\n', ...
            valoriK(indiceK), ...
            silhouetteMedia(indiceK));

    end


    %% Individuazione della soluzione migliore

    [silhouetteMigliore, indiceMigliore] = ...
        max( ...
            silhouetteMedia);


    numeroModalita = ...
        valoriK(indiceMigliore);


    %% ========================================================
    %% CONTROLLO DELLA QUALITA DEL CLUSTERING
    %% ========================================================

    if silhouetteMigliore < ...
            sogliaSilhouette

        % Nessuna suddivisione sufficientemente
        % ben definita:
        % considero una sola modalità

        gruppo = ...
            ones( ...
                numeroEventiValidi, ...
                1);


        numeroModalita = 1;

    else

        % Clustering definitivo

        gruppo = ...
            kmeans( ...
                Xnormalizzata, ...
                numeroModalita, ...
                'Replicates', ...
                50, ...
                'MaxIter', ...
                1000, ...
                'Display', ...
                'off');

    end


    %% ========================================================
    %% ORDINAMENTO DELLE MODALITA
    %% ========================================================

    % Le modalità vengono ordinate
    % dalla durata mediana più breve
    % alla durata mediana più lunga.

    durataMedianaGruppo = ...
        zeros( ...
            numeroModalita, ...
            1);


    for m = 1:numeroModalita

        durataMedianaGruppo(m) = ...
            median( ...
                X( ...
                    gruppo == m, ...
                    1));

    end


    [~, ordineGruppi] = ...
        sort( ...
            durataMedianaGruppo);


    gruppoOrdinato = ...
        zeros( ...
            size(gruppo));


    for nuovaEtichetta = 1:numeroModalita

        vecchiaEtichetta = ...
            ordineGruppi( ...
                nuovaEtichetta);


        gruppoOrdinato( ...
            gruppo == vecchiaEtichetta) = ...
            nuovaEtichetta;

    end


    gruppo = ...
        gruppoOrdinato;


    %% ========================================================
    %% ASSEGNAZIONE DELLE MODALITA AGLI EVENTI
    %% ========================================================

    modalitaEvento = ...
        repmat( ...
            "Non valida", ...
            height(T), ...
            1);


    modalitaValide = ...
        "Modalità " + ...
        string(gruppo);


    modalitaEvento( ...
        eventiValidi) = ...
        modalitaValide;


    tabellaEventiModalita = ...
        T;


    tabellaEventiModalita.ModalitaStimata = ...
        modalitaEvento;


    %% ========================================================
    %% RIEPILOGO DELLE MODALITA
    %% ========================================================

    nomeModalita = ...
        strings( ...
            numeroModalita, ...
            1);


    numeroEventiModalita = ...
        zeros( ...
            numeroModalita, ...
            1);


    percentualeEventi = ...
        zeros( ...
            numeroModalita, ...
            1);


    durataMediana = ...
        zeros( ...
            numeroModalita, ...
            1);


    potenzaMediaModalita = ...
        zeros( ...
            numeroModalita, ...
            1);


    energiaMediaModalita = ...
        zeros( ...
            numeroModalita, ...
            1);


    for m = 1:numeroModalita

        righeModalita = ...
            gruppo == m;


        nomeModalita(m) = ...
            "Modalità " + ...
            string(m);


        numeroEventiModalita(m) = ...
            sum( ...
                righeModalita);


        percentualeEventi(m) = ...
            100 * ...
            numeroEventiModalita(m) / ...
            numeroEventiValidi;


        durataMediana(m) = ...
            median( ...
                X( ...
                    righeModalita, ...
                    1));


        potenzaMediaModalita(m) = ...
            mean( ...
                X( ...
                    righeModalita, ...
                    2));


        energiaMediaModalita(m) = ...
            mean( ...
                X( ...
                    righeModalita, ...
                    3));

    end


    %% Tabella riassuntiva

    riepilogoModalita = ...
        table( ...
            nomeModalita, ...
            numeroEventiModalita, ...
            percentualeEventi, ...
            durataMediana, ...
            potenzaMediaModalita, ...
            energiaMediaModalita);


    riepilogoModalita.Properties.VariableNames = { ...
        'Modalita', ...
        'NumeroEventi', ...
        'PercentualeEventi', ...
        'DurataMediana_min', ...
        'PotenzaMedia_W', ...
        'EnergiaMedia_Wh'};


    %% ========================================================
    %% SALVATAGGIO
    %% ========================================================

    ModalitaOperative.(nome).Eventi = ...
        tabellaEventiModalita;


    ModalitaOperative.(nome).Riepilogo = ...
        riepilogoModalita;


    ModalitaOperative.(nome).NumeroModalita = ...
        numeroModalita;


    ModalitaOperative.(nome).SilhouetteMedia = ...
        silhouetteMigliore;


    %% Visualizzazione del riepilogo

    fprintf( ...
        '\nNumero di modalità selezionato: %d\n', ...
        numeroModalita);


    fprintf( ...
        'Silhouette migliore: %.4f\n', ...
        silhouetteMigliore);


    disp( ...
        riepilogoModalita)


    %% ========================================================
    %% RAPPRESENTAZIONE GRAFICA
    %% ========================================================

    figure( ...
        'Name', ...
        'Modalità operative - ' + string(nome), ...
        'NumberTitle', ...
        'off')


    hold on


    for g = 1:numeroModalita

        idxGruppo = ...
            gruppo == g;


        scatter( ...
            X(idxGruppo,1), ...
            X(idxGruppo,3), ...
            36, ...
            'filled', ...
            'DisplayName', ...
            ['Modalità ', ...
             num2str(g)])

    end


    % Mantengo la stessa rappresentazione
    % utilizzata per l'Utente 1

    set( ...
        gca, ...
        'XScale', ...
        'log', ...
        'YScale', ...
        'log')


    grid on


    xlabel( ...
        'Durata [min]')


    ylabel( ...
        'Energia [Wh]')


    title( ...
        'Modalità operative stimate - ' + ...
        string(nome) + ...
        ' - gruppi: ' + ...
        string(numeroModalita))


    legend( ...
        'show', ...
        'Location', ...
        'best')


    hold off

end


%% ============================================================
%% FINE FASI 6-7
%% ============================================================

disp(" ")
disp("==============================================")
disp("FINE CARATTERIZZAZIONE E CLUSTERING - UTENTE 2")
disp("==============================================")

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

    % Individuo la percentuale massima osservata
    percentualeMassima = max(Riepilogo.PercentualeEventi);

    % Individuo tutte le modalità che presentano
    % la percentuale massima di eventi
    indiciPrevalenti = find( ...
        abs(Riepilogo.PercentualeEventi - percentualeMassima) < 1e-6);

    % Verifico se esiste una sola modalità prevalente
    % oppure se è presente un pareggio
    presenzaPareggio = length(indiciPrevalenti) > 1;

    if ~presenzaPareggio

        % Recupero l'indice della modalità prevalente
        indicePrevalente = indiciPrevalenti(1);

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

    else

        % In presenza di un pareggio non viene
        % identificata arbitrariamente una modalità prevalente
        modalitaPrevalente = "Nessuna";

        % Non essendoci una singola modalità prevalente,
        % i parametri rappresentativi non vengono assegnati
        numeroEventiPrevalente = NaN;
        durataTipica = NaN;
        potenzaMediaTipica = NaN;
        energiaMediaTipica = NaN;

    end


    %% Interpretazione automatica del profilo

    % Inizializzo il commento conclusivo
    commentoProfilo = '';

    % Caso di pareggio tra due o più modalità
    if presenzaPareggio

        commentoProfilo = ...
            ['L''utilizzo è distribuito in modo equivalente tra ', ...
             'più modalità operative, senza una modalità prevalente.'];

    % Caso con una sola modalità
    elseif numeroModalita == 1

        commentoProfilo = ...
            ['È stata individuata una sola modalità operativa ', ...
             'prevalente. Il comportamento risulta fortemente ripetitivo.'];

    % Caso con modalità quasi esclusiva
    elseif percentualeMassima >= 80

        commentoProfilo = ...
            ['L''utente utilizza quasi esclusivamente una sola ', ...
             'modalità operativa.'];

    % Caso con modalità prevalente
    elseif percentualeMassima >= 60

        commentoProfilo = ...
            ['È presente una modalità prevalente, ma vengono ', ...
             'utilizzate anche modalità alternative.'];

    % Caso senza netta prevalenza
    elseif percentualeMassima >= 40

        commentoProfilo = ...
            ['L''utilizzo è distribuito tra più modalità operative ', ...
             'senza una netta prevalenza.'];

    % Caso molto variabile
    else

        commentoProfilo = ...
            ['L''utilizzo risulta distribuito tra diverse ', ...
             'modalità operative.'];

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
% le profilazioni finali
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
    'Profilazione finale degli elettrodomestici', ...
    'HorizontalAlignment', ...
    'center', ...
    'FontSize', ...
    15, ...
    'FontWeight', ...
    'bold', ...
    'EdgeColor', ...
    'none');

% Definisco il numero di profili
numeroProfili = length(nomiElettrodomestici);

% Definisco l'altezza di ogni tabella
altezzaTabella = 0.14;

% Calcolo le posizioni verticali
posizioniVerticali = linspace(0.78, 0.06, numeroProfili);

% Scorro le analisi finali
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
            'Profilo'}, ...
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