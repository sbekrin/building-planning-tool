part of planner;

/**
 * CanvasObject is base class for any canvas objects
 */
abstract class EditableCanvasObject extends CanvasObject implements ISelectable, IRemovable, IRangeable
{
	/*
	 * Defaults
	 */
	static const SELECTED_CLASS			= 'canvas-object-selected',
				 ALIGN_REQUIRED_EVENT	= 'onAlignLineRequired';
	
	/*
	 * Data
	 */
	Map<String, StreamSubscription>	_listeners	= new Map<String, StreamSubscription>();
	
	/*
	 * Bind direct selection events
	 */
	void _bindSelectionEvents ( )
	{
		this._listeners['onCanvasObjectMouseDown']		= this._node.on['mousedown'].listen(this._canvasObjectSelectHandler);
		this._listeners['onCanvasObjectTouchStart']		= this._node.on['touchstart'].listen(this._canvasObjectSelectHandler);
	}
	
	/*
	 *	Getters
	 */
	bool	get isSelected		=> this._node.classes.contains(SELECTED_CLASS);
	bool	get isNotSelected	=> !this.isSelected;
	
	/**
	 * Handles mouse click
	 */
	void _canvasObjectSelectHandler (Event event)
	{
		// Accept selection tool only
		if (Tool.active != Tool.SELECT)
		{
			return;
		}
		
		// If mouse click accept left click only
		if (event is MouseEvent &&
			event.which != 1)
		{
			return;
		}
		
		this._triggerSelect();
		
		event.preventDefault();
		event.stopPropagation();
	}
	
	/**
	 * Triggers single object selection
	 */
	void _triggerSelect ( )
	{
		window.dispatchEvent(new CustomEvent(Selection.SELECT_EVENT, detail: { 'content': [ this.hashCode ]}));
	}
	
	/**
	 * Triggers single object deselection
	 */
	void _triggerDeselect ( )
	{
		window.dispatchEvent(new CustomEvent(Selection.DESELECT_EVENT, detail: { 'content': [ this.hashCode ]}));
	}
	
	/**
	 * Checks if object on selection area
	 */
	@override bool inRange (Rectangle area);
	
	/**
	 * Converts object to portable map object
	 */
	Map<String, Object> toMap ( );
	
	/**
	 * Adds visual object highlight
	 */
	void select ( )
	{
		this._node.classes.add(SELECTED_CLASS);
	}
	
	/**
	 * Removes visual object highlight
	 */
	void deselect ( )
   	{
   		this._node.classes.remove(SELECTED_CLASS);
   	}
	
	/**
	 * Removes node element
	 */
	void removeNode ( )
	{
		this._listeners
		.forEach((String name, StreamSubscription listener) =>
												  listener.cancel());
		
		super.removeNode();
	}
}