import { App } from "astal/gtk3"
import style from "./scss/main.scss"
import Bar from "./widget/Bar"

App.start({
    css: style,
    main() {
        App.get_monitors().map(Bar)
    },
})
