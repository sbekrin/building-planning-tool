part of planner;

/**
 * Menu section checkbox item class
 * 
 * Allows to add toggable item to section menu
 */
class MenuSectionGroupToggleableItem extends MenuSectionGroupLabelItem
{
	/*
	 * Constructor
	 */
	MenuSectionGroupToggleableItem (String text, Action action, { bool checked, bool beta }): super(text, action, icon: new Icon(null), beta: beta)
	{
		this._node.on['mousedown'].listen(this._clickHandler);
		this._node.on['touchstart'].listen(this._clickHandler);
		
		if (checked == true)
		{
			this.check();
		}
	}
	
	/*
	 * Getters
	 */
	bool get isChecked		=> this._iconNode.children.isNotEmpty;
	bool get isNotChecked	=> !this.isChecked;
	
	/**
	 * Handles item click
	 */
	void _clickHandler (Event event)
	{
		this.isChecked ? this.uncheck() : this.check();
	}
	
	/**
	 * Switches on item
	 */
	void check ( )
	{
		this.icon = new Icon('check');
	}
	
	/**
	 * Switches off item
	 */
	void uncheck ( )
	{
		this.icon = new Icon('');
	}
}