{-# LANGUAGE TemplateHaskell, QuasiQuotes #-}

module CompileTimeQ
    ( playQ
    ) where

import Language.Haskell.TH

import CompileTimeQ.Core

playQ :: DecsQ
playQ = runIO ioAction >> [d| dummy = undefined |]
    where
        ioAction = play
