.PHONY: all

VERSION = v0

all: test-$(VERSION)

test-$(VERSION): test-$(VERSION).cc svf-$(VERSION).h
	g++ -Wall -Wextra -g -o test-$(VERSION) test-$(VERSION).cc

svf-$(VERSION).h: svf.h.in
	cat svf.h.in | sed -e 's/VERSION/$(VERSION)/g' > svf-$(VERSION).h

test-$(VERSION).cc: test.cc.in
	cat test.cc.in | sed -e 's/VERSION/$(VERSION)/g' > test-$(VERSION).cc


