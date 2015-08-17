part of planner;

/**
 *	Interface Element class.
 *	This is base class for any custom GUI elements.
 */
abstract class InterfaceElement
{
	/*
	 * Defaults
	 */
	static const CLASS					= 'gui-element',
				 HOVER_CLASS			= 'gui-element-hovered',
				 ACTIVE_CLASS			= 'gui-element-pressed',
				 DRAGGABLE_CLASS		= 'gui-element-draggable',
				 DISABLE_CLASS			= 'gui-element-disabled',
				 DRAG_START_EVENT		= 'onElementDragStart',
				 DRAG_END_EVENT			= 'onElementDragEnd',
				 DATA_TRANSFER_TYPE		= 'application/json';
				 //DATA_TRANSFER_TYPE		= 'text/plain';

	/*
	 * Data
	 */
	static StreamSubscription interfaceElementsActiveStateReset;
	
	Map<String, StreamSubscription>	_interfaceElementListeners	= new Map<String, StreamSubscription>();
	Map<String, Object>				_draggableData				= new Map<String, Object>();
	String							_typeId;
	Element							_node;
	
	/*
	 * Constructor
	 */
	InterfaceElement ( )
	{
		if (InterfaceElement.interfaceElementsActiveStateReset == null)
		{
			InterfaceElement.interfaceElementsActiveStateReset = window.on['mouseup'].listen(InterfaceElement.resetActiveState);
		}
	}
	
	/*
	 * Getters
	 */
	Element				get node			=> this._node;
	ElementEvents		get on				=> this._node.on;
	String				get id				=> this._node.id;
	bool				get isDraggable		=> this._node.attributes.containsKey('draggable');
	bool				get isNotDraggable	=> !this.isDraggable;
	bool				get isDisabled		=> this._node.classes.contains(DISABLE_CLASS);
	bool				get isEnabled		=> !this.isDisabled;
	
	/*
	 * Setters
	 */
	set id (String id)								=> this._node.id = id;
	set tooltip (String title)						=> this._node.title = title;
	set draggableData (Map<String, Object> data)	=> this._draggableData = data;
	set draggable (bool value)
	{
		if (value == true)
		{
			this._node.classes.add(DRAGGABLE_CLASS);
			this._node.attributes['draggable'] = 'true';
		}
		else
		{
			this._node.classes.remove(DRAGGABLE_CLASS);
			this._node.attributes.remove('draggable');
		}
	}
	
	// Reset all item being pressed
	static void resetActiveState ([ MouseEvent event ])
	{
		for (Element element in querySelectorAll('.$ACTIVE_CLASS'))
		{
			element.classes.remove(ACTIVE_CLASS);
		}
	}
	
	// Block event
	static bool eventBlockHandler (Event event)
	{
		event.preventDefault();
		event.stopPropagation();
		event.stopImmediatePropagation();
		
		return false;
	}
	
	// Compose created element to be interactable
	void _compose ( )
	{
		// Add gui element class
		this._node.classes.add(CLASS);
	
		// Listeners
		this._interfaceElementListeners['onMouseEnter']		= this._node.on['mouseenter'].listen(this._interfaceElementMouseOverHandler);
		this._interfaceElementListeners['onMouseLeave']		= this._node.on['mouseleave'].listen(this._interfaceElementMouseLeaveHandler);
		this._interfaceElementListeners['onMouseDown']		= this._node.on['mousedown'].listen(this._interfaceElementMouseDownHandler);
		this._interfaceElementListeners['onMouseUp']		= this._node.on['mouseup'].listen(this._interfaceElementMouseUpHandler);
		this._interfaceElementListeners['onTouchStart']		= this._node.on['touchstart'].listen(this._interfaceElementMouseDownHandler);
		this._interfaceElementListeners['onTouchEnd']		= this._node.on['touchend'].listen(this._interfaceElementMouseUpHandler);
		this._interfaceElementListeners['onDragStart']		= this._node.on['dragstart'].listen(this._interfaceElementDragStart);
		this._interfaceElementListeners['onDragEnd']		= this._node.on['dragend'].listen(this._interfaceElementDragEnd);
	}
	
	// Handle mouse over
	void _interfaceElementMouseOverHandler (Event event)
	{
		this._node.classes.add(HOVER_CLASS);
	}
	
	// Handle mouse leave
	void _interfaceElementMouseLeaveHandler (Event event)
	{
		this._node.classes.remove(HOVER_CLASS);
		
		// TODO: new Timer(new Duration(miliseconds: 100), () => remove over style on all elements);
	}
	
	// Handle mouse down
	void _interfaceElementMouseDownHandler (Event event)
	{
		this._node.classes.add(ACTIVE_CLASS);
	}
	
	// Handle mouse up
	void _interfaceElementMouseUpHandler (Event event)
	{
		this._node.classes.remove(ACTIVE_CLASS);
	}
	
	/**
	 * Handles drag start
	 */
	void _interfaceElementDragStart (MouseEvent event)
	{
		if (this.isNotDraggable)
		{
			return;
		}
		
		// TODO: Bug: Browsers does't send transferData to onDragOver event
		// This is temp solution
		window.dispatchEvent(new CustomEvent(DRAG_START_EVENT, detail: this._draggableData));
		
		event.dataTransfer.effectAllowed = 'move';
		event.dataTransfer.dropEffect = 'copy';
       	event.dataTransfer.setData(DATA_TRANSFER_TYPE, JSON.encode(this._draggableData));
	}
	
	/**
	 * Handles drag end
	 */
	void _interfaceElementDragEnd (MouseEvent event)
	{
		window.dispatchEvent(new CustomEvent(DRAG_END_EVENT, detail: this._draggableData));
		
		this._interfaceElementMouseUpHandler(event);
	}
	
	// Convert to html text
	@override String toString ( ) => this._node.outerHtml;
	
	// Disable element
	void disable ( )
	{
		this._node.classes.add(DISABLE_CLASS);
		
		// Bind block handler each time due to override
		this._interfaceElementListeners['onClickBlock'] = this._node.on['click'].listen(InterfaceElement.eventBlockHandler);
	}
	
	// Enable element
	void enable ( )
	{
		this._node.classes.remove(DISABLE_CLASS);
		
		// Unbind block handler
		if (this._interfaceElementListeners['onClickBlock'] != null)
		{
			this._interfaceElementListeners['onClickBlock'].cancel();
		}
	}
	
	// Remove element
	void remove ( )
	{
		this._interfaceElementListeners
		.forEach((String name, StreamSubscription listener) =>
												  listener.cancel());
		this._node.remove();
	}
}