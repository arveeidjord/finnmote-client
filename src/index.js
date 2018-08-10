require('./main.css');
// require('./main.scss');
var Elm = require('./Main.elm');

var root = document.getElementById('root');

var app = Elm.Main.embed(root, JSON.parse(localStorage.getItem("access_token")));

app.ports.put.subscribe(function (item) {
    localStorage.setItem("access_token", JSON.stringify(item));
    app.ports.get.send(JSON.parse(localStorage.getItem("access_token")));
});


if (module.hot) {
    module.hot.accept();
}