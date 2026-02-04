# NativeWind + React Native Reusables Migration Plan

**Status**: In Progress  
**Branch**: (migration branch)  
**Estimated Effort**: 2-3 days  
**Complexity**: Low (~16 components)

---

## Overview

Migrate from React Native `StyleSheet` to NativeWind v4 (Tailwind CSS) for styling, and integrate React Native Reusables for accessible UI primitives.

### Target Platforms
- Electron/Web (Windows tablets - primary)
- iOS
- Android

### Benefits
- Utility-first CSS with Tailwind classes
- Consistent design tokens across platforms
- Accessible UI primitives (Dialog, Select, Toast)
- Faster UI development with familiar Tailwind syntax

---

## Migration Steps

### Phase 1: Setup & Configuration

- [x] **1.1** Install NativeWind v4 and Tailwind CSS dependencies
  ```bash
  npm install nativewind tailwindcss --legacy-peer-deps
  ```

- [x] **1.2** Install React Native Reusables primitives
  ```bash
  npm install @rn-primitives/slot @rn-primitives/dialog @rn-primitives/select @rn-primitives/toast --legacy-peer-deps
  ```

- [x] **1.3** Create `tailwind.config.ts` with existing theme tokens
  - Migrated `src/shared/theme/colors.ts` → `theme.extend.colors`
  - Migrated `src/shared/theme/spacing.ts` → `theme.extend.spacing`
  - Migrated `src/shared/theme/typography.ts` → `theme.extend.fontSize`

- [x] **1.4** Configure Metro bundler (`metro.config.js`)
  - Added `withNativeWind()` wrapper

- [x] **1.5** Configure Babel (`babel.config.js`)
  - Added `nativewind/babel` preset

- [x] **1.6** Update Webpack for Electron (`webpack.config.js`)
  - ~~Added CSS loader with postcss-loader~~ (caused Electron SIGSEGV crash)
  - **Solution**: Build Tailwind CSS to static file (`public/tailwind.css`)
  - Added `build:css` and `watch:css` npm scripts
  - Load CSS via `<link>` tag in `public/index.html`
  - Updated `electron:dev` to run CSS watcher concurrently

- [x] **1.7** Create `global.css` with Tailwind directives
  - Added imports to `index.js` and `index.web.js`
  - Added NativeWind types to `global.d.ts`

- [x] **1.8** Create `cn` utility (`src/shared/utils/cn.ts`)
  - Installed `clsx` and `tailwind-merge`

### Phase 2: Migrate Shared UI Components

- [x] **2.1** `src/shared/ui/Button/Button.tsx` → className props with variants
- [x] **2.2** `src/shared/ui/Card/Card.tsx` → className props
- [x] **2.3** `src/shared/ui/Header/Header.tsx` → className props

### Phase 3: Migrate Feature Components

- [ ] **3.1** `src/features/home/components/VesselInfo.tsx`
- [ ] **3.2** `src/features/home/components/ActionButtons.tsx`
- [ ] **3.3** `src/features/home/components/RecentLogs.tsx`
- [ ] **3.4** `src/features/home/components/AlarmTable.tsx`
- [ ] **3.5** `src/features/operators/components/AddOperatorModal.tsx` → Replace with Reusables Dialog
- [ ] **3.6** `src/features/operators/components/OperatorSelect.tsx` → Replace with Reusables Select
- [ ] **3.7** `src/features/loading/MultiStepLoadingScreen.tsx`

### Phase 4: Migrate Screens

- [ ] **4.1** `src/features/home/screens/HomeScreen.tsx`
- [ ] **4.2** `src/features/auth/screens/LoginScreen.tsx`
- [ ] **4.3** `src/features/settings/screens/SettingsScreen.tsx`
- [ ] **4.4** `src/features/walkaround/screens/WalkaroundInitScreen.tsx`
- [ ] **4.5** `src/features/operators/screens/ManageOperatorsScreen.tsx`

### Phase 5: Cleanup & Validation

- [ ] **5.1** Remove old `StyleSheet` imports where no longer needed
- [ ] **5.2** Remove legacy theme files if fully migrated to Tailwind config
- [ ] **5.3** Test Electron build
- [ ] **5.4** Test iOS build
- [ ] **5.5** Test Android build
- [ ] **5.6** Update TypeScript types for className props

---

## Future Cleanup (Separate PR)

- [ ] Remove `react-native-windows` dependency from `package.json`
- [ ] Delete `windows/` directory
- [ ] Remove Windows-specific configs from `metro.config.js`

---

## Reference Links

- [NativeWind v4 Docs](https://www.nativewind.dev/)
- [React Native Reusables](https://reactnativereusables.com/docs)
- [Tailwind CSS](https://tailwindcss.com/docs)

---

## Notes

- Existing theme tokens in `src/shared/theme/` align well with Tailwind design system
- No external UI library conflicts (currently using custom StyleSheet components)
- Primary target is Electron/Web for Windows tablets
