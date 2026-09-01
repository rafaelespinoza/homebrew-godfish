class GodfishCassandra < Formula
  desc "Database migrations CLI for cassandra"
  homepage "https://github.com/rafaelespinoza/godfish"
  license "ISC"

  if OS.mac? && Hardware::CPU.intel?
    url "https://github.com/rafaelespinoza/godfish/releases/download/v0.18.0/godfish_0.18.0_darwin_amd64.tar.gz"
    sha256 "d8a81b5993f2e216f276109eed48e5f0971eb4094759afaaa302904d7a275b57"
  end

  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/rafaelespinoza/godfish/releases/download/v0.18.0/godfish_0.18.0_darwin_arm64.tar.gz"
    sha256 "83a872492ff88902150ab9bf9c46830867746c3e091b6df440dcb098e63d3006"
  end

  if OS.linux? && Hardware::CPU.intel?
    url "https://github.com/rafaelespinoza/godfish/releases/download/v0.18.0/godfish_0.18.0_linux_amd64.tar.gz"
    sha256 "071818c3f1e1ba255379c29c55066bcea8bf45132c254d4e6c3292bad6889e8b"
  end

  if OS.linux? && Hardware::CPU.arm?
    url "https://github.com/rafaelespinoza/godfish/releases/download/v0.18.0/godfish_0.18.0_linux_arm64.tar.gz"
    sha256 "5b4afdd6ae20ed81db74183794dd136debc57a1741ddc62a24776f0786aadcbc"
  end

  def install
    # Homebrew extracts the entire multi-binary archive. Cherry-pick only
    # the targeted binary into the installation path.
    driver_bin = "godfish-cassandra"
    bin.install driver_bin

    # Generate, install shell autocompletion scripts.
    %w[bash fish zsh].each do |sh|
      generate_completions_from_executable(bin/driver_bin.to_s, "completion", sh, shells: [sh.to_sym])
    end
  end

  test do
    assert_match(/Driver:.*cassandra/, shell_output("#{bin}/godfish-cassandra version 2>&1"))
  end
end
