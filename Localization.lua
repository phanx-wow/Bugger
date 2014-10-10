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
	L["Current Session"] = "Aktuelle Sitzung"
	L["Previous Session"] = "Vorherige Sitzung"
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
	L["Click to open the error window."] = "Clic para mostrar la ventana de errores."
	L["Alt-click to clear all saved errors."] = "Alt-clic para borrar todos errores guardados."
	L["Shift-click to reload the UI."] = "Mayús-clic para volver a cargar la IU."
	L["Right-click for options."] = "Clic derecho para opciones."
	L["Chat frame alerts"] = "Mensajes de alerta en chat"
	L["Sound alerts"] = "Sonidos de alerta"
	L["Minimap icon"] = "Icono en minimapa"
	L["/bugger"] = "/errores"

elseif GetLocale() == "frFR" then

	L["Errors"] = "Erreurs"
	L["All Errors"] = "Toutes erreures"
	L["Current Session"] = "Session en cours"
	L["Previous Session"] = "Session précédente"
	L["An error has been captured!"] = "Une erreur a été capturé!"
	L["There are no errors to display."] = "Il n'y a pas d'erreur à afficher."
	L["All saved errors have been deleted."] = "Toutes les erreurs enregistrées ont été supprimées."
	L["Bugger can't function without !BugGrabber. Find it on Curse or WoWInterface."] = "Bugger ne peut pas fonctionner sans !BugGrabber. Trouvez-le sur Curse ou WoWInterface."
	L["Click to open the error window."] = "Cliquez pour ouvrir la fenêtre d'erreurs."
	L["Alt-click to clear all saved errors."] = "Alt-clic pour effacer toutes les erreurs."
	L["Shift-click to reload the UI."] = "Maj-clic pour recharger l'IU."
	L["Right-click for options."] = "Clic droit pour options."
	L["Chat frame alerts"] = "Messages d'alerte dans le discussion"
	L["Sound alerts"] = "Sons d'alerte"
	L["Minimap icon"] = "Icône sur la minicarte"
	L["/bugger"] = "/erreurs"

elseif GetLocale() == "itIT" then

	L["Errors"] = "Errori"
	L["All Errors"] = "Tutti errori"
	L["Current Session"] = "Sessione corrente"
	L["Previous Session"] = "Sessione precedente"
	L["An error has been captured!"] = "Un errore è stato catturato!"
	L["There are no errors to display."] = "Non ci sono errori da mostrare."
	L["All saved errors have been deleted."] = "Tutti gli errori salvati sono stati cancellari."
	L["Bugger can't function without !BugGrabber. Find it on Curse or WoWInterface."] = "Bugger non può funzionare senza !BugGrabber. Lo si può trovare su Curse o WoWInterface."
	L["Click to open the error window."] = "Clicca per mostrare la finestra di errori."
	L["Alt-click to clear all saved errors."] = "Alt-clic per cancellare tutti gli errori salvati."
	L["Shift-click to reload the UI."] = "Maiusc + clic per ricaricare l'interfaccia utente."
	L["Right-click for options."] = "Clic destro per le opzioni."
	L["Chat frame alerts"] = "Messaggi di avviso nel chat"
	L["Sound alerts"] = "Suoni di avviso"
	L["Minimap icon"] = "Icona sulla minimappa"
	L["/bugger"] = "/errori"

elseif GetLocale():match("^pt") then

	L["Errors"] = "Erros"
	L["All Errors"] = "Todos erros"
	L["Current Session"] = "Sessão atual"
	L["Previous Session"] = "Sessão anterior"
	L["An error has been captured!"] = "Um erro foi capturado!"
	L["There are no errors to display."] = "Não há erros para mostrar."
	L["All saved errors have been deleted."] = "Todos os erros guardados foram apogados."
	L["Bugger can't function without !BugGrabber. Find it on Curse or WoWInterface."] = "Bugger não pode funcionar sem !BugGrabber. Procurar no Curse ou WoWInterface."
	L["Click to open the error window."] = "Clique para mostrar a janela de erros."
	L["Alt-click to clear all saved errors."] = "Alt-clique para apagar todos os erros guardados."
	L["Shift-click to reload the UI."] = "Shift-clique para recarregar a IU."
	L["Right-click for options."] = "Clique direito para opções."
	L["Chat frame alerts"] = "Mensagens de alerta no chat"
	L["Sound alerts"] = "Sons de alerta"
	L["Minimap icon"] = "Ícone no minimapa"
	L["/bugger"] = "/erros"

elseif GetLocale() == "zhTW" then -- contributors: BNSSNB

	L["Errors"] = "錯誤"
	L["All Errors"] = "所有錯誤"
	L["Current Session"] = "目前階段"
	L["Previous Session"] = "之前階段"
	L["An error has been captured!"] = "一個錯誤已被捕捉！"
	L["There are no errors to display."] = "沒有錯誤可顯示。"
	L["All saved errors have been deleted."] = "所有儲存的錯誤已被刪除。"
	L["Bugger can't function without !BugGrabber. Find it on Curse or WoWInterface."] = "Bugger沒有!BugGrabber將無法運作。請在Curse或WoWInterface尋找它。"
	L["Click to open the error window."] = "點擊開啟錯誤視窗。"
	L["Alt-click to clear all saved errors."] = "Alt-點擊以清除所有儲存的錯誤。"
	L["Shift-click to reload the UI."] = "Shift-點擊重載UI。"
	L["Right-click for options."] = "右鍵點擊開啟選項。"
	L["Chat frame alerts"] = "聊天框架警告"
	L["Sound alerts"] = "聲音警告"
	L["Minimap icon"] = "小地圖圖標"
	L["/bugger"] = "/錯誤"

end