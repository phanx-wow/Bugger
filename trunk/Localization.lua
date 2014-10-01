local BUGGER, Bugger = ...
local L = Bugger.L

if GetLocale() == "deDE" then

	L["Errors"] = "Fehler"
	L["Current Session"] = "Aktuelle Session"
	L["Previous Session"] = "Vorherige Session"
	L["All Sessions"] = "Alle Sessions"
	L["An error has been captured!"] = "Ein Fehler wurde eingefangen!"
	L["There are no errors to display."] = "Es gibt keine Fehler anzuzeigen."
	L["All saved errors have been deleted."] = "Alle gespeicherten Fehler wurden gelöscht."
	L["Bugger can't function without !BugGrabber. Find it on Curse or WoWInterface."] = "Ohne !BugGrabber kann Bugger nicht funktionieren. Findet es auf Curse oder WoWInterface."
	L["Click to open the error window."] = "Klick, um das Fehler-Fenster anzuzeigen."
	L["Alt-click to clear all saved errors."] = "Alt-klick, um alle gespeicherten Fehler zu löschen."
	L["Ctrl-click to reload the UI."] = "Strg-klick, um die UI neuzuladen."
	L["Right-click for options."] = "Rechtsklick für Optionen."
	L["/bugger"] = "/fehler"

elseif GetLocale():match("^es") then

	L["Errors"] = "Errores"
	L["Current Session"] = "Sesión actual"
	L["Previous Session"] = "Sesión anterior"
	L["All Sessions"] = "Todas sesiones"
	L["An error has been captured!"] = "Un error se ha capturado!"
	L["There are no errors to display."] = "No hay errores para mostrar."
	L["All saved errors have been deleted."] = "Todos los errores guardados se han borrados."
	L["Bugger can't function without !BugGrabber. Find it on Curse or WoWInterface."] = "Bugger no puede funcionar sin !BugGrabber. Encuentralo en Curse o WoWInterface."
	L["Click to open the error window."] = "Clic para mostrar el error más reciente."
	L["Alt-click to clear all saved errors."] = "Alt-clic para borrar todos errores guardados."
	L["Ctrl-click to reload the UI."] = "Ctrl-clic para recargar la IU."
	L["Right-click for options."] = "Clic derecho para opciones."
	L["/bugger"] = "/errores"

end