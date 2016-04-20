JAVA_VERSION = $(shelll java -version 2>&1 | grep -e "[^\d\.]1\.8")
edit:
ifeq ($(JAVA_VERSION),'')
	echo "not java-1.8"
else
	echo "java 1.8"
endif
