part of planner;

/**
 *	Custom button class
 */
class Button extends InterfaceElement
{
	/*
	 * Defaults
	 */
	static const CLASS				= 'gui-button',
				 CONTENT_CLASS		= 'gui-button-content',
				 BACKGROUND_CLASS	= 'gui-button-background';

	/*
	 * Data
	 */
	Action _action;
	
	/*
	 * Constructor
	 */
	Button (String content, Action action, { String tooltip, bool disabled })
	{
		this._action = action;
		
		this._node = new Element.html('<button class="$CLASS">$content</button>');
		
		this._node
		..on['click'].listen(this._buttonElementClickHanlder)
		..on['touchend'].listen(this._buttonElementClickHanlder);
		
		if (tooltip != null)
		{
			this.tooltip = tooltip;
		}
		
		if (disabled == true)
		{
			this.disable();
		}
		
		this._compose();
	}
	
	/*
	 * Getters
	 */
	String get content => this._node.innerHtml;
	String get tooltip => this._node.title;
	Action get action => this._action;
	
	/**
	 * Handles button click
	 */
	void _buttonElementClickHanlder (Event event)
	{
		action.execute();
	}
	
	/**
	 * Click alias
	 */
	void click ( ) => this._node.click();
}