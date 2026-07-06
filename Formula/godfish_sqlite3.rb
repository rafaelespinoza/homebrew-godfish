class GodfishSqlite3 < Formula
  desc "Database migrations CLI for sqlite3"
  homepage "https://github.com/rafaelespinoza/godfish"
  version "0.15.0"
  license "ISC"

  if OS.mac? && Hardware::CPU.intel?
    url "https://github.com/rafaelespinoza/godfish/releases/download/v0.15.0/godfish_0.15.0_darwin_amd64.tar.gz"
    sha256 "67221b8c8547ab56ff1950124275540d3dcb9d1708d975b4e7faad68f7bb5b25"
  end

  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/rafaelespinoza/godfish/releases/download/v0.15.0/godfish_0.15.0_darwin_arm64.tar.gz"
    sha256 "fe51c1d40607e4be7be076509d2c10b48900f4a8b6ccae75eb7f52b19b5a20f9"
  end

  if OS.linux? && Hardware::CPU.intel?
    url "https://github.com/rafaelespinoza/godfish/releases/download/v0.15.0/godfish_0.15.0_linux_amd64.tar.gz"
    sha256 "e6598dd1a5cb7add672c7b07341c0ea9e28448ab50d697a42a788b16cd87c154"
  end

  if OS.linux? && Hardware::CPU.arm?
    url "https://github.com/rafaelespinoza/godfish/releases/download/v0.15.0/godfish_0.15.0_linux_arm64.tar.gz"
    sha256 "b4fd5e3689812546b617f30d90d21f1d6d6da4f34e7d9b0f704e5c7a897460a3"
  end

  def install
    # Homebrew extracts the entire multi-binary archive. Cherry-pick only
    # the targeted binary into the installation path. Also rename so it's
    # more conventionally-cased.
    bin.install "godfish_sqlite3" => "godfish-sqlite3"
  end

  test do
    assert_match(/Driver:.*sqlite3/, shell_output("#{bin}/godfish-sqlite3 version 2>&1"))
  end
end
