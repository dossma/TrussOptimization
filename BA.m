clear

% --------------------------------------------------------------------------
% Eingangsmatrizen, Konstruktion des Fachwerks
% --------------------------------------------------------------------------

% Äussere Kraft
F=100;

% Knotenkoordinaten, Koordinatensystem in Knoten 1
P1=[00,00];
P2=[10,00];
P3=[05,8.66];

% Knotenmatrix;
Knoten=[P1;P2;P3]';

% Knotenanfang und -ende der Stäbe
S1=[02,03];
S2=[01,03];
S3=[01,02];

% Stabmatrix
Verbindung=[S1;S2;S3]';

% Lagermatrix, Dimension entspricht Knotenmatrix
Lager=zeros(size(Knoten));
Lager(:,1)=[1 1]';
Lager(:,2)=[0 1]';

% Lastmatrix, Dimension enstpricht Knotenmatrix
Lasten=zeros(size(Knoten));
Lasten(2,3)=-F;

% Prüfen auf notwendige Bedingung für "statisch bestimmt" (Lagerreaktionen+Stäbe=2*Knoten)
if (sum(sum(Lager.^2))+size(Verbindung,2)) ~= 2*(size(Knoten,2))
    error ('Das Tragwerk ist nicht statisch bestimmt, überprüfen Sie Ihre Eingaben')
end

% --------------------------------------------------------------------------
% Geometriebestimmung
% --------------------------------------------------------------------------

% Nullvektor und Nullmatrix; Dimension entsprechend der Stäbe, also von "Verbindung"
Stablaengen=zeros(1,size(Verbindung,2));
Stabkoeffizienten=zeros(size(Verbindung));

%Generieren der Stablängen und der Stabkoeffizienten
for j=1:size(Verbindung,2)
    t=Verbindung(:,j);
    Stablaengen(j)=norm(Knoten(:,t(2))-Knoten(:,t(1)));
    Stabkoeffizienten(:,j)=(Knoten(:,t(2))-Knoten(:,t(1)))/Stablaengen(j);
end

% --------------------------------------------------------------------------
% Erstellen der Koeffizientenmatrix
% --------------------------------------------------------------------------

% Initialisieren der Koeffizientenmatrix (Zeilen: Doppelte Knotenzahl, Spalten: Stäbe,Lager)
Koeffmatrix=zeros(size(Verbindung,2)+sum(sum(Lager.^2)));

% Indexvektor
u=1:size(Knoten,1):size(Koeffmatrix,1)-1;

% Assemblierung der Stabkoeffizienten in die Koeffizientenmatrix (d.h.Winkel werden eingetragen)
for j=1:size(Verbindung,2)
    s=Stabkoeffizienten(:,j);
    oben=Verbindung(1,j);
    unten=Verbindung(2,j);
    Koeffmatrix(u(oben):u(oben)+1,j)=+s;
    Koeffmatrix(u(unten):u(unten)+1,j)=-s;
end

% Assemblierung der Lagerkoeffizienten in die Koeffizientenmatrix
i=1;
for j=1:size(Koeffmatrix,2)
    if Lager(j)~=0
        Koeffmatrix(j,i+size(Verbindung,2))=Lager(j);
        i=i+1;
    end
end

% Prüfen auf hinreichende Bedingung für statische Bestimmtheit
if det(Koeffmatrix)==0
    error ('Koeffizientenmatrix nicht eindeutig lösbar. Tragwerk ist beweglich. Überprüfen Sie Ihre Eingaben.')
end

% --------------------------------------------------------------------------
% Lösen des Gleichungssystems
% --------------------------------------------------------------------------

% Lastenmatrix wird zu einem Vektor überführt und negativ (Ax+b=0 -> Ax=-b)
Lasten=-Lasten(:);

% Lösen des Gleichungssystems
Forces=linsolve(Koeffmatrix, Lasten);

% --------------------------------------------------------------------------
% Generieren des Fachwerkgewichts
% --------------------------------------------------------------------------

%Materialwerte (hier: S235)
S=1.5; % Sicherheit
sigma_zzul=235e6/S;
sigma_dzul=235e6/S;
E=210e9;
rho=7900;

