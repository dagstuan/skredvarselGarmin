export const faqNo = {
  title: "Ofte stilte spørsmål",
  problemsHelpAlt: "Forklaring av skredproblemer",
  items: {
    installApp: {
      question: "Hvordan installerer jeg appen?",
      step1Before: "Gå til ",
      step1LinkLabel: "Connect IQ Store",
      step1After:
        " og last ned appen til klokken din. Det kan hende du må installere \"Connect IQ Store\"-appen til mobiltelefonen din.",
      step2LinkLabel: "Kjøp et abonnement på appen",
      step3:
        "Start appen på klokka. Da bør det dukke opp en kode du skal skrive inn.",
      step4Before: "Gå til ",
      step4LinkLabel: "Min side",
      step4After: " og skriv inn koden som står på klokka.",
      step5: "Tusen takk!",
    },
    detailSymbols: {
      question: "Hva betyr symbolene i detaljvisningen?",
      intro: "Rødt markerer området som er mest utsatt.",
      point1: "Himmelretninger som er mest utsatt for skredproblemet.",
      point2: "Hvor i fjellet skredproblemet er.",
      point3: "Høyder over havet hvor skredproblemet finnes.",
      point4: "Varslet faregrad for skredproblemet.",
      note:
        "NB! Det vil alltid være lokale variasjoner, og de røde områdene angir mest utsatte steder. Det vil si at skredproblemet også kan være tilstede i andre områder, men det er forventa at det er i mindre omfang her.",
    },
    paymentMethods: {
      question: "Kan jeg betale med noe annet enn Vipps?",
      answer:
        "Garmin tilbyr ikke betaling av apper i sin egen \"Connect IQ Store\", så all betaling for apper til Garmin-klokker må tas utenfor. Derfor må jeg selv lage betalingsløsning, og har enn så lenge valgt å kun tilby Vipps som betalingsløsning.",
    },
    compatibleWatches: {
      question: "Hvilke klokker virker appen på?",
      introBefore:
        "Appen virker på de fleste nyere Garmin-klokker som har fargeskjerm. En fullstendig oversikt kan sees på ",
      introLinkLabel: "Connect IQ Store",
      introAfter:
        ". Hvis du har en klokke med støtte for musikk er det større sannsynlighet for at appen virker, siden de klokkene har mer minne.",
      unsupportedHeading:
        "Klokker hvor appen ikke virker på grunn av manglende minne:",
    },
    whyNotMyWatch: {
      question: "Hvorfor virker den ikke på [klokken min]?",
      answer:
        "Jeg har forsøkt å få appen til å fungere på så mange klokker som mulig, og nye klokker legges til etterhvert. Hvis appen ikke fungerer på klokken din er det mest sannsynlig på grunn av minnebegrensninger i selve klokken. Garmin-klokker har veldig strenge krav til minnebruk for å opprettholde batteritiden på klokka.",
    },
    weirdLayout: {
      question: "Ting ser rart ut på skjermen min.",
      answer:
        "Noen Garmin-klokker med veldig liten skjerm har ikke så mye plass til å vise informasjon. Jeg er enda ikke helt ferdig med å få appen til å virke perfekt med små skjermer. Jeg har heller ikke testet med alle fysiske klokker, siden jeg ikke eier alle sammen. Send meg gjerne et bilde av hvordan det ser ut på klokken din så jeg kan forbedre visningen.",
    },
    sources: {
      question: "Hvor kommer varslene fra?",
      beforeVarsom: "Varslene hentes fra Snøskredvarslingen i Norge og ",
      varsomLinkLabel: "www.varsom.no",
      betweenLinks: " via deres åpne API som ligger ",
      apiLinkLabel: "her",
      afterApi: ".",
    },
    updateFrequency: {
      question: "Hvor ofte blir varslene oppdatert?",
      answer:
        "Klokka henter varslene en gang per time og lagrer de på klokka. I tillegg hentes de på nytt når du åpner appen dersom de er gamle. Hvis varslene er eldre enn 24 timer gamle vil de ikke lenger vises frem.",
    },
    internetConnection: {
      question: "Hvordan kommuniserer klokka med internett?",
      answer:
        "Klokka er avhengig av tilkobling til mobiltelefon med Bluetooth for å få hentet varsler fra internett, siden nesten ingen Garmin-klokker har direkte tilgang til internett selv. Hvis klokken din har utdaterte varsler eller slutter å vise varsler kan det være fordi klokka mangler tilkobling til mobil.",
    },
    beaconInterference: {
      question: "Kan klokka forstyrre skredsøkeren (sender/mottaker)?",
      paragraph1Before:
        "Akkurat som at en mobiltelefon kan forstyrre en skredsøker, er det også en viss mulighet for at en smartklokke kan forårsake forstyrrelser. Derfor anbefales det å slå av kommunikasjon med mobiltelefonen mens man går tur. En ",
      researchLinkLabel: "forskningsartikkel",
      paragraph1After:
        " fra 2014 publiserte en anbefaling om at man har klokka på motsatt hånd av den hånda man bruker en en skredsøker i søk-modus.",
      paragraph2:
        "For å slå av kommunikasjon med mobiltelefon underveis på turen kan man på de fleste Garmin-klokker konfigurere \"Power mode\" underveis i en aktivitet. Da kan man velge at \"Power mode\" for aktiviteten du bruker under topptur slår av kommunikasjon med mobil. Se instruksjonsboka for klokken din for å finne ut hvordan du gjør det på din klokke.",
    },
    whyPaid: {
      question: "Hvorfor er ikke appen gratis?",
      answer:
        "For å få appen til å fungere med Garmin må jeg kjøre en liten webtjeneste som behandler varslene fra Varsom og fjerner unødvendig informasjon for klokkevisning. Appen koster litt penger slik at jeg kan holde den webtjenesten gående uten å tape penger.",
    },
    sourceCode: {
      question: "Kan jeg få se kildekoden til appen?",
      beforeLink:
        "Det kan du! Hele appen, inkludert denne websiden, ligger åpent tilgjengelig på ",
      linkLabel: "Github",
      afterLink: ".",
    },
    vippsLogin: {
      question: "Hvorfor kan jeg ikke logge inn med Vipps lenger?",
      beforeLink:
        "Vipps har endret vilkårene sine, og \"Logg inn med Vipps\" er nå et ",
      linkLabel: "betalt produkt",
      afterLink:
        ". Jeg syns prisen Vipps har valgt å ta er urimelig høy, og har derfor erstattet \"Logg inn med Vipps\" med innlogging med e-post. Hvis du har problemer med å logge inn, ikke nøl med å ta kontakt!",
    },
    bugReport: {
      question: "Jeg fant en feil!",
      answer: "Ta kontakt, så skal jeg prøve å fikse det.",
    },
    contact: {
      question: "Jeg lurer fortsatt på noe. Hvordan kan jeg ta kontakt?",
      beforeInstagram: "Ta kontakt på ",
      instagramLabel: "Instagram",
      betweenLinks: " eller ",
      emailLabel: "mail",
      afterEmail: " hvis du fortsatt lurer på noe.",
    },
  },
} as const;

