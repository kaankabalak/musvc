module API
    ( muServer
    ) where

import           Network.Wai                    (pathInfo)
import           Network.Wai.Handler.Warp       (defaultSettings,
                                                 runSettings, setPort)
import qualified Web.Scotty.Trans               as S

import           Lib.Prelude

import           MuSvc.APIHandlers
import           MuSvc.Types
import           Static

muAPI :: S.ScottyT LText MuSvcM ()
muAPI = do
    S.get "/" $ S.redirect "/index.html"
    S.get "/api/v1/status" statusHandler
    -- other API routes will be declared below

muServer :: Int -> MuEnv -> IO ()
muServer port env = do
    let runIO m = runReaderT (unMuSvcM m) env
    let settings = setPort port defaultSettings
    apiServer <- S.scottyAppT runIO muAPI
    runSettings settings $ app apiServer
    where
        app apiServer req handler =
            let servingApp "api" = apiServer
                servingApp _     = browserApp
                appToUse = maybe apiServer servingApp $
                           headMay $ pathInfo req
            in appToUse req handler
