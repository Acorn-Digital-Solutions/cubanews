---
name: zero-slop-ai-pipeline
description: Step-by-step guide for implementing the zero-AI-slop quality pipeline in a React Native / TypeScript project
version: 1.0.0
license: MIT
---

## What This Skill Covers

This skill implements the **Zero-AI-Slop Pipeline** — a layered quality gate that ensures
AI-generated code is caught and rejected before it reaches production.

The pipeline has been fully implemented in this project. Use this guide to replicate it in
new projects.

The protection layers listed below are ordered by **execution stage** — from the earliest
(developer's machine, on save / on commit) to the latest (CI Phase 3, after every other
gate has passed):

| Stage       | Layer                  | Tool                         | Catches                                   |
| ----------- | ---------------------- | ---------------------------- | ----------------------------------------- |
| Commit-time | TypeScript strict mode | `tsc`                        | Wrong types, implicit any, null bugs      |
| Commit-time | Linting + formatting   | ESLint + Prettier + Husky    | Style, dead code, commit-time enforcement |
| CI Phase 1  | Unit tests             | Jest + React Testing Library | Logic bugs                                |
| CI Phase 2  | Mutation testing       | Stryker                      | Fake / useless tests                      |
| CI Phase 2  | Contract tests         | Zod schemas                  | Data shape drift between app and backend  |
| CI Phase 2  | Architecture rules     | dependency-cruiser           | Broken module boundaries                  |
| CI Phase 3  | E2E tests              | Maestro (via EAS)            | Navigation, state, real user flows        |

---

## Step 1 — Strict TypeScript

Add these settings to `tsconfig.json`. They eliminate 60–70% of AI-generated bugs:

```json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true
  }
}
```

Add a `type-check` script to `package.json`:

```json
"type-check": "tsc --noEmit"
```

---

## Step 2 — ESLint + Prettier + Pre-Commit Enforcement

### Install tools

```bash
npm install --save-dev eslint prettier husky lint-staged
```

### Configure lint-staged in `package.json`

```json
"lint-staged": {
  "*.{ts,tsx}": ["eslint --fix", "prettier --write"],
  "*.{json,md}": ["prettier --write"]
}
```

### Add scripts

```json
"lint": "eslint . --ext .ts,.tsx",
"lint:fix": "eslint . --ext .ts,.tsx --fix",
"format": "prettier --write '**/*.{ts,tsx,json,md}'",
"format:check": "prettier --check '**/*.{ts,tsx,json,md}'"
```

### Set up Husky pre-commit hook

```bash
npx husky init
```

`.husky/pre-commit`:

```sh
#!/bin/sh
npx lint-staged
npm run deps:check
```

👉 Result: AI-generated code that fails lint or type checks never reaches Git.

---

## Step 3 — Unit Tests with Jest

### Install

```bash
npm install --save-dev jest @types/jest @testing-library/react-native @testing-library/jest-native
```

### Scripts

```json
"test": "jest",
"test:watch": "jest --watch",
"test:coverage": "jest --coverage"
```

### Test structure rules

- Place tests in `__tests__/` folders next to the module they test.
- Tests must test **behavior**, not implementation.
- Name test files `*.test.ts` or `*.test.tsx`.

---

## Step 4 — Mutation Testing with Stryker

Mutation testing is the **anti-AI-slop killer**. Stryker intentionally breaks your code and
verifies that tests actually fail. If tests pass after the code is broken → the tests are useless.

### Install

```bash
npm install --save-dev @stryker-mutator/core @stryker-mutator/jest-runner @stryker-mutator/typescript-checker
```

### Script

```json
"test:mutate": "npx stryker run --ignoreStatic"
// --ignoreStatic skips mutants in static class members and module-level constants
// that Jest cannot execute in isolation. Remove the flag to run a stricter scan.
```

### `stryker.config.json`

```json
{
  "$schema": "https://raw.githubusercontent.com/stryker-mutator/stryker/master/packages/core/schema/stryker-core.schema.json",
  "mutate": [
    "component/**/*.ts",
    "component/**/*.tsx",
    "!component/**/__tests__/**",
    "!component/**/*.test.{ts,tsx}",
    "!component/**/index.ts"
  ],
  "testRunner": "jest",
  "jest": { "configFile": "jest.config.cjs" },
  "checkers": ["typescript"],
  "tsconfigFile": "tsconfig.json",
  "reporters": ["html", "clear-text", "progress", "json"],
  "htmlReporter": { "fileName": "reports/mutation/mutation-report.html" },
  "thresholds": { "high": 80, "low": 60, "break": 30 },
  "concurrency": 4,
  "timeoutMS": 60000
}
```

**Thresholds explained:**

