class Swift < Formula
  desc "High-performance system programming language"
  homepage "https://github.com/apple/swift"
  url "https://github.com/apple/swift/archive/swift-5.1.2-RELEASE.tar.gz"
  sha256 "1a366fd001df4f6d0da61361f3574ca01a63f3f551b2ccc21939aa570b61b59e"

  bottle do
    cellar :any
    rebuild 1
    sha256 "eb739a681ff2f5b585422d3b9408dd817724eb7bc0484a31f38db6f7dc387867" => :mojave
    sha256 "1a82548cd25a4b6a525b7d8a194393e9853843e952c00c2650792141c17a528d" => :high_sierra
  end

  keg_only :provided_by_macos, "Apple's CLT package contains Swift"

  depends_on "cmake" => :build
  depends_on "ninja" => :build

  # Depends on latest version of Xcode
  # https://github.com/apple/swift#system-requirements
  depends_on :xcode => ["11.0", :build]

  # This formula is expected to have broken/missing linkage to
  # both UIKit.framework and AssetsLibrary.framework. This is
  # simply due to the nature of Swift's SDK Overlays.
  resource "llvm-project" do
    url "https://github.com/apple/llvm-project/archive/swift-5.1.2-RELEASE.tar.gz"
    sha256 "d045b1d42933f4d34b24f5434438bbdce4a18341964be019ff5d3f0ed56653fe"
  end

  resource "cmark" do
    url "https://github.com/apple/swift-cmark/archive/swift-5.1.2-RELEASE.tar.gz"
    sha256 "2d0919a443536161ac7e059ac3922b70f63c3e46a26efc4b5f8ac824caf09d2e"
  end

  resource "llbuild" do
    url "https://github.com/apple/swift-llbuild/archive/swift-5.1.2-RELEASE.tar.gz"
    sha256 "61629212db265d849db5fa2b2b770385713938a38fdfb3bb7cff120a748f946a"
  end

  resource "swiftpm" do
    url "https://github.com/apple/swift-package-manager/archive/swift-5.1.2-RELEASE.tar.gz"
    sha256 "74e61207f4d0ac67fe5bc69d16591df1bc29cbcaeb0ccfdf480d43bfc5c5608a"
  end

  def install
    workspace = buildpath.parent
    build = workspace/"build"

    toolchain_prefix = "/Swift-#{version}.xctoolchain"
    install_prefix = "#{toolchain_prefix}/usr"

    ln_sf buildpath, "#{workspace}/swift"
    resources.each { |r| r.stage("#{workspace}/#{r.name}") }
    %w[clang llvm lldb compiler-rt libcxx clang-tools-extra].each { |p|
      ln_sf workspace/"llvm-project"/p, workspace/p
    }

    mkdir build do
      # List of components to build
      components = %w[
        compiler clang-resource-dir-symlink
        clang-builtin-headers-in-clang-resource-dir stdlib sdk-overlay tools
        editor-integration testsuite-tools toolchain-dev-tools license
        sourcekit-xpc-service swift-remote-mirror
        swift-remote-mirror-headers
      ]

      # SwiftPM _requires_ CC to be either absolute or unset
      ENV["CC"] = which ENV.cc

      system "#{workspace}/swift/utils/build-script",
        "--release", "--assertions",
        "--no-swift-stdlib-assertions",
        "--build-subdir=#{build}",
        "--llbuild", "--swiftpm",
        "--jobs=#{ENV.make_jobs}",
        "--verbose-build",
        "--",
        "--workspace=#{workspace}",
        "--install-destdir=#{prefix}",
        "--toolchain-prefix=#{toolchain_prefix}",
        "--install-prefix=#{install_prefix}",
        "--host-target=macosx-x86_64",
        "--stdlib-deployment-targets=macosx-x86_64",
        "--build-swift-static-stdlib",
        "--build-swift-dynamic-stdlib",
        "--build-swift-static-sdk-overlay",
        "--build-swift-dynamic-sdk-overlay",
        "--build-swift-stdlib-unittest-extra",
        "--install-swift",
        "--swift-install-components=#{components.join(";")}",
        "--llvm-install-components=clang;libclang;libclang-headers",
        "--install-llbuild",
        "--install-swiftpm"
    end
  end

  test do
    (testpath/"test.swift").write <<~EOS
      let base = 2
      let exponent_inner = 3
      let exponent_outer = 4
      var answer = 1

      for _ in 1...exponent_outer {
        for _ in 1...exponent_inner {
          answer *= base
        }
      }

      print("(\\(base)^\\(exponent_inner))^\\(exponent_outer) == \\(answer)")
    EOS
    output = shell_output("#{prefix}/Swift-#{version}.xctoolchain/usr/bin/swift test.swift")
    assert_match "(2^3)^4 == 4096\n", output
  end
end
