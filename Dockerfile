# Pinned to the exact digest verified healthy on Railway (equals :latest / 2.9.1 as
# of 2026-07-31). Avoids :latest tag drift between builds.
FROM denho/faved@sha256:a0f4d9386b706c4d74f398323cf4315667e204bf833f579c25b9512cd1977046

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
