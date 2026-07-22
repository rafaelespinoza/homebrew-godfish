class Godfish < Formula
  desc "Database migrations CLIs for cassandra, postgres, mysql, sqlite3, sqlserver"
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
