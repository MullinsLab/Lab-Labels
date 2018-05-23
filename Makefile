deps: cpanm cpanfile
	perl ./$< -L local --quiet --notest --installdeps .

cpanm:
	curl -fsSL https://cpanmin.us > $@
	chmod +x $@
