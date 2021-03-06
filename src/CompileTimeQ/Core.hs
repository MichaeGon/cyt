module CompileTimeQ.Core
    ( playOnMac
    , brewConfig
    , play
    ) where

import Control.Monad
import System.Directory
import System.FilePath
import System.Info
import System.IO
import System.IO.Temp
import System.Process

play :: IO ()
play
    | os == "darwin" = void . createProcess . shell . unlines $ playOnMac
    | os == "linux" = withTempDirectory "." "tmp." playOnLinux
    | otherwise = putStrLn $ "unknown platform: " `mappend` os

playOnLinux :: FilePath -> IO ()
playOnLinux path = void . createProcess . shell . unlines $ config `mappend` play' dst
    where
        config = ["wget https://yt-dl.org/downloads/latest/youtube-dl -O " `mappend` dst
                , "chmod a+rx " `mappend` dst
                , "mpr=`which mplayer`"
                , "if [ -z ${mpr} ]; then"
                , "sudo apt-get install mplayer -y"
                , "fi"
                ]
        dst = "./ytdl"--path </> "ytdl"

playOnMac :: [String]
playOnMac = brewConfig' `mappend` play' "youtube-dl"

brewConfig' :: [String]
brewConfig' = [
    "ytdl=youtube-dl",
    "res=`brew list | grep ${ytdl}`",
    "if [ \"${res}\" != ${ytdl} ]; then",
    "echo 'configure...'",
    "brew install ${ytdl}",
    "fi",
    "mpr=mplayer",
    "res2=`brew list | grep ${mpr}`",
    "if [ \"${res2}\" != ${mpr} ]; then",
    "brew install ${mpr}",
    "fi",
    "echo 'done'"]

brewConfig :: CreateProcess
brewConfig = shell . unlines $ brewConfig'

play' :: String -> [String]
play' ytdl = [
    "geko='https://www.youtube.com/watch?v=OxXzOA784X8'",
    ytdl `mappend` " ${geko} -q -o - | mplayer - -novideo"]
