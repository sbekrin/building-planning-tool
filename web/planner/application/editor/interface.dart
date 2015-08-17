part of planner;

/**
 *	Interface class.
 */
class Interface
{
	/*
	 * Data
	 */
	Map<String, StreamSubscription>	_listeners = new Map<String, StreamSubscription>();

	/*
	 * Constructor
	 */
	Interface ( )
	{
		this._listeners['onMSHoldVisual']	= window.on['MSHoldVisual'].listen(this._blockHandler);
		this._listeners['onContextMenu']	= window.on['contextmenu'].listen(this._blockHandler);
		this._listeners['onTouchStart']		= window.on['touchstart'].listen(this._blockHandler);
		this._listeners['onTouchMove']		= window.on['touchmove'].listen(this._blockHandler);
		this._listeners['onTouchEnd']		= window.on['touchstart'].listen(this._blockHandler);
	}
	
	/**
	 * Block event
	 */
	void _blockHandler (Event event)
	{
		event.preventDefault();
	}
}