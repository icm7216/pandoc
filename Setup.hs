{-# LANGUAGE CPP #-}
{-
Copyright (C) 2006-2014 John MacFarlane <jgm@berkeley.edu>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
-}

import Distribution.Simple
import Distribution.Simple.PreProcess
import Distribution.Simple.Setup
         (copyDest, copyVerbosity, fromFlag, installVerbosity, BuildFlags(..),
          TestFlags(..))
import Distribution.PackageDescription (PackageDescription(..), Executable(..))
import Distribution.Simple.LocalBuildInfo
         (LocalBuildInfo(..), absoluteInstallDirs)
import Distribution.Verbosity ( Verbosity, silent )
import Distribution.Simple.InstallDirs (mandir, CopyDest (NoCopyDest), toPathTemplate)
import Distribution.Simple.Utils (installOrdinaryFiles, info)
import Distribution.Simple.Test (test)
import System.Process ( rawSystem )
import System.FilePath ( (</>) )
import System.Directory ( findExecutable )
import System.Exit

main :: IO ()
main = do
  defaultMainWithHooks $ simpleUserHooks {
      postBuild = makeManPages
    , testHook = \pkg lbi _ flags ->
         -- pass build directory as first argument to test program
         test pkg lbi flags{ testOptions =
               toPathTemplate (buildDir lbi) : testOptions flags }
    , postCopy = \ _ flags pkg lbi ->
         installManpages pkg lbi (fromFlag $ copyVerbosity flags)
              (fromFlag $ copyDest flags)
    , postInst = \ _ flags pkg lbi ->
         installManpages pkg lbi (fromFlag $ installVerbosity flags) NoCopyDest
    , copyHook = \pkgdescr ->
         (copyHook simpleUserHooks) pkgdescr{ executables =
            [x | x <- executables pkgdescr, exeName x /= "make-pandoc-man-pages"] }
    , instHook = \pkgdescr ->
         (instHook simpleUserHooks) pkgdescr{ executables =
            [x | x <- executables pkgdescr, exeName x /= "make-pandoc-man-pages"] }
    , hookedPreProcessors = [ppBlobSuffixHandler]
    }
  exitWith ExitSuccess

-- | Build man pages from markdown sources in man/
makeManPages :: Args -> BuildFlags -> PackageDescription -> LocalBuildInfo -> IO ()
makeManPages _ flags _ lbi = do
  let verbosity = fromFlag $ buildVerbosity flags
  let args = ["--verbose" | verbosity /= silent]
  rawSystem (buildDir lbi </> "make-pandoc-man-pages" </> "make-pandoc-man-pages")
      args >>= exitWith

manpages :: [FilePath]
manpages = ["man1" </> "pandoc.1"
           ,"man5" </> "pandoc_markdown.5"]

manDir :: FilePath
manDir = "man"

installManpages :: PackageDescription -> LocalBuildInfo
                -> Verbosity -> CopyDest -> IO ()
installManpages pkg lbi verbosity copy =
  installOrdinaryFiles verbosity (mandir (absoluteInstallDirs pkg lbi copy))
             (zip (repeat manDir) manpages)

ppBlobSuffixHandler :: PPSuffixHandler
ppBlobSuffixHandler = ("hsb", \_ _ ->
  PreProcessor {
    platformIndependent = True,
    runPreProcessor = mkSimplePreProcessor $ \infile outfile verbosity ->
      do info verbosity $ "Preprocessing " ++ infile ++ " to " ++ outfile
         hsb2hsPath <- findExecutable "hsb2hs"
         case hsb2hsPath of
            Just p  -> rawSystem p [infile, infile, outfile]
            Nothing -> error "hsb2hs is needed to build this program: cabal install hsb2hs"
         return ()

  })
