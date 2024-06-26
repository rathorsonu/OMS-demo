require File.expand_path('../helper', __FILE__)

class TestCook < TestCase
  attr_accessor :assets_path, :tar_path, :recipe

  def before_all
    super
    @assets_path = File.expand_path("../assets", __FILE__)
    @tar_path = File.expand_path("../../tmp/test mini portile-1.0.0.tar.gz", __FILE__)

    FileUtils.rm_rf("tmp") # remove any previous test files

    create_tar(@tar_path, @assets_path, "test mini portile-1.0.0")
    start_webrick(File.dirname(@tar_path))

    @logger = StringIO.new # IO to keep recipe logs in case we need to debug
    @recipe = MiniPortile.new("test mini portile", "1.0.0").tap do |recipe|
      recipe.logger = @logger
      recipe.files << "http://localhost:#{HTTP_PORT}/#{ERB::Util.url_encode(File.basename(@tar_path))}"
      recipe.patch_files << File.join(@assets_path, "patch 1.diff")
      recipe.configure_options << "--option=\"path with 'space'\""
      git_dir = File.join(@assets_path, "git")
      with_custom_git_dir(git_dir) do
        recipe.cook
      end
    end
  rescue => e
    puts @logger.string
    raise e
  end

  def after_all
    super
    stop_webrick
    FileUtils.rm_rf("tmp") # remove test files
  end

  def test_download
    download = "ports/archives/test%20mini%20portile-1.0.0.tar.gz"
    assert File.exist?(download), download
  end

  def test_untar
    configure = File.join(work_dir, "configure")
    assert File.exist?(configure), configure
    assert_match( /^#!\/bin\/sh/, IO.read(configure) )
  end

  def test_patch
    patch1 = File.join(work_dir, "patch 1.txt")
    assert File.exist?(patch1), patch1
    assert_match( /^\tchange 1/, IO.read(patch1) )
  end

  def test_configure
    txt = File.join(work_dir, "configure.txt")
    assert File.exist?(txt), txt
    opts = recipe.configure_options + ["--prefix=#{recipe.path}"]
    assert_equal( opts.inspect, IO.read(txt).chomp )
  end

  def test_compile
    txt = File.join(work_dir, "compile.txt")
    assert File.exist?(txt), txt
    assert_equal( ["all"].inspect, IO.read(txt).chomp )
  end

  def test_install
    txt = File.join(work_dir, "install.txt")
    assert File.exist?(txt), txt
    assert_equal( ["install"].inspect, IO.read(txt).chomp )
  end
end

class TestCookConfiguration < TestCase
  def test_make_command_configuration
    without_env("MAKE") do
      assert_equal("make", MiniPortile.new("test", "1.0.0").make_cmd)
      assert_equal("xyzzy", MiniPortile.new("test", "1.0.0", make_command: "xyzzy").make_cmd)
    end
    with_env("MAKE"=>"asdf") do
      assert_equal("asdf", MiniPortile.new("test", "1.0.0").make_cmd)
      assert_equal("asdf", MiniPortile.new("test", "1.0.0", make_command: "xyzzy").make_cmd)
    end
  end

  def test_cc_command_configuration
    without_env("CC") do
      expected_compiler = RbConfig::CONFIG["CC"] || "gcc"
      assert_equal(expected_compiler, MiniPortile.new("test", "1.0.0").cc_cmd)
      assert_equal(expected_compiler, MiniPortile.new("test", "1.0.0").gcc_cmd)
      assert_equal("xyzzy", MiniPortile.new("test", "1.0.0", cc_command: "xyzzy").cc_cmd)
      assert_equal("xyzzy", MiniPortile.new("test", "1.0.0", gcc_command: "xyzzy").cc_cmd)
      assert_equal("xyzzy", MiniPortile.new("test", "1.0.0", cc_command: "xyzzy").gcc_cmd)
      assert_equal("xyzzy", MiniPortile.new("test", "1.0.0", gcc_command: "xyzzy").gcc_cmd)
    end
    with_env("CC"=>"asdf") do
      assert_equal("asdf", MiniPortile.new("test", "1.0.0").cc_cmd)
      assert_equal("asdf", MiniPortile.new("test", "1.0.0").gcc_cmd)
      assert_equal("asdf", MiniPortile.new("test", "1.0.0", cc_command: "xyzzy").cc_cmd)
      assert_equal("asdf", MiniPortile.new("test", "1.0.0", gcc_command: "xyzzy").cc_cmd)
      assert_equal("asdf", MiniPortile.new("test", "1.0.0", cc_command: "xyzzy").gcc_cmd)
      assert_equal("asdf", MiniPortile.new("test", "1.0.0", gcc_command: "xyzzy").gcc_cmd)
    end
  end

  def test_cxx_command_configuration
    without_env("CXX") do
      expected_compiler = RbConfig::CONFIG["CXX"] || "g++"
      assert_equal(expected_compiler, MiniPortile.new("test", "1.0.0").cxx_cmd)
      assert_equal("xyzzy", MiniPortile.new("test", "1.0.0", cxx_command: "xyzzy").cxx_cmd)
    end
    with_env("CXX"=>"asdf") do
      assert_equal("asdf", MiniPortile.new("test", "1.0.0").cxx_cmd)
      assert_equal("asdf", MiniPortile.new("test", "1.0.0", cxx_command: "xyzzy").cxx_cmd)
    end
  end
end


class TestCookWithBrokenGitDir < TestCase
  #
  #  this is a test for #69
  #  https://github.com/flavorjones/mini_portile/issues/69
  #
  attr_accessor :assets_path, :tar_path, :recipe

  def before_all
    super
    @assets_path = File.expand_path("../assets", __FILE__)
    @tar_path = File.expand_path("../../tmp/test-mini-portile-1.0.0.tar.gz", __FILE__)

    @git_dir = File.join(@assets_path, "git-broken")
    FileUtils.rm_rf @git_dir
    FileUtils.mkdir_p @git_dir
    Dir.chdir(@git_dir) do
      File.open ".git", "w" do |f|
        f.write "gitdir: /nonexistent"
      end
    end

    create_tar(@tar_path, @assets_path, "test mini portile-1.0.0")

    @logger = StringIO.new # IO to keep recipe logs in case we need to debug
    @recipe = MiniPortile.new("test mini portile", "1.0.0").tap do |recipe|
      recipe.logger = @logger
      recipe.files << "file://#{@tar_path}"
      recipe.patch_files << File.join(@assets_path, "patch 1.diff")
      recipe.configure_options << "--option=\"path with 'space'\""
    end

    Dir.chdir(@git_dir) do
      @recipe.cook
    end
  end

  def after_all
    FileUtils.rm_rf @git_dir
  end

  def test_patch
    Dir.chdir(@git_dir) do
      patch1 = File.join(work_dir, "patch 1.txt")
      assert File.exist?(patch1), patch1
      assert_match( /^\tchange 1/, IO.read(patch1) )
    end
  end
end

class TestCookAgainstSourceDirectory < TestCase
  attr_accessor :recipe

  def setup
    super

    @logger = StringIO.new # IO to keep recipe logs in case we need to debug
    @recipe ||= MiniPortile.new("test mini portile", "1.0.0").tap do |recipe|
      recipe.logger = @logger
      recipe.source_directory = File.expand_path("../assets/test mini portile-1.0.0", __FILE__)
    end
  end

  def test_source_directory
    recipe.cook

    path = File.join(work_dir, "configure.txt")
    assert(File.exist?(path))
    assert_equal((recipe.configure_options + ["--prefix=#{recipe.path}"]).inspect,
                 File.read(path).chomp);

    path = File.join(work_dir, "compile.txt")
    assert(File.exist?(path))
    assert_equal("[\"all\"]", File.read(path).chomp);

    path = File.join(work_dir, "install.txt")
    assert(File.exist?(path))
    assert_equal("[\"install\"]", File.read(path).chomp);
  end
end