- `high`: mutation score above this → green
- `low`: mutation score below this → yellow warning
- `break`: mutation score below this → pipeline fails

---

## Step 5 — Contract Testing with Zod

Contract tests protect against data shape drift between the frontend and backend (Firestore, REST API, etc.).
This project uses **Zod** schemas (not Pact) as the contract layer, which is lighter-weight and
sufficient for a Firebase-backed React Native app.

### Install

```bash
npm install zod
```

### Pattern: Create a `Contracts.ts` file in the Core layer

```ts
import { z } from "zod";

// Define schemas that mirror your backend/Firestore document shapes exactly
export const ItemContract = z
  .object({
    name: z.string().min(1),
    value: z.string(),
    timestamp: z.number(),
    userId: z.string().min(1),
    encrypted: z.boolean().optional(),
  })
  .strict();

// Export validators — these are what you call in tests and optionally at runtime
export function validateItem(data: unknown) {
  return ItemContract.parse(data);
}
```

### Pattern: Write contract tests that prove consistency

Name contract test files `*.Contracts.test.ts` so they can be run separately:

```ts
// component/Core/__tests__/Contracts.test.ts
import { validateItem } from "../Contracts";
import { ZodError } from "zod";

describe("ItemContract", () => {
  it("accepts valid item", () => {
    expect(() =>
      validateItem({ name: "pw", value: "abc", timestamp: 1, userId: "u1" })
    ).not.toThrow();
  });
  it("rejects missing name", () => {
    expect(() =>
      validateItem({ value: "abc", timestamp: 1, userId: "u1" })
    ).toThrow(ZodError);
  });
  it("rejects wrong type for timestamp", () => {
    expect(() =>
      validateItem({
        name: "pw",
        value: "abc",
        timestamp: "2024",
        userId: "u1",
      })
    ).toThrow(ZodError);
  });
});
```

### Script to run only contract tests

```json
"test:contracts": "jest --testPathPattern='Contracts\\.test'"
```

---

## Step 6 — Architecture Enforcement with dependency-cruiser

dependency-cruiser enforces module boundary rules. AI tends to write "quick fixes" that
violate layer boundaries — this catches them automatically.

### Install

```bash
npm install --save-dev dependency-cruiser
```

### Script

```json
"deps:check": "depcruise --config .dependency-cruiser.cjs component App.tsx",
"deps:graph": "mkdir -p reports && depcruise --config .dependency-cruiser.cjs --output-type dot component App.tsx | dot -T svg > reports/dependency-graph.svg"
```

### `.dependency-cruiser.cjs` — core rules pattern

```js
module.exports = {
  forbidden: [
    // UI screens cannot import the database/storage layer directly
    {
      name: "no-direct-db-from-screens",
      severity: "error",
      from: { path: "^component/(HomeScreen|ProfileScreen)" },
      to: { path: "@react-native-firebase/firestore" },
    },
    // No circular dependencies
    {
      name: "no-circular",
      severity: "error",
      from: {},
      to: { circular: true },
    },
    // Core/data-model layer must stay pure (no side effects)
    {
      name: "datamodel-must-be-pure",
      severity: "error",
      from: { path: "^component/Core/DataModel" },
      to: { path: "(Core/Storage|Core/Security|@react-native-firebase)" },
    },
    // Warn about orphan modules (dead code AI might generate)
    {
      name: "no-orphans",
      severity: "warn",
      from: {
        orphan: true,
        pathNot: [
          "(^|/)\\.[^/]+\\.(cjs|mjs|js|json)$",
          "\\.d\\.ts$",
          "(^|/)__tests__/",
          "^App\\.tsx$",
          "^index\\.js$",
        ],
      },
      to: {},
    },
  ],
  options: {
    // Paths here are treated as regular expressions, so '.' must be escaped as '\\.'.
    doNotFollow: {
      path: ["node_modules", "android", "ios", "\\.git", "coverage"],
    },
    exclude: { path: ["__tests__", "\\.test\\.tsx?$"] },
    tsPreCompilationDeps: true,
    tsConfig: { fileName: "tsconfig.json" },
  },
};
```

**Add `deps:check` to the pre-commit hook** so architecture violations are caught before commit.

---

## Step 7 — E2E Testing with Maestro

Maestro is the recommended E2E tool for Expo projects. It integrates with EAS for cloud execution.

### Install Maestro CLI (local)

```bash
curl -Ls "https://get.maestro.mobile.dev" | bash
```

### Write flows in `.maestro/` directory

```yaml
# .maestro/home_add_item.yml
appId: com.yourapp.id
---
- launchApp
- assertVisible: "Add Item"
- tapOn: "Add Item"
- inputText:
    id: "item-name-input"
    text: "My Secret"
- tapOn: "Save"
- assertVisible: "My Secret"
```

