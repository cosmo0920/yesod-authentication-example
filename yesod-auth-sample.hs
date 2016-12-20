{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE QuasiQuotes           #-}
{-# LANGUAGE TemplateHaskell       #-}
{-# LANGUAGE TypeFamilies          #-}
import           Data.Text                   (Text)
import           Network.HTTP.Client.Conduit (Manager, newManager)
import           Yesod
import           Yesod.Auth
import           Yesod.Auth.GoogleEmail2
import           Yesod.Auth.OpenId           (authOpenId, IdentifierType (Claimed))
import           LoadEnv
import           System.Environment          (getEnv)
import qualified Data.Text as T

data GoogleLoginKeys = GoogleLoginKeys
    { googleLoginClientId :: Text
    , googleLoginClientSecret :: Text
    }

data App = App
    { httpManager :: Manager
    , googleLoginKeys :: GoogleLoginKeys
    }

mkYesod "App" [parseRoutes|
/ HomeR GET
/auth AuthR Auth getAuth
|]

instance Yesod App where
    -- Note: In order to log in with BrowserID, you must correctly
    -- set your hostname here.
    approot = ApprootStatic "http://localhost:3000"

instance YesodAuth App where
    type AuthId App = Text
    getAuthId = return . Just . credsIdent

    loginDest _ = HomeR
    logoutDest _ = HomeR

    authPlugins m =
        [ authOpenId Claimed []
        , authGoogleEmail (googleLoginClientId $ googleLoginKeys m) (googleLoginClientSecret $ googleLoginKeys m)
        ]

    authHttpManager = httpManager

    -- The default maybeAuthId assumes a Persistent database. We're going for a
    -- simpler AuthId, so we'll just do a direct lookup in the session.
    maybeAuthId = lookupSession "_ID"

instance RenderMessage App FormMessage where
    renderMessage _ _ = defaultFormMessage

getHomeR :: Handler Html
getHomeR = do
    maid <- maybeAuthId
    defaultLayout
        [whamlet|
            <p>Your current auth ID: #{show maid}
            $maybe _ <- maid
                <p>
                    <a href=@{AuthR LogoutR}>Logout
            $nothing
                <p>
                    <a href=@{AuthR LoginR}>Go to the login page
        |]

main :: IO ()
main = do
    loadEnv -- load from .env
    googleLoginKeys <- getGoogleLoginKeys

    man <- newManager
    warp 3000 $ App man googleLoginKeys
      where
        getGoogleLoginKeys :: IO GoogleLoginKeys
        getGoogleLoginKeys = GoogleLoginKeys
          <$> getEnvT "GOOGLE_LOGIN_CLIENT_ID"
          <*> getEnvT "GOOGLE_LOGIN_CLIENT_SECRET"
          where
            getEnvT = fmap T.pack . getEnv
