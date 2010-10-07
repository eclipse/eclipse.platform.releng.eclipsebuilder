function expandCollapse(id) {
	expandCollapse(id, null);
}
 
function expandCollapse(id, value) {
	var element = document.getElementById(id);
	if (value == null) {
		element.className = (element.className == 'collapsable') ? '' : 'collapsable';
	} else {
		element.className = value;
	}
	var button = document.getElementById(id + '.button');
	if (element.className == 'collapsable')	
		button.src="http://eclipse.org/equinox/images/arrow.png";
	else
		button.src="http://eclipse.org/equinox/images/downarrow.png";
}
