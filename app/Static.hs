{-# LANGUAGE QuasiQuotes     #-}
{-# LANGUAGE TemplateHaskell #-}
module Static where

import           Data.FileEmbed                 (embedDir)
import           Network.Wai                    (Application)
import           Network.Wai.Application.Static (StaticSettings,
                                                 embeddedSettings, ss404Handler,
                                                 staticApp)
import           Network.Wai.Middleware.Vhost   (redirectTo)

import           Lib.Prelude

redirectHome :: Application
redirectHome _ sendResponse = sendResponse $ redirectTo "/"

appSettings :: StaticSettings
appSettings = let s = embeddedSettings $(embedDir "ui")
              in s {ss404Handler = Just redirectHome}

browserApp :: Application
browserApp = staticApp appSettings
