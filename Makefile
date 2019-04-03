default: doc

test:
	racket test.rkt

uninstall:
	raco pkg remove cuid

install:
	raco pkg install

reinstall:
	$(MAKE) uninstall
	$(MAKE) install
