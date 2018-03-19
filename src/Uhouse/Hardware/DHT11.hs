{-# LANGUAGE QuasiQuotes     #-}
{-# LANGUAGE TemplateHaskell #-}

module Uhouse.Hardware.DHT11 where

import Foreign.C.Types
import qualified Language.C.Inline as C

C.include "<stdio.h>"
C.include "myconv.h"
C.include "mysens.h"

dhtReadRaw :: CInt -> CInt -> IO CInt
dhtReadRaw sensor pin = [C.block| int {
      float tem, hum;
      int res = pi_dht_read($(int sensor), $(int pin), &tem, &hum);
      return pack(res, tem, hum);
  }|]

data SensorReadResult = Error ReadError | Result SensorData deriving (Show)

data SensorData = SensorData {
    temperature :: Int
  , humidity    :: Int
} deriving (Show)

data ReadError = ReadError {
    statusCode  :: Int
  , description :: String
} deriving (Show)
