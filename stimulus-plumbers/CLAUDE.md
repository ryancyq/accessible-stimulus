# Stimulus Plumbers

## Project Overview

**@stimulus-plumbers/controllers** is a library of accessible Stimulus controllers that follow WCAG 2.1+ standards. This package provides semantically correct, keyboard-navigable UI components built on the Hotwire Stimulus framework.

## Folder Structure

```
stimulus-plumbers/
├── src/
│   ├── controllers/                 # Stimulus controllers
│   │   ├── *_controller.js
│   ├── plumbers/                    # Core plumber utilities
│   │   ├── plumber/                 # Base plumber classes
│   │   │   ├── index.js
│   │   │   └── support.js
│   │   └── *.js
│   ├── aria.js                      # ARIA utilities
│   ├── focus.js                     # Focus management
│   ├── keyboard.js                  # Keyboard event handlers
│   └── index.js                     # Main entry point
├── tests/
│   ├── unit/
│   │   ├── controllers/
│   │   │   └── *.test.js
│   │   └── plumbers/
│   │       ├── plumber/
│   │       │   ├── *.test.js
│   │       └── *.test.js
│   └── setup.js
├── package.json
├── vite.config.js
├── .eslintrc.json
├── .prettierrc.json
├── .gitignore
└── README.md
```

### Prerequisites

- **Node.js** >= 18.0.0
- **npm** package manager

### CMD

```bash
npm install           # Install dependencies
npm run dev           # Start development server
npm run preview       # Preview production build
npm test              # Run all tests
npm run test:ui       # Run tests with UI
npm run test:coverage # Run tests with coverage report
npm run lint          # Lint code
npm run format:write  # Format code (write changes)
npm run format:check  # Check code formatting (no changes)
npm run build         # Build distribution
```

**Build outputs:**
- `dist/*.es.js` - ES module format
- `dist/*.umd.js` - UMD format for browsers

## Guidelines
- Follow WCAG 2.1 Level AA standards
- Support `prefers-reduced-motion`
- Work with screen readers
- **native HTML5 first** - only use controllers when native elements have limitations
- import statement should not ends with .js

- **Unit tests** using Vitest
- **Keyboard navigation tests** (Tab, Enter, Space, Escape, Arrows)
- **Focus management tests** (focus traps, restoration)
- **ARIA attribute tests** (roles, labels, states)
- **Lint tests** (eslint)
