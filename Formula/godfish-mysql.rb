class GodfishMysql < Formula
  desc "Database migrations CLI for mysql"
  homepage "https://github.com/rafaelespinoza/godfish"
  version "0.16.0"
  license "ISC"

  if OS.mac? && Hardware::CPU.intel?
    url "https://github.com/rafaelespinoza/godfish/releases/download/v0.16.0/godfish_0.16.0_darwin_amd64.tar.gz"
    sha256 "7ae0a5711b402d505763209406b20d9336631a04d238a2503b45b7f77e9b5cb7"
  end

  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/rafaelespinoza/godfish/releases/download/v0.16.0/godfish_0.16.0_darwin_arm64.tar.gz"
    sha256 "cfacc2dece17883f416853cf54051a20e86e3513741f87d1d5a9f1b5f4864c3e"
  end

  if OS.linux? && Hardware::CPU.intel?
    url "https://github.com/rafaelespinoza/godfish/releases/download/v0.16.0/godfish_0.16.0_linux_amd64.tar.gz"
    sha256 "487f1457965bbc2586dc601bb6f020237255f88a35787cf2d985a48961e5e156"
  end

  if OS.linux? && Hardware::CPU.arm?
    url "https://github.com/rafaelespinoza/godfish/releases/download/v0.16.0/godfish_0.16.0_linux_arm64.tar.gz"
    sha256 "64b930097eecc8930f6ba0c34adc1b48061cb993cb7d6a64155a102ac1d553eb"
  end

  def install
    # Homebrew extracts the entire multi-binary archive. Cherry-pick only
    # the targeted binary into the installation path.
    driver_bin = "godfish-mysql"
    bin.install driver_bin

    # Generate, install shell autocompletion scripts.
    %w[bash fish zsh].each do |sh|
      generate_completions_from_executable(bin/driver_bin.to_s, "completion", sh, shells: [sh.to_sym])
    end
  end

  test do
    assert_match(/Driver:.*mysql/, shell_output("#{bin}/godfish-mysql version 2>&1"))
  end
end
