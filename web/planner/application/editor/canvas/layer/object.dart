part of planner;

/**
 * Any object being dropped to editor
 */
abstract class CanvasObject
{
	/*
	 * Defaults
	 */
	static const String CLASS = 'canvas-object';
	
	/*
	 * Data
	 */
	Element _node;

	/*
	 * Constructor
	 */
	CanvasObject ( )
	{
		this._node = new GElement();
	}
	
	/*
	 * Getters
	 */
	Element get node => this._node;
	
	/**
	 * Removes node element
	 */
	void removeNode ( )
	{
		this._node.remove();
	}
}