part of planner;

/*
 *	Custom checkbox class.
 */
class Checkbox extends InterfaceElement
{
	// Defaults
	static const CLASS = 'gui-checkbox';

	// Constructor
	Checkbox (String content, { bool checked, Function onChange })
	{
		this._node = new Element.html('<button class="$CLASS">$content</button>');
		
		if (checked != null &&
			checked == true)
		{
			this._node.attributes['checked'] = 'checked';
		}
		
		if (onChange != null)
		{
			this._node.on['change'].listen((MouseEvent event) => Function.apply(onChange, []));
		}
		
		this._compose();
	}
	
	// Set element as checked
	void check ( )
	{
		this._node.attributes['checked'] = 'checked';
	}
	
	// Set element as unchecked
	void uncheck ( )
	{
		this._node.attributes.remove('checked');
	}
}