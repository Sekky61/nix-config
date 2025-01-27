import { App } from "astal/gtk3";
import style from "./scss/main.scss";
import Applauncher from "./windows/AppLauncher";
import Bar, { BarOrientation, handleBarRequest } from "./windows/Bar";
import CheatSheet from "./windows/CheatSheet";
import SessionWindow from "./windows/Session";

function requestHandler(request: string, res: (response: any) => void) {
  let resp: string;
  switch (request) {
    case "bar-vertical":
      resp = handleBarRequest({ orientation: BarOrientation.VERTICAL });
      break;
    case "bar-horizontal":
      resp = handleBarRequest({ orientation: BarOrientation.HORIZONTAL });
      break;
    case "bar-toggle":
      resp = handleBarRequest({ orientation: BarOrientation.TOGGLE });
      break;
    default:
      resp = "unknown command";
  }
  res(resp);
}

App.start({
  css: style,
  main() {
    App.get_monitors().map(Bar);
    Applauncher();
    SessionWindow();
    CheatSheet();
  },
  requestHandler,
});
