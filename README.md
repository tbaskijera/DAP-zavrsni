# Seminarski rad i projektni zadatak, DAP, 2022./23

**Autori:** Toni Baskijera i Martina Sirotić

**Datum:** 10. siječnja 2023.

**Predmet:** Dubinska analiza podataka

**Akademska godina:** 2022./2023.

## Opis odabranog skupa podataka

Skup podataka koji će se koristiti u ovom radu naziva se [FIFA 21 complete player dataset](https://www.kaggle.com/datasets/stefanoleone992/fifa-21-complete-player-dataset), a sadrži sve nogometaše koji se nalaze u videoigri FIFA 21. Sastoji se od 18 944 unosa sa 106 različith atributa.

## Odabir metoda

Za projektni zadatak, odabrali smo sljedeće metode:

- Pretprocesiranje podataka - **Agregacija**
- Klasifikacija - **Umjetne neuronske mreže**
- Ansambli - **Slučajne šume**
- Asocijacijska analiza - **Vizualizacija asocijacijskih pravila**
- Grupiranje - **Grupiranje K - sredina**

*Zašto smo odabrali ove metode?*...

### Agregacija

Agregacija u pretprocesiranju podataka odnosi se na proces sažimanja podataka iz više izvora u jedan, kompaktniji prikaz kojim je lakše upravljati. To može uključivati operacije kao što su grupiranje, sažimanje i združivanje podatkovnih točaka u sumarnu statistiku, kao što je srednja vrijednost, medijan ili način. Agregacija se obično koristi za smanjenje količine podataka za analizu, vizualizaciju i izvješćivanje ili za otkrivanje obrazaca ili odnosa u podacima koje bi bilo teško vidjeti u neobrađenim podacima.

### Umjetne neuronske mreže

Umjetna neuronska mreža je model strojnog učenja inspiriran strukturom i funkcijom ljudskog mozga, no u praksi nemaju međusobnih sličnosti. Koristi se za izvođenje zadataka nadziranog strojnog učenja, kao što je binarna ili višerazredna klasifikacija. U klasifikaciji, umjetna neuronska mreža uzima ulazne značajke, obrađuje ih kroz niz međusobno povezanih čvorova (neurona) organiziranih u slojeve i daje predviđenu oznaku klase. Neuroni u mreži uče prepoznati obrasce u ulaznim podacima kroz prilagodbu svojih težina i pristranosti tijekom treninga, koristeći algoritme kao što je **backpropagation**. Cilj obuke je minimizirati pogrešku između predviđenih i stvarnih oznaka klase, što dovodi do poboljšane točnosti klasifikacije.

### Slučajne šume

Slučajna šuma je algoritam strojnog učenja koji se koristi za zadatke klasifikacije i regresije. Kombinira više stabala odlučivanja kako bi formiralo šumu stabala, gdje svako stablo daje predviđanje, a konačno predviđanje se daje prosjekom ili glasovanjem za sva stabla.

U klasifikaciji, svako stablo u šumi izgrađeno je pomoću nasumičnog podskupa značajki i uzoraka iz podataka o obučavanju i daje predviđanja na temelju skupa pravila odlučivanja naučenih iz podataka. Konačna predviđanja za novi uzorak napravljena su zbrajanjem predviđanja iz svih stabala. Kombiniranjem više stabala, algoritam slučajne šume može ublažiti pretreniranje modela i smanjiti varijance u usporedbi s jednim stablom odlučivanja, što dovodi do poboljšane točnosti i robusnosti.

### Vizualizacija asocijacijskih pravila

Vizualizacija pravila pridruživanja proces je grafičkog predstavljanja odnosa i ovisnosti između stavki u skupu podataka. Često se koristi u analizi kako bi se otkrili skriveni uzorci i odnosi između entiteta. Asocijacijska pravila mogu se vizualizirati korištenjem različitih vrsta grafikona kao što su stupčasti dijagrami, histogrami, raspršeni dijagrami, toplinske karte i slično.

### Grupiranje K - sredina

Grupiranje K - sredina je nenadzirani algoritam strojnog učenja koji se koristi za particioniranje skupa podatkovnih točaka u K sredina, gdje je K korisnički definiran broj. Algoritam funkcionira tako da svaku podatkovnu točku dodjeljuje najbližem centru klastera, a zatim ponovno izračunava centre klastera na temelju srednje vrijednosti dodijeljenih podatkovnih točaka. Ovaj se proces ponavlja sve dok se središta klastera više ne mijenjaju ili dok se ne ispuni kriterij zaustavljanja.

Cilj grupiranja K-srednjih vrijednosti je minimizirati zbroj kvadrata udaljenosti između podatkovnih točaka i njihovih dodijeljenih centara klastera. To rezultira kompaktnim i dobro odvojenim klasterima koji se mogu koristiti za daljnju analizu ili kompresiju podataka.  Grupiranje K - sredina naširoko se koristi za različite zadatke, uključujući segmentaciju slika, segmentaciju kupaca i istraživanje tržišta.

## Izvođenje eksperimenata

## Prikaz i interpretacija rezultata

### Agregacija

Tijekom predprocesiranja u procesu agregacije smo dani skup podataka grupirali odnosno saželi sa operacijom srednje vrijednosti ```mean``` po ulozi igrača. Na slici je vidljivo da varijbala ```role``` ime 5 vrijednosti: ```attacker```, ```defender```, ```goalkeeper```, ```midfielder``` i ```unknown```, a vrijednosti ostalih varijabli su prosjek svih igrača koji spadaju u pojedinu ulogu na terenu.

![agregacija](images/agregacija.jpg)

### Grupiranje k-sredina

Rezultat grupiranje k-sredina je dani skup grupiran u 3 klastera. U prvom klasteru se nalaze obrambeni igrači, u drugom klasteru golmani, a u terćem klasteru napadači i veznjaci. Iako bi bilo za očekivati da su napadači i vezanjaci odvojeni u različite klastere, skup podataka na kojem smo provodili eksperiment nije dovoljno precizan. Naime, postoje brojni primjeri gdje je uloga/pozcija nogometaša netočna (npr. L.Messi igra na poziciji napadača, ali je u skupu podataka navedeno da je vezni igrač ili S. Agüero igra na poziciji napadača, a u skupu podataka nema navedenu poziciju) te je samim time klasteriranje neprecizno i otežano. Zbog čestih grešaka u skupu podataka za pozicije igrača, naapadače i veznjake smo odlučili smjestiti u isti klaster.

#### Vizualizacija 1

Na slici je prikazano grupiranje na 3 klastera po varijblama ```defending``` i ```shooting```. Iz vizualizacije se može iščitati da golmani (klaster 2 - zeleno) ima vrlo loše gotovo nikakve vještine u tijekom pucanja prema golu ili u obrani. Također može se vidjeti da obrambeni igrači imaju vještine tijekom obrane bolje izražene od vještina pucanja prema golu.

![kmeans1](images/k_means_shooting_defending.png)

#### Vizualizacija 2

Druga vizualizacija je interaktivna te se prelaskom miša preko točkice mogu vidjeti kojem klasteru igrač pripada, ```skill_dribbling``` i ```power_strangth``` za svakog igrača odnosno točkicu. Iz vizualizacije je vidljivo da golmani (zeleno) imaju jako loše vještine driblinga. Kod napadača i veznjaka su izražene vještine drublinga, ```power_strangth``` im jako varira. U odnsou na golmane, napadače i veznjake, obrambenim igračima su prosječne, ali im je ```power_strangth``` bolji od ostalih igrača.

![kmeans2](images/interaktivni_prikaz2.jpeg)

## Izvješće

### Toni

Moji zadaci na projektu bili su metoda agregacije iz skupa metoda predprocesiranja, metoda umjetne neuronske mreže iz skupa kmetoda klasifikacije, te metoda nasumičnih šuma iz skupa metoda ansambli. Unatoč tome, kolegica i ja smo aktivno međusobno surađivali na svim zadacima, te su rješenja zajednička. Opseg posla smo dobro rasporedili te smo oboje odradili podjednak dio projektnog zadatka.

### Martina

Moji zadaci na projektu bili su metoda vizualizacije iz skupa metoda asocijacijskih pravila i metoda grupiranja K - sredina iz skupa metoda grupiranja. Unatoč tome, kolega i ja smo aktivno međusobno surađivali na svim zadacima, te su rješenja zajednička. Opseg posla smo dobro rasporedili te smo oboje odradili podjednak dio projektnog zadatka.
