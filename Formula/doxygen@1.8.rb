  class Doxygen < Formula
    desc "Generate documentation for several programming languages"
    homepage "https://www.doxygen.org/"
    url "https://doxygen.nl/files/doxygen-1.8.20.src.tar.gz"
    mirror "https://downloads.sourceforge.net/project/doxygen/rel-1.8.20/doxygen-1.8.20.src.tar.gz"
    sha256 "e0db6979286fd7ccd3a99af9f97397f2bae50532e4ecb312aa18862f8401ddec"
    license "GPL-2.0-only"
    head "https://github.com/doxygen/doxygen.git"
  
    bottle do
      sha256 cellar: :any_skip_relocation, arm64_monterey: "4480d3fc744af8e694082acf0f49eb1177efa777b052772dfae462d3d721c0a6"
      sha256 cellar: :any_skip_relocation, arm64_big_sur:  "394d436a05fa82a549ceff74805491fdc789c27a5ae93cfbf42d4990e24e19a5"
      sha256 cellar: :any_skip_relocation, monterey:       "861eb638fe0f4af8f43f53a0cb4c09ceb154695ff0896e9bab21531b99088a54"
      sha256 cellar: :any_skip_relocation, big_sur:        "0e08a4950256754440a961bbc22829fefeee4778c7b5249e59df0d145d247d47"
      sha256 cellar: :any_skip_relocation, catalina:       "e725c473cf26d1f43e2b85bf5859c31f6ea87c9c367153cf85f63b29ce6c318f"
      sha256 cellar: :any_skip_relocation, x86_64_linux:   "14f8ff5de43df4782711ca36f9d667530f53c6c2c96e396f183e8cc29ab34c53"
    end
  
    depends_on "bison" => :build
    depends_on "cmake" => :build
  
    uses_from_macos "flex" => :build
  
    on_linux do
      depends_on "gcc"
    end
  
    # Need gcc>=7.2. See https://gcc.gnu.org/bugzilla/show_bug.cgi?id=66297
    fails_with gcc: "5"
    fails_with gcc: "6"
  
    def install
      mkdir "build" do
        system "cmake", "..", *std_cmake_args
        system "make"
      end
      bin.install Dir["build/bin/*"]
      man1.install Dir["doc/*.1"]
    end
  
    test do
      system "#{bin}/doxygen", "-g"
      system "#{bin}/doxygen", "Doxyfile"
    end
  end