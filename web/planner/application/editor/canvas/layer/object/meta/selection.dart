part of planner;

/**
 * Selection class provides visual feedback of
 * selected objects and provides event trigger
 */
class Selection
{
	// Defaults
	static const // Classes
				 CLASS				= 'selection',
						 
				 // Events
				 SELECT_EVENT		= 'onContentSelect',
				 AREA_SELECT_EVENT	= 'onContentAreaSelect',
				 DESELECT_EVENT		= 'onContentDeselect';
	
	// Data
	Point		_start;
	Point		_end;
	Element		_node;
	bool		_active		= false;
	
	/*
	 * Constructor
	 */
	Selection ( )
	{
		this._node = new PathElement();
		
		this._node.classes.add(CLASS);
	}
	
	/*
	 * Getters
	 */
	Element		get node		=> this._node;
	bool		get isActive	=> this._active;
	bool		get isNotActive	=> !this.isActive;
	
	/**
	 * Update selection area
	 */
	void update (Point end)
	{
		this._end = end;
		
		// Find mins and maxs
		num minX = Math.min(this._start.x, this._end.x),
			maxX = Math.max(this._start.x, this._end.x),
			minY = Math.min(this._start.y, this._end.y),
			maxY = Math.max(this._start.y, this._end.y);
		
		// Compile points to path data
		this._node.attributes['d'] = 'M$minX,$minY L$minX,$maxY L$maxX,$maxY L$maxX,$minY Z';
	}
	
	/**
	 * Starts selection at set point
	 */
	void startSelectionAt (Point fromPoint)
	{
		this._active = true;
		this._start = this._end = fromPoint;
	}
	
	/**
	 * Ends selection
	 */
	void endSelection ( )
	{
		if (this.isNotActive)
		{
			return;
		}
		
		// Send SELECT_EVENT event before coordinates reset
		window.dispatchEvent(new CustomEvent(AREA_SELECT_EVENT, detail: { 'start': this._start, 'end': this._end }));
		
		this._active = false;
		this._start = this._end = new Point(0, 0);
		this._node.attributes['d'] = 'M0,0Z';
	}
}