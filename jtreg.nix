{
  stdenv,
  fetchFromGitHub,
  which,
  jdk25,
  ant,
  lib,
  jtharness,
  asmtools,
  writeText,
  fetchurl,
  hostname-debian,
  pandoc,
  zip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "jtreg";
  version = "8.2.1+1";

  patches = [
    ./0001-Lookup-binaries-from-PATH.patch
    ./0002-Drop-Werror-for-helper-classes-on-JDK-21.patch
  ];

  src = fetchFromGitHub {
    owner = "openjdk";
    repo = "jtreg";
    tag = "jtreg-${finalAttrs.version}";
    sha256 = "sha256-psrvWeuYDQ6rUtwvf981057Q6Rd5UsBMSd1uVCp7Y6g=";
  };

  nativeBuildInputs = [
    which
    jdk25
    hostname-debian
    pandoc
    zip
  ];

  env = {
    ANT = lib.getExe ant;

    JTHARNESS_JAVATEST_JAR = jtharness.jar;
    JTHARNESS_LICENSE = writeText "LICENSE" "meow";
    JTHARNESS_COPYRIGHT = writeText "COPYRIGHT" "meow";

    ASMTOOLS_JAR = asmtools.jar;
    ASMTOOLS_LICENSE = writeText "LICENSE" "meow";

    JUNIT_JAR = fetchurl {
      url = "https://repo1.maven.org/maven2/org/junit/platform/junit-platform-console-standalone/6.1.0/junit-platform-console-standalone-6.1.0.jar";
      hash = "sha256-w1lUShBqp051zZdx6wzWk9TltE7Sed2sjWv4HQ8AC1I=";
    };
    JUNIT_LICENSE = writeText "LICENSE" "meow";

    TESTNG_JAR = fetchurl {
      url = "https://repo1.maven.org/maven2/org/testng/testng/7.3.0/testng-7.3.0.jar";
      hash = "sha256-Y3J0iPlxfVfw0KD+5aH8EKK+nPz/LsOnGHZW1mPAd04=";
    };
    TESTNG_LICENSE = writeText "LICENSE" "meow";

    JCOMMANDER_JAR = fetchurl {
      url = "https://repo1.maven.org/maven2/com/beust/jcommander/1.82/jcommander-1.82.jar";
      hash = "sha256-3urBV8jeaCKHjYXQx7yEZ6GcyEhNN3iPeATwOd3igLE=";
    };

    GOOGLE_GUICE_JAR = fetchurl {
      url = "https://repo1.maven.org/maven2/com/google/inject/guice/7.0.0/guice-7.0.0.jar";
      hash = "sha256-3lsONZvXsDykKAazaIRu/ZVIQ4D+Ba4qTqcbwzjFnAA=";
    };
  };

  buildPhase = ''
    runHook preBuild

    bash make/build.sh

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mv build/images/jtreg $out

    runHook postInstall
  '';
})
