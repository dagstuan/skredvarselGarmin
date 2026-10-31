# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the frontend for **Skredvarsel for Garmin** - a subscription-based web application that delivers avalanche warnings (Skredvarsel from Varsom and Lavinprognoser) to Garmin smartwatches. Built as a React SPA with TypeScript, Vite, and React Router v7. The site is available in Norwegian (default), English and Swedish.

**Tech Stack:**

- React 19 + TypeScript + Vite
- TanStack React Query v5 (state management)
- Tailwind CSS v4 + Base UI (styling)
- React Router v7 (routing with lazy loading)
- i18next + react-i18next (translations)
- pnpm 12 (package manager)

**Backend:** ASP.NET server at `https://localhost:8080` (proxied via Vite)

## Development Commands

```bash
# Install dependencies (only pnpm allowed via preinstall hook)
pnpm install

# Start dev server (runs on https://localhost:5173)
pnpm dev

# Build for production
pnpm build

# Preview production build
pnpm preview

# Type checking
pnpm check:types

# Format code
pnpm fix:prettier

# Check formatting
pnpm check:prettier

# Run all checks (types + prettier)
pnpm check
```

## Architecture Overview

### Routing & Page Structure

**Routing Pattern:** Modals as nested routes

- Root route renders `<App />` wrapper (Nav + Footer)
- Child routes render as overlay modals/drawers while keeping FrontPage visible
- Uses lazy loading for all pages via `lazy: () => import()`

**Localized routes:** Defined in [src/routes.ts](src/routes.ts) and registered in [src/main.tsx](src/main.tsx).

- Norwegian has no prefix, English uses `/en`, Swedish uses `/sv`
- Each route has a key (`AppRouteKey`) and one path segment in `routeSegments`. The segment is the same in every language; only the prefix differs (e.g. `/faq`, `/en/faq`, `/sv/faq`).
- `createLanguageRoutes()` in `main.tsx` generates the same routes for each language. Add new routes to `modalRoutes` or `pageRoutes` there, and their segment to `routeSegments`.
- Every route sets `handle: { routeKey }` so the current route can be resolved with `useCurrentRouteKey()`
- **The URL is the source of truth for the language.** `<LanguageProvider>` picks an i18next instance for the URL's language during render (one cloned instance per language), so there is no global language to keep in sync. Never call `i18n.changeLanguage()`; change the URL instead. There is no stored language preference.

`account`, `subscribe`, `addwatch` and `login` are modals nested under the home route; `faq`, `salesconditions`, `privacy` and `admin` are full pages.

The watch apps and the backend build URLs as language prefix + segment, e.g. `/sv/addwatch?watchKey=...`. Don't rename a segment without updating them and adding a redirect.

Old Norwegian paths `/minSide`, `/salgsbetingelser` and `/personvern` redirect to their current routes.

**Building links:** Never hardcode paths. Use the helpers from `routes.ts`:

```typescript
const pathFor = usePathForCurrentLanguage();
<RouterLink to={pathFor("faq", { hash: "vippslogin" })} />

// Links to backend endpoints that redirect back to the frontend (payment, Stripe portal).
// Adds ?lang= so the backend can redirect to the localized route.
const language = useCurrentLanguage();
<a href={buildBackendUrl("/createStripeSubscription", language, { watchKey })} />
```

**Modal/Drawer Closing Pattern:**

```typescript
const { isClosing, onClose } = useNavigateOnClose("home") // takes a route key
<Drawer open={shouldOpen && !isClosing} onOpenChange={(open) => !open && onClose()}>
```

The `isClosing` flag triggers the close animation before navigation.

### Translations (i18n)

- Setup in [src/i18n/index.ts](src/i18n/index.ts), strings in [src/i18n/resources.ts](src/i18n/resources.ts). Long page content (FAQ, privacy, sales conditions, SEO) lives in [src/i18n/resources/](src/i18n/resources/).
- Norwegian (`no`) is the reference language. `en` and `sv` are typed with `satisfies TranslationSchema<typeof no>`, so a missing or extra key is a type error. Add new keys to all three languages.
- Use the selector syntax (typed via [src/i18n.d.ts](src/i18n.d.ts)):

```typescript
const { t } = useTranslation();
t(($) => $.account.watches.added);
t(($) => $.account.subscription.renewsOn, { date: formattedDate });
```

- Format dates and numbers with `Intl` and `intlLocales[language]` from `i18n/resources.ts`, not fixed patterns.
- Page title, all SEO, Open Graph and Twitter meta tags, canonical and `hreflang` links are rendered by the `<RouteMetadata />` component, using React 19's support for `<title>`, `<meta>` and `<link>` in components. Don't add per-page tags to `index.html`; React can't replace them, so they would show up twice.
- Don't show error text from the backend directly; it isn't translated. Map status codes to translated strings instead (see `isWatchNotFoundError` in `useWatches.ts`).

