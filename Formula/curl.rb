class Curl < Formula
  desc "Get a file from an HTTP, HTTPS or FTP server"
  homepage "https://curl.haxx.se/"
  url "https://curl.haxx.se/download/curl-7.72.0.tar.bz2"
  sha256 "ad91970864102a59765e20ce16216efc9d6ad381471f7accceceab7d905703ef"
  license "curl"
  revision 1

  bottle do
    cellar :any
    sha256 "cf0b3a7fa1d1608caad2c0a9c9a8336f354e5376c827205d65cd17768dea62d8" => :catalina
    sha256 "49f8082e1253de80b4178a30a3c1ea368d438139584ac4aa2b837e7568179404" => :mojave
    sha256 "38ec51342cdf8105a69780cede9c6c28164d112119791d318610893ddf77e314" => :high_sierra
  end

  head do
    url "https://github.com/curl/curl.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  keg_only :provided_by_macos

  depends_on "pkg-config" => :build
  depends_on "brotli"
  depends_on "c-ares"
  depends_on "libidn2"
  depends_on "libmetalink"
  depends_on "libssh2"
  depends_on "nghttp2"
  depends_on "openldap"
  depends_on "openssl@1.1"
  depends_on "rtmpdump"
  depends_on "zstd"

  uses_from_macos "zlib"

  def install
    system "./buildconf" if build.head?

    openssl = Formula["openssl@1.1"]
    args = %W[
      --disable-debug
      --disable-dependency-tracking
      --disable-silent-rules
      --prefix=#{prefix}
      --with-ssl=#{openssl.opt_prefix}
      --with-ca-bundle=#{openssl.pkgetc}/cert.pem
      --with-ca-path=#{openssl.pkgetc}/certs
      --with-secure-transport
      --with-default-ssl-backend=openssl
      --enable-ares=#{Formula["c-ares"].opt_prefix}
      --with-gssapi
      --with-libidn2
      --with-libmetalink
      --with-librtmp
      --with-libssh2
      --without-libpsl
    ]

    system "./configure", *args
    system "make", "install"
    system "make", "install", "-C", "scripts"
    libexec.install "lib/mk-ca-bundle.pl"
  end

  test do
    # Fetch the curl tarball and see that the checksum matches.
    # This requires a network connection, but so does Homebrew in general.
    filename = (testpath/"test.tar.gz")
    system "#{bin}/curl", "-L", stable.url, "-o", filename
    filename.verify_checksum stable.checksum

    system libexec/"mk-ca-bundle.pl", "test.pem"
    assert_predicate testpath/"test.pem", :exist?
    assert_predicate testpath/"certdata.txt", :exist?
  end
end