export const privacyNo = {
  title: "Personvernerklæring",
  intro:
    "Når du bruker skredvarsel.app, gir du oss tilgang til opplysninger om deg. Her kan du lese hvilke opplysninger vi samler inn, hvordan vi gjør det og hva vi bruker dem til.",
  about: {
    title: "Om skredvarsel.app",
    paragraph1:
      "Skredvarsel.app er eid av Dag Stuan og har til hensikt å selge abonnement på app som viser skredvarsel på Garmin-klokker. Skredvarsel.app er i henhold til personopplysningsloven og EUs generelle personvernforordning (GDPR) behandlingsansvarlig for de personopplysningene som behandles av selskapet.",
    contactIntro: "Vi har følgende kontaktdetaljer:",
    addressLabel: "Adresse",
    addressValue: "Marie Wexelsens veg 6, 7045 Trondheim",
    orgNumberLabel: "Organisasjonsnummer",
    orgNumberValue: "926 049 690",
  },
  personalData: {
    title: "Hva er personopplysninger?",
    paragraph:
      "Personopplysninger er informasjon som kan knyttes til en person, for eksempel navn, bosted, telefonnummer, e-postadresse og IP-adresse. Opplysninger om hvordan du bruker tjenesten vår, for eksempel hvilke produkter du har sett på eller kjøpt, regnes også som personopplysninger.",
  },
  collectedInfo: {
    title: "Hvilke opplysninger samler vi inn?",
    paragraph:
      "Når du oppretter en bruker for å kjøpe et abonnement oppgir du telefonnummer til Vipps. Vi får informasjon fra Vipps og lagrer navn, telefonnummer og e-postadresse. Dette blir lagret slik at du senere kan hente status for abonnementet ditt og si det opp ved behov.",
  },
  cookies: {
    title: "Informasjonskapsler",
    paragraph1:
      "Det benyttes informasjonskapsler på skredvarsel.app. En informasjonskapsel er en liten tekstfil som sendes til nettleseren og plasseres på datamaskinen, nettbrettet eller mobilenheten din når du besøker et nettsted. Den kan brukes til å huske informasjon om besøkene dine og kan for eksempel brukes til å spore preferansene dine, for eksempel språkinnstillinger.",
    paragraph2:
      "Vi bruker informasjonskapsler til å forbedre og forenkle besøket ditt. Vi bruker ikke informasjonskapsler til å lagre personlig informasjon med mindre du har gitt oss tillatelse til å gjøre det. Vi bruker heller ikke informasjonskapsler til å oppgi opplysninger til tredjeparter.",
    paragraph3:
      "De fleste nettlesere godtar automatisk informasjonskapsler. Samtykke til bruk av informasjonskapsler anses å ha blitt gitt hvis nettleseren er innstilt til å godta bruk. Dette gjelder også hvis godkjenning er forhåndsinnstilt for nettleseren. Du kan imidlertid fjerne og eller kontrollere informasjonskapsler ved å bruke nettleseren. Ved å bruke innstillingene i nettleseren kan du for eksempel fjerne alle informasjonskapsler eller velge å motta en melding hver gang en ny informasjonskapsel blir sendt til enheten. Vær oppmerksom på at det å begrense informasjonskapsler kan påvirke funksjonaliteten til nettstedet. Mange interaktive funksjoner som tilbys av nettstedet avhenger av informasjonskapsler.",
  },
  cookieTypes: {
    title: "Hvilke informasjonskapsler benyttes?",
    intro: "Skredvarsel.app bruker følgende informasjonskapsler:",
    paymentTitle: "Betaling",
    paymentProvider: "Vipps faste betalinger",
    vippsPolicyPrefix:
      "Vipps innhenter informasjon basert på deres retningslinjer som du kan finne i ",
    vippsPolicyLabel: "Vipps personvernerklæring",
  },
  deletionRequest: {
    title: "Forespørsel om sletting av data",
    paragraphBefore:
      "I samsvar med personvernlovgivningen kan du be oss om å slette dine personopplysninger. Dette kan gjøres ved å ta kontakt på ",
    paragraphAfter: ".",
  },
} as const;

