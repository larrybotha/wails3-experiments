import { Events } from "@wailsio/runtime";
import { GreetService } from "./bindings/changeme";
import { Elm } from "./src/Main.elm";

// Initialize the Elm app
const elmApp = Elm.Main.init({
  node: document.getElementById("app"),
});

// Connect Elm port to Wails Greet service
elmApp.ports.greet.subscribe((name) => {
  GreetService.Greet(name)
    .then((result) => {
      elmApp.ports.greetResult.send(result);
    })
    .catch((err) => {
      console.error(err);
    });
});

// Connect Wails time event to Elm
Events.On("time", (time) => {
  elmApp.ports.timeEvent.send(time.data[0]);
});
