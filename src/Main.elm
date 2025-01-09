module Main exposing (main)

import UI
import ECS

import Browser
import String exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Time
import Dict exposing (..)
import Platform.Sub exposing (none)

main : Program () Model Msg
main = Browser.element { 
        init = init, update = update, view = view, subscriptions = subscriptions
    }

type alias Model = { 
        tick: Int, paused: Bool, 
        entities: List ECS.Entity,
        width: Float, height: Float
    }
type Msg = Tick Time.Posix | TogglePause

init : () -> (Model, Cmd Msg)
init _ = (Model 0 False [makeShape 10 11 -1 -1 "square"] 500 500, Cmd.none)

subscriptions : Model -> Sub Msg
subscriptions {paused} = if not paused then Time.every 30 Tick else Sub.none

update : Msg -> Model -> (Model, Cmd Msg)
update msg ({tick, paused, entities} as model) = case msg of
    Tick _ -> ({ model | tick = tick + 1, entities = applySystems model entities }, Cmd.none)
    TogglePause -> ({ model | paused = not paused }, Cmd.none)

view : Model -> Html Msg
view model = UI.fullscreen 
    <| div 
        [ 
            style "width" "100%", style "height" "100%",
            style "position" "relative"
        ] 
        ((UI.centered 
            <| UI.optionCard [ UI.Clickable (if model.paused then "Play" else "Pause") TogglePause UI.Default ]
            <| text ("Tick: " ++ String.fromInt model.tick ))
        :: List.map viewEntity model.entities)

viewEntity : ECS.Entity -> Html msg
viewEntity entity = div
    [
        style "width" "25px", style "height" "25px",
        style "position" "absolute", 
        style "top" (String.fromFloat (ECS.nget "y" entity) ++ "px"),
        style "left" (String.fromFloat (ECS.nget "x" entity) ++ "px"),
        style "border" "1px solid black", style "background-color" "steelblue"
    ] []


makeShape : Float -> Float -> Float -> Float -> String -> ECS.Entity
makeShape x y vx vy shape = Dict.fromList 
    [
        ("shape", ECS.StringValue shape),
        ("x", ECS.NumValue x), ("y", ECS.NumValue y),
        ("vx", ECS.NumValue vx), ("vy", ECS.NumValue vy)
    ]

applySystems : ECS.System Model
applySystems model entities = moveShapes model entities 
    |> bounceShapes model 

bounceShapes : ECS.System Model
bounceShapes model entities = List.map (\ e -> bounceShape model e) entities
bounceShape : Model -> ECS.Entity -> ECS.Entity
bounceShape {width, height} entity = 
    if ECS.hasComponents ["x", "y", "vx", "vy"] entity then
        if ECS.nget "x" entity <= 0 || ECS.nget "x" entity >= width then
            ECS.nset "vx" (-1 * (ECS.nget "vx" entity)) entity
        else 
            if ECS.nget "y" entity <= 0 || ECS.nget "y" entity >= height then
                ECS.nset "vy" (-1 * (ECS.nget "vy" entity)) entity
            else 
                entity
    else 
        entity


moveShapes : ECS.System Model
moveShapes _ entities = List.map moveShape entities
moveShape : ECS.Entity -> ECS.Entity
moveShape entity = 
    if ECS.hasComponents ["x", "y", "vx", "vy"] entity then
        ECS.nset "x" ((ECS.nget "x" entity) + (ECS.nget "vx" entity)) entity
        |> ECS.nset "y" ((ECS.nget "y" entity) + (ECS.nget "vy" entity))
    else 
        entity
