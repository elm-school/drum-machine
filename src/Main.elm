module Main exposing (main)


import Bank exposing (Bank, KeyConfig, Kit)
import Browser
import Html as H
import Html.Attributes as HA
import Json.Decode as JD
import Json.Encode as JE
import Key exposing (Key)


main : Program Flags Model Msg
main =
  Browser.element
    { init = init
    , view = view
    , update = update
    , subscriptions = always Sub.none
    }


-- MODEL


type alias Flags =
  JE.Value


type alias Model =
  Maybe State


type alias State =
  { bank : Bank
  }


init : Flags -> (Model, Cmd msg)
init value =
  let
    model =
      case JD.decodeValue Bank.decoder value of
        Ok bank ->
          Just { bank = bank }

        Err _ ->
          Nothing
  in
  ( model
  , Cmd.none
  )


-- UPDATE


type Msg
  = NoOp


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp ->
      ( model
      , Cmd.none
      )


-- VIEW


view : Model -> H.Html msg
view model =
  case model of
    Just { bank } ->
      let
        kit =
          Bank.kit bank
      in
      viewPanel False kit

    Nothing ->
      viewError "Sorry, we're unable to start the application since it's not properly configured."


viewPanel : Bool -> Kit -> H.Html msg
viewPanel isDisabled kit =
  H.div [ HA.class "panel" ]
    [ H.div [ HA.class "panel__container" ] <|
        List.indexedMap (viewPanelSpot isDisabled) kit.keyConfigs
    ]


viewPanelSpot : Bool -> Int -> KeyConfig -> H.Html msg
viewPanelSpot isDisabled index config =
  let
    (r, c) =
      (index // 3 + 1, modBy 3 index + 1)
  in
  H.div
    [ HA.class "panel__spot"
    , HA.class <| "r" ++ String.fromInt r
    , HA.class <| "c" ++ String.fromInt c
    ]
    [ viewKey isDisabled config.key ]


viewKey : Bool -> Key -> H.Html msg
viewKey isDisabled key =
  H.button
    [ HA.class "key"
    , HA.disabled isDisabled
    ]
    [ H.text <| Key.toString key ]


viewError : String -> H.Html msg
viewError text =
  H.div
    [ HA.class "error" ]
    [ H.text text ]
