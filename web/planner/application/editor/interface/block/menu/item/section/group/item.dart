part of planner;

/**
 * Menu section item class
 *
 * Base class for any menu items
 */
abstract class MenuSectionGroupItem extends InterfaceElement
{
	/*
	 * Defaults
	 */
	static const CLASS = 'gui-menu-section-content-group-item';
	
	/*
	 * Constructor
	 */
	MenuSectionGroupItem ( )
	{
		this._node = new Element.html('<span class="$CLASS"></span>');
		
		this._compose();
	}
}