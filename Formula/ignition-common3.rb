class IgnitionCommon3 < Formula
  desc "Common libraries for robotics applications"
  homepage "https://github.com/ignitionrobotics/ign-common"
  url "https://osrf-distributions.s3.amazonaws.com/ign-common/releases/ignition-common3-3.14.0.tar.bz2"
  sha256 "ab8f1cbb3bb62649cbe096bbccac43c240dad197f3d5df3360e9eac8f04a9cda"
  license "Apache-2.0"
  revision 2

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, big_sur:  "3effc94c28838a58112d7d0e0a3682e6b99b0639c3bbd499cceedda43e897722"
    sha256 cellar: :any, catalina: "00583fdf7d448bd98e52035c21705c86dd91b2f0787290004239e0f4ce72d321"
  end

  depends_on "cmake"
  depends_on "ffmpeg@4"
  depends_on "freeimage"
  depends_on "gts"
  depends_on "ignition-cmake2"
  depends_on "ignition-math6"
  depends_on macos: :high_sierra # c++17
  depends_on "ossp-uuid"
  depends_on "pkg-config"
  depends_on "tinyxml2"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=Off"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpath}"

    if Hardware::CPU.arm?
      # REVISIT: this works around a crash on Apple M1 processors
      # https://github.com/osrf/homebrew-simulation/pull/1698#discussion_r774674536
      cmake_args << "-DIGN_PROFILER_REMOTERY=Off"
    end

    system "cmake", ".", *cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<-EOS
      #include <iostream>
      #include <ignition/common.hh>
      int main() {
        igndbg << "debug" << std::endl;
        ignwarn << "warn" << std::endl;
        ignerr << "error" << std::endl;
        // // this example code doesn't compile
        // try {
        //   ignthrow("An example exception that is caught.");
        // }
        // catch(const ignition::common::exception &_e) {
        //   std::cerr << "Caught a runtime error " << _e.what() << std::endl;
        // }
        // ignassert(0 == 0);
        return 0;
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.5 FATAL_ERROR)
      find_package(ignition-common3 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ${IGNITION-COMMON_LIBRARIES})
    EOS
    system "pkg-config", "ignition-common3"
    cflags = `pkg-config --cflags ignition-common3`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-common3",
                   "-lc++",
                   "-o", "test"
    system "./test"
    # test building with cmake
    mkdir "build" do
      ENV.append "LIBRARY_PATH", Formula["gettext"].opt_lib
      system "cmake", ".."
      system "make"
      system "./test_cmake"
    end
    # check for Xcode frameworks in bottle
    # ! requires system with single argument, which uses standard shell
    # put in variable to avoid audit complaint
    # enclose / in [] so the following line won't match itself
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
