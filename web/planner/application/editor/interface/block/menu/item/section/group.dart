part of planner;

/**
 * Menu section group item
 * 
 * Stores items group
 */
class MenuSectionGroup extends InterfaceElement
{
	/*
	 * Defaults
	 */
	static const CLASS			= 'gui-menu-section-content-group',
				 CONTENT_CLASS	= 'gui-menu-section-content-group-content',
				 LABEL_CLASS	= 'gui-menu-section-content-group-label';
	
	
	/*
	 * Data
	 */
	List<MenuSectionGroupItem> _items = new List<MenuSectionGroupItem>();
	
	/*
	 * Constructor
	 */
	MenuSectionGroup (String label, [ List<MenuSectionGroupItem> items ])
	{
		this._node = new Element.html('''
			<span class="$CLASS">
				<span class="$CONTENT_CLASS"></span>
				<span class="$LABEL_CLASS"></span>
			</span>
		''');
		
		this._compose();
		
		this._labelNode.text = label;
		
		this.registerAll(items);
	}
	
	/*
	 * Getters
	 */
	Element		get	_contentNode	=> this._node.querySelector('.$CONTENT_CLASS');
	Element		get _labelNode		=> this._node.querySelector('.$LABEL_CLASS');
	
	/**
	 * Registers single item
	 */
	void register (MenuSectionGroupItem item)
	{
		this._items.add(item);
		this._contentNode.children.add(item.node);
	}
	
	/**
	 * Registers bunch of items
	 */
	void registerAll (List<MenuSectionGroupItem> items)
	{
		items.forEach((MenuSectionGroupItem item) =>
											this.register(item));
	}
}