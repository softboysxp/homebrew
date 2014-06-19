require "formula"

class Docker < Formula
  homepage "http://docker.io"
  url "https://github.com/dotcloud/docker.git", :tag => "v1.0.0"

  bottle do
    sha1 "ff9ca100ffcbf521cc4abad2a6a6a9569dd5a52b" => :mavericks
    sha1 "ec28d7907015be6898bbfee7c8c85b6ee030c6e1" => :mountain_lion
    sha1 "b9621863233b248d3efe059dcca271ed1769ada6" => :lion
  end

  option "without-completions", "Disable bash/zsh completions"
  option "without-netgo", "Disable netgo tag (required for mDNS)"

  depends_on "go" => :build

  patch :DATA if build.without? "netgo"

  def install
    ENV["GIT_DIR"] = cached_download/".git"
    ENV["AUTO_GOPATH"] = "1"
    ENV["DOCKER_CLIENTONLY"] = "1"
    ENV["CGO_ENABLED"] = build.without?("netgo") ? "1" : "0"

    system "hack/make.sh", "dynbinary"
    bin.install "bundles/#{version}/dynbinary/docker-#{version}" => "docker"

    if build.with? "completions"
      bash_completion.install "contrib/completion/bash/docker"
      zsh_completion.install "contrib/completion/zsh/_docker"
    end
  end

  test do
    system "#{bin}/docker", "--version"
  end
end

__END__
diff --git a/hack/make.sh b/hack/make.sh
index 8636756..3f379ca 100755
--- a/hack/make.sh
+++ b/hack/make.sh
@@ -96,7 +96,7 @@ LDFLAGS='
 '
 LDFLAGS_STATIC='-linkmode external'
 EXTLDFLAGS_STATIC='-static'
-BUILDFLAGS=( -a -tags "netgo static_build $DOCKER_BUILDTAGS" )
+BUILDFLAGS=( -a -tags "static_build $DOCKER_BUILDTAGS" )
 
 # A few more flags that are specific just to building a completely-static binary (see hack/make/binary)
 # PLEASE do not use these anywhere else.

diff --git a/pkg/libcontainer/namespaces/nsenter.go b/pkg/libcontainer/namespaces/nsenter.go
index d5c2e76..db5b699 100644
--- a/pkg/libcontainer/namespaces/nsenter.go
+++ b/pkg/libcontainer/namespaces/nsenter.go
@@ -1,3 +1,5 @@
+// +build !darwin
+
 package namespaces
 
 /*

