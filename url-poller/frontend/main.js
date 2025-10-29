import { Events } from "@wailsio/runtime";
import { URLPollerService } from "./bindings/changeme";
import { Elm } from "./src/Main.elm";

const elmApp = Elm.Main.init({
  node: document.getElementById("app"),
});

// Connect URL Poller service to Elm
elmApp.ports.pollStartEmitter.subscribe(async ({ url, durationSeconds }) => {
  try {
    const result = await URLPollerService.StartPolling(url, durationSeconds);

    elmApp.ports.pollStartReceiver.send(result);
  } catch (e) {
    console.error(e);
    elmApp.ports.pollStartReceiver.send("Error: " + e.message);
  }
});

elmApp.ports.pollStopEmitter.subscribe(async () => {
  try {
    const result = await URLPollerService.StopPolling();

    elmApp.ports.pollStopReceiver.send(result);
  } catch (e) {
    console.error(e);
    elmApp.ports.pollStopReceiver.send("Error: " + e.message);
  }
});

Events.On("pollResult", (result) => {
  const value = result.data[0];

  elmApp.ports.pollResultReceiver.send(value);
});