export const salesConditionsNo = {
  title: "Salgsbetingelser",
  intro:
    "Disse salgsbetingelsene gjelder for salg av varer og tjenester til forbrukere av Skredvarsel for Garmin. Med forbruker menes en fysisk person som ikke hovedsakelig handler som ledd i næringsvirksomhet.",
  seller: {
    title: "Selger",
    paragraph:
      "Dag Stuan\nOrganisasjonsnummer: 926 049 690\nAdresse: Marie Wexelsens veg 6, 7045 Trondheim\nHeretter også omtalt som «vi», «oss» eller «skredvarsel.app».",
  },
  buyer: {
    title: "Kjøper",
    paragraph:
      "Er den personen som er oppgitt som kjøper i bestillingen, heretter også omtalt som «du», «din» eller «deg».",
  },
  payment: {
    title: "Betaling",
    paragraph:
      "Vipps brukes som betalingsmetode. Abonnementsbetaling vil bli fakturert automatisk ved starten av den månedlige eller årlige perioden, avhengig av hvilken betalingsperiode du velger. Betaling fornyes automatisk inntil abonnementet ditt nedgraderes eller avsluttes. Du kan kansellere abonnementet ditt når som helst, som beskrevet nedenfor.",
  },
  fees: {
    title: "Avgifter",
    paragraph:
      "For å få tilgang til applikasjonen på klokka, blir du pålagt å betale abonnementsavgift. Abonnementsavgift kan betales på månedlig eller årlig basis. Abonnementsavgiften betales på forhånd. Hvis du bytter fra månedlig til årlig abonnement vil årspris tre i kraft ved begynnelsen av neste faktureringsdato. Du godtar å betale abonnementsavgift i forbindelse med kontoen din på skredvarsel.app, enten på engangs- eller abonnementsbasis. Skredvarsel.app forbeholder seg retten til å øke abonnementsavgiftene, eventuelle tilknyttede skatter, eller å innføre nye avgifter når som helst med rimelig forhåndsvarsel.",
  },
  renewal: {
    title: "Automatisk fornyelse av abonnement",
    paragraph:
      "Abonnementsavgifter vil bli fakturert automatisk ved starten av den månedlige eller årlige perioden, avhengig av hva som er aktuelt. Disse avgiftene fornyes automatisk inntil abonnementet ditt nedgraderes eller avsluttes. Abonnementsavgiften din vil være den samme som de første kostnadene dine med mindre du får beskjed om noe annet på forhånd. Du kan kansellere abonnementet ditt når som helst, som beskrevet nedenfor.",
  },
  delivery: {
    title: "Levering",
    paragraph: "Etter godkjent betaling vil du få tilgang til data på klokken.",
  },
  cancellation: {
    title: "Kansellering av abonnement",
    paragraph:
      "Du kan kansellere abonnementet ditt ved å gå til «Konto»-siden og velge «Avslutt». Kanselleringen av et abonnement trer i kraft ved slutten av gjeldende faktureringsperiode. Du kan fornye abonnementet ditt når som helst uten å åpne en ny konto, selv om abonnementsavgiftene kan ha økt. Du kan slette kontoen din når som helst.",
  },
  withdrawal: {
    title: "Angrerett",
    paragraph:
      "Alle abonnementer har 14 dagers angrerett. Vær oppmerksom på at angreretten kun gjelder nye kjøp, og ikke ved automatisk fornyelse av ditt abonnement. For å angre ditt kjøp, send en e-post til d.stuan@gmail.com. Skriv gjerne også hvorfor du ønsker å angre kjøpet ditt. Dette hjelper oss å forbedre tjenesten vår i fremtiden. Hvis du benytter deg av angreretten, vil du få tilbakebetalt tjenestens verdi ved kjøpstidspunktet. Beløpet vil tilbakeføres direkte til den Vipps-kontoen du benyttet ved kjøp.",
  },
  disputeResolution: {
    title: "Konfliktløsning",
    paragraph:
      "Klager rettes til selger innen rimelig tid. Partene skal forsøke å løse eventuelle tvister i minnelighet. Dersom dette ikke lykkes, kan kjøperen ta kontakt med Forbrukerrådet for mekling. Forbrukerrådet er tilgjengelig på telefon 23 400 500 eller www.forbrukerradet.no.",
  },
  defects: {
    title: "Mangel ved varen - kjøperens rettigheter og reklamasjonsfrist",
    paragraph:
      "Hvis det foreligger en mangel ved varen må kjøper innen rimelig tid etter at den ble oppdaget eller burde ha blitt oppdaget, gi selger melding om at han eller hun vil påberope seg mangelen. Kjøper har alltid reklamert tidsnok dersom det skjer innen 2 mnd. fra mangelen ble oppdaget eller burde blitt oppdaget. Reklamasjon kan skje senest to år etter at kjøper overtok varen. For å reklamere på ditt kjøp, send en e-post til d.stuan@gmail.com med beskrivelse av hva som er mangelfullt med varen.",
  },
} as const;

