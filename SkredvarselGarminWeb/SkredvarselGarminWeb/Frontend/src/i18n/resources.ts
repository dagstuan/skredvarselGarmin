import {
  faqEn,
  faqNo,
  privacyEn,
  privacyNo,
  salesConditionsEn,
  salesConditionsNo,
} from "./resources/content";
import { seoEn, seoNo } from "./resources/seo";
import { faqSv, privacySv, salesConditionsSv, seoSv } from "./resources/sv";

type TranslationLeaf = string | readonly string[];

type TranslationSchema<T> = {
  [K in keyof T]: T[K] extends TranslationLeaf
    ? T[K] extends readonly string[]
      ? readonly string[]
      : string
    : T[K] extends object
      ? TranslationSchema<T[K]>
      : never;
};

const no = {
  common: {
    loading: "Laster...",
    or: "Eller",
    close: "Lukk",
    delete: "Slett",
    checkInbox: "Sjekk innboksen din for en innloggingslenke.",
  },
  languageSwitcher: {
    label: "Språk",
    norwegian: "NO",
    english: "EN",
    swedish: "SV",
  },
  nav: {
    iconAlt: "Skredvarsel-ikon",
    shortTitle: "Skredvarsel",
    title: "Skredvarsel for Garmin",
    login: "Logg inn",
    admin: "Admin",
    account: "Min side",
    faq: "Spørsmål og svar",
  },
  ciqStore: {
    downloadOn: "Last ned på",
  },
  frontPage: {
    heroLine1: "Skredvarsel for Garmin-klokker.",
    heroLine2: "Oppdatert og tilgjengelig mens du er på tur.",
    priceValue: "30 kr",
    priceUnit: "/år",
    buySubscription: "Kjøp abonnement",
    paymentMethodVipps: "Vipps",
    paymentMethodCard: "Kort",
    paymentMethodApplePay: "Apple Pay",
    paymentMethodGooglePay: "Google Pay",
  },
  features: {
    norwayAndSweden: {
      heading: "Norge og Sverige",
      text: "Skredvarsler for alle varslingsregioner i Norge og Sverige.",
    },
    dataField: {
      heading: "Datafelt",
      text: "Legg til datafeltet i aktiviteten og følg varselet underveis på turen.",
    },
    glance: {
      heading: "Glance",
      text: "Se tidslinje med faregrader for én region sammen med andre widgets.",
    },
    timelines: {
      heading: "Tidslinjer",
      text: "Tidslinjer med faregrader over tid for dine valgte regioner.",
    },
    textForecast: {
      heading: "Tekstvarsel",
      text: "Tekstvarsel med nærmere informasjon om faregraden for dagen.",
    },
    avalancheProblems: {
      heading: "Skredproblemer",
      text: "Se alle meldte skredproblemer for dagen.",
    },
    offline: {
      alt: "Skredvarsel for Garmin",
      heading: "Tilgjengelig uten tilkobling",
      text: "Appen synkroniserer snøskredvarselet for alle valgte regioner hver time. Varselet er tilgjengelig selv om du er på tur uten dekning eller uten mobilen.",
    },
  },
  footer: {
    owner: "Dag Stuan",
    sourcesPrefix: "Varsler fra Snøskredvarslingen i Norge (",
    sourcesMiddle: ") og Naturvårdsverket i Sverige (",
    sourcesSuffix: ")",
    iconsPrefix: "Ikoner fra ",
    iconsLinkLabel: "European Avalanche Warning Services.",
    aboutHeading: "Om",
    faq: "Ofte stilte spørsmål",
    privacy: "Personvern og informasjonskapsler",
    salesConditions: "Salgsbetingelser",
    sourceCode: "Kildekode",
    socialHeading: "Sosiale medier",
    disclaimer:
      "Bruk varslene og datagrunnlaget på eget ansvar. Det kan forekomme feil og mangler. Varselet er et hjelpemiddel, ikke en fasit. Gjør alltid egne vurderinger. Tilpass egen risiko i utsatte områder ved å velge hvor, når og hvordan du ferdes. Varslene er regionale og basert på tilgjengelige observasjoner og værprognoser. Forholdene kan være komplekse og avvike fra det som er varslet. Verken NVE eller Dag Stuan gir garantier for informasjonens aktualitet og tar ikke ansvar for at data kan gi feil eller villedende informasjon.",
  },
  buttons: {
    vipps: {
      continueWith: "Fortsett med",
      buySubscriptionWith: "Kjøp abonnement med",
      goTo: "Gå til",
    },
    stripe: {
      buySubscriptionWith: "Kjøp abonnement med",
      manageInStripe: "Gå til Stripe for å endre abonnement",
      card: "Kort",
      applePay: "Apple Pay",
      googlePay: "Google Pay",
    },
    google: {
      login: "Logg inn med Google",
    },
    facebook: {
      login: "Logg inn med Facebook",
    },
  },
  login: {
    title: "Logg inn",
    emailSentTitle: "E-post sendt",
    loginDescription:
      "Logg inn eller registrer deg med e-post eller sosiale innlogginger.",
    emailSentDescription:
      "Det er sendt en innloggingslenke til e-postadressen din.",
    whyNoVippsLogin: "Hvorfor kan jeg ikke logge inn med Vipps?",
    loginManageSubscription: "Logg inn for å administrere abonnement",
    emailPlaceholder: "E-post",
    emailRequired: "Du må skrive inn en e-postadresse.",
    loginWithEmail: "Logg inn med e-post",
    linkExpired: "Innloggingslenken har utløpt. Be om en ny lenke under.",
    linkInvalid: "Innloggingslenken er ugyldig. Be om en ny lenke under.",
  },
  buySubscription: {
    title: "Kjøp abonnement",
    infoLine1: "Abonnement kjøpes med Vipps eller Stripe.",
    infoLine2:
      "Når du kjøper abonnement har du tilgang i 12 måneder fra kjøpsdato.",
    infoLine3:
      "Velg hvordan du vil kjøpe abonnement. Hvis du allerede har et abonnement, kan du logge inn for å administrere det.",
    addWatchLine1: "Abonnement kan kjøpes med Vipps eller Stripe.",
    addWatchLine2:
      "Hvis du allerede har et abonnement, kan du logge inn for å legge til klokken din.",
    srDescription:
      "Velg hvordan du vil kjøpe abonnement eller logge inn for å endre det.",
  },
  account: {
    pageTitle: "Min side",
    srDescription:
      "Administrer abonnement, klokker og personlige opplysninger.",
    faqPromptPrefix: "Lurer du på noe? Se ",
    faqPromptLink: "ofte stilte spørsmål",
    faqPromptSuffix: ".",
    subscriptionHeading: "Abonnement",
    watchesHeading: "Klokker",
    personalInfoHeading: "Personlige opplysninger",
    logout: "Logg ut",
    subscription: {
      none: "Du har ikke registrert et abonnement på appen.",
      pending:
        "Du har en pågående registrering for et abonnement. Gå til Vipps for å fullføre registreringen.",
      canceled:
        "Du har sagt opp abonnementet ditt. Du har fortsatt tilgang frem til {{date}}.",
      reactivate: "Behold abonnementet",
      active: "Du har registrert et abonnement på appen. Tusen takk!",
      renewsOn: "Abonnementet fornyes automatisk {{date}}",
      cancel: "Avslutt abonnement",
    },
    watches: {
      none: "Du har ikke lagt til noen klokker.",
      addWatchLabel: "Legg til klokke",
      add: "Legg til",
      help: "Skriv inn koden som står på klokka når du starter appen.",
      codeRequired: "Du må skrive inn en kode.",
      added: "Klokke lagt til",
      addFailed:
        "Det skjedde en feil når vi prøvde å legge til klokken. Prøv igjen senere.",
      notFound: "Fant ikke noen klokke med den koden.",
      deleteAriaLabel: "Slett {{name}}",
    },
  },
  faq: faqNo,
  privacy: privacyNo,
  salesConditions: salesConditionsNo,
  error: {
    title: "Oops!",
    unexpected: "Beklager, det oppstod en uventet feil.",
  },
  seo: seoNo,
  admin: {
    title: "Admin",
    numberOfUsers: "Antall brukere",
    watches: "Klokker",
    staleUsers: "Inaktive brukere",
    activeAgreements: "Aktive avtaler",
    unsubscribedAgreements: "Oppsagte avtaler",
    activeOrUnsubscribedAgreements: "Aktive eller oppsagte avtaler",
  },
} as const;

