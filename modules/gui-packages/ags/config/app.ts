import { App } from "astal/gtk3";
import style from "./scss/main.scss";
import Bar from "./windows/Bar";
import Applauncher from "./windows/AppLauncher";
import SessionWindow from "./windows/Session";
import CheatSheet from "./windows/CheatSheet";

App.start({
  css: style,
  main() {
    App.get_monitors().map(Bar);
    Applauncher();
    SessionWindow();
    CheatSheet();
  },
});
