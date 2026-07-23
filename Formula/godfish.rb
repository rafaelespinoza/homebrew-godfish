class Godfish < Formula
  desc "Database migrations CLI for cassandra, postgres, mysql, sqlite3, sqlserver"
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
