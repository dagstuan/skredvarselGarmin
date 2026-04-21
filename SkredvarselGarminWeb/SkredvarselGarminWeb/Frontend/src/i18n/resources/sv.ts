export const faqSv = {
  title: "Vanliga frågor",
  problemsHelpAlt: "Förklaring av lavinproblem",
  items: {
    installApp: {
      question: "Hur installerar jag appen?",
      step1Before: "Gå till ",
      step1LinkLabel: "Connect IQ Store",
      step1After:
        " och ladda ner appen till din klocka. Du kan också behöva installera appen \"Connect IQ Store\" på din mobiltelefon.",
      step2LinkLabel: "Köp ett abonnemang på appen",
      step3:
        "Starta appen på klockan. Då ska en kod visas som du behöver skriva in.",
      step4Before: "Gå till ",
      step4LinkLabel: "Konto",
      step4After: " och skriv in koden som visas på klockan.",
      step5: "Tack så mycket!",
    },
    detailSymbols: {
      question: "Vad betyder symbolerna i detaljvyn?",
      intro: "Rött markerar det område som är mest utsatt.",
      point1: "Väderstreck som är mest utsatta för lavinproblemet.",
      point2: "Var i fjället lavinproblemet finns.",
      point3: "Höjder över havet där lavinproblemet förekommer.",
      point4: "Prognostiserad fara för lavinproblemet.",
      note:
        "Obs! Det finns alltid lokala variationer, och de röda områdena visar de mest utsatta platserna. Det betyder att lavinproblemet också kan finnas i andra områden, men det förväntas vara mindre utbrett där.",
    },
    paymentMethods: {
      question: "Kan jag betala med något annat än Vipps?",
      answer:
        "Garmin erbjuder inte betalning för appar i sin egen \"Connect IQ Store\", så all betalning för appar till Garmin-klockor måste hanteras utanför butiken. Därför måste jag själv ordna betalningslösningen, och just nu har jag valt att endast erbjuda Vipps.",
    },
    compatibleWatches: {
      question: "Vilka klockor fungerar appen på?",
      introBefore:
        "Appen fungerar på de flesta nyare Garmin-klockor med färgskärm. En fullständig översikt finns i ",
      introLinkLabel: "Connect IQ Store",
      introAfter:
        ". Om din klocka har stöd för musik är sannolikheten större att appen fungerar, eftersom de klockorna har mer minne.",
      unsupportedHeading:
        "Klockor där appen inte fungerar på grund av begränsat minne:",
    },
    whyNotMyWatch: {
      question: "Varför fungerar den inte på min klocka?",
      answer:
        "Jag har försökt få appen att fungera på så många klockor som möjligt, och nya klockor läggs till efter hand. Om appen inte fungerar på din klocka beror det troligen på minnesbegränsningar i själva klockan. Garmin-klockor har mycket strikta krav på minnesanvändning för att bevara batteritiden.",
    },
    weirdLayout: {
      question: "Det ser konstigt ut på min skärm.",
      answer:
        "Vissa Garmin-klockor med mycket liten skärm har begränsat utrymme för att visa information. Jag arbetar fortfarande med att få appen att fungera perfekt på små skärmar. Jag har heller inte testat alla fysiska klockor, eftersom jag inte äger allihop. Skicka gärna en bild på hur det ser ut på din klocka så att jag kan förbättra layouten.",
    },
    sources: {
      question: "Var kommer varningarna ifrån?",
      beforeVarsom:
        "Varningarna hämtas från den norska lavinvarningstjänsten och ",
      varsomLinkLabel: "www.varsom.no",
      betweenLinks: " via deras öppna API som finns ",
      apiLinkLabel: "här",
      afterApi: ".",
    },
    updateFrequency: {
      question: "Hur ofta uppdateras varningarna?",
      answer:
        "Klockan hämtar varningarna en gång i timmen och lagrar dem på klockan. De hämtas också på nytt när du öppnar appen om de är gamla. Om varningarna är äldre än 24 timmar visas de inte längre.",
    },
    internetConnection: {
      question: "Hur kommunicerar klockan med internet?",
      answer:
        "Klockan är beroende av Bluetooth-anslutning till din mobiltelefon för att hämta varningar från internet, eftersom nästan inga Garmin-klockor har direkt internetåtkomst. Om din klocka har gamla varningar eller slutar visa dem kan det bero på att klockan har tappat kontakten med mobilen.",
    },
    beaconInterference: {
      question: "Kan klockan störa en lavinsändare?",
      paragraph1Before:
        "Precis som en mobiltelefon kan störa en lavinsändare finns det också en viss möjlighet att en smartklocka kan orsaka störningar. Därför rekommenderas det att stänga av kommunikationen med mobiltelefonen under turen. En ",
      researchLinkLabel: "forskningsartikel",
      paragraph1After:
        " från 2014 rekommenderade att bära klockan på motsatt hand från den hand du använder för lavinsändaren i sökläge.",
      paragraph2:
        "För att stänga av kommunikationen med mobilen under turen kan du på de flesta Garmin-klockor konfigurera ett \"Power mode\" under en aktivitet. Du kan välja ett energiläge för din topptursaktivitet som stänger av mobilkommunikationen. Läs klockans manual för att se hur du gör detta på just din modell.",
    },
    whyPaid: {
      question: "Varför är inte appen gratis?",
      answer:
        "För att få appen att fungera med Garmin behöver jag driva en liten webbtjänst som behandlar varningarna från Varsom och tar bort onödig information för visning på klockan. Appen kostar lite för att jag ska kunna hålla den tjänsten igång utan att förlora pengar.",
    },
    sourceCode: {
      question: "Kan jag se appens källkod?",
      beforeLink:
        "Ja. Hela appen, inklusive den här webbplatsen, finns öppet tillgänglig på ",
      linkLabel: "GitHub",
      afterLink: ".",
    },
    vippsLogin: {
      question: "Varför kan jag inte längre logga in med Vipps?",
      beforeLink:
        "Vipps har ändrat sina villkor, och \"Logga in med Vipps\" är nu en ",
      linkLabel: "betald produkt",
      afterLink:
        ". Jag tycker att priset Vipps har valt är orimligt högt, och därför har jag ersatt Vipps-inloggning med e-postinloggning. Om du har problem med att logga in får du gärna höra av dig.",
    },
    bugReport: {
      question: "Jag hittade ett fel!",
      answer: "Hör av dig så ska jag försöka fixa det.",
    },
    contact: {
      question: "Jag undrar fortfarande över något. Hur kan jag kontakta dig?",
      beforeInstagram: "Kontakta mig på ",
      instagramLabel: "Instagram",
      betweenLinks: " eller via ",
      emailLabel: "e-post",
      afterEmail: " om du fortfarande undrar över något.",
    },
  },
} as const;

