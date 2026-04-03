.PHONY: all build clean install help

PLUGIN_NAME = hello-world-test
OUTPUT_DIR = build

# Platform detection
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
	PLUGIN_EXT = .so
	PLATFORM = linux
endif
ifeq ($(UNAME_S),Darwin)
	PLUGIN_EXT = .so
	PLATFORM = darwin
endif

# Architecture detection
UNAME_M := $(shell uname -m)
ifeq ($(UNAME_M),x86_64)
	ARCH = amd64
endif
ifeq ($(UNAME_M),arm64)
	ARCH = arm64
endif

OUTPUT = $(OUTPUT_DIR)/$(PLUGIN_NAME)$(PLUGIN_EXT)

# Path to the bifrost repo root (must contain go.work).
# Override via: make build BIFROST_DIR=/path/to/bifrost
BIFROST_DIR ?= $(shell cd ../../bifrost 2>/dev/null && pwd)

build: ## Build the plugin for current platform
	@echo "Building plugin for $(PLATFORM)/$(ARCH)..."
	@mkdir -p $(OUTPUT_DIR)
	@if [ -z "$(BIFROST_DIR)" ] || [ ! -f "$(BIFROST_DIR)/go.work" ]; then \
		echo "ERROR: BIFROST_DIR not set or go.work not found. Run: make build BIFROST_DIR=/path/to/bifrost"; \
		exit 1; \
	fi
	GOWORK=$(BIFROST_DIR)/go.work GOFLAGS="" CGO_ENABLED=1 \
		go build -buildmode=plugin -o $(OUTPUT) main.go
	@echo "Plugin built successfully: $(OUTPUT)"

clean: ## Remove build artifacts
	@rm -rf $(OUTPUT_DIR)

install: build ## Build and install to Bifrost plugins directory
	@mkdir -p ~/.bifrost/plugins
	@cp $(OUTPUT) ~/.bifrost/plugins/
	@echo "Plugin installed to ~/.bifrost/plugins/"