const en = {
  common: {
    loading: "Loading...",
    or: "Or",
    close: "Close",
    delete: "Delete",
    checkInbox: "Check your inbox for a sign-in link.",
  },
  languageSwitcher: {
    label: "Language",
    norwegian: "NO",
    english: "EN",
    swedish: "SV",
  },
  nav: {
    iconAlt: "Avalanche warning icon",
    shortTitle: "Skredvarsel",
    title: "Skredvarsel for Garmin",
    login: "Log in",
    admin: "Admin",
    account: "Account",
    faq: "FAQ",
  },
  ciqStore: {
    downloadOn: "Download on",
  },
  frontPage: {
    heroLine1: "Avalanche forecasts for Garmin watches.",
    heroLine2: "Updated and available while you are out in the mountains.",
    priceValue: "NOK 30",
    priceUnit: "/year",
    buySubscription: "Buy subscription",
    paymentMethodVipps: "Vipps",
    paymentMethodCard: "Card",
    paymentMethodApplePay: "Apple Pay",
    paymentMethodGooglePay: "Google Pay",
  },
  features: {
    norwayAndSweden: {
      heading: "Norway and Sweden",
      text: "Avalanche forecasts for every warning region in Norway and Sweden.",
    },
    dataField: {
      heading: "Data field",
      text: "Add the data field to your activity and follow the forecast while you are out touring.",
    },
    glance: {
      heading: "Glance",
      text: "See a timeline of danger levels for a single region alongside your other widgets.",
    },
    timelines: {
      heading: "Timelines",
      text: "Timelines with danger levels over time for your selected regions.",
    },
    textForecast: {
      heading: "Text forecast",
      text: "A text forecast with more detailed information about the danger level for the current day.",
    },
    avalancheProblems: {
      heading: "Avalanche problems",
      text: "See every reported avalanche problem for the day.",
    },
    offline: {
      alt: "Skredvarsel for Garmin",
      heading: "Available offline",
      text: "The app syncs avalanche forecasts for all selected regions every hour. The forecast is still available even when you are out without cell coverage or without your phone.",
    },
  },
  footer: {
    owner: "Dag Stuan",
    sourcesPrefix:
      "Forecasts from the avalanche forecasting services in Norway (",
    sourcesMiddle: ") and Sweden (",
    sourcesSuffix: ")",
    iconsPrefix: "Icons from ",
    iconsLinkLabel: "European Avalanche Warning Services.",
    aboutHeading: "About",
    faq: "Frequently asked questions",
    privacy: "Privacy and cookies",
    salesConditions: "Terms of sale",
    sourceCode: "Source code",
    socialHeading: "Social media",
    disclaimer:
      "Use the forecasts and underlying data at your own risk. Errors and omissions may occur. The forecast is an aid, not a guarantee. Always make your own assessments. Adjust your personal risk in exposed terrain by choosing where, when and how you travel. The forecasts are regional and based on available observations and weather forecasts. Conditions can be complex and may differ from what is forecast. Neither NVE nor Dag Stuan guarantees that the information is up to date and they are not responsible for data that may be incorrect or misleading.",
  },
  buttons: {
    vipps: {
      continueWith: "Continue with",
      buySubscriptionWith: "Buy subscription with",
      goTo: "Go to",
    },
    stripe: {
      buySubscriptionWith: "Buy subscription with",
      manageInStripe: "Go to Stripe to manage your subscription",
      card: "Card",
      applePay: "Apple Pay",
      googlePay: "Google Pay",
    },
    google: {
      login: "Log in with Google",
    },
    facebook: {
      login: "Log in with Facebook",
    },
  },
  login: {
    title: "Log in",
    emailSentTitle: "Email sent",
    loginDescription:
      "Log in or sign up with email or a social sign-in provider.",
    emailSentDescription: "A sign-in link has been sent to your email address.",
    whyNoVippsLogin: "Why can’t I log in with Vipps anymore?",
    loginManageSubscription: "Log in to manage your subscription",
    emailPlaceholder: "Email",
    emailRequired: "You must enter an email address.",
    loginWithEmail: "Log in with email",
    linkExpired: "The sign-in link has expired. Request a new one below.",
    linkInvalid: "The sign-in link is invalid. Request a new one below.",
  },
  buySubscription: {
    title: "Buy subscription",
    infoLine1: "Subscriptions can be purchased with Vipps or Stripe.",
    infoLine2:
      "When you buy a subscription, you get access for 12 months from the date of purchase.",
    infoLine3:
      "Choose how you want to buy your subscription. If you already have a subscription, you can log in to manage it.",
    addWatchLine1: "Subscriptions can be purchased with Vipps or Stripe.",
    addWatchLine2:
      "If you already have a subscription, you can log in to add your watch.",
    srDescription:
      "Choose how you want to buy a subscription or log in to change it.",
  },
  account: {
    pageTitle: "Account",
    srDescription: "Manage subscriptions, watches and personal information.",
    faqPromptPrefix: "Need help? See the ",
    faqPromptLink: "frequently asked questions",
    faqPromptSuffix: ".",
    subscriptionHeading: "Subscription",
    watchesHeading: "Watches",
    personalInfoHeading: "Personal information",
    logout: "Log out",
    subscription: {
      none: "You do not have a subscription registered for the app.",
      pending:
        "You have a subscription registration in progress. Go to Vipps to complete it.",
      canceled:
        "You have canceled your subscription. You still have access until {{date}}.",
      reactivate: "Keep subscription",
      active: "You have a subscription registered for the app. Thank you!",
      renewsOn: "The subscription renews automatically on {{date}}",
      cancel: "Cancel subscription",
    },
    watches: {
      none: "You have not added any watches.",
      addWatchLabel: "Add watch",
      add: "Add",
      help: "Enter the code shown on the watch when you start the app.",
      codeRequired: "You must enter a code.",
      added: "Watch added",
      addFailed:
        "Something went wrong while we tried to add the watch. Please try again later.",
      notFound: "No watch found with that code.",
      deleteAriaLabel: "Delete {{name}}",
    },
  },
  faq: faqEn,
  privacy: privacyEn,
  salesConditions: salesConditionsEn,
  error: {
    title: "Oops!",
    unexpected: "Sorry, an unexpected error has occurred.",
  },
  seo: seoEn,
  admin: {
    title: "Admin",
    numberOfUsers: "Number of users",
    watches: "Watches",
    staleUsers: "Stale users",
    activeAgreements: "Active agreements",
    unsubscribedAgreements: "Unsubscribed agreements",
    activeOrUnsubscribedAgreements: "Active or unsubscribed agreements",
  },
} as const satisfies TranslationSchema<typeof no>;

