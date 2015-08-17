part of planner;

/**
 * Context menu section is temp section for
 * selected stuff mostly
 */
class ContextMenuSection extends MenuSection
{
	static const CLASS			= 'special',
				 CREATE_EVENT	= 'onSpecialMenuSectionCreate',
				 CLOSE_EVENT	= 'onSpecialMenuSectionClose';
	
	ContextMenuSection (String title, [ List<MenuSectionGroup> groups ]): super (title, groups)
	{
		this._node.classes.add(CLASS);
	}
}