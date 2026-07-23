class GodfishPostgres < Formula
  desc "Database migrations CLI for postgres"
  homepage "https://github.com/rafaelespinoza/godfish"
  version "0.16.1"
  license "ISC"

  if OS.mac? && Hardware::CPU.intel?
    url "https://github.com/rafaelespinoza/godfish/releases/download/v0.16.1/godfish_0.16.1_darwin_amd64.tar.gz"
    sha256 "4be4efc2a1e2be6c3fb7ad6a098c9f67595a94213134870d32c78e15579d8cb3"
  end

  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/rafaelespinoza/godfish/releases/download/v0.16.1/godfish_0.16.1_darwin_arm64.tar.gz"
    sha256 "961ae77c0f40b45b7ab39fb8e232f8b4e1ef2d3c3d14a250b53b0a7661d374e9"
  end

  if OS.linux? && Hardware::CPU.intel?
    url "https://github.com/rafaelespinoza/godfish/releases/download/v0.16.1/godfish_0.16.1_linux_amd64.tar.gz"
    sha256 "d0526260cc037044140e07cc6864f13b32ad9d174c2973038ff80adcef35d1db"
  end

  if OS.linux? && Hardware::CPU.arm?
    url "https://github.com/rafaelespinoza/godfish/releases/download/v0.16.1/godfish_0.16.1_linux_arm64.tar.gz"
    sha256 "ff3de7d70d53cc4f0387f013c147df2001571fc1a2a0def4a7bd61dda2af4a0c"
  end

  def install
    # Homebrew extracts the entire multi-binary archive. Cherry-pick only
    # the targeted binary into the installation path.
    driver_bin = "godfish-postgres"
    bin.install driver_bin

    # Generate, install shell autocompletion scripts.
    %w[bash fish zsh].each do |sh|
      generate_completions_from_executable(bin/driver_bin.to_s, "completion", sh, shells: [sh.to_sym])
    end
  end

  test do
    assert_match(/Driver:.*postgres/, shell_output("#{bin}/godfish-postgres version 2>&1"))
  end
end
