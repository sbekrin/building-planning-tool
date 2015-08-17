part of planner;

/**
 * Menu section group list box
 */
class MenuSectionGroupList extends MenuSectionGroupItem
{
	/*
	 * Defaults
	 */
	static const CLASS = 'gui-menu-section-content-group-list';
	
	/*
	 * Data
	 */
	List<MenuSectionGroupItem>	_items = new List<MenuSectionGroupItem>();
	bool						_dragable;
	
	/*
	 * Constructor
	 */
	MenuSectionGroupList (List<MenuSectionGroupItem> items, { bool dragable })
	{
		this._dragable = dragable;
		
		this._node = new Element.html('<span class="$CLASS"></span>');
		
		this.registerAll(items);
	}
	
	/**
	 * 
	 */
	void register (MenuSectionGroupItem item)
	{
		this._items.add(item);
		this._node.children.add(item.node);
		
		if (this._dragable == true)
		{
			item.draggable = true;
		}
	}
	
	/**
	 * 
	 */
	void registerAll (List<MenuSectionGroupItem> items)
	{
		items.forEach((MenuSectionGroupItem item) =>
											this.register(item));
	}
}