export const privacySv = {
  title: "Integritetspolicy",
  intro:
    "När du använder skredvarsel.app ger du oss tillgång till information om dig. Här kan du läsa vilka uppgifter vi samlar in, hur vi gör det och vad vi använder dem till.",
  about: {
    title: "Om skredvarsel.app",
    paragraph1:
      "Skredvarsel.app ägs av Dag Stuan och säljer abonnemang på en app som visar lavinvarningar på Garmin-klockor. I enlighet med norsk personuppgiftslagstiftning och EU:s allmänna dataskyddsförordning är skredvarsel.app personuppgiftsansvarig för de personuppgifter som behandlas av företaget.",
    contactIntro: "Vi har följande kontaktuppgifter:",
    addressLabel: "Adress",
    addressValue: "Marie Wexelsens veg 6, 7045 Trondheim",
    orgNumberLabel: "Organisationsnummer",
    orgNumberValue: "926 049 690",
  },
  personalData: {
    title: "Vad är personuppgifter?",
    paragraph:
      "Personuppgifter är information som kan kopplas till en person, till exempel namn, bostadsort, telefonnummer, e-postadress eller IP-adress. Information om hur du använder vår tjänst, till exempel vilka produkter du har tittat på eller köpt, räknas också som personuppgifter.",
  },
  collectedInfo: {
    title: "Vilka uppgifter samlar vi in?",
    paragraph:
      "När du skapar en användare för att köpa ett abonnemang anger du ditt telefonnummer i Vipps. Vi får information från Vipps och lagrar namn, telefonnummer och e-postadress. Detta lagras så att du senare kan hämta status för ditt abonnemang och säga upp det vid behov.",
  },
  cookies: {
    title: "Kakor",
    paragraph1:
      "Kakor används på skredvarsel.app. En kaka är en liten textfil som skickas till webbläsaren och placeras på din dator, surfplatta eller mobil när du besöker en webbplats. Den kan användas för att komma ihåg information om dina besök och till exempel spåra dina inställningar, såsom språkval.",
    paragraph2:
      "Vi använder kakor för att förbättra och förenkla ditt besök. Vi använder inte kakor för att lagra personlig information om du inte har gett oss tillstånd till det. Vi använder heller inte kakor för att lämna ut personuppgifter till tredje part.",
    paragraph3:
      "De flesta webbläsare accepterar automatiskt kakor. Samtycke till användning av kakor anses vara givet om din webbläsare är inställd på att acceptera dem. Detta gäller även om godkännandet är förinställt i webbläsaren. Du kan dock ta bort och kontrollera kakor via din webbläsare. Du kan till exempel ta bort alla kakor eller välja att få en avisering varje gång en ny kaka skickas till din enhet. Observera att om du begränsar kakor kan det påverka webbplatsens funktionalitet. Många interaktiva funktioner på webbplatsen är beroende av kakor.",
  },
  cookieTypes: {
    title: "Vilka kakor används?",
    intro: "Skredvarsel.app använder följande kakor:",
    paymentTitle: "Betalning",
    paymentProvider: "Vipps återkommande betalningar",
    vippsPolicyPrefix:
      "Vipps samlar in information enligt sina egna riktlinjer, som du kan läsa i ",
    vippsPolicyLabel: "Vipps integritetspolicy",
  },
  deletionRequest: {
    title: "Begäran om radering av data",
    paragraphBefore:
      "I enlighet med dataskyddslagstiftningen kan du be oss att radera dina personuppgifter. Detta kan göras genom att kontakta ",
    paragraphAfter: ".",
  },
} as const;

