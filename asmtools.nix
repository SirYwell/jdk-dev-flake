{
  stdenv,
  fetchFromGitHub,
  ant,
  openjdk25,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "asmtools";
  version = "9.1-b01";

  src = fetchFromGitHub {
    owner = "openjdk";
    repo = "asmtools";
    tag = finalAttrs.version;
    hash = "sha256-fRlXq+c09MyMfVRoIEdx6egusWVDPiYRDjC3rPmRZTY=";
  };

  nativeBuildInputs = [
    ant
    openjdk25
  ];

  buildPhase = ''
    runHook preBuild

    ant -DBUILD_DIR=$NIX_BUILD_TOP -f build/build.xml

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 $NIX_BUILD_TOP/binaries/lib/asmtools.jar $out/share/java/asmtools.jar

    runHook postInstall
  '';

  passthru = {
    jar = "${finalAttrs.finalPackage}/share/java/asmtools.jar";
  };
})
