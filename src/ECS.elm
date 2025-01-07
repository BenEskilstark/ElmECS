module ECS exposing (..)

import Browser
import String exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Time
import Dict exposing (..)
import Platform.Sub exposing (none)


type Component = StringValue String | NumValue Float
type alias Entity = Dict String Component

type alias System = List Entity -> List Entity
hasComponents : List String -> Entity -> Bool
hasComponents components entity = List.all (\ a -> member a entity) components


nget : String -> Entity -> Float
nget key entity = case Dict.get key entity of 
    Nothing -> 0
    Just val -> case val of 
        StringValue _ -> 0
        NumValue n -> n

nset : String -> Float -> Entity -> Entity
nset key value entity = Dict.update key 
    (\n -> case n of 
        Nothing -> Just (NumValue value)
        Just _ -> Just (NumValue value)
    ) entity


sget : String -> Entity -> String
sget key entity = case Dict.get key entity of 
    Nothing -> ""
    Just val -> case val of 
        NumValue _ -> ""
        StringValue n -> n

sset : String -> String -> Entity -> Entity
sset key value entity = Dict.update key 
    (\n -> case n of 
        Nothing -> Just (StringValue value)
        Just _ -> Just (StringValue value)
    ) entity