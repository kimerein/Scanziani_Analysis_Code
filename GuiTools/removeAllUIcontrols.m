function removeAllUIcontrols(hFig)


hTemp = findall(hFig,'Type','uicontrol');
delete(hTemp)

