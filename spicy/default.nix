{ stdenv
, cmake
, flex
, bison
, python38
, zlib
, llvmPackages_9
, fetchFromGitHub
, which
, ninja
, lib
, makeWrapper
, glibc
}:

stdenv.mkDerivation rec {
  version = "2021-03-05";
  name = "spicy";
  src = fetchFromGitHub {
    owner = "zeek";
    repo = "spicy";
    rev = "f1e2dc0f3e068864ee4dbc587af8b0f4aa19ed9b";
    fetchSubmodules = true;
    sha256 = "sha256-jHXgv/usPTCflnH5AqLXgYUyXDa4tN2i+fjFDoxMJbo=";
  };


  nativeBuildInputs = [
    cmake
    flex
    bison
    python38
    zlib
    #ninja
  ];
  buildInputs = [
    which
    llvmPackages_9.clang-unwrapped
    llvmPackages_9.llvm
    makeWrapper
  ];

  preConfigure = ''
    patchShebangs ./scripts/autogen-type-erased
    patchShebangs ./scripts/autogen-dispatchers
  '';

  patches = [ ./version.patch ];

  cmakeFlags = [
    "-DCMAKE_CXX_COMPILER=${llvmPackages_9.clang}/bin/clang++"
    "-DCMAKE_C_COMPILER=${llvmPackages_9.clang}/bin/clang"
  ];

  postFixup = ''
    for e in $(cd $out/bin && ls); do
      wrapProgram $out/bin/$e \
        --set CLANG_PATH      "${llvmPackages_9.clang}/bin/clang" \
        --set CLANGPP_PATH    "${llvmPackages_9.clang}/bin/clang++" \
        --set LIBRARY_PATH    "${lib.makeLibraryPath [ flex bison python38 zlib glibc llvmPackages_9.libclang llvmPackages_9.libcxxabi llvmPackages_9.libcxx ]}"
     done
  '';

  meta = with stdenv.lib; {
    description = "C++ parser generator for dissecting protocols & files";
    homepage = https://docs.zeek.org/projects/spicy/en/latest/;
    license = licenses.bsd3;
    platforms = with platforms; linux;
  };
}
