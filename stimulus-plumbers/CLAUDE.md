# Stimulus Plumbers

## Project Overview

**@stimulus-plumbers/controllers** is a library of accessible Stimulus controllers that follow WCAG 2.1+ standards. This package provides semantically correct, keyboard-navigable UI components built on the Hotwire Stimulus framework.

## Folder Structure

```
stimulus-plumbers/
├── src/
│   ├── controllers/                 # Stimulus controllers
│   │   ├── calendar-month_controller.js
│   │   ├── form-field_controller.js
│   │   ├── panner_controller.js
│   │   ├── popover_controller.js
│   │   └── visibility_controller.js
│   ├── plumbers/                    # Core plumber utilities
│   │   ├── plumber/                 # Base plumber classes
│   │   │   ├── index.js
│   │   │   └── support.js
│   │   ├── calendar.js
│   │   ├── content-loader.js
│   │   ├── dismisser.js
│   │   ├── flipper.js
│   │   ├── shifter.js
│   │   └── visibility.js
│   ├── aria.js                      # ARIA utilities
│   ├── focus.js                     # Focus management
│   ├── keyboard.js                  # Keyboard event handlers
│   └── index.js                     # Main entry point
├── tests/
│   ├── unit/
│   │   └── plumbers/
│   │       ├── plumber/
│   │       │   ├── index.test.js
│   │       │   └── support.test.js
│   │       ├── calendar.test.js
│   │       ├── content-loader.test.js
│   │       ├── dismisser.test.js
│   │       ├── flipper.test.js
│   │       ├── shifter.test.js
│   │       └── visibility.test.js
│   └── setup.js
├── package.json
├── vite.config.js
├── .eslintrc.json
├── .prettierrc.json
├── .gitignore
└── README.md
```

## Setup & Development

### Prerequisites

- **Node.js** >= 18.0.0
- **npm** or **yarn** package manager

### Installation

```bash
# Install dependencies
npm install
```

### Development Commands

```bash
# Start development server
npm run dev

# Preview production build
npm run preview

# Run all tests
npm test

# Run tests with UI
npm run test:ui

# Run tests with coverage report
npm run test:coverage

# Lint code
npm run lint

# Format code (write changes)
npm run format:write

# Check code formatting (no changes)
npm run format:check
```

### Building for Production

```bash
# Build library
npm run build
```

**Build outputs:**
- `dist/stimulus-plumbers-controllers.es.js` - ES module format
- `dist/stimulus-plumbers-controllers.umd.js` - UMD format for browsers

### Package Configuration

**Package name:** `@stimulus-plumbers/controllers`
**Version:** `0.1.0`
**License:** MIT

**Peer Dependencies:**
- `@hotwired/stimulus` ^3.0.0 || ^2.0.0

**Key Dev Dependencies:**
- `vite` ^7.3.1 - Build tool and dev server
- `vitest` ^4.0.18 - Testing framework
- `@testing-library/dom` ^10.4.0 - DOM testing utilities
- `axe-core` ^4.10.2 - Accessibility testing
- `eslint` ^8.57.1 - Code linting
- `prettier` ^3.3.3 - Code formatting
- `jsdom` ^28.0.0 - DOM environment for testing

## Testing Guidelines

All components must include comprehensive tests:

### Required Test Coverage
- ✅ **Unit tests** using Vitest
- ✅ **Accessibility tests** using axe-core
- ✅ **Keyboard navigation tests** (Tab, Enter, Space, Escape, Arrows)
- ✅ **Focus management tests** (focus traps, restoration)
- ✅ **ARIA attribute tests** (roles, labels, states)

### Running Tests

```bash
# Run all tests once
npm test

# Run tests in watch mode
npm run test:ui

# Generate coverage report
npm run test:coverage
```

### Test Configuration

Tests are configured via `vite.config.js`:
- **Environment:** jsdom
- **Setup file:** `tests/setup.js`
- **Coverage provider:** v8
- **Coverage formats:** text, json, html

## Code Quality

### Linting

ESLint configuration in `.eslintrc.json`:
```bash
npm run lint
```

### Formatting

Prettier configuration in `.prettierrc.json`:
```bash
# Format all files
npm run format:write

# Check formatting without changes
npm run format:check
```

## Architecture

### Controllers
Stimulus controllers that provide high-level component behavior. Located in `src/controllers/`.

### Plumbers
Core utility classes that handle specific functionality (dismissal, positioning, visibility, etc.). Located in `src/plumbers/`.

### Utilities
Helper functions for:
- **ARIA** (`src/aria.js`) - ARIA attribute management, announcements
- **Focus** (`src/focus.js`) - Focus traps, restoration, focusable element detection
- **Keyboard** (`src/keyboard.js`) - Keyboard event handling, key detection

## Development Workflow

1. **Make changes** to source files in `src/`
2. **Run tests** to verify functionality: `npm test`
3. **Check linting**: `npm run lint`
4. **Format code**: `npm run format:write`
5. **Build**: `npm run build`
6. **Commit** changes following git conventions

## Accessibility Requirements

Every component MUST:
- ✅ Be fully keyboard navigable
- ✅ Have proper ARIA attributes
- ✅ Pass axe-core accessibility tests
- ✅ Work with screen readers
- ✅ Manage focus appropriately
- ✅ Support `prefers-reduced-motion`
- ✅ Have visible focus indicators
- ✅ Follow WCAG 2.1 Level AA standards

## Notes

- This library uses **native HTML5 first** - only use controllers when native elements have limitations
- Prefer `<details>` for disclosures, `<dialog>` for basic modals
- All code should be vanilla JavaScript for maximum compatibility
- Components are built to be modular and composable
