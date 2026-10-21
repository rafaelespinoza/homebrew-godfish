class Godfish < Formula
  desc "Database migrations CLI for cassandra, postgres, mysql, sqlite3, sqlserver"
  homepage "https://github.com/rafaelespinoza/godfish"
  license "ISC"

  if OS.mac? && Hardware::CPU.intel?
    url "https://github.com/rafaelespinoza/godfish/releases/download/v0.18.1/godfish_0.18.1_darwin_amd64.tar.gz"
    sha256 "a850026a78907faf601143f709cafd391119dd356909964e9984cf699d03cc02"
  end

  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/rafaelespinoza/godfish/releases/download/v0.18.1/godfish_0.18.1_darwin_arm64.tar.gz"
    sha256 "76bc3782626eefe6fc39540ff97e0b884b765c6001deb7ff89b8c551cedd9d0f"
  end

  if OS.linux? && Hardware::CPU.intel?
    url "https://github.com/rafaelespinoza/godfish/releases/download/v0.18.1/godfish_0.18.1_linux_amd64.tar.gz"
    sha256 "d6106b0f71267e920d863a27ea1d7c96781a0771fe518ffb7a9e4cd589428842"
  end

  if OS.linux? && Hardware::CPU.arm?
    url "https://github.com/rafaelespinoza/godfish/releases/download/v0.18.1/godfish_0.18.1_linux_arm64.tar.gz"
    sha256 "9113c0146039d97b87eb03e7f5fa4421d8e59f6909021dc560b998307435d3d7"
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
