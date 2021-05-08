LIBRARY = library
HANDLER = handler

Q       = @

all: membrane_handler membrane_library

membrane_handler:
	$(Q) echo "[Build] Building handler..."
	$(Q) cd $(HANDLER); make
	$(Q) cp $(HANDLER)/.theos/obj/debug/membrane .
	$(Q) echo "[Build] Done."

membrane_library:
	$(Q) echo "[Build] Building library..."
	$(Q) cd $(LIBRARY); make
	$(Q) cp $(LIBRARY)/.theos/obj/debug/membrane.dylib .
	$(Q) echo "[Build] Done."
