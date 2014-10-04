--[[--------------------------------------------------------------------
	Bugger
	Basic GUI front-end for !BugGrabber.
	Copyright (c) 2014 Phanx. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info23144-Bugger.html
	http://www.curse.com/addons/wow/bugger
----------------------------------------------------------------------]]

local BUGGER, Bugger = ...
local L = Bugger.L

if GetLocale() == "deDE" then

	L["Errors"] = "Fehler"
	L["All Errors"] = "Alle Felher"
	L["Current Session"] = "Aktuelle Session"
	L["Previous Session"] = "Vorherige Session"
	L["An error has been captured!"] = "Ein Fehler wurde eingefangen!"
	L["There are no errors to display."] = "Es gibt keine Fehler anzuzeigen."
	L["All saved errors have been deleted."] = "Alle gespeicherten Fehler wurden gelöscht."
	L["Bugger can't function without !BugGrabber. Find it on Curse or WoWInterface."] = "Ohne !BugGrabber kann Bugger nicht funktionieren. Findet es auf Curse oder WoWInterface."
	L["Click to open the error window."] = "Klick, um das Fehler-Fenster anzuzeigen."
	L["Alt-click to clear all saved errors."] = "Alt-klick, um alle gespeicherten Fehler zu löschen."
	L["Shift-click to reload the UI."] = "Shift-klick, um die UI neu zu laden."
	L["Right-click for options."] = "Rechtsklick für Optionen."
	L["Chat frame alerts"] = "Warnmeldungen im Chatfenster"
	L["Sound alerts"] = "Warnsounds abspielen"
	L["Minimap icon"] = "Minikartensymbol anzeigen"
	L["/bugger"] = "/fehler"

elseif GetLocale():match("^es") then

	L["Errors"] = "Errores"
	L["All Errors"] = "Todos errores"
	L["Current Session"] = "Sesión actual"
	L["Previous Session"] = "Sesión anterior"
	L["An error has been captured!"] = "Un error se ha capturado!"
	L["There are no errors to display."] = "No hay errores para mostrar."
	L["All saved errors have been deleted."] = "Todos los errores guardados se han borrados."
	L["Bugger can't function without !BugGrabber. Find it on Curse or WoWInterface."] = "Bugger no puede funcionar sin !BugGrabber. Encuentralo en Curse o WoWInterface."
	L["Click to open the error window."] = "Clic para mostrar el error más reciente."
	L["Alt-click to clear all saved errors."] = "Alt-clic para borrar todos errores guardados."
	L["Shift-click to reload the UI."] = "Mayús-clic para volver a cargar la IU."
	L["Right-click for options."] = "Clic derecho para opciones."
	L["Chat frame alerts"] = "Mensajes de alerta en chat"
	L["Sound alerts"] = "Sonidos de alerta"
	L["Minimap icon"] = "Icono en minimapa"
	L["/bugger"] = "/errores"

end