% Anfangswerte der Stabprofilflächen
A_kzul=sqrt((abs(Forces(1:size(Verbindung,2)))'.*Stablaengen.^2*4*S/(pi*E)))';
A_dzul=abs(Forces(1:size(Verbindung,2)))/sigma_dzul;
A_zzul=abs(Forces(1:size(Verbindung,2)))/sigma_zzul;

% Initialisieren des Profilflächen-Vektors
A=zeros(size(Verbindung,2),1);

% Zuweisen der Profilflächen
for i=1:size(Verbindung,2)
    if Forces(i)<0
        if A_kzul(i) > A_dzul(i)
            A(i)=A_kzul(i);
        else
            A(i)=A_dzul(i);
        end
    else
        A(i)=A_zzul(i);
    end
end

% Qualitätsfunktion (Gewicht)
qe=Stablaengen*A*rho;
Anfangsgewicht=qe;

% --------------------------------------------------------------------------
% Gewichtsoptimierung mittels Evolutionsstrategie
% --------------------------------------------------------------------------

% Neue Knotenmatrix, Variablenzahl, Startschrittweite
Kn=Knoten;
v=1;
d=6;
Startschrittweite=d;

% Speichern von Daten des aktuellen Elters (vgl. Zeile 201)
Fn=Forces; An=A; Stablaengen_n=Stablaengen;

% Übergabe der Anfangswerte an die grafische Ausgabe (g=0)
subplot (2,1,1)
semilogy(0,Anfangsgewicht,'b.')
hold on
semilogy(0,Startschrittweite,'y.')

% Generationenschleife
for g=1:200
    
    Kn(2,3)=Knoten(2,3)+d*randn(size(Knoten(2,3)))/sqrt(v);
    
    % Stabkoeffizienten
    for j=1:size(Verbindung,2)
        t=Verbindung(:,j);
        Stablaengen(j)=norm(Kn(:,t(2))-Kn(:,t(1)));
        Stabkoeffizienten(:,j)=(Kn(:,t(2))-Kn(:,t(1)))/Stablaengen(j);
    end
    
    % Assemblierung
    for j=1:size(Verbindung,2)
        s=Stabkoeffizienten(:,j);
        oben=Verbindung(1,j);
        unten=Verbindung(2,j);
        Koeffmatrix(u(oben):u(oben)+1,j)=+s;
        Koeffmatrix(u(unten):u(unten)+1,j)=-s;
    end
    
    % Lösen des Gleichungssystems
    Forces=linsolve(Koeffmatrix, Lasten);
    
    % Stabprofilflächen
    A_kzul=sqrt((abs(Forces(1:size(Verbindung,2)))'.*Stablaengen.^2*4*S/(pi*E)))';
    A_dzul=abs(Forces(1:size(Verbindung,2)))/sigma_dzul;
    A_zzul=abs(Forces(1:size(Verbindung,2)))/sigma_zzul;
    
    for i=1:size(Verbindung,2)
        if Forces(i)<0
            if A_kzul(i) > A_dzul(i)
                A(i)=A_kzul(i);
            else
                A(i)=A_dzul(i);
            end
        else
            A(i)=A_zzul(i);
        end
    end
    
    % Qualitätsfunktion des 'Kindes'
    qn=Stablaengen*A*rho;
    
    % Vergleich der Qualitäten Elter/Kind
    if qn < qe
        qe=qn; Knoten=Kn; d=d*1.3;
        % Speichern von neuen Werten des Elters (vgl. Zeile 145)
        Fn=Forces; An=A; Stablaengen_n=Stablaengen;
    else
        d=d/(1.3^0.25);
    end
    
    % --------------------------------------------------------------------------
    % Grafische Ausgabe
    % --------------------------------------------------------------------------
    subplot (2,1,1)
    
    semilogy(g,qe,'b.')     % Plot Qualität (blau)                        
        hold on
    semilogy(g,d,'y.')       % Plot Schrittweite (gelb)                       
    
    x=[Kn(1,:) Kn(1,1)];
    y=[Kn(2,:) Kn(2,1)];

    subplot (2,1,2)
    plot(x,y,'LineWidth',10)
    
    drawnow;
    
end % Generationenschleife

% --------------------------------------------------------------------------
% Ausgabe der Gewichtsersparnis
% --------------------------------------------------------------------------

disp 'Gewichtsersparnis in %:'
(1-qe/Anfangsgewicht)*100

% © Jonas Doßmann