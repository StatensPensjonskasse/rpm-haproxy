HOME=$(shell pwd)
MAINVERSION=2.0
ifeq ("${VERSION}", "")
		VERSION=$(shell wget -qO- http://git.haproxy.org/git/haproxy-${MAINVERSION}.git/refs/tags/ | sed -n 's:.*>\(.*\)</a>.*:\1:p' | sed 's/^.//' | sort -rV | head -1)
endif
ifeq ("${VERSION}","./")
		VERSION="${MAINVERSION}.0"
endif
ifeq ("${RELEASE}", "")
        RELEASE=1
endif

all: build

install_prereq:
	sudo yum install -y pcre-devel make gcc openssl-devel rpm-build systemd-devel wget sed zlib-devel

check_lua_env:
	@if  [ -z "${LUA_PACKAGE}" ]; then echo "Environment not prepared for build with Lua. Run 'prep-lua-deps.sh' and 'source setEnv'";  exit 1; fi;
	@if  [ -z "${LUA_INC}" ]; then echo "Environment not prepared for build with Lua. Run 'prep-lua-deps.sh' and 'source setEnv'";  exit 1; fi;
	@if  [ -z "${LUA_LIB}" ]; then echo "Environment not prepared for build with Lua. Run 'prep-lua-deps.sh' and 'source setEnv'";  exit 1; fi;

install_lua:
	sudo yum install -y ${LUA_PACKAGE}

clean:
	rm -f ./SOURCES/haproxy-${VERSION}.tar.gz
	rm -rf ./rpmbuild
	mkdir -p ./rpmbuild/SPECS/ ./rpmbuild/SOURCES/ ./rpmbuild/RPMS/ ./rpmbuild/SRPMS/
	rm -rf ./lua-${LUA_VERSION}*

download-upstream:
	wget http://www.haproxy.org/download/${MAINVERSION}/src/haproxy-${VERSION}.tar.gz -O ./SOURCES/haproxy-${VERSION}.tar.gz

build_lua:
	sudo yum install -y readline-devel
	wget https://www.lua.org/ftp/lua-${LUA_VERSION}.tar.gz
	tar xzf lua-${LUA_VERSION}.tar.gz
	cd lua-${LUA_VERSION}
	$(MAKE) -C lua-${LUA_VERSION} clean
	$(MAKE) -C lua-${LUA_VERSION} MYCFLAGS=-fPIC linux test  # MYCFLAGS=-fPIC is required during linux ld
	$(MAKE) -C lua-${LUA_VERSION} install

build_stages := install_prereq clean download-upstream
ifeq ($(USE_LUA),1)
	build_stages += build_lua
endif

build: $(build_stages)
	cp -r ./SPECS/* ./rpmbuild/SPECS/ || true
	cp -r ./SOURCES/* ./rpmbuild/SOURCES/ || true
	rpmbuild -ba SPECS/haproxy.spec \
	--define "mainversion ${MAINVERSION}" \
	--define "version ${VERSION}" \
	--define "release ${RELEASE}" \
	--define "_topdir %(pwd)/rpmbuild" \
	--define "_builddir %{_topdir}/BUILD" \
	--define "_buildroot %{_topdir}/BUILDROOT" \
	--define "_rpmdir %{_topdir}/RPMS" \
	--define "_srcrpmdir %{_topdir}/SRPMS"

build-with-lua: check_lua_env install_prereq install_lua clean download-upstream
	cp -r ./SPECS/* ./rpmbuild/SPECS/ || true
	cp -r ./SOURCES/* ./rpmbuild/SOURCES/ || true
	rpmbuild -ba SPECS/haproxy.spec \
	--define "version ${VERSION}" \
	--define "release ${RELEASE}" \
	--define "use_lua 1" \
	--define "lua_package ${LUA_PACKAGE}" \
	--define "lua_inc ${LUA_INC}" \
	--define "lua_lib ${LUA_LIB}" \
	--define "_topdir %(pwd)/rpmbuild" \
	--define "_builddir %{_topdir}/BUILD" \
	--define "_buildroot %{_topdir}/BUILDROOT" \
	--define "_rpmdir %{_topdir}/RPMS" \
	--define "_srcrpmdir %{_topdir}/SRPMS"