### State Management

**All state is managed via TanStack React Query** - no Redux, Context, or global state.

**Key Query Keys:**

- `["user"]` - User data (infinite staleTime, no retry)
- `["watches"]` - List of user's Garmin watches
- `["subscription"]` - User's subscription details

**Pattern:**

```typescript
// Query (GET)
const useWatches = () =>
  useQuery({
    queryKey: ["watches"],
    queryFn: async () => getWatches(),
  });

// Mutation (POST/PUT/DELETE)
const useAddWatch = (onSuccess?: () => void) => {
  const { t } = useTranslation();

  return useMutation({
    mutationFn: addWatch,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["watches"] });
      toast.success(t(($) => $.account.watches.added));
      onSuccess?.();
    },
  });
};
```

### API Layer

**Axios Instance:** `src/api.ts`

```typescript
const api = axios.create({
  baseURL: "/",
  timeout: 30000,
});
```

**Backend Proxy:** Requests to `/api/*`, `/vipps*`, `/google*`, `/facebook*`, `/stripe*`, `/email*`, `/logout` and `/createVippsAgreement` / `/createStripeSubscription` are proxied to `https://localhost:8080`

**CSRF Protection:** Custom header `X-CSRF: 1` is sent with user API calls

**Key Endpoints:**

- `GET /api/user` - Fetch current user
- `GET /api/watches` - List user's watches
- `POST /api/watches/:watchKey` - Add a watch (400 if no watch has the code)
- `DELETE /api/watches/:watchId` - Remove a watch
- `GET /api/subscription` - Get subscription status
- `DELETE /api/vippsAgreement` - Cancel Vipps subscription
- `PUT /api/vippsAgreement/reactivate` - Reactivate Vipps
- `POST /email-login-send?email=...&returnUrl=...` - Send magic link. The email's language is taken from `returnUrl`.
- `/createVippsAgreement`, `/createStripeSubscription`, `/stripe-customer-portal` - accept `?lang=` and `?watchKey=`; build these links with `buildBackendUrl`
- OAuth: `/google-login`, `/facebook-login` with `?returnUrl=`

`returnUrl` must be a local path (starting with a single `/`); the backend rejects or ignores anything else.

### Custom Hooks (`src/hooks/`)

API calls are abstracted into custom hooks:

- `useUser()` - Query user data
- `useWatches()`, `useAddWatch()`, `useRemoveWatch()` - Manage watches
- `useSubscription()`, `useStopVippsAgreement()`, `useReactivateVippsAgreement()` - Manage subscriptions
- `useEmailLogin()` - Handle email auth flow with local state
- `useAdminData()` - Admin statistics
- `useScrollToTopOnNavigate()` - Auto-scroll on route change
- `useNavigateOnClose()` - Navigate when modal/drawer closes (with animation delay)
- `useNavigateToAccountIfLoggedIn()` - Redirect if already logged in

Route and language hooks (`useCurrentLanguage()`, `useCurrentRouteKey()`, `usePathForCurrentLanguage()`) live in `src/routes.ts`.

### Component Organization

**Structure:**

```
src/
├── Components/
│   ├── AccountPage/         # Account management components
│   ├── Admin/               # Admin panel
│   ├── Buttons/             # Login and payment buttons (Google, Facebook, Vipps, Stripe)
│   ├── EmailLoginForm/      # Email authentication
│   ├── Icons/               # SVG icon components
│   ├── LoginModal/          # Login modal
│   ├── ui/                  # Base UI components (shadcn-style)
│   └── [Other components]   # Pages and shared components (Nav, Footer, LanguageSwitcher, ...)
├── Pages/                   # Route loaders (lazy imports)
├── hooks/                   # Custom React hooks
├── i18n/                    # i18next setup and translations
├── lib/                     # Utility functions (cn, toast)
├── api.ts                   # Axios instance
├── routes.ts                # Localized routes and link helpers
├── types.ts                 # TypeScript types
└── main.tsx                 # Entry point + routing
```

**Component Types:**

- **Presentational** - Reusable, data-driven (e.g., `Feature.tsx`)
- **Container** - Handle logic, use hooks (e.g., `AccountPage.tsx`)
- **UI Components** - Base UI wrappers in `ui/` folder (shadcn-style)
- **Page loaders** in `Pages/` - Simple re-exports for lazy loading

### Styling

**Tailwind CSS + Base UI Patterns:**

