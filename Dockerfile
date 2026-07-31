FROM denho/faved:latest

EXPOSE 80

ENV PORT=80

# Railway injects PORT (and sometimes other vars) at runtime; Faved listens on 80.
# Guard against Apache MPM conflicts: ensure exactly one MPM (prefork) is enabled
# before Apache starts. The base image can end up with multiple MPMs enabled when
# a2enmod/a2dismod state diverges, which aborts startup with AH00534.
RUN a2dismod mpm_event mpm_worker || true \
 && a2enmod mpm_prefork \
 && a2dismod mpm_event mpm_worker || true \
 && apache2ctl configtest

# Runtime wrapper: logs the live MPM state (diagnosing AH00534 on Railway),
# forces a single MPM, then starts Apache normally.
COPY start.sh /usr/local/bin/faved-start.sh
RUN chmod +x /usr/local/bin/faved-start.sh

CMD ["/usr/local/bin/faved-start.sh"]