const sv = {
  common: {
    loading: "Laddar...",
    or: "Eller",
    close: "Stäng",
    delete: "Ta bort",
    checkInbox: "Kolla din inkorg efter en inloggningslänk.",
  },
  languageSwitcher: {
    label: "Språk",
    norwegian: "NO",
    english: "EN",
    swedish: "SV",
  },
  nav: {
    iconAlt: "Lavinvarningsikon",
    shortTitle: "Skredvarsel",
    title: "Skredvarsel for Garmin",
    login: "Logga in",
    admin: "Admin",
    account: "Konto",
    faq: "Frågor och svar",
  },
  ciqStore: {
    downloadOn: "Hämta på",
  },
  frontPage: {
    heroLine1: "Lavinvarningar för Garmin-klockor.",
    heroLine2: "Uppdaterade och tillgängliga medan du är ute på tur.",
    priceValue: "30 NOK",
    priceUnit: "/år",
    buySubscription: "Köp abonnemang",
    paymentMethodVipps: "Vipps",
    paymentMethodCard: "Kort",
    paymentMethodApplePay: "Apple Pay",
    paymentMethodGooglePay: "Google Pay",
  },
  features: {
    norwayAndSweden: {
      heading: "Norge och Sverige",
      text: "Lavinvarningar för alla varningsregioner i Norge och Sverige.",
    },
    dataField: {
      heading: "Datafält",
      text: "Lägg till datafältet i aktiviteten och följ varningen under turen.",
    },
    glance: {
      heading: "Översikt",
      text: "Se en tidslinje med faranivåer för en region tillsammans med dina andra widgets.",
    },
    timelines: {
      heading: "Tidslinjer",
      text: "Tidslinjer med faranivåer över tid för dina valda regioner.",
    },
    textForecast: {
      heading: "Textprognos",
      text: "En textprognos med mer detaljerad information om faranivån för den aktuella dagen.",
    },
    avalancheProblems: {
      heading: "Lavinproblem",
      text: "Se alla rapporterade lavinproblem för dagen.",
    },
    offline: {
      alt: "Skredvarsel for Garmin",
      heading: "Tillgänglig offline",
      text: "Appen synkroniserar lavinvarningar för alla valda regioner varje timme. Varningen är fortfarande tillgänglig även när du är ute utan täckning eller utan mobilen.",
    },
  },
  footer: {
    owner: "Dag Stuan",
    sourcesPrefix: "Varningar från lavinvarningstjänsterna i Norge (",
    sourcesMiddle: ") och Sverige (",
    sourcesSuffix: ")",
    iconsPrefix: "Ikoner från ",
    iconsLinkLabel: "European Avalanche Warning Services.",
    aboutHeading: "Om",
    faq: "Vanliga frågor",
    privacy: "Integritet och kakor",
    salesConditions: "Köpvillkor",
    sourceCode: "Källkod",
    socialHeading: "Sociala medier",
    disclaimer:
      "Använd varningarna och underlaget på egen risk. Fel och brister kan förekomma. Varningen är ett hjälpmedel, inte en garanti. Gör alltid dina egna bedömningar. Anpassa din egen risk i utsatt terräng genom att välja var, när och hur du rör dig. Varningarna är regionala och bygger på tillgängliga observationer och väderprognoser. Förhållandena kan vara komplexa och avvika från det som varnas för. Varken NVE eller Dag Stuan garanterar att informationen är uppdaterad och ansvarar inte för data som kan vara felaktiga eller missvisande.",
  },
  buttons: {
    vipps: {
      continueWith: "Fortsätt med",
      buySubscriptionWith: "Köp abonnemang med",
      goTo: "Gå till",
    },
    stripe: {
      buySubscriptionWith: "Köp abonnemang med",
      manageInStripe: "Gå till Stripe för att hantera abonnemanget",
      card: "Kort",
      applePay: "Apple Pay",
      googlePay: "Google Pay",
    },
    google: {
      login: "Logga in med Google",
    },
    facebook: {
      login: "Logga in med Facebook",
    },
  },
  login: {
    title: "Logga in",
    emailSentTitle: "E-post skickad",
    loginDescription:
      "Logga in eller registrera dig med e-post eller sociala inloggningar.",
    emailSentDescription:
      "En inloggningslänk har skickats till din e-postadress.",
    whyNoVippsLogin: "Varför kan jag inte längre logga in med Vipps?",
    loginManageSubscription: "Logga in för att hantera abonnemanget",
    emailPlaceholder: "E-post",
    emailRequired: "Du måste ange en e-postadress.",
    loginWithEmail: "Logga in med e-post",
    linkExpired: "Inloggningslänken har gått ut. Begär en ny länk nedan.",
    linkInvalid: "Inloggningslänken är ogiltig. Begär en ny länk nedan.",
  },
  buySubscription: {
    title: "Köp abonnemang",
    infoLine1: "Abonnemang kan köpas med Vipps eller Stripe.",
    infoLine2:
      "När du köper ett abonnemang får du tillgång i 12 månader från köpdatumet.",
    infoLine3:
      "Välj hur du vill köpa ditt abonnemang. Om du redan har ett abonnemang kan du logga in för att hantera det.",
    addWatchLine1: "Abonnemang kan köpas med Vipps eller Stripe.",
    addWatchLine2:
      "Om du redan har ett abonnemang kan du logga in för att lägga till din klocka.",
    srDescription:
      "Välj hur du vill köpa ett abonnemang eller logga in för att ändra det.",
  },
  account: {
    pageTitle: "Konto",
    srDescription: "Hantera abonnemang, klockor och personuppgifter.",
    faqPromptPrefix: "Behöver du hjälp? Se ",
    faqPromptLink: "vanliga frågor",
    faqPromptSuffix: ".",
    subscriptionHeading: "Abonnemang",
    watchesHeading: "Klockor",
    personalInfoHeading: "Personlig information",
    logout: "Logga ut",
    subscription: {
      none: "Du har inget abonnemang registrerat för appen.",
      pending:
        "Du har en abonnemangsregistrering som pågår. Gå till Vipps för att slutföra den.",
      canceled:
        "Du har sagt upp ditt abonnemang. Du har fortfarande tillgång fram till den {{date}}.",
      reactivate: "Behåll abonnemanget",
      active: "Du har ett abonnemang registrerat för appen. Tack!",
      renewsOn: "Abonnemanget förnyas automatiskt den {{date}}",
      cancel: "Avsluta abonnemang",
    },
    watches: {
      none: "Du har inte lagt till några klockor.",
      addWatchLabel: "Lägg till klocka",
      add: "Lägg till",
      help: "Ange koden som visas på klockan när du startar appen.",
      codeRequired: "Du måste ange en kod.",
      added: "Klocka tillagd",
      addFailed:
        "Något gick fel när vi försökte lägga till klockan. Försök igen senare.",
      notFound: "Hittade ingen klocka med den koden.",
      deleteAriaLabel: "Ta bort {{name}}",
    },
  },
  faq: faqSv,
  privacy: privacySv,
  salesConditions: salesConditionsSv,
  error: {
    title: "Oops!",
    unexpected: "Tyvärr uppstod ett oväntat fel.",
  },
  seo: seoSv,
  admin: {
    title: "Admin",
    numberOfUsers: "Antal användare",
    watches: "Klockor",
    staleUsers: "Inaktiva användare",
    activeAgreements: "Aktiva avtal",
    unsubscribedAgreements: "Uppsagda avtal",
    activeOrUnsubscribedAgreements: "Aktiva eller uppsagda avtal",
  },
} as const satisfies TranslationSchema<typeof no>;

export const defaultNS = "translation";

export const resources = {
  no: {
    translation: no,
  },
  en: {
    translation: en,
  },
  sv: {
    translation: sv,
  },
} as const;

export const supportedLanguages = ["no", "en", "sv"] as const;

export type AppLanguage = (typeof supportedLanguages)[number];

// Locales for Intl formatting of dates and numbers.
export const intlLocales: Record<AppLanguage, string> = {
  no: "nb-NO",
  en: "en-GB",
  sv: "sv-SE",
};
