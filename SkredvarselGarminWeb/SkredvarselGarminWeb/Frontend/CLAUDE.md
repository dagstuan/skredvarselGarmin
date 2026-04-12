# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the frontend for **Skredvarsel for Garmin** - a subscription-based web application that delivers avalanche warnings (Skredvarsel from Varsom) to Garmin smartwatches. Built as a React SPA with TypeScript, Vite, and React Router v7.

**Tech Stack:**

- React 19 + TypeScript + Vite
- TanStack React Query v5 (state management)
- Tailwind CSS + Base UI (styling)
- React Router v7 (routing with lazy loading)
- pnpm 9.15.2 (package manager)

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

- Parent route (`/`) renders `<App />` wrapper (Nav + Footer)
- Child routes render as overlay modals/drawers while keeping FrontPage visible
- Uses lazy loading for all pages via `lazy: () => import()`

**Key Routes:**

- `/` - FrontPage (landing page)
- `/account` - AccountPage (drawer modal)
- `/subscribe` - BuySubscriptionModalPage (modal)
- `/addwatch` - AddWatchModalPage (modal)
- `/login` - LoginModalPage (modal)
- `/faq`, `/privacy`, `/salesconditions` - Full page routes
- `/admin` - AdminPage

**Modal/Drawer Closing Pattern:**

```typescript
const { isClosing, onClose } = useNavigateOnClose("/")
<Drawer open={shouldOpen && !isClosing} onOpenChange={(open) => !open && onClose()}>
```

The `isClosing` flag triggers the close animation before navigation.

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
const useAddWatch = (onSuccess?: () => void) =>
  useMutation({
    mutationFn: addWatch,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["watches"] });
      toast.success("Klokke lagt til!");
      onSuccess?.();
    },
  });
```

### API Layer

**Axios Instance:** `src/api.ts`

```typescript
const api = axios.create({
  baseURL: "/",
  timeout: 30000,
});
```

**Backend Proxy:** All requests to `/api/*`, `/vipps`, `/google`, `/facebook`, `/stripe`, `/email`, `/logout`, and `/create*` are proxied to `https://localhost:8080`

**CSRF Protection:** Custom header `X-CSRF: 1` is sent with user API calls

**Key Endpoints:**

- `GET /api/user` - Fetch current user
- `GET /api/watches` - List user's watches
- `POST /api/watches/:watchKey` - Add a watch
- `DELETE /api/watches/:watchId` - Remove a watch
- `GET /api/subscription` - Get subscription status
- `DELETE /api/vippsAgreement` - Cancel Vipps subscription
- `PUT /api/vippsAgreement/reactivate` - Reactivate Vipps
- `POST /email-login-send?email=...&returnUrl=...` - Send magic link
- OAuth: `/google`, `/facebook`, `/vipps`, `/stripe`

### Custom Hooks (`src/hooks/`)

All API calls are abstracted into custom hooks:

- `useUser()` - Query user data
- `useWatches()`, `useAddWatch()`, `useRemoveWatch()` - Manage watches
- `useSubscription()`, `useStopVippsAgreement()`, `useReactivateVippsAgreement()` - Manage subscriptions
- `useEmailLogin()` - Handle email auth flow with local state
- `useScrollToTopOnNavigate()` - Auto-scroll on route change
- `useNavigateOnClose()` - Navigate when modal/drawer closes (with animation delay)
- `useNavigateToAccountIfLoggedIn()` - Redirect if already logged in

### Component Organization

**Structure:**

```
src/
├── Components/
│   ├── AccountPage/         # Account management components
│   ├── Admin/               # Admin panel
│   ├── Buttons/             # Login buttons (Google, Facebook, Vipps, Stripe)
│   ├── EmailLoginForm/      # Email authentication
│   ├── Icons/               # SVG icon components
│   ├── LoginModal/          # Login modal
│   ├── ui/                  # Base UI components (shadcn-style)
│   └── [Other feature dirs] # Feature-specific components
├── Pages/                   # Route loaders (lazy imports)
├── hooks/                   # Custom React hooks
├── lib/                     # Utility functions (cn, etc.)
├── api.ts                   # Axios instance
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
- `heading.tsx` - Typography headings with size variants
- `input.tsx` - Form input (Base UI Input)
- `accordion.tsx` - Collapsible sections (Base UI Collapsible)
- `spinner.tsx` - Loading spinner

**Custom Tailwind Colors** (defined in `src/index.css`):

- `brand-green` - Green button color (#1F883D)
- `brand-blue` - Blue button color (#3182CE)
- `ciq-button` - Connect IQ store button color (#0e334c)

## Important Conventions

### Query String Parameters

- `?watchKey=xyz` - Auto-add watch after login
- `?returnUrl=/account` - Redirect destination after OAuth

### Image Optimization

Uses `vite-imagetools` for responsive images:

```typescript
import imageMeta from "./image.jpg?w=400;800&format=webp;jpg&as=meta:width;height;src";
```

### HTTPS Development

Vite automatically generates ASP.NET dev certificates (`~/.aspnet/https/frontend.pem`) for HTTPS development.

### Payment Integrations

- **Vipps** - Norwegian mobile payment
- **Stripe** - Credit card (with Apple Pay, Google Pay)
- **Email** - Magic link authentication

### Toast Notifications

Uses `sonner` for toast notifications:

```typescript
import { toast } from "sonner";
toast.success("Success message");
toast.error("Error message");
```

## TypeScript Configuration

- **Strict mode enabled** - All strict checks on
- **No JS allowed** - `allowJs: false`
- **ESNext** - Latest ECMAScript features
- **JSX:** `react-jsx` (new JSX transform)

## Key Files

- [src/main.tsx](src/main.tsx) - Entry point, routing, providers
- [src/App.tsx](src/App.tsx) - Root component (Nav + Footer wrapper)
- [src/api.ts](src/api.ts) - Axios instance
- [src/types.ts](src/types.ts) - TypeScript type definitions
- [src/lib/utils.ts](src/lib/utils.ts) - Utility functions (cn for class merging)
- [vite.config.ts](vite.config.ts) - Vite configuration, proxy, HTTPS
- [tailwind.config.js](tailwind.config.js) - Tailwind CSS configuration
- [package.json](package.json) - Dependencies and scripts

## Norwegian Language Notes

The app is in Norwegian. Common terms:

- **Skredvarsel** - Avalanche warning
- **Varsom** - Norwegian avalanche warning service (varsom.no)
- **Abonnement** - Subscription
- **Klokke** - Watch
- **Min side** - My account/page
- **Salgsbetingelser** - Terms of sale
- **Personvern** - Privacy policy