export const faqEn = {
  title: "Frequently asked questions",
  problemsHelpAlt: "Explanation of avalanche problems",
  items: {
    installApp: {
      question: "How do I install the app?",
      step1Before: "Go to ",
      step1LinkLabel: "Connect IQ Store",
      step1After:
        " and download the app to your watch. You may also need to install the \"Connect IQ Store\" app on your phone.",
      step2LinkLabel: "Buy a subscription for the app",
      step3:
        "Start the app on the watch. A code should appear that you need to enter.",
      step4Before: "Go to ",
      step4LinkLabel: "Account",
      step4After: " and enter the code shown on the watch.",
      step5: "Thank you!",
    },
    detailSymbols: {
      question: "What do the symbols in the detail view mean?",
      intro: "Red marks the area that is most exposed.",
      point1: "Aspect directions that are most exposed to the avalanche problem.",
      point2: "Where in the mountain the avalanche problem is found.",
      point3: "Elevations above sea level where the avalanche problem exists.",
      point4: "Forecast danger level for the avalanche problem.",
      note:
        "Note: there will always be local variations, and the red areas mark the most exposed places. That means the avalanche problem may also exist in other areas, but it is expected to be less widespread there.",
    },
    paymentMethods: {
      question: "Can I pay with something other than Vipps?",
      answer:
        "Garmin does not offer in-store app payments in its own \"Connect IQ Store\", so all payments for Garmin watch apps must be handled outside the store. That means I need to provide the payment solution myself, and for now I have chosen to only offer Vipps.",
    },
    compatibleWatches: {
      question: "Which watches does the app work on?",
      introBefore:
        "The app works on most newer Garmin watches with a color display. A complete overview is available in the ",
      introLinkLabel: "Connect IQ Store",
      introAfter:
        ". If your watch supports music, there is a greater chance that the app works because those watches have more memory.",
      unsupportedHeading:
        "Watches that do not support the app because of limited memory:",
    },
    whyNotMyWatch: {
      question: "Why doesn’t it work on my watch?",
      answer:
        "I have tried to make the app work on as many watches as possible, and new watches are added over time. If the app does not work on your watch, the most likely reason is memory limits in the watch itself. Garmin watches have very strict memory requirements in order to maintain battery life.",
    },
    weirdLayout: {
      question: "Things look strange on my screen.",
      answer:
        "Some Garmin watches with very small screens do not have much room to display information. I am still working on making the app look perfect on smaller screens. I also have not tested every physical watch because I do not own all of them. Feel free to send me a photo of what it looks like on your watch so I can improve the layout.",
    },
    sources: {
      question: "Where do the forecasts come from?",
      beforeVarsom:
        "The forecasts are fetched from the avalanche forecasting service in Norway and ",
      varsomLinkLabel: "www.varsom.no",
      betweenLinks: " through their public API available ",
      apiLinkLabel: "here",
      afterApi: ".",
    },
    updateFrequency: {
      question: "How often are the forecasts updated?",
      answer:
        "The watch fetches forecasts once every hour and stores them on the watch. They are also fetched again when you open the app if the existing data is old. If the forecasts are more than 24 hours old, they are no longer shown.",
    },
    internetConnection: {
      question: "How does the watch communicate with the internet?",
      answer:
        "The watch depends on a Bluetooth connection to your phone in order to fetch forecasts from the internet, because almost no Garmin watches have direct internet access. If your watch has outdated forecasts or stops showing them, it may be because the watch has lost its phone connection.",
    },
    beaconInterference: {
      question: "Can the watch interfere with an avalanche beacon?",
      paragraph1Before:
        "Just as a mobile phone can interfere with an avalanche transceiver, there is also some possibility that a smartwatch can cause interference. Because of that, it is recommended to disable phone communication while touring. A ",
      researchLinkLabel: "research paper",
      paragraph1After:
        " from 2014 recommended wearing the watch on the opposite hand from the one you use for the beacon in search mode.",
      paragraph2:
        "To turn off phone communication during a tour, most Garmin watches let you configure a \"Power mode\" during an activity. You can choose a power mode for your ski touring activity that disables phone communication. Check your watch manual to see how to do that on your model.",
    },
    whyPaid: {
      question: "Why isn’t the app free?",
      answer:
        "To make the app work with Garmin, I need to run a small web service that processes the forecasts from Varsom and removes unnecessary information for watch display. The app costs a little so I can keep that service running without losing money.",
    },
    sourceCode: {
      question: "Can I see the app source code?",
      beforeLink:
        "Yes. The entire app, including this website, is openly available on ",
      linkLabel: "GitHub",
      afterLink: ".",
    },
    vippsLogin: {
      question: "Why can’t I log in with Vipps anymore?",
      beforeLink:
        "Vipps changed its terms, and \"Log in with Vipps\" is now a ",
      linkLabel: "paid product",
      afterLink:
        ". I think the price Vipps chose is unreasonably high, so I replaced Vipps login with email login instead. If you have trouble logging in, feel free to get in touch.",
    },
    bugReport: {
      question: "I found a bug!",
      answer: "Get in touch and I will try to fix it.",
    },
    contact: {
      question: "I still have a question. How can I get in touch?",
      beforeInstagram: "Reach out on ",
      instagramLabel: "Instagram",
      betweenLinks: " or by ",
      emailLabel: "email",
      afterEmail: " if you still have questions.",
    },
  },
} as const;

