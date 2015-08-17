part of planner;

class MenuShortcut extends MenuItem
{
	/*
	 * Defaults
	 */
	static const CLASS			= 'gui-menu-shortcut',
				 ICON_CLASS		= 'gui-menu-shortcut-icon';
	
	/*
	 * Data
	 */
	Map<String, StreamSubscription>	_listeners	= new Map<String, StreamSubscription>();
	Action							_action;
	
	/*
	 * Constructor
	 */
	MenuShortcut (Icon icon, Action action)
	{
		this._action = action;
		
		this._node = new Element.html('''
        	<li class="$CLASS">
				<span class="$ICON_CLASS">${icon}</span>
			</li>
		''');
		
		this._listeners['onMouseDown'] = this._node.on['mousedown'].listen(this._inputDeviceDownHandler);
		this._listeners['onTouchDown'] = this._node.on['touchdown'].listen(this._inputDeviceDownHandler);
		
		this._compose();
	}
	
	/**
	 * Handles click
	 */
	void _inputDeviceDownHandler (Event event)
	{
		this._action.execute();
	}
}