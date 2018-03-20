module Main where

import Control.Concurrent (threadDelay)
import Data.DateTime (getCurrentTime)

import Uhouse.Hardware.DHT11

writePrLog :: String -> IO ()
writePrLog = log' "station.test.log"

logWeather :: String -> IO ()
logWeather = log' "station.weather.log"

log' fileName txt = do
    currentTime <- show <$> getCurrentTime
    let logMsg = currentTime++"<  --  >"++txt++"\n"
    appendFile fileName logMsg
    putStr logMsg

main = do
    writePrLog "Starting.."
    go
      where
        go :: IO ()
        go = do
            r <- dhtRead 11 4
            logWeather (show r)
            threadDelay 2000000
            go
