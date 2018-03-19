{-# LANGUAGE QuasiQuotes     #-}
{-# LANGUAGE TemplateHaskell #-}

module Uhouse.Hardware.DHT11 where

import Foreign.C.Types
import qualified Language.C.Inline as C

C.include "<stdio.h>"
C.include "myconv.h"
C.include "pi_dht_read.h"

dhtReadRaw :: CInt -> CInt -> IO CInt
dhtReadRaw sensor pin = [C.block| int {
      float tem, hum;
      int res = pi_dht_read($(int sensor), $(int pin), &tem, &hum);
      return pack(res, tem, hum);
  }|]

type Sensor = Int
type Pin = Int

-- dhtRead :: Sesor -> Pin -> IO SensorReadResult
-- dhtRead sens pin = dhtReadRaw sens pin >>=

data SensorReadResult = Error ReadError | Result SensorData deriving (Show)

data SensorData = SensorData {
    temperature :: Int
  , humidity    :: Int
} deriving (Show)

data ReadError = ReadError {
    statusCode  :: Int
  , description :: String
} deriving (Show)
