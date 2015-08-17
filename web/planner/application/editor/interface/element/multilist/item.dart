part of planner;

class MultilistItem extends InterfaceElement
{
	// Defaults
	static const CLASS				= 'gui-multilist-item',
				 SELECTED_CLASS		= 'gui-multilist-item-selected',
				 
				 // Events
				 SELECT_EVENT		= 'listItemSelect',
				 DRAG_START_EVENT	= 'listItemDragStart',
				 DRAG_MOVE_EVENT	= 'listItemDragMove',
				 DRAG_END_EVENT		= 'listItemDragEnd';

	// Constructor
	MultilistItem (String id, String label)
	{
		this._node = new Element.html('<li class="$CLASS" id="$id">$label</li>');
		
		this._node
		..on['mousedown'].listen(this._inputDownHandler)
		..on['touchstart'].listen(this._inputDownHandler);
		
		this._compose();
	}
	
	// Getters
	bool get isSelected => this._node.classes.contains(SELECTED_CLASS);
	
	// Handle item click
	void _inputDownHandler (Event event)
	{
		this.triggerSelect();
	}
	
	// Trigger select event
	bool triggerSelect ( ) => this._node.dispatchEvent(new CustomEvent(SELECT_EVENT, detail: this.id));
	
	// Select item
	void select ( )
	{
		this._node.classes.add(SELECTED_CLASS);
	}
	
	// Unselect item
	void deselect ( )
	{
		this._node.classes.remove(SELECTED_CLASS);
	}
}