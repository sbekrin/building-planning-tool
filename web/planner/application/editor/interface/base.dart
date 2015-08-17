part of planner;

class InterfaceItem
{
	/*
	 * Data
	 */
	Element							_node;
	ContextBubble					_contextBubble;
	Map<String, StreamSubscription>	_interfaceItemListeners = new Map<String, StreamSubscription>();
	
	/**
	 * Bind context bubble events
	 */
	void _bindContextBubbleEvents ( )
	{
		// Check if object provides custom bubble
		if (this is IContextBubbleProvider)
		{
			this._interfaceItemListeners['onInterfaceItemMouseDown']	= this.on['mousedown'].listen(this._interfaceItemClickHandler);
			this._interfaceItemListeners['onInterfaceItemContextMenu']	= this.on['contextmenu'].listen(this._interfaceItemContextMenuHandler);
		}
	}
	
	/*
	 * Getters
	 */
	ElementEvents get on => this._node.on;
	
	/**
	 * 
	 */
	void _interfaceItemClickHandler (MouseEvent event)
	{
		this._interfaceItemRemoveContextBubble();
		
		event.preventDefault();
	}
	
	/**
	 * 
	 */
	void _interfaceItemContextMenuHandler (MouseEvent event)
	{
		this._interfaceItemRemoveContextBubble();
		
		ContextBubble bubble = new ContextBubble(event.client);
		
		for (ContextBubbleOption option in (this as IContextBubbleProvider).contextBubbleItems)
		{
			bubble.register(option);
		}
		
		this._contextBubble = bubble;
		
		this._node.children.add(this._contextBubble.node);
		
		event.preventDefault();
	}
	
	/**
	 * 
	 */
	void _interfaceItemRemoveContextBubble ( )
	{
		if (this._contextBubble != null)
		{
			this._contextBubble.removeNode();
			this._contextBubble = null;
		}
	}
}