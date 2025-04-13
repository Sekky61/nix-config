import { App } from "astal/gtk3";
import style from "./scss/main.scss";
import Applauncher from "./windows/AppLauncher";
import Bar, { BarOrientation, handleBarRequest } from "./windows/Bar";
import CheatSheet from "./windows/CheatSheet";
import SessionWindow from "./windows/Session";
import { NotificationPopupWindow } from "./windows/Notification";
import Indicator from "./windows/Indicator";
import { IndicatorService } from "./services/indicator";

const AgsRequests = {
  "bar-vertical": null,
  "bar-horizontal": null,
  "bar-toggle": null,
  "show-popup": null,
};

type AgsRequest = keyof typeof AgsRequests;

function requestHandler(request: AgsRequest, res: (response: unknown) => void) {
  const request_tokens = request.split(" ");
  let resp: string;
  switch (request_tokens[0] as AgsRequest) {
    case "bar-vertical":
      resp = handleBarRequest({ orientation: BarOrientation.VERTICAL });
      break;
    case "bar-horizontal":
      resp = handleBarRequest({ orientation: BarOrientation.HORIZONTAL });
      break;
    case "bar-toggle":
      resp = handleBarRequest({ orientation: BarOrientation.TOGGLE });
      break;
    case "show-popup":
      resp = IndicatorService.get_default().handlePopupRequest({
        args: request_tokens,
      });
      break;
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
    NotificationPopupWindow();
    Indicator();
  },
  requestHandler,
});