### Run locally

```bash
maestro test .maestro/home_add_item.yml
```

### Run on EAS (CI)

Create `.eas/workflows/e2e-test-android.yml` and trigger with:

```bash
npx eas-cli@latest workflow:run .eas/workflows/e2e-test-android.yml --non-interactive
```

---

## Step 8 — GitHub Actions CI/CD Pipeline

The pipeline must run in **three phases**. Merge is only allowed if all three pass.

```
Phase 1 — Fast checks (1–2 min): TypeScript · ESLint · Unit tests
Phase 2 — Deep checks (5–10 min): Mutation testing · Architecture · Contract tests
Phase 3 — Real user simulation: Maestro E2E tests
```

### `.github/workflows/push.yml` structure

```yaml
on:
  push:
    branches: [master, main]
  pull_request:
    branches: [master, main]

jobs:
  # ── Phase 1 ──────────────────────────────────────────────
  type-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: "22"
      - run: npm ci
      - run: npm run type-check

  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: "22"
      - run: npm ci
      - run: npm run lint

  unit-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: "22"
      - run: npm ci
      - run: npm test -- --coverage --watchAll=false

  # ── Phase 2 (needs Phase 1) ───────────────────────────────
  mutation-test:
    needs: [type-check, lint, unit-tests]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: "22"
      - run: npm ci
      - run: npm run test:mutate -- --reporters clear-text,json

  static-analysis:
    needs: [type-check, lint, unit-tests]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: "22"
      - run: npm ci
      - run: npm run deps:check

  contract-tests:
    needs: [type-check, lint, unit-tests]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: "22"
      - run: npm ci
      - run: npm run test:contracts -- --watchAll=false

  # ── Phase 3 (needs Phase 2) ───────────────────────────────
  # E2E tests run only on the default branch. PRs get full coverage from
  # Phases 1 and 2; E2E is reserved for post-merge validation to keep
  # PR feedback cycles fast and to avoid consuming EAS build minutes on every PR.
  e2e-test:
    needs: [mutation-test, static-analysis, contract-tests]
    if: github.ref == 'refs/heads/master' || github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: "22"
      - run: npm ci
      - run: npx eas-cli@latest workflow:run .eas/workflows/e2e-test-android.yml --non-interactive
```

---

## Implementation Checklist

Use this checklist when setting up the pipeline in a new project:

- [ ] Add strict TypeScript settings to `tsconfig.json`
- [ ] Add `type-check` script to `package.json`
- [ ] Install and configure ESLint + Prettier
- [ ] Install Husky and set up `pre-commit` hook with `lint-staged` and `deps:check`
- [ ] Install Jest; write unit tests in `__tests__/` folders with behavior-focused assertions
- [ ] Add `test:coverage` script
- [ ] Install Stryker; configure `stryker.config.json` with thresholds (`break: 30`)
- [ ] Add `test:mutate` script
- [ ] Install Zod; create `Contracts.ts` in the Core layer with schema validators
- [ ] Write `Contracts.test.ts` covering valid shapes, missing fields, type errors, and round-trips
- [ ] Add `test:contracts` script
- [ ] Install dependency-cruiser; create `.dependency-cruiser.cjs` with layer boundary rules
- [ ] Add `deps:check` script; add it to the pre-commit hook
- [ ] Write Maestro flow files in `.maestro/`
- [ ] Create `.github/workflows/push.yml` with 3-phase pipeline

---

## What Each Layer Catches

| Problem                            | Where it gets caught   |
| ---------------------------------- | ---------------------- |
| Wrong types / null deref           | TypeScript strict mode |
| Dead code, style violations        | ESLint                 |
| Logic bugs                         | Unit tests             |
| Fake / coverage-padding tests      | Mutation testing       |
| API / Firestore schema drift       | Contract tests (Zod)   |
| Broken module boundaries           | dependency-cruiser     |
| Navigation / state / real-use bugs | Maestro E2E            |

---

## What Was NOT Implemented in This Project

The plan mentioned these tools. They were evaluated and either replaced or deferred:

| Plan Item                    | Status   | Notes                                                                                   |
| ---------------------------- | -------- | --------------------------------------------------------------------------------------- |
| Pact (contract testing)      | Replaced | Zod schemas are sufficient for a Firebase-backed app without a separate backend team    |
| SonarQube / Qodana           | Deferred | dependency-cruiser covers architecture rules; SonarQube adds value at larger team sizes |
| Sentry (error monitoring)    | Deferred | Useful for production; add when the app has real users                                  |
| Datadog / New Relic          | Deferred | Add for performance monitoring at scale                                                 |
| LaunchDarkly (feature flags) | Deferred | Add when shipping AI-generated features that need instant kill-switches                 |
