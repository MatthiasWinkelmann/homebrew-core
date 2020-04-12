class Jigdo < Formula
  desc "Tool to distribute very large files over the internet"
  homepage "https://www.einval.com/~steve/software/jigdo/"
  url "https://www.einval.com/~steve/software/jigdo/download/jigdo-0.8.0.tar.xz"
  sha256 "f253f72b5719716a7f039877a97ebaf4ba96e877510fca0fb42010d0793db6a4"
  head "https://git.einval.com/git/jigdo.git", :branch => "upstream"

  bottle do
    sha256 "bcde67883304312dcb904e44b17928a16ec9cb1c8a469e37b2832104178eb7b1" => :catalina
    sha256 "eb44dc4044f003304fa8dcbf29a607b79e82e62ed1f106fb2172d1af30c139a0" => :mojave
    sha256 "dd14191d456b799e759d7adad19a1ca25a1791f63188d60db48460f76d4650fd" => :high_sierra
    sha256 "2a08598075af594b3d31b957f6fdbb6f86d90d3ad542545eaa5ffc6417085600" => :sierra
  end

  depends_on "pkg-config" => :build
  depends_on "berkeley-db"
  depends_on "wget"

  def install
    # truncate64 is Linux-specific
    ENV.append_to_cflags "-Dtruncate64=truncate"
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--with-gui=no",
                          "--prefix=#{prefix}",
                          "--mandir=#{man}"
    system "make"
    system "make", "install"
  end

  test do
    assert_match "version #{version}", shell_output("#{bin}/jigdo-file -v")
  end
end
