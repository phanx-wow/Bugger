local BUGGER, Bugger = ...
local L = Bugger.L

if GetLocale() == "deDE" then

	L["Errors"] = "Fehler"
	L["An error has been captured!"] = "Ein Fehler wurde eingefangen!"
	L["No errors have been captured."] = "Keine Fehler wurde in dieser Session eingefangen."
	L["Click to open the error window."] = "Klick, um das Fehler-Fenster anzuzeigen."
	L["Alt-click to clear all saved errors."] = "Alt-klick, um alle gespeicherten Fehler zu löschen."
	L["All saved errors have been deleted."] = "Alle gespeicherten Fehler wurden gelöscht."
	L["Shift-click to reload the UI."] = "Shift-klick, um die UI neuzuladen."
	L["Right-click for options."] = "Rechtsklick für Optionen."
	L["/bugger"] = "/fehler"

elseif GetLocale():match("^es") then

	L["Errors"] = "Errores"
	L["An error has been captured!"] = "Un error se ha capturado!"
	L["No errors have been captured."] = "Ningunos errores se han capturados en esta sesión."
	L["Click to open the error window."] = "Clic para mostrar el error más reciente."
	L["Alt-click to clear all saved errors."] = "Alt-clic para borrar todos errores guardados."
	L["All saved errors have been deleted."] = "Todos los errores guardados se han borrados."
	L["Shift-click to reload the UI."] = "Mayús-clic para recargar la IU."
	L["Right-click for options."] = "Clic derecho para opciones."
	L["/bugger"] = "/errores"

end