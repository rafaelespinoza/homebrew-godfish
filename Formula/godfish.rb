class Godfish < Formula
  desc "Database migrations CLI for cassandra, postgres, mysql, sqlite3, sqlserver"
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
    bin.install "godfish"

    # Copy shell autocompletion scripts.
    src_autocomplete_dir = "completions"
    bash_completion.install "#{src_autocomplete_dir}/godfish.bash" => "godfish"
    fish_completion.install "#{src_autocomplete_dir}/godfish.fish" => "godfish.fish"
    zsh_completion.install "#{src_autocomplete_dir}/godfish.zsh" => "_godfish"
  end

  test do
    %w[cassandra postgres mysql sqlite3 sqlserver].each do |driver|
      # Execute the main godfish cmd for each driver name
      output = shell_output("#{bin}/godfish #{driver} version 2>&1")

      # Assert the output matches the expected /Driver:.*${driver_name}/ pattern
      assert_match(/Driver:.*#{driver}/, output)
    end
  end
end
