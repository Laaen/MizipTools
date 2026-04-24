content = File.read("CHANGELOG.md")
File.write("release_text", content.split("\n\n").first)

