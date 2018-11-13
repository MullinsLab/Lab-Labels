FROM perl:5.28

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        texlive-xetex \
        xzdec  # for tlmgr

RUN tlmgr init-usertree --usertree $(kpsewhich -var-value TEXMFLOCAL) && \
    tlmgr install --usertree $(kpsewhich -var-value TEXMFLOCAL) droid

# See the .dockerignore file for what gets omitted
COPY . /src
WORKDIR /src

RUN cpanm --quiet --notest --installdeps .
RUN cpanm --quiet --notest Starman

EXPOSE 80
CMD [ "/usr/local/bin/starman", "--listen=:80", "--user=nobody", "--group=nogroup" ]
