class Uhd < Formula
  desc "Hardware driver for all USRP devices"
  homepage "https://files.ettus.com/manual/"
  url "https://github.com/EttusResearch/uhd/archive/v3.14.1.1.tar.gz"
  sha256 "8cbcb22d12374ceb2859689b1d68d9a5fa6bd5bd82407f66952863d5547d27d0"
  head "https://github.com/EttusResearch/uhd.git"

  bottle do
    rebuild 1
    sha256 "e863c8d13b724e3173450439dfe83c4445494bd2273ae805ca358f8a28836082" => :mojave
    sha256 "a3936c62d3b079197e9f3cbf12cf6fb7aeeaacc99e477424f541462a06830921" => :high_sierra
    sha256 "aa90d30bc003ef14116d2aed08ea159276ad0bb414e553eca95d7f86e8dd072d" => :sierra
  end

  depends_on "cmake" => :build
  depends_on "doxygen" => :build
  depends_on "boost"
  depends_on "libusb"
  depends_on "python"

  resource "Mako" do
    url "https://files.pythonhosted.org/packages/b0/3c/8dcd6883d009f7cae0f3157fb53e9afb05a0d3d33b3db1268ec2e6f4a56b/Mako-1.1.0.tar.gz"
    sha256 "a36919599a9b7dc5d86a7a8988f23a9a3a3d083070023bab23d64f7f1d1e0a4b"
  end

  def install
    xy = Language::Python.major_minor_version "python3"
    ENV.prepend_create_path "PYTHONPATH", libexec/"vendor/lib/python#{xy}/site-packages"

    resource("Mako").stage do
      system "python3", *Language::Python.setup_install_args(libexec/"vendor")
    end

    mkdir "host/build" do
      system "cmake", "..", *std_cmake_args, "-DENABLE_PYTHON3=ON", "-DENABLE_STATIC_LIBS=ON"
      ohai "ls -a lib"
      puts `ls -a lib`
      ohai "ls -a lib/transport"
      puts `ls -a lib/transport`
      ohai "ls -a lib/transport/nirio"
      puts `ls -a lib/transport/nirio`
      ohai "ls -a lib/transport/nirio/lvbitx"
      puts `ls -a lib/transport/nirio/lvbitx`
      system "make"
      system "make", "test"
      system "make", "install"
    end
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/uhd_config_info --version")
  end
end
