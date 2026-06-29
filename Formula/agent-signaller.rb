class AgentSignaller < Formula
  desc "Always-visible macOS traffic light for AI coding agents (Claude Code & Codex)"
  homepage "https://github.com/Jasjah/agent-signaller"
  url "https://github.com/Jasjah/agent-signaller/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "ffa7b07a522d3075884152e01ca565667e85cec4b70dd373fe792b6ec3aa64f3"
  license "MIT"
  version "1.0.0"

  depends_on :macos
  depends_on xcode: :build

  def install
    system "swift", "build", "--disable-sandbox", "--build-system", "native", "-c", "release"
    bin_path = `swift build --disable-sandbox --build-system native -c release --show-bin-path`.strip
    bin.install "#{bin_path}/SignalerCLI" => "agent-signaller"

    # Assemble the .app bundle and install it into the prefix.
    app = "AgentSignaller.app"
    mkdir_p "#{app}/Contents/MacOS"
    mkdir_p "#{app}/Contents/Resources"
    cp "#{bin_path}/SignalerApp", "#{app}/Contents/MacOS/AgentSignaller"
    cp "#{bin_path}/SignalerCLI", "#{app}/Contents/MacOS/agent-signaller"
    cp "Resources/Info.plist", "#{app}/Contents/Info.plist"
    system "/usr/bin/codesign", "--force", "--deep", "--sign", "-", app
    prefix.install app
  end

  def caveats
    <<~EOS
      To finish setup:

        1. Copy the app to /Applications:
             cp -R #{opt_prefix}/AgentSignaller.app /Applications/

        2. Wire up Claude Code + Codex and launch:
             agent-signaller install --bin #{opt_bin}/agent-signaller
             open -a AgentSignaller

      Open a NEW Claude Code session afterward so the hooks take effect.
    EOS
  end

  test do
    assert_match "usage:", shell_output("#{bin}/agent-signaller 2>&1")
  end
end
