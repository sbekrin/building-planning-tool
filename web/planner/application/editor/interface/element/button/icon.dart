part of planner;

class IconButton extends Button
{
	IconButton (Icon icon, Action action, { String tooltip, bool disabled }):
		super(icon.toString(), action, tooltip: tooltip, disabled: disabled);
}