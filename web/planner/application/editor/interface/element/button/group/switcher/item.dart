part of planner;

class ButtonSwitcherItem extends Button
{
	// Defaults
	static const CLASS = 'gui-element-switched';

	// Constructors
	ButtonSwitcherItem (String content, Action action, { String tooltip }): super(content, action, tooltip: tooltip)
	{
		this._bindEvents();
	}
	
	ButtonSwitcherItem.fromButton (Button button): super(button.content, button.action, tooltip: button.tooltip)
	{
		this._bindEvents();
	}
		
	// Getters
	bool get isSwitchedOn	=> this._node.classes.contains(CLASS);
	bool get isSwitchedOff	=> !this.isSwitchedOn;
	
	// Bind events
	void _bindEvents ( )
	{
		this.on['click'].listen((MouseEvent event)
			{
				if (this.isSwitchedOn)
				{
					event.preventDefault();
					
					return false;
				}
			}
		);
	}
	
	// Switch item on
	void switchOn ( )
	{
		this._node.classes.add(CLASS);
	}
	
	void switchOff ( )
	{
		this._node.classes.remove(CLASS);
	}
}