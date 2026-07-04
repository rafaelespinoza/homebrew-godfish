class GodfishSqlserver < Formula
  desc "Database migrations CLI for sqlserver"
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

  # TODO: figure out how to detect a Windows-like platform for Homebrew.
  # if OS.wsl? && Hardware::CPU.intel?
  #   #   url "https://github.com/rafaelespinoza/godfish/releases/download/v0.15.0/godfish_0.15.0_windows_amd64.tar.gz"
  #   sha256 "5fe7b8e37e31b3f27af23e38800fc06913a6b7faa463d7ef4504b643e27c6948"
  # end

  # if OS.wsl? && Hardware::CPU.arm?
  #   #   url "https://github.com/rafaelespinoza/godfish/releases/download/v0.15.0/godfish_0.15.0_windows_arm64.tar.gz"
  #   sha256 "3b010339f8226479eb0008de2981ecd4d52ff6a29c8a30a37f95cc60b5c3fd14"
  # end

  def install
    # Homebrew extracts the entire multi-binary archive. Cherry-pick only
    # the targeted binary into the installation path
    bin.install "godfish_sqlserver"
  end

  test do
    assert_match(/Driver:.*sqlserver/, shell_output("#{bin}/godfish_sqlserver version 2>&1"))
  end
end