export const salesConditionsSv = {
  title: "Köpvillkor",
  intro:
    "Dessa köpvillkor gäller för försäljning av varor och tjänster till konsumenter av Lavinvarning för Garmin. Med konsument avses en fysisk person som inte huvudsakligen handlar som ett led i näringsverksamhet.",
  seller: {
    title: "Säljare",
    paragraph:
      "Dag Stuan\nOrganisationsnummer: 926 049 690\nAdress: Marie Wexelsens veg 6, 7045 Trondheim\nNedan även kallad «vi», «oss» eller «skredvarsel.app».",
  },
  buyer: {
    title: "Köpare",
    paragraph:
      "Köparen är den person som anges som köpare i beställningen, nedan även kallad «du» eller «din».",
  },
  payment: {
    title: "Betalning",
    paragraph:
      "Vipps används som betalningsmetod. Prenumerationsbetalningar debiteras automatiskt i början av den månatliga eller årliga perioden, beroende på vilken betalningsperiod du väljer. Betalningen förnyas automatiskt tills ditt abonnemang sägs upp eller avslutas. Du kan avsluta ditt abonnemang när som helst enligt beskrivningen nedan.",
  },
  fees: {
    title: "Avgifter",
    paragraph:
      "För att få tillgång till applikationen på klockan måste du betala en abonnemangsavgift. Avgiften kan betalas månadsvis eller årsvis. Abonnemangsavgiften betalas i förskott. Om du byter från månadsabonnemang till årsabonnemang börjar årspriset gälla från nästa faktureringsdatum. Du godkänner att betala abonnemangsavgiften kopplad till ditt konto på skredvarsel.app, antingen som engångsbetalning eller som återkommande abonnemang. Skredvarsel.app förbehåller sig rätten att höja abonnemangsavgifterna, eventuella relaterade skatter eller att införa nya avgifter när som helst med rimligt förhandsmeddelande.",
  },
  renewal: {
    title: "Automatisk förnyelse av abonnemang",
    paragraph:
      "Abonnemangsavgifter debiteras automatiskt i början av den månatliga eller årliga perioden, beroende på vad som gäller. Dessa avgifter förnyas automatiskt tills ditt abonnemang sägs upp eller avslutas. Din abonnemangsavgift kommer att vara densamma som den ursprungliga avgiften om du inte får besked om något annat i förväg. Du kan avsluta ditt abonnemang när som helst enligt beskrivningen nedan.",
  },
  delivery: {
    title: "Leverans",
    paragraph: "Efter godkänd betalning får du tillgång till data på din klocka.",
  },
  cancellation: {
    title: "Uppsägning av abonnemang",
    paragraph:
      "Du kan avsluta ditt abonnemang genom att gå till sidan «Konto» och välja «Avsluta». Uppsägningen träder i kraft vid slutet av den aktuella faktureringsperioden. Du kan förnya abonnemanget när som helst utan att öppna ett nytt konto, även om abonnemangsavgifterna kan ha höjts. Du kan radera ditt konto när som helst.",
  },
  withdrawal: {
    title: "Ångerrätt",
    paragraph:
      "Alla abonnemang har 14 dagars ångerrätt. Observera att ångerrätten endast gäller nya köp och inte automatisk förnyelse av ditt abonnemang. För att ångra ditt köp, skicka ett e-postmeddelande till d.stuan@gmail.com. Du får gärna skriva varför du vill ångra köpet, eftersom detta hjälper oss att förbättra tjänsten i framtiden. Om du använder din ångerrätt får du tillbaka värdet av tjänsten vid köptillfället. Beloppet återbetalas direkt till det Vipps-konto som användes vid köpet.",
  },
  disputeResolution: {
    title: "Tvistlösning",
    paragraph:
      "Klagomål ska riktas till säljaren inom skälig tid. Parterna ska försöka lösa eventuella tvister i godo. Om detta inte lyckas kan köparen kontakta Konsumentrådet i Norge för medling. Konsumentrådet nås på telefon 23 400 500 eller via www.forbrukerradet.no.",
  },
  defects: {
    title: "Fel i varan - köparens rättigheter och reklamationsfrist",
    paragraph:
      "Om det finns ett fel i varan måste köparen inom skälig tid efter att felet upptäckts eller borde ha upptäckts meddela säljaren att felet åberopas. En reklamation anses alltid ha skett i tid om den görs inom två månader från att felet upptäcktes eller borde ha upptäckts. Reklamation kan göras senast två år efter att köparen tog emot varan. För att reklamera ditt köp, skicka ett e-postmeddelande till d.stuan@gmail.com med en beskrivning av felet i varan.",
  },
} as const;

