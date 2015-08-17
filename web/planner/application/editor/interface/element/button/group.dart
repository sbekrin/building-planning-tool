part of planner;

class ButtonGroup extends InterfaceBlock
{
	// Defaults
	static const CLASS				= 'gui-button-group',
				 HORIZAL			= 'gui-button-group-horizal',
				 VERTICAL			= 'gui-button-group-vertical',
				 ZINDEX_FIX_CLASS	= 'gui-button-zindex-fix';

	// Data
	List<Button> _items = new List<Button>();
	
	// Constructor
	// TODO: Add horizal and vertical styles
	ButtonGroup ([ int orientation ])
	{
		this._node = new Element.html('<div class="$CLASS"></div>');
		
		this._zindexFix();
	}
	
	// Fix flickering
	void _zindexFix ( )
	{
		// Move button forward
		this._node.on['mouseover'].listen((MouseEvent event) => this._node.classes.add(ZINDEX_FIX_CLASS));
		
		// Wait same time as transition
		this._node.on['mouseleave'].listen((MouseEvent event)
			{
				new Timer(new Duration(milliseconds: 10), ()
					{
						this._node.classes.remove(ZINDEX_FIX_CLASS);
					}
				);
			}
		);
	}
	
	// Register button
	void register (Button button)
	{
		this._items.add(button);
		this._node.children.add(button.node);
	}
}