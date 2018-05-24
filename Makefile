deps: cpanm cpanfile bin/perl
	./bin/perl ./$< -L local --quiet --notest --installdeps .

cpanm:
	curl -fsSL https://cpanmin.us > $@
	chmod +x $@
