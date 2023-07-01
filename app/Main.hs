{-
  Create a Julia set image.
  See: https://en.wikipedia.org/wiki/Julia_set
  By: Javier Ríos, Jul 2023.
-}

import Codec.Picture
import Data.Complex

width, height :: Int
width = 800
height = 800

xmin, xmax, ymin, ymax :: Double
xmin = -1.5
xmax = 1.5
ymin = -1.5
ymax = 1.5

maxIterations :: Int
maxIterations = 150

c :: Complex Double
c = (-0.8) + 0.156 * (0 :+ 1)

calcJulia :: Complex Double -> Int
calcJulia z0 = iterateJulia z0 0
  where
    iterateJulia z n
      | n == maxIterations || magnitude z > 2.0 = n
      | otherwise = iterateJulia (z * z + c) (n + 1)

pixelToCoords :: Int -> Int -> Double -> Double -> Complex Double
pixelToCoords x y xRange yRange =
  let x' = xmin + (fromIntegral x / fromIntegral width) * xRange
      y' = ymin + (fromIntegral y / fromIntegral height) * yRange
   in x' :+ y'

calculatePixelColor :: Int -> PixelRGB8
calculatePixelColor iterationCount
  | iterationCount == maxIterations = PixelRGB8 0 0 0
  | otherwise = PixelRGB8 r g b
  where
    normalizedN = fromIntegral iterationCount / fromIntegral maxIterations :: Double
    hue = normalizedN
    saturation = 1.0
    value = 1.0
    (r, g, b) = hsvToRgb hue saturation value

hsvToRgb :: Double -> Double -> Double -> (Pixel8, Pixel8, Pixel8)
hsvToRgb h s v = (r, g, b)
  where
    hi = floor (h * 6) :: Int
    f = h * 6 - fromIntegral hi
    p = round (v * (1 - s) * 255)
    q = round (v * (1 - f * s) * 255)
    t = round (v * (1 - (1 - f) * s) * 255)
    (r, g, b) =
      case hi of
        0 -> (round (v * 255), t, p)
        1 -> (q, round (v * 255), p)
        2 -> (p, round (v * 255), t)
        3 -> (p, q, round (v * 255))
        4 -> (t, p, round (v * 255))
        5 -> (round (v * 255), p, q)
        _ -> (0, 0, 0)

createJuliaSetImage :: Int -> Int -> Double -> Double -> Image PixelRGB8
createJuliaSetImage w h xRange yRange =
  generateImage (\x y -> calculatePixelColor $ calcJulia $ pixelToCoords x y xRange yRange) w h

main :: IO ()
main = do
  let xRange = xmax - xmin
      yRange = ymax - ymin
      image = createJuliaSetImage width height xRange yRange
  writePng "julia_set.png" image
