LIBRARY = library
HANDLER = handler

Q       = @

all: membrane-handler membrane-library

membrane-handler:
	$(Q) echo "[Build] Building handler..."
	$(Q) cd $(HANDLER); make
	$(Q) cp $(HANDLER)/.theos/obj/debug/membrane .
	$(Q) echo "[Build] Done."

membrane-library:
	$(Q) echo "[Build] Building library..."
	$(Q) cd $(LIBRARY); make
	$(Q) cp $(LIBRARY)/.theos/obj/debug/membrane.dylib .
	$(Q) echo "[Build] Done."
