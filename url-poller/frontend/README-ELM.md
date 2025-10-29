# Wails3 + Elm Template

This project has been bootstrapped to use Elm for the UI while maintaining the existing Go backend.

## Project Structure

```
frontend/
├── src/
│   └── Main.elm          # Main Elm application
├── elm.json              # Elm dependencies
├── vite.config.js        # Vite configuration with Elm plugin
├── main.js               # JavaScript interop layer
└── index.html            # HTML entry point
```

## How It Works

### Elm Application (`src/Main.elm`)
- Implements the UI using the Elm architecture (Model-View-Update)
- Defines ports for communicating with the Wails runtime
- Handles user interactions and state management

### JavaScript Interop (`main.js`)
- Initializes the Elm application
- Connects Elm ports to Wails bindings
- Handles communication between Elm and the Go backend

### Ports

The Elm app uses ports to communicate with Wails:

**Outgoing (Elm → JS → Wails):**
- `greet : String -> Cmd msg` - Sends a name to the Greet service

**Incoming (Wails → JS → Elm):**
- `greetResult : (String -> msg) -> Sub msg` - Receives greeting results
- `timeEvent : (String -> msg) -> Sub msg` - Receives time updates

## Development

Run the development server:
```bash
task dev
```

The Wails bindings are auto-generated in `frontend/bindings/` when you run dev mode.

## Building

Build for production:
```bash
task build
```

## Adding Elm Dependencies

```bash
cd frontend
npx elm install <package-name>
```

## Modifying the UI

Edit `frontend/src/Main.elm` to modify the Elm application. The Elm compiler will provide helpful error messages if something is wrong.
