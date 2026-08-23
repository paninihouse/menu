PREFIX ?= $(HOME)/.local

.PHONY: build
build: .build/release/menu .build/plugins/GenerateManual/outputs/menu/menu.1

.build/release/menu:
	swift build -c release

.build/plugins/GenerateManual/outputs/menu/menu.1:
	swift package generate-manual

.PHONY: clean
clean:
	@rm -rf .build .docc-build .docs

.PHONY: install
install: build
	@install -d $(PREFIX)/bin/
	@install -Dm755 .build/release/menu $(PREFIX)/bin/
	@install -d $(PREFIX)/share/man/man1/
	@install -Dm644 .build/plugins/GenerateManual/outputs/menu/menu.1 $(PREFIX)/share/man/man1/

.PHONY: uninstall
uninstall:
	@rm -f $(PREFIX)/bin/menu
	@rm -f $(PREFIX)/share/man/man1/menu.1

.PHONY: docs
docs: .build/release/menu
	@$(MAKE) -C Sources/menu/menu.docc build

.PHONY: docs-preview
docs-preview: .build/release/menu
	@$(MAKE) -C Sources/menu/menu.docc preview