export const privacyEn = {
  title: "Privacy policy",
  intro:
    "When you use skredvarsel.app, you give us access to information about you. Here you can read what information we collect, how we collect it and what we use it for.",
  about: {
    title: "About skredvarsel.app",
    paragraph1:
      "Skredvarsel.app is owned by Dag Stuan and exists to sell subscriptions for an app that shows avalanche forecasts on Garmin watches. In accordance with Norwegian privacy legislation and the EU General Data Protection Regulation, skredvarsel.app is the data controller for the personal data processed by the company.",
    contactIntro: "We have the following contact details:",
    addressLabel: "Address",
    addressValue: "Marie Wexelsens veg 6, 7045 Trondheim",
    orgNumberLabel: "Organization number",
    orgNumberValue: "926 049 690",
  },
  personalData: {
    title: "What is personal data?",
    paragraph:
      "Personal data is information that can be linked to a person, for example a name, place of residence, phone number, email address or IP address. Information about how you use our service, such as which products you have viewed or purchased, is also considered personal data.",
  },
  collectedInfo: {
    title: "What information do we collect?",
    paragraph:
      "When you create a user to buy a subscription, you provide your Vipps phone number. We receive information from Vipps and store your name, phone number and email address. This is stored so that you can later retrieve the status of your subscription and cancel it if needed.",
  },
  cookies: {
    title: "Cookies",
    paragraph1:
      "Cookies are used on skredvarsel.app. A cookie is a small text file sent to the browser and placed on your computer, tablet or mobile device when you visit a website. It can be used to remember information about your visits and can for example be used to track your preferences, such as language settings.",
    paragraph2:
      "We use cookies to improve and simplify your visit. We do not use cookies to store personal information unless you have given us permission to do so. We also do not use cookies to provide personal data to third parties.",
    paragraph3:
      "Most browsers automatically accept cookies. Consent to the use of cookies is considered granted if your browser is configured to accept them. This also applies if acceptance is preconfigured in the browser. You can however remove and control cookies by using your browser settings. For example, you can delete all cookies or choose to receive a notice every time a new cookie is sent to your device. Please note that restricting cookies may affect the functionality of the website. Many interactive features offered by the website depend on cookies.",
  },
  cookieTypes: {
    title: "Which cookies are used?",
    intro: "Skredvarsel.app uses the following cookies:",
    paymentTitle: "Payments",
    paymentProvider: "Vipps recurring payments",
    vippsPolicyPrefix:
      "Vipps collects information according to its own policies, which you can find in the ",
    vippsPolicyLabel: "Vipps privacy policy",
  },
  deletionRequest: {
    title: "Request deletion of data",
    paragraphBefore:
      "In accordance with privacy legislation, you may ask us to delete your personal data. This can be done by contacting ",
    paragraphAfter: ".",
  },
} as const;

