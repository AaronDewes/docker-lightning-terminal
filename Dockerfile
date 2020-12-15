ARG VERSION=v0.3.3-alpha

FROM lightninglabs/lightning-terminal:$VERSION

RUN adduser --disabled-password --uid 1000 --home /lit --gecos "" lit
USER lit

COPY entrypoint.sh /bin/entrypoint
RUN chmod a+x /bin/entrypoint

EXPOSE 8443 10009 9735

ENTRYPOINT ["/bin/entrypoint"]
