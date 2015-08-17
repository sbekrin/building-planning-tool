part of planner;

class LayersWidget extends Widget
{
	/*
	 * Data
	 */
	Multilist						_multilist	= new Multilist();
	Map<String, StreamSubscription>	_listeners	= new Map<String, StreamSubscription>();
	IconButton						_createLayerButton;
	IconButton						_duplicateLayerButton;
	IconButton						_removeLayerButton;
	
	/*
	 * Constructor
	 */
	LayersWidget (Action createLayerAction, Action duplicateLayerAction, Action removeLayerAction):
		super('Layers', id: 'layers', horizal: Widget.SNAP_RIGHT, vertical: Widget.SNAP_BOTTOM)
	{
		this._createLayerButton = new IconButton(new Icon('new'), createLayerAction, tooltip: 'Create new layer');
		this._duplicateLayerButton = new IconButton(new Icon('duplicate'), duplicateLayerAction, tooltip: 'Duplicate active layer');
		this._removeLayerButton = new IconButton(new Icon('trash'), removeLayerAction, tooltip: 'Remove active layer', disabled: true);
		
		this._content.children.add(this._multilist.node);
		this._content.children.add(new BRElement());
		this._content.children.add(this._createLayerButton.node);
		this._content.children.add(this._duplicateLayerButton.node);
		this._content.children.add(this._removeLayerButton.node);
		
		this._listeners['onLayerCreate']	= window.on[Layer.CREATE_EVENT].listen(this._layerCreateHandler);
		this._listeners['onLayerSwitch']	= window.on[Layer.SWITCH_EVENT].listen(this._layerSwitchHandler);
		this._listeners['onLayerRemove']	= window.on[Layer.REMOVE_EVENT].listen(this._layerRemoveHandler);
	}
	
	/**
	 * Handles new layer
	 */
	void _layerCreateHandler (CustomEvent event)
	{
		String id	= event.detail['id'],
			   name	= event.detail['name'];
		
		MultilistItem item = new MultilistItem(id, name);
		
		item.on[MultilistItem.SELECT_EVENT].listen((Event event)
			{
				window.dispatchEvent(new CustomEvent(Layer.SWITCH_EVENT, detail: { 'id': item.id }));
			}
		);
		
		this._multilist.register(item);
		
		// Focus on fresh layer
		item.triggerSelect();
		
		this._checkRemoveButton();
	}
	
	/**
	 * 
	 */
	void _layerSwitchHandler (CustomEvent event)
	{
		this._multilist.items.forEach((MultilistItem item) =>
													 item.id == event.detail['id'] ? item.select() : item.deselect());
	}
	
	/**
	 * Handles layer remove
	 */
	void _layerRemoveHandler (CustomEvent event)
	{
		String id = event.detail['id'];
		
		this._multilist.unregister(id);
		
		// When open project no layers will left
		// So prevent 'no element' exception
		if (this._multilist.items.isNotEmpty)
		{
			this._multilist.items.first.triggerSelect();
		}
		
		this._checkRemoveButton();
	}
	
	/**
	 * Checks remove button
	 */
	void _checkRemoveButton ( )
	{
		if (this._multilist.length <= 1)
		{
			this._removeLayerButton.disable();
			
			return;
		}
		
		this._removeLayerButton.enable();
	}
}