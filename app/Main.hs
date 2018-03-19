module Main where

import Control.Concurrent (threadDelay)

import Uhouse.Hardware.DHT11

main :: IO ()
main = do
    r <- dhtReadRaw 11 4
    print r
    threadDelay 2000000
    main
