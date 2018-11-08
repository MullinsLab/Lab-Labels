deps: bin/cpanm cpanfile bin/perl
	./bin/perl ./$< -L local --quiet --notest --installdeps .

bin/cpanm:
	mkdir -p $(dir $@)
	curl -fsSL https://cpanmin.us > $@
	chmod +x $@
