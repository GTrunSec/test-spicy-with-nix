{stdenv, cmake, flex, bison, python38, zlib, llvmPackages_9, fetchFromGitHub, which, ninja, lib
, makeWrapper, glibc
}:

stdenv.mkDerivation rec {
  version = "master";
  name = "spicy";
  src = fetchFromGitHub {
    owner = "zeek";
    repo = "spicy";
    rev = "193742cd1d197910dbc2b905e1e3ada7d968d480";
    fetchSubmodules = true;
    sha256 = "sha256-7OaKsiyqLAR/eeVWwT/sk2KZYnI2yqjB4DuQH7b2/to=";
  };


  nativeBuildInputs = [ cmake flex bison  python38 zlib
                        #ninja
                      ];
  buildInputs = [ which
                  llvmPackages_9.clang-unwrapped
                  llvmPackages_9.llvm
                  makeWrapper
                ];

  preConfigure = ''
   patchShebangs ./scripts/autogen-type-erased
   patchShebangs ./scripts/autogen-dispatchers
'';

  cmakeFlags = [
    "-DCMAKE_CXX_COMPILER=${llvmPackages_9.clang}/bin/clang++"
    "-DCMAKE_C_COMPILER=${llvmPackages_9.clang}/bin/clang"
    "-DHILTI_HAVE_JIT=true"
  ];

  postFixup = ''
    wrapProgram $out/bin/spicyc \
      --set CLANG_PATH      "${llvmPackages_9.clang}/bin/clang" \
      --set CLANGPP_PATH    "${llvmPackages_9.clang}/bin/clang++" \
      --set CPATH           "${lib.makeSearchPathOutput "dev" "include" [ flex bison python38 zlib glibc llvmPackages_9.libcxxabi llvmPackages_9.libcxx ]}/c++/v1" \
      --set LIBRARY_PATH    "${lib.makeLibraryPath [ flex bison python38 zlib glibc llvmPackages_9.libclang llvmPackages_9.libcxxabi llvmPackages_9.libcxx ]}" \
      --set NIX_CFLAGS_LINK "-lc++abi -lc++"
  '';

  meta = with stdenv.lib; {
    description = "C++ parser generator for dissecting protocols & files";
    homepage = https://docs.zeek.org/projects/spicy/en/latest/;
    license = licenses.bsd3;
    platforms = with platforms; linux;
  };
}
