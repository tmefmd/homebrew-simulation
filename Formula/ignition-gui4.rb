class IgnitionGui4 < Formula
  desc "Common libraries for robotics applications. GUI Library"
  homepage "https://github.com/ignitionrobotics/ign-gui"
  url "https://osrf-distributions.s3.amazonaws.com/ign-gui/releases/ignition-gui4-4.6.0.tar.bz2"
  sha256 "597d8e55115d3b36e6ae3659249efa4eb12e2183fc4399993ada0c7b56617313"
  license "Apache-2.0"
  revision 2

  head "https://github.com/ignitionrobotics/ign-gui.git", branch: "ign-gui4"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 big_sur:  "adce58f79d6ae84621e416b75f83923c84e7fbaf4bfd37fc0fe49a21c1eeff6d"
    sha256 catalina: "41b564ff41bcbeab3b6fe22bec331fc22c8fb46439bf99477e009a4b0bcf8517"
  end

  disable! date: "2022-02-28", because: "is past end-of-life date"
  deprecate! date: "2021-12-31", because: "is past end-of-life date"

  depends_on "cmake" => [:build, :test]
  depends_on "pkg-config" => [:build, :test]
  depends_on "ignition-cmake2"
  depends_on "ignition-common3"
  depends_on "ignition-msgs6"
  depends_on "ignition-plugin1"
  depends_on "ignition-rendering4"
  depends_on "ignition-transport9"
  depends_on macos: :mojave # c++17
  depends_on "qt@5"
  depends_on "tinyxml2"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=Off"

    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
  end

  test do
    (testpath/"test.cpp").write <<-EOS
    #include <iostream>

    #ifndef Q_MOC_RUN
      #include <ignition/gui/qt.h>
      #include <ignition/gui/Application.hh>
      #include <ignition/gui/MainWindow.hh>
    #endif

    //////////////////////////////////////////////////
    int main(int _argc, char **_argv)
    {
      std::cout << "Hello, GUI!" << std::endl;

      // Increase verboosity so we see all messages
      ignition::common::Console::SetVerbosity(4);

      // Create app
      ignition::gui::Application app(_argc, _argv);

      // Load plugins / config
      if (!app.LoadPlugin("Publisher"))
      {
        return 1;
      }

      // Customize main window
      auto win = app.findChild<ignition::gui::MainWindow *>()->QuickWindow();
      win->setProperty("title", "Hello Window!");

      // Run window
      // app.exec();

      std::cout << "After run" << std::endl;

      return 0;
    }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.5 FATAL_ERROR)
      find_package(ignition-gui4 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-gui4::ignition-gui4)
    EOS
    ENV.append_path "PKG_CONFIG_PATH", Formula["qt@5"].opt_lib/"pkgconfig"
    system "pkg-config", "ignition-gui4"
    cflags   = `pkg-config --cflags ignition-gui4`.split
    ldflags  = `pkg-config --libs ignition-gui4`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   *ldflags,
                   "-lc++",
                   "-o", "test"
    ENV["IGN_PARTITION"] = rand((1 << 32) - 1).to_s
    system "./test"
    # test building with cmake
    ENV.append_path "CMAKE_PREFIX_PATH", Formula["qt@5"].opt_prefix
    mkdir "build" do
      system "cmake", ".."
      system "make"
      system "./test_cmake"
    end
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
