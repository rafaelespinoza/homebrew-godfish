class Godfish < Formula
  desc "Database migrations CLIs for cassandra, postgres, mysql, sqlite3, sqlserver"
  homepage "https://github.com/rafaelespinoza/godfish"
  version "0.15.0"
  license "ISC"
  conflicts_with(
    "godfish_cassandra",
    "godfish_postgres",
    "godfish_mysql",
    "godfish_sqlite3",
    "godfish_sqlserver",
    because: "each driver formula (godfish_*) already installs a binary of the same name",
  )

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
    # the targeted binaries into the installation path
    libexec.install "godfish_cassandra"
    libexec.install "godfish_postgres"
    libexec.install "godfish_mysql"
    libexec.install "godfish_sqlite3"
    libexec.install "godfish_sqlserver"

    # Copy wrapper script.
    script_dest_pathname = bin/"godfish"
    script_dest_pathname.write(File.read("#{__dir__}/godfish"))
    inreplace(script_dest_pathname, /LIBEXEC_DIR=.*$/, "LIBEXEC_DIR=#{libexec}")
    chmod(0555, script_dest_pathname)
  end

  test do
    assert_match(/Driver:.*cassandra/, shell_output("#{bin}/godfish cassandra version 2>&1"))
    assert_match(/Driver:.*postgres/, shell_output("#{bin}/godfish postgres version 2>&1"))
    assert_match(/Driver:.*mysql/, shell_output("#{bin}/godfish mysql version 2>&1"))
    assert_match(/Driver:.*sqlite3/, shell_output("#{bin}/godfish sqlite3 version 2>&1"))
    assert_match(/Driver:.*sqlserver/, shell_output("#{bin}/godfish sqlserver version 2>&1"))
  end
end