export const salesConditionsEn = {
  title: "Terms of sale",
  intro:
    "These terms of sale apply to the sale of goods and services to consumers of Avalanche Forecast for Garmin. A consumer means a natural person who is not mainly acting as part of a business activity.",
  seller: {
    title: "Seller",
    paragraph:
      "Dag Stuan\nOrganization number: 926 049 690\nAddress: Marie Wexelsens veg 6, 7045 Trondheim\nAlso referred to below as «we», «us» or «skredvarsel.app».",
  },
  buyer: {
    title: "Buyer",
    paragraph:
      "The buyer is the person identified as the purchaser in the order, also referred to below as «you» or «your».",
  },
  payment: {
    title: "Payment",
    paragraph:
      "Vipps is used as the payment method. Subscription payments are charged automatically at the beginning of the monthly or yearly period, depending on which billing period you choose. Payments renew automatically until your subscription is downgraded or terminated. You may cancel your subscription at any time as described below.",
  },
  fees: {
    title: "Fees",
    paragraph:
      "To access the application on the watch, you are required to pay a subscription fee. The subscription fee can be paid monthly or yearly. The subscription fee is paid in advance. If you change from a monthly to a yearly subscription, the yearly price takes effect at the beginning of the next billing date. You agree to pay the subscription fee associated with your account at skredvarsel.app, either on a one-time or recurring basis. Skredvarsel.app reserves the right to increase subscription fees, any related taxes, or introduce new fees at any time with reasonable prior notice.",
  },
  renewal: {
    title: "Automatic subscription renewal",
    paragraph:
      "Subscription fees are charged automatically at the beginning of the monthly or yearly period, as applicable. These fees renew automatically until your subscription is downgraded or terminated. Your subscription fee will be the same as your original fee unless you are informed otherwise in advance. You may cancel your subscription at any time as described below.",
  },
  delivery: {
    title: "Delivery",
    paragraph: "After approved payment, you will get access to the data on your watch.",
  },
  cancellation: {
    title: "Subscription cancellation",
    paragraph:
      "You may cancel your subscription by going to the «Account» page and choosing «Cancel». The cancellation takes effect at the end of the current billing period. You may renew your subscription at any time without opening a new account, even if subscription fees may have increased. You may delete your account at any time.",
  },
  withdrawal: {
    title: "Right of withdrawal",
    paragraph:
      "All subscriptions have a 14-day right of withdrawal. Please note that this right only applies to new purchases and not to automatic renewal of your subscription. To withdraw from your purchase, send an email to d.stuan@gmail.com. You are welcome to explain why you want to withdraw, as this helps us improve the service in the future. If you make use of the right of withdrawal, you will be refunded the value of the service at the time of purchase. The amount will be returned directly to the Vipps account used for the purchase.",
  },
  disputeResolution: {
    title: "Dispute resolution",
    paragraph:
      "Complaints should be directed to the seller within a reasonable time. The parties shall attempt to resolve disputes amicably. If this is unsuccessful, the buyer may contact the Norwegian Consumer Council for mediation. The Consumer Council is available by phone at 23 400 500 or at www.forbrukerradet.no.",
  },
  defects: {
    title: "Product defects - the buyer’s rights and complaint deadline",
    paragraph:
      "If there is a defect in the product, the buyer must notify the seller within a reasonable time after the defect was discovered or should have been discovered that they wish to invoke the defect. A complaint is always timely if it is made within two months of the defect being discovered or when it should have been discovered. A complaint can be made no later than two years after the buyer took over the product. To submit a complaint, send an email to d.stuan@gmail.com describing the defect in the product.",
  },
} as const;