require "spec_helper"

describe "bundle show" do
  before :each do
    install_gemfile <<-G
      source "file://#{gem_repo1}"
      gem "rails"
    G
  end

  it "prints path if gem exists in bundle" do
    bundle "show rails"
    out.should == default_bundle_path('gems', 'rails-2.3.2').to_s
  end

  it "complains if gem not in bundle" do
    bundle "show missing"
    out.should =~ /could not find gem 'missing'/i
  end

  describe "while locked" do
    before :each do
      bundle :lock
    end

    it "prints path if gem exists in bundle" do
      bundle "show rails"
      out.should == default_bundle_path('gems', 'rails-2.3.2').to_s
    end

    it "complains if gem not in bundle" do
      bundle "show missing"
      out.should =~ /could not find gem 'missing'/i
    end
  end

end

describe "bundle show with a git repo" do
  before :each do
    @git = build_git "foo", "1.0"
  end

  it "prints out git info" do
    install_gemfile <<-G
      gem "foo", :git => "#{lib_path('foo-1.0')}"
    G
    should_be_installed "foo 1.0"

    bundle :show
    out.should include("foo (1.0 #{@git.ref_for('master', 6)}")
  end

  it "prints out branch names other than master" do
    update_git "foo", :branch => "omg" do |s|
      s.write "lib/foo.rb", "FOO = '1.0.omg'"
    end
    @revision = revision_for(lib_path("foo-1.0"))[0...6]

    install_gemfile <<-G
      gem "foo", :git => "#{lib_path('foo-1.0')}", :branch => "omg"
    G
    should_be_installed "foo 1.0.omg"

    bundle :show
    out.should include("foo (1.0 #{@git.ref_for('omg', 6)}")
  end

  it "doesn't print the branch when tied to a ref" do
    sha = revision_for(lib_path("foo-1.0"))
    install_gemfile <<-G
      gem "foo", :git => "#{lib_path('foo-1.0')}", :ref => "#{sha}"
    G

    bundle :show
    out.should include("foo (1.0 #{sha[0..6]})")
  end
end