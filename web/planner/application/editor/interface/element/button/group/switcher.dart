part of planner;

class ButtonSwitcher extends ButtonGroup
{
	// Defaults
	static const CLASS = 'gui-button-switcher';
	
	// Data
	List<ButtonSwitcherItem> _switcherItems = new List<ButtonSwitcherItem>();

	// Constructor
	ButtonSwitcher ([ int orienation ]): super(orienation)
	{
		this._node.classes.add(CLASS);
	}
	
	// Register button
	void register (ButtonSwitcherItem button)
	{
		// Switch item if first
		if (this._switcherItems.isEmpty)
		{
			button.switchOn();
		}
	
		// Register button
		super.register(button);
		
		// Register item
		this._switcherItems.add(button);
		
		void clickHandler (Event event)
		{
	    	this._switcherItems.forEach((ButtonSwitcherItem item) => item.switchOff());
        				
        	button.switchOn();
		}
		
		// Listen to click
		button
		..on['click'].listen(clickHandler)
		..on['touchend'].listen(clickHandler);
	}	
}