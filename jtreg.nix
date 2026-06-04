{
  stdenv,
  fetchFromGitHub,
  which,
  jdk25,
  ant,
  lib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "jtreg";
  version = "8.2.1+1";

  src = fetchFromGitHub {
    owner = "openjdk";
    repo = "jtreg";
    tag = "jtreg-${finalAttrs.version}";
    sha256 = "sha256-psrvWeuYDQ6rUtwvf981057Q6Rd5UsBMSd1uVCp7Y6g=";
  };

  nativeBuildInputs = [
    which
    jdk25
  ];

  env = {
    ANT = lib.getExe ant;
  };

  buildPhase = ''
    runHook preBuild

    bash make/build.sh

    runHook postBuild
  '';
})
