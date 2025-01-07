Run a server that updates on browser refresh (like `python -m http.server`):

    > elm reactor
First time in a new directory, get started with:

    > elm init
Or add additional libraries like Time with

    > elm install elm/time

Compile into html:

    > elm make src/Main.elm

Compile into js:

    > elm make src/Main.elm --output=main.js
    
And then include the generated script in the <head> and attach it to 
the DOM similar to react: 

```
<div id="container"></div>
<script>
    var app = Elm.Main.init({
        node: document.getElementById('container')
    });
</script>
```


Pass values into init from javascript (like from a config) with the flags attribute:

```
var app = Elm.Main.init({
    node: document.getElementById('container'),
    flags: {width: 100, height: 100}
});
```
And then in elm:
```
type alias Flags = { width: Int, height: Int }

init : Flags -> ( Model, Cmd Msg )
init { width, height } =
    -- do stuff
```