```typescript
// Utility function for conditional classes
import { cn } from "../lib/utils"
<div className={cn("base-classes", condition && "conditional-class")} />

// Responsive layouts
<div className="flex flex-col md:flex-row" />

// Responsive values
<p className="text-3xl md:text-4xl" />

// Gradient backgrounds
<div className="bg-linear-to-r from-black/35 to-transparent" />

// Animations with Tailwind
<div className={cn(
  "transition-all duration-200",
  isOpen ? "opacity-100 translate-y-0" : "opacity-0 translate-y-5"
)} />
```

**UI Components (`src/Components/ui/`):**

- `button.tsx` - Button with variants (default, green, blue, outline, ghost)
- `card.tsx` - Card container components
- `dialog.tsx` - Modal dialog (Base UI Dialog)
- `drawer.tsx` - Slide-out drawer (Base UI Dialog)
- `popover.tsx` - Popover (Base UI Popover), used by `LanguageSwitcher`
- `heading.tsx` - Typography headings with size variants
- `input.tsx` - Form input (Base UI Input)
- `label.tsx` - Form label
- `separator.tsx` - Horizontal/vertical divider
- `accordion.tsx` - Collapsible sections (Base UI Collapsible)
- `spinner.tsx` - Loading spinner
- `toast.tsx` - Toast renderer (Base UI Toast)

**Custom Tailwind Colors** (defined in `src/index.css`):

- `brand-green` - Green button color (#1F883D)
- `brand-blue` - Blue button color (#3182CE)
- `ciq-button` - Connect IQ store button color (#0e334c)

## Important Conventions

### Query String Parameters

- `?watchKey=xyz` - Auto-add watch after login
- `?returnUrl=/en/account` - Redirect destination after OAuth or email login (local paths only)
- `?lang=en` - Language for backend endpoints that redirect back to the frontend
- `?error=expired|invalid` - Set on the login route when a magic link can't be used

### Image Optimization

Uses `vite-imagetools` for responsive images:

```typescript
import imageMeta from "./image.jpg?w=400;800&format=webp;jpg&as=meta:width;height;src";
```

### HTTPS Development

Vite automatically generates ASP.NET dev certificates (`~/.aspnet/https/frontend.pem`) for HTTPS development.

### Payment Integrations

- **Vipps** - Norwegian mobile payment
- **Stripe** - Credit card (with Apple Pay, Google Pay). Checkout and the customer portal are shown in the page's language.
- **Email** - Magic link authentication

The price is in NOK for all languages.

### Toast Notifications

Uses a small wrapper around Base UI Toast in [src/lib/toast.ts](src/lib/toast.ts):

```typescript
import { toast } from "../lib/toast";
toast.success(t(($) => $.account.watches.added));
toast.error(t(($) => $.account.watches.addFailed));
```

## TypeScript Configuration

- **Strict mode enabled** - All strict checks on
- **No JS allowed** - `allowJs: false`
- **ESNext** - Latest ECMAScript features
- **JSX:** `react-jsx` (new JSX transform)

## Key Files

- [src/main.tsx](src/main.tsx) - Entry point, routing, providers
- [src/routes.ts](src/routes.ts) - Localized route segments and link helpers
- [src/i18n/resources.ts](src/i18n/resources.ts) - Translations
- [src/App.tsx](src/App.tsx) - Root component (Nav + Footer wrapper)
- [src/api.ts](src/api.ts) - Axios instance
- [src/types.ts](src/types.ts) - TypeScript type definitions
- [src/lib/utils.ts](src/lib/utils.ts) - Utility functions (cn for class merging)
- [vite.config.ts](vite.config.ts) - Vite configuration, proxy, HTTPS
- [src/index.css](src/index.css) - Tailwind setup and theme colors
- [package.json](package.json) - Dependencies and scripts

## Related Code Outside the Frontend

- **Watch apps** (`skredvarselGarmin/`, `skredvarselGarminDatafield/` in the repo root) open `/subscribe` and `/addwatch?watchKey=...` with a language prefix from the `FrontendUrl` string resource.
- **Backend** (`../Helpers/FrontendLanguage.cs`) maps `lang` to the path prefix when redirecting to the frontend, and picks the login email language.

## Norwegian Terms

Code and comments are in English, but many identifiers and texts come from the original Norwegian app:

- **Skredvarsel** - Avalanche warning
- **Varsom** - Norwegian avalanche warning service (varsom.no)
- **Lavinprognoser** - Swedish avalanche forecasts (lavinprognoser.se)
- **Abonnement** - Subscription
- **Klokke** - Watch
- **Min side** - My account/page
- **Salgsbetingelser** - Terms of sale
- **Personvern** - Privacy policy