export const seoSv = {
  home: {
    title: "Lavinvarning för Garmin",
    description:
      "Lavinvarningar från Varsom och Lavinprognoser direkt på din Garmin-klocka.",
  },
  account: {
    title: "Konto | Lavinvarning för Garmin",
    description:
      "Hantera ditt abonnemang, dina klockor och din personliga information.",
  },
  subscribe: {
    title: "Köp abonnemang | Lavinvarning för Garmin",
    description:
      "Köp ett abonnemang med Vipps eller Stripe för att få lavinvarningar på din Garmin-klocka.",
  },
  addWatch: {
    title: "Lägg till klocka | Lavinvarning för Garmin",
    description:
      "Koppla din Garmin-klocka till abonnemanget och lägg till den på ditt konto.",
  },
  login: {
    title: "Logga in | Lavinvarning för Garmin",
    description:
      "Logga in för att hantera ditt abonnemang och dina Garmin-klockor.",
  },
  faq: {
    title: "Vanliga frågor | Lavinvarning för Garmin",
    description:
      "Svar på vanliga frågor om installation, kompatibla klockor, betalning och hur appen fungerar.",
  },
  salesConditions: {
    title: "Köpvillkor | Lavinvarning för Garmin",
    description:
      "Läs köpvillkoren för abonnemang på Lavinvarning för Garmin.",
  },
  privacy: {
    title: "Integritetspolicy | Lavinvarning för Garmin",
    description:
      "Läs hur skredvarsel.app behandlar personuppgifter och använder kakor.",
  },
  admin: {
    title: "Admin | Lavinvarning för Garmin",
    description:
      "Administrationssida för användar- och abonnemangsstatistik i Lavinvarning för Garmin.",
  },
} as const;