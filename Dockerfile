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
