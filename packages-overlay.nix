self: super:
{
  spicy = super.callPackage ./spicy { stdenv = super.llvmPackages_9.stdenv; };
}
