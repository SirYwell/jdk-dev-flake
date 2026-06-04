{
  stdenv,
  fetchFromGitHub,
  ant,
  jdk25,
  stripJavaArchivesHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "jtharness";
  version = "6.0-b26";

  src = fetchFromGitHub {
    owner = "openjdk";
    repo = "jtharness";
    tag = "jt${finalAttrs.version}";
    hash = "sha256-41PjFHBrtcNN/PgUmZQloE0oXBWEv9l6YqPIdVgpymo=";
  };

  nativeBuildInputs = [
    ant
    jdk25
    stripJavaArchivesHook
  ];

  buildPhase = ''
    runHook preBuild
    ant -f build/build.xml
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 ../JTHarness-build/binaries/lib/javatest.jar $out/share/java/javatest.jar

    runHook postInstall
  '';

  passthru = {
    jar = "${finalAttrs.finalPackage}/share/java/javatest.jar";
  };
})
