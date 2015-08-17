part of planner;

/*
 *	Multi List class.
 *
 *	Allows to render multi-line lists.
 */
class Multilist extends InterfaceElement
{
	// Defaults
	static const CLASS			= 'gui-multilist',
				 CHANGE_EVENT	= 'multilistChange',
				 MAX_SELECTIONS	= 1;
	
	// Data
	List<MultilistItem>	_items			= new List<MultilistItem>();
	int					_maxSelections	= MAX_SELECTIONS;

	// Constructor
	Multilist ({ int maxSelections })
	{
		this._node = new Element.html('<ul class="$CLASS"></ul>');
		
		if (maxSelections != null)
		{
			this._maxSelections = maxSelections;
		}
		
		this._compose();
	}
	
	// Getters
	List<MultilistItem>	get items => this._items;
	int get length => this._items.length;
	
	// Handle item selection
	void _itemSelectionHandler (CustomEvent event)
	{
		// If single-item mode
		if (this._maxSelections == 1)
		{
			this._items.forEach((MultilistItem item) => item.deselect());
		}
		
		// TODO: Multi selection via SHIFT and CTRL
		else if (this._maxSelections > 1)
		{
			throw new Exception('Not supported yet');
		}
		
		// Select selected item
		String targetItemId = event.detail;
		
		for (MultilistItem item in this._items)
		{
			if (item.id == targetItemId)
			{
				item.select();
				
				return;
			}
		}
		
		// If no such item
		throw new Exception('Unknown MultiListItem id');
	}
	
	// Add single item
	void register (MultilistItem item)
	{
		item.on[MultilistItem.SELECT_EVENT].listen(this._itemSelectionHandler);
		
		this._items.add(item);
		this._node.children.add(item.node);
	}
	
	// Remove single item
	void unregister (String itemId)
	{
		//this._items.removeWhere((MultilistItem item) => item.id == itemId);
	
		for (MultilistItem item in this._items)
		{
			if (item.id == itemId)
			{
				item.remove();
			
				this._items.remove(item);
			
				break;
			}
		}
	}
	
	//
	int indexOf (MultilistItem item) => this.items.indexOf(item);
}