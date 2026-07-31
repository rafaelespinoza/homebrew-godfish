class GodfishCassandra < Formula
  desc "Database migrations CLI for cassandra"
  homepage "https://github.com/rafaelespinoza/godfish"
  license "ISC"

  if OS.mac? && Hardware::CPU.intel?
    url "https://github.com/rafaelespinoza/godfish/releases/download/v0.17.0/godfish_0.17.0_darwin_amd64.tar.gz"
    sha256 "f557c160055bb3a85f35ff255031c666d259aa1071c737414747ce15eccbdd22"
  end

  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/rafaelespinoza/godfish/releases/download/v0.17.0/godfish_0.17.0_darwin_arm64.tar.gz"
    sha256 "9c10a9b9980e2b00ae16e7b55dbaef45f15b68884b9f082a0ca01f66143b9352"
  end

  if OS.linux? && Hardware::CPU.intel?
    url "https://github.com/rafaelespinoza/godfish/releases/download/v0.17.0/godfish_0.17.0_linux_amd64.tar.gz"
    sha256 "2485e061cd5946d0fa876abb8eccc1d3a982562d04d711141623bdae6e77a231"
  end

  if OS.linux? && Hardware::CPU.arm?
    url "https://github.com/rafaelespinoza/godfish/releases/download/v0.17.0/godfish_0.17.0_linux_arm64.tar.gz"
    sha256 "dd18f951f942014c0d66a3a71a0e27a6ac797ea7a38fbeedebd9f5a92a8313e0"
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
