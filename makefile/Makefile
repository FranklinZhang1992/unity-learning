JAVA_VERSION = $(shell java -version 2>&1 | grep -e "[^\d\.]1\.8")
PROJECT_FOLDER := $(shell pwd)

edit:
	echo "base foler is $(PROJECT_FOLDER)"
	scripts/test
  ifeq ($(JAVA_VERSION),'')
	echo "not java-1.8"
  else
	echo "java 1.8"
  endif
