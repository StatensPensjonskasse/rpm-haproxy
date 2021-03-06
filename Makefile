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

opts=--define "version ${VERSION}" \
 --define "release ${RELEASE}" \
 --define "_topdir %(pwd)/rpmbuild" \
 --define "_builddir %{_topdir}/BUILD" \
 --define "_buildroot %{_topdir}/BUILDROOT" \
 --define "_rpmdir %{_topdir}/RPMS" \
 --define "_srcrpmdir %{_topdir}/SRPMS" \
 --define "extra_objs ${EXTRA_OBJS}"

ifeq ("${USE_LUA}","1")
lua_opts=--define "use_lua 1" \
--define "lua_package ${LUA_PACKAGE}" \
--define "lua_inc ${LUA_INC}" \
--define "lua_lib ${LUA_LIB}"
endif

ifneq ("${EXTRA_OBJS}","")
extra_objs_opts=--define "extra_objs ${EXTRA_OBJS}"
endif

all: build

install_prereq:
	sudo yum install -y pcre-devel make gcc openssl-devel rpm-build systemd-devel wget sed zlib-devel

check_lua_env:
	@if  [ -z "${LUA_PACKAGE}" ]; then echo "Environment not prepared for build with Lua. Run 'prep-lua-deps.sh' and 'source setEnv'";  exit 1; fi;
	@if  [ -z "${LUA_INC}" ]; then echo "Environment not prepared for build with Lua. Run 'prep-lua-deps.sh' and 'source setEnv'";  exit 1; fi;
	@if  [ -z "${LUA_LIB}" ]; then echo "Environment not prepared for build with Lua. Run 'prep-lua-deps.sh' and 'source setEnv'";  exit 1; fi;

install_lua:
	@if  [ "${USE_LUA}" ]; then sudo yum install -y ${LUA_PACKAGE}; fi;

clean:
	rm -f ./SOURCES/haproxy-${VERSION}.tar.gz
	rm -rf ./rpmbuild
	mkdir -p ./rpmbuild/SPECS/ ./rpmbuild/SOURCES/ ./rpmbuild/RPMS/ ./rpmbuild/SRPMS/

download-upstream:
	wget http://www.haproxy.org/download/${MAINVERSION}/src/haproxy-${VERSION}.tar.gz -O ./SOURCES/haproxy-${VERSION}.tar.gz

build: install_prereq install_lua clean download-upstream
	cp -r ./SPECS/* ./rpmbuild/SPECS/ || true
	cp -r ./SOURCES/* ./rpmbuild/SOURCES/ || true
	rpmbuild -ba SPECS/haproxy.spec $(opts) $(lua_opts) $(extra_objs_opts)
