FROM ortussolutions/commandbox:jdk17

# The application webroot within the mounted /app volume. This is baked into the finalized
# startup script during the build, so changing it requires a rebuild (docker compose build).
ENV APP_DIR=/app/wwwroot

# Custom fonts for image generation.
COPY docker/usr/share/fonts/truetype/custom/roboto/static/*.ttf /usr/share/fonts/truetype/custom/roboto/static/

# Copy the server.json so that CommandBox can pre-install the Adobe ColdFusion engine
# during the Docker build. This uses the FINALIZE_STARTUP flag to generate an authoritative
# startup script, which means CommandBox doesn't have to re-download the ColdFusion engine
# or re-evaluate the server configuration on every container start.
COPY docker/server.json /app/wwwroot/server.json
RUN export FINALIZE_STARTUP=true && \
	$BUILD_DIR/run.sh && \
	unset FINALIZE_STARTUP
