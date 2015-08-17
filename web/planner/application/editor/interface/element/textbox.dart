part of planner;

class Textbox extends InterfaceElement
{
	/*
	 * Defaults
	 */
	static const STRETCH = -1,
				 
				 // Classes
				 CLASS			= 'gui-textbox',
				 STRETCH_CLASS	= 'gui-stretch';
	
	/*
	 * Constructor
	 */
	Textbox ({ String placeholder, Pattern pattern, int width })
	{
		this._node = new TextInputElement();
		
		this._node.classes.add(CLASS);
		
		if (placeholder != null)
		{
			this._node.attributes['placeholder'] = placeholder;
		}
		
		if (width == STRETCH)
		{
			this._node.classes.add(STRETCH_CLASS);
		}
		
		this._compose();
	}
}