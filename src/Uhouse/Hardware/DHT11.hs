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

unpack :: CInt -> (CInt, CInt, CInt)
unpack i =
  (
      [C.pure| int {unpack_sta($(int i))}|]
    , [C.pure| int {unpack_tem($(int i))}|]
    , [C.pure| int {unpack_hum($(int i))}|]
  )

type SensorReadResult = Either ReadError SensorData

data SensorData = SensorData {
    temperature :: Int
  , humidity    :: Int
} deriving (Show)


data ReadError =
    TimeoutError
  | ChecksumError
  | ArgumentError
  | GPIOError deriving (Show)

type Sensor = Int
type Pin = Int

dhtRead :: Sensor -> Pin -> IO SensorReadResult
dhtRead sens pin = parseSensResp <$> (mapTr fromIntegral) . unpack <$> dhtReadRaw (p sens) (p pin)
  where
    p = fromIntegral

    mapTr :: (a -> b) -> (a, a, a) -> (b, b, b)
    mapTr f (a1, a2, a3) = (f a1, f a2, f a3)

parseSensResp :: (Int, Int, Int) -> SensorReadResult
parseSensResp (sta, tem, hum) =
  case parseError sta of
    Just err -> Left err
    Nothing  -> Right $ SensorData tem hum

-- #define DHT_ERROR_TIMEOUT -1
-- #define DHT_ERROR_CHECKSUM -2
-- #define DHT_ERROR_ARGUMENT -3
-- #define DHT_ERROR_GPIO -4

parseError :: Int -> Maybe ReadError
parseError -1 = Just TimeoutError
parseError -2 = Just ChecksumError
parseError -3 = Just ArgumentError
parseError -4 = Just GPIOError
parseError _ = Nothing
